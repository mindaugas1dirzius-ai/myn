# BRAIN ARENA — kaip veikia žaidimas (audito pagrindas)

> Šis dokumentas paprastai paaiškina, **kaip viskas sudėliota ir kokie principai**, kad
> pagal jį būtų galima padaryti **pilną auditą** (saugumo, turinio, kokybės, monetizacijos).
> Paskutinio peržiūros punkto sąraše („Ką svarbu patikrinti“) surašyta, ką tikrinti.

Data: 2026-06-12 · Projektas: `math-game-9862f` · Regionas: `europe-west1`
Repo: `mindaugas1dirzius-ai/myn` · Šaka: `claude/android-app-monetization-ads-RORMZ`

---

## 1. Kas tai per žaidimas

**BRAIN ARENA** — protų mankštos / viktorinos žaidimas telefonui (Android), komercinis
(uždirba iš reklamų ir pirkinių). Žaidėjas renkasi **temą**, **lygį** ir atsako į klausimus
per laiką. Yra ir atskiras **„Atspėk paslaptį“** žaidimas (renki frazę raidė po raidės).

Pagrindinė idėja: daug temų, įdomūs ir patikrinti klausimai, dvi kalbos (lietuvių + anglų),
sąžiningas taškų skaičiavimas serveryje, švelni monetizacija (reklama netrukdo žaisti).

> ⚠️ **Audito pastaba:** repo šaknyje esantis `README.md` aprašo **seną, kitą** žaidimą
> („MYN“ — žodžių spėliojimas su Supabase/Vercel). Tai NĖRA dabartinis žaidimas.
> Dabartinis žaidimas yra `math_game/` aplanke. Senus dokumentus vertėtų sutvarkyti,
> kad nepainiotų.

---

## 2. Iš ko sudarytas (architektūra)

Trys dalys:

| Dalis | Kur | Ką daro |
|---|---|---|
| **Klientas** (telefono programa) | `math_game/` (Flutter/Dart) | Ekranai, mygtukai, animacijos, garsai, reklama. Pats **NIEKO neskaičiuoja** — tik klausia serverio ir rodo. |
| **Serveris** (Cloud Functions) | `phase2_backend/functions/src/` (TypeScript) | Visa logika: parenka klausimus, slepia atsakymus, skaičiuoja taškus, tvarko monetus, užraktus. |
| **Duomenų bazė** (Firestore) | Firebase debesyje | Saugo žaidėjų profilius, rezultatų lentelę, laikinus žaidimus. |

**Svarbiausias principas: „serveris yra teisėjas“ (server-authoritative).**
Telefonas niekada negeneruoja klausimų ir neskaičiuoja taškų pats — viskas tikrinama
serveryje. Tai apsaugo nuo sukčiavimo.

---

## 3. Žaidimo režimai

| Tema (emoji) | Tipas | Būsena | Pastaba |
|---|---|---|---|
| Matematika 🧮 | math | atidaryta | Klausimai generuojami begalybe (ne iš sąrašo) |
| Gamta 🌿 | nature | atidaryta | ~600–720 klausimų (faktai/išnykę/augalai/mišrūs) |
| Atspėk paslaptį 🕵️ | mystery | atidaryta | ~77 frazės (citatos, patarlės, faktai, orientyrai) |
| Pop kultūra 🎬 | trivia | atidaryta (testui) | |
| Geografija 🌍 | trivia | atidaryta (testui) | |
| Istorija 🏛️ | trivia | atidaryta (testui) | |
| Technologijos 🔬 | trivia | atidaryta (testui) | |
| Maistas 🍔 | trivia | atidaryta (testui) | |
| Sportas ⚽ | trivia | atidaryta (testui) | |
| Žmogaus kūnas 🧠 | trivia | atidaryta (testui) | |
| Blitz ⚡ | blitz | **užrakinta** | „Coming soon“ — vietos rezervas |

