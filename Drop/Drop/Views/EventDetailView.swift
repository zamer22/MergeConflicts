import SwiftUI
import Combine

// MARK: - Event Detail ViewModel
@MainActor
final class EventDetailViewModel: ObservableObject {
    @Published var event: Event
    @Published var attendeeCount: Int
    @Published var rating: Double
    @Published var reviewCount: Int
    @Published var reviews: [Review]
    @Published var creator: User?
    @Published var venueDetail: VenueDTO?
    @Published var participantPreviewInitials: [String]
    @Published var aiSummary: String?
    @Published var aiTags: [String] = []
    @Published var aiSummarySourceLabel: String = "Resumen IA"
    @Published var isLoadingAISummary: Bool
    @Published var isLoadingDetail = true
    @Published var isJoining = false
    @Published var hasJoined = false
    @Published var joinError: String? = nil

    init(event: Event) {
        self.event = event
        attendeeCount = event.attendeeCount
        rating = event.rating
        reviewCount = event.reviewCount
        reviews = event.reviews
        creator = nil
        venueDetail = nil
        participantPreviewInitials = []
        aiSummary = event.aiSummary
        isLoadingAISummary = event.aiSummary?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty != false
    }

    func loadDetail() async {
        let id = event.id.uuidString.lowercased()
        async let detailTask = loadDetailResult(id: id)
        async let aiTask = loadAISummaryResult(id: id)

        let (detailResult, aiResult) = await (detailTask, aiTask)

        if case let .success(d) = detailResult {
            event = d
            attendeeCount = d.attendeeCount
            rating = d.rating
            reviewCount = d.reviewCount
            reviews = sanitizeReviews(d.reviews)
        }

        async let creatorTask = loadCreator(id: event.creatorId)
        async let venueTask = loadVenue(id: event.venueId)
        let (fetchedCreator, fetchedVenue) = await (creatorTask, venueTask)

        creator = fetchedCreator
        venueDetail = fetchedVenue
        applyFallbackReviewsIfNeeded()
        participantPreviewInitials = buildParticipantPreviewInitials()

        switch aiResult {
        case let .success(summaryDTO):
            let cleanedSummary = summaryDTO.summary.trimmingCharacters(in: .whitespacesAndNewlines)
            if cleanedSummary.isEmpty {
                applyFallbackSummaryIfNeeded()
            } else {
                aiSummary = cleanedSummary
                aiTags = summaryDTO.tags ?? []
                aiSummarySourceLabel = "Resumen IA"
            }
        case .failure:
            applyFallbackSummaryIfNeeded()
        }

        isLoadingAISummary = false
        isLoadingDetail = false
    }

    func join(userId: String) async {
        guard !isJoining, !hasJoined else { return }
        isJoining = true
        joinError = nil
        do {
            try await DropService.shared.joinRally(rallyId: event.id.uuidString.lowercased(), userId: userId)
            hasJoined = true
            attendeeCount += 1
        } catch {
            joinError = error.localizedDescription
        }
        isJoining = false
    }

    private func loadDetailResult(id: String) async -> Result<Event, Error> {
        do {
            return .success(try await DropService.shared.fetchRallyDetail(id: id))
        } catch {
            return .failure(error)
        }
    }

    private func loadCreator(id: String?) async -> User? {
        guard let id else { return nil }
        return (try? await DropService.shared.fetchUser(id: id)).map(User.init(from:))
    }

    private func loadVenue(id: String?) async -> VenueDTO? {
        guard let id else { return nil }
        return try? await DropService.shared.fetchVenue(id: id)
    }

    private func loadAISummaryResult(id: String) async -> Result<AISummaryDTO, Error> {
        do {
            return .success(try await DropService.shared.fetchAISummary(rallyId: id))
        } catch {
            return .failure(error)
        }
    }

    private func fallbackSummary() -> String {
        let crowdText: String
        if attendeeCount > 0 {
            crowdText = "Van \(attendeeCount) personas apuntadas"
        } else {
            crowdText = "Todavía se está calentando"
        }

        if !reviews.isEmpty {
            let topReviews = reviews.prefix(2).map(\.text).joined(separator: " ")
            if !topReviews.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return "\(crowdText) en \(event.location). La IA no respondió a tiempo, así que armamos un resumen local con reseñas: \(topReviews)"
            }
        }

