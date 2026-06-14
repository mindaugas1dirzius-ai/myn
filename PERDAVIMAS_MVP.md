# 🚀 PERDAVIMAS — MVP („greito paleidimo" projektas)

> ⚠️ **SVARBU: ČIA NE „Minalect Arena" (didysis žaidimas).** Tai jo PILNA KOPIJA, perdaroma į
> mažesnį, paprastesnį produktą greitam paleidimui. **Sek ŠĮ dokumentą** — automatinė atmintis
> (memory) ir senas `PERDAVIMAS_NAUJAI_SESIJAI.md` kalba apie DIDĮJĮ žaidimą; jais remkis tik
> dėl „virtuvės" (kaip kuriam klausimus, sauga, kodavimas), o NE dėl apimties/tikslo.
>
> Savininkas — **Mindaugas**, NE programuotojas, kalbam **LIETUVIŠKAI, paprastai**.

---

## 0. NUO KO PRADĖTI (nauja sesija — skaityk pirma)

1. Perskaityk šį dokumentą VISĄ.
2. Perskaityk „virtuvės" dokumentus (jie atkeliavo su kopija): **`KLAUSIMU_KURIMO_METODIKA.md`**
   ir `KLAUSIMU_STILIAUS_GIDAS.md` — klausimų kūrimo/kokybės taisyklės GALIOJA ir čia.
3. Šis projektas turi SAVO atskirą GitHub repo ir SAVO atskirą Firebase projektą (žr. §5).
4. Pasisveikink lietuviškai, patvirtink, kad supratai tikslą (§2), ir lauk savininko „darom".

---

## 1. VIZIJA IR KODĖL (kontekstas)

- **Didysis projektas „Minalect Arena"** — Flutter (Android) + Firebase protų žaidimų PLATFORMA
  vakarų rinkoms (10 kalbų ateityje), daug temų/režimų, kelias į Google Play + uždarbį. Jis
  TĘSIAMAS atskirai (kitame lange) — šito MVP NELIEČIA jo.
- **Kodėl darom šį MVP (savininko mintis):** tai PIRMAS savininko programėlės paleidimas. Jis
  nori **pereiti visą „paleidimo virtuvę" ant MAŽO, paprasto produkto** — kad išmoktų visą
  procesą (parduotuvė, parašas, reklamos su realiais pinigais, mokama versija, atnaujinimai,
  atmetimai/taisymai, crash stebėjimas) ir sumažintų riziką, PRIEŠ statydamas didįjį iki galo.
  Baimė, kurią tai gydo: „o jei kursiu amžinai, o pasirodys nereikalinga arba reikės viską
  perdaryti, nes ko nors nepadariau."
- **Strategija:** greitai paleisti NETUŠČIĄ produktą bandymui. Tikslas — **PEREITI KELIĄ**, ne
  tobulumas. Mokomės proceso.

---

## 2. KO NORIU IŠ MVP (tikslas + apimtis)

**Produktas:** paprasta protų/žinių programėlė su keliais režimais. NETUŠČIA, bet daug
paprastesnė nei didysis žaidimas (be temų skirstymo, be sudėtingų režimų).

