'use strict';

const CACHE_NAME = 'mathcalcu-cache-v1';

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

self.addEventListener('install', (event) => {
    event.waitUntil(
        caches.open(CACHE_NAME).then((cache) => {
            return cache.addAll(CORE_ASSETS);
        })
    );
    self.skipWaiting();
});

self.addEventListener('activate', (event) => {
    event.waitUntil(
        caches.keys().then((keys) => {
            return Promise.all(
                keys.filter((key) => key !== CACHE_NAME).map((key) => caches.delete(key))
            );
        })
    );
    self.clients.claim();
});

self.addEventListener('fetch', (event) => {
    event.respondWith(
        caches.match(event.request).then((cached) => {
            return cached || fetch(event.request).catch(() => caches.match('/MathCalcu/index.html'));
        })
    );
});