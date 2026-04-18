import Foundation

@MainActor
class AuthManager: ObservableObject {
    @Published var currentUser: AppUser?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    static let shared = AuthManager()
    private init() {}

    func signUp(email: String, username: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            struct Body: Encodable { let email: String; let username: String; let id: String }
            let id = UUID().uuidString
            currentUser = try await APIClient.shared.post("/users/", body: Body(email: email, username: username, id: id))
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signInMock(username: String) {
        // Para demo: crea usuario local sin red
        currentUser = AppUser(
            id: UUID(),
            email: "\(username)@drop.mx",
            username: username,
            avatarUrl: nil,
            rallyScore: 0,
            ralliesAttended: 0,
            createdAt: Date()
        )
        isAuthenticated = true
    }

    func signOut() {
        currentUser = nil
        isAuthenticated = false
    }
}