### Režimai MVP'e (galutinis sąrašas — savininko valia):
| Režimas | Būsena |
|---|---|
| 🧮 **Matematika** (pagal lygius) | ✅ Lieka (jau veikia) |
| 🧠 **Bendro žinių viktorina pagal lygius** | ✅ Lieka — VISI klausimai sulieti į vieną katilą, BE temų skirstymo, 4 lygiai |
| 🧐 **Taip/Ne** (teiginiai pagal lygius) | ✅ Lieka |
| 🕵️ **Detektyvas** (spėk slaptą žodį perkant taip/ne klausimus) | ✅ Lieka (savininkas: „bus populiaresnis") |
| 🎓 **Egzaminai pagal lygius** | ✅ Lieka — MIKSAS: matematika + bendros žinios + taip/ne viename |
| ❄️ Raidžių tirpimas (melt) | ❌ Išmesta MVP'e (galima grąžinti) |
| 🔑 Atspėk paslaptį (paslaptis su raidėmis) | ❌ Išmesta MVP'e (galima grąžinti) |
| 🌌 Atskiros temos (kosmosas, mitologija, rekordai, prekių ženklai, transportas…) | ➡️ NEBE atskiros — jų klausimai SULIEJAMI į bendrą viktoriną |

> ⚠️ **PATIKSLINTI SU SAVININKU (neprivaloma plėtra):** Detektyvas dabar tekstinis su emoji
> užuominomis. Savininkas minėjo „su paveiksliukais" — patikslinti, ar nori, kad būtų pridėtas
> TIKRAS paveikslėlis kaip užuomina (nedidelis darbas), ar dabartinio pakanka.

### Turinys:
- **Bendro žinių viktorina — reikia ≥ 500 klausimų** (kad greitai neatsibostų / nesikartotų).
  GERA ŽINIA: didysis žaidimas jau turi **~3000+ trivijos klausimų** (gamta + visos temos) →
  juos tiesiog SULIEJAM pagal lygį → gerokai virš 500. Beveik nieko nereikia kurti iš naujo.
- Matematika — generuojama (jau yra).
- Taip/Ne — turim „Tiesa ar mitas" + „Blitz" pagrindą (pritaikom/papildom).

### Monetizacija (BŪTINA išbandyti — tai ir yra mokymosi tikslas):
- 📺 **Reklamos** (žr. §5 dėl Amazon niuanso).
- 💎 **Mokama versija** (per **Amazon mokėjimus**, NE Google).

### Parduotuvė: **Amazon Appstore** (savininko pasirinkimas)
- Kodėl: nereikia 12–20 testuotojų 14 d. (kaip Google Play naujoms paskyroms); peržiūra
  švelnesnė; jei kažkas ne taip — **leidžia pataisyti, o ne blokuoja**. Idealu pirmam paleidimui.
- ⚠️ Žinoti: mažesnė auditorija nei Play (silpnesnis „ar reikia" signalas, bet pipeline'ui mokytis — puiku).

---

## 3. VISA „VIRTUVĖ" — KAIP KURIAM KLAUSIMUS (galioja ir čia!)

> Pilnos taisyklės: **`KLAUSIMU_KURIMO_METODIKA.md`** (privaloma perskaityti) + `KLAUSIMU_STILIAUS_GIDAS.md`.
> Trumpai svarbiausi ramsčiai (jų NIEKADA nepažeisti):

1. **🟥 AUKSO TAISYKLĖ:** (a) tobulas LT+EN vertimas (natūralu, ne pažodžiui); (b) JOKIO jautraus/
   nešvaraus turinio (politika, religija, rasė, narkotikai, alkoholis, smurtas, seksas — nieko,
   kas įžeistų; saugu 9 m. vaikui); (c) garantuotas patikimas šaltinis; (d) naujausia info (ne pasenę rekordai).
2. **🎚️ Amžiaus skalė:** lengvas = 9–12 m. vaikas · vidutinis = 12–18 m. · sunkus = suaugęs · ekstremalus = žinovas.
   Sunkumą lemia fakto RETUMAS, ne gudri formuluotė.
3. **🚫 „Ilgio kvapas":** teisingas atsakymas NEGALI būti ilgiausias >+5 simb.; visi variantai ≤46 simb. (abiem kalbom). Įrankis: `phase2_backend/functions/_audit_*.js`.
4. **❌ Jokio „Kuris…?" klausimo pradžioje** — naudoti aprašomąją (kabliuko) formą be klaustuko
   (pvz. „Vabzdys, naktį sukuriantis savo švytinčią šviesą"). Varijuoti pradžias.
5. **🔤 Linksniai sutampa:** visi 6 atsakymai tos pačios gramatinės formos IR atitinka klausimą
   („Kam? → bendratis"). Klausimas paprastas, aiškus iš pirmo karto.
6. **🔁 Jokių dublikatų** — nei to paties fakto lygyje, nei tarp lygių. PRIEŠ pridedant — patikrinti, ar nėra.
7. **🌍 Kultūrinis universalumas;** patarlės/citatos/posakiai — NEKURIAMI NIEKADA.
8. **🔬🔤 DVI QC bangos kiekvienai naujai partijai:** faktų patikra + LT/EN stiliaus patikra.
9. **q.emoji** — neutralus teminis, NIEKADA neišduoda atsakymo; įvairus.

---

## 4. KAIP PROGRAMUOJAM + SAUGA (principai — galioja ir čia)

- **🔐 SAUGA #1 — SERVER-AUTHORITATIVE:** klausimai, atsakymai, taškai, monetos, gyvybės, laikas,
  atrakinimai, mokama versija — TIK serveryje (Cloud Functions, transakcijomis). Klientas (Flutter)
  TIK rodo. Atsakymas siunčiamas klientui sąmoningai (momentinė reakcija), bet taškai skaičiuojami iš LAIKO serveryje.
- **App Check** ant VISŲ funkcijų (`enforceAppCheck: true`). ⚠️ Amazonui reikės kito App Check
  sprendimo (Play Integrity NEVEIKIA be Google paslaugų — žr. §5).
- **`firestore.rules`:** klientas gali keisti TIK `username`; coins/playPacks/premium ir kt. rašo TIK serveris.
- **Anti-cheat (`submitScore`):** serveris pats matuoja laiką; botų filtras (≥200 ms/kl.); žaidimas trinamas (no replay).
- **Anti-spam baudos** 2-mygtukų/quiz žaidimams: bauda už klaidą proporcinga; praleidimai dėl
  laiko nebaudžiami; viskas SKAIDRU žaidėjui (rodo +X/−Y). Detalės: didžiojo `PERDAVIMAS_NAUJAI_SESIJAI.md` §6.
- **🧹 Kodo švara:** maži, sufokusuoti failai; seną/nereikalingą kodą TRINTI iškart; viskas į GitHub po kiekvieno gabalo.

---

## 5. KĄ KEISTI / PERDARYTI (MVP-specifika)

1. **🗑️ Išmesti nereikalingus režimus** (melt, mystery, atskiros temos kaip atskiros) — ir jų
   klientą, ir serverio funkcijas, ir turinį, kurio nereikia. Klausimus iš temų SULIETI į bendrą viktoriną.
2. **🆕 ATSKIRAS NAUJAS Firebase projektas** MVP'ui (NE `math-game-9862f`!). Nauja Firestore,
   naujos funkcijos, naujas App Check, naujas AdMob. (Tai ir yra ta „pilna virtuvė", kurią norim pereiti.)
3. **💳 Mokėjimai — Amazon In-App Purchasing (IAP)**, NE Google Play Billing. Mokamos versijos kodą perdaryti Amazonui.
4. **📺 Reklamos:** patikrinti, ar AdMob veikia per Amazon (Google reklamoms reikia Google Play
   paslaugų; Amazon Fire planšetės jų neturi). Variantai: taikytis į Amazon-ant-įprasto-Android,
   arba naudoti Amazon Mobile Ads. NUSPRĘSTI anksti.
5. **💥 Release APK „crash" (R8) SUTVARKYTI** — dabar release versija krenta startuojant
   (R8 × androidx.work). Tai BŪTINA bet kuriai parduotuvei (ir tas pats fix pravers Play'ui vėliau).
   Detalės: didžiojo handoff §4.
6. **🏷️ Naujas tapatumas:** naujas pavadinimas (NE „Minalect Arena"), nauja ikona, **naujas paketo
   vardas** (pvz. `com.myn.quiz` — užsirakina po 1-o įkėlimo, parinkti atsargiai). Logotipą/sudėtingą dizainą galima supaprastinti.
7. **🧹 Atnaujinti dokumentus:** šis `PERDAVIMAS_MVP.md` tampa pagrindiniu; senus didžiojo žaidimo planus laikyti tik kaip „virtuvės" žinyną.

---

## 6. ARCHITEKTŪRA IR KUR KAS YRA (kad galėtum dirbti / pereiti į naują serverį)

- **Stack:** Flutter (Dart) klientas `math_game/` + Firebase backend `phase2_backend/`
  (Cloud Functions TS 2nd Gen, Firestore, Auth, App Check) + AdMob.
- **Klausimų turinys (serveris):** `phase2_backend/functions/src/` —
  - Bendros žinios/temos: `*Content.ts` + per-potemę failai (gamta `natureContent.ts`,
    `cosmos*`, `mythology*`, `records*`, `brands*`, `transport*`, geo/history/pop/tech/food/sport/body…) → **sulieti į bendrą viktoriną**.
  - Registras: `triviaRegistry.ts`, tipai `triviaTypes.ts`.
  - Matematika: generuojama — `questionRegistry.ts`.
  - Taip/Ne: `mythContent.ts`/`mythFunctions.ts` (Tiesa ar mitas), `blitzFunctions.ts`.
  - Detektyvas: `detectiveContent.ts`/`detectiveFunctions.ts`/`detectiveTypes.ts`.
- **Klientas:** `math_game/lib/` — ekranai (`*_screen.dart`), katalogas/temos (`theme_catalog.dart`), tekstai (`app_strings.dart`).
- **Įrankiai (untracked `_*.js` `functions/`):** `validateContent.js`, `_audit_len.js` ir kt. — kopijuoti/naudoti.
- **Deploy (nauju Firebase projektu):** `npx --prefix "<…>/functions" firebase-tools deploy --only "functions:X" --config "<…>/phase2_backend/firebase.json" --project <NAUJAS-PROJEKTAS>`.
- **Turinys gyvena serveryje** → klausimų teksto keitimui APK perdiegti NEREIKIA (tik build + deploy). UI keitimui — reikia APK.

---

## 7. ŽINGSNIŲ PLANAS iki Amazon paleidimo (checklist)

1. ⬜ Sukurti naują GitHub repo + naują Firebase projektą; prijungti.
2. ⬜ Išmesti nereikalingus režimus/temas; sulieti klausimus į bendrą viktoriną pagal lygius.
3. ⬜ Padaryti „Egzaminai" režimą (miksas: matematika + žinios + taip/ne pagal lygius).
4. ⬜ Patikrinti, kad ≥500 bendrų klausimų; QC (faktai + stilius); jokio „Kuris", linksniai OK.
5. ⬜ Naujas pavadinimas + ikona + paketo vardas.
6. ⬜ Sutvarkyti release R8 crash (kad release APK nekristų).
7. ⬜ Reklamos (AdMob ar Amazon) + mokama versija (Amazon IAP) — išbandyti realiai.
8. ⬜ App Check sprendimas Amazonui.
9. ⬜ Privatumo politika, turinio reitingas, parduotuvės aprašymas, ekrano nuotraukos.
10. ⬜ Įkelti į Amazon Appstore → peržiūra → taisymai → paleidimas → stebėti.

---

## 8. APLINKA IR ĮRANKIAI (Windows!)

- Repo: šios KOPIJOS aplankas. ⚠️ default cwd dažnai = `…\Desktop` — prieš `node`/`npm` būtina `Set-Location` į `…\phase2_backend\functions` (ATSKIRU kvietimu; NIEKADA `cd X; komanda` viename — meta leidimo langą).
- **Flutter:** `& "C:\Users\minda\flutter\bin\flutter.bat"`. **TELEFONUI/TESTUI — DEBUG APK** (`build apk --debug`), nes release dabar krenta (kol nesutvarkytas R8).
- **adb:** `C:\Users\minda\AppData\Local\Android\Sdk\platform-tools\adb.exe`.
- **Python NĖRA** — laikinus skriptus rašyk `node` (`_vardas.js`, untracked).
- Validacija: `node validateContent.js src/<failas>.ts` → `npm run build` (tsc).

---

## 9. KAIP DIRBAM SU SAVININKU

- 🤖 **Pilna autonomija** aptartiems darbams — daryk iki galo (kodas → patikra → deploy → (APK jei
  Dart) → commit → push), TADA pranešk LT, ką pasirinkai ir kur patikrinti.
- ❓ **NEAIŠKU (ypač dizainas/išdėstymas/subjektyvu) → KLAUSK, nespėliok.** Geriau 1 klausimas nei 5 perdarymai.
- 🐛 Savininkas genialiai gaudo spragas žaisdamas — jo pastabos = AUKSAS; radęs taisyk TUOJ PAT ir paversk amžina taisykle.
- 🐢 NESKUBĖK: kokybė > greitis. Klaidą radus — pirma sutvark.
- 💾 VISKAS Į GITHUB po kiekvieno gabalo. 📣 PRANEŠK LT po kiekvieno pakeitimo.
- 👤 Viena sesija ant repo vienu metu (šis MVP — atskiras repo, tad su didžiuoju nesikerta).

---

> **Santrauka naujam langui:** paimk šią pilną kopiją, IŠMESK ko nereikia (melt, mystery, atskiros
> temos), PALIK matematiką + bendrą viktoriną + taip/ne + detektyvą + egzaminus, SULIEK klausimus
> pagal lygius, perkelk į NAUJĄ Firebase projektą, pritaikyk Amazonui (IAP, reklamos, R8 fix,
> naujas vardas), ir greitai paleisk bandymui. Kokybės taisyklės — kaip didžiajame. Tikslas — pereiti visą paleidimo kelią.
