import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    @Published var rallies: [Rally] = []
    @Published var venues: [String: Venue] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadRallies() async {
        isLoading = true
        defer { isLoading = false }
        do {
            rallies = try await APIClient.shared.get("/rallies/")
            await loadVenues()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadVenues() async {
        do {
            let all: [Venue] = try await APIClient.shared.get("/venues/")
            venues = Dictionary(uniqueKeysWithValues: all.map { ($0.id.uuidString, $0) })
        } catch {}
    }

    func venue(for rally: Rally) -> Venue? {
        guard let id = rally.venueId else { return nil }
        return venues[id.uuidString]
    }
}
