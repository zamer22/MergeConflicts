import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState

    @State private var selectedTab = 0
    let tabs = ["Próximos", "Pasados", "Publicados"]

    var user: User { appState.currentUser ?? .sample }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // Header
                    HStack {
                        Text("Mi perfil")
                            .font(.system(size: 26, weight: .black, design: .rounded))
                        Spacer()
                        Button(action: {}) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 18))
                                .foregroundColor(BullaTheme.Colors.textSecondary)
                        }
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
                                gradient: [Color(hex: "#FFD8C6"), Color(hex: "#FF9A7A")]
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
                                StatItem(value: "\(user.followerCount)", label: "seguidores")
                                StatItem(value: "\(user.followingCount)", label: "sigo")
                            }
                        }
                    }
                    .padding(.horizontal, BullaTheme.Spacing.lg)
                    .padding(.bottom, 14)

                    // Interests
                    VStack(alignment: .leading, spacing: 8) {
                        Text("MIS INTERESES")
                            .font(BullaTheme.Font.body(11, weight: .bold))
                            .foregroundColor(BullaTheme.Colors.textSecondary)
                            .tracking(0.5)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(user.interests) { interest in
                                    BullaChip(text: "\(interest.icon) \(interest.rawValue)", style: .brand)
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

                    // AI Recommendation
                    HStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 6) {
                                AIBadge(label: "IA")
                                Text("recomendación")
                                    .font(BullaTheme.Font.body(11))
                                    .foregroundColor(BullaTheme.Colors.textSecondary)
                            }
                            Text("Basado en tus gustos: **Bazar de diseño sábado** te encantaría 🎨")
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
                    LazyVStack(spacing: 0) {
                        ForEach(user.upcomingEvents) { event in
                            ProfileEventRow(event: event, status: "Voy")
                        }
                    }
                    .padding(.horizontal, BullaTheme.Spacing.lg)

                    Spacer().frame(height: 90)
                }
            }
            .scrollIndicators(.hidden)
            .background(Color(UIColor.systemGroupedBackground))
            .overlay(alignment: .bottom) {
                BullaTabBar(selected: $appState.selectedTab)
            }
            .navigationBarHidden(true)
        }
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
