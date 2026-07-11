# PWA Web Update — Readiness Audit

## Checklist

- [x] `web/flutter_service_worker.js` exists with stale-while-revalidate strategy
- [x] `web/flutter_service_worker.js` has versioned cache name (`mathcalcu-v1.5.2`)
- [x] `web/flutter_service_worker.js` listens for `skip-waiting` message
- [x] `web/version.json` exists with `{"version": "1.5.2"}`
- [x] `lib/version.dart` exists with `kAppVersion = '1.5.2'`
- [x] `lib/widgets/web_update_dialog.dart` exists with Update/Later UI
- [x] `lib/widgets/web_update_web.dart` exists (web-only reload via service worker)
- [x] `lib/widgets/web_update_stub.dart` exists (no-op for non-web)
- [x] `lib/widgets/web_update_helper.dart` exists (conditional import)
- [x] `lib/main.dart` imports `web_update_dialog.dart` and `version.dart`
- [x] `lib/main.dart` has `_checkForWebUpdate()` method
- [x] `lib/main.dart` uses `kIsWeb` to branch web vs Android/Windows update check
- [x] `lib/main.dart` fetches `version.json` with cache-bust timestamp
- [x] `lib/main.dart` compares `version.json` against `kAppVersion`
- [x] `flutter analyze` — 0 errors
- [x] `flutter test` — all tests passing
- [x] No `dart:html` import in non-web files (conditional import used)
- [x] Android/Windows update flow unchanged (no regressions)
- [x] `pubspec.yaml` unchanged (no `web` dependency added)

## Result

**PASS** — All items verified. Feature is production-ready.
