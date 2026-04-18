import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedEvent: Event? = nil
    @State private var selectedHotZoneID: UUID? = nil
    @State private var isHotZoneVisible = false
    @State private var showBottomSheet = true
    @State private var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 25.6672, longitude: -100.3101),
            span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
        )
    )

    var body: some View {
        ZStack(alignment: .bottom) {

            DropMapCanvas(
                cameraPosition: $cameraPosition,
                showsHotZones: isHotZoneVisible,
                hotZones: appState.hotZones,
                events: appState.events,
                selectedEventID: selectedEvent?.id,
                selectedHotZoneID: activeHotZone?.id,
                onSelectZone: { zone in
                    withAnimation(.spring(duration: 0.35)) {
                        selectedHotZoneID = zone.id
                        focus(on: zone)
                    }
                },
                onSelectEvent: { event in
                    withAnimation(.spring(duration: 0.3)) {
                        selectedEvent = event
                        showBottomSheet = true
                    }
                }
            )

            VStack(spacing: 0) {
                topChrome
                Spacer()
                bottomChrome
            }

            // Tab bar
            VStack(spacing: 0) {
                Spacer()
                BullaTabBar(selected: $appState.selectedTab)
                    .ignoresSafeArea(edges: .bottom)
            }
        }
        .task {
            if appState.hotZones.isEmpty {
                await appState.loadHotZones()
            }
            if selectedEvent == nil {
                selectedEvent = defaultLiveEvent(in: appState.events)
            }
            if selectedHotZoneID == nil {
                selectedHotZoneID = appState.hotZones.first?.id
            }
        }
        .onChange(of: appState.events.map(\.id)) { _, _ in
            let newEvents = appState.events
            if selectedEvent == nil || !(newEvents.contains { $0.id == selectedEvent?.id }) {
                selectedEvent = defaultLiveEvent(in: newEvents)
            }
        }
        .onChange(of: appState.hotZones.map(\.id)) { _, _ in
            let newZones = appState.hotZones
            if selectedHotZoneID == nil || !(newZones.contains { $0.id == selectedHotZoneID }) {
                selectedHotZoneID = newZones.first?.id
            }
        }
    }

    var activeHotZone: HotZone? {
        appState.hotZones.first(where: { $0.id == selectedHotZoneID }) ?? appState.hotZones.first
    }

    private var topChrome: some View {
        VStack(spacing: 10) {
            BullaSearchBar(placeholder: "Buscar eventos o lugares")
                .padding(.horizontal, BullaTheme.Spacing.lg)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    BullaChip(text: "● Ahora", style: .live)
                    BullaChip(text: "Pronto", style: .soon)
                    BullaChip(text: "Hoy", style: .outline)
                    BullaChip(text: "Finde", style: .outline)
                    BullaChip(text: "Gratis", style: .outline)
                }
                .padding(.horizontal, BullaTheme.Spacing.lg)
            }
        }
        .padding(.top, 60)
        .background(
            LinearGradient(
                colors: [.white.opacity(0.95), .white.opacity(0.8), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var bottomChrome: some View {
        VStack(alignment: .leading, spacing: 12) {
            HotZoneToggleButton(isActive: isHotZoneVisible) {
                withAnimation(.spring(duration: 0.32)) {
                    isHotZoneVisible.toggle()
                    if isHotZoneVisible, let zone = activeHotZone {
                        focus(on: zone)
                    }
                }
            }
            .padding(.horizontal, BullaTheme.Spacing.lg)

            if isHotZoneVisible {
                HotZoneInsightCard(
                    zone: activeHotZone,
                    summary: appState.hotZoneSummary,
                    sourceLabel: appState.hotZoneInsightSource,
                    isLoading: appState.isLoadingHotZones
                )
                .padding(.horizontal, BullaTheme.Spacing.lg)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            } else if showBottomSheet, let event = selectedEvent ?? defaultLiveEvent(in: appState.events) {
                MapBottomSheet(event: event) {
                    appState.selectedEvent = event
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(.bottom, isHotZoneVisible ? 92 : 8)
    }

    func focus(on zone: HotZone) {
        cameraPosition = .region(
            MKCoordinateRegion(
                center: zone.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        )
    }

    private func defaultLiveEvent(in events: [Event]) -> Event? {
        events.first(where: isLive) ?? events.first
    }

    private func isLive(_ event: Event) -> Bool {
        if case .live = event.status {
            return true
        }
        return false
    }
}

private struct DropMapCanvas: View {
    @Binding var cameraPosition: MapCameraPosition
    let showsHotZones: Bool
    let hotZones: [HotZone]
    let events: [Event]
    let selectedEventID: UUID?
    let selectedHotZoneID: UUID?
    let onSelectZone: (HotZone) -> Void
    let onSelectEvent: (Event) -> Void

    var body: some View {
        Map(position: $cameraPosition) {
            if showsHotZones {
                ForEach(hotZones) { zone in
                    MapCircle(center: zone.coordinate, radius: zone.radiusMeters * 1.5)
                        .foregroundStyle(zone.heatOuterColor)
                    MapCircle(center: zone.coordinate, radius: zone.radiusMeters)
                        .foregroundStyle(zone.heatMidColor)
                    MapCircle(center: zone.coordinate, radius: zone.radiusMeters * 0.55)
                        .foregroundStyle(zone.heatCoreColor)

                    Annotation(zone.title, coordinate: zone.coordinate) {
                        HotZoneMarker(zone: zone, isSelected: selectedHotZoneID == zone.id)
                            .onTapGesture { onSelectZone(zone) }
                    }
                }
            }

            ForEach(events) { event in
                Annotation("", coordinate: eventCoordinate(event)) {
                    EventPin(event: event, isSelected: selectedEventID == event.id)
                        .onTapGesture { onSelectEvent(event) }
                }
            }

            UserAnnotation()
        }
        .mapStyle(.standard(elevation: .realistic))
        .ignoresSafeArea(edges: .top)
    }

    private func eventCoordinate(_ event: Event) -> CLLocationCoordinate2D {
        // Usa las coordenadas reales del evento si están disponibles
        if let coordinate = event.coordinate {
            return coordinate
        }
        // Si lat/lng vienen del DTO y son distintos de cero, úsalos
        if event.lat != 0 && event.lng != 0 {
            return CLLocationCoordinate2D(latitude: event.lat, longitude: event.lng)
        }
        // Fallback: dispersar alrededor de Monterrey
        let base = CLLocationCoordinate2D(latitude: 25.6672, longitude: -100.3101)
        let idx = events.firstIndex(where: { $0.id == event.id }) ?? 0
        return CLLocationCoordinate2D(
            latitude: base.latitude + Double(idx) * 0.003,
            longitude: base.longitude + Double(idx % 2 == 0 ? 1 : -1) * 0.004
        )
    }
}

private struct HotZoneToggleButton: View {
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 11, weight: .bold))
                Text("Zona hot")
                    .font(BullaTheme.Font.body(12, weight: .semibold))
            }
            .foregroundColor(isActive ? .white : Color(hex: "#6D28D9"))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isActive ? AnyShapeStyle(BullaTheme.Gradients.ai) : AnyShapeStyle(.white.opacity(0.92)))
            )
            .overlay(
                Capsule()
                    .stroke(isActive ? .clear : Color(hex: "#E9D5FF"), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.08), radius: 14, x: 0, y: 8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Event Pin
struct EventPin: View {
    let event: Event
    var isSelected: Bool = false

    var pinColor: Color {
        switch event.category {
        case .music: return Color(hex: "#6D5FA0")
        case .fair, .market: return BullaTheme.Colors.brand
        case .art: return Color(hex: "#3B82F6")
        case .food: return Color(hex: "#B5874A")
        case .sport: return BullaTheme.Colors.live
        default: return BullaTheme.Colors.brand
        }
    }

    var size: CGFloat { isSelected ? 44 : 32 }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(pinColor)
                    .frame(width: size, height: size)
                    .overlay(Circle().stroke(.white, lineWidth: 2))
                    .shadow(color: .black.opacity(0.2), radius: isSelected ? 8 : 4, x: 0, y: 3)

                Image(systemName: event.category.icon)
                    .font(.system(size: size * 0.38, weight: .medium))
                    .foregroundColor(.white)
            }

            Triangle()
                .fill(pinColor)
                .frame(width: 10, height: 6)
                .offset(y: -1)
        }
        .scaleEffect(isSelected ? 1.1 : 1)
        .animation(.spring(duration: 0.3), value: isSelected)
    }
}

