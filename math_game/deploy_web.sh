#!/usr/bin/env bash
# Web build + deploy su CACHE-BUSTING (sprendžia "neatsinaujina" problemą).
# Kiekvienas paleidimas įdeda unikalų BUILD_STAMP → naršyklė PRIVALO imti naują.
set -e
export PATH="$PATH:/opt/flutter/bin"
cd "$(dirname "$0")"

STAMP=$(date +%s)
echo "=== Build (stamp: $STAMP) ==="
flutter build web --release --no-web-resources-cdn --pwa-strategy=none

# Pašalinam service worker (jis cache'ina seną versiją)
rm -f build/web/flutter_service_worker.js

# Įdedam unikalų BUILD_STAMP į index.html (cache-busting + SW unregister)
python3 - "$STAMP" <<'PY'
import sys
stamp = sys.argv[1]
p = "build/web/index.html"
html = open(p, encoding="utf-8").read()
html = html.replace("BUILD_STAMP", stamp)
unreg = '''  <script>
    if ('serviceWorker' in navigator) { navigator.serviceWorker.getRegistrations().then(function(rs){for(var r of rs)r.unregister();}); }
  </script>
'''
if "unregister" not in html:
    html = html.replace("</body>", unreg + "</body>")
open(p, "w", encoding="utf-8").write(html)
print("index.html patched, stamp:", stamp)
PY

echo "=== Deploy ==="
firebase deploy --only hosting --token "$FIREBASE_TOKEN" --project math-game-9862f
echo "=== DONE: https://math-game-9862f.web.app (stamp $STAMP) ==="
