import SwiftUI

// MARK: - Chip / Pill
struct BullaChip: View {
    let text: String
    var style: ChipStyle = .default

    enum ChipStyle {
        case `default`, solid, live, soon, outline, brand
    }

    var body: some View {
        Text(text)
            .font(BullaTheme.Font.body(11, weight: .medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(background)
            .foregroundColor(foreground)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(borderColor, lineWidth: style == .outline ? 1 : 0)
            )
    }

    var background: Color {
        switch style {
        case .default: return BullaTheme.Colors.chipBg
        case .solid: return BullaTheme.Colors.ink
        case .live: return Color(hex: "#DCFCE7")
        case .soon: return Color(hex: "#FEF3C7")
        case .outline: return .white
        case .brand: return BullaTheme.Colors.brand
        }
    }

    var foreground: Color {
        switch style {
        case .solid, .brand: return .white
        case .live: return BullaTheme.Colors.live
        case .soon: return BullaTheme.Colors.soon
        default: return BullaTheme.Colors.ink
        }
    }

    var borderColor: Color {
        style == .outline ? BullaTheme.Colors.line : .clear
    }
}

// MARK: - AI Badge
struct AIBadge: View {
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "sparkle")
                .font(.system(size: 10))
            Text(label)
                .font(BullaTheme.Font.body(11, weight: .semibold))
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 3)
        .background(BullaTheme.Gradients.ai)
        .foregroundColor(.white)
        .clipShape(Capsule())
    }
}

// MARK: - Avatar
struct BullaAvatar: View {
    let initial: String
    var size: CGFloat = 32
    var gradient: [Color] = [Color(hex: "#CBD5E1"), Color(hex: "#94A3B8")]

    var body: some View {
        Text(initial)
            .font(.system(size: size * 0.4, weight: .bold))
            .foregroundColor(.white)
            .frame(width: size, height: size)
            .background(
                LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .clipShape(Circle())
            .overlay(Circle().stroke(.white, lineWidth: 2))
    }
}

// MARK: - Search Bar
struct BullaSearchBar: View {
    var placeholder: String = "Buscar eventos..."
    private let text: Binding<String>?
    private let onFilterTap: (() -> Void)?

    init(placeholder: String = "Buscar eventos...", onFilterTap: (() -> Void)? = nil) {
        self.placeholder = placeholder
        self.text = nil
        self.onFilterTap = onFilterTap
    }

    init(text: Binding<String>, placeholder: String = "Buscar eventos...", onFilterTap: (() -> Void)? = nil) {
        self.placeholder = placeholder
        self.text = text
        self.onFilterTap = onFilterTap
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(BullaTheme.Colors.textTertiary)
                .font(.system(size: 14))

            if let text {
                TextField(placeholder, text: text)
                    .font(BullaTheme.Font.body(14))
                    .foregroundColor(BullaTheme.Colors.ink)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                if !text.wrappedValue.isEmpty {
                    Button {
                        text.wrappedValue = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(BullaTheme.Colors.textTertiary.opacity(0.9))
                            .font(.system(size: 15))
                    }
                    .buttonStyle(.plain)
                }
            } else {
                Text(placeholder)
                    .font(BullaTheme.Font.body(14))
                    .foregroundColor(BullaTheme.Colors.textTertiary)
            }

            Spacer()

            Button(action: { onFilterTap?() }) {
                Image(systemName: "line.3.horizontal.decrease")
                    .foregroundColor(BullaTheme.Colors.brand)
                    .font(.system(size: 14, weight: .medium))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.white)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 2)
        .overlay(Capsule().stroke(BullaTheme.Colors.line, lineWidth: 1))
    }
}

// MARK: - Primary Button
struct BullaPrimaryButton: View {
    let title: String
    var action: () -> Void = {}
    var isFullWidth: Bool = true

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(BullaTheme.Font.body(14, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: isFullWidth ? .infinity : nil)
                .padding(.vertical, 14)
                .padding(.horizontal, isFullWidth ? 0 : 24)
                .background(BullaTheme.Gradients.brand)
                .clipShape(Capsule())
        }
    }
}

// MARK: - Secondary Button
struct BullaSecondaryButton: View {
    let title: String
    var icon: String? = nil
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 13))
                }
                Text(title)
                    .font(BullaTheme.Font.body(14, weight: .semibold))
            }
            .foregroundColor(BullaTheme.Colors.ink)
            .padding(.vertical, 12)
            .padding(.horizontal, 18)
            .background(.white)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(BullaTheme.Colors.line, lineWidth: 1))
        }
    }
}

