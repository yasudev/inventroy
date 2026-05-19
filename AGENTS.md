# AGENTS.md

## Repository structure

Two independent projects co-located (not a monorepo workspace):
- **Flutter app** at root (`lib/main.dart`)
- **Laravel 12 API** in `backend/` (`backend/routes/api.php`)

## Architecture

Offline-first inventory management:
```
Flutter (sqflite local DB)  →  sync_queue  →  POST /api/sync  →  Laravel (SQLite server)
```
- `InventoryProvider` (ChangeNotifier) at `lib/providers/inventory_provider.dart` is the central state holder
- CRUD writes to local SQLite first, then attempts API; offline changes queue in `sync_queue` table
- `SyncService.pushChanges()` / `pullChanges()` / `fullSync()` at `lib/services/sync_service.dart`
- Connectivity pings `/api/login` every 30s via `ConnectivityService`
- API base URL hardcoded as `http://localhost:8080` in `lib/main.dart:37`

## Auth (two separate systems)

Frontend: hardcoded users in `lib/models/user_model.dart`
Backend: Sanctum tokens, users table validated in `AuthController`

| Role | Username | Password |
|------|----------|----------|
| Admin | admin | admin |
| Cashier | cashier | cashier |
| Manager | manager | manager |
| Seller | seller | seller |

## Commands

### Flutter (run from root)
| Command | Purpose |
|---------|---------|
| `flutter pub get` | Install Dart deps |
| `flutter analyze` | Static analysis |
| `dart format .` | Format Dart code |
| `dart fix --apply .` | Auto-fix lints |
| `flutter test` | Run tests (only test is broken — see below) |
| `flutter build web` | Web build (used by `serve.sh`) |
| `flutter build windows --release` | Windows release build |
| `flutter run` | Dev server (auto-detects device) |

### Laravel (run from `backend/`)
| Command | Purpose |
|---------|---------|
| `composer setup` | Full setup: install + .env + key + migrate + npm build |
| `composer dev` | Run all dev servers concurrently (server + queue + logs + vite) |
| `composer test` | `config:clear` + `artisan test` |
| `php artisan serve` | Dev server (port 8000) |
| `php artisan migrate` | Run migrations |
| `php artisan queue:listen --tries=1 --timeout=0` | Process queue |
| `npm run dev` | Vite dev server |
| `npm run build` | Build frontend assets |

### serve.sh (from root)
`./serve.sh` — builds Flutter web, serves on port 8080, opens Cloudflare tunnel (requires `cloudflared` at `/home/user/.local/bin/cloudflared`).

## Key gotchas

- **No code generation**: No `build_runner`, `json_serializable`, `freezed`, `mockito`. Models use hand-written `toMap()`/`fromMap()`/`copyWith()`.
- **Test is broken**: `test/widget_test.dart` is the default Flutter counter smoke test and will fail — the app shows a login screen, not a counter.
- **No unit tests exist** for services, providers, or screens.
- **Only dark theme**: `AppTheme.darkTheme` only, no light/dark toggle.
- **i18n is custom**: Hand-written `AppLocalizations` with EN + AM translations, not `flutter_l10n` ARB files.
- **Backend `.gitignore` is empty** — vendor and generated files are not excluded at the backend level.
- **API port mismatch**: Flutter hardcodes `localhost:8080` but `composer dev` serves on port 8000.
- **CORS wide open**: `config/cors.php` allows all origins, methods, and headers.
- **CI**: Only builds Windows release (`flutter build windows --release`) on push to `main` or `v*` tags. No tests run in CI.

## Existing instruction files

- `GEMINI.md` (834 lines) — Firebase Studio / Gemini guidelines. Contains **outdated/inaccurate** guidance: references `build_runner`, `mockito`, and Firebase SDKs that are not used in this project.
- No `opencode.json`, `CLAUDE.md`, or cursor rules exist.

## Backend API routes (`routes/api.php`)

```
POST /api/login                     (no auth)
GET  /api/user                      (sanctum)
POST /api/sync                      (sanctum) — offline sync
POST /api/sales                     (sanctum) — create sale w/ items, decrements stock
GET  /api/sales                     (sanctum)
GET  /api/{entity}                  (sanctum) — generic CRUD
GET  /api/{entity}/{id}             (sanctum)
POST /api/{entity}                  (sanctum)
PUT  /api/{entity}/{id}             (sanctum)
DELETE /api/{entity}/{id}           (sanctum)
```

Entities: categories, units, brands, customers, warehouses, locations, products.
