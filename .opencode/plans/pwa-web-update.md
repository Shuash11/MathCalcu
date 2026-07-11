# PWA Web Update System

## Problem
On iOS/web, the service worker caches old assets. When a new version is deployed, users see the stale version. The current update flow only shows a snackbar with "Open" link on web — no in-app update prompt.

## Solution
3-part fix: (1) Service worker uses cache-bust + stale-while-revalidate, (2) web-specific update dialog that reloads the page, (3) version check on launch.

---

## Part 1: Service Worker (`web/flutter_service_worker.js`)

**Problem:** Fixed cache name `mathcalcu-cache-v1` never invalidates old assets.

**Fix:**
- Switch to **stale-while-revalidate** for all requests (fast load + background update)
- On `activate`, clear ALL old caches (already does this, but need dynamic cache name)
- Use a **versioned cache name** derived from a `version.json` file (or build hash)
- Add a **message listener** so the Flutter app can tell the SW to skip waiting

**Approach:**
- Keep a single cache key `mathcalcu-cache-v{N}` where N is incremented on each deploy
- On install: cache core assets with the new key
- On activate: delete all caches NOT matching the current key, then `clients.claim()`
- On fetch: stale-while-revalidate — return cached version, fetch in background to update cache
- Listen for `message` events: `skip-waiting` triggers `self.skipWaiting()`

## Part 2: Version Check (`web/version.json`)

**New file:** `web/version.json` containing `{"version": "1.5.2"}`

- This file gets deployed with each build
- Flutter reads it on startup via `http.get` (no package_info needed for web)
- Compare against the version baked into the current build

## Part 3: Web Update Dialog (`lib/widgets/web_update_dialog.dart`)

**New file** — web-specific dialog:

```
Update Available
Version 1.5.3

[Later]  [Update]
```

- "Update" button: sends `skip-waiting` message to service worker → `window.location.reload()`
- "Later" button: dismisses dialog, remembers choice in localStorage so it won't nag again until next new version

## Part 4: Update Check on Web (`lib/main.dart`)

**Modify `_checkForUpdates()`:**
- On web (`kIsWeb`): fetch `version.json`, compare against `pubspec.yaml` version, show `WebUpdateDialog` if different
- On Android/Windows: keep existing behavior (download + install)
- On other platforms: keep existing snackbar

---

## Files to Modify/Create

| File | Action |
|------|--------|
| `web/flutter_service_worker.js` | Rewrite — stale-while-revalidate, versioned cache, skip-waiting |
| `web/version.json` | Create — `{"version": "1.5.2"}` |
| `lib/widgets/web_update_dialog.dart` | Create — web update dialog |
| `lib/main.dart` | Modify — add web update check in `_checkForUpdates()` |

## Implementation Details

### Service Worker Strategy
```
install: cache core assets → skipWaiting()
activate: delete old caches → clients.claim()
fetch: stale-while-revalidate (return cache, fetch in bg)
message: skip-waiting on command
```

### WebUpdateDialog Flow
1. App launches on web → fetch `?v=1.5.2` (cache-bust)
2. Compare response.version against current pubspec version
3. If different → show dialog
4. User taps "Update" → postMessage to SW → skipWaiting → reload
5. User taps "Later" → save `lastDismissedVersion` in localStorage → don't show again until next version

### Cache-Bust for version.json
- Fetch `version.json?v={timestamp}` to bypass CDN/server cache
- This ensures we always get the latest version file

## Verification
1. `flutter analyze` — no errors
2. `flutter test` — all passing
3. Manual test: build web, deploy, verify old cache is cleared on reload
4. Manual test: dialog appears on new version, "Update" reloads with new assets
5. Manual test: "Later" dismisses and doesn't show again until next version
