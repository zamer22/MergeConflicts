import SwiftUI
import Combine

// MARK: - Event Detail ViewModel
@MainActor
final class EventDetailViewModel: ObservableObject {
    let baseEvent: Event
    @Published var attendeeCount: Int
    @Published var rating: Double
    @Published var reviewCount: Int
    @Published var reviews: [Review]
    @Published var aiSummary: String?
    @Published var aiTags: [String] = []
    @Published var isLoadingDetail = true

    init(event: Event) {
        baseEvent = event
        attendeeCount = event.attendeeCount
        rating = event.rating
        reviewCount = event.reviewCount
        reviews = event.reviews
        aiSummary = event.aiSummary
    }

    func loadDetail() async {
        let id = baseEvent.id.uuidString.lowercased()
        async let detailTask: Event? = try? DropService.shared.fetchRallyDetail(id: id)
        async let aiTask: AISummaryDTO? = try? DropService.shared.fetchAISummary(rallyId: id)

        let (detail, ai) = await (detailTask, aiTask)

        if let d = detail {
            attendeeCount = d.attendeeCount
            rating = d.rating
            reviewCount = d.reviewCount
            reviews = d.reviews
        }
        if let a = ai {
            aiSummary = a.summary
            aiTags = a.tags ?? []
        }
        isLoadingDetail = false
    }
}

// MARK: - Event Detail View
struct EventDetailView: View {
    @StateObject private var vm: EventDetailViewModel
    @Environment(\.dismiss) var dismiss

    @State private var selectedTab = 0
    let tabs = ["Info", "Fotos"]

    init(event: Event) {
        _vm = StateObject(wrappedValue: EventDetailViewModel(event: event))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {

                    // Hero
                    HeroSection(event: vm.baseEvent, onBack: { dismiss() })

                    // Tabs
                    HStack(spacing: 0) {
                        ForEach(Array(tabs.enumerated()), id: \.offset) { i, tab in
                            Button(action: { selectedTab = i }) {
                                VStack(spacing: 0) {
                                    Text(tab)
                                        .font(BullaTheme.Font.body(14, weight: selectedTab == i ? .bold : .medium))
                                        .foregroundColor(selectedTab == i ? BullaTheme.Colors.ink : BullaTheme.Colors.textSecondary)
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 14)

                                    Rectangle()
                                        .fill(selectedTab == i ? BullaTheme.Colors.brand : .clear)
                                        .frame(height: 2.5)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        Spacer()
                    }
                    .overlay(alignment: .bottom) {
                        Rectangle().fill(BullaTheme.Colors.line).frame(height: 1)
                    }

                    VStack(alignment: .leading, spacing: 16) {

                        // Title + Meta
                        VStack(alignment: .leading, spacing: 6) {
                            Text(vm.baseEvent.title)
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
                        }

                        // Tags
                        HStack(spacing: 6) {
                            ForEach(vm.baseEvent.tags, id: \.self) { tag in
                                BullaChip(text: tag)
                            }
                        }

                        // AI Summary
                        if let summary = vm.aiSummary {
                            AISummaryCard(summary: summary, reviewCount: vm.reviewCount, tags: vm.aiTags)
                        } else if vm.isLoadingDetail {
                            AISummaryLoadingCard()
                        }

                        // Attendees + Rating
                        HStack(spacing: 14) {
                            HStack(spacing: -8) {
                                ForEach(["A", "M", "L"], id: \.self) { initial in
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
            CTAFooter()
        }
        .navigationBarHidden(true)
        .task { await vm.loadDetail() }
    }

    private var formattedTime: String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        let start = f.string(from: vm.baseEvent.startTime)
        if let end = vm.baseEvent.endTime {
            return "Hoy \(start) – \(f.string(from: end))"
        }
        return "Hoy \(start)"
    }

    private var locationText: String {
        let loc = vm.baseEvent.location
        if vm.baseEvent.distanceMeters > 0 {
            return "\(loc) · a \(Int(vm.baseEvent.distanceMeters))m"
        }
        return loc
    }
}

// MARK: - Hero Section
private struct HeroSection: View {
    let event: Event
    let onBack: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            EventImagePlaceholder(category: event.category, height: 260, imageUrl: event.imageUrl)

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
                        ForEach(["heart", "square.and.arrow.up"], id: \.self) { icon in
                            Circle()
                                .fill(.white.opacity(0.95))
                                .frame(width: 38, height: 38)
                                .overlay(
                                    Image(systemName: icon)
                                        .font(.system(size: 15))
                                        .foregroundColor(BullaTheme.Colors.ink)
                                )
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                        }
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

// MARK: - AI Summary Card
struct AISummaryCard: View {
    let summary: String
    let reviewCount: Int
    var tags: [String] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                AIBadge(label: "Resumen IA")
                Text("de \(reviewCount) comentarios")
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
    var body: some View {
        HStack(spacing: 8) {
            BullaSecondaryButton(title: "Chat", icon: "bubble.left")
            BullaPrimaryButton(title: "Unirme")
            Button(action: {}) {
                Circle()
                    .stroke(BullaTheme.Colors.line, lineWidth: 1)
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 15))
                            .foregroundColor(BullaTheme.Colors.ink)
                    )
            }
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
}
