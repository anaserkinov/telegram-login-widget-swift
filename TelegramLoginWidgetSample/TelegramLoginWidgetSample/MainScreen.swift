//
//  MainScreen.swift
//  Sample
//
//  Created by Anas Erkinjonov on 04/03/26.
//


import SwiftUI
import TelegramLoginData

struct MainScreen: View {
    let user: TelegramLoginResultSuccess
    let backToLoginScreen: () -> Void
    let onLogout: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 32)

            AsyncImage(url: user.photoUrl.flatMap { URL(string: $0) }) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Circle().fill(Color(.systemGray5))
            }
            .frame(width: 120, height: 120)
            .clipShape(Circle())

            Spacer().frame(height: 16)

            Text([user.firstName, user.lastName].compactMap { $0 }.joined(separator: " "))
                .fontWeight(.bold)
                .font(.system(size: 24))

            if let username = user.username {
                Text(username)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: backToLoginScreen) {
                Text("Back to Login screen")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)

            Spacer()
                .frame(height: 16)
            
            Button(action: onLogout) {
                Text("Log out")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    MainScreen(
        user: TelegramLoginResultSuccess(
            id: 123,
            firstName: "John",
            lastName: "Doe",
            username: "@johndoe",
            photoUrl: nil,
            authDate: 0,
            hash: ""
        ),
        backToLoginScreen: {},
        onLogout: {}
    )
}
