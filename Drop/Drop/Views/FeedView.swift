import SwiftUI

struct FeedView: View {
    @EnvironmentObject var appState: AppState

    let liveStories: [(icon: String, color: Color, minutesAway: Int)] = [
        ("🎵", Color(hex: "#7C6FAA"), 3),
        ("🎪", BullaTheme.Colors.brand, 6),
        ("🍴", Color(hex: "#D4A574"), 9),
        ("🎨", Color(hex: "#C87F7F"), 12),
        ("🏃", BullaTheme.Colors.live, 15),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Descubrir")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 11))
                                .foregroundColor(BullaTheme.Colors.brand)
                            Text("Roma Norte, CDMX")
                                .font(BullaTheme.Font.body(13))
                                .foregroundColor(BullaTheme.Colors.textSecondary)
                        }
                    }
                    .padding(.horizontal, BullaTheme.Spacing.lg)
                    .padding(.top, 12)
                    .padding(.bottom, 16)

                    // EN VIVO Stories
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            LiveDot()
                            Text("EN VIVO · PASANDO AHORA")
                                .font(BullaTheme.Font.body(11, weight: .bold))
                                .foregroundColor(BullaTheme.Colors.brand)
                                .tracking(0.8)
                        }
                        .padding(.horizontal, BullaTheme.Spacing.lg)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(liveStories, id: \.minutesAway) { story in
                                    LiveStoryItem(icon: story.icon, color: story.color, minutesAway: story.minutesAway)
                                }
                            }
                            .padding(.horizontal, BullaTheme.Spacing.lg)
                        }
                    }
                    .padding(.bottom, 14)

                    // Search
                    BullaSearchBar()
                        .padding(.horizontal, BullaTheme.Spacing.lg)
                        .padding(.bottom, 12)

                    // Category chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            BullaChip(text: "Todos", style: .solid)
                            BullaChip(text: "🎵 Música", style: .outline)
                            BullaChip(text: "🎪 Ferias", style: .outline)
                            BullaChip(text: "🎨 Arte", style: .outline)
                            BullaChip(text: "🍴 Comida", style: .outline)
                        }
                        .padding(.horizontal, BullaTheme.Spacing.lg)
                    }
                    .padding(.bottom, 14)

                    // AI "Para ti"
                    AIRecommendationCard(text: appState.recommendationText)
                        .padding(.horizontal, BullaTheme.Spacing.lg)
                        .padding(.bottom, 16)

                    // Event cards
                    Text("Cerca de ti")
                        .font(BullaTheme.Font.heading(17))
                        .padding(.horizontal, BullaTheme.Spacing.lg)
                        .padding(.bottom, 10)

                    ForEach(appState.events) { event in
                        Button {
                            appState.selectedEvent = event
                        } label: {
                            FeedEventCard(event: event)
                                .padding(.horizontal, BullaTheme.Spacing.lg)
                                .padding(.bottom, 14)
                        }
                        .buttonStyle(.plain)
                    }

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

// MARK: - Live Story Item
struct LiveStoryItem: View {
    let icon: String
    let color: Color
    let minutesAway: Int

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Gradient ring
                Circle()
                    .stroke(
                        AngularGradient(
                            colors: [BullaTheme.Colors.brand, Color(hex: "#EC4899"), BullaTheme.Colors.soon, BullaTheme.Colors.brand],
                            center: .center
                        ),
                        lineWidth: 2.5
                    )
                    .frame(width: 66, height: 66)

                Circle()
                    .fill(color)
                    .frame(width: 58, height: 58)
                    .overlay(Circle().stroke(.white, lineWidth: 2))

                Text(icon)
                    .font(.system(size: 24))
            }
            Text("a \(minutesAway) min")
                .font(BullaTheme.Font.body(10))
                .foregroundColor(BullaTheme.Colors.textSecondary)
        }
    }
}

// MARK: - AI Recommendation Card
struct AIRecommendationCard: View {
    var text: String = "Descubriendo eventos para ti..."

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    AIBadge(label: "Para ti")
                    Text("según tus gustos")
                        .font(BullaTheme.Font.body(11))
                        .foregroundColor(BullaTheme.Colors.textSecondary)
                }
                Text(text)
                    .font(BullaTheme.Font.body(13))
                    .foregroundColor(BullaTheme.Colors.ink)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BullaTheme.Gradients.aiCard)
        .clipShape(RoundedRectangle(cornerRadius: BullaTheme.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: BullaTheme.Radius.lg)
                .stroke(Color(hex: "#FED7AA"), lineWidth: 1)
        )
    }
}

// MARK: - Feed Event Card
struct FeedEventCard: View {
    let event: Event

    var badgeText: String {
        switch event.status {
        case .live: return "AHORA"
        case .upcoming(let mins):
            return mins < 60 ? "En \(mins)min" : "MAÑANA"
        case .today: return "HOY"
        case .weekend: return "FINDE"
        }
    }

    var badgeStyle: BullaChip.ChipStyle {
        switch event.status {
        case .live: return .live
        case .upcoming: return .soon
        default: return .default
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image
            ZStack(alignment: .topLeading) {
                EventImagePlaceholder(category: event.category, height: 130)

                VStack {
                    HStack {
                        BullaChip(
                            text: event.status == .live ? "● \(badgeText)" : badgeText,
                            style: badgeStyle
                        )
                        .padding(10)
                        Spacer()
                        Button {
                            appState.saveEvent(event)
                        } label: {
                            Circle()
                                .fill(.white.opacity(0.9))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Image(systemName: "heart")
                                        .font(.system(size: 14))
                                        .foregroundColor(BullaTheme.Colors.ink)
                                )
                        }
                        .padding(10)
                    }
                    Spacer()
                }
            }

            // Info
            VStack(alignment: .leading, spacing: 6) {
                Text(event.title)
                    .font(BullaTheme.Font.heading(15))
                    .foregroundColor(BullaTheme.Colors.ink)

                Text(event.location)
                    .font(BullaTheme.Font.body(12))
                    .foregroundColor(BullaTheme.Colors.textSecondary)

                HStack(spacing: 6) {
                    ForEach(event.tags.prefix(2), id: \.self) { tag in
                        BullaChip(text: tag, style: .default)
                    }
                    Spacer()
                    HStack(spacing: 3) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 10))
                            .foregroundColor(BullaTheme.Colors.textSecondary)
                        Text("\(event.attendeeCount)")
                            .font(BullaTheme.Font.body(11, weight: .bold))
                            .foregroundColor(BullaTheme.Colors.ink)
                        Text("van")
                            .font(BullaTheme.Font.body(11))
                            .foregroundColor(BullaTheme.Colors.textSecondary)
                    }
                }
            }
            .padding(12)
        }
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: BullaTheme.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: BullaTheme.Radius.lg)
                .stroke(BullaTheme.Colors.line, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    @EnvironmentObject var appState: AppState
}

// MARK: - Preview
#Preview {
    FeedView()
        .environmentObject(AppState())
}
