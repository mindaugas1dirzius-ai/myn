# 📋 PROJEKTO PLANAS — Matematikos žaidimas (A → Z)

> **Mūsų susitarimas:** 90% planuojam ir aiškinamės, 10% programuojam.
> Einam **po vieną žingsnį**. Nepradedam naujo, kol esamas neaiškus ir nepažymėtas ✅.
> Kiekvienai daliai atsakom į 3 klausimus: **KODĖL? KAIP? KAM SKIRTA?**

## 📜 DARBO TAISYKLĖS (visada galioja)

### 1. Planas virš visko (Plan Before Code) + Kokybė > greitis
Niekada nerašom kodo, kol abu nepatvirtinam, kurioje tiksliai plano vietoje esam ir ką konkrečiai darysim.
**Kaip veikia:** prieš kiekvieną naują žingsnį parodau atnaujintą `PLANAS.md` vaizdą. Tik kai parašai **„Darom"** — judam toliau.
**Auksinė taisyklė:** geriau **lėčiau, bet kokybiškai ir taip, kaip nori savininkas**, nei greitai ir „bele kaip". Po kiekvieno žingsnio parodau rezultatą — savininkas patikrina PRIEŠ einant toliau. Niekada nebėgam „kaip akis išdegę".

### 2. Griežtas kodo skaidymas (Single Responsibility)
Jokių milžiniškų failų. Kodas skaidomas į mažus, nepriklausomus modulius.
**Kaip veikia:** dizainas (Widgets) gyvena atskirai nuo logikos (Services/Providers). Kiekviena serverio funkcija ar ekrano elementas turi **tik vieną aiškią užduotį** — kad pakeitimai nesugriautų likusio žaidimo.

### 3. „Skauto taisyklė" ir nulinis dubliavimas (Zero Redundancy)
Senas, nebenaudojamas ar pakeistas kodas **iškart ištrinamas**, ne komentuojamas ar paliekamas fone.
**Kaip veikia:** nauja versija pilnai pakeičia senąją (kaip su `submitScore`). Jei kodas kartojasi dviejose vietose — iškeliam į bendrą pagalbinę funkciją (Utility).

### 4. Dviejų žingsnių kodo keitimas (Refactor workflow)
Taisant klaidą einam per principą: **KODĖL tai įvyko → KAIP ištaisyti.**
**Kaip veikia:** visada aiškiai parodau, kurią vietą ištrinti ir ką įklijuoti vietoje jos — kad tavo failuose nekiltų chaosas.

**Statuso ženklai:** ✅ padaryta · 🔄 dabar dirbam · ⬜ liko · ⏸️ laukia kitų

---

## 🗺️ DIDŽIOJI LENTELĖ (A → Z)

| # | Žingsnis | Kam skirta (1 sakiniu) | Statusas |
|---|----------|------------------------|----------|
| **A** | Planas ir susitarimas dirbti | Kad žinotume, ką ir kokia tvarka darom | ✅ |
| **B** | Darbo aplinka (Flutter + įrankiai) | Kad būtų kuo kurti app | ✅ (debesyje) |
| **C** | Tuščias Flutter projektas paleidžiamas | Patvirtinam, kad viskas veikia | ✅ (analyze 0 klaidų, testas praeina) |
| **D** | Firebase projektas + prijungimas | Serverio pamatas (DB, funkcijos) | ✅ projektas, Auth, Firestore(eur3), Blaze, funkcijos deploy'intos |
| **E** | Google Play paskyra ($25) + testerių rinkimas | Pradeda 14 d. laikrodį, vėliau nesusistresuosim | ⬜ |
| **F** | Žaidimo dizainas ant popieriaus (ekranai, spalvos) | Žinom, kaip atrodys, prieš programuojant | ✅ (8/8, žr. DIZAINAS.md) |
| **G** | Žaidimo branduolys offline (be serverio, be reklamų) | Pagaminam patį žaidimą | ✅ G1–G5 (analyze 0, testai praeina) |
| **H** | Serverio smegenys: anti-cheat (startGame/submitScore) | Niekas negali suklastoti rezultatų | ✅ perrašyta 16 režimų, kompiliuojasi (laukia diegimo D) |
| **I** | Security Rules + App Check įjungimas | Užrakinam DB ir patvirtinam app tapatybę | ⬜ |
| **J** | Flutter klientas jungiasi prie serverio | Telefonas „kalbasi" su smegenimis | ⬜ |
| **K** | Top 10 lentelė (leaderboard) ekrane | Žaidėjai mato reitingą | ⬜ |
| **L** | UMP privatumo sutikimas (GDPR) | Teisėtai rodyti reklamas ES | ⬜ |
| **M** | AdMob reklamos (test ID): banner, interstitial, rewarded | Pajamų variklis | ⬜ |
| **N** | (Neprivaloma) IAP „Remove Ads" | Papildomos pajamos + UX | ⏸️ |
| **O** | Pre-launch: Data Safety, Privacy Policy, ikonos, aprašymas | Be šito Google atmeta | ⬜ |
| **P** | Test ID → realūs AdMob ID | Tikros pajamos | ⏸️ |
| **R** | Closed Testing (14 d., 12+ testerių) | Privaloma sąlyga paleidimui | ⬜ |
| **S** | Paleidimas į Production | Žaidimas viešai Play Store | ⬜ |
| **Z** | Po paleidimo: Analytics, Mediation, optimizacija | Augimas ir didesnės pajamos | ⏸️ |

