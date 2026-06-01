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
- ✅ analyze 0, 7 testai, deployinta

---

## ⬜ KAS LIKO (eilės tvarka)

### Etapas 2 — Nauji MATEMATIKOS režimai (lengviausi, saugu)
- Mix (+−×÷ viename), 3 skaitmenų veiksmai (`12+5−4`), šaknys/kvadratai
- Tik nauja generavimo logika; variklis nesikeičia
- ⚠️ Pirma apsvarstyti: V3 sudėtingumas (Ekstremalus ×/÷ per lengvas)

### Etapas 3 — Coins PANAUDOJIMAS (užrakinti langeliai)
- `users/{uid}.unlockedModes[]` masyvas
- Nauja Cloud Function `unlockMode` (atima coins serveryje, prideda ID)
- UI: užrakinti langeliai su 🔒 + kaina; atrakinus — atsidaro

### Etapas 4 — Rewarded reklama (coins už žiūrėjimą)
- AdMob Rewarded; serveris prideda coins (onUserEarnedReward → serverio call)

### Etapas 5 — IAP prenumerata (isPremium)
- Google Play Billing; serveris validuoja kvitą; isPremium atrakina viską

### Etapas 6 — Naujos TEMOS (sunkiausia)
- Geografija, maistas, gyvūnai — reikia NUOTRAUKŲ (autorių teisės!)
- Abstraktus `Question` modelis (display=tekstas ARBA paveikslėlis)
- Duomenų bazė temų klausimams

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
