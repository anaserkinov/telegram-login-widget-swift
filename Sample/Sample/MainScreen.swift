//
//  MainScreen.swift
//  Sample
//
//  Created by Anas Erkinjonov on 04/03/26.
//

import SwiftUI
import TelegramLoginData

struct MainScreen: View {
    let user: User
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

            Text(user.fullName)
                .fontWeight(.bold)
                .font(.system(size: 24))

            if let username = user.username {
                Text(username)
                    .foregroundColor(.secondary)
            }

            if let phoneNumber = user.phoneNumber {
                Text(phoneNumber)
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

            if user.loggedInWithWidget {
                Button(action: onLogout) {
                    Text("Log out")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    MainScreen(
        user: User(
            photoUrl: nil,
            fullName: "John",
            username: "@johndoe",
            phoneNumber: "35463574656",
            loggedInWithWidget: true
        ),
        backToLoginScreen: {},
        onLogout: {}
    )
}
