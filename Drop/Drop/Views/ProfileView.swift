import SwiftUI

private struct ProfileRecommendation {
    let title: String
    let body: String
    let sourceLabel: String
    let chips: [String]
    let event: Event?
}

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

    private var profileRecommendation: ProfileRecommendation {
        let remoteReason = cleanedRemoteReason

        if let upcoming = upcomingEvents.sorted(by: profilePriority).first {
            return ProfileRecommendation(
                title: "Tu próximo mejor drop ya está apartado",
                body: remoteReason ?? "\(upcoming.title) pinta como tu mejor siguiente salida: ya lo tienes en próximos y conecta bien con tu ritmo reciente.",
                sourceLabel: "según tu actividad",
                chips: profileChips(for: upcoming, extra: ["Próximo"]),
                event: upcoming
            )
        }

        if let created = createdEvents.sorted(by: profilePriority).first {
            return ProfileRecommendation(
                title: "Empuja el rally que tú armaste",
                body: remoteReason ?? "\(created.title) puede ser tu mejor carta para crecer reputación. Si lo activas bien, te sube visibilidad en tu perfil.",
                sourceLabel: "basado en tus publicados",
                chips: profileChips(for: created, extra: ["Creado por ti"]),
                event: created
            )
        }

        if let past = pastEvents.sorted(by: profilePriority).first {
            return ProfileRecommendation(
                title: "Tu historial marca una línea clara",
                body: remoteReason ?? "Vienes de moverte bien en \(past.category.rawValue.lowercased()). Te conviene repetir ese patrón con algo parecido esta semana.",
                sourceLabel: "leyendo tu historial",
                chips: profileChips(for: past, extra: ["Tu vibe"]),
                event: past
            )
        }

        if let saved = appState.savedEvents.first {
            return ProfileRecommendation(
                title: "Tienes algo guardado con potencial",
                body: remoteReason ?? "\(saved.title) sigue siendo buen candidato para tu siguiente salida. Vale la pena abrirlo y decidir rápido.",
                sourceLabel: "desde tus guardados",
                chips: profileChips(for: saved, extra: ["Guardado"]),
                event: saved
            )
        }

        return ProfileRecommendation(
            title: "Tu perfil todavía se está armando",
            body: "Cuando guardes eventos, te unas a rallies o publiques uno, esta IA empezará a recomendarte tu siguiente mejor movimiento aquí mismo.",
            sourceLabel: "motor local",
            chips: ["Sin historial"],
            event: nil
        )
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
                            StatItem(value: "\(user.followerCount)", label: "followers")
                            StatItem(value: "\(user.followingCount)", label: "following")
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
                Button {
                    if let event = profileRecommendation.event {
                        appState.selectedEvent = event
                    }
                } label: {
                    HStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 6) {
                                AIBadge(label: "IA")
                                Text(profileRecommendation.sourceLabel)
                                    .font(BullaTheme.Font.body(11))
                                    .foregroundColor(BullaTheme.Colors.textSecondary)
                            }

                            Text(profileRecommendation.title)
                                .font(BullaTheme.Font.heading(16))
                                .foregroundColor(BullaTheme.Colors.ink)

                            Text(profileRecommendation.body)
                                .font(BullaTheme.Font.body(12))
                                .foregroundColor(BullaTheme.Colors.ink)
                                .fixedSize(horizontal: false, vertical: true)

                            if !profileRecommendation.chips.isEmpty {
                                HStack(spacing: 6) {
                                    ForEach(profileRecommendation.chips, id: \.self) { chip in
                                        BullaChip(text: chip, style: .outline)
                                    }
                                }
                            }

                            if let event = profileRecommendation.event {
                                HStack(spacing: 6) {
                                    Image(systemName: event.category.icon)
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(BullaTheme.Colors.brand)
                                    Text("Abrir \(event.title)")
                                        .font(BullaTheme.Font.body(12, weight: .semibold))
                                        .foregroundColor(BullaTheme.Colors.brand)
                                }
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
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

    private var cleanedRemoteReason: String? {
        let trimmed = appState.recommendationText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty || trimmed == "Descubriendo eventos para ti..." || trimmed == "Eventos cerca de ti" {
            return nil
        }
        return trimmed
    }

    private func profilePriority(_ lhs: Event, _ rhs: Event) -> Bool {
        let leftScore = Double(lhs.attendeeCount) + lhs.rating * 10 - (lhs.distanceMeters / 200)
        let rightScore = Double(rhs.attendeeCount) + rhs.rating * 10 - (rhs.distanceMeters / 200)
        return leftScore > rightScore
    }

    private func profileChips(for event: Event, extra: [String]) -> [String] {
        var chips = extra

        if event.attendeeCount > 0 {
            chips.append("+\(event.attendeeCount) van")
        }

        if event.rating > 0 {
            chips.append(String(format: "★ %.1f", event.rating))
        }

        if event.isFree {
            chips.append("Gratis")
        } else if event.entryFee > 0 {
            chips.append("$\(event.entryFee)")
        }

        return Array(chips.prefix(3))
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
            EventCoverImage(event: event, height: 42)
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
