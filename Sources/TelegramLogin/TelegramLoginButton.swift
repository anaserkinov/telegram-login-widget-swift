//
//  TelegramLoginButton.swift
//  TelegramLoginWidget
//
//  Created by Anas Erkinjonov on 03/03/26.
//

import SwiftUI

// MARK: - TelegramDefaults

public enum TelegramDefaults {
    public static let primaryColor = Color(red: 84.0 / 255, green: 169.0 / 255, blue: 235.0 / 255)  // FF54A9EB
    public static let disabledPrimaryColor = Color(red: 171.0 / 255, green: 218.0 / 255, blue: 1)  // FFABDAFF
    public static let iconSize: CGFloat = 24
}

// MARK: - Sub-components

public struct TelegramButtonIcon: View {
    var size: CGFloat

    public init(
        size: CGFloat = TelegramDefaults.iconSize
    ) {
        self.size = size
    }

    public var body: some View {
        TelegramIcon()
            .frame(width: size, height: size)
    }
}

public struct TelegramButtonCircleIcon: View {
    var size: CGFloat

    public init(
        size: CGFloat = TelegramDefaults.iconSize
    ) {
        self.size = size
    }

    public var body: some View {
        TelegramIcon()
            .padding(.all, 6)
            .frame(width: size, height: size)
            .background(TelegramDefaults.primaryColor)
            .clipShape(Circle())
    }
}

// MARK: - TelegramLoginButton

/// Full-featured login button. Shows a bottom sheet when tapped.

public struct TelegramLoginButton<Content: View>: View {

    private var config: TelegramLoginConfig
    private let onResult: (TelegramLoginResult) -> Void
    private let content: () -> Content

    @State private var showDialog = false
    @State private var isUserDismiss = true

    public init(
        config: TelegramLoginConfig,
        onResult: @escaping (TelegramLoginResult) -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.config = config
        self.onResult = onResult
        self.content = content
    }

    public var body: some View {
        Button {
            showDialog = true
        } label: {
            content()
        }
        .telegramLoginDialog(isPresented: $showDialog, config: config, onResult: onResult)
    }
}
