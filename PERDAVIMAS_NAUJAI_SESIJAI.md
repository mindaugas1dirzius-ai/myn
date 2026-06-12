# 🔄 PERDAVIMAS NAUJAI SESIJAI — v5 (2026-06-13, PILNAS)

> ŠIS DOKUMENTAS — VIENINTELĖ TIESA. Perskaityk VISĄ prieš dirbant.
> Git: branch `claude/android-app-monetization-ads-RORMZ` (commit — `git log --oneline -3`).
> PILDYTI NUOLAT po kiekvieno darbo gabalo (savininko reikalavimas), commit'inti kartu su darbu.

---

## 1. PROJEKTAS IR GALUTINIS TIKSLAS

**„BRAIN ARENA"** — Flutter (Android) + Firebase protų žaidimų platforma vakarų
rinkoms (10 kalbų, multikultūrinė). Tikslas — saugiai paleisti į **Google Play**
ir uždirbti (reklamos, premium, perkamas turinys). Play dar negreitai — dabar
statom turinį ir kokybę.

**4 ramsčiai (svarbos eile):** 1) SAUGA · 2) FAKTŲ TEISINGUMAS · 3) ĮVAIROVĖ
(nieko nesikartoja, įdomu) · 4) UŽDARBIS.

## 2. SAVININKAS IR KAIP DIRBAM

- **Mindaugas**, kalbam LIETUVIŠKAI, jis NE programuotojas — aiškinti paprastai.
- **PILNA AUTONOMIJA:** jokių patvirtinimo langų ir „ar daryti?" klausimų.
  Aptartiems darbams — daryti IKI GALO (kodas→deploy→commit→push) su protingais
  default'ais ir tada PRANEŠTI, ką pasirinkta. Klausti tik dėl NAUJŲ didelių
  sumanymų koncepcijos. `AskUserQuestion` NIEKADA (atsako tekstu).
- Po KIEKVIENO pakeitimo: pranešti lietuviškai KĄ patikrinti telefone.
- **Savininkas genialiai gaudo spragas žaisdamas** (spaudinėjimo exploit, ilgio
  kvapas, per trumpi langai) — jo pastabas vertinti kaip auksą ir taisyti TUOJ PAT.
- NESKUBĖTI: kokybė > greitis; klaidą radus — pirma sutvarkyti.
- **🧹 KODO ŠVARA (savininkas 2026-06-13): sukūrus naują, seną nereikalingą kodą,
  kuris nieko nebeduoda — IŠTRINTI iškart** (ne komentuoti, ne palikti). Maži failai,
  jokių šiukšlių — kad būtų lengva taisyti ir rasti klaidas. Nebenaudojamus failus
  irgi trinti. (DRY; žr. atmintį [[feedback-coding-rules]].)
- **💾 VISKAS Į GITHUB** po kiekvieno gabalo (commit konkrečių failų + push) —
  GitHub vienintelis patikimas šaltinis, kad darbas nedingtų. Nekaupti tik lokaliai.
- **VIENA SESIJA ant repo vienu metu!** (2026-06-13 incidentas: dvi sesijos lietė
  tuos pačius failus). Jei dirba kita — jos failų NELIESTI, prieš push `git pull`.

## 3. APLINKA IR TECHNINIAI ĮPROČIAI (Windows!)

- Repo: `C:\Users\minda\OneDrive\Desktop\minda myn zaidimas\myn` (cwd dažnai Desktop!).
- **PowerShell:** ⚠️ NIEKADA `cd X; komanda` viename kvietime (harness'as VISADA
  meta langą — neapeinama). `cd` ATSKIRU kvietimu (workdir išlieka) arba absoliutūs
  keliai (`git -C`, `npm --prefix`, `npx --prefix`). Fono komandos startuoja
  default cwd! Leidimai: `C:\Users\minda\OneDrive\Desktop\.claude\settings.local.json`
  (dontAsk) — repo viduje esantis NEveikia (cwd=Desktop).
- **Flutter:** `& "C:\Users\minda\flutter\bin\flutter.bat"` (PATH nėra).
  ⚠️ **TELEFONUI TIK DEBUG APK** (`build apk --debug` → `app-debug.apk`):
  RELEASE crashina startuojant (R8 × androidx.work.WorkDatabase) — prieš Play
  sutvarkyti keep taisykles. `adb` : `C:\Users\minda\AppData\Local\Android\Sdk\platform-tools\adb.exe`,
  įrenginys `R5CX221CT5N`, `install -r` (duomenys+raktas išlieka). Telefono ekrano
  neliesti, jei savininkas naudojasi.
