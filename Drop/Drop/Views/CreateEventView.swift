import SwiftUI
import MapKit

struct CreateEventView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    @State private var selectedCategory: EventCategory = .music
    @State private var title = ""
    @State private var locationText = "Parque México · Roma Nte."
    @State private var startNow = true
    @State private var tags: [String] = ["#gratis", "#aire-libre"]
    @State private var newTag = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // Category grid
                    VStack(alignment: .leading, spacing: 8) {
                        SectionLabel("QUÉ ESTÁ PASANDO")
                        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 4), spacing: 10) {
                            ForEach(EventCategory.allCases) { cat in
                                CategoryButton(
                                    category: cat,
                                    isSelected: selectedCategory == cat
                                ) {
                                    selectedCategory = cat
                                }
                            }
                        }
                    }

                    // Name field
                    VStack(alignment: .leading, spacing: 6) {
                        SectionLabel("NOMBRE")
                        TextField("ej. Jam session en el parque", text: $title)
                            .font(BullaTheme.Font.body(14))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(BullaTheme.Colors.chipBg)
                            .clipShape(RoundedRectangle(cornerRadius: BullaTheme.Radius.sm))
                    }

                    // Location
                    VStack(alignment: .leading, spacing: 6) {
                        SectionLabel("DÓNDE")
                        HStack(spacing: 8) {
                            Image(systemName: "location.fill")
                                .foregroundColor(BullaTheme.Colors.brand)
                                .font(.system(size: 13))
                            Text(locationText)
                                .font(BullaTheme.Font.body(13))
                            Spacer()
                            Text("mapa")
                                .font(BullaTheme.Font.body(12, weight: .bold))
                                .foregroundColor(BullaTheme.Colors.brand)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(BullaTheme.Colors.chipBg)
                        .clipShape(RoundedRectangle(cornerRadius: BullaTheme.Radius.sm))
                    }

                    // Mini map pin drop
                    MiniMapPinDrop()

                    // Time
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            SectionLabel("EMPIEZA")
                            HStack {
                                Image(systemName: "clock")
                                    .font(.system(size: 12))
                                    .foregroundColor(BullaTheme.Colors.textSecondary)
                                Text("Ahora")
                                    .font(BullaTheme.Font.body(13))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(BullaTheme.Colors.chipBg)
                            .clipShape(RoundedRectangle(cornerRadius: BullaTheme.Radius.sm))
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            SectionLabel("TERMINA")
                            HStack {
                                Image(systemName: "clock")
                                    .font(.system(size: 12))
                                    .foregroundColor(BullaTheme.Colors.textSecondary)
                                Text("21:00")
                                    .font(BullaTheme.Font.body(13))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(BullaTheme.Colors.chipBg)
                            .clipShape(RoundedRectangle(cornerRadius: BullaTheme.Radius.sm))
                        }
                    }

                    // Tags
                    VStack(alignment: .leading, spacing: 8) {
                        SectionLabel("ETIQUETAS")
                        HStack(spacing: 6) {
                            ForEach(tags, id: \.self) { tag in
                                HStack(spacing: 4) {
                                    Text(tag)
                                        .font(BullaTheme.Font.body(11, weight: .medium))
                                    Button(action: { tags.removeAll { $0 == tag } }) {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 8, weight: .bold))
                                    }
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(BullaTheme.Colors.brand)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                            }
                            Button("+ añadir") {
                                tags.append("#nuevo")
                            }
                            .font(BullaTheme.Font.body(12))
                            .foregroundColor(BullaTheme.Colors.textSecondary)
                        }
                    }

                    // AI Suggestions
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            AIBadge(label: "IA")
                            Text("sugerencias")
                                .font(BullaTheme.Font.body(11))
                                .foregroundColor(BullaTheme.Colors.textSecondary)
                        }
                        HStack(spacing: 6) {
                            ForEach(["+ #música-en-vivo", "+ #familiar"], id: \.self) { suggestion in
                                Button(action: { tags.append(suggestion.replacingOccurrences(of: "+ ", with: "")) }) {
                                    Text(suggestion)
                                        .font(BullaTheme.Font.body(11))
                                        .foregroundColor(BullaTheme.Colors.ink)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(.white)
                                        .clipShape(Capsule())
                                        .overlay(Capsule().stroke(BullaTheme.Colors.line, lineWidth: 1))
                                }
                            }
                        }
                    }
                    .padding(12)
                    .background(BullaTheme.Colors.brand.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: BullaTheme.Radius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: BullaTheme.Radius.md)
                            .stroke(BullaTheme.Colors.brand.opacity(0.2), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                    )

                    BullaPrimaryButton(title: "Publicar evento") {
                        dismiss()
                    }

                    Spacer().frame(height: 20)
                }
                .padding(BullaTheme.Spacing.lg)
            }
            .navigationTitle("Nuevo evento")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                        .foregroundColor(BullaTheme.Colors.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("Borrador")
                        .font(BullaTheme.Font.body(13))
                        .foregroundColor(BullaTheme.Colors.textSecondary)
                }
            }
        }
    }
}

