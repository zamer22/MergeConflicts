import SwiftUI

// MARK: - Bulla Design Tokens
enum BullaTheme {

    // MARK: Colors
    enum Colors {
        static let brand = Color(hex: "#FF5A3C")
        static let brandSoft = Color(hex: "#FFF1EC")
        static let live = Color(hex: "#22C55E")
        static let soon = Color(hex: "#F59E0B")
        static let aiGradientStart = Color(hex: "#7C3AED")
        static let aiGradientMid = Color(hex: "#EC4899")
        static let aiGradientEnd = Color(hex: "#F59E0B")
        static let ink = Color(hex: "#0A0A0F")
        static let textSecondary = Color(hex: "#6B6B76")
        static let textTertiary = Color(hex: "#9AA0A6")
        static let line = Color(hex: "#ECECF0")
        static let chipBg = Color(hex: "#F5F5F8")
        static let mapBg = Color(hex: "#E8ECF0")
    }

    // MARK: Gradients
    enum Gradients {
        static let brand = LinearGradient(
            colors: [Color(hex: "#FF5A3C"), Color(hex: "#FF8A3C")],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
        static let ai = LinearGradient(
            colors: [Color(hex: "#7C3AED"), Color(hex: "#EC4899"), Color(hex: "#F59E0B")],
            startPoint: .leading, endPoint: .trailing
        )
        static let aiCard = LinearGradient(
            colors: [Color(hex: "#FFF5EF"), Color(hex: "#FEF3C7")],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    // MARK: Typography
    enum Font {
        static func heading(_ size: CGFloat, weight: SwiftUI.Font.Weight = .bold) -> SwiftUI.Font {
            .system(size: size, weight: weight, design: .rounded)
        }
        static func body(_ size: CGFloat, weight: SwiftUI.Font.Weight = .regular) -> SwiftUI.Font {
            .system(size: size, weight: weight)
        }
    }

    // MARK: Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 14
        static let lg: CGFloat = 18
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }

    // MARK: Corner Radius
    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let pill: CGFloat = 100
    }
}

// MARK: - Color from Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