> **Audito pastaba:** kūrimo metu VISOS 7 trivijos temos laikinai atidarytos (`open: true`),
> kad būtų galima testuoti. Prieš paleidimą reikės nuspręsti, kurios atidarytos iš karto,
> o kurios užrakintos (už monetus / reklamą).

7 trivijos temas aptarnauja **viena bendra** serverio funkcija `startTriviaGame`. Matematiką
ir Gamtą — atskiros (`startGame`, `startNatureGame`). Paslaptį — atskiros funkcijos.

---

## 4. Kaip vyksta žaidimas (eiga)

### Trivijos / matematikos partija
1. Žaidėjas pasirenka temą → potemę → lygį (lengvas / vidutinis / sunkus / ekstremalus).
2. Telefonas kviečia serverį (`startTriviaGame` / `startGame`).
3. Serveris parenka **10 klausimų** (vengia neseniai matytų — „rotacija“), kiekvienam
   sudaro **6 variantus** (1 teisingas + 5 „spąstai“), sumaišo ir grąžina.
4. Serveris išsaugo teisingus atsakymus į laikiną įrašą `active_games` (telefonui jų logikai
   nereikia — taškus skaičiuoja iš **laiko**, ne iš atsakymo žinojimo).
5. Žaidėjas atsakinėja, telefonas matuoja laiką.
6. Telefonas siunčia atsakymus + laikus į `submitScore`.
7. Serveris **patikrina**: ar atsakymai sutampa su jo saugotais, ar laikas realus
   (ne per greitas — apsauga nuo botų), suskaičiuoja taškus, monetus, „raides“ paslapčiai,
   atnaujina rezultatų lentelę ir profilį. Laikinas žaidimas ištrinamas (apsauga nuo
   pakartotinio siuntimo).

**Taškai:** `max(10, 100 − sekundės × 3)` už teisingą atsakymą. Greičiau = daugiau.
Klaida = 0 taškų, bet žaidimas tęsiasi visus 10 klausimų (švelnus modelis).

### „Atspėk paslaptį“
- Renki paslėptą frazę raidė po raidės. Turi „raidžių banką“ (200/300/400/500 pagal lygį).
- Užuominos ir raidžių atskleidimas kainuoja iš banko (yra apatinė riba — **50**).
- **Nemokamas bonusas:** žaisdamas kitas temas uždirbi „pendingMysteryLetters“ (0–3 raidės
  pagal tai, kiek teisingai atsakei), kurias gali nemokamai panaudoti paslaptyje.
- Atspėjus — gauni likusį banką kaip „raktus“ (mysteryKeys). Yra 5 bandymai (+galima nusipirkti).

---

## 5. Turinys (klausimai)

Klausimai laikomi serverio kode (`*Content.ts` failuose) ir **įkompiliuojami į funkciją**.
Todėl pataisius tekstą reikia **iš naujo įdiegti serverį** (NE perdaryti telefono APK).

**Trivijos klausimo formatas** (`TriviaQuestion`):
- `id`, `category`, `subTheme`, `level`, `isTrap` (ar tai „klastingas“ klausimas),
  `sourceVerified` (faktas/šaltinis), `emoji`
- `translations.en` ir `translations.lt`, kiekvienoje: `question`, `correct`,
  `distractors` (≥5 klaidingi), `explanation`

**Paslapties formatas** (`MysteryItem`): `id`, `category`, `level`, `sourceVerified`,
`texts.en`/`texts.lt` su `text` (atsakymo frazė), `hint`, `hint1`, `hint2`.

**Kokybės taisyklės (galioja visam turiniui):**
- Visi 6 variantai (teisingas + 5 spąstai) ≤ **46 simboliai** abiem kalbomis.
- Lietuviškos kabutės viduje: `„..."` (ne ASCII `"`).
- Faktai patikrinti (`sourceVerified`).
- Sunkumas tikrai atitinka lygį; klausimai įdomūs ir įvairūs; nieko neįžeidžiantys;
  tinka visoms kalboms/kultūroms.
