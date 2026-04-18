import Foundation
import Combine

// MARK: - App Navigation
enum AppTab {
    case map, feed, create, saved, profile
}

enum AuthState {
    case unauthenticated
    case authenticated(User)
}

// MARK: - AppState
@MainActor
class AppState: ObservableObject {

    // Auth
    @Published var authState: AuthState = .unauthenticated
    @Published var isLoggedIn: Bool = false

    // Navigation
    @Published var selectedTab: AppTab = .map
    @Published var selectedEvent: Event? = nil

    // Data
    @Published var events: [Event] = []
    @Published var savedEvents: [Event] = []
    @Published var isLoadingEvents: Bool = false
    @Published var savedEventIds: Set<String> = []
    @Published var recommendationText: String = "Descubriendo eventos para ti..."
    @Published var hotZones: [HotZone] = []
    @Published var hotZoneSummary: String = "Analizando en qué zona suele prenderse la ciudad..."
    @Published var hotZoneInsightSource: String = "Motor local"
    @Published var isLoadingHotZones: Bool = false

    var currentUser: User? {
        if case .authenticated(let user) = authState { return user }
        return nil
    }

    var currentUserId: String? {
        UserDefaults.standard.string(forKey: "dropUserId")
    }

    // MARK: - Auth

    func login(email: String, username: String) {
        authState = .authenticated(User(name: username, username: username))
        isLoggedIn = true

        Task { @MainActor in
            if let dto = try? await DropService.shared.loginOrCreate(email: email, username: username) {
                UserDefaults.standard.set(dto.id, forKey: "dropUserId")
                authState = .authenticated(User(from: dto))
            }
            await loadEvents()
            await loadSaved()
            await loadRecommendations()
        }
    }

    // Llamar una vez al arrancar para limpiar IDs corruptos
    func clearCorruptedUserId() {
        UserDefaults.standard.removeObject(forKey: "dropUserId")
    }

    func logout() {
        authState = .unauthenticated
        isLoggedIn = false
        selectedTab = .map
        events = []
        savedEvents = []
        savedEventIds = []
        hotZones = []
        hotZoneSummary = "Analizando en qué zona suele prenderse la ciudad..."
        hotZoneInsightSource = "Motor local"
        UserDefaults.standard.removeObject(forKey: "dropUserId")
    }

    // MARK: - Data Loading

    func loadEvents(category: String? = nil, search: String? = nil) async {
        isLoadingEvents = true
        do {
            let fetched = try await DropService.shared.fetchRallies(category: category, search: search)
            if !fetched.isEmpty {
                events = fetched
            }
        } catch {
            // Mantiene los eventos existentes si la API no responde
        }
        isLoadingEvents = false
        await loadSaved()
        await loadHotZones()
    }

    func loadSaved() async {
        guard let userId = currentUserId else { return }
        do {
            savedEvents = try await DropService.shared.fetchSaved(userId: userId)
            savedEventIds = Set(savedEvents.map { $0.id.uuidString.lowercased() })
        } catch {}
    }

    func loadRecommendations() async {
        guard let userId = currentUserId else { return }
        do {
            let (_, reason) = try await DropService.shared.fetchRecommendations(userId: userId)
            recommendationText = reason
        } catch {
            recommendationText = "Eventos cerca de ti"
        }
    }

    // MARK: - Event Actions

    func isSaved(_ event: Event) -> Bool {
        savedEventIds.contains(event.id.uuidString.lowercased())
    }

    func toggleSave(_ event: Event) {
        guard let userId = currentUserId else { return }
        let rallyId = event.id.uuidString.lowercased()
        let alreadySaved = savedEventIds.contains(rallyId)

        // Optimistic update
        if alreadySaved {
            savedEventIds.remove(rallyId)
            savedEvents.removeAll { $0.id == event.id }
        } else {
            savedEventIds.insert(rallyId)
            savedEvents.append(event)
        }

        Task {
            do {
                if alreadySaved {
                    try await DropService.shared.unsaveRally(rallyId: rallyId, userId: userId)
                } else {
                    try await DropService.shared.saveRally(rallyId: rallyId, userId: userId)
                }
            } catch {
                // Revert on failure
                if alreadySaved {
                    savedEventIds.insert(rallyId)
                    savedEvents.append(event)
                } else {
                    savedEventIds.remove(rallyId)
                    savedEvents.removeAll { $0.id == event.id }
                }
            }
        }
    }

    func joinEvent(_ event: Event) {
        guard let userId = currentUserId else { return }
        Task {
            try? await DropService.shared.joinRally(
                rallyId: event.id.uuidString.lowercased(),
                userId: userId
            )
        }
    }

    // Called after publishing a new event
    func afterPublish() {
        Task {
            await loadEvents()
        }
        selectedTab = .feed
    }

    func loadHotZones() async {
        isLoadingHotZones = true
        hotZoneInsightSource = "Motor local"

        let history: [Event]
        if let userId = currentUserId {
            history = (try? await DropService.shared.fetchPast(userId: userId)) ?? []
        } else {
            history = []
        }

        var generatedZones = HotZoneEngine().generateHotZones(
            currentEvents: events,
            historicalEvents: history
        )

        if let firstZone = generatedZones.first {
            if let aiInsight = await AppleHotZoneNarrator.shared.insight(for: firstZone) {
                generatedZones[0].insight = aiInsight
                hotZoneSummary = aiInsight
                hotZoneInsightSource = "Apple Intelligence"
            } else {
                hotZoneSummary = firstZone.fallbackInsight
            }
        } else {
            hotZoneSummary = "Todavía no hay suficiente historial para detectar una zona caliente."
        }

        hotZones = generatedZones
        isLoadingHotZones = false
    }
}