# 🔄 PERDAVIMAS NAUJAI SESIJAI — v6 (2026-06-13, PILNAS)

> **ŠIS DOKUMENTAS — VIENINTELĖ TIESA. Perskaityk VISĄ prieš dirbant.**
> Čia surašyta VISKAS: kaip dirbam, kaip kuriam klausimus, kaip tikrinam kokybę,
> kokios formulės, kas padaryta, kas liko ir KAIP tai daryti (receptai).
> Git: branch `claude/android-app-monetization-ads-RORMZ` (naujausią commit — `git log --oneline -3`).
> **PILDYK ŠĮ DOKUMENTĄ NUOLAT** po kiekvieno darbo gabalo ir commit'ink kartu — savininko reikalavimas.

---

## 🚀 NUO KO PRADĖTI (naujai sesijai — PERSKAITYK PIRMA)

- **Naujausias commit:** `669c5cb`, branch `claude/android-app-monetization-ads-RORMZ`. Prieš dirbant: `git fetch` + tikrink ahead/behind (viena sesija ant repo!).
- **📘 KLAUSIMŲ KŪRIMO METODIKA — atskiras PILNAS dokumentas: `KLAUSIMU_KURIMO_METODIKA.md`** (kaip/kokius klausimus ieškom pagal potemes, šaltiniai, reikalavimai, formatas, emoji, LT spąstai, QC bangos, recipe'ai, checklist). **SKAITYK jį prieš rašydamas bet kokią partiją.**
- **KAS PADARYTA (turinys):** ✅ 2 BANGA (visos naujos temos) BAIGTA — 🏷️ brands + 🚂 transport (po 160). ✅ 3 BANGA PRADĖTA — 🌿 Gamta: 🧬 Supergalios + 🧠 Gyvūnų protas (po 40 = 10/lygiui).
- **KAS TOLIAU (eilės tvarka):**
  1. **Daugiau 3 bangos potemių** (starteris po 10/lygiui=40). PIRMA pasiūlyk įdomias PLAČIAS potemes (METODIKA §3) → savininkas pasirenka → rašyk. Recipe: METODIKA §14 (⚠️ Gamta = §14B, skiriasi!). Kandidatai: §11 B + TURINIO_PLANAS „3 BANGA".
  2. **Pildyti esamas potemes iki 150/lygiui** (=600 potemei) — galutinis kiekio tikslas.
  3. **„⚠️ Pranešti apie klaidą" mygtukas** (BŪTINAS feature, §11 C) — kai savininkas pasakys daryti.
  4. Šlifavimas iki Google Play (§11 C).
- **KAIP DIRBTI:** pilna autonomija aptartiems darbams; **NEAIŠKU (ypač dizainas/išdėstymas) → KLAUSK, nespėliok** (§1). Klausimus **Opus rašo PATS** (ne Sonnet — METODIKA §13). Ciklas: parašai → patikra (tsc+validacija+ilgio kvapas) → **2 QC bangos** (faktai+stilius) → pataisos → deploy → APK (jei keitei Dart) → įdiegti → commit+push → **pildyk šį dokumentą** → pranešk savininkui LT, ką tikrinti.
- **⏳ LAUKIA SAVININKO SPRENDIMO:** ar vėliau suvienodinti Gamtos kodą su kitomis temomis (`NatureTopic`+`startNatureGame` paveldas; žaidėjui jokio skirtumo; neskubu).

---

## 0. SANTRAUKA (30 sekundžių)

- **„Minalect Arena"** (PAVADINIMAS PAKEISTAS 2026-06-13 iš „BRAIN ARENA"; savininko valia) — Flutter (Android) + Firebase protų žaidimų platforma vakarų rinkoms (10 kalbų), kelias į **Google Play** + uždarbį (reklamos, premium). **Logotipas:** savininko Canva dizainas (auksinės smegenys + karūna + laurai), `math_game/assets/images/logo.png` — fonas pašalintas (permatomas, per Jimp), rodomas pradinio ekrano viršuje vietoj teksto pavadinimo. Canva design_id `DAHMd4xFhd0`.
- **4 ramsčiai (svarbos eile): 1) SAUGA · 2) FAKTŲ TEISINGUMAS · 3) ĮVAIROVĖ (nieko nesikartoja, įdomu) · 4) UŽDARBIS.**
- Server-authoritative; turinys serveryje (Cloud Functions TS), klientas (Flutter) tik rodo.
- Dabar etapas: **statom turinį + temas** (Google Play dar negreitai, savininkas pasakys kada).
- Šią sesiją baigtos 2 naujos temos (🌌 Kosmosas 200 kl., 🏺 Mitologija 160 kl.) + pradėti 📏 Rekordai.

---

## 1. SAVININKAS IR KAIP SU JUO DIRBAM (svarbiausia — perskaityk atidžiai)