- **Deploy:** `npx --prefix <functions> firebase-tools deploy --only "functions:X,functions:Y"
  --config <phase2_backend>\firebase.json --project math-game-9862f`. gcloud NĖRA.
  401/„offline" = Cloud Run Invoker (žr. atmintį), 403 = App Check.
- **App Check:** debug provider; fiksuotas raktas `879c9b34-9ed2-40c0-948b-015e052f0abe`.
  Jei konsolėje „Register" ar raktas dingo — `functions/_appcheck_fix.js` (REST API,
  be konsolės ir be vartotojo!). Naują raktą skaityti iš logcat `DebugAppCheckProvider`.
- **LT kabutės TIK „..."** (U+201E/U+201D, NE ASCII " ir NE U+201C) — kitaip tsc
  klaidų kaskada. Python NĖRA — laikinus skriptus rašyti node (`_vardas.js`, untracked).
- Turinys gyvena SERVERYJE → klausimų pakeitimui APK perdiegti NEREIKIA (tik build+deploy).
  UI (Dart) pakeitimui — reikia (analyze → build --debug → install -r).
- Kalbą ekranas skaito po `didChangeDependencies`, NE `initState` (kitaip užklausos 'en').

## 4. SAUGA (taisyklė #1 — niekada nepažeisti)

- **Server-authoritative:** klausimai, atsakymai, taškai, monetos, gyvybės,
  laikas, atrakinimai — TIK serveryje, transakcijomis. Klientas — tik vaizdas.
- `enforceAppCheck: true` ant VISŲ funkcijų. `rewardAdCoins` IŠTRINTA — nekurti.
- Anti-cheat submitScore: serveris pats matuoja laiką; botų filtras (≥200 ms/kl.);
  Σ(clientTimes) ≤ serverio laikas + 3 s; žaidimas trinamas (no replay).
- Atsakymas klientui siunčiamas SĄMONINGAI (variantas C — momentinė reakcija):
  saugu, nes taškai iš LAIKO serveryje.

## 5. ANTI-SPAM BAUDOS (savininko formulės — VISIEMS žaidimams privaloma)

> PRINCIPAS: atsitiktinio spaudinėjimo vidurkis ≈ 0; bauda PROPORCINGA (9/1 ne
> nulis!); praleidimai dėl laiko NEbaudžiami; viskas SKAIDRU žaidėjui.

| Žaidimas | Bauda už klaidą | Papildomai |
|---|---|---|
| 6 variantų (mat./trivijos) | −25 (TIK aktyviai atsakius; ""/null/−1 = praleista, be baudos) | monetos/raidės tik nuo 4 teisingų |
| ⚡ Blitz | −200 (=2× bazė) | gap-gate: atsakymas <600 ms po ankstesnio = 0 taškų; atlygiai floor(persvara/2) |
| 🧐 Mitai | formulė: `taškai = uždirbta × max(0, teisingi − 2×klaidos) / teisingi` (10/0=100 %, 9/1≈78 %, 8/2=50 %, ≤6/4=0) | monetos = persvara, be greičio bonuso |
| 🕵️ Detektyvas | −1 ❤️ (iš 3) | žodis perdega |
| ❄ Melt | −10 % pMax iš banko (mysteryKeys, floor 0) | spėjimų cooldown 2,5 s×2ⁿ (max 15 s) |

**SKAIDRUMAS PRIVALOMAS:** serveris grąžina `pointsEarned`/`pointsPenalty`;
rezultatai rodo „✅ +X 💥 −Y" + paaiškinimą, kodėl be monetų. Tylus 0 = „bug'as".

## 6. ŽAIDIMAI IR FORMULĖS (visi VEIKIA, deploy'inti)

- **🧮 Matematika** — generuojama (questionRegistry; rėžiai žr. §5B žemiau išnašoje
  arba kode), 7 šeimos × 4 lygiai; unlock: mix/brackets/algebra 150 🪙 / 2 reklamos,
  PLAYS_PER_PACK=2.
