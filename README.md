# SayAgain — English Speaking Flashcard Practice (MVP)

A lightweight, mobile-first Progressive Web App (PWA) for daily English speaking practice linked to **English Speaking Challenge** episodes. Viewers open an import link (`/import/{id}`), sign in with Google, preview and import the episode’s speaking cards idempotently, and review due cards daily using client-side **FSRS** (`ts-fsrs`) persisted to **Supabase Postgres** under Row Level Security (RLS). The id is not a sequential name, and the app does not list every published deck.

> **Integration boundary:** SayAgain is the deployed app. `english-one-minute` stays on your machine and posts a finished episode to `POST /api/publish/episode` on that deployment. Learners open `/import/{id}`. The id is not a sequential name.

---

## Core Architecture

- **Framework:** Next.js 16 (App Router) + React 19 + TypeScript + Tailwind CSS v4
- **Auth & Database:** Supabase Auth (Google OAuth PKCE via `@supabase/ssr`) + Postgres 17 + strict RLS on all tables
- **Spaced Repetition:** Client-side `ts-fsrs` (`DefaultScheduler` FSRS-6) + atomic Postgres RPCs (`import_episode_deck`, `submit_card_review`) with idempotent `event_id` deduplication, optimistic locking (`version`), and server-authoritative review timestamps
- **PWA:** Next.js Web App Manifest (`/manifest.webmanifest`), slim top-of-page platform-aware install banner, and a strictly scoped Service Worker (`/sw.js`) that caches public static assets/offline shell only and **never** caches authenticated HTML, RSC payloads, or Supabase responses

---

## Quick Start (Local Development)

### 1. Install dependencies

```bash
pnpm install
```

### 2. Configure environment variables

Copy `.env.example` to `.env.local` and fill in your Supabase project URL and publishable key:

```bash
cp .env.example .env.local
```

| Variable | Required | Where used | Description |
|---|---|---|---|
| `NEXT_PUBLIC_SUPABASE_URL` | Yes | Browser + Server | Supabase project URL (`https://<project-ref>.supabase.co`) |
| `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` | Yes* | Browser + Server | Supabase publishable key (`sb_publishable_...`). *Falls back to `NEXT_PUBLIC_SUPABASE_ANON_KEY` if using legacy keys. |
| `NEXT_PUBLIC_SITE_URL` | Optional | Server Auth Routes | Canonical public origin (e.g. `https://sayagain.vercel.app`) |
| `SUPABASE_SECRET_KEY` / `SUPABASE_SERVICE_ROLE_KEY` | CLI and publish API | `scripts/publish-episode.ts`, `POST /api/publish/episode` | Admin key for deck publishing. **Never** prefix with `NEXT_PUBLIC_` or expose to client bundles. |
| `SAYAGAIN_PUBLISH_SECRET` | Publish API | `POST /api/publish/episode` | Bearer secret the video repo sends. **Never** prefix with `NEXT_PUBLIC_`. |

### 3. Apply Database Schema & Seed Episode 001

If setting up a fresh Supabase project manually, open the **Supabase SQL Editor** and run in order:

1. `supabase/migrations/20261030090000_init_sayagain_mvp.sql`
2. `supabase/migrations/20261030120000_card_framework.sql` *(framework steps, optional picture, public `card-images` bucket)*
3. `supabase/migrations/20261030150000_opaque_episode_links.sql` *(unguessable import ids, and no public episode list)*
4. `supabase/seed.sql` *(seeds a local published deck. The in-app sample link is `/import/fa46986aa5a5d9cc43d82b38`, **SCN-021 You forgot their name again**)*

### 4. Configure Google OAuth in Supabase

1. In [Google Cloud Console → Auth Platform → Clients](https://console.cloud.google.com/auth/clients), create a **Web application** OAuth 2.0 Client:
   - **Authorized JavaScript origins:** `http://localhost:5001` (and your production Vercel URL)
   - **Authorized redirect URIs:** `https://<project-ref>.supabase.co/auth/v1/callback`
2. In **Supabase Dashboard → Authentication → Providers → Google**:
   - Enable **Sign in with Google** and paste your Google `Client ID` and `Client Secret`.
3. In **Supabase Dashboard → Authentication → URL Configuration**:
   - **Site URL:** `http://localhost:5001` (switch to your Vercel HTTPS domain in production)
   - **Redirect URLs:**
     - `http://localhost:5001/auth/callback`
     - `https://<your-vercel-domain>/auth/callback`

### 5. Run locally

```bash
pnpm dev
```

Open `http://localhost:5001`. Import links look like `/import/{id}`, not `/import/episode-001`.

---

## Publishing New Episode Decks (`episode.cards.json`)

Validated episode JSON files live in `content/episodes/` (see `content/episodes/episode-001.cards.json`). To validate and publish a new episode from the command line:

```bash
SUPABASE_SECRET_KEY="sb_secret_..." pnpm episode:publish content/episodes/episode-001.cards.json
```

Framework episodes from `english-one-minute` use one card. The front is a picture (when the episode has `pictureImage`) or the situation text, then the question, then the three framework labels. Reveal shows each step as `Label: answer`.

From the video repo, after the MP4 looks right:

```bash
npm run publish:card -- --episode data/SCN-001-unrealistic_deadline.json
```

That command calls the deployed SayAgain app: set `SAYAGAIN_PUBLISH_URL` to `https://<your-vercel-domain>/api/publish/episode`. `english-one-minute` stays local. The same `SAYAGAIN_PUBLISH_SECRET` must be set in that repo’s `.env` and in Vercel. The command prints a full import URL whose id is not the video file name. Republishing with the same secret updates the same card. Apply migration `20261030150000_opaque_episode_links.sql` on Supabase before the first publish.

---

## Verification & Testing

```bash
pnpm typecheck   # TypeScript strict check
pnpm lint        # ESLint check
pnpm test        # Vitest unit tests (redirect safety, schema validation, ts-fsrs, PWA platform detection)
pnpm build       # Production Next.js build
```

---

## Vercel Deployment Checklist

1. Import this repository into Vercel (Root Directory: `./`).
2. Add environment variables in **Vercel Project Settings → Environment Variables**:
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`
   - `NEXT_PUBLIC_SITE_URL` = `https://<your-production-domain>`
   - `SAYAGAIN_PUBLISH_SECRET` = the same long random string used in `english-one-minute/.env`
3. Update **Supabase Dashboard → Authentication → URL Configuration**:
   - Set **Site URL** to `https://<your-production-domain>`
   - Add `https://<your-production-domain>/auth/callback` (and optional preview URLs) to **Redirect URLs**.
4. Update **Google Cloud Console → Authorized JavaScript origins** to include `https://<your-production-domain>`.
5. Verify over HTTPS on Android Chrome (`Install` banner prompt), iPhone Safari (`How to add` → `Share → Add to Home Screen`), and an in-app browser (`Open in Browser` guidance).

---

## MVP Limitations

- **Offline behavior:** Only the public app shell and static icons are cached by the service worker. Full offline review queueing/conflict merge is intentionally out of scope for MVP; reviews require connectivity to persist safely, with automatic unsaved-review recovery (`Retry Save`) if a network drop interrupts submission.
- **Audio:** Cards play recorded `audioUrl` files when provided and fall back to browser device speech synthesis (`en-US`) when `audioUrl` is `null`. Microphone input is never recorded or scored.
