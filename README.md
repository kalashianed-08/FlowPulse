# FlowPulse

## Overview
FlowPulse is a **Flutter** based mobile application that demonstrates a modern architecture using **Riverpod** for state management, **Firebase** for backend services, and rich UI animations with **Lottie** and **video_player**. It serves as a starter template for building feature‑rich cross‑platform apps.

---

## Features
- **State Management** with `flutter_riverpod`
- **Firebase Integration** (Authentication, core services)
- **Google Sign‑In** and **Apple Sign‑In** support
- Beautiful UI powered by **Lottie** animations and **video_player**
- Custom fonts via `google_fonts`
- Responsive layout with `gap` and `flutter_svg`
- Theming and Material Design (`uses-material-design: true`)

---

## Tech Stack
| Layer | Technology |
|------|------------|
| UI | Flutter, Material Design, Lottie, video_player |
| State | Riverpod |
| Backend | Firebase Core, Firebase Auth |
| Auth Providers | Google Sign‑In, Apple Sign‑In |
| Fonts & Icons | google_fonts, cupertino_icons |
| Assets | Images, videos, animations |

---

## Getting Started
### Prerequisites
1. **Flutter SDK** (>= 3.12) – install from <https://flutter.dev/docs/get-started/install>
2. **Android Studio** or **VS Code** with Flutter plugins
3. An Android/iOS device or emulator
4. A Firebase project (optional – required for auth features)

### Clone the repository
```bash
git clone https://github.com/<your‑username>/flowpulse.git
cd flowpulse
```

### Install dependencies
```bash
flutter pub get
```

### Configure Firebase (optional)
- Follow the Firebase console setup for Android and iOS.
- Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) and place them in the respective platform folders.

### Run the app
```bash
flutter run
```
You can specify a device:
```bash
flutter run -d chrome   # web
flutter run -d emulator-5554   # Android emulator
```

---

## Building for Release
### Android
```bash
flutter build apk   # Generates an APK
flutter build appbundle   # Generates an AAB for Play Store
```
### iOS
```bash
flutter build ios   # Requires a macOS machine with Xcode
```

---

## Testing
The project includes a basic test scaffold.
```bash
flutter test
```
Add unit and widget tests under the `test/` directory.

---

## Linting & Code Quality
The repository uses the recommended Flutter lints.
```bash
flutter analyze   # Run static analysis
```
Fix issues with:
```bash
dart fix --apply
```

---

## Contributing
Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/awesome-feature`)
3. Commit your changes with clear messages
4. Open a Pull Request targeting `main`

---

## License
Distributed under the **MIT License**. See `LICENSE` file for details.

---

## Resources
- Flutter docs: <https://flutter.dev/docs>
- Riverpod: <https://riverpod.dev>
- Firebase for Flutter: <https://firebase.flutter.dev>
- Lottie animations: <https://airbnb.io/lottie>

---

*Happy coding!*