private struct HotZoneMarker: View {
    let zone: HotZone
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 10, weight: .bold))
                Text(zone.title)
                    .lineLimit(1)
                Text(zone.confidenceLabel)
                    .foregroundColor(.white.opacity(0.8))
            }
            .font(BullaTheme.Font.body(11, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#FF5A3C"), Color(hex: "#FF8A3C")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .overlay(
                Capsule()
                    .stroke(.white.opacity(0.18), lineWidth: 1)
            )
            .shadow(color: Color(hex: "#FF5A3C").opacity(0.28), radius: isSelected ? 16 : 10, x: 0, y: 8)

            Circle()
                .fill(Color(hex: "#FF5A3C"))
                .frame(width: isSelected ? 14 : 10, height: isSelected ? 14 : 10)
                .overlay(Circle().stroke(.white, lineWidth: 2))
        }
        .scaleEffect(isSelected ? 1.03 : 0.96)
        .animation(.spring(duration: 0.28), value: isSelected)
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

private struct HotZoneInsightCard: View {
    let zone: HotZone?
    let summary: String
    let sourceLabel: String
    let isLoading: Bool

    private var displaySummary: String {
        zone?.insight ?? zone?.fallbackInsight ?? summary
    }

    private var displaySource: String {
        zone?.insight == nil ? "Motor local" : sourceLabel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        AIBadge(label: "Zona hot")
                        Text(displaySource)
                            .font(BullaTheme.Font.body(11, weight: .semibold))
                            .foregroundColor(BullaTheme.Colors.textSecondary)
                    }