// MARK: - Category Button
private struct CategoryButton: View {
    let category: EventCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(category.icon)
                    .font(.system(size: 22))
                Text(category.rawValue)
                    .font(BullaTheme.Font.body(10, weight: isSelected ? .bold : .regular))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(isSelected ? BullaTheme.Colors.brand : BullaTheme.Colors.chipBg)
            .foregroundColor(isSelected ? .white : BullaTheme.Colors.ink)
            .clipShape(RoundedRectangle(cornerRadius: BullaTheme.Radius.sm))
            .shadow(color: isSelected ? BullaTheme.Colors.brand.opacity(0.3) : .clear, radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .animation(.spring(duration: 0.2), value: isSelected)
    }
}

// MARK: - Mini Map Pin Drop
private struct MiniMapPinDrop: View {
    var body: some View {
        ZStack {
            // Simplified map background
            Rectangle()
                .fill(BullaTheme.Colors.mapBg)
                .frame(height: 160)
                .clipShape(RoundedRectangle(cornerRadius: BullaTheme.Radius.md))

            // Street lines (SVG-like using SwiftUI)
            Canvas { ctx, size in
                let w = size.width
                let h = size.height

                var path = Path()
                path.move(to: CGPoint(x: 0, y: h * 0.3))
                path.addQuadCurve(
                    to: CGPoint(x: w, y: h * 0.35),
                    control: CGPoint(x: w * 0.5, y: h * 0.2)
                )
                ctx.stroke(path, with: .color(.white), lineWidth: 14)
                ctx.stroke(path, with: .color(BullaTheme.Colors.line), lineWidth: 1)

                var path2 = Path()
                path2.move(to: CGPoint(x: w * 0.3, y: 0))
                path2.addLine(to: CGPoint(x: w * 0.32, y: h))
                ctx.stroke(path2, with: .color(.white), lineWidth: 12)
            }
            .frame(height: 160)

            // Drop pin
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(BullaTheme.Colors.brand)
                        .frame(width: 44, height: 44)
                        .overlay(Circle().stroke(.white, lineWidth: 2))
                        .shadow(color: BullaTheme.Colors.brand.opacity(0.4), radius: 8, x: 0, y: 4)
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(.white)
                }
                Circle()
                    .fill(BullaTheme.Colors.ink.opacity(0.3))
                    .frame(width: 8, height: 4)
                    .blur(radius: 1)
            }

            // Hint
            VStack {
                BullaChip(text: "Arrastra para ubicar 👉", style: .solid)
                    .padding(.top, 10)
                Spacer()
                BullaChip(text: "Confirmar esta ubicación", style: .brand)
                    .padding(.bottom, 10)
                    .shadow(color: BullaTheme.Colors.brand.opacity(0.3), radius: 6, x: 0, y: 2)
            }
        }
        .frame(height: 160)
        .clipShape(RoundedRectangle(cornerRadius: BullaTheme.Radius.md))
    }
}

// MARK: - Section Label
private struct SectionLabel: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text)
            .font(BullaTheme.Font.body(11, weight: .bold))
            .foregroundColor(BullaTheme.Colors.textSecondary)
            .tracking(0.5)
    }
}

// MARK: - Preview
#Preview {
    CreateEventView()
        .environmentObject(AppState())
}
