# Web build (Firebase Hosting demo)

Žaidimo web demo: https://math-game-9862f.web.app

## Build komanda (SVARBU: be service worker, kitaip telefonas cache'ina seną versiją)
```
flutter build web --release --no-web-resources-cdn --pwa-strategy=none
rm -f build/web/flutter_service_worker.js
# + index.html turi SW unregister skriptą (žr. web/index.html)
firebase deploy --only hosting
```

## Pastabos
- Web'e Firebase IŠJUNGTAS (kIsWeb guard) — žaidimas veikia offline (lokalūs klausimai).
- Reklamų web'e nėra (AdMob tik Android/iOS).
- Web — tik PERŽIŪRAI. Tikra app = Android AAB (su serveriu, Top 10, reklamomis).