// MARK: - Tab Bar
struct BullaTabBar: View {
    @Binding var selected: AppTab

    var body: some View {
        HStack {
            TabBarItem(icon: "map", label: "Mapa", tab: .map, selected: $selected)
            TabBarItem(icon: "magnifyingglass.circle", label: "Descubrir", tab: .feed, selected: $selected)

            // FAB
            Button(action: { selected = .create }) {
                ZStack {
                    Circle()
                        .fill(BullaTheme.Gradients.brand)
                        .frame(width: 52, height: 52)
                        .shadow(color: BullaTheme.Colors.brand.opacity(0.3), radius: 12, x: 0, y: 4)
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .light))
                        .foregroundColor(.white)
                }
                .offset(y: -12)
            }

            TabBarItem(icon: "heart", label: "Guardado", tab: .saved, selected: $selected)
            TabBarItem(icon: "person", label: "Yo", tab: .profile, selected: $selected)
        }
        .padding(.horizontal, 12)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(
            Rectangle()
                .fill(.white.opacity(0.97))
                .overlay(Rectangle().frame(height: 1).foregroundColor(BullaTheme.Colors.line), alignment: .top)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

private struct TabBarItem: View {
    let icon: String
    let label: String
    let tab: AppTab
    @Binding var selected: AppTab

    var isActive: Bool { selected == tab }

    var body: some View {
        Button(action: { selected = tab }) {
            VStack(spacing: 3) {
                Image(systemName: isActive ? "\(icon).fill" : icon)
                    .font(.system(size: 20))
                Text(label)
                    .font(BullaTheme.Font.body(10, weight: .medium))
            }
            .foregroundColor(isActive ? BullaTheme.Colors.brand : BullaTheme.Colors.textSecondary)
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Live Dot
struct LiveDot: View {
    @State private var pulsing = false

    var body: some View {
        ZStack {
            Circle()
                .fill(BullaTheme.Colors.live.opacity(0.3))
                .frame(width: pulsing ? 14 : 8, height: pulsing ? 14 : 8)
            Circle()
                .fill(BullaTheme.Colors.live)
                .frame(width: 6, height: 6)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                pulsing = true
            }
        }
    }
}

// MARK: - Image Placeholder
struct EventImagePlaceholder: View {
    var category: EventCategory = .fair
    var height: CGFloat = 120
    var imageUrl: String? = nil

    var baseColor: Color {
        switch category {
        case .music: return Color(hex: "#6D5FA0")
        case .food: return Color(hex: "#B5874A")
        case .art: return Color(hex: "#A06B6B")
        case .sport: return Color(hex: "#3D7A56")
        case .bar: return Color(hex: "#5C4A2A")
        case .gym: return Color(hex: "#2D5A7A")
        default: return Color(hex: "#7A8A78")
        }
    }

    var body: some View {
        if let urlStr = imageUrl, let url = URL(string: urlStr) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    colorBlock
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .clipped()
        } else {
            colorBlock
        }
    }

    private var colorBlock: some View {
        ZStack {
            baseColor
            LinearGradient(
                colors: [.white.opacity(0.15), .clear, .black.opacity(0.15)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            Image(systemName: category.icon)
                .font(.system(size: height * 0.25))
                .foregroundColor(.white.opacity(0.35))
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
    }
}

// MARK: - Previews
#Preview("Components") {
    ScrollView {
        VStack(spacing: 16) {
            HStack {
                BullaChip(text: "Todos", style: .solid)
                BullaChip(text: "En vivo", style: .live)
                BullaChip(text: "Pronto", style: .soon)
                BullaChip(text: "Gratis", style: .outline)
            }
            AIBadge(label: "Para ti")
            HStack {
                BullaAvatar(initial: "A")
                BullaAvatar(initial: "M", gradient: [Color(hex: "#FDE68A"), Color(hex: "#B45309")])
                BullaAvatar(initial: "L", gradient: [Color(hex: "#BFDBFE"), Color(hex: "#3B82F6")])
            }
            BullaSearchBar()
                .padding(.horizontal)
            BullaPrimaryButton(title: "Unirme")
                .padding(.horizontal)
            BullaSecondaryButton(title: "Chat", icon: "bubble.left")
            LiveDot()
            EventImagePlaceholder(category: .music, height: 120)
        }
        .padding()
    }
}