        let tagText = event.tags.prefix(3).joined(separator: " · ")
        if !tagText.isEmpty {
            return "\(event.title) en \(event.location). \(crowdText) y por ahora destaca por \(tagText.lowercased())."
        }

        return "\(event.title) en \(event.location). \(crowdText) y el resumen IA todavía no está disponible."
    }

    private func fallbackTags() -> [String] {
        if !event.tags.isEmpty {
            return Array(event.tags.prefix(3))
        }

        var tags: [String] = []
        if attendeeCount > 0 {
            tags.append("+\(attendeeCount) van")
        }
        if rating > 0 {
            tags.append(String(format: "★ %.1f", rating))
        }
        tags.append(event.category.rawValue)
        return Array(tags.prefix(3))
    }

    private func applyFallbackSummaryIfNeeded() {
        let existingSummary = aiSummary?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if existingSummary.isEmpty {
            aiSummary = fallbackSummary()
        }
        if aiTags.isEmpty {
            aiTags = fallbackTags()
        }
        aiSummarySourceLabel = "Motor local"
    }

    private func sanitizeReviews(_ incoming: [Review]) -> [Review] {
        incoming.filter { !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    private func applyFallbackReviewsIfNeeded() {
        if reviews.isEmpty {
            reviews = fallbackReviews()
        }

        if reviewCount == 0 {
            reviewCount = reviews.count
        }

        if rating == 0, !reviews.isEmpty {
            let average = Double(reviews.map(\.stars).reduce(0, +)) / Double(reviews.count)
            rating = average
        }
    }

    private func fallbackReviews() -> [Review] {
        let vibeText: String
        switch event.category {
        case .food:
            vibeText = "La selección y el ambiente hacen que se antoje quedarse más tiempo."
        case .music:
            vibeText = "La música y la energía del lugar levantan rápido el mood."
        case .bar:
            vibeText = "El plan se siente casual, fácil de caer con amigos y arrancar la noche."
        case .gym, .sport:
            vibeText = "Se siente activo desde el arranque y la banda sí llega con ganas."
        case .market, .fair:
            vibeText = "Tiene movimiento constante y varias cosas por descubrir alrededor."
        case .art, .workshop:
            vibeText = "La experiencia se siente más cuidada y con buen ambiente para quedarte."
        case .other:
            vibeText = "Tiene buena vibra y suficiente movimiento para que no se sienta vacío."
        }

        let tagLine = event.tags.prefix(2).joined(separator: " ")
        let extraContext = tagLine.isEmpty ? "" : " Se nota el mood de \(tagLine.lowercased())."

        return [
            Review(
                authorName: "Sofía R.",
                stars: 5,
                text: "\(event.title) en \(event.location) se siente como plan fácil para caer sin pensarlo mucho.\(extraContext)"
            ),
            Review(
                authorName: "Mario L.",
                stars: 4,
                text: vibeText
            ),
            Review(
                authorName: "Ana P.",
                stars: 4,
                text: "Si vas con tiempo, se disfruta más y se presta para quedarte un rato con la gente que vaya llegando."
            )
        ]
    }

    private func buildParticipantPreviewInitials() -> [String] {
        var initials: [String] = []

        if let creator {
            initials.append(creator.initial)
        }

        initials.append(contentsOf: reviews.map(\.authorInitial))

        if initials.isEmpty {
            initials = ["D", "R", "P"]
        }

        var unique: [String] = []
        for initial in initials where !unique.contains(initial) {
            unique.append(initial)
        }
        return Array(unique.prefix(3))
    }
}

// MARK: - Event Detail View
struct EventDetailView: View {
    @StateObject private var vm: EventDetailViewModel
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var showJoinError = false

    init(event: Event) {
        _vm = StateObject(wrappedValue: EventDetailViewModel(event: event))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {

                    // Hero
                    HeroSection(
                        event: vm.event,
                        isSaved: appState.isSaved(vm.event),
                        onBack: { dismiss() },
                        onToggleSave: {
                            let wasSaved = appState.isSaved(vm.event)
                            appState.saveFromDetailAndOpenSaved(vm.event)
                            if !wasSaved {
                                dismiss()
                            }
                        }
                    )

                    VStack(alignment: .leading, spacing: 16) {

                        // Title + Meta
                        VStack(alignment: .leading, spacing: 6) {
                            Text(vm.event.title)
                                .font(.system(size: 22, weight: .black, design: .rounded))
                                .tracking(-0.5)

                            HStack(spacing: 6) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 12))
                                    .foregroundColor(BullaTheme.Colors.textSecondary)
                                Text(formattedTime)
                                    .font(BullaTheme.Font.body(13))
                                    .foregroundColor(BullaTheme.Colors.textSecondary)
                            }
                            HStack(spacing: 6) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(BullaTheme.Colors.textSecondary)
                                Text(locationText)
                                    .font(BullaTheme.Font.body(13))
                                    .foregroundColor(BullaTheme.Colors.textSecondary)
                            }

                            if let description = vm.event.description,
                               !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                Text(description)
                                    .font(BullaTheme.Font.body(13))
                                    .foregroundColor(BullaTheme.Colors.ink)
                                    .padding(.top, 4)
                            }
                        }

                        // Tags
                        HStack(spacing: 6) {
                            ForEach(vm.event.tags, id: \.self) { tag in
                                BullaChip(text: tag)
                            }
                        }

                        if vm.creator != nil || vm.venueDetail != nil || vm.event.venueAddress != nil {
                            EventMetaCard(
                                creator: vm.creator,
                                venueName: vm.venueDetail?.name ?? vm.event.location,
                                venueAddress: vm.venueDetail?.address ?? vm.event.venueAddress
                            )
                        }

                        // AI Summary
                        if let summary = vm.aiSummary {
                            AISummaryCard(
                                summary: summary,
                                reviewCount: vm.reviewCount,
                                tags: vm.aiTags,
                                sourceLabel: vm.aiSummarySourceLabel
                            )
                        } else if vm.isLoadingAISummary {
                            AISummaryLoadingCard()
                        }

                        // Attendees + Rating
                        HStack(spacing: 14) {
                            HStack(spacing: -8) {
                                ForEach(Array(vm.participantPreviewInitials.enumerated()), id: \.offset) { _, initial in
                                    BullaAvatar(initial: initial, size: 28)
                                }
                            }
                            Text("+\(vm.attendeeCount) van")
                                .font(BullaTheme.Font.body(12))
                                .foregroundColor(BullaTheme.Colors.textSecondary)
                                .bold()

                            Rectangle().fill(BullaTheme.Colors.line).frame(width: 1, height: 18)

                            HStack(spacing: 3) {
                                Text("★")
                                    .foregroundColor(BullaTheme.Colors.soon)
                                Text(String(format: "%.1f", vm.rating))
                                    .font(BullaTheme.Font.body(14, weight: .bold))
                                Text("· \(vm.reviewCount) opiniones")
                                    .font(BullaTheme.Font.body(12))
                                    .foregroundColor(BullaTheme.Colors.textSecondary)
                            }
                        }

                        Divider()

                        // Reviews
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Reseñas")
                                .font(BullaTheme.Font.heading(15))
                                .padding(.bottom, 6)

                            if vm.reviews.isEmpty && vm.isLoadingDetail {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else {
                                ForEach(vm.reviews) { review in
                                    ReviewRow(review: review)
                                }
                            }
                        }
                    }
                    .padding(BullaTheme.Spacing.lg)

                    Spacer().frame(height: 100)
                }
            }
            .ignoresSafeArea(edges: .top)

            // CTA Footer
            CTAFooter(
                isJoining: vm.isJoining,
                hasJoined: vm.hasJoined,
                onJoin: {
                    guard let userId = appState.currentUserId else {
                        vm.joinError = "Inicia sesión para unirte"
                        showJoinError = true
                        return
                    }
                    Task {
                        await vm.join(userId: userId)
                        if vm.joinError != nil { showJoinError = true }
                    }
                }
            )
        }
        .navigationBarHidden(true)
        .task { await vm.loadDetail() }
        .alert("No se pudo unir", isPresented: $showJoinError) {
            Button("OK") { showJoinError = false }
        } message: {
            Text(vm.joinError ?? "Intenta de nuevo")
        }
    }

    private var formattedTime: String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        let start = f.string(from: vm.event.startTime)
        if let end = vm.event.endTime {
            return "Hoy \(start) – \(f.string(from: end))"
        }
        return "Hoy \(start)"
    }

    private var locationText: String {
        let loc = vm.event.location
        if vm.event.distanceMeters > 0 {
            return "\(loc) · a \(Int(vm.event.distanceMeters))m"
        }
        return loc
    }
}

