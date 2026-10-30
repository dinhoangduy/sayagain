# SayAgain — English Speaking Flashcard Practice (MVP)

A lightweight, mobile-first Progressive Web App (PWA) for daily English speaking practice linked to **English Speaking Challenge** episodes. Viewers open an episode link (such as `/import/episode-001`), sign in with Google, preview and import the episode’s speaking cards idempotently, and review due cards daily using client-side **FSRS** (`ts-fsrs`) persisted to **Supabase Postgres** under Row Level Security (RLS).

> **Integration boundary:** This repository is completely independent from the Remotion / Python Edge-TTS video production pipeline. Episode decks are imported via a standalone `episode.cards.json` export contract.

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
| `SUPABASE_SECRET_KEY` / `SUPABASE_SERVICE_ROLE_KEY` | CLI only | `scripts/publish-episode.ts` | Admin key for CLI deck publishing. **Never** prefix with `NEXT_PUBLIC_` or expose to client bundles. |

### 3. Apply Database Schema & Seed Episode 001

If setting up a fresh Supabase project manually, open the **Supabase SQL Editor** and run in order:

1. `supabase/migrations/20261030090000_init_sayagain_mvp.sql`
2. `supabase/seed.sql` *(seeds `episode-001`: **Ordering Coffee** with 5 speaking cards)*

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

Open `http://localhost:5001` or test the deep-link flow directly at `http://localhost:5001/import/episode-001`.

---

## Publishing New Episode Decks (`episode.cards.json`)

Validated episode JSON files live in `content/episodes/` (see `content/episodes/episode-001.cards.json`). To validate and publish a new episode from the command line:

```bash
SUPABASE_SECRET_KEY="sb_secret_..." pnpm episode:publish content/episodes/episode-001.cards.json
```

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
3. Update **Supabase Dashboard → Authentication → URL Configuration**:
   - Set **Site URL** to `https://<your-production-domain>`
   - Add `https://<your-production-domain>/auth/callback` (and optional preview URLs) to **Redirect URLs**.
4. Update **Google Cloud Console → Authorized JavaScript origins** to include `https://<your-production-domain>`.
5. Verify over HTTPS on Android Chrome (`Install` banner prompt), iPhone Safari (`How to add` → `Share → Add to Home Screen`), and an in-app browser (`Open in Browser` guidance).

---

## MVP Limitations

- **Offline behavior:** Only the public app shell and static icons are cached by the service worker. Full offline review queueing/conflict merge is intentionally out of scope for MVP; reviews require connectivity to persist safely, with automatic unsaved-review recovery (`Retry Save`) if a network drop interrupts submission.
- **Audio:** Cards play recorded `audioUrl` files when provided and fall back to browser device speech synthesis (`en-US`) when `audioUrl` is `null`. Microphone input is never recorded or scored.
