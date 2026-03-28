//
//  ContentView.swift
//  Sample
//
//  Created by Anas Erkinjonov on 02/03/26.
//

import SwiftUI
import TelegramLogin

#Preview {
    LoginScreen { _ in

    }
}

struct LoginScreen: View {

    @State
    var telegramConfig = TelegramLoginConfig(
        clientId: 8_266_153_417,
        redirectURI: "https://anasmusa.me"
    )

    @State private var showDialog = false

    var onResult: (TelegramLoginResult) -> Void

    var body: some View {
        VStack {
            TelegramLoginButton(config: telegramConfig, onResult: onResult) {
                HStack {
                    TelegramButtonIcon()
                    Text("Sign in with Telegram")
                }
                .frame(maxWidth: .infinity)
            }
            .tint(TelegramDefaults.primaryColor)
            .buttonStyle(.glassProminent)

            TelegramLoginButton(config: telegramConfig, onResult: onResult) {
                HStack {
                    TelegramButtonIcon()
                        .foregroundStyle(TelegramDefaults.primaryColor)
                    Text("Sign in with Telegram")
                        .foregroundStyle(.black)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 12)
            }
            .tint(.white)
            .buttonStyle(.glassProminent)

            TelegramLoginButton(config: telegramConfig, onResult: onResult) {
                HStack {
                    TelegramButtonIcon()
                    Spacer()
                    Text("Sign in with Telegram")
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 12)
            }
            .tint(TelegramDefaults.primaryColor)
            .buttonStyle(.glassProminent)

            Button {
                showDialog = true
            } label: {
                ZStack {
                    TelegramIcon()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.white)
                }
                .frame(width: 48, height: 48)
            }
            .buttonStyle(.glassProminent)
            .buttonBorderShape(.circle)
            .tint(TelegramDefaults.primaryColor)
            .telegramLoginDialog(isPresented: $showDialog, config: telegramConfig, onResult: onResult)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
