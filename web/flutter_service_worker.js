'use strict';

const CACHE_NAME = 'mathcalcu-v1.5.3';
const CORE_ASSETS = [
  '/MathCalcu/',
  '/MathCalcu/index.html',
  '/MathCalcu/main.dart.js',
  '/MathCalcu/flutter.js',
  '/MathCalcu/flutter_bootstrap.js',
  '/MathCalcu/manifest.json',
  '/MathCalcu/icons/Icon-192.png',
  '/MathCalcu/icons/Icon-512.png',
];

// Install: cache core assets, then activate immediately
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(CORE_ASSETS))
  );
  self.skipWaiting();
});

// Activate: delete old caches, claim all clients
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(
        keys.filter((key) => key !== CACHE_NAME).map((key) => caches.delete(key))
      )
    )
  );
  self.clients.claim();
});

// Fetch: stale-while-revalidate — fast response from cache, update in background
self.addEventListener('fetch', (event) => {
  // Skip non-GET requests
  if (event.request.method !== 'GET') return;

  // Skip chrome-extension and other non-http requests
  if (!event.request.url.startsWith('http')) return;

  event.respondWith(
    caches.open(CACHE_NAME).then((cache) =>
      cache.match(event.request).then((cached) => {
        // Always fetch in background to update cache
        const fetchPromise = fetch(event.request)
          .then((response) => {
            // Only cache successful same-origin responses
            if (response.ok && event.request.url.startsWith(self.location.origin)) {
              cache.put(event.request, response.clone());
            }
            return response;
          })
          .catch(() => {
            // Network failed, return cached if available
            return cached;
          });

        // Return cached immediately if available, otherwise wait for fetch
        return cached || fetchPromise;
      })
    )
  );
});

// Listen for messages from Flutter
self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'skip-waiting') {
    self.skipWaiting();
  }
});
