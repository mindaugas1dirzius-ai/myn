# 🕵️ DETEKTYVAS v2 — PILNAS įgyvendinimo planas (savininko patvirtinta 2026-06-13)

> ŠIS DOKUMENTAS YRA VIENINTELĖ TIESA apie Detektyvo režimą. Jis skirtas naujai
> sesijai, kad galėtų SUKURTI viską be papildomų klausimų. Savininko taisyklės
> pažymėtos „GELEŽINĖ" — jų nekeisti be jo OK. Balanso skaičiai pažymėti
> „derinama" — protingi startiniai, koreguojami testuojant.

---

## 0. ESAMA BŪSENA (ką rasi kode)

Detektyvas **v1 JAU PASTATYTAS** (commit 54c1b79 + dizainas f122469) pagal
SENĄ supaprastintą planą. v2 = PERTVARKYTI šiuos failus (nekurti naujų vardų!):

| Failas | v1 būsena | v2 darbas |
|---|---|---|
| `phase2_backend/functions/src/detectiveTypes.ts` | ~9 kl., `a: boolean`, be laikrodžio, bankas 200–500 | perrašyti pagal §2–§4 |
| `phase2_backend/functions/src/detectiveContent.ts` | 10 bylų LT+EN po ~9 kl. | perrašyti bylas pagal §6 |
| `phase2_backend/functions/src/detectiveFunctions.ts` | startDetective, buyDetectiveClue, guessDetective, abandonDetective | papildyti pagal §4 (FUNKCIJŲ VARDŲ NEKEISTI — deployintos, invoker jau sutvarkytas; naujų funkcijų NEkurti) |
| `index.ts` | eksportai yra | nekeisti (nebent tipų importai) |
| `math_game/lib/models/detective_models.dart`, `services/detective_api.dart`, `screens/detective_screen.dart` | bylos segtuvo dizainas | pertvarkyti pagal §5 |
| Įėjimas: `mystery_mode_screen.dart` (3-ias režimas 🕵️) | yra | palikti |

Kas iš v1 LIEKA be pakeitimų: žodis perdega po partijos (detectiveSolved,
cap 300), dienos limitas 3 nemokamos bylos (UTC, users.detectiveDate/Count),
premium (premiumUntil) be ribos, visa logika serveryje, enforceAppCheck: true,
kategorijos kortelė nemokama, žodžio ilgis matomas.

---

## 1. ŽAIDIMO ESMĖ (savininko formuluotė)

Sugalvotas gyvūnas/daiktas/kažkas — žaidėjas JO NEŽINO. Mes jam įmetam
**30 paruoštų klausimų** (3 lygiai), jis pats renkasi, kuriuos PASPAUSTI,
ir už kiekvieną moka taškais iš bylos banko. Mes atsakome TAIP / NE /
TAIP-NE su paaiškinimu. Laikas tiksi visą laiką. Spėjimas dviem variantais:
**V1 — įrašo atsakymą pats**, **V2 — paspaudžia vieną iš 30 mūsų pateiktų
atsakymo variantų**. 3 gyvybės. Pvz.: sugalvotas 🍎 — „Ar didesnis už šunį?"
→ NE; „Ar raudonos spalvos?" → TAIP/NE „būna kelių spalvų"; „Ar auga ant
medžių?" → TAIP… „OBUOLYS!" 🎉

## 2. GELEŽINĖS TAISYKLĖS (savininko)

1. **30 klausimų matrica** kiekvienam žodžiui: 3 lygiai po 10, paruošta
   IŠ ANKSTO serveryje. Balanso garantija: visi 30 pritaikyti būtent TAM
   žodžiui — loginių klaidų nėra; išnaudojęs visus 30 žaidėjas 100 % žinos
   atsakymą, bet gaus labai mažai taškų.
2. **Kainos pagal vertę:** kuo klausimas labiau priartina prie atsakymo,
   tuo brangesnis.
