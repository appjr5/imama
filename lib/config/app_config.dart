/// Build-time configuration. The backend URL is compiled into the app at
/// build/run time via --dart-define — the end user never sees a settings
/// screen, a key field, or a link. They just open the app and chat.
///
/// Run with:
///   flutter run --dart-define-from-file=env.json
/// Build with:
///   flutter build apk --release --dart-define-from-file=env.json
///
/// env.json (create this yourself, keep it OUT of git):
///   { "BACKEND_URL": "https://your-imama-backend-url" }
class AppConfig {
  static const String backendUrl =
      String.fromEnvironment('BACKEND_URL', defaultValue: '');
}
