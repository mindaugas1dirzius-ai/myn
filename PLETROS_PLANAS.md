# 🗺️ PLĖTROS PLANAS — Žaidimų platforma (V2 vizija)

> Nuo „matematikos žaidimo" link „žaidimų platformos" (matematika, geografija,
> maistas, gyvūnai...). Tas pats variklis, daug temų.
> **Saugus grįžimo taškas:** git tag `v1.0-stable-math`

---

## 💰 EKONOMIKA (sutarta)
- **Score** = leaderboard prestižas. Geriausias kiekvieno režimo rezultatas,
  nesikeičia perkant. (JAU veikia.)
- **Coins** = atskira valiuta. 1/teisingą + 1 jei <3s (maks 20/sesiją).
  Serveryje. Universali piniginė (visi žaidimai). Atrakinti: lygis ~150,
  tema ~500. (Renkami JAU; panaudojimas — Etapas 3.)

---

## ✅ KAS PADARYTA

### Bazinis matematikos žaidimas (v1.0-stable-math)
- 16 režimų (4 veiksmai × 4 lygiai), 30s laikmatis, taškai max(10,100−s×3)
- Gyvi taškai, animacijos, švelnus modelis, no-dup rotacija
- Serveris + Top 10 + anti-cheat + App Check
- Reklamos (AdMob test) + UMP + kalbos LT/EN + mygtukai
- Web demo (cache išspręstas)

### ✅ ETAPAS 1 — Profilis + getMyRank + coins pamatas (BAIGTA)
- Serveris: `getMyRank` (pozicija = count(score>mano)+1)
- Serveris: coins skaičiavimas + auto `Player_XXXX` + promptName
- Klientas: profilis (ExpansionTile, Personal Best), rank popup
- Klientas: coins rodymas + Top10 vardo raginimas rezultatų ekrane

### ✅ V3 — Sudėtingumo balansas (BAIGTA)
- Ekstremalus ×/÷: 13-25×3-9 (~189) → 12-50×6-19 (~546 variantų)

### ✅ ETAPAS 2 — Registro architektūra + Mix Blitz (BAIGTA)
- `questionRegistry.ts`: vienas registras, pridėti temą = 1 funkcija
- `generateOptions` universalus (answer + trap + neighbors), jokio eval
- 🌪️ Mix Blitz (4 lygiai, veiksmų eilės spąstai)

### ✅ GRUPĖ A — Skliaustai + Algebra (BAIGTA)
- 🧱 Skliaustai (4 lvl, nested, eilės spąstai)
- 🧬 Algebra X (4 lvl, mokykliniai spąstai, x² su kaimyniniais kvadratais)
- **MATEMATIKOS PAKETAS = 7 režimai, 28 lygiai. Su skaičiais BAIGTA.**
- Visi: 7 šeimos × 4 lvl × 5000 testų = 0 klaidų

---

## ⬜ KAS LIKO (eilės tvarka)

### Etapas 3 — Coins PANAUDOJIMAS (užrakinti langeliai) ← KITAS
- `users/{uid}.unlockedModes[]` masyvas
- Nauja Cloud Function `unlockMode` (atima coins serveryje, prideda ID)
- UI: užrakinti langeliai su 🔒 + kaina; atrakinus — atsidaro

### Etapas 4 — Rewarded reklama (coins už žiūrėjimą)
- AdMob Rewarded; serveris prideda coins (onUserEarnedReward → serverio call)

### Etapas 5 — IAP prenumerata (isPremium)
- Google Play Billing; serveris validuoja kvitą; isPremium atrakina viską

### Grupė B / Etapas 6 — KONTRAKTO IŠPLĖTIMAS + nauji žaidimai
⚠️ Šie reikia, kad variantai/klausimai būtų NE TIK skaičiai (tekstas/ikona/foto).
Vienas pamato darbas (kontraktas) → visi šie atsirakina:
- 🎯 Ženklų medžioklė (atsakymas = ženklas +−×÷)
- 🧸 Kids su ikonomis (🧸🧸+🧸 — vaikams, kurie skaičių nepažįsta)
- 🗺️ Šalys pagal objektą (Eiffelis → Prancūzija) — nuotrauka
- 🏛️ Objektai pagal šalį · 🍽️ Maistas · 🐾 Gyvūnai — nuotraukos
- ⚠️ NUOTRAUKOS — autorių teisės (savos/CC0/licencijuotos)

**Techniškai:**
- Abstraktus `Question` modelis (display = tekstas ARBA paveikslėlis URL)
- Duomenų bazė temų klausimams (Firestore arba JSON)
- ⚠️ NUOTRAUKOS — autorių teisės! Savos/licencijuotos/CC0 (Google Play tikrina)
- Coins universalūs: žaidi matematiką → atrakini geografiją → ir t.t.
- Kiekviena tema = atskiras "žaidimas", bet tas pats kodo karkasas (3 taisyklė)

---

## 🚀 PALEIDIMAS (lygiagrečiai, reikia TAVO kompiuterio)
- Flutter diegimas → AAB → Play Console → 12 testerių 14d → Production
- Dokumentai paruošti: `launch/`

---

## 🔒 PRINCIPAI (NEKEIČIAM — Google Play sauga)
- Server-authoritative (serveris tikrina viską)
- App Check, Security Rules
- Coins/IAP/atrakinimas — TIK serveryje (klientas negali pats)
- Po kiekvieno etapo: analyze 0 + testai + commit + (jei reikia) git tag

---

## 🛑 DARBO BŪDAS
Be aiškaus „OK, darom" — jokio kodo. Pirma išdirbam kiekvieną pakeitimą,
suderinam, tada programuojam. Dirbam etapais, po vieną.
