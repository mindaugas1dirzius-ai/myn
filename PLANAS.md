# 📋 PROJEKTO PLANAS — Matematikos žaidimas (A → Z)

> **Mūsų susitarimas:** 90% planuojam ir aiškinamės, 10% programuojam.
> Einam **po vieną žingsnį**. Nepradedam naujo, kol esamas neaiškus ir nepažymėtas ✅.
> Kiekvienai daliai atsakom į 3 klausimus: **KODĖL? KAIP? KAM SKIRTA?**

**Statuso ženklai:** ✅ padaryta · 🔄 dabar dirbam · ⬜ liko · ⏸️ laukia kitų

---

## 🗺️ DIDŽIOJI LENTELĖ (A → Z)

| # | Žingsnis | Kam skirta (1 sakiniu) | Statusas |
|---|----------|------------------------|----------|
| **A** | Planas ir susitarimas dirbti | Kad žinotume, ką ir kokia tvarka darom | 🔄 |
| **B** | Darbo aplinka (Flutter + įrankiai) | Kad kompiuteris galėtų kurti app | ⬜ |
| **C** | Tuščias Flutter projektas paleidžiamas | Patvirtinam, kad viskas veikia | ⬜ |
| **D** | Firebase projektas + prijungimas | Serverio pamatas (DB, funkcijos) | ⬜ |
| **E** | Google Play paskyra ($25) + testerių rinkimas | Pradeda 14 d. laikrodį, vėliau nesusistresuosim | ⬜ |
| **F** | Žaidimo dizainas ant popieriaus (ekranai, spalvos) | Žinom, kaip atrodys, prieš programuojant | ⬜ |
| **G** | Žaidimo branduolys offline (be serverio, be reklamų) | Pagaminam patį žaidimą | ⬜ |
| **H** | Serverio smegenys: anti-cheat (startGame/submitScore) | Niekas negali suklastoti rezultatų | ✅ kodas paruoštas |
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

### H — Serverio smegenys (anti-cheat) ✅
- **Kodėl:** jei telefonas pats skaičiuotų taškus, bet kas galėtų pameluoti rezultatą.
- **Kaip:** `startGame` serveryje kuria klausimus (slepia atsakymus); `submitScore` serveryje tikrina ir skaičiuoja. Kodas: `phase2_backend/`.
- **Kam skirta:** kad Top 10 lentelė būtų sąžininga ir nesugadinama.
- **Statusas:** kodas parašytas, BET dar neįdiegtas (laukia D, I žingsnių).

---

## ▶️ KUR ESAM DABAR

Esam ties **žingsniu A** (susitariam dėl plano).
Jau iš anksto turim paruoštą **H žingsnio kodą** (serverio smegenys) — bet jo dar neįdiegsim, kol nepadarysim B–D (aplinka ir Firebase).

**Kitas žingsnis:** B — paruošti darbo aplinką. Bet pirma — ar šita lentelė tau aiški?
