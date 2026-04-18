import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var auth: AuthManager
    @StateObject private var vm = ProfileViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Avatar + username
                    VStack(spacing: 8) {
                        Circle()
                            .fill(.orange.opacity(0.2))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text(String(auth.currentUser?.username.prefix(1).uppercased() ?? "?"))
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundStyle(.orange)
                            )
                        Text("@\(auth.currentUser?.username ?? "")")
                            .font(.title3.weight(.bold))
                    }
                    .padding(.top)

                    // Stats
                    HStack(spacing: 32) {
                        statView(value: "\(auth.currentUser?.rallyScore ?? 0)", label: "Score")
                        statView(value: "\(auth.currentUser?.ralliesAttended ?? 0)", label: "Rallies")
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)

                    // Badges
                    if !vm.badges.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Badges")
                                .font(.headline)
                                .padding(.horizontal)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(vm.badges, id: \.self) { badge in
                                        Text("🏅 \(badge)")
                                            .font(.subheadline.weight(.medium))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(.orange.opacity(0.15))
                                            .clipShape(Capsule())
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }

                    // Historial
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Historial")
                            .font(.headline)
                            .padding(.horizontal)

                        if vm.isLoading {
                            ProgressView().padding()
                        } else if vm.attendedRallies.isEmpty {
                            Text("Aún no has ido a ningún rally")
                                .foregroundStyle(.secondary)
                                .padding(.horizontal)
                        } else {
                            ForEach(vm.attendedRallies) { rally in
                                HStack {
                                    Text(rally.title)
                                    Spacer()
                                    Text("$\(rally.entryFee) MXN")
                                        .foregroundStyle(.secondary)
                                        .font(.subheadline)
                                }
                                .padding()
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                                .padding(.horizontal)
                            }
                        }
                    }

                    Button("Cerrar sesión") { auth.signOut() }
                        .foregroundStyle(.red)
                        .padding(.top)
                }
            }
            .navigationTitle("Perfil")
            .task { await vm.loadProfile() }
        }
    }

    private func statView(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.title.weight(.bold))
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
    }
}
