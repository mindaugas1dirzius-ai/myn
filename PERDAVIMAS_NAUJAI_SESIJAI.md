# 🔄 PERDAVIMAS NAUJAI SESIJAI (Handoff)

> Šis dokumentas perduoda VISKĄ naujai Claude sesijai, kad ji tęstų be
> informacijos praradimo. Perskaityk VISĄ prieš pradedant.

---

## 1. KAS YRA PROJEKTAS

**Matematikos žaidimas** (Android, vėliau žaidimų platforma), kuriamas kaip
verslo produktas JAV/Vakarų rinkoms.

- **Stack:** Flutter (Dart) klientas + Firebase (Firestore, Cloud Functions
  TypeScript 2nd Gen, Auth, App Check) + Google AdMob.
- **Repo:** `mindaugas1dirzius-ai/myn`
- **Branch:** `claude/android-app-monetization-ads-RORMZ`
- **Firebase projektas:** `math-game-9862f` (regionas `europe-west1`, Blaze planas)
- **Web demo:** https://math-game-9862f.web.app (TIK peržiūrai — žr. apribojimus)
- **Saugus grįžimo taškas:** git tag `v1.0-stable-math`

**Savininkas:** Mindaugas (mindaugas1.dirzius@gmail.com). NE programuotojas —
aiškinti PAPRASTAI, lietuviškai, be žargono.

---

## 2. 🛑 GELEŽINĖS DARBO TAISYKLĖS (privaloma laikytis!)

1. **JOKIO KODO be aiškaus „OK, darom".** Pirma IŠDIRBAM kiekvieną pakeitimą
   (kaip veiks, sauga, ar nepažeidžia principų/Google Play), SUDERINAM, tik
   tada — kodas. Visada paaiškinti KODĖL/KAIP.
2. **Po vieną žingsnį.** Neperšokti. Kokybė > greitis.
3. **Moduliai (SRP):** maži failai, viena atsakomybė. Dizainas atskirai nuo logikos.
4. **Jokio dubliavimo:** seną/pakeistą kodą TRINAM iškart (ne komentuojam).
5. **Patikrinti, ne tik pritarti:** savininkas dažnai siūlo idėjas su klaidomis —
   PRIVALU jas pagauti ir sąžiningai pasakyti (jis tai vertina labiausiai).
6. **Po kiekvieno žingsnio:** `flutter analyze` (0 klaidų) + testai + commit + push.
7. **Sąžiningai apie web demo ribas** (žr. žemiau) — neapsimesti, kad veikia.

---

## 3. 🔒 ARCHITEKTŪROS PRINCIPAI (NEKEISTI)

- **Server-authoritative:** serveris generuoja klausimus, tikrina atsakymus,
  skaičiuoja taškus/coins, atrakina lygius. Klientas NIEKO svarbaus nesprendžia.
- **App Check (enforceAppCheck)** ant visų funkcijų — tik tikra app prisijungia.
- **Jokio eval()** — serveris pats skaičiuoja (sauga).
- **Coins/unlock/IAP — TIK serveryje** (atominės transakcijos).

---

## 4. ✅ KAS PADARYTA (pilnai veikia, deployinta)

### Bazinis žaidimas
- 30s laikmatis (tiksi AUKŠTYN, žiedas pilnėja), taškai `max(10, 100−sek×3)`
  VISIEMS lygiams vienodai, gyvi mažėjantys taškai kampe (+100→10)
- Švelnus modelis (klaida=0, žaidimas tęsiasi 10 klausimų)
- Cyber-Neumorphism dizainas (tamsus + neon)
- Kalbos LT/EN (jungiklis veikia), mygtukai (✕ Baigti + Išeiti)

### Režimai (7, visi atsakymai = SKAIČIAI)
- ➕➖✖️➗ baziniai (4 lygiai each) + 🌪️ Mix + 🧱 Skliaustai + 🧬 Algebra
- Architektūra: `questionRegistry.ts` — VIENAS registras, pridėti temą = 1 funkcija
- `generateOptions` universalus (answer + trap + neighbors), Fisher-Yates
- Spąstai (trap): veiksmų eilės klaidos, mokykliniai (algebroj), garantuotai tarp 6
- Rotacija: paskutiniai N nesikartoja; offline irgi no-dup

### Serveris (5 Cloud Functions, GYVOS):
- `startGame` — generuoja 10 klausimų + variantus, tikrina užraktą, rotacija
- `submitScore` — tikrina atsakymus, taškai, coins (1/teisingą +1 jei <3s),
  auto Player_XXXX, promptName, leaderboard rekordas
- `getMyRank` — pozicija = count(score>mano)+1
- `unlockMode` — atrakina lygį už 150 coins (atominė)
- `unlockByAds` — atrakina už 2 reklamas

### Etapas 1: Profilis + getMyRank
- ExpansionTile (4 veiksmai → lygiai su Personal Best), vardas+✏️, rank popup
- Top10 vardo raginimas (variantas C), coins rodymas rezultatuose

### Etapas 3: Užraktai (PILNAS)
- Mix/Skliaustai/Algebra: Vidutinis=nemokamas demo, kiti 3 lygiai užrakinti (150🪙)
- 3 keliai: 150 coins ARBA 2 reklamos (amžinai) · $2.99 viskas/mėn (Etapas 5)
- Kliente: 🔒 langeliai, unlock_dialog (coins/reklama), showRewarded

