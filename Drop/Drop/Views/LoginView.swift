import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState

    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var animateIn = false

    var body: some View {
        ZStack {
            // Background
            Color(hex: "#0A0A0F").ignoresSafeArea()

            // Heatmap glow
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [BullaTheme.Colors.brand.opacity(0.35), .clear],
                            center: .center, startRadius: 0, endRadius: 220
                        )
                    )
                    .frame(width: 440, height: 440)
                    .offset(x: -60, y: -180)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "#EC4899").opacity(0.2), .clear],
                            center: .center, startRadius: 0, endRadius: 180
                        )
                    )
                    .frame(width: 360, height: 360)
                    .offset(x: 100, y: 80)
            }
            .blur(radius: 8)

            VStack(spacing: 0) {
                Spacer()

                // Logo
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

                // Form card
                VStack(spacing: 16) {
                    // Email field
                    LoginField(
                        text: $email,
                        placeholder: "correo@ejemplo.com",
                        icon: "envelope",
                        isSecure: false
                    )

                    // Password field
                    LoginField(
                        text: $password,
                        placeholder: "contraseña",
                        icon: "lock",
                        isSecure: !showPassword,
                        trailingButton: {
                            Button(action: { showPassword.toggle() }) {
                                Image(systemName: showPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.white.opacity(0.4))
                                    .font(.system(size: 14))
                            }
                        }
                    )

                    // Forgot password
                    HStack {
                        Spacer()
                        Button("¿Olvidaste tu contraseña?") {}
                            .font(BullaTheme.Font.body(13))
                            .foregroundColor(BullaTheme.Colors.brand)
                    }

                    // Login button
                    Button(action: {
                        appState.login(email: email, password: password)
                    }) {
                        Text("Entrar")
                            .font(BullaTheme.Font.body(16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(BullaTheme.Gradients.brand)
                            .clipShape(Capsule())
                            .shadow(color: BullaTheme.Colors.brand.opacity(0.5), radius: 16, x: 0, y: 6)
                    }

                    // Divider
                    HStack {
                        Rectangle().fill(.white.opacity(0.15)).frame(height: 1)
                        Text("o")
                            .font(BullaTheme.Font.body(13))
                            .foregroundColor(.white.opacity(0.4))
                            .padding(.horizontal, 12)
                        Rectangle().fill(.white.opacity(0.15)).frame(height: 1)
                    }

                    // Google OAuth
                    Button(action: { appState.loginWithGoogle() }) {
                        HStack(spacing: 10) {
                            // Google icon (simplified)
                            ZStack {
                                Circle().fill(.white).frame(width: 22, height: 22)
                                Text("G")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(Color(hex: "#4285F4"))
                            }
                            Text("Continuar con Google")
                                .font(BullaTheme.Font.body(15, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.white.opacity(0.1))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(.white.opacity(0.15), lineWidth: 1))
                    }

                    // Demo rápido
                    Button("Entrar como demo →") {
                        appState.login(email: "demo@drop.app", password: "")
                    }
                    .font(BullaTheme.Font.body(14))
                    .foregroundColor(.white.opacity(0.4))
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(.white.opacity(0.1), lineWidth: 1)
                        )
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
}

// MARK: - Login Field
private struct LoginField<TrailingButton: View>: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    var isSecure: Bool
    var trailingButton: () -> TrailingButton

    init(
        text: Binding<String>,
        placeholder: String,
        icon: String,
        isSecure: Bool,
        @ViewBuilder trailingButton: @escaping () -> TrailingButton = { EmptyView() }
    ) {
        self._text = text
        self.placeholder = placeholder
        self.icon = icon
        self.isSecure = isSecure
        self.trailingButton = trailingButton
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.4))
                .frame(width: 20)

            if isSecure {
                SecureField("", text: $text, prompt: Text(placeholder).foregroundColor(.white.opacity(0.3)))
                    .foregroundColor(.white)
                    .font(BullaTheme.Font.body(15))
            } else {
                TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.white.opacity(0.3)))
                    .foregroundColor(.white)
                    .font(BullaTheme.Font.body(15))
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }

            trailingButton()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.1), lineWidth: 1))
    }
}

// MARK: - Preview
#Preview {
    LoginView()
        .environmentObject(AppState())
}
