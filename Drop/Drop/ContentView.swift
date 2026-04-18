import SwiftUI

struct ContentView: View {
    @StateObject var appState = AppState()

    var body: some View {
        Group {
            if appState.isLoggedIn {
                MainTabView()
                    .environmentObject(appState)
            } else {
                LoginView()
                    .environmentObject(appState)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.isLoggedIn)
    }
}

// MARK: - Main Tab Coordinator
struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var showCreateSheet = false
    @State private var showDetail = false

    var body: some View {
        ZStack {
            switch appState.selectedTab {
            case .map:
                MapView()
            case .feed:
                FeedView()
            case .create:
                Color.clear
                    .onAppear { showCreateSheet = true }
                    .onChange(of: appState.selectedTab) { _, new in
                        if new == .create { showCreateSheet = true }
                    }
            case .saved:
                SavedView()
            case .profile:
                ProfileView()
            }
        }
        .sheet(isPresented: $showCreateSheet, onDismiss: {
            if appState.selectedTab == .create {
                appState.selectedTab = .feed
            }
        }) {
            CreateEventView()
                .environmentObject(appState)
        }
        .sheet(item: $appState.selectedEvent) { event in
            EventDetailView(event: event)
        }
    }
}

// MARK: - Saved View (placeholder)
struct SavedView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(BullaTheme.Gradients.brand)
                Text("Guardados")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                Text("Aquí aparecerán los eventos que guardes")
                    .font(BullaTheme.Font.body(15))
                    .foregroundColor(BullaTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor.systemGroupedBackground))
            .overlay(alignment: .bottom) {
                BullaTabBar(selected: $appState.selectedTab)
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - App Entry Point
//@main
struct BullaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - Preview
#Preview("Login") {
    LoginView()
        .environmentObject(AppState())
}

#Preview("App (autenticado)") {
    let state = AppState()
    state.authState = .authenticated(.sample)
    state.isLoggedIn = true
    return MainTabView()
        .environmentObject(state)
}

#Preview("Mapa") {
    let state = AppState()
    state.isLoggedIn = true
    state.authState = .authenticated(.sample)
    return MapView().environmentObject(state)
}

#Preview("Feed") {
    let state = AppState()
    state.isLoggedIn = true
    state.authState = .authenticated(.sample)
    return FeedView().environmentObject(state)
}

#Preview("Detalle") {
    EventDetailView(event: Event.sampleEvents[0])
}

#Preview("Crear evento") {
    CreateEventView()
        .environmentObject(AppState())
}

#Preview("Perfil") {
    let state = AppState()
    state.authState = .authenticated(.sample)
    return ProfileView().environmentObject(state)
}