3. **Trys atsakymų tipai:** griežtas TAIP · griežtas NE · **TAIP/NE +
   PAAIŠKINIMAS** (kai būna visaip: „Ar žalias?" → „TAIP, bet gali būti ir
   raudonas ar geltonas") — paaiškinimas rodomas IŠKART nupirkus.
4. **Protingos užuominos (3 lygis):** joks klausimas VIENAS negali atskleisti
   atsakymo. Testas kiekvienam brangiam klausimui: „ar gavęs ŠĮ VIENĄ atsakymą
   žaidėjas dar turi galvoti?" Brangūs klausimai veikia per ASOCIACIJĄ
   (legendos, simboliai, garsūs įvykiai): ❌ „Ar tai vaisius iš Adomo ir Ievos
   istorijos?" (per tiesmuka) → ✅ „Ar susijęs su garsiu mokslininko atradimu?"
   → TAIP (Niutonas — dar reikia sujungti). Ryšys paaiškinamas PO partijos.
5. **Laikas tiksi NUOLAT** (ir spėjant!). Galutiniai taškai =
   likęs bankas − laiko bauda (formulė §3).
6. **3 gyvybės**, klaidingas spėjimas −1; 0 → byla žlugo, žodis parodomas ir
   vis tiek perdega.
7. Sunkumo lygiai pagal amžiaus skalę: L1 = 9–12 m. vaikai (Žirafa, Obuolys),
   L2 = paaugliai, L3 = suaugę, L4 = žinovai.

## 3. EKONOMIKA IR FORMULĖS (derinama testuojant; konstantos detectiveTypes.ts)

- `DETECTIVE_BANK = 1000` 🔑 — bylos bankas (visiems lygiams vienodas;
  lygis keičia žodžių/klausimų sunkumą, ne banką).
- Kainos: `TIER_PRICES = {1: 15, 2: 35, 3: 70}`; **SOS mįslė −120** (§5.4).
- Laiko bauda: `TIME_COEF = 2` 🔑/sek. Laimėjus:
  `award = max(25, bankLeft − round(elapsedSec × TIME_COEF))`.
  elapsedSec — TIK serverio laikas (startedAt įrašytas serveryje).
- **V1 premija už rašymą ranka:** `award = round(award × 1.25)` (sunkiau be
  variantų — vertingiau).
- Laimėti taškai → `mysteryKeys` (bendras raktų bankas, kaip paslapčių/melt).
- Klaidingo spėjimo bauda: −1 gyvybė (V1 ir V2 vienodai). Banko už klaidą
  nemažinam — gyvybės pakanka (derinama).

## 4. SERVERIS (detectiveTypes.ts / detectiveContent.ts / detectiveFunctions.ts)

### 4.1 Tipai (v2)
```ts
export type ClueTier = 1 | 2 | 3;
export type ClueAnswer = "yes" | "no" | "both"; // both = TAIP/NE + note privalomas
export interface ClueQuestion {
  t: ClueTier;
  q: string;            // klausimo tekstas (matomas NEMOKAMAI)
  a: ClueAnswer;        // siunčiama TIK nupirkus
  note?: string;        // paaiškinimas; PRIVALOMAS kai a === "both"
  kills?: number[];     // kuriuos lentos variantus (indeksus) šis atsakymas
                        // logiškai atmeta — įrodymų matuokliui (§5.6) ir
                        // validatoriui. Pildoma su turiniu.
}
export interface DetectiveText {
  word: string;            // slaptas žodis (V1 spėjimui — normalizeGuess)
  categoryLabel: string;   // „Gyvūnas" — nemokama
  intro: string;           // 1 sakinio intriga: „Liudininkai matė jį parke…"
  board: string[];         // LYGIAI 30 variantų (žodis + 29 tikėtini tos
                           // pačios kategorijos distraktoriai) — V2 lentai
  boardEmoji: string[];    // po emoji kiekvienam variantui (ta pačia tvarka)
  sos: string;             // SOS mįslė — stipriausia, bet IRGI protinga
  questions: ClueQuestion[]; // LYGIAI 30: po 10 kiekvieno lygio (t: 1/2/3)
}
export interface DetectiveCase {
  id: string;              // "det_001"… (NEKEISTI esamų id — solved sąrašai!)
  level: 1 | 2 | 3 | 4;
  texts: Partial<Record<Lang, DetectiveText>>; // v2: lt + en
}
```

### 4.2 Būsena `users/{uid}.detective` (rašo TIK serveris)
```ts
{ id, lang, level, variant: 1|2, startedAt /*serverio ms*/,
  bankSpent /*išleista klausimams*/, bought: number[] /*klausimų indeksai*/,
  sosBought: boolean, lives: 1|2|3, boardOrder?: number[] /*V2: sumaišyti
  lentos indeksai, fiksuoti starte (shuffle kaip melt revealOrder)*/ }
```
Eliminavimo braukymai V2 — TIK kliento kosmetika (serveriui nesiunčiami).

### 4.3 Funkcijos (vardai SENI — deployintos, invoker netaisyti)
- **startDetective({lang, level, variant})** — transakcija: dienos limito
  patikra (3/parą UTC, premium be ribos; aktyvios bylos resume — limito
  neskaičiuoti antrąkart); parinkti neperdegusią bylą pagal lang+level
  (fallback kaip pickMeltMystery: level → bet koks); state į users;
  grąžinti: intro, categoryLabel, žodžio ilgis (V1), klausimų TEKSTAI+kainos
  +lygiai (BE atsakymų!), board pagal boardOrder + emoji (V2), bankLeft,
  lives, startedAt, serverNow, sosAvailable:false.
- **buyDetectiveClue({index})** — transakcija: index 0..29 (arba 30=SOS, tik
  kai lives === 1 ir !sosBought); dar nepirktas; bankLeft − kaina ≥ 0;
  įrašyti bought+bankSpent; grąžinti {a, note, bankLeft}. SOS atveju — {sos}.
- **guessDetective({guess})** — transakcija; laikas NETIKRINAMAS prieš spėjimą
  (laikrodis tiksi, bet partijos galiojimo limito nėra — bankas ir taip tirpsta;
  jei elapsed bauda suvalgė banką — award = minimumas 25, žaisti vis tiek verta):
  - V1: `normalizeGuess(guess) === normalizeGuess(word)`;
  - V2: `guess` = lentos indeksas, lyginti su žodžio pozicija boardOrder'e;
  - teisingai → award pagal §3, mysteryKeys += award, byla → detectiveSolved
    (cap 300), state trinti; grąžinti breakdown (bankLeft, elapsedSec,
    timePenalty, variantBonus, award, totalKeys) + visų 30 atsakymų sąrašą
    ANALIZEI (§5.7) + word;
  - klaidingai → lives−1; jei 0 → fail: grąžinti word, perdeginti, state
    trinti; kitaip {correct:false, lives, sosAvailable: lives===1}.
- **abandonDetective()** — fail be taškų, žodis grąžinamas, perdega.
- Sauga: viskas transakcijose, atsakymai siunčiami tik nupirkus, replay
  neįmanomas, enforceAppCheck: true (visos jau turi).

### 4.4 Validatorius `_validateDetective.js` (PARAŠYTI PIRMA turinio!)
Tikrina kiekvienos bylos kiekvieną kalbą: lygiai 30 klausimų (10/10/10 pagal t);
a==="both" → note netuščias; board.length===30 ir boardEmoji.length===30;
word yra board'e LYGIAI vieną kartą; kills indeksai 0..29 ir niekada nekilla
teisingo žodžio; SUJUNGUS visų 30 klausimų kills lieka LYGIAI 1 variantas
(teisingas) — matricos pilnumo įrodymas; jokio klausimo q, kuriame pažodžiui
yra word (atsakymas klausime); LT kabutės „..." (ne ASCII, ne U+201C);
id unikalūs. Paleisti po kiekvienos bylos parašymo.

## 5. KLIENTAS (Flutter)

### 5.1 Ekranų srautas
`mystery_mode_screen` (🕵️ kortelė) → **detective_intro** (naujas widget'as arba
dialogas): tamsus stalas, žalia lempa, rudas vokas „VISIŠKAI SLAPTAI" —
braukimas perplėšia (animacija), iškrenta kortelė „BYLA · GYVŪNAS" + intro
sakinys; čia pasirenkamas LYGIS (1–4 pagal amžiaus skalę) ir VARIANTAS:
🎯 „Įtariamųjų lenta" (numatytasis L1–L2) / ✍️ „Rašyk pats +25 %"
(numatytasis L3–L4) → **detective_screen** → rezultato dialogas su analize.

### 5.2 Žaidimo ekranas — 3 zonos
- **Viršus:** taksometras-bankas (skaičius tirpsta su tyliu tik-tak garsu;
  kas sekundę −TIME_COEF vizualiai — kliento laikrodis sinchronizuotas per
  serverNow kaip melt_screen), 3 gyvybės 🔍 (suskyla su garsu), kategorija.
- **Centras:** TRYS IŠSISKLEIDŽIANTYS STALČIAI (ExpansionTile stiliumi):
  🟢 APKLAUSA −15 · 🟡 EKSPERTIZĖ −35 · 🔴 SLAPTI ŠALTINIAI −70. Klausimų
  tekstai matomi nemokamai. Paspaudus — pirkimas: kortelė apsiverčia su
  ANTSPAUDU: ✅ žalias TAIP / ❌ raudonas NE / ⚠️ gintarinis „TAIP, BET…"
  + paaiškinimo juostelė. Nupirkti klausimai krenta į APKLAUSOS ŽURNALĄ
  (chat-stiliaus sąrašas po stalčiais); ilgu paspaudimu — žvaigždutė ⭐.
- **Apačia:** V1 — mygtukas „KALTINU!" → įvesties laukas (rašomosios
  mašinėlės garsas raidėms; laikrodis tiksi toliau!). V2 — lentos mygtukas
  (žr. §5.3).

