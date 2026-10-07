# Principal Scheduler - Flutter

This is a ready-to-run Flutter project converted from a Kivy app. It includes:
- Staff and Principal dashboards
- Local JSON DB (assets/data.json), optional SQLite or Firestore services
- Push notifications (FCM) integration + Cloud Function to send notifications
- Dark/light theme support
- App icon SVG and placeholder assets

## Setup

1. Install Flutter SDK: https://flutter.dev/docs/get-started/install
2. Clone or extract this project.
3. Run:
   ```
   flutter pub get
   ```

## Firebase Setup (Android & iOS)

1. Create a Firebase project.
2. Add Android app with package name (e.g., com.example.principal_scheduler). Download `google-services.json` and copy to `android/app/`.
3. Add iOS app, download `GoogleService-Info.plist` and copy to `ios/Runner/`.
4. Enable Cloud Firestore and Cloud Messaging.
5. (Optional) Run `flutterfire configure` to generate `firebase_options.dart`.

## Cloud Functions

Functions are in `functions/`. To deploy:
```
cd functions
npm install
firebase deploy --only functions
```

## Build APK (Android)
```
flutter build apk --release
```

## Build iOS (macOS + Xcode)
```
flutter build ios --release
open ios/Runner.xcworkspace
# Archive in Xcode and submit to App Store
```

## Notes
- Update `lib/main.dart` to use Firestore/SQLite service if desired.
- Place your real `assets/college_logo.jpeg` and app icon PNGs in `assets/` before building.


## Final notes - ready to finish
This repository is packaged to run out-of-the-box using the local JSON database (no Firebase required).
To enable full cloud features (Firestore, FCM):
1. Install Firebase CLI and the FlutterFire CLI: `dart pub global activate flutterfire_cli`
2. Run `flutterfire configure` in the project root to generate `lib/firebase_options.dart` with your Firebase project credentials.
3. Set `USE_FIRESTORE = true;` in `lib/main.dart` to switch to Firestore services (after ensuring Firestore methods are implemented).
4. Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) as described in the README.
5. Deploy Cloud Functions in `functions/` with `firebase deploy --only functions`.

This package includes:
- Cloud Function (functions/index.js) to send FCM notifications when appointments update.
- Placeholder app icon SVG and small placeholder logo.
- Full working UI backed by local JSON data (`assets/data.json`).

If you want, I can now produce a build (APK) from this environment and provide it for download, or generate PNG icons for various densities and include them in the ZIP.
