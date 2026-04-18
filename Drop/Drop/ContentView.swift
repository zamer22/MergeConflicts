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

// MARK: - Saved View
struct SavedView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                HStack {
                    Text("Guardados")
                        .font(.system(size: 26, weight: .black, design: .rounded))
                    Spacer()
                    if !appState.savedEvents.isEmpty {
                        Text("\(appState.savedEvents.count)")
                            .font(BullaTheme.Font.body(13, weight: .bold))
                            .foregroundColor(BullaTheme.Colors.textSecondary)
                    }
                }
                .padding(.horizontal, BullaTheme.Spacing.lg)
                .padding(.top, 12)
                .padding(.bottom, 16)

                if appState.savedEvents.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "heart")
                            .font(.system(size: 44))
                            .foregroundColor(BullaTheme.Colors.textSecondary)
                        Text("Aún no has guardado eventos")
                            .font(BullaTheme.Font.body(15))
                            .foregroundColor(BullaTheme.Colors.textSecondary)
                        Text("Dale al corazón en cualquier evento")
                            .font(BullaTheme.Font.body(13))
                            .foregroundColor(BullaTheme.Colors.textSecondary.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(appState.savedEvents) { event in
                            Button { appState.selectedEvent = event } label: {
                                HStack(spacing: 10) {
                                    EventImagePlaceholder(category: event.category, height: 48)
                                        .frame(width: 48, height: 48)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(event.title)
                                            .font(BullaTheme.Font.body(13, weight: .bold))
                                            .lineLimit(1)
                                            .foregroundColor(BullaTheme.Colors.ink)
                                        Text(event.location)
                                            .font(BullaTheme.Font.body(11))
                                            .foregroundColor(BullaTheme.Colors.textSecondary)
                                    }
                                    Spacer()
                                    Button {
                                        appState.toggleSave(event)
                                    } label: {
                                        Image(systemName: "heart.fill")
                                            .font(.system(size: 18))
                                            .foregroundColor(BullaTheme.Colors.brand)
                                    }
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal, BullaTheme.Spacing.lg)
                                .overlay(alignment: .bottom) {
                                    Rectangle().fill(BullaTheme.Colors.line.opacity(0.5)).frame(height: 1)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Spacer().frame(height: 90)
            }
        }
        .scrollIndicators(.hidden)
        .background(Color(UIColor.systemGroupedBackground))
        .safeAreaInset(edge: .bottom) {
            BullaTabBar(selected: $appState.selectedTab)
        }
        .task { await appState.loadSaved() }
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