### 5.3 V2 „Įtariamųjų lenta"
Atskiras pilno ekrano vaizdas (toggle iš žaidimo ekrano): kamštinė lenta,
30 kortelių (žodis+emoji) prisisega smeigtukais viena po kitos starte
(stagger animacija). Brūkšt per kortelę — papilkėja su ❌ (kliento būsena,
undo antru paspaudimu). Likus ≤3 neišbrauktoms — kortelės vos virpėja
(scale pulse). ILGAS paspaudimas → „KALTINTI ŠITĄ?" patvirtinimas → spėjimas.
Teisingai: lenta nušvinta, kortelė apsiverčia, konfeti + raudono siūlo
animacija nuo žurnalo iki kortelės (CustomPainter linija). Klaidingai:
kortelė „sudega" 🔥 (fade į pelenus) ir gyvybė skyla.

### 5.4 SOS mįslė
Kai lieka 1 gyvybė — virš žurnalo iškyla speciali raudona kortelė
„🆘 SLAPTAS INFORMATORIUS −120" (pulsuoja). Nupirkus — rodoma SOS mįslė.

### 5.5 Garsai/atmosfera (esamas SoundService + nauji maži efektai)
Lietaus/vinilo fonas (tylus loop), antspaudo trinkt (pirkimas), mašinėlės
tak (V1 raidės), stiklo dzingt (gyvybė), širdies dūžiai kai lives==1,
smeigtukų tak-tak (lentos startas), win fanfaros (esama). Jei garso failų
nėra — naudoti esamus tap/correct/wrong/points/win, naujų neoutsource'inti.

