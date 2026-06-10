# 🔄 PERDAVIMAS NAUJAI SESIJAI (Handoff) — v2 (2026-06)

> Šis dokumentas perduoda VISKĄ naujai Claude sesijai, kad ji tęstų be klaidų ir be
> informacijos praradimo. **Perskaityk VISĄ prieš pradedant dirbti.**
> Ankstesnė versija buvo pasenusi → sukėlė didelę painiavą (žr. 1 skyrių). Nepakartok.

---

## ⚡ 0. SANTRAUKA (30 sekundžių)

- **Projektas:** „BRAIN ARENA" — Flutter (Android) + Firebase protų žaidimas vakarų rinkoms.
- **Turinys:** 3 kategorijos — 🧮 Matematika (veikia pilnai), 🌿 Gamta (pildom), 🔍 Mistika (veikia).
- **Repo:** `mindaugas1dirzius-ai/myn`, branch **`claude/android-app-monetization-ads-RORMZ`**.
- **Kur baigėm:** sujungėm išsiskyrusius git medžius; viskas įkelta į GitHub (branch sinchronizuotas su `origin`).
- **Dabartinis tikslas:** prikrauti VISUS gamtos lygius iki **≥150 klausimų** (dabar 79/96/100/68).
- **Po to:** subalansuoti mįsles, tada kiti darbai (žr. 9 skyrių).
- **4 ramsčiai (svarbos eilė):** 1) Sauga 2) Faktų/matematikos teisingumas 3) Įvairovė (jokio kartojimosi) 4) Uždarbis.

---

## 🛑 1. SVARBIAUSIA PAMOKA — NEPAKARTOK ŠIŲ KLAIDŲ

**Kas nutiko (2026-06):** veikė DVI Claude sesijos vienu metu ant to paties repo.
Viena turėjo pilną kopiją (gamta/mystery), kita — seną kopiją be jų. Antra sesija
įkėlė commit'ą ant seno pamato → git medžiai „išsiskyrė" → kilo panika „prarasim darbą".
Realiai niekas nedingo (sujungėm per `merge`), bet sugaišom laiko.

**Taisyklės (PRIVALOMA):**
1. **VIENA sesija vienu metu.** Niekada nedirbk lygiagrečiai su kita Claude sesija ant šio repo.
2. **Periodiškai kelk į GitHub** (po kiekvieno užbaigto gabalo, sesijos pabaigoje):
   `git add <konkretūs failai>` → `git commit` → `git push`. **NEKAUPK darbo tik lokaliai.**
3. **PRIEŠ push — VISADA `git fetch`** ir patikrink ahead/behind:
   - jei **behind** (nuotolinis turi naujesnių) → PIRMA `merge`/`pull`, NE `push --force`;
   - paprastas `push` saugus: jei non-fast-forward, git atmeta, nieko neperrašo.
4. **NENAUDOK `git add -A` ar `git add .`** — šaknyje guli senas `android/` (MINA Capacitor
   build su tūkstančiais šiukšlių + `local.properties`). Pridėk TIK konkrečius kelius
   (`math_game/`, `phase2_backend/...`). `android/` praleidžiam visada.
5. **Atnaujink ŠĮ dokumentą prieš perduodamas** — pasenęs handoff = pagrindinė šios painiavos priežastis.

---

## 👤 2. KAS SAVININKAS (su kuo dirbi)

- **Mindaugas** (mindaugas1.dirzius@gmail.com). Kalbam **lietuviškai**.
- **NE programuotojas.** Aiškinti PAPRASTAI, be žargono, žingsnis po žingsnio.
- Mėgsta: struktūruotus atsakymus, „šviesoforo" stilių (✅⚠️🔴), emoji, lenteles.
- **Vertina sąžiningumą labiausiai:** dažnai pasiūlo idėjų su klaidomis — TU privalai
  jas pagauti ir tiesiai pasakyti, ne aklai pritarti.
