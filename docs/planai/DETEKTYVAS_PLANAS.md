# 🕵️ DETEKTYVAS — įgyvendinimo planas (2026-06-12, savininko „kuriam kitą")

## Idėja (savininko sprendimas 2026-06-12)
Slaptas ŽODIS. Žaidėjas PERKA TAIP/NE klausimus iš „klausimų turgaus" (3 kainų
lygiai) ir bando atspėti žodį. 3 gyvybės. Žodis PERDEGA po vieno žaidimo
(turinys vienkartinis) → nemokamai ribotas dienos srautas, premium — daugiau.

## Mechanika
- BANKAS pagal lygį: L1 200 · L2 300 · L3 400 · L4 500 🔑 (kaip paslapčių). Grindys 50.
- KLAUSIMŲ TURGUS: matai VISUS ~9 klausimų TEKSTUS, bet atsakymas (TAIP/NE)
  kainuoja: 🟢 pigus −15 (platus: „Ar tai gyva būtybė?") · 🟡 vidutinis −30
  (siaurinantis: „Ar gyvena Afrikoje?") · 🔴 brangus −60 (beveik pasako:
  „Ar tai aukščiausias pasaulio gyvūnas?"). Pirkimas tirpdo banką (laiko
  spaudimo NĖRA — tai MĄSTYMO žaidimas, kontrastas blitz/tirpimui).
- ŽODŽIO LANGELIAI matomi (ilgis = nemokama užuomina) + raidžių pool
  (mystery stiliaus, kalbai neutralu). SPĖTI galima bet kada.
- ❤️❤️❤️ 3 gyvybės: klaidingas spėjimas −1. 0 → byla žlugo, žodis parodomas,
  vis tiek PERDEGA. Atspėjus → likęs bankas + mysteryKeys.
- Kategorijos kortelė (Gyvūnas/Vieta/Daiktas/Maistas…) — matoma nemokamai.

## Monetizacija (savininko valia)
- NEMOKAMAI: 3 bylos per parą (UTC; users.detectiveDate/detectiveCount).
- PREMIUM (premiumUntil galioja): be ribos. Vėliau — perkami bylų paketai.

## Sauga (viskas serveryje)
- Žodis, atsakymai, bankas, gyvybės, pirkimai — TIK serveryje (users.detective).
- Atsakymas grąžinamas TIK nupirkus (transakcija: bank−kaina ≥ 50).
- Spėjimas: normalizeGuess === word serveryje; replay neįmanomas (perdega
  detectiveSolved sąraše, cap kaip mystery SOLVED_CAP).
- enforceAppCheck: true visoms funkcijoms.

## Failai
- Serveris: detectiveTypes.ts (kainos/bankai/limitai) · detectiveContent.ts
  (bylos: id, level, kategorija, texts{lang: word, categoryLabel,
  questions[{t,q,a}]}) · detectiveFunctions.ts (startDetective, buyDetectiveClue,
  guessDetective, abandonDetective) · index.ts eksportai.
- Klientas: detective_models.dart · detective_api.dart · detective_screen.dart
  („bylos segtuvo" dizainas: kategorija+bankas+gyvybės, žodžio langeliai,
  turgaus kortelės su apverstimo animacija TAIP✅/NE❌, raidžių pool spėjimui)
  · įėjimas iš mystery_mode_screen (3-ias režimas 🕵️).
- Lygiai pagal amžiaus skalę: L1 vaikiški žodžiai (Žirafa), L4 žinovams.
- Turinys v1: ~10 bylų LT+EN (L1×3, L2×3, L3×2, L4×2), klausimai įdomūs,
  faktai tikri, universalūs visoms kalboms.

## Eiga
1. Serveris + 10 bylų + deploy. 2. Klientas + APK. 3. Testas telefone.
4. v2: bylų paketai už 🔑/reklamas, kasdienė „dienos byla" su bonusu.
