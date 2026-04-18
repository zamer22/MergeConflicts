import SwiftUI

struct MockPaymentView: View {
    let rally: Rally
    let onConfirm: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var processing = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            Image(systemName: "creditcard.fill")
                .font(.system(size: 60))
                .foregroundStyle(.orange)

            VStack(spacing: 8) {
                Text("Confirmar pago")
                    .font(.title2.weight(.bold))
                Text("$\(rally.entryFee) MXN")
                    .font(.system(size: 44, weight: .black))
                Text(rally.title)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                warningRow(icon: "exclamationmark.triangle", text: "Si cancelas antes de 2h pierdes todo")
                warningRow(icon: "arrow.uturn.backward", text: "Cancelación antes → reembolso del 50%")
            }
            .padding()
            .background(.orange.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))

            Spacer()

            VStack(spacing: 12) {
                Button {
                    processing = true
                    onConfirm()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { dismiss() }
                } label: {
                    Group {
                        if processing {
                            ProgressView().tint(.white)
                        } else {
                            Text("Pagar $\(rally.entryFee) MXN")
                        }
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.orange)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(processing)

                Button("Cancelar") { dismiss() }
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }

    private func warningRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon).foregroundStyle(.orange)
            Text(text).font(.subheadline)
        }
    }
}
