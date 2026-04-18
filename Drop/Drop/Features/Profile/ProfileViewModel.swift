import Foundation

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var attendedRallies: [Rally] = []
    @Published var isLoading = false

    func loadProfile() async {
        guard let uid = AuthManager.shared.currentUser?.id.uuidString else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            attendedRallies = try await APIClient.shared.get("/users/\(uid)/rallies")
        } catch {}
    }

    var badges: [String] {
        guard let user = AuthManager.shared.currentUser else { return [] }
        var result: [String] = []
        if user.ralliesAttended >= 1 { result.append("First Drop") }
        if user.ralliesAttended >= 5 { result.append("5 Rallies") }
        if user.rallyScore >= 100 { result.append("Top Rated") }
        return result
    }
}
