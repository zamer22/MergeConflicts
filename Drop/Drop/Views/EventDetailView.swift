import SwiftUI

struct EventDetailView: View {
    let event: Event
    @Environment(\.dismiss) var dismiss

    @State private var selectedTab = 0
    let tabs = ["Info", "Fotos"]

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {

                    // Hero
                    HeroSection(event: event, onBack: { dismiss() })

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
                            Text(event.title)
                                .font(.system(size: 22, weight: .black, design: .rounded))
                                .tracking(-0.5)

                            HStack(spacing: 6) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 12))
                                    .foregroundColor(BullaTheme.Colors.textSecondary)
                                Text("Hoy 10:00 – 22:00")
                                    .font(BullaTheme.Font.body(13))
                                    .foregroundColor(BullaTheme.Colors.textSecondary)
                            }
                            HStack(spacing: 6) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(BullaTheme.Colors.textSecondary)
                                Text("\(event.location) · a \(Int(event.distanceMeters))m")
                                    .font(BullaTheme.Font.body(13))
                                    .foregroundColor(BullaTheme.Colors.textSecondary)
                            }
                        }

                        // Tags
                        HStack(spacing: 6) {
                            ForEach(event.tags, id: \.self) { tag in
                                BullaChip(text: tag)
                            }
                        }

                        // AI Summary
                        if let summary = event.aiSummary {
                            AISummaryCard(summary: summary, reviewCount: event.reviewCount)
                        }

                        // Attendees + Rating
                        HStack(spacing: 14) {
                            // Avatars
                            HStack(spacing: -8) {
                                ForEach(["A", "M", "L"], id: \.self) { initial in
                                    BullaAvatar(initial: initial, size: 28)
                                }
                            }
                            Text("+\(event.attendeeCount) van")
                                .font(BullaTheme.Font.body(12))
                                .foregroundColor(BullaTheme.Colors.textSecondary)
                                .bold()

                            Rectangle().fill(BullaTheme.Colors.line).frame(width: 1, height: 18)

                            HStack(spacing: 3) {
                                Text("★")
                                    .foregroundColor(BullaTheme.Colors.soon)
                                Text(String(format: "%.1f", event.rating))
                                    .font(BullaTheme.Font.body(14, weight: .bold))
                                Text("· \(event.reviewCount) opiniones")
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

                            ForEach(event.reviews) { review in
                                ReviewRow(review: review)
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
    }
}

// MARK: - Hero Section
private struct HeroSection: View {
    let event: Event
    let onBack: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            EventImagePlaceholder(category: event.category, height: 260)

            // Gradient overlay
            LinearGradient(
                colors: [.black.opacity(0.3), .clear, .clear, .black.opacity(0.4)],
                startPoint: .top, endPoint: .bottom
            )

            // Top buttons
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

            // Bottom chips
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

            HStack(spacing: 6) {
                ForEach([
                    ("+ variedad", true),
                    ("+ ambiente", true),
                    ("– precios", false)
                ], id: \.0) { label, positive in
                    Text(label)
                        .font(BullaTheme.Font.body(10, weight: .semibold))
                        .padding(.horizontal, 9)
                        .padding(.vertical, 3)
                        .background(positive ? Color(hex: "#DCFCE7") : Color(hex: "#FEF3C7"))
                        .foregroundColor(positive ? Color(hex: "#166534") : Color(hex: "#854D0E"))
                        .clipShape(Capsule())
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
