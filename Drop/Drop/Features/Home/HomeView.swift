import SwiftUI
import MapKit

struct HomeView: View {
    @StateObject private var vm = HomeViewModel()
    @EnvironmentObject private var location: LocationManager
    @State private var selectedRally: Rally?

    private var mapRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 25.6672, longitude: -100.3101),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Map(initialPosition: .region(mapRegion)) {
                    ForEach(vm.rallies) { rally in
                        Annotation(rally.title, coordinate: CLLocationCoordinate2D(latitude: rally.lat, longitude: rally.lng)) {
                            Button {
                                selectedRally = rally
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(vm.venue(for: rally)?.isSponsor == true ? .yellow : .orange)
                                        .frame(width: 40, height: 40)
                                    Text("🔥")
                                        .font(.title3)
                                }
                                .shadow(radius: 4)
                            }
                        }
                    }
                }
                .ignoresSafeArea(edges: .top)

                VStack(spacing: 0) {
                    HStack {
                        Text("Rallies cerca")
                            .font(.title2.weight(.bold))
                        Spacer()
                        if vm.isLoading {
                            ProgressView()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)

                    if vm.rallies.isEmpty && !vm.isLoading {
                        Text("No hay rallies activos ahorita")
                            .foregroundStyle(.secondary)
                            .padding()
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(vm.rallies) { rally in
                                    NavigationLink(value: rally) {
                                        RallyCardView(
                                            rally: rally,
                                            venue: vm.venue(for: rally),
                                            distanceText: location.distanceText(to: rally)
                                        )
                                        .frame(width: 300)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                        }
                    }
                }
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                .padding(.bottom, 8)
            }
            .navigationDestination(for: Rally.self) { rally in
                RallyDetailView(rally: rally)
            }
            .navigationDestination(item: $selectedRally) { rally in
                RallyDetailView(rally: rally)
            }
            .task { await vm.loadRallies() }
        }
    }
}
