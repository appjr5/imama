# iMama — Fresh Rebuild (Online, FastAPI + PostgreSQL)

Full rebuild: real login/register, online-only (no on-device model, no
RAG complexity), Postgres-backed via a FastAPI backend, your two provided
images as app logo and chatbot avatar, Maktaba as cards under Vidokezo
vya Leo, logout in the drawer, dark mode preserved, 3-second launcher.

## Project layout

```
lib/            Flutter app source
assets/images/  app_logo.webp, chatbot_avatar.jpg (your uploaded images)
backend/        FastAPI + PostgreSQL API — deploy this separately
```

## Running the Flutter app

1. `flutter pub get`
2. Create `env.json` in the project root:
   ```json
   { "BACKEND_URL": "https://your-backend-url" }
   ```
   Point this at wherever you deploy the `backend/` folder (see its own
   README). For local testing on the same machine as the backend, use
   your PC's LAN IP (e.g. `http://192.168.1.42:8000`) — same approach as
   earlier in our setup, since the app is online-only and always needs
   to reach this URL.
3. `flutter run --dart-define-from-file=env.json`
4. Build release APK: `flutter build apk --release --dart-define-from-file=env.json`

## What changed from the previous (on-device) version

- Removed: flutter_gemma, on-device model, RAG/OCR/PDF packages, the
  huge bundled model file, all the compileSdk/storage fights that came
  with it.
- Added: real accounts (register/login/logout) backed by PostgreSQL,
  server-side chat via Google AI Studio's Gemma API (swap this for your
  own hosted model in `backend/app/main.py` if you have one already).
- Maktaba is now inline on the home screen as tappable cards, directly
  under "Vidokezo vya Leo," instead of only living in the drawer.
- Splash screen holds for exactly 3 seconds before routing to
  login/home based on whether a saved session exists.

## Known gaps, stated plainly

- `GET /blog` in the backend reads from a `blog_posts` table but nothing
  writes to it yet — you'll want a small script or cron job that
  generates/inserts a new row daily (similar logic to the on-device
  version's daily-tip generation, just running server-side now).
- Maktaba content in `library_screen.dart` is static starter text — flag
  raised earlier still applies: have someone with medical knowledge
  review it before real users see it, since it covers pregnancy safety
  and family planning.
- CORS is wide open (`allow_origins=["*"]`) in the backend for ease of
  testing — tighten this before any real deployment.