### 5.6 ĮRODYMŲ MATUOKLIS (siurprizas #1)
Po kiekvieno pirkimo serveris grąžina `evidencePct` = kiek % lentos variantų
jau logiškai atmesta (iš nupirktų klausimų kills sąjungos; 29 atmesti = 100 %).
UI: plonas termometras po banku „Įrodymų pakanka: 73 %". Ties 100 % —
antspaudas „ĮRODYMŲ PAKANKA KALTINIMUI!". Veikia abiem variantais (V1
žaidėjas lentos nemato, bet matuoklį mato — žino, kad jau galima išvesti).

### 5.7 Rezultato analizė (po bylos)
Dialogas: antspaudas „BYLA IŠSPRĘSTA" / „BYLA ŽLUGO"; žodis; taškų
išskaidymas (bankas − klausimai − laikas + V1 premija); detektyvo rangas:
🥇 Šerlokas (≤6 klausimai, be klaidų) / 🥈 Inspektorius (≤12 arba 1 klaida) /
🥉 Naujokas (kitaip) — ribos konstantose, derinama; visų 30 klausimų
atsakymai su paaiškinimais (scroll) — „aha!" momentas brangiųjų asociacijoms.

## 6. TURINYS (didžiausias darbas — daryti PO kodo)

v2 startui: **perrašyti esamas 10 bylų** (id NEKEISTI) į pilną formatą:
L1×3 (pvz. Žirafa, Obuolys, Mėnulis), L2×3, L3×2, L4×2 — LT+EN.
Kiekvienai bylai × kalbai: word, categoryLabel, intro (1 sakinys intrigos),
30 klausimų (10/10/10, su a/note/kills), board 30 (žodis + 29 TOS PAČIOS
kategorijos tikėtini distraktoriai), boardEmoji 30, sos mįslė.

