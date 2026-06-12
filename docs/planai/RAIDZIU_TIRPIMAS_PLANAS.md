# RAIDŽIŲ TIRPIMAS — įgyvendinimo planas (2026-06-12)

Naujas paslapties žaidimo režimas: žaidėjas PATS pasirenka laiko limitą ir raidžių
atsivėrimo intervalą; taškai pagal procentinę formulę. Ilgainiui pakeis painų banko modelį.

## Esminiai sprendimai

- **Atskira būsena** `users/{uid}.mysteryMelt` — klasikinis režimas ir Melt veikia greta
  (a fazė). Firestore taisyklių keisti NEREIKIA (klientas ir taip negali rašyti).
- **Deterministinis atsivėrimas be jokių laikmačių serveryje**: starte išsaugoma
  sumaišyta raidžių tvarka `revealOrder`; bet kuriuo momentu iš `elapsedMs` išvedama
  kiek raidžių atversta: `k = floor(elapsed / interval)` → pirmos k `revealOrder` pozicijos.
  NEMOKAMOS raidės (iš viktorinų) imamos iš `revealOrder` GALO (`freeCount`) — niekada
  nesusikerta su automatinėmis ir NEMAŽINA laimėjimo.
- **Formulės** (meltTypes.ts):
  - `meltBaseFor(level)` = 200/300/400/500 (kaip bankMaxFor — ekonomika pažįstama)
  - `speedCoefFor(interval)`: 20 s → 1.0, 10 s → 1.25, 5 s → 1.5 (rizika = atlygis)
  - `P_max = base × speedCoef`
  - Laimėjus: `taškai = P_max × (1 − elapsed/limit) × (1 − autoPenalty/totalLetters)`,
    min. 1. `autoPenalty` — TIK automatiškai atsivėrusios (be nemokamų).
- **Leistinos reikšmės (whitelist)**: limitai [60, 120, 300] s; intervalai [5, 10, 20] s.
  `MELT_MIN_LETTERS = 12` (trumpos frazės netinka — tirpsta per žiauriai).
- **Spėjimai neriboti**, gyvybių nėra; anti-spam eskaluojantis cooldown
  `min(2500 × 2^wrong, 15000)` ms. Priešas — laikas.

## Serverio failai

1. **meltTypes.ts** (grynas, be Firestore): konstantos, formulės, `deriveMelt(state, totalLetters, now)`
   → `{expired, autoCount, autoPenaltyCount, revealedSet, remainingMs, nextRevealInMs, potentialPointsNow}`.
2. **meltFunctions.ts** (visi onCall + enforceAppCheck + europe-west1):
   - `startMelt({lang, limitSec, intervalSec})` — resume jei aktyvus; expired → užskaito
     pralaimėjimą ir startuoja naują toje pačioje transakcijoje; `pendingMysteryLetters`
     automatiškai pritaikomos į `freeCount` (cap: totalLetters−3); naudoja
     `pickMeltMystery` (pickMystery + min. raidžių filtras).
   - `syncMelt({})` — read-mostly; tik expired atveju rašo (užskaito pralaimėjimą).
   - `guessMelt({guess})` — transakcija; laimėjus: `mysteryKeys += meltPoints(...)`,
     `mysterySolved` papildomas, būsena trinama; grąžina breakdown sąžiningam dialogui.
   - `abandonMelt({})` — pralaimėjimas be taškų; kitas pick'as išskiria mestą id.
   - Eksportai index.ts po mystery bloko.
3. Būsenos forma: `{id, lang, level, revealOrder[], freeCount, startedAt, limitSec,
   intervalSec, lastGuessTs, wrongGuesses}` — `startedAt` IMAMAS SERVERYJE.

## Kliento failai

- `models/melt_models.dart` — MeltView (be banko laukų; su limitSec/intervalSec/startedAt/
  serverNow/remainingMs/nextRevealInMs/pMax/potentialPointsNow), MeltGuessOutcome.
- `services/melt_api.dart` — start/sync/guess/abandon (kaip mystery_api).
- `screens/melt_setup_screen.dart` — 2 pasirinkimų eilutės (laikas, intervalas) + gyvas
  P_max rodymas + paaiškinimas.
- `screens/melt_screen.dart` — viršuje: limito juosta + „kita raidė po Xs" + tirpstantys
  taškai; viduryje: kaukė (kopijuoti iš mystery_screen — IZOLIUOTO modulio principas);
  apačioje: didelis „ŽINAU ATSAKYMĄ" → bottom sheet su esamu raidžių įvedimu.
  SVARBU: sheet'as FOTOGRAFUOJA kaukę/pool atidarymo metu (fonas nesimaišo rašant);
  laikrodis tiksi toliau. Sync: lokalus Timer ties kiekviena atsivėrimo riba + on resume;
  serverio laiko poslinkis = serverNow − DateTime.now().
- Įėjimas: `category_home_screen.dart` mystery atveju — režimo pasirinkimo sheet:
  „Klasikinis" / „Raidžių tirpimas". Katalogo keisti nereikia.

## Anti-cheat
Whitelist nustatymai; serverio laikas; tekstas nesiunčiamas iki pabaigos; eskaluojantis
spėjimų cooldown; atsiskaitymas transakcijoje (no replay); abandon-fishing apsauga;
fono pauzė savaime nuostolinga (laikrodis — sieninis).

## b fazė (banko modelio pensija) — VĖLIAU
mysteryPowerup + banko konstantos šalinamos tik po priverstinio atnaujinimo lango;
mysteryKeys/mysterySolved migruoja be pakeitimų; melt-native užuominos = nemokamos
pagal laiką (hint1 ties 40 % laiko, hint2 ties 70 %) — be naujos būsenos.

## Eiga
1. meltTypes.ts (+ determinizmo sanity testas) → 2. pickMeltMystery → 3. meltFunctions
(start+sync pirmiau, tada guess+abandon) → 4. modeliai+API → 5. setup ekranas + sheet
→ 6. melt ekranas → 7. balanso žaidimas visomis 9 kombinacijomis.

## Rizikos
Balanso dominavimas (limitCoef rezervas), laimėjimas paskutinę sekundę ~0 taškų
(svarstyti 5 % grindis), trumpos frazės (MIN_LETTERS), sync dažnis prie 5 s intervalo.
