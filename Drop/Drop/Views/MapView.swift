import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedEvent: Event? = nil
    @State private var showBottomSheet = true
    @State private var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 25.6672, longitude: -100.3101),
            span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
        )
    )

    var body: some View {
        ZStack(alignment: .bottom) {

            // Map — capa base, recibe todos los toques del centro
            Map(position: $cameraPosition) {
                ForEach(appState.events) { event in
                    Annotation("", coordinate: eventCoordinate(event)) {
                        EventPin(event: event, isSelected: selectedEvent?.id == event.id)
                            .onTapGesture {
                                withAnimation(.spring(duration: 0.3)) {
                                    selectedEvent = event
                                    showBottomSheet = true
                                }
                            }
                    }
                }
                UserAnnotation()
            }
            .mapStyle(.standard(elevation: .realistic))
            .ignoresSafeArea(edges: .top)

            // Overlay superior — sólo ocupa el área de la barra de búsqueda
            VStack {
                VStack(spacing: 10) {
                    BullaSearchBar(placeholder: "Buscar eventos o lugares")
                        .padding(.horizontal, BullaTheme.Spacing.lg)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            BullaChip(text: "Ahora", style: .live)
                            BullaChip(text: "Pronto", style: .soon)
                            BullaChip(text: "Hoy", style: .outline)
                            BullaChip(text: "Finde", style: .outline)
                            BullaChip(text: "Gratis", style: .outline)
                        }
                        .padding(.horizontal, BullaTheme.Spacing.lg)
                    }
                }
                .padding(.top, 60)
                .padding(.bottom, 12)
                .background(
                    LinearGradient(
                        colors: [.white.opacity(0.97), .white.opacity(0.85), .clear],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                Spacer().allowsHitTesting(false)
            }

            // Badge de zona IA — esquina inferior derecha antes del sheet
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    AIBadge(label: "Zona activa")
                        .padding(.trailing, BullaTheme.Spacing.lg)
                        .padding(.bottom, showBottomSheet ? 160 : 100)
                }
            }
            .allowsHitTesting(false)

            // Bottom sheet del evento seleccionado
            if showBottomSheet, let event = selectedEvent ?? appState.events.first {
                MapBottomSheet(event: event) {
                    appState.selectedEvent = event
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .padding(.bottom, 82)
            }

            // Tab bar
            VStack(spacing: 0) {
                Spacer()
                BullaTabBar(selected: $appState.selectedTab)
                    .ignoresSafeArea(edges: .bottom)
            }
        }
    }

    func eventCoordinate(_ event: Event) -> CLLocationCoordinate2D {
        // Use real coordinates from DTO if non-zero, else spread around Monterrey
        guard event.lat != 0 && event.lng != 0 else {
            let base = CLLocationCoordinate2D(latitude: 25.6672, longitude: -100.3101)
            let idx = appState.events.firstIndex(where: { $0.id == event.id }) ?? 0
            return CLLocationCoordinate2D(
                latitude: base.latitude + Double(idx) * 0.003,
                longitude: base.longitude + Double(idx % 2 == 0 ? 1 : -1) * 0.004
            )
        }
        return CLLocationCoordinate2D(latitude: event.lat, longitude: event.lng)
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
