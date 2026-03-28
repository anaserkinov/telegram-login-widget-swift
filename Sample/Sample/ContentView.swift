import SwiftUI
import TelegramLogin
import TelegramLoginData

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme

    @State private var localIsDarkMode: Bool? = nil
    @State private var useLegacyMethod = false
    @State private var user: User? = nil
    @State private var toastMessage: String? = nil

    private var isDarkMode: Bool {
        localIsDarkMode ?? (colorScheme == .dark)
    }

    private var backgroundColor: Color {
        isDarkMode ? Color(red: 0.055, green: 0.071, blue: 0.122) : .white  // 0xFF0E121F
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar with theme toggle
                HStack {
                    if user == nil {
                        Button {
                            useLegacyMethod = !useLegacyMethod
                        } label: {
                            Text(
                                useLegacyMethod ? "Switch to telegram-login" : "Switch to telegram-widget"
                            )
                        }
                        .buttonStyle(.glassProminent)
                        .frame(maxWidth: .infinity)
                    } else {
                        Spacer()
                    }

                    Button {
                        localIsDarkMode = !isDarkMode
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
                    if useLegacyMethod {
                        LoginScreenLegacy { result in
                            if let user = result as? TelegramLoginResultSuccess {
                                self.user = User(
                                    photoUrl: user.photoUrl,
                                    fullName: user.firstName + (user.lastName != nil ? " \(user.lastName!)" : ""),
                                    username: user.username,
                                    phoneNumber: nil,
                                    loggedInWithWidget: true
                                )
                            } else {
                                showToast("Canceled")
                            }
                        }
                    } else {
                        LoginScreen { result in
                            switch result {
                            case .success(let data):
                                self.user = User(
                                    photoUrl: data.user.picture,
                                    fullName: data.user.name,
                                    username: data.user.preferredUsername,
                                    phoneNumber: data.user.phoneNumber,
                                    loggedInWithWidget: false
                                )
                            case .cancelled:
                                showToast("Canceled")
                            }
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
        .animation(.easeInOut(duration: 0.25), value: isDarkMode)
        .animation(.easeInOut(duration: 0.3), value: toastMessage)
        .applyIf(localIsDarkMode != nil) { view in
            view.preferredColorScheme(localIsDarkMode! ? .dark : .light)
        }
    }

    private func showToast(_ message: String) {
        toastMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            toastMessage = nil
        }
    }
}

extension View {
    @ViewBuilder
    func applyIf<Content: View>(
        _ condition: Bool,
        transform: (Self) -> Content
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

#Preview {
    ContentView()
}
