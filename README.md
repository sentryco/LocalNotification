[![Tests](https://github.com/sentryco/LocalNotification/actions/workflows/tests.yml/badge.svg)](https://github.com/sentryco/LocalNotification/actions/workflows/tests.yml) [![codebeat badge](https://codebeat.co/badges/a0d953b9-586d-4f10-905f-b2992a9f4076)](https://codebeat.co/projects/github-com-sentryco-localnotification-main)

# ⚙️ LocalNotification
- LocalNotification is a Swift package that helps you manage local notifications in your iOS application. 
- Intended to be used as a debug tool for background operations where consol output doesnt work

> [!NOTE]  
> Can be used in production, but that isn't very usefull since most people will not allow app level notifications by default, to avoid notification spam etc

## Features

- Check and request local notification permisions
- Direct call to show title and message
- Constructor call to show title and message

## Usage

Here's an example of how to use the LocalNotification package:

```swift
import LocalNotification

// Do this once at app first time start, can't be requested again
if !LocalNotification.isNotificationAvailable {
    LocalNotification.requestPermission()
}
// Check if available
guard LocalNotification.isNotificationAvailable else { print("Err, notification not allowed"); return }
// Direct call
LocalNotification.showNotification(title: "Feed the cat", body: "It looks hungry")
// Create a new notification
let notification = LocalNotification(title: "My Notification", body: "This is a notification")
notification.schedule()

// Cancel a notification
notification.cancel()
```

## Installation

To install the LocalNotification package, add the following to your Package.swift file.

```swift
dependencies: [
    .package(url: "https://github.com/sentryco/LocalNotification.git", branch: "main")
]
```

## License

[MIT](https://opensource.org/licenses/MIT)


## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

 
