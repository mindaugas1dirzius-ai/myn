# TAIP/NE BLITZ — įgyvendinimo planas (2026-06-12)

30 sek. raundas: teiginiai krenta vienas po kito, žaidėjas spaudžia TAIP/NE.
Vieta jau rezervuota (Blitz ⚡ kortelė kataloge, open:false → true).

## SVARBIAUSIAS sprendimas — teiginių generavimas BE gramatikos rizikos

Analizė parodė: perrašyti klausimus į sklandžius lietuviškus teiginius pavyktų tik
~5–10 % fondo (linksniai!). „Nilas įteka į **Viduržemio jūra**" — negramatiška.

**Sprendimas — „patikrinimo šablonas":** rodom klausimą PAŽODŽIUI + kandidatą:

    Koks aukščiausias gyvūnas pasaulyje?
    👉 Žirafa            → TAIP
    👉 Dramblys          → NE

TAIP = kandidatas teisingas, NE = distraktorius. Veikia 100 % fondo (~2 346 LT
klausimai), nulis linksniavimo, veikia visomis kalbomis. TRUE = klausimas+correct,
FALSE = klausimas+atsitiktinis distraktorius; balansas ~50/50 serveryje.

## Serveris

- **blitzFunctions.ts** (naujas, izoliuotas):
  - `startBlitz({lang})` → ~40 teiginių paketas iš SUJUNGTO fondo (gamta + visos
    trivijos temos), pickQuestions+mergeRecent rotacija (recentByMode["blitz"]),
    `active_games` doc: `{uid, mode:"blitz", isTrue:boolean[], createdAt}`.
  - `submitBlitzScore({gameId, answers:[{i,val,tMs}]})` → laiko vartai
    (trukmė ≤30s+tolerancija, ≥atsakymų×~250ms, indeksai unikalūs), vertinimas
    TIK iš serverio isTrue[], doc trinamas (no replay), coins/lentelė kaip
    submitScore. SVARBU: submitScore NEPERNAUDOJAMAS (jis hardcoded 10 atsakymų).
- gameConfig.ts: BLITZ_DURATION_MS=30000, BLITZ_BATCH=40, MIN_BLITZ_MS~250.
- index.ts: vienas export.

## Taškai (serveryje)

    base=100 · kombo ×(1+0.1×streak, iki ×2 ties 10 iš eilės)
    paskutinės 5 s ×2 · klaida = 0 ir kombo nulinasi
    Lentelė: mode "blitz" (viena globali).

## isTrue siųsti klientui? — TAIP (variantas C)

6 variantų trivijoje atsakymo žinojimas duoda 6× pranašumą ir mes jį jau siunčiam;
TAIP/NE bazinė tikimybė 50 %, tad žinojimas duoda tik 2× — MAŽIAU išnaudojama nei
esamas modelis. UX reikalauja momentinės žalios/raudonos reakcijos be round-tripo.
Apsauga: laiko vartai + outlier logging (beveik tobulas + beveik minimalus laikas).

## Klientas

- blitz_models.dart, game_api.dart +2 metodai (su esamu _withRetry).
- blitz_game_provider.dart: VIENAS 30 s laikmatis (ne per klausimą), eilė,
  kombo, {i,val,tMs} sąrašas, pabaigoje submit.
- blitz_game_screen.dart: viršuje tirpstanti laiko juosta (paskutinės 5 s
  raudona + pulsuoja), centre klausimas + 👉 kandidatas (AutoSizeText),
  apačioje du DIDELI nykščio mygtukai: NE (kairė, raudona) / TAIP (dešinė,
  žalia). Haptics (pirmą kartą programoje: HapticFeedback.light/heavyImpact)
  + esami garsai (tap/correct/wrong/points/win). Klaida = raudonas glitch.
- theme_catalog.dart: blitz open:true; category_home: → BlitzGameScreen.
- Rezultatams: esamas ResultScreen arba plonas BlitzResultScreen (score,
  max kombo, correct/total, „Žaisti dar").

## Rizikos
- Ilgi atsakymai-sakiniai → praleisti generuojant (lieka >2000 tinkamų).
- Skubantis skaitymas → svoris į lengvas/vidutinis, trumpi kandidatai.
- Fonas/pauzė raundo metu → serveris atmeta pavėluotą submit (graceful klaida).

## MVP eiga
1. blitzFunctions.ts + konstantos + export → deploy.
2. Modeliai + API + provider + ekranas.
3. Katalogo perjungimas. 4. Poliravimas (kombo SFX, ×2 vizualas) — v2.
