import SwiftUI

struct ContentView: View {
    @EnvironmentObject var auth: AuthManager

    var body: some View {
        if auth.isAuthenticated {
            TabView {
                HomeView()
                    .tabItem { Label("Home", systemImage: "map.fill") }
                ProfileView()
                    .tabItem { Label("Perfil", systemImage: "person.fill") }
            }
            .tint(.orange)
        } else {
            LoginView()
        }
    }
}
