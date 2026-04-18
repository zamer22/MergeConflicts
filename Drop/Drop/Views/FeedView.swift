import SwiftUI

private struct FeedRecommendation {
    let title: String
    let body: String
    let sourceLabel: String
    let chips: [String]
    let event: Event?
}

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

    private var recommendation: FeedRecommendation {
        let remoteReason = cleanedRemoteReason

        if let preferredCategory = preferredCategoryKey,
           let event = filteredEvents.first(where: { $0.category.backendKey == preferredCategory }) {
            return FeedRecommendation(
                title: "\(event.title) se parece mucho a lo que guardas",
                body: remoteReason ?? "\(event.location) está alineado con tus guardados y se mueve bien para ahorita.",
                sourceLabel: "basado en tus likes",
                chips: recommendationChips(for: event, extra: ["Match \(event.category.rawValue)"]),
                event: event
            )
        }

        if let livePick = filteredEvents.first(where: { $0.status == .live }) {
            return FeedRecommendation(
                title: "Esto se está prendiendo ahorita",
                body: remoteReason ?? "\(livePick.title) va en vivo en \(livePick.location) y pinta para ser tu mejor drop inmediato.",
                sourceLabel: "por contexto en vivo",
                chips: recommendationChips(for: livePick, extra: ["En vivo"]),
                event: livePick
            )
        }

        if let popularPick = filteredEvents.max(by: { recommendationScore(for: $0) < recommendationScore(for: $1) }) {
            return FeedRecommendation(
                title: "Populares cerca de ti",
                body: remoteReason ?? "\(popularPick.title) trae buena respuesta cerca de ti, con mejor momentum para descubrir algo nuevo.",
                sourceLabel: selectedCategory == nil ? "motor local" : "filtrado por \(popularPick.category.rawValue.lowercased())",
                chips: recommendationChips(for: popularPick, extra: ["Top local"]),
                event: popularPick
            )
        }

        return FeedRecommendation(
            title: "Ajustando tu radar",
            body: "Todavía no encontramos una sugerencia fuerte con ese filtro. Cambia de categoría o vuelve a `Todos` para ver más opciones.",
            sourceLabel: "motor local",
            chips: ["Sin matches"],
            event: nil
        )
    }

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
                AIRecommendationCard(recommendation: recommendation) {
                    if let event = recommendation.event {
                        appState.selectedEvent = event
                    }
                }
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
        .task {
            await appState.loadEvents()
            await appState.loadRecommendations()
        }
        .refreshable {
            await appState.loadEvents()
            await appState.loadRecommendations()
        }
    }

    private var cleanedRemoteReason: String? {
        let trimmed = appState.recommendationText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty || trimmed == "Descubriendo eventos para ti..." || trimmed == "Eventos cerca de ti" {
            return nil
        }
        return trimmed
    }

    private var preferredCategoryKey: String? {
        if let selectedCategory {
            return selectedCategory
        }

        let savedCategories = appState.savedEvents.map { $0.category.backendKey }
        return savedCategories.reduce(into: [:]) { partialResult, key in
            partialResult[key, default: 0] += 1
        }
        .max(by: { $0.value < $1.value })?
        .key
    }

    private func recommendationScore(for event: Event) -> Double {
        let liveBonus = event.status == .live ? 30.0 : 0.0
        let freeBonus = event.isFree ? 8.0 : 0.0
        let crowdScore = Double(event.attendeeCount) * 1.2
        let distancePenalty = event.distanceMeters / 180
        return liveBonus + freeBonus + crowdScore - distancePenalty
    }

    private func recommendationChips(for event: Event, extra: [String]) -> [String] {
        var chips = extra

        if event.isFree {
            chips.append("Gratis")
        } else if event.entryFee > 0 {
            chips.append("$\(event.entryFee)")
        }

        if event.attendeeCount > 0 {
            chips.append("+\(event.attendeeCount) van")
        }

        if event.distanceMeters > 0 {
            chips.append("a \(Int(event.distanceMeters))m")
        }

        return Array(chips.prefix(3))
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
private struct AIRecommendationCard: View {
    let recommendation: FeedRecommendation
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 6) {
                        AIBadge(label: "Para ti")
                        Text(recommendation.sourceLabel)
                            .font(BullaTheme.Font.body(11))
                            .foregroundColor(BullaTheme.Colors.textSecondary)
                    }

                    Text(recommendation.title)
                        .font(BullaTheme.Font.heading(17))
                        .foregroundColor(BullaTheme.Colors.ink)

                    Text(recommendation.body)
                        .font(BullaTheme.Font.body(13))
                        .foregroundColor(BullaTheme.Colors.ink)
                        .fixedSize(horizontal: false, vertical: true)

                    if !recommendation.chips.isEmpty {
                        HStack(spacing: 6) {
                            ForEach(recommendation.chips, id: \.self) { chip in
                                BullaChip(text: chip, style: .outline)
                            }
                        }
                    }

                    if let event = recommendation.event {
                        HStack(spacing: 6) {
                            Image(systemName: event.category.icon)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(BullaTheme.Colors.brand)
                            Text("Abrir \(event.title)")
                                .font(BullaTheme.Font.body(12, weight: .semibold))
                                .foregroundColor(BullaTheme.Colors.brand)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(BullaTheme.Colors.brand)
                        }
                    }
                }
            }
        }
        .buttonStyle(.plain)
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
                EventCoverImage(event: event, height: 130)

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