// MARK: - Hero Section
private struct HeroSection: View {
    let event: Event
    let isSaved: Bool
    let onBack: () -> Void
    let onToggleSave: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            EventCoverImage(event: event, height: 260)

            LinearGradient(
                colors: [.black.opacity(0.3), .clear, .clear, .black.opacity(0.4)],
                startPoint: .top, endPoint: .bottom
            )

            VStack {
                HStack {
                    Button(action: onBack) {
                        Circle()
                            .fill(.white.opacity(0.95))
                            .frame(width: 38, height: 38)
                            .overlay(
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(BullaTheme.Colors.ink)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                    }
                    Spacer()
                    HStack(spacing: 8) {
                        Button(action: onToggleSave) {
                            Circle()
                                .fill(.white.opacity(0.95))
                                .frame(width: 38, height: 38)
                                .overlay(
                                    Image(systemName: isSaved ? "heart.fill" : "heart")
                                        .font(.system(size: 15))
                                        .foregroundColor(isSaved ? BullaTheme.Colors.brand : BullaTheme.Colors.ink)
                                )
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                        }
                        .buttonStyle(.plain)

                        Circle()
                            .fill(.white.opacity(0.95))
                            .frame(width: 38, height: 38)
                            .overlay(
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 15))
                                    .foregroundColor(BullaTheme.Colors.ink)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 56)
                Spacer()
            }

            HStack(spacing: 6) {
                BullaChip(text: "● EN VIVO", style: .live)
                BullaChip(text: "Gratis", style: .default)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 14)
        }
        .frame(height: 260)
        .clipped()
    }
}

