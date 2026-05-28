# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

MYN / MINA — a real-time multiplayer "20 questions" game (Lithuanian UI). One player picks a secret word; others ask yes/no questions and guess. There is also a solo mode where Claude (via the Anthropic API) is the answerer.

Stack: Create React App (react-scripts 5) + Supabase (Postgres + Realtime) + Vercel serverless functions. Deployed on Vercel.

## Commands

- `npm install` — install deps
- `npm start` — local dev server at http://localhost:3000 (CRA dev server)
- `npm run build` — production build into `build/`

There are no tests, no linter config, and no TypeScript. `react-scripts` provides ESLint defaults at build time only.

The `/api/*` serverless functions only run under `vercel dev` or in Vercel deployment — `npm start` alone will not serve them, so the AI mode and `/api/cleanup` will 404 locally unless you run `vercel dev`.

## Environment

Required env vars (see `.env.example`):

- `REACT_APP_SUPABASE_URL`, `REACT_APP_SUPABASE_ANON_KEY` — used by the React client (`src/lib/supabase.js`)
- `ANTHROPIC_API_KEY` — used by `api/ai.js` (server-side only; never expose to client)
- `SUPABASE_SERVICE_ROLE_KEY` (optional) — used by `api/cleanup.js`; falls back to anon key

Before running anything against a fresh Supabase project, paste `SUPABASE_SCHEMA.sql` into the Supabase SQL editor. The schema is idempotent (uses `if not exists` / `add column if not exists`) so it doubles as a migration script — add new schema changes there rather than as separate files.

## Architecture

### Single-file React client (`src/App.js`)

The entire client (~1500 lines) lives in one file. The default-exported `App` component holds **all** game state and renders one of several screen components (`HomeScreen`, `CreateScreen`, `JoinScreen`, `LobbyScreen`, `GameScreen`, `GuessedScreen`, `FinishedScreen`, `PublicRoomsScreen`, `AiSetupScreen`, `AiGameScreen`) selected via a `screen` string. New screens should be added by extending that switch in `App`, not by adding routes — there is no router.

Persistent identity: `playerId` is generated client-side and stored in `localStorage`. The same key is reused when rejoining so a host returning to their room is recognized as the host (`isReturningHost` check in `joinRoom`/`joinPublicRoom`).

### Realtime sync model

Two sync mechanisms run **in parallel** and you should keep both working:

1. **Supabase Realtime** subscriptions via `subscribeToRoom(roomCode)` listen to `postgres_changes` on `rooms`, `players`, `questions`.
2. **2-second polling fallback** (`useEffect` near the top of `App`) re-fetches the same tables. This exists because Realtime is unreliable on some networks/mobile; do not remove it. If you add a new piece of room state, update both the realtime handler and the polling effect.

A separate Supabase `broadcast` channel (`voice:<roomId>`) carries WebRTC signaling for the optional voice chat (`startVoice`/`createPC`/`stopVoice`). It uses a single public STUN server (`stun.l.google.com:19302`).

Chat messages go over the same room channel as a `broadcast` event named `chat` and are not persisted.

### Ghost-player cleanup

Players who close the tab are removed by `/api/cleanup` (`api/cleanup.js`), called from `leaveRoom` and from `beforeunload` / `visibilitychange` listeners with `fetch(..., { keepalive: true })`. The endpoint also handles host transfer for public rooms and deletes the room entirely when the host of a private room leaves or the last player leaves. Any code that adds new exit paths must trigger the same call.

### Question/answer flow

- A "question" is a row in the `questions` table with `answer = null` until the host responds.
- The host UI surfaces `pendingQuestion` (the first unanswered row) and the answer buttons write `taip` / `ne` / `gali_buti` / `yra` into the `answer` column.
- `answerQuestion` decrements `rooms.questions_left`, advances `current_questioner` round-robin through non-host players, and when a guess (`is_guess = true`) is answered also decrements `guesses_left`.
- Game-over is driven by `rooms.status` (`waiting` → `playing` → `guessed` | `finished`). The screen-routing `useEffect` near the bottom of `App` watches `room.status` to advance the local screen.

The answer key strings (`taip`, `ne`, `gali_buti`, `yra`) are Lithuanian and are written to the DB as-is. Don't rename them without a migration; the UI labels live in the `ANSWERS` constant.

### AI mode (`api/ai.js`)

A single Vercel handler with two `action`s:

- `pickWord` — Claude picks a Lithuanian word for a category/difficulty, with an explicit blocklist of common examples to discourage repetition.
- `answer` — Claude answers the player's question about the secret word; the prompt includes the full prior `history` so answers stay consistent. The model is asked to reply as JSON `{"mintis": ..., "atsakymas": "TAIP|NE|GALI BŪTI|ATSPĖJOTE"}` and the handler extracts the `atsakymas` field before returning.

In-memory per-IP rate limit: 20 requests/minute. This resets on every cold start — fine for a small game, do not treat it as a real abuse defense.

Model is `claude-sonnet-4-6`. When upgrading, update both the model id in `api/ai.js` and verify the JSON-extraction regex still matches.

### Audio

`playSound(type)` synthesizes short tones via the WebAudio API — there are no audio assets. iOS Safari requires user-gesture unlock, handled by the one-shot `touchstart`/`click` listeners near the top of `App.js` that resume `window._minaCtx`. Mute state lives in `localStorage` under `soundEnabled`.

## Conventions

- UI strings and user-facing copy are Lithuanian. The `rooms.language` column (`lt` / `en` / `all`) only filters which public rooms a user sees — it does not switch the UI language.
- Don't introduce TypeScript, a router, or a state library for incidental changes; the single-file pattern is intentional for this project. If something genuinely needs to be extracted, prefer adding a sibling file under `src/` and importing it into `App.js`.
- `lib/supabase.js` is the only place that should construct the Supabase client. Reuse the exported `supabase` instance.
- Branch policy in this environment: develop on `claude/claude-md-docs-fNZVD`, commit, and push there. Do not push to `main`.
