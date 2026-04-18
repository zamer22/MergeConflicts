import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: AuthManager
    @State private var username = ""

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            VStack(spacing: 8) {
                Text("Drop")
                    .font(.system(size: 56, weight: .black))
                Text("Sal. Ahora. Sin excusas.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(spacing: 16) {
                TextField("Elige un username", text: $username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))

                Button {
                    guard !username.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    auth.signInMock(username: username.trimmingCharacters(in: .whitespaces))
                } label: {
                    Text("Entrar")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.primary)
                        .foregroundStyle(.background)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(.horizontal, 24)
            Spacer()
        }
    }
}
