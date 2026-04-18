import SwiftUI

struct RallyDetailView: View {
    let rally: Rally
    @StateObject private var vm: RallyDetailViewModel
    @State private var showSuccess = false

    init(rally: Rally) {
        self.rally = rally
        _vm = StateObject(wrappedValue: RallyDetailViewModel(rally: rally))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 6) {
                    Text(rally.title)
                        .font(.title.weight(.bold))
                    if let desc = rally.description {
                        Text(desc)
                            .foregroundStyle(.secondary)
                    }
                }

                // Stats
                HStack(spacing: 24) {
                    statView(icon: "creditcard", text: "$\(rally.entryFee) MXN")
                    statView(icon: "clock", text: rally.timeRemainingText)
                    statView(icon: "person.2", text: "\(vm.participants.count)/\(rally.maxParticipants)")
                }

                // Progreso
                VStack(alignment: .leading, spacing: 6) {
                    Text("Cupo")
                        .font(.subheadline.weight(.medium))
                    ProgressView(value: vm.participationProgress)
                        .tint(.orange)
                    Text("\(vm.spotsLeft) lugares disponibles")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Divider()

                // Participantes
                if !vm.participants.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Ya van \(vm.participants.count)")
                            .font(.subheadline.weight(.medium))
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: -10) {
                                ForEach(vm.participants) { p in
                                    Circle()
                                        .fill(Color.orange.opacity(0.7))
                                        .frame(width: 36, height: 36)
                                        .overlay(
                                            Text(String(p.userId.uuidString.prefix(1)).uppercased())
                                                .font(.caption.weight(.bold))
                                                .foregroundStyle(.white)
                                        )
                                        .overlay(Circle().stroke(.background, lineWidth: 2))
                                }
                            }
                        }
                    }
                }

                Spacer(minLength: 40)

                // Botón
                if vm.isJoined {
                    Label("Ya estás dentro", systemImage: "checkmark.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.green.opacity(0.15))
                        .foregroundStyle(.green)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                } else {
                    Button { vm.initiateJoin() } label: {
                        Text("Drop in — $\(rally.entryFee) MXN")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.orange)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(vm.spotsLeft == 0 || vm.isLoading)
                }
            }
            .padding()
        }
        .task { await vm.loadParticipants() }
        .sheet(isPresented: $vm.showMockPayment) {
            MockPaymentView(rally: rally) {
                Task { await vm.confirmMockPayment() }
            }
        }
        .alert("¡Estás dentro!", isPresented: $vm.paymentSuccess) {
            Button("OK") {}
        } message: {
            Text("Pagaste $\(rally.entryFee) MXN. Si cancelas, pierdes el dinero. ¡Ve!")
        }
        .alert("Error", isPresented: .constant(vm.errorMessage != nil)) {
            Button("OK") { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }

    private func statView(icon: String, text: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(.orange)
            Text(text)
                .font(.caption.weight(.medium))
        }
    }
}
