import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState

    @State private var email = ""
    @State private var username = ""
    @State private var animateIn = false
    @State private var isLoading = false

    var canSubmit: Bool {
        email.contains("@") && username.count >= 2
    }

    var body: some View {
        ZStack {
            Color(hex: "#0A0A0F").ignoresSafeArea()

            ZStack {
                Circle()
                    .fill(RadialGradient(
                        colors: [BullaTheme.Colors.brand.opacity(0.35), .clear],
                        center: .center, startRadius: 0, endRadius: 220
                    ))
                    .frame(width: 440, height: 440)
                    .offset(x: -60, y: -180)
                Circle()
                    .fill(RadialGradient(
                        colors: [Color(hex: "#EC4899").opacity(0.2), .clear],
                        center: .center, startRadius: 0, endRadius: 180
                    ))
                    .frame(width: 360, height: 360)
                    .offset(x: 100, y: 80)
            }
            .blur(radius: 8)

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(BullaTheme.Gradients.brand)
                            .frame(width: 72, height: 72)
                            .shadow(color: BullaTheme.Colors.brand.opacity(0.5), radius: 24, x: 0, y: 8)
                        Text("◉")
                            .font(.system(size: 36))
                            .foregroundColor(.white)
                    }
                    Text("Drop")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .tracking(-1)
                    Text("sal en menos de 5 minutos")
                        .font(BullaTheme.Font.body(15))
                        .foregroundColor(.white.opacity(0.5))
                }
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : 20)

                Spacer()

                VStack(spacing: 16) {
                    LoginField(text: $email, placeholder: "correo@ejemplo.com", icon: "envelope")
                        .keyboardType(.emailAddress)

                    LoginField(text: $username, placeholder: "nombre de usuario", icon: "person")

                    Button(action: submit) {
                        ZStack {
                            Text("Entrar")
                                .font(BullaTheme.Font.body(16, weight: .bold))
                                .foregroundColor(.white)
                                .opacity(isLoading ? 0 : 1)
                            if isLoading {
                                ProgressView().tint(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(canSubmit ? BullaTheme.Gradients.brand : LinearGradient(colors: [.gray.opacity(0.4), .gray.opacity(0.4)], startPoint: .leading, endPoint: .trailing))
                        .clipShape(Capsule())
                        .shadow(color: canSubmit ? BullaTheme.Colors.brand.opacity(0.5) : .clear, radius: 16, x: 0, y: 6)
                    }
                    .disabled(!canSubmit || isLoading)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(.ultraThinMaterial)
                        .overlay(RoundedRectangle(cornerRadius: 28).stroke(.white.opacity(0.1), lineWidth: 1))
                )
                .padding(.horizontal, 20)
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : 40)

                Spacer().frame(height: 40)
            }
        }
        .onAppear {
            withAnimation(.spring(duration: 0.7, bounce: 0.3).delay(0.1)) {
                animateIn = true
            }
        }
    }

    private func submit() {
        isLoading = true
        appState.login(email: email.lowercased().trimmingCharacters(in: .whitespaces),
                       username: username.trimmingCharacters(in: .whitespaces))
    }
}

// MARK: - Login Field
private struct LoginField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.4))
                .frame(width: 20)

            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.white.opacity(0.3)))
                .foregroundColor(.white)
                .font(BullaTheme.Font.body(15))
                .keyboardType(keyboardType)
                .autocapitalization(.none)
                .autocorrectionDisabled()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.1), lineWidth: 1))
    }
}

#Preview {
    LoginView()
        .environmentObject(AppState())
}
