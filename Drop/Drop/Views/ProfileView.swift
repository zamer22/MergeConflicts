import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState

    @State private var selectedTab = 0
    @State private var upcomingEvents: [Event] = []
    @State private var pastEvents: [Event] = []
    @State private var createdEvents: [Event] = []
    @State private var isLoading = false

    let tabs = ["Próximos", "Pasados", "Publicados"]

    var user: User { appState.currentUser ?? .sample }

    var currentTabEvents: [Event] {
        switch selectedTab {
        case 0: return upcomingEvents
        case 1: return pastEvents
        case 2: return createdEvents
        default: return []
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // Header
                HStack {
                    Text("Mi perfil")
                        .font(.system(size: 26, weight: .black, design: .rounded))
                    Spacer()
                    Button(action: { appState.logout() }) {
                        Text("Salir")
                            .font(BullaTheme.Font.body(13))
                            .foregroundColor(BullaTheme.Colors.brand)
                    }
                }
                .padding(.horizontal, BullaTheme.Spacing.lg)
                .padding(.top, 12)
                .padding(.bottom, 16)

                // Avatar + Info
                HStack(spacing: 14) {
                    ZStack(alignment: .bottomTrailing) {
                        BullaAvatar(
                            initial: user.initial,
                            size: 68,
                            gradient: [Color(hex: "#CBD5E1"), Color(hex: "#94A3B8")]
                        )
                        Circle()
                            .fill(BullaTheme.Colors.brand)
                            .frame(width: 20, height: 20)
                            .overlay(
                                Image(systemName: "plus")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .overlay(Circle().stroke(.white, lineWidth: 1.5))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.name)
                            .font(BullaTheme.Font.heading(17))
                        Text("@\(user.username) · \(user.location)")
                            .font(BullaTheme.Font.body(12))
                            .foregroundColor(BullaTheme.Colors.textSecondary)

                        HStack(spacing: 12) {
                            StatItem(value: "\(user.totalEventsAttended)", label: "eventos")
                            StatItem(value: "\(createdEvents.count)", label: "creados")
                        }
                    }
                }
                .padding(.horizontal, BullaTheme.Spacing.lg)
                .padding(.bottom, 14)

                // Interests
                if !user.interests.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("MIS INTERESES")
                            .font(BullaTheme.Font.body(11, weight: .bold))
                            .foregroundColor(BullaTheme.Colors.textSecondary)
                            .tracking(0.5)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(user.interests) { interest in
                                    HStack(spacing: 4) {
                                        Image(systemName: interest.icon)
                                            .font(.system(size: 10))
                                        Text(interest.rawValue)
                                            .font(BullaTheme.Font.body(11, weight: .medium))
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(BullaTheme.Colors.brand)
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                                }
                                Button(action: {}) {
                                    Text("+ editar")
                                        .font(BullaTheme.Font.body(11))
                                        .foregroundColor(BullaTheme.Colors.textSecondary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .overlay(Capsule().stroke(BullaTheme.Colors.line, style: StrokeStyle(lineWidth: 1.5, dash: [4])))
                                }
                            }
                            .padding(.horizontal, BullaTheme.Spacing.lg)
                        }
                    }
                    .padding(.bottom, 14)
                }

                // AI Recommendation
                HStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            AIBadge(label: "IA")
                            Text("recomendación")
                                .font(BullaTheme.Font.body(11))
                                .foregroundColor(BullaTheme.Colors.textSecondary)
                        }
                        Text(appState.recommendationText)
                            .font(BullaTheme.Font.body(12))
                            .foregroundColor(BullaTheme.Colors.ink)
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(BullaTheme.Gradients.aiCard)
                .clipShape(RoundedRectangle(cornerRadius: BullaTheme.Radius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: BullaTheme.Radius.md)
                        .stroke(Color(hex: "#FED7AA"), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                )
                .padding(.horizontal, BullaTheme.Spacing.lg)
                .padding(.bottom, 14)

                // Tabs
                HStack(spacing: 0) {
                    ForEach(Array(tabs.enumerated()), id: \.offset) { i, tab in
                        Button(action: { selectedTab = i }) {
                            VStack(spacing: 6) {
                                Text(tab)
                                    .font(BullaTheme.Font.body(12, weight: selectedTab == i ? .bold : .medium))
                                    .foregroundColor(selectedTab == i ? BullaTheme.Colors.ink : BullaTheme.Colors.textSecondary)
                                Rectangle()
                                    .fill(selectedTab == i ? BullaTheme.Colors.brand : .clear)
                                    .frame(height: 2.5)
                            }
                            .padding(.horizontal, 12)
                            .padding(.top, 8)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .overlay(alignment: .bottom) {
                    Rectangle().fill(BullaTheme.Colors.line).frame(height: 1)
                }
                .padding(.bottom, 8)

                // Event list
                if isLoading {
                    ProgressView().frame(maxWidth: .infinity).padding(.top, 30)
                } else if currentTabEvents.isEmpty {
                    Text("Sin eventos en esta sección")
                        .font(BullaTheme.Font.body(13))
                        .foregroundColor(BullaTheme.Colors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 30)
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(currentTabEvents) { event in
                            Button { appState.selectedEvent = event } label: {
                                ProfileEventRow(event: event, status: selectedTab == 0 ? "Voy" : selectedTab == 1 ? "Fui" : "Creé")
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, BullaTheme.Spacing.lg)
                }

                Spacer().frame(height: 90)
            }
        }
        .scrollIndicators(.hidden)
        .background(Color(UIColor.systemGroupedBackground))
        .safeAreaInset(edge: .bottom) {
            BullaTabBar(selected: $appState.selectedTab)
        }
        .task {
            await loadProfileEvents()
        }
        .onChange(of: appState.currentUser?.id) { _, _ in
            Task { await loadProfileEvents() }
        }
    }

    private func loadProfileEvents() async {
        guard let userId = appState.currentUserId else { return }
        isLoading = true
        async let upcoming = (try? await DropService.shared.fetchUpcoming(userId: userId)) ?? []
        async let past = (try? await DropService.shared.fetchPast(userId: userId)) ?? []
        async let created = (try? await DropService.shared.fetchCreated(userId: userId)) ?? []
        (upcomingEvents, pastEvents, createdEvents) = await (upcoming, past, created)
        isLoading = false
    }
}

// MARK: - Stat Item
private struct StatItem: View {
    let value: String
    let label: String

    var body: some View {
        HStack(spacing: 3) {
            Text(value)
                .font(BullaTheme.Font.body(12, weight: .bold))
            Text(label)
                .font(BullaTheme.Font.body(12))
                .foregroundColor(BullaTheme.Colors.textSecondary)
        }
    }
}

// MARK: - Profile Event Row
struct ProfileEventRow: View {
    let event: Event
    let status: String

    var body: some View {
        HStack(spacing: 10) {
            EventImagePlaceholder(category: event.category, height: 42)
                .frame(width: 42, height: 42)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(BullaTheme.Font.body(13, weight: .bold))
                    .lineLimit(1)
                Text(event.location)
                    .font(BullaTheme.Font.body(11))
                    .foregroundColor(BullaTheme.Colors.textSecondary)
            }
            Spacer()
            BullaChip(
                text: status,
                style: status == "Voy" ? .live : .default
            )
        }
        .padding(.vertical, 8)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(BullaTheme.Colors.line.opacity(0.5))
                .frame(height: 1)
        }
    }
}

// MARK: - Preview
#Preview {
    ProfileView()
        .environmentObject({
            let s = AppState()
            s.authState = .authenticated(.sample)
            return s
        }())
}
