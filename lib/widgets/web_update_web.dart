import 'dart:html' as html;

void reloadPage() {
  // Tell the service worker to skip waiting
  final controller = html.window.navigator.serviceWorker?.controller;
  if (controller != null) {
    controller.postMessage('skip-waiting', <Object>[]);
  }
  // Brief delay then reload
  Future.delayed(const Duration(milliseconds: 500), () {
    html.window.location.reload();
  });
}