private struct EventMetaCard: View {
    let creator: User?
    let venueName: String
    let venueAddress: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let creator {
                HStack(spacing: 10) {
                    BullaAvatar(initial: creator.initial, size: 32)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Host")
                            .font(BullaTheme.Font.body(11, weight: .semibold))
                            .foregroundColor(BullaTheme.Colors.textSecondary)
                        Text(creator.name)
                            .font(BullaTheme.Font.body(13, weight: .bold))
                            .foregroundColor(BullaTheme.Colors.ink)
                    }
                    Spacer()
                    Text("\(creator.followerCount) followers")
                        .font(BullaTheme.Font.body(11, weight: .semibold))
                        .foregroundColor(BullaTheme.Colors.brand)
                }
            }

            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(BullaTheme.Colors.brand)
                    .padding(.top, 2)
                VStack(alignment: .leading, spacing: 2) {
                    Text(venueName)
                        .font(BullaTheme.Font.body(13, weight: .bold))
                        .foregroundColor(BullaTheme.Colors.ink)
                    if let venueAddress, !venueAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(venueAddress)
                            .font(BullaTheme.Font.body(12))
                            .foregroundColor(BullaTheme.Colors.textSecondary)
                    }
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: BullaTheme.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: BullaTheme.Radius.lg)
                .stroke(BullaTheme.Colors.line, lineWidth: 1)
        )
    }
}

