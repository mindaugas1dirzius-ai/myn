# 🎮 Flutter Matematikos Žaidimas — Pilnas Kūrimo Gidas

> **Stack:** Flutter (Dart) · Firebase (Firestore + Cloud Functions 2nd Gen + Auth + App Check) · Google AdMob
> **Tikslas:** saugiai (server-authoritative anti-cheat) ir tobulai paleisti greito tempo matematikos žaidimą į Google Play.

Šis dokumentas — tai **fazė po fazės** kūrimo planas. Kiekviena fazė turi:
- **🧠 Reikalingi įgūdžiai (Skills)** — ką reikia mokėti / ko mokysies.
- **📋 PROMPT** — paruoštą tekstą, kurį kopijuoji į AI asistentą tos fazės darbui.

Eik nuosekliai. **Niekada nepradėk nuo reklamų** — jos yra paskutinė fazė.

---

## ⚠️ TRYS DALYKAI, KURIE TAVE IŠGELBĖS (perskaityk pirma)

1. **Closed Testing 14 d. / 12+ testerių** — naujoms asmeninėms Google Play paskyroms PRIVALOMA prieš production. Pradėk rinkti testerius JAU dabar (Fazė 0).
2. **App Check (Play Integrity)** — be jo bet kas gali kviesti tavo Cloud Functions. Įjungti PRIEŠ rašant funkcijas.
3. **Server-authoritative** — klientas niekada negeneruoja klausimų ir neskaičiuoja taškų. Tik serveris.

---

# FAZĖ 0 — Pamatas (1 diena)

### 🧠 Reikalingi įgūdžiai
- Bazinis komandinės eilutės (terminal) naudojimas
- Git / GitHub pagrindai
- Flutter SDK instaliavimas, `flutterfire` CLI
- Google paskyros valdymas

### 📋 PROMPT
```text
Esu pradedantysis. Padėk man paruošti darbo aplinką Flutter + Firebase matematikos žaidimui ŽINGSNIS PO ŽINGSNIO, su tiksliomis komandomis mano OS (paklausk kokia mano OS):

1. Įdiegti Flutter SDK ir patikrinti per `flutter doctor` (paaiškink kiekvieną klaidą).
2. Sukurti naują Flutter projektą `math_game` su tvarkinga aplankų struktūra (lib/screens, lib/widgets, lib/services, lib/models, lib/theme).
3. Sukurti Firebase projektą konsolėje ir prijungti per `flutterfire configure` (Android + iOS).
4. Įjungti Firebase: Authentication (Anonymous sign-in), Cloud Firestore (test mode kol kas), App Check.
5. Paaiškinti, kaip dabar pat pradėti Google Play Console registraciją ($25) ir KODĖL svarbu iškart, dėl 14 dienų Closed Testing taisyklės.
6. Duoti man checklistą, ką turiu padaryti rankiniu būdu Google/Firebase konsolėse (su nuorodomis).

Nerašyk žaidimo logikos dar — tik paruošk aplinką ir patvirtink, kad `flutter run` paleidžia tuščią app.
```

---

# FAZĖ 1 — Žaidimo branduolys (offline, BE reklamų, BE serverio)

### 🧠 Reikalingi įgūdžiai
- Flutter widget'ai, layout, navigacija
- State management (Provider arba Riverpod)
- Animacijos (`AnimatedContainer`, `ScaleTransition`, `AnimationController`)
- UI/UX: dark theme, `BoxShadow` (neumorfizmas), gradientai
- `Timer` ir realaus laiko atsako matavimas

