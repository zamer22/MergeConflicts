import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState

    @State private var email = ""
    @State private var password = ""
    @State private var animateIn = false
    @State private var isLoading = false

    var canSubmit: Bool {
        email.contains("@") && password.count >= 4
    }

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()

            ZStack {
                RoundedRectangle(cornerRadius: 40)
                    .fill(
                        LinearGradient(
                            colors: [BullaTheme.Colors.brandSoft, .white],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 360, height: 360)
                    .offset(x: -80, y: -220)
                Circle()
                    .fill(RadialGradient(
                        colors: [Color(hex: "#FDE68A").opacity(0.35), .clear],
                        center: .center, startRadius: 0, endRadius: 180
                    ))
                    .frame(width: 360, height: 360)
                    .offset(x: 120, y: 120)
            }
            .blur(radius: 18)

            VStack(spacing: 0) {
                Spacer().frame(height: 148)

                VStack(spacing: 0) {
                    ZStack {
                        Circle()
                            .fill(BullaTheme.Gradients.brand)
                            .frame(width: 72, height: 72)
                            .shadow(color: BullaTheme.Colors.brand.opacity(0.24), radius: 18, x: 0, y: 8)
                        Text("◉")
                            .font(.system(size: 36))
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 26)

                    Text("Drop")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundColor(BullaTheme.Colors.ink)
                        .tracking(-1)
                        .padding(.bottom, 18)

                    Text("Tu ciudad esta pasando ahora mismo")
                        .font(BullaTheme.Font.body(15))
                        .foregroundColor(BullaTheme.Colors.textSecondary)
                }
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 36 : 56)

                Spacer()

                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Entrar")
                            .font(BullaTheme.Font.heading(22))
                            .foregroundColor(BullaTheme.Colors.ink)
                        Text("Ingresa con tu correo y contraseña")
                            .font(BullaTheme.Font.body(13))
                            .foregroundColor(BullaTheme.Colors.textSecondary)
                    }

                    LoginField(text: $email, placeholder: "correo@ejemplo.com", icon: "envelope", keyboardType: .emailAddress)

                    LoginField(text: $password, placeholder: "contraseña", icon: "lock", isSecure: true)

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
                        .fill(.white)
                        .overlay(RoundedRectangle(cornerRadius: 28).stroke(BullaTheme.Colors.line, lineWidth: 1))
                )
                .shadow(color: .black.opacity(0.06), radius: 24, x: 0, y: 12)
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
        let normalizedEmail = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let derivedUsername = normalizedEmail
            .split(separator: "@")
            .first
            .map(String.init)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        appState.login(
            email: normalizedEmail,
            username: (derivedUsername?.isEmpty == false ? derivedUsername! : "dropuser")
        )
    }
}

// MARK: - Login Field
private struct LoginField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(BullaTheme.Colors.textSecondary)
                .frame(width: 20)

            Group {
                if isSecure {
                    SecureField("", text: $text, prompt: Text(placeholder).foregroundColor(BullaTheme.Colors.textTertiary))
                } else {
                    TextField("", text: $text, prompt: Text(placeholder).foregroundColor(BullaTheme.Colors.textTertiary))
                        .keyboardType(keyboardType)
                }
            }
            .foregroundColor(BullaTheme.Colors.ink)
            .font(BullaTheme.Font.body(15))
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(BullaTheme.Colors.chipBg)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(BullaTheme.Colors.line, lineWidth: 1))
    }
}

#Preview {
    LoginView()
        .environmentObject(AppState())
}