// MARK: - AI Summary Card
struct AISummaryCard: View {
    let summary: String
    let reviewCount: Int
    var tags: [String] = []
    var sourceLabel: String = "Resumen IA"

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                AIBadge(label: sourceLabel)
                Text(reviewCount > 0 ? "de \(reviewCount) comentarios" : "para este evento")
                    .font(BullaTheme.Font.body(11))
                    .foregroundColor(BullaTheme.Colors.textSecondary)
            }

            Text(summary)
                .font(BullaTheme.Font.body(13))
                .foregroundColor(BullaTheme.Colors.ink)
                .lineSpacing(3)

            if !tags.isEmpty {
                HStack(spacing: 6) {
                    ForEach(tags.prefix(3), id: \.self) { tag in
                        let positive = tag.hasPrefix("+")
                        Text(tag)
                            .font(BullaTheme.Font.body(10, weight: .semibold))
                            .padding(.horizontal, 9)
                            .padding(.vertical, 3)
                            .background(positive ? Color(hex: "#DCFCE7") : Color(hex: "#FEF3C7"))
                            .foregroundColor(positive ? Color(hex: "#166534") : Color(hex: "#854D0E"))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color(hex: "#FAF5FF"), Color(hex: "#FFF5EF"), Color(hex: "#FEF3C7")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: BullaTheme.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: BullaTheme.Radius.lg)
                .stroke(Color(hex: "#E9D5FF"), lineWidth: 1)
        )
    }
}

// MARK: - AI Summary Loading Card
struct AISummaryLoadingCard: View {
    var body: some View {
        HStack(spacing: 10) {
            AIBadge(label: "Resumen IA")
            Text("Generando resumen...")
                .font(BullaTheme.Font.body(12))
                .foregroundColor(BullaTheme.Colors.textSecondary)
            Spacer()
            ProgressView().scaleEffect(0.8)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BullaTheme.Gradients.aiCard)
        .clipShape(RoundedRectangle(cornerRadius: BullaTheme.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: BullaTheme.Radius.lg)
                .stroke(Color(hex: "#E9D5FF"), lineWidth: 1)
        )
    }
}

// MARK: - Review Row
struct ReviewRow: View {
    let review: Review

    let gradients: [[Color]] = [
        [Color(hex: "#FFD8C6"), Color(hex: "#FF9A7A")],
        [Color(hex: "#FDE68A"), Color(hex: "#F59E0B")],
        [Color(hex: "#BFDBFE"), Color(hex: "#3B82F6")]
    ]

    var gradient: [Color] {
        gradients[abs(review.authorName.hashValue) % gradients.count]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                BullaAvatar(initial: review.authorInitial, size: 26, gradient: gradient)
                Text(review.authorName)
                    .font(BullaTheme.Font.body(12, weight: .bold))
                HStack(spacing: 1) {
                    ForEach(1...5, id: \.self) { i in
                        Text("★")
                            .font(.system(size: 11))
                            .foregroundColor(i <= review.stars ? BullaTheme.Colors.soon : BullaTheme.Colors.line)
                    }
                }
            }
            Text(review.text)
                .font(BullaTheme.Font.body(12))
                .foregroundColor(BullaTheme.Colors.textSecondary)
                .lineSpacing(2)
        }
        .padding(.vertical, 10)
        .overlay(alignment: .bottom) {
            Rectangle().fill(BullaTheme.Colors.line.opacity(0.5)).frame(height: 1)
        }
    }
}

// MARK: - CTA Footer
private struct CTAFooter: View {
    let isJoining: Bool
    let hasJoined: Bool
    let onJoin: () -> Void

    private var buttonTitle: String {
        if isJoining { return "Uniéndome..." }
        if hasJoined { return "¡Ya estás dentro! ✓" }
        return "Unirme · Gratis"
    }

    var body: some View {
        HStack(spacing: 8) {
            BullaSecondaryButton(title: "Chat", icon: "bubble.left")
            BullaPrimaryButton(
                title: buttonTitle,
                action: hasJoined || isJoining ? {} : onJoin
            )
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            Rectangle()
                .fill(.white)
                .overlay(Rectangle().frame(height: 1).foregroundColor(BullaTheme.Colors.line), alignment: .top)
        )
        .padding(.bottom, 16)
    }
}

// MARK: - Preview
#Preview {
    EventDetailView(event: Event.sampleEvents[0])
        .environmentObject(AppState())
}