### 📋 PROMPT
```text
Kuriam matematikos žaidimo branduolį VEIKIANTĮ LOKALIAI (be Firebase, be reklamų). Naudok Provider state management.

Žaidimo koncepcija:
- Žaidėjas pasirenka režimą (Sudėtis-Lengvas, Sudėtis-Sunkus, Daugyba-Lengvas, Daugyba-Sunkus).
- Ekrane 10 vizualiai gražių langelių (3D/neumorphic, tamsus fonas, neoniniai akcentai).
- Serija: aktyvuojasi langelis, jame matematinis veiksmas (pvz. 3+5), tiksi laikas, rodomi 6 atsakymų variantai.
- Tikslas: kuo greičiau paspausti teisingą. Mažiau laiko = daugiau taškų. Klaida = 0 taškų ir iškart kitas langelis.
- Po 10 langelių — rezultatų ekranas (kol kas vietinis, be Top 10).

Užduotis:
1. Pateik švarią failų struktūrą.
2. Tamsaus režimo spalvų paletę (neon/dark) kaip ThemeData + konstantas.
3. Pagrindinį gameplay ekraną su:
   - laiko matavimu kiekvienam veiksmui (Stopwatch, ms tikslumu),
   - gražiomis animacijomis (teisingas atsakymas = žalias pulse, klaida = raudonas shake),
   - lokaliu klausimų generatoriumi (KOL KAS lokaliai — vėliau perkelsim į serverį).
4. Meniu ekraną režimų pasirinkimui ir rezultatų ekraną.
5. Laikyk atsakymus ir laikus masyve, kad vėliau galėtume siųsti į serverį.

SVARBU: parašyk kodą taip, kad klausimų generavimą ir taškų skaičiavimą būtų LENGVA vėliau pakeisti serverio kvietimu. Iškelk tai į atskirą service klasę su aiškia sąsaja.
```

---

# FAZĖ 2 — Backend ir Anti-Cheat (server-authoritative)

### 🧠 Reikalingi įgūdžiai
- TypeScript / Node.js
- Firebase Cloud Functions (2nd Gen, `onCall`)
- Firestore duomenų modeliavimas ir **transakcijos**
- Firestore **Security Rules**
- **App Check** (Play Integrity) enforcement
- Įeinančių duomenų validacija (anti-bot)

### 📋 PROMPT
```text
Kuriam server-authoritative anti-cheat backend Firebase Cloud Functions (TypeScript, 2nd Gen, onCall). Klientas NIEKADA negeneruoja klausimų ir neskaičiuoja taškų.

Reikia DVIEJŲ funkcijų ir Security Rules:

1) startGame (onCall, enforceAppCheck: true):
   - Reikalauja Auth (Anonymous).
   - Pagal `mode` SERVERYJE sugeneruoja 10 klausimų su teisingais atsakymais.
   - Įrašo į `active_games` kolekciją: { uid, mode, questions:[{action,answer}], createdAt: serverTimestamp(), used:false }.
   - Grąžina klientui TIK { gameId, questions:[tekstai be atsakymų] }.

2) submitScore (onCall, enforceAppCheck: true):
   - Reikalauja Auth.
   - Priima { gameId, clientAnswers, clientTimesMs }.
   - VALIDACIJA pradžioje: clientAnswers ir clientTimesMs turi būti masyvai, ilgis == serverio klausimų skaičiui; kitaip HttpsError.
   - db.runTransaction:
     * VISI get() PIRMA (gameRef IR leaderboardRef) — Firestore reikalauja read-before-write!
     * Patikrina: game egzistuoja, used==false, uid sutampa.
     * Serveryje išmatuoja totalDurationMs = Date.now() - createdAt.
     * Atmeta jei totalDurationMs neįmanomai trumpas (žmogui negalimas) — priežastį loginki, klientui grąžink BENDRĄ klaidą (neatskleisk ribos!).
     * Anti-cheat laikui: sum(clientTimesMs) negali viršyti serverio totalDurationMs (su nedidele paklaida) — kitaip atmesk.
     * Skaičiuoja taškus serveryje: tik teisingi atsakymai (pagal serverio questions), greitis pagal clientTimesMs apribotą serverio laiku (greičiau = daugiau).
     * transaction.update(gameRef,{used:true}) ARBA transaction.delete(gameRef) kad active_games nesikauptų.
     * username skaitomas iš users/{uid} doc, SANITIZUOJAMAS (ilgis, leidžiami simboliai, profanity), prieš rašant į leaderboard.
     * Rašo į leaderboard/{uid}_{mode} tik jei naujas rekordas didesnis.
   - Grąžina { success:true, finalScore }.

3) Firestore Security Rules:
   - users/{userId}: read if auth; write tik savininkui IR su username lauko validacija (ilgis, tipas).
   - leaderboard/{id}: read if auth; write: if false (rašo tik Cloud Functions).
   - active_games/{id}: read,write: if false (visiškai uždara klientams).

4) Paaiškink, kaip įjungti App Check su Play Integrity (Android) ir kaip Flutter kliente prijungti firebase_app_check + cloud_functions paketus, kad onCall automatiškai siųstų App Check + Auth tokenus.

5) Pasiūlyk active_games TTL valymo strategiją (Firestore TTL policy ant createdAt arba delete submit metu).

Duok kompiliuojamą, komentuotą kodą + komandas deploy'inti (firebase deploy --only functions,firestore:rules).
```

