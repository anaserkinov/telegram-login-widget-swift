# Telegram Login Widget

A SwiftUI library that brings [Telegram Login Widget](https://core.telegram.org/widgets/login) to iOS. It provides ready-to-use, fully customizable login buttons backed by Telegram's official OAuth flow.

<img src="/assets/images/buttons_light.webp"  alt="Buttons"/>

## Platforms

| Platform | Minimum |
|----------|---------|
| iOS      | 17.0    |

Looking for the Android / Kotlin Multiplatform version? Check out the [Compose Multiplatform library](https://github.com/anaserkinov/telegram-login-widget).

---

## Installation

### Swift Package Manager

In Xcode, go to **File → Add Package Dependencies** and enter the repository URL:

```
https://github.com/anaserkinov/telegram-login-widget-swift
```

Or add it directly to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/anaserkinov/telegram-login-widget-swift", from: "latest_version")
]
```

### About TelegramLoginData

This package depends on `TelegramLoginData`, an XCFramework bundled automatically via SPM. It is generated from the Kotlin shared module in the [Compose Multiplatform library](https://github.com/anaserkinov/telegram-login-widget) and contains the networking, caching, and login logic shared between iOS and Android.

---

## Setup

### 1. Create a Telegram Bot

If you don't have a bot yet, create one via [@BotFather](https://t.me/BotFather) and note the **bot ID** and **bot username**.

To find your bot ID, open the following URL in any browser (replace `YOUR_BOT_TOKEN` with your actual token):

```
https://api.telegram.org/botYOUR_BOT_TOKEN/getMe
```

### 2. Configure the Login Widget in BotFather

Send `/setdomain` to BotFather, select your bot, and enter the domain of the website you'll be authorizing against (e.g. `yourdomain.com`). This is required by Telegram's login widget.

---

## Usage

### Basic Button

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

Tapping the button presents a sheet with Telegram's OAuth WebView. Once the user authenticates, the closure is called with either a `TelegramLoginResultSuccess` or `TelegramLoginResultCancelled`.

---

### Handling the Result

```swift
import TelegramLoginData

TelegramLoginButton(state: state) { result in
    switch result {
    case let success as TelegramLoginResultSuccess:
        print("Logged in as \(success.firstName), id: \(success.id)")
        // success.id, success.firstName, success.lastName,
        // success.username, success.photoUrl, success.authDate, success.hash
    case is TelegramLoginResultCancelled:
        print("Login cancelled")
    default:
        break
    }
}
```

---

### Customizing Button

`TelegramLoginButton` accepts a fully custom `content` closure, so you can compose any layout using the provided sub-components or your own views.

<img src="/assets/images/buttons_dark.webp"  alt="Buttons"/>

```swift
// Light-themed button with Telegram-colored icon
TelegramLoginButton(
    state: buttonState,
    onResult: onResult
){ state in
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
    TelegramIcon()
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

### Logout

```swift
import TelegramLoginData

// If you have a state object
state.logout()

// If you don't have a state object
try await TelegramLoginManager.shared.logout()
```

This clears all Telegram cookies and resets the button to its pre-login appearance.

---

## API Reference

### `TelegramLoginState`

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
| `buttonContent` | `ButtonContent` | Current text (may be empty before first successful load), first name, and avatar image |
| `reload()` | `func` | Re-fetches button state |
| `logout()` | `func` | Clears session and resets button |

### `TelegramLoginResultSuccess`

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

The repository includes a sample Xcode project under the `Sample/` directory demonstrating multiple button styles and the standalone bottom sheet.

---

## Requirements

| Tool | Minimum Version |
|------|----------------|
| iOS  | 17.0 |
| Swift | 5.9 |
| Xcode | 15 |

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
