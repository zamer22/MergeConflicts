import SwiftUI
import MapKit

struct CreateEventView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    @State private var selectedCategory: EventCategory = .music
    @State private var title = ""
    @State private var tags: [String] = ["#gratis", "#aire-libre"]
    @State private var newTagText = ""
    @State private var isPublishing = false
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(3 * 3600)

    @State private var mapPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 25.6672, longitude: -100.3101),
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
    )
    @State private var pinnedCoordinate = CLLocationCoordinate2D(latitude: 25.6672, longitude: -100.3101)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    categorySection
                    nameSection
                    mapSection

                    // Time
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            SectionLabel("EMPIEZA")
                            DatePicker("", selection: $startTime, displayedComponents: [.hourAndMinute])
                                .labelsHidden()
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .frame(maxWidth: .infinity)
                                .background(BullaTheme.Colors.chipBg)
                                .clipShape(RoundedRectangle(cornerRadius: BullaTheme.Radius.sm))
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            SectionLabel("TERMINA")
                            DatePicker("", selection: $endTime, displayedComponents: [.hourAndMinute])
                                .labelsHidden()
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .frame(maxWidth: .infinity)
                                .background(BullaTheme.Colors.chipBg)
                                .clipShape(RoundedRectangle(cornerRadius: BullaTheme.Radius.sm))
                        }
                    }

                    // Tags
                    VStack(alignment: .leading, spacing: 8) {
                        SectionLabel("ETIQUETAS")
                        FlowTagRow(tags: $tags)
                        HStack(spacing: 8) {
                            HStack(spacing: 4) {
                                Text("#")
                                    .font(BullaTheme.Font.body(13, weight: .bold))
                                    .foregroundColor(BullaTheme.Colors.brand)
                                TextField("nueva etiqueta", text: $newTagText)
                                    .font(BullaTheme.Font.body(13))
                                    .autocapitalization(.none)
                                    .onSubmit { addTag() }
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .background(BullaTheme.Colors.chipBg)
                            .clipShape(RoundedRectangle(cornerRadius: BullaTheme.Radius.sm))

                            Button(action: addTag) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(BullaTheme.Colors.brand)
                            }
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
                            ForEach(["#música-en-vivo", "#familiar"], id: \.self) { suggestion in
                                Button(action: {
                                    if !tags.contains(suggestion) { tags.append(suggestion) }
                                }) {
                                    Text("+ \(suggestion)")
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

                    BullaPrimaryButton(title: isPublishing ? "Publicando..." : "Publicar evento") {
                        publishEvent()
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

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionLabel("QUÉ ESTÁ PASANDO")
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 4), spacing: 10) {
                ForEach(EventCategory.allCases) { cat in
                    CategoryButton(category: cat, isSelected: selectedCategory == cat) {
                        selectedCategory = cat
                    }
                }
            }
        }
    }

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionLabel("NOMBRE")
            TextField("ej. Jam session en el parque", text: $title)
                .font(BullaTheme.Font.body(14))
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(BullaTheme.Colors.chipBg)
                .clipShape(RoundedRectangle(cornerRadius: BullaTheme.Radius.sm))
        }
    }

    private var mapSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionLabel("DÓNDE")
            ZStack {
                Map(position: $mapPosition)
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: BullaTheme.Radius.md))
                    .onMapCameraChange { ctx in pinnedCoordinate = ctx.region.center }
                VStack(spacing: 0) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(BullaTheme.Colors.brand)
                        .shadow(color: BullaTheme.Colors.brand.opacity(0.4), radius: 6, x: 0, y: 3)
                    Circle()
                        .fill(BullaTheme.Colors.ink.opacity(0.25))
                        .frame(width: 8, height: 4)
                        .blur(radius: 1)
                }
                VStack {
                    HStack {
                        Text("Arrastra para mover el pin")
                            .font(BullaTheme.Font.body(11))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(.black.opacity(0.5))
                            .clipShape(Capsule())
                            .padding(.top, 10)
                            .padding(.leading, 10)
                        Spacer()
                    }
                    Spacer()
                }
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: BullaTheme.Radius.md))
        }
    }

    private func addTag() {
        let clean = newTagText.trimmingCharacters(in: .whitespaces)
        guard !clean.isEmpty else { return }
        let tag = clean.hasPrefix("#") ? clean : "#\(clean)"
        if !tags.contains(tag) { tags.append(tag) }
        newTagText = ""
    }

    private func publishEvent() {
        guard !title.isEmpty, !isPublishing else { return }
        isPublishing = true
        Task {
            let iso = ISO8601DateFormatter()
            iso.formatOptions = [.withInternetDateTime]
            let req = CreateRallyRequest(
                title: title,
                description: nil,
                creatorId: appState.currentUserId ?? "anon",
                entryFee: 0,
                maxParticipants: 20,
                startsAt: iso.string(from: startTime),
                expiresAt: iso.string(from: endTime),
                lat: pinnedCoordinate.latitude,
                lng: pinnedCoordinate.longitude,
                category: selectedCategory.backendKey,
                tags: tags
            )
            if (try? await DropService.shared.createRally(req)) != nil {
                appState.afterPublish()
            }
            isPublishing = false
            dismiss()
        }
    }
}

// MARK: - Flow Tag Row
private struct FlowTagRow: View {
    @Binding var tags: [String]

    var body: some View {
        if tags.isEmpty { EmptyView() } else {
            ScrollView(.horizontal, showsIndicators: false) {
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
                Image(systemName: category.icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .white : BullaTheme.Colors.brand)
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
        }
        .buttonStyle(.plain)
        .animation(.spring(duration: 0.2), value: isSelected)
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