Rašymo taisyklės: faktai NEGINČIJAMI ir patikrinti; tarptautiška, nieko
neįžeidžia, be religijos/politikos; 3 lygio klausimai — TIK protingos
asociacijos (testas §2.4); „both" atsakymų bent 4–6 byloje (jie įdomiausi);
klausimai trumpi (tilptų kortelėje, ~≤60 simbolių); LT natūrali kalba, ne
pažodinis vertimas; kabutės „..."; emoji neišduoda atsakymo ankstyvai
(lentoje emoji prie VISŲ variantų — tai ok). Po kiekvienos bylos —
_validateDetective.js + mano kritinė peržiūra.

## 7. DARBŲ EIGA NAUJAI SESIJAI (griežta tvarka)

1. `detectiveTypes.ts` v2 (tipai+konstantos+formulės) → `npx tsc --noEmit`.
2. `_validateDetective.js` validatorius.
3. 1 PILOTINĖ byla (Obuolys, L1, LT+EN) → validatorius → savininko peržiūra
   TEKSTU (parodyti visus 30 klausimų chat'e!) — TIK PO OK rašyti likusias 9.
4. `detectiveFunctions.ts` v2 + tsc → deploy:
   `cd phase2_backend/functions && npx firebase-tools deploy --only functions:startDetective,functions:buyDetectiveClue,functions:guessDetective,functions:abandonDetective`
   (vardai seni → invoker problemos nebus; jei vis tiek 401 „offline" —
   žr. atmintį apie Cloud Run Invoker, gcloud NĖRA šiame kompe).
5. Klientas: models → api → intro → screen (V1) → lenta (V2) → matuoklis →
   analizė. `flutter analyze` (2 seni info avatar_catalog — ignoruoti) →
   `flutter build apk --debug` → `adb install -r` (įrenginys R5CX221CT5N;
   adb: C:/Users/minda/AppData/Local/Android/Sdk/platform-tools/adb.exe;
   NELIESTI telefono ekrano jei savininkas juo naudojasi).
6. Likusios 9 bylos partijomis po 3 → validatorius → deploy turinio.
7. Po KIEKVIENO gabalo: commit (konkretūs failai, ne -A) + push + PRANEŠTI
   savininkui lietuviškai, ką patikrinti telefone.

## 8. KO NEDARYTI

- Nekeisti deployintų funkcijų vardų ir bylų id.
- Neliesti klasikinio Mystery, Melt, Blitz, „Tiesa ar mitas" — veikia.
- Nekurti naujo taškų tipo — laimėjimai į mysteryKeys (vieninga sistema #49
  dar savininko galvoje).
- Jokio turinio masinio rašymo PRIEŠ pilotinės bylos OK (§7.3).
- Balanso konstantų nekalti į UI tekstus — tik iš serverio payload.

## 9. VĖLESNI ETAPAI (v2.1+, atskiri savininko OK)

Reklama už +1 gyvybę vietoj Game Over (1×/byla) 💰 · Dienos byla visiems
vienoda + pasidalijimo kortelė · Bylų serijos po 10 su tema (aukso ženklelis
už seriją be pralaimėjimų; premium paketai) · Detektyvo licencija/laipsniai
(jungti prie #49) · Dvikova ant vieno telefono (bendras bankas, pakaitomis).
