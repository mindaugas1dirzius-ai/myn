# 🕵️ DETEKTYVAS (Klausimų turgus) — planas pagal SAVININKO specifikaciją

> 2026-06-13: dokumentas sulygiuotas su ORIGINALIA savininko specifikacija
> (ankstesnė versija buvo savavališkai supaprastinta — 9 klausimai, be laikrodžio.
> TAISYKLĖS ŽEMIAU YRA SAVININKO, jų nekeisti be jo OK).

## Idėja
Slaptas ŽODIS pagal temą (pvz. „Maistas"). Žaidėjas PERKA paruoštus TAIP/NE
klausimus iš „klausimų turgaus" ir bando atspėti žodį. Strateginis detektyvas:
rizika prieš grąžą — pirkti brangų klausimą ar spėti pačiam ir rizikuoti gyvybe.

## 30 KLAUSIMŲ TAISYKLĖ (savininko — geležinė)
Kiekvienam slaptam žodžiui serveryje IŠ ANKSTO paruošta 30 klausimų ir atsakymų
matrica — 3 lygiai po 10:
- 🟢 **1 lygis (lengvi)** — nuima MAŽAI taškų; bendra informacija
  („Ar tai valgoma?" → TAIP)
- 🟡 **2 lygis (vidutiniai)** — nuima vidutiniškai; patikslina grupę
  („Ar tai auga ant medžio?" → TAIP)
- 🔴 **3 lygis (sunkūs/specifiniai)** — nuima DAUG, bet iškart atmeta daug
  variantų („Ar tai gali būti susiję su Niujorku?" → TAIP (The Big Apple))

BALANSO GARANTIJA: visi 30 paruošti būtent TAM žodžiui — loginių klaidų nėra.
Išnaudojęs visus 30 žaidėjas 100 % žinos žodį, bet gaus labai mažai taškų.

## ATSAKYMŲ TIPAI (savininko — svarbiausia dalis)
Atsakymai NĖRA vien „taip/ne". Trys tipai:
1. Griežtas **TAIP**
2. Griežtas **NE**
3. **TAIP/NE + PAAIŠKINIMAS** — kai objektas turi kelias būsenas. Pvz.
   „Ar jis žalias?" → „TAIP, bet gali būti ir raudonas ar geltonas".
   Būna visaip — tai apsaugo žaidėją nuo suklaidinimo.
Duomenų modelis: questions[{tier, q, a: "yes"|"no"|"both", note?}].

## Žaidimo eiga ir taškai (savininko formulė)
1. Žaidėjas gauna TEMĄ + maksimalų taškų banką (orientyras ~1000; galutinius
   dydžius derinsim balansuojant) + žodžio langelius (ilgis matomas).
   LAIKAS PRADEDA TIKSĖTI ir tiksi NUOLAT (nestoja net spėjant!).
2. Klausimo pirkimas: spusteli klausimą turguje → iš banko atimama jo kaina
   → atsakymas iškart iššoka (žalias/raudonas burbulas + paaiškinimas jei yra).
3. SPĖTI: bet kada; suvedi žodį klaviatūra (laikas tiksi toliau!).
   - **Teisingai:** žaidimas stabdomas. Galutiniai taškai =
     `Likę taškai − (praėjęs laikas × koeficientas)`.
     Kuo greičiau — tuo daugiau išsaugojai.
   - **Neteisingai:** −1 gyvybė iš ❤️❤️❤️. Žaidimas tęsiasi, galima pirkti toliau.
     0 gyvybių → Game Over, žodis parodomas.

## UI — 3 zonos (savininko)
- **Viršus (būsena):** pulsuojantis laikmatis · taškų bankas (mažėja perkant) ·
  3 gyvybės (sudega su animacija) · tema dideliu šriftu.
- **Centras (turgus + istorija):** 3 kortelės/stulpeliai (Lygis 1/2/3, prie
  kiekvieno klausimo aiški kaina „−10", „−30", „−60"); nupirkti klausimai
  krenta į „pokalbio" (chat) srautą — klausimas kairėje, spalvotas atsakymo
  burbulas dešinėje su paaiškinimu.
- **Apačia (veiksmas):** didelis „SPĖTI ŽODĮ" → stilingas įvesties laukas.

## Monetizacija (savininko sprendimas — uždarbis)
- Žodis PERDEGA po vieno žaidimo (turinys vienkartinis).
- NEMOKAMAI: ribotas bylų kiekis per parą (pvz. 3; users.detectiveDate/Count).
- PREMIUM: be ribos / daugiau žodžių. Vėliau — perkami bylų paketai.

## Sauga (viskas serveryje)
- Žodis, atsakymai, bankas, gyvybės, laikas, pirkimai — TIK serveryje
  (users.detective; startedAt serverio laiku, kaip Melt).
- Atsakymas grąžinamas TIK nupirkus (transakcija); replay neįmanomas
  (detectiveSolved sąrašas su cap).
- enforceAppCheck: true visoms funkcijoms.

## Failai
- Serveris: detectiveTypes.ts · detectiveContent.ts (bylos: id, level,
  kategorija, texts{lang: word, questions[30]}) · detectiveFunctions.ts
  (startDetective, buyDetectiveClue, guessDetective, abandonDetective).
- Klientas: detective_models.dart · detective_api.dart · detective_screen.dart ·
  įėjimas iš mystery_mode_screen (3-ias režimas 🕵️).
- Lygiai pagal amžiaus skalę: L1 vaikiški žodžiai (Žirafa) … L4 žinovams.
- Turinys v1: ~10 bylų LT+EN po 30 klausimų (300 QA porų) — tik tada plėsti.

## 💡 PASIŪLYMAI ĮDOMUMUI (laukia savininko OK — NEKODUOTI be jo)
1. **Siaurėjantis įtariamųjų ratas:** po kiekvieno atsakymo indikatorius
   „pagal atsakymus liko: DAUG → KELETAS → VOS KELI žodžiai" — detektyvo jausmas.
2. **SOS klausimas:** praradus 2 gyvybes atsiranda specialus LABAI brangus
   klausimas, kuris beveik pasako žodį — paskutinės progos drama.
3. **Reklama už gyvybę 💰:** Game Over → pažiūrėk reklamą, gauk +1 gyvybę
   (1×/byla) — tiesioginis uždarbis natūralioje vietoje.
4. **Dienos byla:** visiems žaidėjams ta pati; pasidalinimo kortelė kaip Wordle
   („Įminiau su 4 klausimais ir 1 gyvybe! 🕵️") — nemokama reklama + sugrįžimai.
5. **Detektyvo analizė po bylos:** „Buvo galima įminti vos su 3 klausimais —
   štai kuriais" → noras bandyti iš naujo protingiau.
6. **Detektyvo rangai:** kuo mažiau klausimų nupirkai ir mažiau laiko sugaišai,
   tuo aukštesnis bylos ženkliukas (🥉 Naujokas / 🥈 Inspektorius / 🥇 Šerlokas) —
   kolekcija profilio ekrane.

## Eiga
1. Serveris + 10 bylų LT+EN + deploy. 2. Klientas + APK. 3. Testas telefone.
4. v2: dienos byla, bylų paketai, reklamos taškai.