---

## 📖 DETALŪS PAAIŠKINIMAI (po vieną žingsnį)

> Pildysim šitą dalį einant. Kiekvieną žingsnį paaiškinam PRIEŠ darydami.

### A — Planas ir susitarimas 🔄
- **Kodėl:** be plano klaidžiojam ir perdarinėjam. Su planu matom visą kelią.
- **Kaip:** šita lentelė; einam iš eilės; žymim statusą; nieko nepraleidžiam.
- **Kam skirta:** kad tu visada žinotum, kur esam ir kas toliau.

### B — Darbo aplinka (Windows) 🔄
- **Kodėl:** Windows „iš dėžės" nemoka kurti Android programėlių. Reikia įdiegti įrankius.
- **Kaip:** 4 įrankiai — Git, Flutter SDK, Android Studio, VS Code. Pabaigoje `flutter doctor` patvirtina, kad viskas OK.
- **Kam skirta:** kad galėtum rašyti kodą ir paleisti žaidimą emuliatoriuje/telefone.
- **Užbaigimo sąlyga:** `flutter doctor` rodo ✓ ties Flutter, Android toolchain ir bent vienu įrenginiu.

### ⚠️ SVARBU: APK build tik TAVO kompiuteryje
Debesų aplinkos tinklo politika blokuoja Google Android SDK serverį
(`dl.google.com` → „Host not in allowlist"). Todėl **APK/AAB build'as
debesyje neįmanomas.** Galutinį paleidžiamą failą reikės sukurti TAVO
kompiuteryje (Android Studio įdiegia SDK automatiškai) arba paleisti per
`flutter run`. Visa kita (kodas, analyze, testai) — darau debesyje.

### H — Serverio smegenys (anti-cheat) ✅
- **Kodėl:** jei telefonas pats skaičiuotų taškus, bet kas galėtų pameluoti rezultatą.
- **Kaip:** `startGame` serveryje kuria klausimus (slepia atsakymus); `submitScore` serveryje tikrina ir skaičiuoja. Kodas: `phase2_backend/`.
- **Kam skirta:** kad Top 10 lentelė būtų sąžininga ir nesugadinama.
- **Statusas:** kodas parašytas ir patobulintas (delete=Replay apsauga, geresnės Rules), BET dar neįdiegtas (laukia D, I žingsnių).
- **Liko prie H įdiegiant:** Firestore TTL policy apleistiems žaidimams; vėliau rate-limiting.

---

## ▶️ KUR ESAM DABAR

Esam ties **žingsniu A** (susitariam dėl plano).
Jau iš anksto turim paruoštą **H žingsnio kodą** (serverio smegenys) — bet jo dar neįdiegsim, kol nepadarysim B–D (aplinka ir Firebase).

**Kitas žingsnis:** B — paruošti darbo aplinką. Bet pirma — ar šita lentelė tau aiški?