> 💡 **Pastaba dėl praeitos versijos klaidos:** transakcijoje VISI `get()` turi būti prieš VISUS `write` — kitaip Firestore mes „transactions require all reads before all writes". Šis prompt'as tai jau ištaiso.

---

# FAZĖ 3 — Reklamos (UMP + AdMob) — PASKUTINĖ logikos fazė

### 🧠 Reikalingi įgūdžiai
- Google AdMob konsolė, Ad Unit ID
- `google_mobile_ads` Flutter paketas
- **UMP (User Messaging Platform)** — GDPR sutikimas
- Ad lifecycle: load / show / dispose, frequency capping
- Test Ad Unit ID ir test device registracija

### 📋 PROMPT
```text
Integruojam reklamas į VEIKIANTĮ Flutter matematikos žaidimą. Naudok google_mobile_ads paketą.

GRIEŽTOS taisyklės:
1. UMP (User Messaging Platform) sutikimo langas iškvietimas PIRMA, prieš bet kokią reklamą (GDPR). Parodyk pilną consent flow su ConsentInformation/ConsentForm.
2. Kūrimo metu naudoti TIK oficialius AdMob Test Ad Unit ID + parodyk kaip užregistruoti mano fizinį telefoną kaip test device (RequestConfiguration testDeviceIds). PASPĖK, kad realių ID spaudimas blokuoja paskyrą už Invalid Traffic.
3. Reklamų strategija:
   - Banner: TIK pagrindiniame meniu ir rezultatų ekrane. NIEKADA aktyvaus žaidimo lauke (atsitiktiniai paspaudimai → ban rizika).
   - Interstitial: tik po žaidimo sesijos pabaigos, su cooldown (ne dažniau kaip kas 90-120 sek.) ir frequency capping. NIEKADA per žaidimo eigą ar app paleidime.
   - Rewarded: „Continue" — žiūri 15 sek video ir tęsi žlugusį rekordą. Aukštas eCPM.
4. Švari ad service klasė: load/show/dispose, preload kito interstitial, error handling jei reklama neužsikrauna (žaidimas turi tęstis be jos).

Duok kodą + paaiškink, kuriuos ID kintamuosius keisiu prieš paleidimą ir kaip laikyti juos saugiai (ne hardcode į git).
```

---

# FAZĖ 4 — In-App Purchase „Remove Ads" (neprivaloma v1)

### 🧠 Reikalingi įgūdžiai
- `in_app_purchase` Flutter paketas
- Google Play Billing, produkto kūrimas Play Console
- Server-side kvito (purchase token) validacija per Google Play Developer API
- Cloud Functions plėtimas

### 📋 PROMPT
```text
Pridedam „Remove Ads" vienkartinį pirkimą (non-consumable) per in_app_purchase paketą.

1. Flutter pusė: pirkimo mygtukas, purchase flow, restore purchases, lokalus reklamų išjungimas po sėkmingo pirkimo.
2. SAUGUMAS: pirkimo Purchase Token siunčiamas į NAUJĄ Cloud Function `verifyPurchase` (onCall, App Check), kuri per Google Play Developer API patikrina kvitą serveryje ir tik tada įrašo users/{uid}.removeAds=true.
3. Flutter pusė reklamų rodymą sąlygoja PAGAL serverio patvirtintą users/{uid}.removeAds, ne tik lokaliai.
4. Paaiškink Play Console: kaip sukurti In-app product, service account API prieigai.

Duok kodą + Play Console konfigūracijos checklistą.
```

---

# FAZĖ 5 — Pre-Launch ir Paleidimas (Google Play Console)

