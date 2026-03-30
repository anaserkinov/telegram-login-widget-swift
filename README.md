# Telegram Login Widget

A SwiftUI library that brings Telegram authentication to iOS. It supports two official Telegram login methods — pick the one that fits your use case.

---

## Login Methods

| Method | Product |
|--------|---------|
| [Telegram Login / OpenID Connect](#telegram-login--openid-connect) | `TelegramLogin` |
| [Telegram Login Widget (Legacy)](#telegram-login-widget-legacy) | `TelegramLoginWidget` |

---

## Platforms

| Platform | Minimum |
|----------|---------|
| iOS      | 17.0    |

Looking for the Android / Kotlin Multiplatform version? Check out the [Compose Multiplatform library](https://github.com/anaserkinov/telegram-login-widget).

---

## Installation

In Xcode, go to **File → Add Package Dependencies** and enter the repository URL:

```
https://github.com/anaserkinov/telegram-login-widget-swift
```

Or add it directly to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/anaserkinov/telegram-login-widget-swift", from: "<latest_version>")
]
```

Then add the specific product(s) you need to your target:

```swift
.product(name: "TelegramLogin", package: "telegram-login-widget-swift"),
// and/or
.product(name: "TelegramLoginWidget", package: "telegram-login-widget-swift"),
```

---

## Telegram Login / OpenID Connect

The modern Telegram login flow ([Login via Telegram](https://core.telegram.org/bots/telegram-login)). It presents a Telegram-hosted dialog where the user confirms login with a single tap, then hands back an ID token and profile data to your app.

<p align="center">
  <img src="/assets/images/sample.gif" alt="Telegram Login demo" width="512"/>
</p>

### Setup

Follow Telegram's official guide to set up your bot and obtain a `client_id`: [Setting up a bot](https://core.telegram.org/bots/telegram-login#setting-up-a-bot).

### Usage

#### Basic Button

```swift
import TelegramLogin

struct LoginScreen: View {
    let config = TelegramLoginConfig(
        clientId: 123456789,
        redirectURI: "https://yourapp.com/callback"
    )

    var body: some View {
        TelegramLoginButton(config: config, onResult: { result in
            // handle result
        }) {
            HStack {
                TelegramButtonIcon()
                Text("Sign in with Telegram")
            }
            .frame(maxWidth: .infinity)
        }
        .tint(TelegramDefaults.primaryColor)
        .buttonStyle(.glassProminent)
    }
}
```

Tapping the button presents a `TelegramLoginDialog` with the Telegram OAuth WebView. Once the user authenticates, `onResult` is called with either `.success` or `.cancelled`.

---

#### Handling the Result

```swift
TelegramLoginButton(config: config, onResult: { result in
    switch result {
    case .success(let data):
        print("Logged in as \(data.user.name), id: \(data.user.id)")
        // data.idToken          — raw JWT for server-side validation
        // data.user.id, data.user.name, data.user.preferredUsername,
        // data.user.picture, data.user.phoneNumber, data.user.nonce,
        // data.user.iss, data.user.aud, data.user.iat, data.user.exp
    case .cancelled:
        print("Login cancelled")
    }
}) {
    // button content
}
```

---

#### Using TelegramLoginDialog Directly

You can trigger the login flow from any custom UI element using the `.telegramLoginDialog` modifier:

```swift
@State private var showDialog = false

Button {
    showDialog = true
} label: {
    TelegramButtonIcon()
        .frame(width: 48, height: 48)
}
.buttonStyle(.glassProminent)
.buttonBorderShape(.circle)
.tint(TelegramDefaults.primaryColor)
.telegramLoginDialog(isPresented: $showDialog, config: config) { result in
    showDialog = false
    // handle result
}
```

Or use `TelegramLoginDialog` as a view directly:

```swift
if showDialog {
    TelegramLoginDialog(config: config) { result in
        showDialog = false
        // handle result
    }
}
```

---

#### Embedding the WebView Directly

If you need the OAuth WebView without any button or dialog wrapper, use `TelegramLoginView`:

```swift
TelegramLoginView(
    config: TelegramLoginConfig(
        clientId: 123456789,
        redirectURI: "https://yourapp.com/callback"
    ),
    onResult: { result in
        // handle result
    }
)
```

---

### API Reference

#### `TelegramLoginConfig`

```swift
public struct TelegramLoginConfig {
    public init(
        clientId: Int64,
        redirectURI: String,
        requestDirectMessages: Bool = true,    // request permission to send direct messages to the user (bot_access scope)scope
        requestPhoneNumber: Bool = false,      // request access to the user's phone number (phone scope)
        nonce: String? = nil,                  // optional nonce to protect against ID token replay attacks
        languageCode: String? = nil
    )
}
```

#### `TelegramLoginResult`

```swift
public enum TelegramLoginResult {
    case success(Success)
    case cancelled

    public struct Success {
        public let idToken: String          // raw JWT — validate on your server
        public let user: TelegramUserData
    }
}

public struct TelegramUserData {
    public let id: Int64
    public let name: String
    public let preferredUsername: String?
    public let picture: String?
    public let phoneNumber: String?
    public let nonce: String?
    // JWT standard claims
    public let iss: String
    public let aud: String
    public let sub: String
    public let iat: Int64
    public let exp: Int64
}
```

---

## Telegram Login Widget (Legacy)

The classic [Telegram Login Widget](https://core.telegram.org/widgets/login) flow. It provides ready-to-use, fully customizable login buttons backed by Telegram's official OAuth flow. Requires a bot and a registered website domain.

<img src="/assets/images/buttons_light.webp" alt="Buttons light" />

### About TelegramLoginData

This module depends on `TelegramLoginData`, an XCFramework bundled automatically via SPM. It is generated from the Kotlin shared module in the [Compose Multiplatform library](https://github.com/anaserkinov/telegram-login-widget) and contains the networking, caching, and login logic shared between iOS and Android.

### Setup

#### 1. Create a Telegram Bot

If you don't have a bot yet, create one via [@BotFather](https://t.me/BotFather) and note the **bot ID** and **bot username**.

To find your bot ID, open the following URL in any browser (replace `YOUR_BOT_TOKEN` with your actual token):

```
https://api.telegram.org/botYOUR_BOT_TOKEN/getMe
```

#### 2. Configure the Login Widget in BotFather

Send `/setdomain` to BotFather, select your bot, and enter the domain of the website you'll be authorizing against (e.g. `yourdomain.com`). This is required by Telegram's login widget.

---

### Usage

#### Basic Button

```swift
import TelegramLoginWidget

struct LoginScreen: View {
    @State var state = TelegramLoginState(
        botId: 123456789,
        botUsername: "your_bot",
        websiteUrl: "https://yourdomain.com"
    )

    var body: some View {
        TelegramLoginButton(state: state) { result in
            // handle result
        }
        .tint(TelegramDefaults.primaryColor)
        .buttonStyle(.glassProminent)
    }
}
```

Tapping the button presents a sheet with Telegram's OAuth WebView. Once the user authenticates, the closure is called with either a `.success` or `.cancelled` result.

---

#### Handling the Result

```swift
import TelegramLoginData

TelegramLoginButton(state: state) { result in
    switch result {
    case let .success(data):
        print("Logged in as \(data.firstName), id: \(data.id)")
        // data.id, data.firstName, data.lastName,
        // data.username, data.photoUrl, data.authDate, data.hash
    case .cancelled:
        print("Login cancelled")
    }
}
```

---

#### Customizing the Button

`TelegramLoginButton` accepts a fully custom `content` closure, so you can compose any layout using the provided sub-components or your own views.

<img src="/assets/images/buttons_dark.webp" alt="Buttons dark" />

```swift
// Light-themed button with Telegram-colored icon
TelegramLoginButton(state: state, onResult: onResult) { state in
    HStack {
        TelegramButtonIcon()
            .foregroundStyle(TelegramDefaults.primaryColor)
        TelegramButtonText(state: state)
            .foregroundStyle(.black)
        TelegramButtontUserPhotoBox(state: state, progress: {
            TelegramButtonCircularProgress(tint: .black)
        })
    }
    .frame(maxWidth: .infinity)
    .padding(.horizontal, 12)
}
.tint(.white)
.buttonStyle(.glassProminent)
```

```swift
// Centered label with user photo balanced symmetrically
TelegramLoginButton(state: state, onResult: onResult) { state in
    HStack {
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
```

You can also trigger the login flow from any custom UI element using `TelegramLoginBottomSheet` directly:

```swift
@State private var showSheet = false

Button {
    showSheet = true
} label: {
    TelegramButtonIcon()
        .frame(width: 24, height: 24)
}
.sheet(isPresented: $showSheet) {
    TelegramLoginBottomSheet(config: state.config) { result in
        showSheet = false
        state.reload()
        onResult(result)
    }
}
```

If you need to embed the Telegram OAuth WebView directly into your own layout without any button or bottom sheet, use `TelegramLoginView`:

```swift
import TelegramLoginWidget
import TelegramLoginData

TelegramLoginView(
    config: TelegramLoginConfig(
        botId: 123456789,
        botUsername: "your_bot",
        websiteUrl: "https://yourdomain.com"
    ),
    onResult: onResult
)
```

---

#### Logout

```swift
// If you have a state object
state.logout()

// If you don't have a state object
try await TelegramLoginManager.shared.logout()
```

This clears all Telegram cookies and resets the button to its pre-login appearance.

---

### API Reference

#### `TelegramLoginState`

```swift
@State var state = TelegramLoginState(
    botId: Int64,
    botUsername: String,
    websiteUrl: String,
    requestAccess: Bool = true,   // request permission to send messages
    languageCode: String = "en"
)
```

| Member | Type | Description |
|--------|------|-------------|
| `config` | `TelegramLoginConfig` | The configuration used to initialize the widget |
| `isLoading` | `Bool` | `true` while button content or user photo is being fetched |
| `buttonContent` | `ButtonContent` | Current text, first name, and avatar image |
| `reload()` | `func` | Re-fetches button state (call after a login result) |
| `logout()` | `func` | Clears session and resets button |

#### `TelegramLoginResult` (Widget)

| Property | Type | Description |
|----------|------|-------------|
| `id` | `Int64` | Telegram user ID |
| `firstName` | `String` | User's first name |
| `lastName` | `String?` | User's last name |
| `username` | `String?` | Telegram username |
| `photoUrl` | `String?` | Profile photo URL |
| `authDate` | `Int64` | Unix timestamp of authentication |
| `hash` | `String` | Telegram auth hash for server-side verification |

---

## Sample

The repository includes a sample Xcode project under the `Sample/` directory demonstrating both login methods with multiple button styles.

---

## Requirements

| Tool | Minimum Version |
|------|----------------|
| iOS  | 17.0 |
| Swift | 6.2 |
| Xcode | 26 |

---

## License

```
MIT License

Copyright (c) 2026 Anas (anaserkinjonov@gmail.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```