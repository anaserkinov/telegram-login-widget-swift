//
//  TelegramDefaults.swift
//  TelegramLoginWidget
//
//  Created by Anas Erkinjonov on 03/03/26.
//

import SwiftUI
import TelegramLoginData

// MARK: - TelegramDefaults

public enum TelegramDefaults {
    public static let primaryColor = Color(red: 84.0 / 255, green: 169.0 / 255, blue: 235.0 / 255)  // FF54A9EB
    public static let disabledPrimaryColor = Color(red: 171.0 / 255, green: 218.0 / 255, blue: 1)  // FFABDAFF
    public static let iconSize: CGFloat = 24
    public static let iconEndPadding: CGFloat = 12
    public static let userPhotoSize: CGFloat = 24
}

// MARK: - Sub-components

public struct TelegramButtonIcon: View {
    var size: CGFloat
    var padding: EdgeInsets

    public init(
        size: CGFloat = TelegramDefaults.iconSize,
        padding: EdgeInsets = EdgeInsets(
            top: 0,
            leading: 0,
            bottom: 0,
            trailing: TelegramDefaults.iconEndPadding
        )
    ) {
        self.size = size
        self.padding = padding
    }

    public var body: some View {
        TelegramIcon()
            .frame(width: size, height: size)
            .padding(padding)
    }
}

public struct TelegramButtonCircleIcon: View {
    var size: CGFloat
    var padding: EdgeInsets

    public init(
        size: CGFloat = TelegramDefaults.iconSize,
        padding: EdgeInsets = EdgeInsets(
            top: 0,
            leading: 0,
            bottom: 0,
            trailing: TelegramDefaults.iconEndPadding
        )
    ) {
        self.size = size
        self.padding = padding
    }

    public var body: some View {
        TelegramIcon()
            .padding(.all, 6)
            .frame(width: size, height: size)
            .background(TelegramDefaults.primaryColor)
            .clipShape(Circle())
            .padding(padding)
    }
}

/// Button label text derived from widget details
public struct TelegramButtonText: View {
    var state: TelegramLoginState
    var text: String?

    public init(
        state: TelegramLoginState,
        text: String? = nil,
    ) {
        self.state = state
        self.text = text
    }

    public var body: some View {
        Text(text ?? state.buttonContent.text)
    }
}

/// Small circular indeterminate progress indicator
public struct TelegramButtonCircularProgress: View {
    var size: CGFloat
    var color: Color

    public init(
        size: CGFloat = TelegramDefaults.userPhotoSize,
        color: Color = Color.white
    ) {
        self.size = size
        self.color = color
    }

    public var body: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .tint(color)
            .frame(width: size, height: size)
    }
}

/// Async user photo with circular clip and border
public struct TelegramButtonUserPhoto: View {
    var state: TelegramLoginState
    var size: CGFloat
    var borderColor: Color
    var borderWidth: CGFloat

    public init(
        state: TelegramLoginState,
        size: CGFloat = TelegramDefaults.userPhotoSize,
        borderColor: Color = .white,
        borderWidth: CGFloat = 1
    ) {
        self.state = state
        self.size = size
        self.borderColor = borderColor
        self.borderWidth = borderWidth
    }

    public var body: some View {
        if let photo = state.buttonContent.userPhoto {
            Image(uiImage: photo)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(borderColor, lineWidth: borderWidth)
                )
        }
    }
}

/// Box that shows progress while loading, then the user photo
public struct TelegramButtontUserPhotoBox<Progress: View, Photo: View>: View {
    var state: TelegramLoginState
    var padding: EdgeInsets
    var contentColor: Color
    var preservesSpace: Bool
    @ViewBuilder var progress: (Color) -> Progress
    @ViewBuilder var userPhoto: (TelegramLoginState) -> Photo

    public init(
        state: TelegramLoginState,
        padding: EdgeInsets = EdgeInsets(
            top: 0,
            leading: 8,
            bottom: 0,
            trailing: 0
        ),
        contentColor: Color = .white,
        preservesSpace: Bool = true,
        progress: @escaping (Color) -> Progress = { contentColor in
            TelegramButtonCircularProgress(color: contentColor)
        },
        userPhoto: @escaping (TelegramLoginState) -> Photo = { state in
            TelegramButtonUserPhoto(state: state)
        }
    ) {
        self.state = state
        self.padding = padding
        self.contentColor = contentColor
        self.preservesSpace = preservesSpace
        self.progress = progress
        self.userPhoto = userPhoto
    }

    public var body: some View {
        Group {
            if state.isLoading {
                progress(contentColor)
                    .transition(.scale.combined(with: .opacity))
            }

            if !state.isLoading {
                userPhoto(state)

                if preservesSpace && state.buttonContent.userPhoto == nil {
                    Spacer()
                        .frame(width: TelegramDefaults.userPhotoSize)
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: state.isLoading)
        .padding(padding)
    }
}

// MARK: - TelegramLoginButton

/// Full-featured login button. Shows a bottom sheet when tapped.

public struct TelegramLoginButton<Content: View>: View {

    private var state: TelegramLoginState
    private let onResult: (TelegramLoginResult) -> Void
    private let contentColor: Color
    private let content: (TelegramLoginState, _ contentColor: Color) -> Content

    @State private var showBottomSheet = false
    @State private var isUserDismiss = true

    public init(
        state: TelegramLoginState,
        onResult: @escaping (TelegramLoginResult) -> Void,
        contentColor: Color = .white,
        @ViewBuilder content:
            @escaping (TelegramLoginState, _ contentColor: Color) -> Content = {
                state,
                contentColor in
                HStack(spacing: 0) {
                    TelegramButtonIcon()
                    TelegramButtonText(state: state)
                    TelegramButtontUserPhotoBox(
                        state: state,
                        contentColor: contentColor
                    )
                }
                .frame(maxWidth: .infinity)
            }
    ) {
        self.state = state
        self.onResult = onResult
        self.contentColor = contentColor
        self.content = content
    }

    public var body: some View {
        Button {
            showBottomSheet = true
        } label: {
            content(state, contentColor)
        }
        .foregroundStyle(contentColor)
        .onChange(
            of: showBottomSheet, initial: false,
            { oldValue, newValue in
                if newValue {
                    isUserDismiss = true
                } else if isUserDismiss {
                    onResult(TelegramLoginResultCancelled())
                }
            }
        )
        .sheet(isPresented: $showBottomSheet) {
            TelegramLoginBottomSheet(config: state.config) { result in
                isUserDismiss = false
                showBottomSheet = false
                state.reload()
                onResult(result)
            }
        }
    }
}