### 🧠 Reikalingi įgūdžiai
- Google Play Console pildymas
- App signing, release build (`flutter build appbundle`)
- Data Safety forma, Content rating, Privacy Policy
- Closed → Open → Production testing

### 📋 PROMPT
```text
Ruošiam žaidimą paleidimui į Google Play. Duok man PILNĄ checklistą ir komandas:

1. Release build: `flutter build appbundle` + app signing (Play App Signing) paaiškinimas.
2. Play Console konfigūracija:
   - "App contains ads" varnelė.
   - Data Safety forma — deklaruoti, kad AdMob renka Advertising ID / device info.
   - Privacy Policy URL (privaloma) — padėk sugeneruoti paprastą privatumo politiką, tinkančią AdMob + Firebase.
   - Content rating klausimynas.
   - Target audience: 13+ (kad išvengtume vaikų (under-13) griežtų taisyklių). Paaiškink kodėl.
3. Developer website + app-ads.txt failas (rekomenduojama): parodyk failo turinį su mano AdMob publisher ID.
4. SVARBU: pakeisti Test Ad Unit ID → realius ID TIK dabar, paskutiniame žingsnyje. Duok checklistą ką patikrinti.
5. Closed Testing: kaip pridėti 12+ testerių, kaip prasideda 14 dienų skaičiavimas, kaip pereiti į Production.

Duok viską kaip nuoseklų checklistą su žymėjimo langeliais.
```

---

# FAZĖ 6 — Po paleidimo (augimas ir optimizacija)

### 🧠 Reikalingi įgūdžiai
- AdMob Mediation
- Firebase Analytics / Crashlytics
- A/B testavimas, Remote Config

### 📋 PROMPT
```text
Žaidimas jau Play Store. Padėk optimizuoti pajamas ir kokybę:
1. Įjungti Firebase Crashlytics + Analytics (sesijos, žaidimų skaičius, ad impressions).
2. Įjungti AdMob Mediation (AppLovin, Unity Ads) didesniam eCPM realiu laiku.
3. Firebase Remote Config — keisti interstitial cooldown ir kitus parametrus BE naujo release.
4. Pasiūlyk metrikas, kurias stebėti: retention D1/D7, ARPDAU, eCPM pagal šalį.
```

---

## 📌 GREITAS FAZIŲ SANTRAUKOS LENTELĖ

| Fazė | Ką darai | Reklamos? | Serveris? |
|------|----------|-----------|-----------|
| 0 | Aplinka + Play paskyra | ❌ | ❌ |
| 1 | Žaidimas offline | ❌ | ❌ |
| 2 | Anti-cheat backend | ❌ | ✅ |
| 3 | UMP + AdMob | ✅ (test ID) | ✅ |
| 4 | IAP Remove Ads | ✅ | ✅ |
| 5 | Paleidimas | ✅ (real ID) | ✅ |
| 6 | Optimizacija | Mediation | ✅ |

---

## 🧩 BENDRAS „MASTER" KONTEKSTO BLOKAS

> Įklijuok šitą kiekvieno naujo pokalbio pradžioje, kad AI asistentas turėtų pilną kontekstą, tada pridėk tos fazės PROMPT.

```text
Kuriu greito tempo matematikos žaidimą: Flutter (Dart) + Firebase (Firestore, 2nd Gen Cloud Functions TypeScript, Anonymous Auth, App Check/Play Integrity) + Google AdMob. Esu pradedantysis — aiškink žingsnis po žingsnio su tiksliomis komandomis ir komentuotu kodu.

Architektūra yra SERVER-AUTHORITATIVE: klientas niekada negeneruoja klausimų ir neskaičiuoja taškų. startGame serveryje generuoja 10 klausimų; submitScore serveryje validuoja, matuoja laiką, filtruoja botus ir per transakciją (visi read prieš write!) rašo į leaderboard. active_games ir leaderboard kolekcijos klientui visiškai uždarytos Security Rules.

Monetizacija: UMP sutikimas pirma; banner tik meniu/rezultatuose; interstitial su cooldown po sesijos; rewarded „Continue". Kūrimo metu tik Test Ad Unit ID.
```