- **Mindaugas**, kalbam **LIETUVIŠKAI**, jis **NE programuotojas** — aiškinti PAPRASTAI, be žargono, struktūruotai (emoji, „šviesoforas" ✅⚠️🔴, lentelės).
- **🤖 PILNA AUTONOMIJA.** Jokių patvirtinimo langų ir „ar daryti?" klausimų. Aptartiems/užsakytiems darbams — imk protingą default'ą ir daryk IKI GALO (kodas → patikra → deploy → APK → commit → push), TADA pranešk, ką pasirinkai ir kaip pakeisti, jei nepatiks. `AskUserQuestion` — **NIEKADA** (jis atsako tekstu). Klausti tik dėl VISIŠKAI naujo didelio sumanymo koncepcijos.
- **❓ BET: NEAIŠKU → KLAUSK, NESPĖLIOK (savininkas 2026-06-13, supyko dėl 5× logotipo perdarymo):** „kai ką nors pasiūlau, jei NE 100% aišku — KLAUSK, o nepulk daryti; daug laiko sugaištam perdarinėdami." Autonomija ≠ spėlioti. **Dviprasmiškiems (ypač DIZAINO/IŠDĖSTYMO/subjektyviems — vieta „šone ar vidury", dydis, spalva, kuris variantas) — pirma TRUMPAS patikslinantis klausimas TEKSTU, tada daryk.** Geriau 1 klausimas nei 5 perdarymai. Po UI keitimo VISADA pats pasitikrink telefono ekraną (`adb exec-out screencap`). Žr. [[feedback_no_popup_questions]].
- **🐛 Savininkas genialiai gaudo spragas žaisdamas** (spaudinėjimo exploit'ai, „ilgio kvapas", per trumpi langai, nerangi kalba). **Jo pastabos = AUKSAS.** Radęs — taisyk TUOJ PAT ir paversk amžina taisykle (užrašyk čia + atmintyje).
- **🧹 KODO ŠVARA:** sukūrus naują, seną nereikalingą kodą (kuris nieko nebeduoda ar dubliuoja) — **IŠTRINK IŠKART** (ne komentuok, ne palik „dėl visa ko"). Maži, sufokusuoti failai — kad būtų lengva taisyti ir rasti klaidas. Nebenaudojamus failus irgi trink. (DRY.)
- **💾 VISKAS Į GITHUB** po kiekvieno gabalo (commit konkrečių failų + push). GitHub — vienintelis patikimas šaltinis, kad darbas nedingtų. Nekaupk tik lokaliai.
- **📣 PRANEŠK PO KIEKVIENO PAKEITIMO** lietuviškai: ką padarei ir KĄ TIKSLIAI patikrinti telefone.
- **🐢 NESKUBĖK:** kokybė > greitis. Klaidą radus — pirma sutvark, tik tada toliau. Nešok prie kitos partijos, kol esama netvarkinga.
- **👤 VIENA SESIJA ant repo vienu metu!** (2026-06-13 buvo incidentas — dvi sesijos lietė tuos pačius failus.) Prieš push visada `git fetch` + tikrink ahead/behind; jei behind — pirma `pull/merge`.
- **🔄 NAUJOS SESIJOS sprendimą priima CLAUDE (savininkas 2026-06-13):** savininkas NENORI pats sekti — Claude PATS pasako, kada verta nauja sesija. TIK švariame taške (nieko nebaigto; deploy+commit+perdavimas atnaujinti) IR kai kontekstas ~90%+ ARBA atsakymai lėtėja ARBA reikia taupyti plano limitus. Saugumui nebūtina (viskas perdavime+atmintyje+GitHub). NIEKADA vidury darbo ar kai sukasi workflow.
- **Geležinė taisyklė:** naujiems DIDELIEMS sumanymams — pirma planas + sauga, tada kodas. Aptartiems — autonomija iki galo.

---

## 2. KAIP KURIAM KLAUSIMUS (metodika — privaloma kiekvienai partijai)

> **🟥 AUKSO TAISYKLĖ (savininkas kartoja NUOLAT — niekada nepažeisti):**
> 1. **TOBULAS vertimas** — klausimas vienodai aiškus ir natūralus LT IR EN kalbėtojams; JOKIŲ stiliaus ar kultūrinių nesusipratimų (perfrazuok pagal kultūrą, ne pažodžiui).
> 2. **JOKIO jautraus/nešvaraus turinio:** jokios politikos, religijos/tikėjimo, rasės, tautinių/sienų ginčų, **narkotikų, alkoholio, vaistų-kaip-svaigalų**, smurto, sekso, keiksmų, nešvarių ar dviprasmiškų užuominų. Nieko, kas KĄ NORS įžeistų bet kurioje šalyje.
> 3. **GARANTUOTAS šaltinis:** tik patikimi, neginčijami faktai (enciklopedijos, oficialios institucijos). Neaiškus/nepatvirtintas/„gandų" faktas — NERAŠOMAS. Abejoji — meti.
> 4. **NAUJAUSIA info — turinys negali būti senas:** „aukščiausias/brangiausias/greičiausias/priklauso/čempionas" ir pan. web-PATIKRINTI, ar dar galioja (pvz. Unilever ledai 2025-12 atskirti). Rinktis STABILIUS faktus arba tikrinti naujausią informaciją kiekvienai partijai.
> 4b. **GRIEŽTA ATRANKOS TAISYKLĖ (savininkas 2026-06-13):** klausimai apie KINTAMUS skaičius privalo būti arba su KONTEKSTU („pagal 2024 m.", „vienas didžiausių"), arba remtis FUNDAMENTALIAIS, nekintamais faktais. Gali keistis ir negali būti įrėmintas → NENAUDOTI.
> Ši taisyklė tikrinama abiejose QC bangose (§3) IR mano kritinėje peržiūroje prieš deploy.

**Procesas:** idėja (galvok PLAČIAI — potemės pavadinimas ≠ riba; ieškok „oho" faktų iš gyvenimo) → faktą patikrini patikimuose šaltiniuose → sukomplektuoji (1 teisingas + 5 distraktoriai + paaiškinimas KODĖL + emoji + `sourceVerified` + `subTheme` + `level`) → LT+EN iškart (natūraliai, NE pažodžiui) → validacija → faktų patikra → stiliaus patikra → deploy.

**🧰 DRAFT'INIMO METODAS (savininko valia 2026-06-13):** klausimų JUODRAŠČIUS generuoja **Sonnet 4.6 per `Workflow`** (po 1 agentą potemei = 4 agentai temai, su web paieška ir VISAIS šio §2 reikalavimais prompto), o **Opus (pagrindinė sesija) TIK tikrina, taiso, daro 2 QC bangas ir deploy'ina** — taip taupom Opus/plano limitus. ⚠️ Brands partija (2026-06-13) parašyta PAČIO Opus, nes ankstesnis perdavimas teigė, kad Sonnet workflow pakibo; PATIKRINTA — nauja sesija workflow'us sukioja be pakibimo (36 agentų QC suveikė), tad NUO 🚂 Transporto grąžinam Sonnet-juodraščių metodą. Jei Sonnet workflow vis dėlto pakibtų — krentam atgal į Opus rašymą.

**🎚️ Amžiaus skalė (GELEŽINĖ — savininkui kritiška):**
| Lygis | Kas atspėtų |
|---|---|
| 🟢 lengvas | 9–12 m. **vaikas** |
| 🟡 vidutinis | 12–18 m. paauglys |
| 🔴 sunkus | suaugęs, kuris domisi |
| 🔥 ekstremalus | tos srities **žinovas** |
Sunkumą lemia **fakto retumas, NE gudri formuluotė.** Prieš deploy savęs paklausk: „ar to amžiaus žmogus tai žinotų?"

**📚 Šaltiniai:** tik profesionalūs/patikimi (enciklopedijos, NASA, mokslo institucijos, oficialios federacijos, Gineso). ❌ jokių FB/blogų. **Vienas NEGINČIJAMAS atsakymas** — aktyviai ieškok alternatyvių teisingų atsakymų ir užkirsk juos (Jeopardy „pinning"). Be greitai senstančio turinio (dabartiniai čempionai/nauji filmai). Abejoji — nerašyk.

**✨ Stiliaus gido esmė** (pilnas — `KLAUSIMU_STILIAUS_GIDAS.md`): „įmanoma išprotauti"; „oho" faktas pačiame klausime; keisk klausimo TAIKINĮ (ne visada „Kuris…?"); kabliukas į priekį, ne klausiamasis žodis; distraktoriai = tikri žmonių klaidingi įsitikinimai, **vienodo ilgio** kaip teisingas; po atsakymo 1 eilutės fun-fact paaiškinimas; vengti neiginių („kuris NE…").

**🚫 Techniniai saugikliai (PRIVALOMI):**
- **„Ilgio kvapas":** teisingas atsakymas NEGALI būti ilgiausias daugiau nei +5 simb. — bent vienas distraktorius panašaus ilgio (tikrink **ABIEM kalbom**). Įrankis `functions/_audit_len.js`.
- Visi variantai **≤46 simb.** kiekviena kalba; detales dėk į `explanation`, ne į variantą.
- **Jokio atsakymo klausime;** emoji neišduoda atsakymo.
- **Jokių dublikatų** lygyje IR tarp lygių (tas pats gyvūnas kitame lygyje OK tik su KITU faktu).
- **Kultūrinis universalumas** — vienodai suprantama visoms tautoms (NE „beisbolo bita"); **patarlės/citatos/posakiai — NEKURIAMI NIEKADA** (neišverčiami).
- **Jautru:** jokios politikos/religijos/rasės/ginčytinų sienų. **SSRS/Rusijos niuansas:** atsakymas „Sovietų Sąjunga" kaip valstybė — NE; faktai/pavardės OK (Gagarinas, Tereškova, Maskva, „Rusija didžiausia", carai, distraktoriuose); paaiškinimuose SSRS švelninti per objektą/asmenį.
- **LT kabutės TIK „..."** (U+201E atidaro, U+201D uždaro — NE ASCII `"`, NE U+201C!). ASCII `"` string'o viduje nutraukia JS string → tsc klaidų kaskada. **Geriausia — venk vidinių kabučių LT tekste visai** (perfrazuok).
- **LT — NATŪRALI kalba, ne pažodinis vertimas** (žr. §3 stiliaus patikrą).

---

## 3. DVI KOKYBĖS BANGOS — FAKTAI ir KALBA (privaloma KIEKVIENAI naujai partijai)

Po kiekvienos naujos klausimų partijos PALEISK DU atskirus adversarinius `Workflow` patikrinimus (ultracode režimu — token'ų netaupom dėl kokybės):

**🔬 1) FAKTŲ PATIKRA** — 2 nepriklausomi skeptikai/klausimą su web paieška, nusiteikę PANEIGTI. Tikrina: ar faktas teisingas; ar atsakymas VIENINTELIS gintinas (ar koks distraktorius irgi tinka); ar nepasenęs/nejautrus. Pagavo realių dalykų: Horas/Ra (abu sakalagalviai), sirenos≈undinės, „<30s" loginiai bound'ai, ghoul geria kraują. Pažymėtus — taisyk, tada deploy.

**🔤 2) LT/EN STILIAUS PATIKRA** (savininkas 2026-06-13: „lietuviškai taip nesirašo") — `Workflow` šablonas „style-review-new-content": 1 redaktoriaus agentas/failui skaito LT+EN ir žymi nerangias/pažodines/gramatikos klaidas su natūraliais rewrite'ais.
**Dažni LT spąstai (šią sesiją ištaisyta ~58):**
- pažodinis EN word-order calque („buvo vos apie kokio ūgio" → „Kokio ūgio buvo…");
- **giminės nesutapimas** su moteriškos g. daiktavardžiu („Kuris pabaisa/dvasia" → „Kuri", „Koks … dvasia" → „Kokia");
- kalkės: „nešioja žinutes" → „perduoda žinias", „žvilgsnis akmenino" → „paversdavo akmeniu", „tris šakes turintį ietį" → „trišakę ietį";
- padalyvio dangling: „Pagavęs … jis" → „Pagavus … jis";
- EN gramatika/typo: „How is much" → „How is most".

> Receptas patikrai: žr. ankstesnių `Workflow` skriptus sesijos kataloge (verify-*-facts, style-review-new-content) — kopijuok ir keisk klausimų masyvą.

---

## 4. APLINKA IR TECHNINIAI ĮPROČIAI (Windows!)

- Repo: `C:\Users\minda\OneDrive\Desktop\minda myn zaidimas\myn` (⚠️ default cwd dažnai = `…\Desktop`!).
- **PowerShell spąstas:** NIEKADA `cd X; komanda` viename kvietime (harness'as VISADA meta langą — neapeinama). `cd`/`Set-Location` ATSKIRU kvietimu (workdir išlieka tarp kvietimų) ARBA absoliutūs keliai (`git -C`, `npm --prefix`, `npx --prefix`). ⚠️ Fono/`build` komandos gali startuoti default cwd — prieš `flutter build` būtinai `Set-Location` į `math_game`.
- Leidimai: `C:\Users\minda\OneDrive\Desktop\.claude\settings.local.json` (`dontAsk`) — repo viduje esantis NEveikia (nes cwd=Desktop).
- **Flutter:** `& "C:\Users\minda\flutter\bin\flutter.bat"` (PATH nėra). **TELEFONUI TIK DEBUG APK:** `build apk --debug` → `…\math_game\build\app\outputs\flutter-apk\app-debug.apk`. ⚠️ RELEASE APK CRASHINA startuojant (R8 × androidx.work.WorkDatabase) — prieš Play sutvarkyti keep taisykles/minify.
- **adb:** `C:\Users\minda\AppData\Local\Android\Sdk\platform-tools\adb.exe`, įrenginys `R5CX221CT5N`, `install -r` (duomenys + App Check raktas išlieka). Telefono ekrano NELIESTI, jei savininkas naudojasi. Telefonas kartais atsijungia — patikrink `adb devices`.
- **Deploy:** `npx --prefix "<…>\functions" firebase-tools deploy --only "functions:X" --config "<…>\phase2_backend\firebase.json" --project math-game-9862f`. gcloud NĖRA. Projektas `math-game-9862f`, regionas `europe-west1`.
- **App Check:** debug provider; fiksuotas raktas `879c9b34-9ed2-40c0-948b-015e052f0abe`. Jei konsolė „Register"/raktas dingo — `functions/_appcheck_fix.js` (REST API, be konsolės, be vartotojo!). 401/„offline" = Cloud Run Invoker; 403 = App Check.
- **Python NĖRA** — laikinus skriptus rašyk node (`_vardas.js`, untracked). Node regex su `\` per `node -e` lūžta Windows'e — rašyk `.js` failą.
- **Turinys gyvena SERVERYJE** → klausimų teksto pakeitimui APK perdiegti NEREIKIA (tik `npm run build` + deploy `startTriviaGame`). UI (Dart) pakeitimui (kortelė, spalva, ekranas) — REIKIA APK (analyze → build --debug → install -r).
- Ekrano kalbą skaityk po `didChangeDependencies`, NE `initState` (kitaip užklausa išeina 'en').

---

## 5. SAUGA (taisyklė #1 — niekada nepažeisti)

- **Server-authoritative:** klausimai, atsakymai, taškai, monetos, gyvybės, laikas, atrakinimai, diplomai/privilegijos — TIK serveryje, transakcijomis. Klientas — tik vaizdas.
- `enforceAppCheck: true` ant VISŲ funkcijų (patikrinta: 25/25). `rewardAdCoins` IŠTRINTA — nekurti.
- `firestore.rules`: klientas gali keisti TIK `username`; coins/playPacks/premiumUntil/recentByMode ir kt. rašo TIK Cloud Functions.
- Anti-cheat `submitScore`: serveris pats matuoja laiką; botų filtras (≥200 ms/kl.); Σ(clientTimes) ≤ serverio laikas + 3 s; žaidimas trinamas (no replay).
- Atsakymas klientui siunčiamas SĄMONINGAI (momentinė reakcija) — saugu, nes taškai iš LAIKO serveryje.

---

## 6. ANTI-SPAM BAUDOS (savininko formulės — VISIEMS 2-mygtukų/quiz žaidimams)

> PRINCIPAS: atsitiktinio spaudinėjimo vidurkis ≈ 0; bauda PROPORCINGA (9/1 ≠ nulis!); praleidimai dėl laiko NEbaudžiami; viskas SKAIDRU žaidėjui.

| Žaidimas | Bauda už klaidą | Papildomai |
|---|---|---|
| 6 variantų (mat./trivijos) | −25 (TIK aktyviai atsakius; ""/null/−1 = praleista, be baudos) | monetos/raidės tik nuo 4 teisingų |
| ⚡ Blitz | −200 (=2× bazė) | gap-gate: <600 ms po ankstesnio = 0 tšk.; atlygiai floor(persvara/2) |
| 🧐 Mitai | `taškai = uždirbta × max(0, teisingi − 2×klaidos)/teisingi` (10/0=100 %, 9/1≈78 %, 8/2=50 %, ≤6/4=0) | monetos = persvara, be greičio bonuso |
| 🕵️ Detektyvas | −1 ❤️ (iš 3) | žodis perdega |
| ❄ Melt | −10 % pMax iš banko (floor 0) | spėjimų cooldown 2,5 s×2ⁿ (max 15 s) |

**SKAIDRUMAS PRIVALOMAS:** serveris grąžina `pointsEarned`/`pointsPenalty`; rezultatai rodo „✅ +X 💥 −Y" + paaiškinimą, kodėl be monetų. Tylus 0 atrodo kaip bug'as.

---

## 7. ŽAIDIMAI IR FORMULĖS (visi VEIKIA, deploy'inti)

- **🧮 Matematika** — generuojama (`questionRegistry.ts`), 7 šeimos × 4 lygiai; taškai `max(10,100−sek×3)`; unlock mix/brackets/algebra 150 🪙 / 2 reklamos, PLAYS_PER_PACK=2.
- **Klausimų žaidimai (gamta + temos):** 10 kl., 6 variantai, 30 s/kl.; monetos 1 (+1 jei <3 s); raidės paslaptims `lettersFor(correct)` (≥10→3, ≥8→2, ≥6→1). **Rotacija PER TEMĄ** `recentByMode["cat_<tema>"]`, KEEP=800, LRU (matematika — per režimą, KEEP=150).
- **⚡ Blitz** — 30 s/1 min jungiklis; 40/80 teiginių „klausimas+kandidatas"; kombo ×2; finalas ×2 (paskutinės 5 s); kortelės su temos veidu.
- **🧐 Tiesa ar mitas** — 40 teiginių (10/lygiui) + verdiktas/paaiškinimas; per `submitScore` + §6 formulė; titulai pagal rezultatą.
- **🔑 Mystery klasikinis** — bankas 200/300/400/500; pagalbos iš banko (50/50/+30), floor 50; fondas BE citatų/patarlių (liko klausimas/faktas/istorija).
- **❄ Melt (Raidžių tirpimas)** — TIK „klausimas" kategorija; SPĖTI langas pagal raides (≤12→1 min, ≤20→1,5 min, 21+→2 min, max 5); hint1@40 %/hint2@70 %.
- **🕵️ Detektyvas v2** — DU žaidimai: 🕵️ įtariamųjų lenta + ✍️ PRO (rašai pats, ×1,25); bankas 1000 − laiko bauda; SOS 120; 3 ❤️; 16 bylų (`detective*`). **LAUKIA savininko testo telefone.** ⚠️ `DETECTIVE_FREE_PER_DAY=999` TESTUI — prieš Play grąžinti į 3.

---

## 8. 🛠️ RECEPTAS: KAIP PRIDĖTI NAUJĄ TEMĄ ar POTEMĘ (patikrintas šią sesiją)

**Naujos POTEMĖS esamai temai** (pvz. dar viena Rekordų potemė):
1. Naujas MAŽAS failas `src/<tema><Potemė>.ts` su 40 kl. (10/lygiui), `subTheme: "<kodas>"`.
2. Indekse `src/<tema>Content.ts`: importuok + `...SPREAD` į masyvą.
3. `subThemeConfig.ts` — potemė jau registruota (arba pridėk `<kodas>: ["<kodas>"]`).
4. Klientas `trivia_topic_screen.dart` — tos potemės kortelę `open: false → true`.
5. Patikra → faktų Workflow → stiliaus Workflow → pataisymai → `npm run build` → deploy `startTriviaGame` → (jei keitei klientą) APK + install.

**Nauja TEMA** (kaip Kosmosas/Mitologija/Rekordai — pilnas wiring):
1. Turinys: mažas failas potemei + plonas indeksas `src/<tema>Content.ts`.
2. `triviaTypes.ts` — `TriviaCategory` += `"<kodas>"`.
3. `triviaRegistry.ts` — import + įrašas `<kodas>: <TEMA>_QUESTIONS`.
4. `subThemeConfig.ts` — `<kodas>: { potemė1:[…], … }`.
5. `unlockConfig.ts` — `OPEN_TRIVIA_CATEGORIES` += `"<kodas>"`.
6. `themeEmoji.ts` — `THEME_FALLBACK` += `<kodas>: "🙂"` ⚠️ (BŪTINA — `Record<TriviaCategory>`, kitaip tsc klaida!).
7. `app_theme.dart` — nauja SAVA spalva `themeX` (žr. §9 dizaino taisyklę).
8. `theme_catalog.dart` — `GameTheme(code, emoji, accent, kind: trivia, open, title, subtitle)`.
9. `trivia_topic_screen.dart` — `hasSubThemes` += kodas; `_subThemesFor` `case '<kodas>'` su potemėmis (+mix).
10. `app_strings.dart` — `categoryX`/`Desc` + potemių tekstai (LT+EN).
11. Patikra (tsc + `validateContent.js` + ilgio kvapas + analyze) → faktų Workflow → stiliaus Workflow → pataisymai → deploy `startTriviaGame` → APK + install → commit → atnaujink ŠĮ dokumentą.

> Mažų failų šablonas: `cosmosPlanets.ts` + `cosmosContent.ts` (indeksas). Faktų/stiliaus Workflow: žr. sesijos skriptus.

---

## 9. 🎨 DIZAINO TAISYKLĖS

- **Kiekviena pradinio meniu tema — SAVA spalva** (savininkas 2026-06-13: „negražu, kai skirtingos temos vienodos spalvos"). Spalvos `app_theme.dart` (`themeGeo/History/Tech/Food/Sport/Body/Cosmos/Myth/Mythology/Exam/Records` + level/neon spalvos), priskyrimas `theme_catalog.dart` `accent`. Gretimos kortelės — kuo skirtingesnės.
- **Atsakymų mygtukai:** VIENAS bendras šrifto dydis VISIEMS variantams (`_uniformFont`), NIEKADA per-mygtuko `FittedBox` (skirtingi dydžiai = savininkas pyko). Tekstas wrap'ina/scaleDown, niekada nenukerpamas.
- Cyber-Neumorphism (tamsus + neon); rezultatų ekranai su titulais + „egzamino lapu".

---

## 10. DABARTINĖ BŪSENA (2026-06-13, ~3 165 trivijos/gamtos kl.)

**Esamos temos (klausimų):** gamta 720 · sport 270 · body 255 · history 244 · pop 243 · geo 240 · tech 177 · food 176. + 40 mitų teiginių · 101 mįslė (pool 73; lygiai L1=15/L2=45/L3=35/**L4=6**) · 16 detektyvo bylų.

**🆕 ŠIĄ SESIJĄ pastatyta:**
- 🌌 **KOSMOSAS — PILNA tema, 200 kl.** (5 potemės po 40: 🪐 planets · 🚀 spacerace [perkelta iš tech „space" registro lygyje] · 🧑‍🚀 astronauts · 🔭 universe · 🛰️ rockets). Failai `cosmosPlanets/Astronauts/Universe/Rockets.ts` + `cosmosContent.ts`.
- 🏺 **MITOLOGIJA — PILNA tema, 160 kl.** (4 potemės po 40: ⚡ greek · 🔨 norse · 🐫 egypt · 🐉 creatures). SAUGA: tik senovės mitai. Failai `mythologyGreek/Norse/Egypt/Creatures.ts` + `mythologyContent.ts`.
- 📏 **REKORDAI — BAIGTA, 160 kl. (4/4 potemių).** 🏆 human · 🌍 world · 🤪 laws · 💎 **objects** PILNOS. 🌍 world (Burdž Chalifa, Everestas, Antarktida=didžiausia dykuma). 🤪 laws (Singapūro guma, La Tomatina, Romos laiptai, Šveicarijos jūrų kiaulytės). 💎 objects (40 kl., 2026-06-13: brangiausi/didžiausi daiktai + KAIP rekordai pasiekti [savininko idėja] — Salvator Mundi, Kalinanas, Hope, Mercedes 300 SLR, 1933 moneta; tyrimo Workflow su šaltiniais+aktualumu; QC: 3 faktų [Stradivarijui pridėta „aukcione"; Cobaino gitara perfrazuota, nes Gilmouro „Black Strat" 2026-03 pranoko] + 12 stiliaus). Failai `recordsHuman/World/Laws/Objects.ts` + `recordsContent.ts`. ⚠️ „Brangiausias/didžiausias kada nors" rekordai gali PASENTI — periodiškai web-tikrinti. ⚠️ Gyvūnų rekordai — GAMTOJE, NEkartoti; geo turi dalį tų pačių faktų — Rekorduose duoti KITU faktu/dydžiu.
- 🚨 **EMOJI: skiriam DU dalykus (savininkas 2026-06-13):** (1) **KLAUSIMO emoji** (`q.emoji`, vienas prie klausimo) — NIEKADA neišduoda atsakymo: jokių vėliavų, kai atsakymas yra šalis (🇨🇱→Čilė); jokio daikto, kuris ir yra atsakymas (❄️→Antarktida, 👞→batai, ⚡→Dzeusas, 🦁→Sfinksas). Turi būti bendrinis temos ženklas, ĮVAIRUS (ne vienodas ant visų). (2) **ATSAKYMŲ mygtukų emoji** (`emojiForOption` — vėliavos prie šalių, instrumentai ir kt.) — GERAI, net gražu, paįvairina; NELIESTI (veikia „viskas-arba-nieko", todėl neišduoda). **PADARYTA (2026-06-13): VISOS temos sutvarkytos** — rekordai 18 + kosmosas/mitologija 109 + senos temos (gamta 84/geo/ist/pop/tech/maistas/sport/kūnas) 228 = **355 q.emoji** pakeisti per emoji-audito Workflow. Naujoms partijoms: iškart dėk NEUTRALŲ teminį q.emoji (ne atsakymo daiktą/vėliavą).
- 🚨 **REKORDAI negali būti pasenę (savininkas 2026-06-13):** „aukščiausias/didžiausias/greičiausias" gali pasikeisti — BŪTINA web-patikra ar dar galioja (faktų QC lensas tai tikrina). Rinktis stabilius arba tikrinti naujausią info.
- 🏷️ **PREKIŲ ŽENKLAI — PILNA tema, 160 kl. (4/4 potemių).** 🍟 food (Coca-Cola, McDonald's, Toblerone paslėptas lokys, Häagen-Dazs ne daniškas, Michelin gidas) · 👟 fashion (Adidas/Puma brolių vaidas, LEGO, IKEA, Velcro, Play-Doh) · 🚗 cars (Mercedes dukters vardas, Audi „klausyk", BMW propelerio mitas, Lamborghini traktoriai) · 💡 names (Google/googol, Bluetooth vikingų karalius, Nintendo 1889 kortos, Amazon „Cadabra"). Failai `brandsFood/Fashion/Cars/Names.ts` + `brandsContent.ts`; smaragdo spalva `themeBrands`. Parašė Opus; QC (32 faktų skeptikai+web + 4 stilius, 36 agentų Workflow): ištaisyta **11 faktų** (Porsche irgi turi stojantį žirgą→pakeista į „juodas žirgas geltoname"; LEGO distraktoriai Duplo/Mega Bloks irgi kaladėlės→„danų ženklas, su kaišteliais"; Dassler ir „partneriai"→bendraklasiai; Subaru 5 žvaigždės ne 6; **Unilever ledų rekordas PASENĘS — 2025-12 atskirta į The Magnum Ice Cream Co.→perfrazuota istoriškai**; Toblerone/Rubik „inspiracijos" mitai sušvelninti) + **35 LT stiliaus** (kalkės, giminė, „dvyuodegė" rašyba, „bendraįkūrėjas", „trenčkotas", kabantys „ką?/kaip?"). tsc/validacija/ilgio kvapas(0)/analyze OK; deploy+APK+commit. ⚠️ „brangiausias/didžiausias/priklauso" tipo faktai gali SENTI — periodiškai web-tikrinti (kaip Unilever).
- 🚂 **TRANSPORTAS — PILNA tema, 160 kl. (4/4 potemių).** ✈️ aviation (Wright broliai, juodoji dėžė oranžinė, Concorde, oro uostų kodai) · 🚢 ships (Titanikas, burlaiviai, švyturiai, jūrmylė, povandeniniai) · 🚄 trains (Stephensono Rocket, Shinkansen, Orient Express, metro) · 🧳 routes (Šilko kelias, Route 66, Panamos kanalas, Transsibiras). Failai `transportAviation/Ships/Trains/Routes.ts`; plieno mėlyna `themeTransport`. **METODAS: Sonnet 4.6 juodraščiai (4 agentai per Workflow) → Opus peržiūra (savininko valia).** Sonnet padarė tvarkingą faktų karkasą (validacija/ilgio kvapas/tsc švarūs iškart), BET lietuvių k. ir keletą faktų sutvarkė Opus: faktų QC (2 bangos, web) rado **~20 faktų** (kritiniai: trn_sh_002 LT „laivapriekis/laivagalis" buvo sukeisti+sugalvotas „prikilis"; trn_tr_017 Orient Express 1883 nevažiavo iki Stambulo→perfrazuota į 1889 tiesioginį; trn_tr_032 „Roman Abt"=„Carl Roman Abt" dublis→pakeista; trn_sh_035 ilguma ties pusiauju irgi teisinga→„bet kur Žemėje"; Shinkansen/maglev/metro PASENĘ skaičiai→istoriškai/„projektinis") + **117 LT stiliaus** (kalkės, giminė, sugalvoti žodžiai „prikilis/ilgaplaučius/spūda/nerimavo") — VISKĄ perrašė 4 Opus agentai (transport-fix Workflow). tsc/validacija/ilgio kvapas(0)/analyze OK; deploy+APK+commit. ⚠️ Sonnet LT juodraščiai BUVO labai nešvarūs — ATEITY būtinai pilna Opus LT peržiūra po Sonnet.
- 🌿 **3 BANGA PRADĖTA — Gamtos 2 naujos potemės (2026-06-13):** 🧬 **Supergalios** (40, nat_sup_) + 🧠 **Gyvūnų protas** (40, nat_min_), po 10/lygiui. Rašė Opus pats (ne Sonnet — šitam dydžiui greičiau+kokybiškiau). ⚠️ GAMTA veikia per `NatureTopic`+`startNatureGame` (NE subThemeConfig kaip kitos temos — paveldas; žaidėjui jokio skirtumo). Wiring: `NatureTopic`+2, mažais failais (`natureSuperpowers/Minds.ts`) prikabinta prie `natureContent.ts`, `NATURE_TOPICS`, `nature_topic_screen` (2 kortelės), tekstai. QC 2 bangos: faktų (mantišrimpas 12 ne 16; ungurys „paprastai 600 V"; Koko/šarka sušvelninti) + ~36 LT „kabančio klausimo žodžio" kalkių frontinimas (mano LT modelio problema — VENGTI „...ką?/kur?" gale). tsc/validacija/ilgio kvapas(0)/analyze OK; deploy `startNatureGame`+APK+commit. ⚠️ Tikslas potemei — 150/lygiui (=600); dabar tik starteris po 40, vėliau pildyti.
- 🎓 **Egzaminų centras** — placeholder kortelė meniu (užrakinta „Greitai", `ThemeKind.exam`, aukso spalva); mechanika vėliau (žr. `docs/planai/EGZAMINU_CENTRAS_PLANAS.md`).
- 🎨 Visoms temoms priskirtos skirtingos spalvos.
- 🔬🔤 Visas naujas turinys praėjo faktų IR stiliaus adversarines patikras (rado/ištaisyta realių klaidų).

**Visi nauji klausimai:** 10/lygiui, ≤46 simb., 0 ilgio kvapo, 0 dublių, deploy'inti, telefone.

**Įrankiai `functions/` (untracked):** `validateContent.js`, `_audit_len.js`, `_fix_len.js`, `_appcheck_fix.js`, `_gap.js` (tema×potemė×lygis), `_checkcosmos.js` ir kt.

**⚠️ Testo būsenos (PRIEŠ Play sutvarkyti):** **`TESTING_UNLOCK_ALL=true` (gameConfig.ts) → false** (nuima VISUS blokus: matematikos užraktą, „Atspėk paslaptį" išspręstas, Detektyvo išspręstas bylas + dienos limitą — kad savininkas testuose žaistų viską be ribų); `DETECTIVE_FREE_PER_DAY=999`→3; AdMob TEST ID→realūs (tik kai Play testavime); visos temos `open:true`; release APK R8; App Check debug→playIntegrity.
- 🧪 **„Viska praeita / neina žaisti" KLAIDA ištaisyta 2026-06-13:** priežastis NE Blitz/Mitai (jie patys recikliuoja klausimus per `takeSome`), o IŠSPRĘSTŲ sekimas — „Atspėk paslaptį" (visas paslaptis išsprendus → „Paslapčių dar nėra") ir Detektyvas (visas bylas išsprendus + dienos limitas). Sprendimas: `TESTING_UNLOCK_ALL` jungiklis (`gameConfig.ts`), pritaikytas `index.ts` (math), `detectiveFunctions.ts`, `mysteryFunctions.ts`. Tik serveris — APK neliestas.
- 🛡️ **Saugos turinio pataisymai (savininkas 2026-06-13: jokių narkotikų/religijos/nešvaraus):** brands 3 klausimai pakeisti — 7Up „litis"(vaistas)→Skittles; Quaker Oats(religija)→kas nupirko McDonald's; Canon „budizmas"(religija)→Cisco vardas iš San Francisko. Palikta tik SENOVĖS mitologija (Nike/Maserati/Mazda) — tas pats lygmuo kaip patvirtinta Mitologijos tema. Taisyklė įrašyta §2 „AUKSO TAISYKLĖ".

---

## 11. DARBŲ EILĖ (kas liko, savininko patvirtinta)

**A) TURINYS (tas pats §8 receptas, faktų+stiliaus Workflow kiekvienai partijai):**
1. ✅ 📏 **REKORDAI BAIGTA** (4/4 potemės, 160 kl.) 2026-06-13. ⚠️ objects APK su atrakinta kortele PASTATYTAS, bet telefonas tuo metu buvo ATJUNGTAS — įdiegti `adb -s R5CX221CT5N install -r ...app-debug.apk`, kai bus prijungtas (turinys jau serveryje).
2. ✅ 🏷️ **Prekių ženklai BAIGTA** (kodas `brands`, 4/4, 160 kl.) + ✅ 🚂 **Transportas BAIGTA** (kodas `transport`, 4/4, 160 kl.) — abi 2026-06-13, parašyta+wiring+QC+deploy+APK+commit (detalės §10). **2 BANGA (visos naujos temos) BAIGTA.** Transportas — pirmoji daryta Sonnet-juodraščių metodu (§2): pasiteisino, bet Sonnet LT reikėjo pilnos Opus peržiūros.
3. **3 BANGA — po ≥2 NAUJAS potemes ESAMOMS temoms** (savininko užsakymas; idėjos `TURINIO_PLANAS.md` „3 BANGA"): Gamta (🌋 stichijos, 🦠 mažasis pasaulis) · Pop (😂 internetas/memai, 🎮 žaidimų kultūra) · Istorija (🏰 riteriai/pilys, 🗺️ atradėjai) · Maistas (☕ gėrimai, 🍰 desertai) · Kūnas (🫀 širdis/kraujas, 🍎 mityba). + senesnės 1 bangos sėklinės (tech AI, pop superherojai, kūnas pojūčiai).
4. Lygiagrečiai: senų temų „ilgio kvapas" (~356 ryškūs: gamta 187, istorija 50…) partijomis; mįslių „klausimas"+L4 pildymas; klausimų pildymas iki 150–200/lygiui.

**B) TAVO RANKOSE:**
- 🕵️ **Detektyvo v2 testas telefone** (vis dar laukia).

**C) ŠLIFAVIMAS IKI GOOGLE PLAY (galutinis etapas):**
- ⚠️ **„PRANEŠTI APIE KLAIDĄ" MYGTUKAS (savininko užsakymas 2026-06-13, BŪTINAS):** žaidimo partijos pabaigoje, prie kiekvieno klausimo PAAIŠKINIMO, Standard ir PRO žaidėjams rodyti mažą vėliavėlę `[⚠️ Pranešti apie klaidą]`. Paspaudus — naujas Cloud Function (enforceAppCheck) įrašo pranešimą į Firestore (klausimo ID + lygis + neprivaloma žaidėjo pastaba + laikas). Tikslas: protingiausi žaidėjai praneša, jei mokslas/faktas pasikeitė → DB lieka gyva ir tiksli be didelių kaštų. Vėliau — admin peržiūra (galbūt tame pačiame reklamų/monetizacijos skydelyje). Server-authoritative, anti-spam (limitas pranešimų/žaidėjui).
- 🎓 Egzaminų centro mechanika (po koncepcijos aptarimo — DIDELIS sumanymas).
- ⚖️ #49 bendra logiška TAŠKŲ SISTEMA (rekordai atskirai; parduotuvė už taškus; lygiai).
- 👤 PROFILIS pilnas; 🎨 dizainas žaidimo viduje (taškučiai+serija — ATSARGIAI su nature/math ekranais).
- 🌍 PAPILDOMOS KALBOS (es/it/pl/de/fr/uk/pt/ar) — vertimas PAGAL KULTŪRĄ, ne pažodžiui.
- 🔒 Techninis auditas: R8/release fix, App Check→playIntegrity, tikri AdMob ID, rate-limiting, Firestore TTL.
- 🎛️ **Reklamų/monetizacijos VALDYMO SKYDELIS (savininko užsakymas 2026-06-13)** — custom web admin (Firebase backend): įjungti/išjungti reklamas, keisti jų dažnį/kainas, matyti pajamas + žaidėjų statistiką; reklamų kampanijų duomenis traukti per Windsor.ai jungtį. KŪRIMO darbas PO turinio etapo (ne jungtis — patys statom).

**Vėliau (atskiri OK):** reklama už +1 gyvybę, dienos byla, serijos, dvikova, detektyvo bylų paketai.
- 📹 **REKLAMINIS VIDEO (ateičiai, 2026-06-13 išbandyta):** statiški ekranai+tekstas+muzika = SILPNA (savininkas: „nieko nepareklamuosi"). Reikia TIKRO gameplay JUDESIO. ⚠️ adb `screenrecord` sugedo (45 KB) — naudoti telefono ĮMONTUOTĄ ekrano įrašytuvą (savininkas filmuoja 30–60 s žaidimo). Montažui **Canva Pro (apmokėta) UŽTENKA** — Descript NEpirkti (Free 100 AI kreditų išnaudoti, 720p+vandenženklis). 7 žaidimo ekranai išsaugoti `_p1..p7.png` (untracked). Descript testas: share.descript.com (struktūra OK, bet PNG neperkodavo).

---

## 12. KO NEDARYTI

- Neliesti veikiančių (Mystery/Melt/Blitz/Mitai/Detektyvas/trivijos/Kosmosas/Mitologija) be aiškios priežasties.
- Nekeisti deployintų funkcijų vardų ir klausimų/bylų ID (rotacijos/solved sąrašai!).
- Jokio `git add -A` (šaknyje senas `android/` MINA šlamštas + screenshot'ai) — pridėk TIK konkrečius kelius.
- Nekurti naujo taškų tipo iki #49 — laimėjimai į mysteryKeys/coins kaip dabar.
- NEpildyti gamtos „facts" (600 BAIGTA); neperrašinėti veikančio turinio be reikalo.
- Balanso konstantų nekalti į UI tekstus — tik iš serverio payload.
- Negaminti patarlių/citatų/posakių; nedaryti SSRS-kaip-valstybės atsakymų; nekartoti gyvūnų rekordų už Gamtos ribų.

---

## 13. ATMINTIS, PLANAI IR DOKUMENTAI

- **Atmintis:** `C:\Users\minda\.claude\projects\C--Users-minda-OneDrive-Desktop\memory\` — `MEMORY.md` indeksas + temų failai (`project_math_game`, `feedback_question_writing_rules`, `feedback_coding_rules`, `project_appcheck_debug_token` ir kt.). **Po reikšmingo darbo atnaujink atitinkamą failą.**
- **📘 `KLAUSIMU_KURIMO_METODIKA.md` — PILNA klausimų kūrimo metodika (PRIVALOMA prieš rašant): procesas, AUKSO taisyklė, potemių paieška, šaltiniai, sunkumo skalė, kiekio tikslas, formatas, ilgio kvapas, emoji, LT spąstai (kabantis žodis + vidinės kabutės), QC 2 bangos, recipe'ai (potemė/tema, Gamta atskirai), įrankiai, checklist.**
- **Planai repo:** `TURINIO_PLANAS.md` (temos+potemės, 3 banga) · `KLAUSIMU_STILIAUS_GIDAS.md` (10 auksinių taisyklių) · `docs/planai/` (DETEKTYVAS, RAIDZIU_TIRPIMAS, TAIP_NE_BLITZ, **EGZAMINU_CENTRAS**) · `DIZAINAS.md` · `STRATEGIJA.md` · `PLETROS_PLANAS.md`.

---

## 🔌 ĮRANKIAI IR JUNGTYS (Connectors) — ką turime ir galime naudoti

**✅ Prijungta ir naudojama:**
- **GitHub** — kodas/repo (commit/push).
- **Canva** — dizainas (ikonos, Play grafika, baneriai) + video mp4 eksportas.
- **Claude in Chrome** — naršyklės valdymas (jei reikia).
- **visualize** (įmontuotas) — greiti SVG/HTML mockup'ai pokalbyje (kaip Artifacts).
- **Descript** — video montažas/kūrimas iš teksto (PRIJUNGTA 2026-06-13).
- **LILT** — profesionalus vertimas su žmogaus patikra, 10 kalbų planui (PRIJUNGTA 2026-06-13).
- **Sentry** — crash/klaidų stebėjimas gyvai po paleidimo (PRIJUNGTA 2026-06-13).

**🔥 Dar galima prijungti (neprivaloma):**
- **ElevenLabs** — muzika, garso efektai, įgarsinimas (jei Descript garso neužteks).
- **Snyk** — saugos skenavimas; **Socket** — priklausomybių patikra.
- → Video komplektas: **Descript + Canva** (+ ElevenLabs garsui) = įtraukiantys klipai.

**🌍 Vėliau (plėtra/marketingas):**
- **Windsor.ai** — Meta/Google/TikTok reklamų analitika; **Bitly** — nuorodos/QR; **Semrush/Ahrefs** — ASO.
- **Splice** — garsų biblioteka; **Cloudinary** — media saugykla/apdorojimas.

**⚠️ Ko NĖRA (svarbu žinoti):**
- **Google Play / App Store įdiegimo jungties NĖRA.** Į Play diegiama RANKINIU būdu per Play Console (vėliau galima CI/fastlane). Funkcijų deploy — `firebase-tools` CLI. iOS/Safari NEAKTUALU (žaidimas — Android).
- **Reklamų valdymo skydelio** gatavos jungties nėra, BET GALIMA PASIDARYTI: ateityje sukursim custom web admin skydelį (Firebase backend), kur savininkas valdytų monetizaciją/reklamų nustatymus ir matytų statistiką; kampanijų duomenis trauktume per Windsor.ai. Tai KŪRIMO darbas, ne jungtis.

---

## 14. ❓ PASITIKRINIMO KLAUSIMAI (ar nauja sesija suprato)

1. Kodėl negalima dirbti dviem sesijom vienu metu ir kodėl `git add -A` pavojinga?
2. Kur skaičiuojami taškai/monetos/diplomai — kliente ar serveryje? Kodėl?
3. Kokia amžiaus skalė ir kaip lemiamas sunkumas?
4. Kas yra „ilgio kvapas" ir kaip jį tikrinti?
5. Kokios DVI QC bangos privalomos kiekvienai naujai klausimų partijai?
6. Kodėl LT tekstas turi būti natūralus, ne pažodinis? Pateik 2 dažnus spąstus.
7. Kaip pridėti naują temą (pagrindiniai failai)? Kodėl `themeEmoji.ts` būtinas?
8. Ką reiškia „401/offline" funkcijoje? Kas tai tvarko?
9. Kodėl telefonui tik DEBUG APK?
10. Kas dabar PADARYTA ir kas TOLIAU pagal §11?

> Jei atsakymai aiškūs iš dokumento — perdavimas pavyko. Pasisveikink lietuviškai, paprastai, ir tęsk darbą (greičiausiai: 🌍 Pasaulio rekordai arba savininko nurodymas). Jokio kodo be aptarimo TIK naujiems dideliems sumanymams; aptartiems — autonomija iki galo.
