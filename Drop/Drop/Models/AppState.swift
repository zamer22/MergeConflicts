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

    // Current User
    var currentUser: User? {
        if case .authenticated(let user) = authState { return user }
        return nil
    }

    // MARK: - Auth Actions
    func login(email: String, password: String) {
        // Mock login — replace with real auth
        let user = User.sample
        authState = .authenticated(user)
        isLoggedIn = true
    }

    func loginWithGoogle() {
        let user = User.sample
        authState = .authenticated(user)
        isLoggedIn = true
    }

    func logout() {
        authState = .unauthenticated
        isLoggedIn = false
        selectedTab = .map
    }

    // MARK: - Event Actions
    func joinEvent(_ event: Event) {
        // TODO: join logic
    }

    func saveEvent(_ event: Event) {
        // TODO: save logic
    }
}