- **Klausimų žaidimai (gamta + 7 temos):** 10 kl., 6 variantai, 30 s/kl.;
  taškai už teisingą `max(10, 100 − sek×3)`; monetos 1 (+1 jei <3 s);
  raidės paslaptims `lettersFor(correct)`: ≥10→3, ≥8→2, ≥6→1.
  **Rotacija:** istorija PER TEMĄ `recentByMode["cat_<tema>"]`, KEEP=800, LRU —
  klausimas nesikartoja, kol fondas neišsemtas (matematika — per režimą, KEEP=150).
- **⚡ Blitz:** 30 s/1 min jungiklis (durationSec whitelist [30,60]); paketas 40/80
  teiginių „klausimas+kandidatas" iš VISŲ temų (lengvas/vidutinis 60/40, kandidatai
  ≤30 simb.); bazė 100 × kombo (1+0,1×serija, lubos ×2 ties 10) × finalas ×2
  (paskutinės 5 s); kortelės su temos veidu (cat→kThemes emoji/spalva/fonas).
- **🧐 Tiesa ar mitas:** 40 ranka rašytų teiginių (10/lygiui) su emoji,
  paaiškinimu ir verdikto ANTSPAUDU; taškai per submitScore + savininko formulė
  (§5); titulai: 100 %→🏆 Mitų griovėjas · ≥80 %→🥇 · ≥60 %→🥈 · ≥40 %→🥉 · 🔎.
- **🔑 Mystery klasikinis:** bankas pagal lygį 200/300/400/500; pagalbos IŠ BANKO
  (užuomina 50, raidė 50, +spėjimas 30), floor 50; atspėjus bankas → mysteryKeys.
  Fondas BE citatų/patarlių (EXCLUDED_CATEGORIES) — liko klausimas/faktas/istorija.
