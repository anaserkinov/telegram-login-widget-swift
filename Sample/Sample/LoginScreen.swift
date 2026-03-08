//
//  ContentView.swift
//  Sample
//
//  Created by Anas Erkinjonov on 02/03/26.
//

import SwiftUI
import TelegramLoginData
import TelegramLoginWidget

#Preview {
    LoginScreen { _ in

    }
}

struct LoginScreen: View {

    @State
    var buttonState = TelegramLoginState(
        botId: 8_320_475_019,
        botUsername: "login_widget_telegram_bot",
        websiteUrl: "https://anasmusa.me"
    )

    @State private var showBottomSheet = false

    var onResult: (TelegramLoginResult) -> Void

    var body: some View {
        VStack {
            TelegramLoginButton(state: buttonState, onResult: onResult)
                .tint(TelegramDefaults.primaryColor)
                .buttonStyle(.glassProminent)

            TelegramLoginButton(
                state: buttonState,
                onResult: onResult,
                contentColor: TelegramDefaults.primaryColor
            )
            .tint(.white)
            .buttonStyle(.glassProminent)

            TelegramLoginButton(state: buttonState, onResult: onResult) { state, _ in
                HStack {
                    TelegramButtonIcon()
                    Spacer()
                    TelegramButtonText(state: state)
                    Spacer()
                    TelegramButtontUserPhotoBox(state: state)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 12)
            }
            .tint(TelegramDefaults.primaryColor)
            .buttonStyle(.glassProminent)

            TelegramLoginButton(state: buttonState, onResult: onResult) { state, _ in
                HStack(spacing: 0) {
                    TelegramButtonIcon()
                    Spacer()
                    TelegramButtonText(state: state)
                    TelegramButtontUserPhotoBox(state: state, preservesSpace: false)
                    Spacer()
                        .frame(width: TelegramDefaults.userPhotoSize)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 12)
            }
            .tint(TelegramDefaults.primaryColor)
            .buttonStyle(.glassProminent)

            Button {
                showBottomSheet = true
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
        }
        .sheet(isPresented: $showBottomSheet) {
            TelegramLoginBottomSheet(config: buttonState.config) { result in
                showBottomSheet = false
                buttonState.reload()
                onResult(result)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