- **NEMĖGSTA patvirtinimo mygtukų langų** (`AskUserQuestion`) — JŲ NENAUDOTI. Klausk
  paprastu tekstu („Sutinki? a/b/c"), jis atsako tekstu.
- **Geležinė taisyklė:** be aiškaus **„OK, darom"** Claude NIEKO nekuria/nekeičia kode.
  Pirma išdiskutuojam (kaip veiks, sauga, ar nepažeidžia principų), tada — kodas.
- Sprendimus dėl IAM/Google konsolės **daro pats** (žr. 4 skyrių). Tu jam paaiškini, ką paspausti.

---

## 🖥️ 3. PER KĄ IR KAIP DIRBI (aplinka) — ATIDŽIAI, čia pirmas dokumentas KLYDO

Dirbi **TIESIOGIAI savininko Windows kompiuteryje** (NE debesų Linux!). Detalės:

- **OS:** Windows. Repo kelias: `C:\Users\minda\OneDrive\Desktop\minda myn zaidimas\myn`
  (⚠️ default darbinis katalogas gali būti `...\Desktop` — naudok PILNUS kelius arba `cd` į repo).
- **Šaltinis = GitHub** (ne Windows, ne kuri nors kopija): viskas sinchronizuojama per `git`.
  Prieš dirbdamas pasitikrink aplinką (`uname`): jei `MINGW…/Windows_NT` → Windows keliai `C:\...`.
- **PowerShell 5.1** — NĖRA `&&` (naudok `;`). Nėra ternary/`??`. `git` komandos — be `cd` prefikso.
- **Bash įrankis = Git Bash (MSYS/MINGW64)** — tinka `git`, `npm`, `tsc`, `node`, `grep`.
  ⚠️ **APGAULĖ (lengva suklysti):** `uname`, `grep`, `head`, keliai `/c/Users/...` veikia kaip Linux'e —
  BET tai VIS TIEK Windows, **NE debesų Linux.** Jei `uname` rodo `MINGW64_NT…Msys` ir `Windows_NT` —
  tu savininko kompiuteryje. (Praeita sesija dėl to suklydo manydama, kad veikia debesyje.)
- **Flutter:** NĖRA Bash PATH'e. Yra čia: `C:\Users\minda\flutter\bin\flutter.bat`.
  Kviesk per PowerShell: `& "C:\Users\minda\flutter\bin\flutter.bat" ...`
- **Python NĖRA** įdiegtas — generatoriams naudok **node** (`.js` skriptą), ne python.
- ⚠️ **Node regex su backslash per `node -e` LŪŽTA** Windows'e („Unterminated regexp").
  Sprendimas: rašyk laikiną `.js` failą ir paleisk `node failas.js`, po to ištrink.
- **APK build:** `& "C:\Users\minda\flutter\bin\flutter.bat" build apk --release`
  → rezultatas `math_game/build/app/outputs/flutter-apk/app-release.apk` (~55 MB).
  Savininkas pats persimeta į telefoną (Samsung Android) ir įdiegia.
- **Deploy serveris:** iš `phase2_backend/`: `npx firebase-tools deploy --only "functions:VARDAS"`
  (NE `firebase deploy --token`). Vienos funkcijos deploy greitesnis.
- **SVARBU dėl turinio:** klausimų turinys gyvena SERVERYJE — klientas traukia per runtime.
  Tad **turinio pakeitimas (klausimai) NEReikalauja APK perbudavojimo** — tik `npm run build` + deploy.
  **UI pakeitimas (Dart) REIKALAUJA** APK perbudavojimo + įdiegimo iš naujo.

---

## 🔒 4. SAUGUMO PRINCIPAI (#1 PRIORITETAS — niekada nepažeisti)

- **Server-authoritative:** serveris generuoja klausimus, tikrina atsakymus, skaičiuoja
  taškus/monetas, atrakina lygius. **Klientas NIEKO svarbaus nesprendžia** (sukčius negali apgauti).
- **`enforceAppCheck: true` ant VISŲ Cloud Functions** (patikrinta: 12 funkcijų, visos true).
  Niekada nestatyk `false`.
- **Monetos/unlock/IAP — TIK serveryje**, atominėmis transakcijomis.
- **`rewardAdCoins` funkcija — IŠTRINTA, palikti ištrintą.**
- **Taškai skaičiuojami iš LAIKO serveryje** → atsakymo siuntimas klientui saugus (sukčiui nieko neduoda).
- ⚠️ **Cloud Run niuansas:** jei funkcija meta 401 / „offline" — tai NE App Check problema, o
  trūksta **allUsers / Cloud Run Invoker** leidimo. **Savininkas tai daro pats konsolėje.**
  **NEDARYK `gcloud` IAM / allUsers pakeitimų** ir **NEjunk Firestore „Enforce" rankiniu būdu.**
- **AdMob:** laikyti TEST ID'us, kol savininkas aiškiai pasakys keisti į realius.
- **App Check provideris:** dabar `debug`; prieš tikrą paleidimą → `playIntegrity`.

---

## 🧩 5. DARBO PRINCIPAI (kaip mes dirbam) — ŠIE SVARBŪS SAVININKUI

### 💻 Programavimo
1. **Jokio kodo be „OK, darom".** Pirma planas + sauga, tada kodas.
2. **Maži, sufokusuoti failai (SRP):** viena atsakomybė viename faile (didžiausi ~280–426 eil.).
   Dizainas (widgets) atskirai nuo logikos (services/providers). NEKURTI monolitų.
3. **Maži dokumentai, ne vienas didelis:** info skaidom į atskirus `.md`. Atmintis — irgi maži temų failai (13 sk.).
4. **Jokio dubliavimo (DRY):** seną/pakeistą kodą TRINAM iškart (ne komentuojam). Kartojimąsi keliam į bendrą funkciją.
5. **Registro pattern:** nauja matematikos tema = 1 funkcija `questionRegistry.ts`, ne išbarstytas kodas.
6. **Fisher-Yates** maišymui (NE `sort(()=>Math.random()-0.5)` — šališkas).
7. **`fromJson` su atsargom** (`?? default`) — trūkstamas laukas nelaužia app.
8. **Nested-map atsarga:** Cloud Functions atsakymą su ĮDĖTAIS objektais kliente skaityti per
   `jsonDecode(jsonEncode())` (kitaip `Map<Object?,Object?>` lūžta → telefone atrodo „offline").
9. **Komentarai paaiškina KODĖL** (lietuviškai), ne tik ką.
10. **Po kiekvieno žingsnio:** `flutter analyze` (0 klaidų) + serverio `npm run build` (tsc 0 klaidų) + commit + push.
11. **Vengti tool-permission popup'ų:** pirma papildyk `.claude/settings.json` allowlist'ą, tada vykdyk.

### 🧪 Kokybės
- **Smoke testai** generatoriams (tikrini invariantus: 6 variantai, jokių dublių, teisingas tarp jų, sveiki skaičiai).
- **Patikrinti faktais, ne spėti** — perskaityti kodą/logą prieš teigiant.
- **Offline fallback:** serveris nepasiekiamas → lokalus generatorius (žaidimas niekada nelūžta, tik „offline").
- **Turinys:** faktai 100% patikrinti; variantai ≤46 simb. (tikrink KIEKVIENĄ kalbą atskirai); LT kabutės „...";
  jokio dublio tame pačiame lygyje; tinka VISOMS kalboms/mentalitetams (nieko neįžeisti). Klaida turiny = pasitikėjimo praradimas.
- ⚠️ **Vertimas NĖRA tiesioginis:** kas tinka lietuviškai, nebūtinai tinka italui/lenkui/arabui. **Patarlės, citatos, idiomos
  NEVERČIAMOS pažodžiui** — kiekvienai kalbai reikia KULTŪRIŠKAI atitinkamo ekvivalento (žr. 5B sk. „Lokalizacija").

### 🎮 Žaidimo dizaino (sutarta su savininku)
- **30s laikmatis** klausimui (tiksi aukštyn, be streso), taškai pagal greitį `max(10,100−sek×3)`.
- **Švelnus modelis:** klaida = 0, žaidimas tęsiasi visus 10 klausimų.
- **Spąstai (trap):** klaidingi atsakymai = realios žmogiškos klaidos, garantuotai tarp 6 variantų — kad reikėtų galvoti.
- **Rotacija (no-dup):** klausimai nesikartoja sesijoje IR tarp sesijų (žr. rotacijos receptą 10 sk.).
- **SCORE = prestižas** (geriausias nedingsta, Top10) · **COINS = valiuta** (nusirašo atrakinant).
  Coins teisingiau nei „20 sužaistų" — tinginys, spaudžiantis bet ką, coins negauna.
- **Reklamos saikingai** (interstitial kas 3 partijas + cooldown). Atrakinimas amžinas; prenumerata = 30 d.

### 🤝 Bendravimo / proceso
- Paprastai, lietuviškai, be žargono. Struktūra KODĖL → KAIP, emoji, „šviesoforas".
- **Jokių `AskUserQuestion` popup langų** — tik tekstas (savininkas atsako tekstu).
- **Pagauti savininko klaidas** ir sąžiningai pasakyti (jis tai vertina labiausiai).
- Po vieną žingsnį. Kokybė > greitis. Sąžiningai apie ribas (neapsimesti, kad veikia).

---

## 🧠 5B. METODIKA IR SKAIČIAVIMAI (tikslūs skaičiai iš KODO — „nematoma" žinia)

> Šios žinios dingsta tarp sesijų. Be jų naujas Claude dėlios klausimus „iš akies" ir lygiai išsiderins.
> VISKAS žemiau — patikrinta TIESIAI iš kodo. Faktiniai failai nurodyti skliaustuose.

### A) Matematikos klausimų generavimas — RIBOS pagal lygį (`questionRegistry.ts`)
Vienas variklis: `QUESTION_GENERATORS[family](level)` → `{display, answer, trap?, neighbors?}`. Nauja tema = +1 funkcija (ne 16 kopijų).

**Skaičių rėžiai (`rnd(min,max)`, imtinai):**

| Šeima | 🟢 Lengvas | 🟡 Vidutinis | 🔴 Sunkus | 🔥 Ekstremalus |
|---|---|---|---|---|
| Sudėtis `+` | `1–9 + 1–9` | `10–99 + 1–9` | `10–99 + 10–99` | `100–999 + 10–99` |
| Atimtis `−` | atvirkštinė sudėčiai, rezultatas ≥0 (tie patys rėžiai) ||||
| Daugyba `×` | `2–5 × 2–5` | `2–10 × 2–10` | `2–12 × 2–12` | `12–50 × 6–19` |
| Dalyba `÷` | atvirkštinė daugybai, visada sveika (tie patys rėžiai) ||||

**Sudėtiniai (su `trap` = tipinė žmogiška klaida, GARANTUOTAI tarp 6 variantų):**
- **Mix:** lengvas/vidutinis = 1 atsitiktinis veiksmas; sunkus = 2 veiksmai be skliaustų (`A+B×C`, trap=`(A+B)×C`); ekstremalus = `A×B+C÷D` (trap = nepadalino).
- **Skliaustai:** lengvas `(A+B)×C`; vidutinis `A×(B−C)`; sunkus `(A+B)×(C−D)`; ekstremalus `A×(B−(C+D))`.
- **Algebra (rask x):** lengvas `x+B=C`; vidutinis `A×x=C`; sunkus `Ax+B=C`; ekstremalus `x²+A=B` (su `neighbors` x±1,x±2) arba `A×(x−B)=C`.

### B) 6 variantų generavimas (`generateOptions.ts`)
Aibė = {teisingas} → +`trap` (jei yra) → +`neighbors` (tik ×/÷) → +skaitmenų sukeitimas (jei answer≥10) → +`answer ±1, ±2, ±10`.
Filtras: **tik teigiami sveiki, ≠ teisingam, be dublių.** Jei <6 — pildoma `±N` (didėjant). Visada lygiai **6**, sumaišyta **tikru Fisher-Yates**.

### C) Taškų formulė (`gameConfig.ts`) — VIENODA visiems lygiams
- `maxPoints = 100` **visiems lygiams** (lygiai skiriasi klausimų SUNKUMU, ne taškų skale; atskira Top10 kiekvienam režimui).
- `pointsForAnswer = max(10, floor(100 − sekundės × 3))`; laikas capinamas iki **30s**. Greitas → ~100; 30s → 10; **klaida → 0**.
- **Coins:** +1 už teisingą, **+1 papildomai jei atsakyta <3s** (serveryje).
- Konstantos: `QUESTIONS_PER_GAME=10`, `OPTIONS_PER_QUESTION=6`, `MIN_TIME_PER_Q_MS=200` (botų filtras), `TIME_TOLERANCE_MS=3000`.

### D) Anti-cheat (`submitScore`)
1. Serveris PATS matuoja bendrą laiką (`Date.now() − createdAt`).
2. Botų filtras: jei bendras laikas < `10 × 200ms` → atmesta.
3. Jei `Σ(clientTimesMs) > bendrasLaikas + 3000ms` → atmesta (melagingai maži laikai dideliems taškams).
4. Serveris **perskaičiuoja teisingus** iš `game.answers` — klientu nepasitiki.
5. Žaidimas **ištrinamas** (replay apsauga). Rekordas rašomas TIK jei naujas geriausias.
6. Kaupiama serveryje: `coins`, `totalPoints`, `pointsByCategory`, `learnedFacts` (unikalūs teisingų gamtos/sunkaus-mato klausimų ID), `streakDays` (UTC data), `pendingMysteryLetters`.

### E) Rotacija — be pasikartojimo (`triviaEngine`: pickQuestions + mergeRecent)
- `recentByMode[mode]` — **atskira istorija kiekvienam režimui/potemei/lygiui** (iki `ROTATION_KEEP=150`).
- **Lankstus langas:** vengiam daugiausia `pool − 10 − 5(FRESH_MARGIN)` naujausių → mažam pool'ui langas susitraukia, kad visada liktų šviežių.
- Eilė: nematyti → neseniai matyti; jei pool < 10 — leidžiam kartotis (geriau nei <10 klausimų).
- Atmintis atnaujinama **žaidimo PRADŽIOJE** (ne tik pabaigoje) — iškart išėjus/grįžus gauni KITUS klausimus.
- **Todėl tikslas 150:** 150 klausimų lygyje → ~14 žaidimų be pasikartojimo. Kodo keisti NEREIKIA, tik pasiekti kiekį.

### F) Atrakinimo ekonomika (`unlockConfig.ts`)
- Baziniai `add/sub/mul/div` — **VISI nemokami.**
- Užrakintos šeimos `mix/brackets/algebra`: **Vidutinis = nemokamas DEMO**, kiti 3 lygiai užrakinti.
- Paketas **NĖRA amžinas:** kaina `UNLOCK_COST_COINS=150`🪙, `PLAYS_PER_PACK=2` (po žaidimo −1; 0 → vėl užrakinta). Nuskaičiuojama startGame transakcijoje.
- Reklama: `DAILY_AD_PACK_LIMIT=25` paketai/parą (×2 = 50 nemokami žaidimai). Premium: 30 d. (2.99€), laukas `premiumUntil`.

### G) Mįslių mechanika („Cyber-Ratelis" — BANKO modelis; `mysteryTypes.ts` + `mysteryFunctions.ts`)
- Kategorijos: patarlė/citata/istorija/klausimas/faktas. **Lygis 1–4 → bankas 200/300/400/500** 🔑.
- **Raidės uždirbamos žaidžiant BET KĄ:** `lettersFor(correct)` → ≥10:3, ≥8:2, ≥6:1, kitaip 0. Saugomos `pendingMysteryLetters`.
- **Bankas = `max(50, bankMax(level) − spent)`.** MOKAMA pagalba didina `spent` (tirpdo banką), leidžiama TIK jei bankas liktų ≥50 (grindys `MYSTERY_FLOOR`).
- Pagalbų kainos (iš BANKO, ne iš balanso): užuomina **50**, atskleisti raidę **50**, +1 spėjimas **30**.
- **Atspėjus** → `mysteryKeys += dabartinis bankas`. **Suklydus** → bankas/raktai NEMAŽĖJA, dingsta 1 spėjimas. `MAX_GUESSES=5` (+nupirkti). Bandymams išsekus → atskleidžia atsakymą, parenka NAUJĄ.
- NEMOKAMOS raidės (iš `pendingMysteryLetters`) banko NEMAŽINA — tai atlygis.
- `normalizeGuess`: mažosios, **diakritikai išlaikomi**, skyryba/tarpai suvienodinami. Pauzė tarp spėjimų `GUESS_COOLDOWN_MS=2000`.
- Pool (klaviatūra): paslėptos raidės + 4 šiukšlės **iš paties teksto abėcėlės** (kalbai neutralu — veikia ir kirilica/arabų). `pickMystery`: tos kalbos vienetai (EN atsarga), pirmenybė neišspręstoms.

### H) ⭐ LOKALIZACIJA / VERTIMAS (10 kalbų — ATSARGIAI!)
- Palaikomos: `en, lt, es, it, pl, de, fr, uk, pt, ar`. Nežinoma kalba / neišverstas klausimas → **EN atsarga** (`DEFAULT_LANG`).
- **Vertimas NĖRA pažodinis.** Kas tinka lietuviui, nebūtinai tinka italui/lenkui/arabui.
  - **Patarlės, citatos, idiomos** — NIEKADA neverčiamos pažodžiui. Kiekvienai kalbai reikia **vietinio kultūrinio ekvivalento** ta pačia prasme (arba praleisti, jei nėra gero atitikmens).
  - Faktai/skaičiai universalūs; bet formuluotė, pavyzdžiai, humoras — pritaikomi mentalitetui.
- **Nieko neįžeisti** jokia kultūra/religija/regionu — vengti politiškai/religiškai jautrių temų.
- **Ilgį ≤46 tikrink KIEKVIENA kalba atskirai** (kai kurios ilgesnės už EN). LT vidinės kabutės „..." (ne ASCII); kitos kalbos — savo kabučių taisyklės.
- AR (arabų) — RTL, pridedama paskutinė.

### I) Klausimų sunkumo kalibravimas RAŠOMAM turiniui (gamta/mįslės)
Matematika generuojama (A skyrius), bet gamta/mįslės RAŠOMOS ranka — sunkumą lemia **fakto retumas**:
- 🟢 **Lengvas:** kasdienės/vaikiškos žinios (voras = 8 kojos). Dalis klaidingų akivaizdžiai ne.
- 🟡 **Vidutinis:** bendros žinios (paauglys/suaugęs žino). Klaidingi tikėtini.
- 🔴 **Sunkus:** faktai reikalaujantys domėjimosi. Klaidingi — visi realūs kandidatai.
- 🔥 **Ekstremalus:** specialisto/rekordų/anatomijos detalės (žuvies širdis = 2 kameros). VISI 5 klaidingi labai tikėtini → tikslumas privalomas.
- `isTrap: true` = „False Friend" mitas (atrodo logiška, populiarus klaidingas įsitikinimas) — stipri retencijos priemonė.

### J) Firestore duomenų modelis (kur kas gyvena)
- **Kolekcijos:** `users/{uid}`; `active_games/{id}` (laikinas žaidimas, ištrinamas po submit); `leaderboard/{uid}_{mode}` (geriausias rezultatas režime).
- **`users/{uid}` laukai:** `coins`, `playPacks{mode:liko}`, `premiumUntil`, `recentByMode{mode:[ids]}`, `username`, `totalPoints`, `pointsByCategory{nature|math}`, `learnedFacts`/`learnedFactIds`, `streakDays`/`lastPlayDate`, `pendingMysteryLetters`, `mysteryKeys`, `mysterySolved[]`, `mystery{...}` (aktyvi paslaptis), `adPacksToday`/`adPacksDate`.
- **Klientas (Flutter):** offline atsarga `local_question_generator.dart` (matematika generuojama telefone, jei serveris nepasiekiamas — žaidimas nelūžta, tik „offline"). Serverio atsakymą su ĮDĖTAIS objektais skaityti per `jsonDecode(jsonEncode())`.

---

## 🎯 6. TIKSLAS (kas tai per projektas)

**Saugiai paleisti į Google Play** Flutter+Firebase protų žaidimą („BRAIN ARENA"), kuriame
3 kategorijos (matematika / gamta / mistika), 4 sunkumo lygiai, Top 10 lentelės, monetų ekonomika,
reklamų uždarbis. Rinka — JAV/Vakarai (daugiakalbis). Google Play dar TOLI — nestumti Play žingsnių.

**Kodėl 3 kategorijos viename:** matematika generuojama (skaičiai), gamta/mistika — patikrinti faktai.
BET visos rašo į `active_games` TUO PAČIU formatu → taškus/monetas/Top10/rotaciją skaičiuoja
TAS PATS `submitScore` (App Check apsaugotas). Nulis regresijos.

---

## ✅ 7. KAS PADARYTA (veikia, deployinta)

### 🧮 Matematika (pilnai)
- 7 režimai (➕➖✖️➗ + 🌪️Mix + 🧱Skliaustai + 🧬Algebra), 4 lygiai kiekvienam.
- 30s laikmatis, taškai `max(10, 100−sek×3)`, švelnus modelis (klaida=0, tęsia 10 klausimų).
- Spąstai (trap) garantuotai tarp 6 variantų, Fisher-Yates maišymas, rotacija (no-dup).
- Užraktai: Mix/Skliaustai/Algebra — Vidutinis nemokamas, kiti 3 lygiai už 150🪙 arba 2 reklamas.

### 🌿 Gamta (veikia, turinys pildomas)
- `startNatureGame` funkcija; potemės: faktai / išnykę / augalai / mix; 4 lygiai.
- 6 variantai (1 teisingas + 5 klaidingi), paaiškinimas, emoji.
- Mode formatas: `nature_<potemė>_<lygis>` arba senas `nature_<lygis>`.

### 🔍 Mistika (veikia)
- `startMystery`/`revealLetters`/`guessMystery`/`mysteryPowerup`/`getMysteryStatus`/`resetMystery`.
- Atskleidžiamos raidės, spėjimas, power-up'ai, statusas. Kategorijos: klausimas/patarlė/citata/faktas/istorija.

### Bendra infrastruktūra
- Cyber-Neumorphism dizainas (tamsus + neon), garsai, avatarai, fonai.
- Kalbos LT/EN (+ serveris palaiko en/lt/es/it/pl/de/fr/uk/pt/ar).
- Profilis, Top10, getMyRank, monetos, vardo raginimas.
- **UI mygtukų teksto saugiklis:** `FittedBox(scaleDown)` + `LayoutBuilder` — tekstas niekada nenukerpamas.

---

## 📊 8. KUR BAIGĖM (dabartinė būsena)

- **Naujausias commit keičiasi kas push'ą — netikrink iš čia, tikrink GYVAI:** `git log --oneline -5`.
  Paskutinis ESMINIS turinio darbas — gamta/mystery; po jo eina tik šio perdavimo dokumento commit'ai.
- **Git:** branch sinchronizuotas su `origin` (`0/0`). Yra atsarginė šaka `backup-local-darbas`.
- **Darbo medis švarus**, išskyrus `android/` (senas MINA, sąmoningai nekeliam).

**Gamtos klausimų skaičiai (tikslas ≥150 kiekvienam):**

| Lygis | Dabar | Trūksta iki 150 |
|---|---|---|
| Lengvas | 79 | +71 |
| Vidutinis | 96 | +54 |
| Sunkus | 100 | +50 |
| Ekstremalus | 68 | +82 |

**Mįslių skaičiai (subalansuoti — istorija/faktas/citata atsilieka):**
klausimas 28 · patarlė 15 · citata 13 · faktas 11 · istorija 9.

---

## ⬜ 9. KĄ TĘSTI (planas, eilės tvarka)

1. **🎯 DABARTINIS: prikrauti gamtos lygius iki ≥150** (žr. 8 sk. trūkumus).
   Partijos po ~15 klausimų: nauji faktai → validuoti → `npm run build` → deploy → atsiskaityti.
2. **Subalansuoti mįsles** — pakelti istorija/faktas/citata link klausimas/patarlė lygio.
3. **Ištrinti `gen.js`** prieš galutinį „švarų" commit'ą (tai laikinas įrankis).
4. Vėliau: dienos serija (streak), rewarded ×2 monetos, IAP $2.99 prenumerata, naujos kategorijos.

**Užsirašyta „vėliau":** Firestore TTL `active_games`; rate-limiting `startGame`; nuolatiniai testai;
lengvame yra 1 dublis („Ostrich" 2×) — sutvarkyti progai.

**✅ nested-map bug JAU IŠTAISYTAS — NEKAPSTYK iš naujo.** `game_api.dart` (4 kvietimai), `unlock_api.dart`,
`profile_api.dart` ir `mystery_api.dart` jau naudoja `jsonDecode(jsonEncode(...))` įdėtiems objektams
(patikrinta grep'u). Jei telefonas vis tiek rodo „offline" — priežastis Cloud Run Invoker (allUsers),
tvarko SAVININKAS konsolėje, **NE kodas.** (Kita sesija tai buvo įtarusi kaip „offline" priežastį — buvo neteisinga.)

---

## 🛠️ 10. KONKRETŪS RECEPTAI

### Kaip pridėti gamtos klausimų (su `gen.js`)
`phase2_backend/functions/gen.js` — daugkartinis generatorius. CONFIG: `LEVEL` + `PREFIX`;
`DATA` masyvas `{sub, emoji, enQ, enC, enD[5], enE, ltQ, ltC, ltD[5], ltE}`.
Auto-tikrina: 5 klaidingi variantai, VISI variantai **≤46 simbolių**, LT be ASCII `"`,
EN teisingo atsakymo dublių (lygyje + partijoje). Auto-priskiria ID `<PREFIX><max+1>`.
Įterpia prieš paskutinį `\n];`. **Jei klaida — nieko nerašo** (saugu). Paleidi: `node gen.js`.
- Prefiksai: lengvas `nat_le_`, sunkus `nat_hard_`, ekstremalus `nat_ext_`;
  vidutinis — mišrūs prefiksai (pirma patikrink max ID).

### ⚠️ Turinio taisyklės (kritinės)
- **Kiekvienas variantas (teisingas + 5 klaidingi) VISOSE kalbose ≤46 simbolių** (LT ilgesni už EN
  — tikrink LT atskirai). Detales dėk į `explanation`, ne į variantą. Kitaip UI nukerpa.
- **LT vidinės kabutės — TIK „..." (U+201E/U+201C), NIEKADA ASCII `"`** (lūžta JS string → build error).
- **Sunkumo gradacija:** lengvas=kasdienis (vaikas žino); vidutinis=bendros žinios; sunkus=specifinis
  faktas; ekstremalus=retas/ekspertinis, tikslūs skaičiai. Tas pats gyvūnas kitame lygyje OK tik su KITU faktu.

### Rotacija (kodėl reikia 150)
`pickQuestions` vengia neseniai matytų (`recentByMode[mode]`, serveryje, per vartotoją — išlieka net
išjungus telefoną). `ROTATION_KEEP=150`, `QUESTIONS_PER_GAME=10`. Simuliacija: krepšys 150 → tas pats
klausimas nesikartoja ~14 žaidimų. Tad **150 = tikslas; kodo keisti NEREIKIA**, tik prikrauti.

### Build + deploy
- Serveris: `cd phase2_backend/functions; npm run build` (tsc), tada `cd ..; npx firebase-tools deploy --only "functions:startNatureGame"`.
- Klientas (tik jei keitei Dart UI): `& "C:\Users\minda\flutter\bin\flutter.bat" build apk --release`.

---

## 📁 11. FAILŲ ŽEMĖLAPIS

### Serveris — `phase2_backend/functions/src/` (13 failų)
```
index.ts            — startGame, submitScore, getMyRank, unlockMode, unlockByAd (5 funkcijos)
gameConfig.ts       — ROTATION_KEEP=150, QUESTIONS_PER_GAME=10, MAX_TIME_PER_Q_MS=30000, Level
generateOptions.ts  — universalus variantų generatorius (answer+trap+neighbors)
questionRegistry.ts — matematikos temų registras (pridėti temą = 1 funkcija)
unlockConfig.ts     — lygių užraktų / kainų konstantos
triviaTypes.ts      — gamtos/trivijos tipai (Lang, NatureTopic)
triviaEngine.ts     — pickQuestions, assembleOptions, mergeRecent (rotacija)
natureContent.ts    — GAMTOS KLAUSIMAI (didelis; čia pildom iki 150/lygiui)
natureEmoji.ts      — gamtos emoji pagalbinis
triviaFunctions.ts  — startNatureGame (1 funkcija)
mysteryTypes.ts     — mistikos tipai + helperiai
mysteryContent.ts   — MISTIKOS turinys (klausimas/patarlė/citata/faktas/istorija)
mysteryFunctions.ts — startMystery/revealLetters/guessMystery/mysteryPowerup/getMysteryStatus/resetMystery
```
Laikinas: `phase2_backend/functions/gen.js` (klausimų generatorius — ištrinti prieš galutinį commit).

### Klientas — `math_game/lib/`
```
main.dart · firebase_options.dart
l10n/app_strings.dart (LT/EN tekstai) · language_controller.dart
theme/app_theme.dart
models/  game_models.dart, game_mode.dart, trivia_models.dart, mystery_models.dart, avatar_catalog.dart
providers/ game_provider.dart, nature_game_provider.dart
services/ firebase_service, game_api, profile_api, unlock_api, leaderboard_api, ad_service,
          mystery_api, player_profile_api, sound_service
screens/ home_screen, category_home_screen, level_select_screen, game_screen, result_screen,
         profile_screen, leaderboard_screen, nature_topic_screen, nature_level_screen,
         nature_game_screen, mystery_screen
widgets/ neumorphic_button (FittedBox saugiklis), neumorphic_box, neon_timer_ring, live_points,
         banner_ad_widget, exit_dialog, rank_dialog, unlock_dialog, app_background,
         avatar_collection, sound_toggle_button
assets/ fonts/Orbitron.ttf, sounds/*.wav
tools/gen_sounds.py (garsų generatorius — istoriškai; python nėra šiame PC, jei reikės — node)
```

### Dokumentai (skaityti!)
`PLANAS.md` (A→Z + taisyklės) · `DIZAINAS.md` (sprendimai) · `PLETROS_PLANAS.md` (etapai) ·
`STRATEGIJA.md` (retention/ASO) · `launch/` (Privacy, Data Safety, Store listing).

---

## 🔑 12. SERVERIO KONTRAKTAS + Firestore

**startGame / startNatureGame grąžina:** `{ gameId, level, maxTimeMs, questions:[{action, options[6], answer, ...}] }`
(answer siunčiamas — saugu, taškus skaičiuoja serveris iš laiko).

**submitScore(gameId, clientAnswers[], clientTimesMs[]):**
`{ success, finalScore, correct, isNewRecord, coinsEarned, totalCoins, promptName }`.
Anti-cheat: `sum(clientTimesMs) <= serverioLaikas + tolerance`.

**Firestore:**
- `users/{uid}`: username, coins, unlockedModes[], adProgress{}, **recentByMode{mode:[ids]}** (rotacija), premiumUntil.
- `leaderboard/{uid}_{mode}` (arba per mode): score, username, timestamp. Indeksas `mode ASC + score DESC`.
- `active_games/{gameId}`: uid, mode, level, answers[], actions[](ID rotacijai), createdAt (trinamas submitScore metu).

**Ekonomika:** SCORE = prestižas (geriausias fiksuojasi, Top10). COINS = valiuta (1/teisingą +1 jei <3s,
~15/sesija; nusirašo atrakinant; ~150 = lygis). Atrakinimas amžinas; $2.99 prenumerata = 30 d.

---

## 🧠 13. ATMINTIS (memory) — kur Claude laiko ilgalaikę info

Failai: `C:\Users\minda\.claude\projects\C--Users-minda-OneDrive-Desktop\memory\`
- `MEMORY.md` — indeksas su nuorodomis į temų failus (maži, sufokusuoti).
- Svarbiausi: `project_math_game.md` (šio projekto būsena), `feedback_git_sync_rhythm.md`
  (sinchronizavimo taisyklė), `feedback_coding_rules.md`, `user_role.md`.
- Po reikšmingo darbo — atnaujink atitinkamą memory failą (būsena, skaičiai, pamokos).

---

## ❓ 14. PASITIKRINIMO KLAUSIMAI (ar nauja sesija suprato)

1. Kodėl negalima dirbti dviem Claude sesijom vienu metu?
2. Kodėl `git add -A` čia pavojinga (kas yra šakninis `android/`)?
3. Kur skaičiuojami taškai/monetos — kliente ar serveryje? Kodėl?
4. Kodėl gamtos klausimų variantai turi būti ≤46 simbolių?
5. Kodėl tikslas yra būtent 150 klausimų lygiui (kas tai duoda)?
6. Ką reiškia „401/offline" funkcijoje — App Check ar Cloud Run Invoker? Ką daro savininkas?
7. Kokia geležinė taisyklė dėl kodo rašymo?
8. Kuo skiriasi turinio pakeitimas nuo UI pakeitimo (kada reikia perbudavoti APK)?
9. Kodėl LT kabutės turi būti „..." o ne `"`?
10. Koks dabartinis tikslas ir kur tiksliai baigėm?

Jei šie atsakymai aiškūs iš dokumento — perdavimas pavyko. Pasisveikink lietuviškai, paprastai,
ir paklausk savininko, ką tęsiam (greičiausiai: gamtos klausimų pildymas iki 150). Jokio kodo be „OK".