- Tikrinama scenarijumi `validateContent.js` (≤46 simb., `id` unikalumas).

**Turinio kiekis (apytiksliai, pagal kodo skenavimą):**
- Geografija ~240, Istorija ~244, Žmogaus kūnas ~255, Technologijos ~158, Maistas ~136,
  Pop ~120, Sportas ~120, Gamta ~600–720, Paslaptis ~77.

> ⚠️ **Audito pastaba:** dokumentas `KLAUSIMU_STATISTIKA.md` sako „7×120 = 840“, bet
> tikras kodas turi daugiau (pvz., kūnas ~255). Skaičius reikia suvienodinti su tikrove.

---

## 6. Sauga (svarbiausia)

| Apsauga | Kaip veikia |
|---|---|
| **Serveris — teisėjas** | Atsakymai ir taškai skaičiuojami tik serveryje. Telefonu pateiktais skaičiais nepasitikima. |
| **App Check** | Visos funkcijos turi `enforceAppCheck: true` — priima tik tikrus programos užklausimus. |
| **Autentifikacija** | Reikia `request.auth` (anoniminis prisijungimas). Be jo — atmeta. |
| **Anti-botas (laikas)** | Jei 10 klausimų atsakyti per < 2 sek. arba laikai neatitinka — atmeta. |
| **Be pakartojimo** | Įvertintas žaidimas ištrinamas iš `active_games` — negali siųsti dukart. |
| **Vardo valymas** | Žaidėjo vardas valomas (tik raidės/skaičiai/tarpai, iki 16 simbolių). |
| **Monetai/užraktai** | Keičiami tik serveryje, atominėmis (saugiomis) transakcijomis. |
| **Paslapties bankas** | Visi skaičiavimai serveryje; negali nusipirkti žemiau ribos. |

**Žinomas projektavimo sprendimas:** `startGame`/`startTriviaGame` grąžina teisingą atsakymą
telefonui. Tai saugu, nes taškai priklauso nuo **laiko**, ne nuo atsakymo žinojimo (žinant
atsakymą greičiau neatsakysi, jei nematei klausimo). Verta patvirtinti audite.

---

## 7. Ekonomija ir monetizacija

- **Monetai (coins):** uždirbami žaidžiant (1 už teisingą + 1 bonusas jei < 3 sek.).
  Naudojami užrakintiems lygiams atrakinti (**150 monetų = 2 žaidimai**, `unlockMode`).
- **Reklama vietoj monetų:** `unlockByAd` — už peržiūrėtą reklamą gauni žaidimų; yra
  **dienos riba** (apsauga nuo piktnaudžiavimo).
- **Premium:** prenumerata (30 d.) atrakina viską be monetų/reklamos.
- **Reklamos (AdMob):** baneris (meniu/rezultatų ekranuose, NE žaidimo metu), interstitial
  (po kas 3-io žaidimo, su 90 s pauze), rewarded (papildomos naudos už peržiūrą).
  Prieš reklamą — UMP/GDPR sutikimo langas.
- **Paslapties raktai (mysteryKeys):** atskira valiuta iš paslapties žaidimo.

> ⚠️ **Audito pastaba:** šiuo metu naudojami **Google testiniai reklamų ID** ir **App Check
> „debug“ režimas**. Prieš paleidimą į Google Play būtina perjungti į tikrus reklamų ID ir
> `playIntegrity`.

---

## 8. Duomenų bazė (Firestore)

- **`users/{uid}`** — profilis: `coins`, `premiumUntil`, `totalPoints`, `pointsByCategory`,
  `streakDays`, `learnedFacts`, `recentByMode` (rotacija), `playPacks`, `pendingMysteryLetters`,
  `mystery` (aktyvi paslaptis), `mysterySolved`, `mysteryKeys`, `username`.
