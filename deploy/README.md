# ELED production web

Production: https://eled.vnlab.id.vn

The web application uses the same stack as the IoT console: React 18,
TypeScript, Vite and Tailwind. The API uses NestJS and PostgreSQL. Firebase Auth
handles Google sign-in; no ongoing application writes use Firestore.

## Source and development

- `apps/web`: React UI, split page bundles, vocabulary Web Worker, local cache and offline operation queue.
- `services/api`: NestJS API; Firebase ID token verification and PostgreSQL transactions.
- `apps/web/scripts/prepare-data.mjs`: compiles the repository CSVs into a canonical vocabulary seed.

```sh
npm ci --prefix apps/web
npm ci --prefix services/api
npm run build --prefix apps/web
npm run test --prefix apps/web
npm run test --prefix services/api
npm run dev --prefix apps/web
```

Vite forwards `/api` to the existing production domain during local development.
Use a separate API target in `vite.config.ts` when testing writes on a development database.

## Hosting

SSH alias: `aws-vps`; application directory: `/home/ducnp/eled`.
The independent Compose project `eled` joins the existing `server_default` network.
IoT Caddy terminates HTTPS and routes `/api/eled/*` to `eled-api:3200`, dictionary
requests to a restricted Oxford upstream, and other requests to `eled-web:80`.
No additional host ports are published. IoT services are not recreated.

`deploy/setup-database.py` creates the dedicated `eled` database and role once.
Its password lives only in `/home/ducnp/eled/.env` (mode 600). The API verifies
Firebase tokens against public signing certificates and the ELED project ID;
it does not need a service account private key for token verification.

Run `./deploy/deploy.sh` to build both projects, upload a timestamped web release,
build the API image, seed vocabulary, then wait for API/web health checks.
Override the SSH alias with `ELED_SSH_HOST`. Retained hashed assets keep existing
browser tabs usable after deployment. Flutter is no longer needed to build or
serve the production web application; mobile source remains in `lib/`.

## Data and migration

`eled_profiles` stores a JSONB document per verified Firebase UID. Updates operate
on individual keys inside named sections, under a row lock, so changes on different
devices do not overwrite unrelated words or collections. Anonymous users retain a
local profile until they sign in. Failed writes remain queued for retry.
`eled_vocabulary` stores the 23,481 canonical words. The API serves a compressed,
cacheable snapshot; the browser worker decodes it without blocking UI input.

The browser imports former Flutter SharedPreferences keys (known words, collections,
SRS state, settings, speaking sets and streak days) without deleting the old keys.
`tools/migrate_firestore.mjs` performs the one-time server migration using the
signed-in Firebase CLI account, never writes back to Firestore, and preserves
existing PostgreSQL values on conflict. Four existing account profiles were
imported on 2026-10-15. The account settings page also offers an explicit legacy
import for users who need it. Normal account use only loads Firebase Auth.

The legacy Flutter mobile build still uses its original Firestore sync path.
Its account identity remains the same, but mobile-to-PostgreSQL synchronization
requires updating and distributing the mobile app separately.

A first PostgreSQL dump is stored at `backups/eled-after-migration.dump` on the VPS.
The existing IoT database backup script now includes the ELED database and its
role is included in the existing globals backup. JSON export/import remains
available to users in Settings.

## Validation

Unit tests cover SRS compatibility, session selection, speaking parsing/scoring,
Flutter data migration, account switching, queued edits and API operation validation.
`deploy/test-api.cjs` tests real PostgreSQL writes, persistence, separate users,
concurrent writes, deletion, and the unauthenticated guard in an isolated QA
container. The test uses an Auth emulator mock and refuses to run in production.
Production refuses to start with Auth emulator mode enabled. A real Google sign-in
must be completed by the account owner.

## Roll back the web UI

```sh
cd /home/ducnp/eled
ln -sfn "$(cat previous-release)" releases/current
docker compose -p eled -f compose.yaml up -d --force-recreate --wait web
```

Retain the API and database when rolling back a UI release; the former Flutter web
release uses its old Firestore behavior, so prefer a previous React release.

## Browser vocabulary notifications

Web Push uses the dedicated `eled_push_devices` PostgreSQL table. Each browser
opts in separately and authenticates its subscription with a random 256-bit
device secret stored locally; the server stores only its hash. No Firebase
messaging or Firestore is used. Frequency, word count, local active hours,
IANA timezone and vocabulary filters are stored with that device. Changing
accounts disables the previous browser reminder registration.

Before deploying this feature for the first time, run
`ssh aws-vps 'python3 -' < deploy/setup-push.py`. It appends persistent VAPID
keys to the VPS private `.env` without printing them; never rotate these keys
on ordinary deploys. `VAPID_SUBJECT` is the public site URL. Back up that
private environment file securely together with the database. The setup is
idempotent and requires the existing API container for Node crypto.

The API checks due subscriptions every 15 seconds. PostgreSQL row locks and
advancing the next scheduled time before sending prevent duplicate sends
across API instances or restarts. Quiet hours are evaluated again at send
time. Missed reminders are not replayed. Device subscriptions returning
404/410 are deleted. Other delivery errors are recorded for the settings UI;
the next scheduled send retries normally. Delivery is best effort and can be
delayed by the browser, OS, network or Do Not Disturb. Server acceptance is
not a delivery receipt. Up to 200 recent deliveries per device are retained
and merged into the local learning history on app focus. Abandoned devices
older than 180 days are pruned on API startup.

`notifications-sw.js` handles only push display and click navigation. It has
no fetch handler and does not replace ordinary HTTP cache behavior. iOS and
iPadOS 16.4+ require adding the site to the Home Screen before opting in.
Permission is requested only from the enable action; denied permission must
be changed in browser/OS settings. See the WebKit Web Push documentation:
https://webkit.org/blog/13878/.

Known-word changes send an immediate per-device `push/exclude` request,
including when the user closes the tab right after rating Easy. The push
worker reads current device filters again just before delivery. A notification
already accepted by the browser's push service cannot be recalled. The web
lesson Easy action now records Known and mastered SRS together.
