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
    @Published var events: [Event] = Event.sampleEvents
    @Published var recommendationText: String = "Descubriendo eventos para ti..."
    @Published var hotZones: [HotZone] = []
    @Published var hotZoneSummary: String = "Analizando en qué zona suele prenderse la ciudad..."
    @Published var hotZoneInsightSource: String = "Motor local"
    @Published var isLoadingHotZones: Bool = false

    // Current User
    var currentUser: User? {
        if case .authenticated(let user) = authState { return user }
        return nil
    }

    var currentUserId: String? {
        UserDefaults.standard.string(forKey: "dropUserId")
    }

    // MARK: - Auth Actions

    func login(email: String, password: String) {
        let username = email.components(separatedBy: "@").first ?? "usuario"
        authState = .authenticated(User(name: username, username: username))
        isLoggedIn = true

        Task { @MainActor in
            if let savedId = currentUserId {
                if let dto = try? await DropService.shared.fetchUser(id: savedId) {
                    authState = .authenticated(User(from: dto))
                }
            } else {
                let newId = UUID().uuidString.lowercased()
                if let dto = try? await DropService.shared.createUser(id: newId, email: email, username: username) {
                    UserDefaults.standard.set(newId, forKey: "dropUserId")
                    authState = .authenticated(User(from: dto))
                } else {
                    UserDefaults.standard.set(newId, forKey: "dropUserId")
                }
            }
            await loadEvents()
            await loadRecommendations()
        }
    }

    func loginWithGoogle() {
        login(email: "demo@drop.app", password: "")
    }

    func logout() {
        authState = .unauthenticated
        isLoggedIn = false
        selectedTab = .map
        events = Event.sampleEvents
        hotZones = []
        hotZoneSummary = "Analizando en qué zona suele prenderse la ciudad..."
        hotZoneInsightSource = "Motor local"
    }

    // MARK: - Data Loading

    func loadEvents(category: String? = nil, search: String? = nil) async {
        do {
            let fetched = try await DropService.shared.fetchRallies(category: category, search: search)
            if !fetched.isEmpty {
                events = fetched
            }
        } catch {
            // Mantiene los eventos de muestra si la API no responde
        }
        await loadHotZones()
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

    func joinEvent(_ event: Event) {
        guard let userId = currentUserId else { return }
        Task {
            try? await DropService.shared.joinRally(
                rallyId: event.id.uuidString.lowercased(),
                userId: userId
            )
        }
    }

    func saveEvent(_ event: Event) {
        guard let userId = currentUserId else { return }
        Task {
            try? await DropService.shared.saveRally(
                rallyId: event.id.uuidString.lowercased(),
                userId: userId
            )
        }
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
