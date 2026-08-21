# iMama Backend (FastAPI + PostgreSQL)

## Setup

1. Install PostgreSQL and create a database:
   ```bash
   sudo -u postgres psql
   CREATE DATABASE imama_db;
   CREATE USER imama_user WITH PASSWORD 'changeme';
   GRANT ALL PRIVILEGES ON DATABASE imama_db TO imama_user;
   ```

2. Copy `.env.example` to `.env` and fill in real values:
   ```bash
   cp .env.example .env
   ```
   - `DATABASE_URL` — your Postgres connection string
   - `JWT_SECRET` — a long random string (e.g. `openssl rand -hex 32`)
   - `GEMINI_API_KEY` — from https://aistudio.google.com/apikey

3. Install dependencies:
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   pip install python-dotenv
   ```

4. Run it:
   ```bash
   uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
   ```

Tables are created automatically on first run (`Base.metadata.create_all`).

## Endpoints

- `POST /auth/register` — create account, returns `{token, user_id}`
- `POST /auth/login` — returns `{token, user_id}`
- `GET /profile` — requires `Authorization: Bearer <token>`
- `PUT /profile` — update profile
- `POST /chat` — `{"message": "..."}` -> `{"reply": "..."}`, calls Gemma via Google AI Studio
- `GET /blog` — returns cached blog posts (you'll need a separate process/cron to populate these — this scaffold just reads them)
- `GET /health` — liveness check

## Deploying

For "reliably live" per your earlier requirements, deploy this to Render/Railway/Fly.io rather than your own machine — they handle Postgres hosting too (or use their managed Postgres add-ons). Point your Flutter app's `env.json` `BACKEND_URL` at wherever this ends up.