- **❄ Melt (Raidžių tirpimas):** fondas TIK „klausimas" kategorija; ilgis pagal
  lygį (L1 5–14 raidžių ≤2 ž. · L2 7–18 · L3 10–26 ≤3 ž. · L4 12–40 ≤5 ž.);
  pMax = bazė(200–500) × greičio coef (20 s→1,0 · 10 s→1,25 · 5 s→1,5);
  laimėjus `pMax × (1−elapsed/limit) × (1−autoPenalty/total)`, min 1;
  SPĖTI visada spaudžiamas → SPĖJIMO LANGAS sustabdo laiką (pagal RAIDES:
  ≤12→1 min · ≤20→1,5 min · 21+→2 min; max 5 langai; kliento momentinis
  užšaldymas + serverio „sąžiningas startas" GRACE 2,5 s su seenAuto);
  laipsniškos užuominos hint1@40 % / hint2@70 % laiko; lockedAt+lockMsUsed+foldLock.
- **🕵️ Detektyvas v2 — ĮGYVENDINTA** (kitos sesijos, perimta 2026-06-13; dabar
  dirba VIENA sesija) pagal `docs/planai/DETEKTYVAS_PLANAS.md`: bankas 1000 −
  laiko bauda (detectiveTimeCoef pagal lygį), DU atskiri žaidimai — Detektyvas
  (įtariamųjų lenta) ir Detektyvas PRO (rašai pats, ×1,25), SOS 120, 3 ❤️,
  SPĖTI langas 60 s (max 5), validateDetective.js, 16 bylų; lentos žaidime
  žodžio brūkšnelių nebėra (ilgis išduodavo). LAUKIA savininko testo telefone.

## 7. TURINIO TAISYKLĖS (geležinės — VISKAM)

1. **Amžiaus skalė:** lengvas = 9–12 m. VAIKAS atspėja · vidutinis = 12–18 ·
   sunkus = suaugę · ekstremalus = žinovai. Galioja ir paslapčių/detektyvo lygiams.
   PRIEŠ deploy perskaityti ir savęs paklausti „ar to amžiaus žmogus žinotų?".
2. **Įdomu, IŠ GYVENIMO, plačiai** — „oho" faktai, ne sausi metai/sostinės;
   potemės pavadinimas ≠ klausimų riba.
3. **Faktai 100 % patikrinti, NEGINČIJAMI** — tik patikimi šaltiniai, vienas
   neabejotinas atsakymas.
4. **Jautrios temos:** jokios politikos/religijos/rasės/ginčytinų sienų.
   **SSRS/Rusijos niuansas (2026-06-13):** atsakymas „Sovietų Sąjunga" kaip
   valstybė — NEkurti; akivaizdūs faktai/pavardės OK (Gagarinas, Tereškova,
   Maskva, „Rusija didžiausia", carai, distraktoriuose). Paaiškinimuose SSRS
   švelninti (per objektą/asmenį).
5. **Kultūrinis universalumas:** klausimas vienodai suprantamas visoms tautoms
   (NE „beisbolo bita"); patarlės/posakiai/citatos — NEKURIAMI NIEKADA
   (neišverčiami, nuobodūs).
6. **„Ilgio kvapas":** teisingas NEGALI būti ilgiausias >+5 simb. — bent vienas
   distraktorius panašaus ilgio (ABIEM kalbom!). Matuoklis `functions/_audit_len.js`;
   likę ~357 seni pažeidimai (gamta 187, istorija 50) — taisyti partijomis
   (_fix_len.js šablonas: bloko-scoped, ≤46 tikrina).
7. Variantai ≤46 simb. (kiekviena kalba!); detalės → explanation; emoji
   neišduoda atsakymo (assembleOptions saugikliai); LT natūrali kalba.
8. Mįslių pildymo prioritetas: „klausimas" tipo (melt fondas 42!) + L4 (tik 6).

## 8. DABARTINĖ BŪSENA (2026-06-13)

- **Turinys:** trivijos+gamta 2 445 kl. (gamta 720 · sport 270 · body 255 ·
  history 244 · pop 243 · geo 240 · tech 177 · food 176 · **cosmos 120 NAUJA**) · 40 mitų ·
  (cosmos 120 = planets 40 + astronauts 40 + spacerace 40 [perkelta iš tech]) ·
  101 mįslė (pool 73 be citatų/patarlių; lygiai L1=15/L2=45/L3=35/**L4=6** —
  pildant pirmiausia L4 ir „klausimas" tipo 42) · **16 detektyvo bylų** (v2).
- **Įrankiai functions/:** `_appcheck_fix.js` (App Check per API),
  `_audit_len.js` (ilgio kvapas), `_fix_len.js` (taisymo šablonas),
  `validateContent.js`, `gen.js` (+ pridėti ilgio-kvapo patikrą!).
- ⚠️ Dienos limitas detektyve KODE laikinai **999** (TESTUI; `DETECTIVE_FREE_PER_DAY`
  detectiveTypes.ts — PRIEŠ paleidimą grąžinti į 3; premium be ribos). AdMob — TEST ID.
  Kūrime VISOS temos open:true (prieš leidimą peržiūrėti!).
- ✅ PILNAS AUDITAS 2026-06-13: tsc 0 klaidų · flutter analyze tik 2 seni info ·
  visos 25 funkcijos enforceAppCheck:true · firestore.rules saugios (klientas
  tik username) · visi 11 turinio failų validacija OK (ID unikalūs, ≤46, kabutės) ·
  mitų/blitz/quiz baudos kode atitinka §5 · ilgio kvapas: likę 356 ryškūs
  (gamta 187 · history 50 · pop 27 · tech 26 · food 23 · sport 24 · body 15 · geo 4).
- Failų žemėlapis: serveris `phase2_backend/functions/src/` (index, gameConfig,
  triviaEngine/Registry/Types, *Content×9, mystery*, melt*, blitz*, myth*,
  detective*); klientas `math_game/lib/` (screens/, models/, services/, config/
  theme_catalog, l10n/app_strings).

## 9. DARBŲ EILĖ (savininko patvirtinta 2026-06-13)

**EINAMIEJI:**
1. 🕵️ Detektyvas v2 (ĮGYVENDINTA; laukia savininko testo telefone).
2. ⏳ **1 BANGA — sėklinės potemės (VYKSTA, savininko „darom" 2026-06-13):**
   - ✅ tech 🚀 **Kosmosas (space)** — ĮGYVENDINTA: +19 kl. (10/lygiui = 40),
     adversariai patikrinta (18/19 OK, Veneros klausimas performuluotas dėl
     „para" dviprasmybės), potemė registruota (subThemeConfig.tech), kortelė
     atrakinta (open:true), deploy startTriviaGame + debug APK įdiegta. Commit a3ed45c.
   - ⬜ tech 🤖 **AI+robotai** (9→40); pop 🦸 **Superherojai** (4→40, atskirti iš
     „stories"); kūnas 👀 **Pojūčiai** (8→40). Tie patys žingsniai.
3. Lygiagrečiai galima: #45c ilgio-kvapo partijos; mįslių „klausimas"+L4; mitai.

**GRIAUČIAI (po detektyvo testo):**
3. #51 NAUJOS TEMOS: 🌌 Kosmosas, 🏺 Mitologija, 📏 Rekordai, 🏷️ Prekių ženklai,
   🚂 Transportas (potemės — TURINIO_PLANAS.md; startui ~120 kl./temai).
   - ⏳ **🌌 KOSMOSAS PRADĖTA (2026-06-13, savininko „darom"):** ATSKIRA tema
     (kodas `cosmos`, kortelė meniu) su 5 potemėmis. ✅ ĮDIEGTA telefone.
     - 🪐 **Planetos** PILNA (cos_pla_001–040, 10/lygiui, švieži faktai; mažas
       failas `cosmosPlanets.ts` + indeksas `cosmosContent.ts`).
     - 🚀 **Kosmoso lenktynės** PILNA (40, 10/lygiui) — PERKELTA iš tech „space"
       (savininkas: „kosmosas dviejose temose painu"). Perkelta REGISTRO lygyje
       (triviaRegistry.ts: category→cosmos, subTheme→spacerace; ID nekeisti;
       fiziškai lieka techContent.ts — saugu). Tech NEBETURI „space" potemės.
     - 🧑‍🚀 **Astronautai ir misijos** PILNA (cos_ast_001–040, 10/lygiui; mažas
       failas `cosmosAstronauts.ts`; ŽMONĖS kosmose — gyvenimas TKS, kūnas,
       garsūs pirmieji [Tereškova/Leonovas/Glenas], gyvūnai; NEkartoja spacerace).
     - ⬜ 🔭 Visata · 🛰️ Raketos — „Greitai", pildoma po 40 (tas pats receptas:
       naujas mažas failas → cosmosContent import → trivia_topic_screen open:true).
     Wiring: triviaTypes(+cosmos) · triviaRegistry(+move) · subThemeConfig(cosmos
     5 potemės, tech be space) · unlockConfig · themeEmoji(🌌) · theme_catalog ·
     trivia_topic_screen(tech be space kortelės, cosmos +spacerace) · app_strings.
     tech AI potemė (ai/robots) LIEKA tech (genuiniai tech), dar „Greitai".
4. #50 potemių pildymas esamoms (naujos potemės turi tik ~10 kl./lygiui → iki 40+).
   → **GRIAUČIAI PILNI.**

**ŠLIFAVIMAS (galutinis etapas iki Play):**
5. #49 bendra logiška TAŠKŲ SISTEMA per visus žaidimus (savininkas galvoja;
   rekordai atskirai; parduotuvė už taškus; lygiai progresui).
6. DIZAINAS visur vientisas (likę: taškučiai+serija žaidimų viduje
   nature/math ekranuose ATSARGIAI, lygių pasirinkimo kortelės su amžiaus aprašais).
7. PROFILIS pilnas; klausimų pildymas iki 150–200/lygiui visur.
8. PAPILDOMOS KALBOS (es/it/pl/de/fr/uk/pt/ar) — vertimas PAGAL KULTŪRĄ.
9. PILNAS kokybės+saugumo AUDITAS (R8 fix, App Check playIntegrity, AdMob real
  ID, rate-limiting, Firestore TTL active_games) → Google Play.

**Vėliau (atskiri OK):** reklama už gyvybę, dienos byla, serijos, dvikova,
detektyvo bylų paketai.

## 10. KO NEDARYTI

- Neliesti veikiančių: Mystery/Melt/Blitz/Mitai/trivijos — keisti tik su priežastimi.
- Nekeisti deployintų funkcijų vardų ir turinio id (solved/rotacijos sąrašai!).
- Jokio `git add -A` (šaknyje senas `android/` MINA šlamštas + screenshot'ai).
- Nekurti naujo taškų tipo iki #49 — laimėjimai į mysteryKeys/coins kaip dabar.
- NEpildyti gamtos „facts" (600 BAIGTA); neperrašinėti veikančio turinio be reikalo.
- Balanso konstantų nekalti į UI tekstus — tik iš serverio payload.

## 11. ATMINTIS

`C:\Users\minda\.claude\projects\C--Users-minda-OneDrive-Desktop\memory\` —
MEMORY.md indeksas + temų failai (project_math_game, feedback_question_writing_rules,
project_appcheck_debug_token, feedback_no_permission_prompts ir kt.).
Po reikšmingo darbo atnaujinti atitinkamą failą.