---

## 5. ⬜ KAS LIKO (eilės tvarka)

```
🔄 SEKANTIS: Flutter diegimas TAVO Windows kompiuteryje
   → kad savininkas pamatytų TIKRĄ app telefone (web demo nerodo serverio dalies)
   → flutter run + App Check debug token

(B) Dienos serija (streak) — retention (sutarta daryti po A)
Etapas 4: Rewarded tobulinimas (×2 coins po sesijos)
Etapas 5: IAP $2.99 prenumerata (Google Play Billing, isPremium)
Grupė B / Etapas 6: KONTRAKTO IŠPLĖTIMAS (variantai=tekstas/ikona/foto), tada:
   🎯 Ženklų medžioklė, 🧸 Kids su ikonomis, 🗺️ Geografija, 🍽️ Maistas, 🐾 Gyvūnai
   ⚠️ Nuotraukos = autorių teisės (savos/CC0)
Paleidimas: Flutter→AAB→Play Console→12 testerių 14d→Production (dokumentai launch/)
```

---

## 6. ⚠️ WEB DEMO APRIBOJIMAI (svarbu suprasti!)

Web'e Firebase IŠJUNGTAS (`if (kIsWeb) return`). Todėl web demo:
- ✅ Rodo: žaidimą, laikmatį, 7 režimus, dizainą (lokaliai)
- ❌ NErodo: užraktų, coins, Top10, profilio, reklamų (visa serverio dalis)
- Pilną funkcionalumą matysi TIK tikroje Android app (Flutter + App Check token)

**Web build/deploy:** `cd math_game && ./deploy_web.sh` (turi FIREBASE_TOKEN env).
Cache-busting jau sutvarkytas. Testuoti telefone — INKOGNITO langas.

---

## 7. 💰 EKONOMIKA (sutarta)

- **SCORE** = reitingo prestižas. Geriausias rezultatas FIKSUOJASI, NEdingsta.
  Top 10 + getMyRank pozicija.
- **COINS** = valiuta. Renkami TIK už teisingus (1 + 1 jei <3s, ~15/sesija).
  NUSIRAŠO atrakinant. ~150 = vienas lygis (≈10-20 gerų sesijų).
  Argumentas (savininko): coins teisingesni nei „20 sužaistų", nes tinginys
  spaudžiantis bet ką negauna coins → sąžininga stengiantiems.
- Atrakinimas AMŽINAS (coins/reklama). Tik $2.99 prenumerata = 30 dienų.

---

## 8. 📁 SVARBŪS FAILAI

**Dokumentai (perskaityti!):**
- `PLANAS.md` — pagrindinis A→Z + taisyklės
- `DIZAINAS.md` — VISI žaidimo sprendimai (8 + papildomi)
- `PLETROS_PLANAS.md` — etapai, kas padaryta/liko
- `STRATEGIJA.md` — retention/monetizacija/ASO gairės
- `launch/` — paleidimo dokumentai (Privacy, Data Safety, Store listing)

**Kodas:**
- Serveris: `phase2_backend/functions/src/` (index, gameConfig, questionRegistry,
  generateOptions, unlockConfig)
- Klientas: `math_game/lib/` (screens, widgets, services, models, l10n, theme)

**Deploy:**
- Serveris: `cd phase2_backend && firebase deploy --only functions --token "$FIREBASE_TOKEN"`
- Web: `cd math_game && ./deploy_web.sh`
- FIREBASE_TOKEN reikia env (savininkas turi; generuoja `firebase login:ci`)

---

## 9. 🔑 TECHNINĖS DETALĖS

- Aplinka: debesų Linux. Flutter įdiegtas `/opt/flutter` (PATH).
- ⚠️ Android SDK debesyje BLOKUOJAMAS (dl.google.com) → APK/AAB build TIK
  savininko kompiuteryje. Web build veikia debesyje.
- App Check: dabar `AndroidProvider.debug` (firebase_service.dart, viena konstanta).
  Prieš paleidimą → `playIntegrity`.
- Firestore indeksas: `mode ASC + score DESC` (deployintas).
- Savininko telefonas: Samsung (Android), naršyklė Samsung Internet/Chrome.
- Savininko kompiuteris: Windows, turi Git + Node, NETURI Flutter (reikės diegti).

---

## 10. ❓ KLAUSIMAI NAUJAI SESIJAI (patikrinimui ar supranta)

Nauja sesija, atsakyk SAU (ar savininkui), kad patvirtintum supratimą:

1. Kodėl coins atrakinimas yra teisingesnis nei „20 sužaistų sesijų"?
2. Kodėl web demo nerodo užraktų ir Top 10?
3. Kur skaičiuojami taškai/coins — kliente ar serveryje? Kodėl?
4. Kas yra `questionRegistry.ts` ir kaip pridėti naują žaidimo temą?
5. Kuo skiriasi SCORE nuo COINS (ar abu dingsta perkant)?
6. Kokia geležinė taisyklė dėl kodo rašymo?
7. Kodėl naujos temos (geografija) reikalauja „kontrakto išplėtimo"?
8. Koks SEKANTIS žingsnis ir kodėl (kas atrakina pilną testavimą)?

Jei naujai sesijai šie atsakymai aiškūs iš dokumentų — perdavimas pavyko.
Jei ne — savininkas turi parodyti šį failą + DIZAINAS.md + PLETROS_PLANAS.md.
