import 'dart:js_interop';
import 'dart:js_interop_unsafe';

// JS interop bindings for the window/service-worker APIs used to force a
// service-worker update and reload. Written with `dart:js_interop`, the
// supported replacement for `dart:html` (deprecated). Uses @JS externals
// and the unsafe utilities instead of declaring extension types, so it
// compiles at the project's current SDK constraint (>=3.0.0).
@JS('window.navigator.serviceWorker.controller')
external JSObject? get _serviceWorkerController;

@JS('window.location')
external JSObject get _location;

void reloadPage() {
  // Tell the service worker to skip waiting.
  final controller = _serviceWorkerController;
  if (controller != null) {
    controller.callMethod('postMessage'.toJS, ['skip-waiting'.toJS].toJS);
  }
  // Brief delay then reload.
  Future.delayed(const Duration(milliseconds: 500), () {
    _location.callMethod('reload'.toJS, <JSAny?>[].toJS);
  });
}
