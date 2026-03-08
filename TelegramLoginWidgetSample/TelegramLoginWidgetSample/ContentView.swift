import SwiftUI
import TelegramLoginData

struct ContentView: View {
    @State private var isDarkMode = true
    @State private var user: TelegramLoginResultSuccess? = nil
    @State private var toastMessage: String? = nil

    private var backgroundColor: Color {
        isDarkMode ? Color(red: 0.055, green: 0.071, blue: 0.122) : .white // 0xFF0E121F
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar with theme toggle
                HStack {
                    Spacer()
                    Button {
                        isDarkMode.toggle()
                    } label: {
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                            .font(.system(size: 22))
                            .foregroundColor(isDarkMode ? .white : .primary)
                            .padding(8)
                    }
                }
                .padding(.top, 16)
                .padding(.horizontal, 16)

                // Screen content
                if let user {
                    MainScreen(
                        user: user,
                        backToLoginScreen: {
                            self.user = nil
                        },
                        onLogout: {
                            Task {
                                try await TelegramLoginManager.shared.logout()
                                self.user = nil
                            }
                        }
                    )
                } else {
                    LoginScreen { result in
                        if let user = result as? TelegramLoginResultSuccess {
                            self.user = user
                        } else {
                            showToast("Canceled")
                        }
                    }
                }
            }

            // Snackbar toast
            if let message = toastMessage {
                Text(message)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(isDarkMode ? Color.white : Color(.label))
                    .foregroundColor(isDarkMode ? Color.black : Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.bottom, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .animation(.easeInOut(duration: 0.25), value: isDarkMode)
        .animation(.easeInOut(duration: 0.3), value: toastMessage)
    }

    private func showToast(_ message: String) {
        toastMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            toastMessage = nil
        }
    }
}

#Preview {
    ContentView()
}