- **`active_games/{id}`** — laikinas žaidimas su teisingais atsakymais; ištrinamas po įvertinimo.
- **`leaderboard/{uid}_{mode}`** — geriausias rezultatas pagal režimą (rašo tik serveris).

---

## 9. Kalbos

Klientas: lietuvių (lt) + anglų (en), perjungiamas, išsaugomas telefone.
Serveris turi atsargą daugiau kalbų (es, it, pl, de, fr, uk, pt, ar), bet turinys realiai
parašytas lt + en; jei kalbos nėra — atsarginė anglų.

---

## 10. Dabartinė būsena

✅ Veikia: matematika, gamta, paslaptis, 7 trivijos temos (testui atidarytos), monetų/užraktų
sistema, rezultatų lentelė, reklamos karkasas, dvi kalbos, didelis kalbos/stiliaus valymas.
🔄 Vyksta: potemių pildymas, klausimų įvairinimas, kalbos šlifavimas.
⬜ Liko iki Google Play: tikri reklamų ID, `playIntegrity`, IAP „be reklamų“, paleidimo formos,
uždaras testavimas (~14 d., ≥12 testuotojų).

---

## 11. Ką svarbu patikrinti (audito sąrašas)

### A. Sauga
- [ ] Firestore taisyklės (`firestore.rules`): ar klientas NEGALI tiesiogiai rašyti į
      `users`, `leaderboard`, `active_games` (tik per funkcijas).
- [ ] App Check perjungtas iš `debug` į `playIntegrity` (klientas: `firebase_service.dart`).
- [ ] Cloud Run „invoker“ nustatymai (žinomas niuansas: 401 = „offline“, ne App Check).
- [ ] Ar yra Firestore composite indeksai rezultatų lentelės užklausoms.
- [ ] „pendingMysteryLetters“ ir „coins“ — ar nėra neribotos kaupimosi spragos.
- [ ] „unlockByAd“ — ar dienos riba apsaugo nuo botų (kelios paskyros = nemokami žaidimai).

### B. Monetizacija
- [ ] Pakeisti Google **testinius reklamų ID** tikrais prieš paleidimą.
- [ ] UMP sutikimo logika: ar po sutikimo lango teisingai įjungiamos/išjungiamos reklamos.
- [ ] IAP „be reklamų“ / premium — ar realiai įgyvendinta ir patikrinama serveryje.

### C. Turinys ir kalba
- [ ] Suvienodinti deklaruotus klausimų skaičius su tikrais (`KLAUSIMU_STATISTIKA.md`).
- [ ] Visi variantai ≤ 46 simb. abiem kalbomis (`validateContent.js` visiems failams).
- [ ] `id` unikalumas visuose failuose.
- [ ] Lietuviškos kabutės `„..."` (ne ASCII), natūralūs sakiniai (ne pažodinis vertimas).
- [ ] Faktų patikra (`sourceVerified`) — atsitiktinė kontrolinė imtis.
- [ ] Sunkumas atitinka lygį; nieko neįžeidžiančio; tinka visoms kultūroms.
- [ ] Klausimų pradžių įvairumas (sumažintas monotoniškas „Kurioje šalyje…“, „Kokia X sostinė…“).

### D. Klientas (Flutter)
- [ ] Ar telefonas niekur neskaičiuoja taškų pats (tik rodo serverio rezultatą).
- [ ] Klaidų valdymas: „offline“ būsena, pakartotinis `submitScore` siuntimas.
- [ ] Atminties nutekėjimai (srautų uždarymas), garsų/inicializacijos klaidos.

### E. Tvarka projekte
- [ ] Pašalinti/atskirti senus dokumentus ir failus (senas `README.md` apie „MYN“, laikini
      `_*.js`, `_*.png`, debug logai) — kad nepainiotų.
- [ ] Patvirtinti, kurios temos atidarytos paleidime (dabar visos atidarytos testui).