                    Text(zone?.title ?? "Buscando patrón")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(BullaTheme.Colors.ink)
                }
                Spacer()

                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                }
            }

            Text(displaySummary)
                .font(BullaTheme.Font.body(13))
                .foregroundColor(BullaTheme.Colors.ink)
                .fixedSize(horizontal: false, vertical: true)

            if let zone {
                HStack(spacing: 6) {
                    BullaChip(text: zone.bestWindow, style: .outline)
                    BullaChip(text: "≈ \(zone.expectedCrowd)", style: .outline)
                    BullaChip(text: zone.momentum.label, style: .brand)
                }

                if !zone.categoriesLabel.isEmpty {
                    Text(zone.categoriesLabel)
                        .font(BullaTheme.Font.body(12, weight: .medium))
                        .foregroundColor(BullaTheme.Colors.textSecondary)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.92), Color(hex: "#FFF3EB").opacity(0.96)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.65), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Map Bottom Sheet
struct MapBottomSheet: View {
    let event: Event
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(BullaTheme.Colors.line)
                    .frame(width: 40, height: 4)
                    .padding(.top, 10)
                    .padding(.bottom, 12)

                HStack(spacing: 12) {
                    EventImagePlaceholder(category: event.category, height: 60)
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            BullaChip(text: "En vivo", style: .live)
                            if event.isFree {
                                BullaChip(text: "Gratis", style: .default)
                            }
                        }
                        Text(event.title)
                            .font(BullaTheme.Font.heading(15))
                            .foregroundColor(BullaTheme.Colors.ink)
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 10))
                            Text(event.distanceMeters > 0 ? "a \(Int(event.distanceMeters))m" : event.location)
                            Text("·")
                            Text("+\(event.attendeeCount) van")
                                .fontWeight(.bold)
                        }
                        .font(BullaTheme.Font.body(12))
                        .foregroundColor(BullaTheme.Colors.textSecondary)
                    }
                    Spacer()
                }
                .padding(.horizontal, BullaTheme.Spacing.lg)
                .padding(.bottom, 14)
            }
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: -4)
        )
        .padding(.horizontal, 8)
    }
}

// MARK: - Preview
#Preview {
    MapView()
        .environmentObject(AppState())
}