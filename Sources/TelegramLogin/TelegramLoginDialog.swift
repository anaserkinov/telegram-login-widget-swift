//
//  TelegramLoginDialog.swift
//  TelegramLoginWidget
//
//  Created by Anas Erkinjonov on 26/03/26.
//

import SwiftUI

public struct TelegramLoginDialog<Progress: View>: View {
    let config: TelegramLoginConfig
    let onResult: (TelegramLoginResult) -> Void
    @ViewBuilder var pageLoader: () -> Progress

    @State var isPresented: Bool = false

    public init(
        config: TelegramLoginConfig,
        onResult: @escaping (TelegramLoginResult) -> Void,
        pageLoader: @escaping () -> Progress = {
            ProgressView()
                .progressViewStyle(.circular)
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.top, 16)
        }
    ) {
        self.config = config
        self.onResult = onResult
        self.pageLoader = pageLoader
    }

    func withoutAnimation(action: @escaping () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            action()
        }
    }

    public var body: some View {
        Color.clear
            .fullScreenCover(
                isPresented: $isPresented,
                onDismiss: {
                    onResult(TelegramLoginResult.cancelled)
                }
            ) {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()

                    GeometryReader { geo in
                        ZStack(alignment: .center) {
                            TelegramLoginView(
                                config: config,
                                onResult: { result in
                                    onResult(result)
                                    withoutAnimation {
                                        isPresented = false
                                    }
                                },
                                pageLoader: pageLoader
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .frame(
                                minHeight: geo.size.height * 0.6 > 620 ? 620 : min(geo.size.height - 48, 620),
                                maxHeight: geo.size.height * 0.6,
                            )
                            .frame(maxWidth: 530)
                            .padding(.horizontal, 24)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .onTapGesture {
                    withoutAnimation {
                        isPresented = false
                    }
                }
                .presentationBackground(.clear)
            }
            .onAppear {
                withoutAnimation {
                    isPresented = true
                }
            }
    }
}

extension View {
    public func telegramLoginDialog(
        isPresented: Binding<Bool>,
        config: TelegramLoginConfig,
        onResult: @escaping (TelegramLoginResult) -> Void
    ) -> some View {
        self.overlay {
            if isPresented.wrappedValue {
                TelegramLoginDialog(config: config) { result in
                    isPresented.wrappedValue = false
                    onResult(result)
                }
            }
        }
    }
}
