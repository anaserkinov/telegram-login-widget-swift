//
//  TelegramLoginBottomSheet.swift
//  TelegramLoginWidget
//
//  Created by Anas Erkinjonov on 03/03/26.
//

import SwiftUI
import TelegramLoginData

// MARK: - TelegramLoginBottomSheet

public struct TelegramLoginBottomSheet<Progress: View>: View {
    let config: TelegramLoginConfig
    let onResult: (TelegramLoginResult) -> Void
    @ViewBuilder var pageLoader: () -> Progress

    public init(
        config: TelegramLoginConfig,
        onResult: @escaping (TelegramLoginResult) -> Void,
        pageLoader: @escaping () -> Progress = {
            ProgressView()
                .progressViewStyle(.circular)
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.top, 32)
        }
    ) {
        self.config = config
        self.onResult = onResult
        self.pageLoader = pageLoader
    }

    public var body: some View {
        TelegramLoginView(
            config: config,
            onResult: onResult,
            pageLoader: pageLoader,
        )
        .padding(.top, 48)
        .background(.white)
        .presentationDetents([.fraction(0.75)])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - View modifier helper
// Mirrors the pattern: show the bottom sheet from a parent view

struct TelegramLoginBottomSheetModifier: ViewModifier {
    @Binding var isPresented: Bool
    let config: TelegramLoginConfig
    let onResult: (TelegramLoginResult) -> Void

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                TelegramLoginBottomSheet(config: config) { result in
                    isPresented = false
                    onResult(result)
                }
            }
    }
}

extension View {
    func telegramLoginBottomSheet(
        isPresented: Binding<Bool>,
        config: TelegramLoginConfig,
        onResult: @escaping (TelegramLoginResult) -> Void
    ) -> some View {
        modifier(
            TelegramLoginBottomSheetModifier(
                isPresented: isPresented,
                config: config,
                onResult: onResult
            )
        )
    }
}

// MARK: - Preview

#Preview {
    let config = TelegramLoginConfig(
        botId: 123_456_789,
        botUsername: "mybot",
        websiteUrl: "https://example.com",
        requestAccess: true,
        languageCode: "en"
    )
    Text("Tap to login")
        .sheet(isPresented: .constant(true)) {
            TelegramLoginBottomSheet(config: config) { result in
            }
            .presentationDragIndicator(.visible)
        }

}
