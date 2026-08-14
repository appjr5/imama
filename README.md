# iMama — Flutter Rebuild

A Flutter port of the original iMama Android (Java) app: Swahili-language
maternal health assistant, purple-gradient theme, talking to your existing
FastAPI backend (Gemma multimodal model) over a Cloudflare Tunnel.

This project is set up to be built and run **entirely from VS Code**, with
no Android Studio installation required. You still need the Android
**command-line tools / SDK** (Android Studio bundles these, but you can
install just the SDK components without the IDE).

## What's included

```
lib/
  main.dart                 # App entry point
  theme/
    app_theme.dart           # Purple gradient theme (matches original UI)
    strings_sw.dart           # All Swahili UI strings, centralized
  models/
    chat_message.dart
    user_profile.dart
  services/
    api_service.dart          # Replaces Retrofit — talks to your FastAPI backend
    settings_service.dart     # Persists backend URL + profile locally
  screens/
    splash_screen.dart
    home_screen.dart
    chat_screen.dart          # Text + image chat with the Gemma backend
    appointments_screen.dart  # Stub — wire to your /appointments endpoint
    tips_screen.dart          # Stub — static tips for now
    profile_screen.dart
    settings_screen.dart      # Configure/test the Cloudflare Tunnel URL
pubspec.yaml
```

## One-time setup (Windows/Linux, matches your existing dev environment)

1. **Install Flutter SDK**
   - Download from https://docs.flutter.dev/get-started/install
   - Add `flutter/bin` to your PATH.
   - Run `flutter doctor` in a terminal — follow any remaining instructions.

2. **Install just the Android SDK command-line tools** (no Android Studio):
   - `flutter doctor --android-licenses` will prompt you to accept licenses
     once the SDK is present.
   - Easiest path: install the tools via `sdkmanager` (comes with the
     "command line tools only" download from
     https://developer.android.com/studio#command-tools), or point
     Flutter at an existing SDK with:
     `flutter config --android-sdk /path/to/Android/sdk`

3. **VS Code setup**
   - Install the **Flutter** extension (this pulls in the Dart extension
     automatically).
   - Open this project folder in VS Code.
   - Run `flutter pub get` in the integrated terminal (or VS Code will
     prompt you to do this automatically when it detects `pubspec.yaml`).

4. **Connect a device or start an emulator**
   - Physical device: enable USB debugging (same as before), plug in,
     confirm with `flutter devices`.
   - Emulator: `flutter emulators --launch <emulator_id>` (list them with
     `flutter emulators`), or use VS Code's device picker in the bottom
     status bar.

## Running in debug mode (VS Code)

- Open `lib/main.dart`, press **F5** (or use the Run and Debug panel).
- VS Code will build and launch the app on the selected device/emulator,
  with hot reload (`r`) and hot restart (`R`) in the terminal.

## Building the release APK

From the VS Code integrated terminal, in the project root:

```bash
flutter pub get
flutter build apk --release
```

The signed/unsigned APK will be at:

```
build/app/outputs/flutter-apk/app-release.apk
```

Copy that file to your device, or install directly with:

```bash
flutter install
```

For a smaller, per-architecture build (recommended for distribution):

```bash
flutter build apk --split-per-abi
```

## Connecting to your FastAPI/Gemma backend (no user-facing setup)

The app calls your own FastAPI backend directly — there's no settings
screen, no link, no key entry for the end user. Instead, **you** bake the
backend URL in at build/run time, so it's compiled into the app before it
ever reaches a user.

1. Make sure your FastAPI backend is reachable at a stable URL (e.g. a
   Cloudflare Tunnel address, or wherever you've deployed it) and exposes:
   - `POST /chat` — accepts `{"message": "..."}` as JSON, or
     `multipart/form-data` with fields `message` and `image` when an image
     is attached. Returns `{"reply": "..."}` (or `{"response": "..."}`).
   - `GET /health` — used for connectivity checks.

   If your actual routes use different field/response names, adjust
   `lib/services/api_service.dart` to match.

2. In the project root, create a file named `env.json` (already listed in
   `.gitignore` — never commit this):
   ```json
   {
     "BACKEND_URL": "https://your-imama-backend-url"
   }
   ```
3. Run or build with `--dart-define-from-file`:
   ```bash
   flutter run --dart-define-from-file=env.json
   flutter build apk --release --dart-define-from-file=env.json
   ```

**VS Code tip:** so you don't have to remember that flag every time you
press F5, add a `.vscode/launch.json` with:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "iMama (with backend URL)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": ["--dart-define-from-file=env.json"]
    }
  ]
}
```
Then F5 will always include it automatically.

## Notes on parity with the original Android app

This rebuild reproduces, at a structural level: the Swahili UI, the purple
gradient branding, a chat screen that sends text/image to your Gemma
backend, and local storage of a user profile. It does **not** yet include
any screen-specific business logic that only existed in your original Java
code (exact validation rules, specific API field names, DPPS-related native
integrations, etc.) since I was rebuilding from a conversation summary, not
the original files. If you still have the Java project, share the relevant
files (Activities, Retrofit interfaces, XML layouts) and I'll port the
exact logic over rather than the reconstructed version here.
