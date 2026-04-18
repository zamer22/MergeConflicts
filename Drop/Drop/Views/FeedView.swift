import SwiftUI

struct FeedView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedCategory: String? = nil

    var liveEvents: [Event] { appState.events.filter { $0.status == .live } }
    var filteredEvents: [Event] {
        guard let cat = selectedCategory else { return appState.events }
        return appState.events.filter { $0.category.backendKey == cat }
    }

    let categories: [(key: String, label: String, icon: String)] = [
        ("musica", "Música", "music.note"),
        ("feria", "Feria", "sparkles"),
        ("arte", "Arte", "paintpalette"),
        ("comida", "Comida", "fork.knife"),
        ("bar", "Bar", "wineglass"),
        ("deporte", "Deporte", "figure.run"),
        ("gym", "Gym", "dumbbell"),
        ("mercado", "Mercado", "cart"),
        ("otro", "Otro", "plus"),
    ]

    var body: some View {
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
                        Text("Barrio Antiguo, Monterrey")
                            .font(BullaTheme.Font.body(13))
                            .foregroundColor(BullaTheme.Colors.textSecondary)
                    }
                }
                .padding(.horizontal, BullaTheme.Spacing.lg)
                .padding(.top, 12)
                .padding(.bottom, 16)

                // EN VIVO Stories — from real data
                if !liveEvents.isEmpty {
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
                                ForEach(liveEvents.prefix(6)) { event in
                                    Button { appState.selectedEvent = event } label: {
                                        LiveStoryItem(event: event)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, BullaTheme.Spacing.lg)
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(.bottom, 14)
                }

                // Search
                BullaSearchBar()
                    .padding(.horizontal, BullaTheme.Spacing.lg)
                    .padding(.bottom, 12)

                // Category chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        CategoryChip(label: "Todos", icon: nil, isSelected: selectedCategory == nil) {
                            selectedCategory = nil
                        }
                        ForEach(categories, id: \.key) { cat in
                            CategoryChip(label: cat.label, icon: cat.icon, isSelected: selectedCategory == cat.key) {
                                selectedCategory = selectedCategory == cat.key ? nil : cat.key
                            }
                        }
                    }
                    .padding(.horizontal, BullaTheme.Spacing.lg)
                }
                .padding(.bottom, 14)

                // AI "Para ti"
                AIRecommendationCard(text: appState.recommendationText)
                    .padding(.horizontal, BullaTheme.Spacing.lg)
                    .padding(.bottom, 16)

                // Event list
                HStack {
                    Text(selectedCategory == nil ? "Cerca de ti" : "Filtrado")
                        .font(BullaTheme.Font.heading(17))
                    Spacer()
                    if appState.isLoadingEvents {
                        ProgressView().scaleEffect(0.8)
                    }
                }
                .padding(.horizontal, BullaTheme.Spacing.lg)
                .padding(.bottom, 10)

                if filteredEvents.isEmpty && !appState.isLoadingEvents {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass.circle")
                            .font(.system(size: 40))
                            .foregroundColor(BullaTheme.Colors.textSecondary)
                        Text("No hay eventos ahora mismo")
                            .font(BullaTheme.Font.body(15))
                            .foregroundColor(BullaTheme.Colors.textSecondary)
                        Text("¡Crea el primero con el botón +!")
                            .font(BullaTheme.Font.body(13))
                            .foregroundColor(BullaTheme.Colors.textSecondary.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
                } else {
                    ForEach(filteredEvents) { event in
                        Button {
                            appState.selectedEvent = event
                        } label: {
                            FeedEventCard(event: event)
                                .padding(.horizontal, BullaTheme.Spacing.lg)
                                .padding(.bottom, 14)
                        }
                        .buttonStyle(.plain)
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
        .task { await appState.loadEvents() }
        .refreshable { await appState.loadEvents() }
    }
}

// MARK: - Category Chip (interactive)
private struct CategoryChip: View {
    let label: String
    let icon: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 11))
                }
                Text(label)
                    .font(BullaTheme.Font.body(12, weight: isSelected ? .bold : .medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? BullaTheme.Colors.brand : .white)
            .foregroundColor(isSelected ? .white : BullaTheme.Colors.ink)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(isSelected ? Color.clear : BullaTheme.Colors.line, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .animation(.spring(duration: 0.2), value: isSelected)
    }
}

// MARK: - Live Story Item (from real event)
struct LiveStoryItem: View {
    let event: Event

    var pinColor: Color {
        switch event.category {
        case .music: return Color(hex: "#6D5FA0")
        case .food: return Color(hex: "#B5874A")
        case .art: return Color(hex: "#A06B6B")
        case .sport, .gym: return BullaTheme.Colors.live
        case .bar: return Color(hex: "#5C3D11")
        default: return BullaTheme.Colors.brand
        }
    }

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .stroke(
                        AngularGradient(
                            colors: [BullaTheme.Colors.brand, Color(hex: "#EC4899"), BullaTheme.Colors.soon, BullaTheme.Colors.brand],
                            center: .center
                        ),
                        lineWidth: 2.5
                    )
                    .frame(width: 70, height: 70)

                Circle()
                    .fill(pinColor)
                    .frame(width: 60, height: 60)
                    .overlay(Circle().stroke(.white, lineWidth: 2))

                Image(systemName: event.category.icon)
                    .font(.system(size: 22))
                    .foregroundColor(.white)
            }
            Text(event.location)
                .font(BullaTheme.Font.body(10))
                .foregroundColor(BullaTheme.Colors.textSecondary)
                .lineLimit(1)
                .frame(maxWidth: 70)
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
            return mins < 60 ? "En \(mins)min" : "HOY"
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
                            appState.toggleSave(event)
                        } label: {
                            Circle()
                                .fill(.white.opacity(0.9))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Image(systemName: appState.isSaved(event) ? "heart.fill" : "heart")
                                        .font(.system(size: 14))
                                        .foregroundColor(appState.isSaved(event) ? BullaTheme.Colors.brand : BullaTheme.Colors.ink)
                                )
                        }
                        .padding(10)
                        .animation(.spring(duration: 0.2), value: appState.isSaved(event))
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
                    if event.entryFee > 0 {
                        Text("$\(event.entryFee)")
                            .font(BullaTheme.Font.body(11, weight: .bold))
                            .foregroundColor(BullaTheme.Colors.ink)
                    } else {
                        Text("Gratis")
                            .font(BullaTheme.Font.body(11, weight: .bold))
                            .foregroundColor(BullaTheme.Colors.live)
                    }
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
