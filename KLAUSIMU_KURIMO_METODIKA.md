# 🧠 KLAUSIMŲ KŪRIMO METODIKA — „Minalect Arena"

> **Vienintelė tiesa apie tai, KAIP ir KOKIUS klausimus kuriame.** Perskaityk VISĄ prieš
> rašydamas bet kokią naują klausimų partiją. Skirta žinių (trivijos) klausimams visose
> temose ir potemėse. Papildo `PERDAVIMAS_NAUJAI_SESIJAI.md` (bendra projekto būsena) ir
> `KLAUSIMU_STILIAUS_GIDAS.md` (10 stiliaus auksinių taisyklių).

---

## 0. ESMĖ — 4 RAMSČIAI (svarbos eile)

Kiekvieną sprendimą vertink pagal šiuos keturis:
1. **SAUGA** — server-authoritative; jokio nešvaraus/jautraus turinio.
2. **FAKTŲ TEISINGUMAS** — 100 % tikra, neginčijama, NEpasenę.
3. **ĮVAIROVĖ + ĮDOMUMAS** — „oho" faktai, nieko nuobodaus, nieko nesikartoja.
4. **UŽDARBIS** — (netiesiogiai: kuo įdomiau, tuo daugiau žaidėjų liks).

Savininkas **Mindaugas** — NE programuotojas, kalbam **lietuviškai, paprastai**. Pilna
autonomija aptartiems darbams; **bet jei kas NE 100 % aišku (ypač dizainas/išdėstymas) —
KLAUSK, nespėliok** (žr. perdavimas §1).

---

## 1. PROCESAS — nuo idėjos iki deploy (privaloma kiekvienai partijai)

1. **Idėja** → galvok PLAČIAI (potemės pavadinimas ≠ riba), ieškok „oho" faktų iš gyvenimo.
2. **Faktą patikrini** patikimuose šaltiniuose (žr. §4).
3. **Sukomplektuoji** klausimą (1 teisingas + 5 distraktoriai + paaiškinimas + emoji +
   `sourceVerified` + `subTheme`/`topic` + `level`).
4. **LT + EN iš karto** — natūraliai, NE pažodžiui (žr. §10).
5. **Validacija** (`validateContent.js` + `tsc` + ilgio kvapas) — žr. §8, §16.
6. **DVI QC bangos** (faktai + stilius per `Workflow`) — žr. §12. Ištaisai radinius.
7. **Deploy** (`startTriviaGame` arba `startNatureGame`) → APK (jei keitėsi Dart) → įdiegti →
   commit + push → atnaujinti perdavimą → pranešti savininkui ką tikrinti telefone.

---

## 2. 🟥 AUKSO TAISYKLĖ (savininkas kartoja NUOLAT — niekada nepažeisti)

1. **TOBULAS vertimas** — klausimas vienodai aiškus ir natūralus LT IR EN kalbėtojams;
   JOKIŲ stiliaus ar kultūrinių nesusipratimų. Versti pagal PRASMĘ / kultūrą, ne pažodžiui.
2. **JOKIO jautraus/nešvaraus turinio:** jokios politikos, religijos/tikėjimo, rasės,
   tautinių/sienų ginčų, **narkotikų, alkoholio, vaistų-kaip-svaigalų**, smurto, sekso,
   keiksmų, nešvarių/dviprasmiškų užuominų. Nieko, kas ką nors įžeistų bet kurioje šalyje.
   Saugu net 9 m. vaikui. (Gyvūnų nuodai/biologija — OK, tai gamta, ne svaigalai. Senovės
   mitologija — OK, atskira patvirtinta tema.)
3. **GARANTUOTAS šaltinis:** tik patikimi, neginčijami faktai. Neaiškus/nepatvirtintas/
   „gandų" faktas — NERAŠOMAS. Abejoji — metam.
4. **NAUJAUSIA info — turinys negali būti senas.** Žr. §3 „Griežta atrankos taisyklė".

---

## 2b. 🚦 GRIEŽTA ATRANKOS TAISYKLĖ (kintami skaičiai)

Klausimai apie **KINTAMUS skaičius/rekordus** („didžiausias / greičiausias / aukščiausias /
brangiausias / priklauso / čempionas…") privalo būti:
- (a) suformuluoti su **KONTEKSTU** — „pagal 2024 m. duomenis", „vienas didžiausių",
  „istoriškai", „daugelį metų"; **ARBA**
- (b) remtis **FUNDAMENTALIAIS, nekintamais** faktais.

Jei rekordas gali pasikeisti IR negali būti įrėmintas kontekstu — **NENAUDOTI.**
Realūs pavyzdžiai, kur tai išgelbėjo: Unilever ledai (2025-12 atskirti → perfrazuota
istoriškai); Shanghai maglev (greitis sumažintas → „projektinis"); Shinkansen vėlavimas
(„daugelį metų ~1 min"). **„Pranešti apie klaidą" mygtukas** (žr. perdavimas §11) — antras
saugiklis: žaidėjai praneš, jei mokslas pasikeitė.

---

## 3. POTEMIŲ IDĖJŲ PAIEŠKA (PIRMA sugalvoti, TADA rašyti)

Prieš rašant — sugalvok **įdomias, plačias** potemes (savininkas: „turi būti ir žmonėms
įdomios ir plačios, kad eitų klausimų prigalvoti"). Kiekviena potemė turi būti:
- **Iškart traukianti** smalsumą (ne sausa/akademiška); „oho" faktai, kuriais norisi dalintis.
- **Universali** — vienodai įdomi/teisinga bet kurioje šalyje.
- **SAUGI** (žr. §2).
- **GILI** — realiai ištempia **600+ klausimų** (4 lygiai × 150), su ĮVAIRIAIS faktais.
- **Skirtinga** nuo esamų ir viena nuo kitos.

Metodas: paleisti `Workflow` (po 1 agentą temai) idėjoms generuoti → susintetinti į meniu →
savininkas pasirenka. Pateik: LT+EN pavadinimą, emoji, trumpą „kabliuką", 3 pavyzdinius
klausimų kampus, kiek klausimų ištemptų.

---

## 4. ŠALTINIAI

✅ **TINKA:** enciklopedijos (Britannica, Wikipedia kryžmiškai), NASA, mokslo institucijos,
oficialios federacijos, Guinness, muziejai, recenzuoti tyrimai, oficiali prekės ženklo
istorija, patikimi naujienų šaltiniai.
❌ **NETINKA:** FB/blogai, forumai (kaip vienintelis šaltinis), gandai, neaiškios svetainės.

- **VIENAS NEGINČIJAMAS atsakymas** — aktyviai IEŠKOK alternatyvių teisingų atsakymų ir juos
  užkirsk (Jeopardy „pinning"). Jei distraktorius irgi gali būti teisingas — pakeisk jį.
- Saugotis MITŲ (ypač prekių ženklų vardų kilmės, „pirmas kada nors", gyvūnų gebėjimų).
  Pvz. realiai pagauta: Adidas ≠ akronimas; Porsche irgi turi žirgą; mantišrimpas 12 (ne 16)
  spalvų receptorių; chameleonas spalvą keičia ne tik slėpdamasis.
- `sourceVerified` laukas — trumpas EN šaltinio užrašas KIEKVIENAM klausimui (drausmina).

---

## 5. AMŽIAUS / SUNKUMO SKALĖ (GELEŽINĖ)

| Lygis (kodas) | Kas atspėtų |
|---|---|
| 🟢 `lengvas` | 9–12 m. **vaikas** |
| 🟡 `vidutinis` | 12–18 m. paauglys |
| 🔴 `sunkus` | suaugęs, kuris domisi |
| 🔥 `ekstremalus` | tos srities **žinovas** |

Sunkumą lemia **fakto RETUMAS, NE gudri formuluotė.** Prieš deploy savęs paklausk: „ar to
amžiaus žmogus tai žinotų?" Tas pats objektas gali būti keliuose lygiuose, JEI klausiama
KITO fakto (žemesnis lygis = plačiau žinomas; aukštesnis = obskurus/tikslūs skaičiai).

---

## 6. KIEKIO TIKSLAS + KŪRIMO TVARKA

- **GALUTINIS tikslas:** min. **150 klausimų VIENAM LYGIUI** (geriau daugiau) → **min. 600
  vienai POTEMEI** (4 × 150). Todėl potemės turi būti plačios (§3).
- **MINIMUMAS, kad serveris leistų žaisti:** **10 klausimų vienam lygiui** (=40 potemei).
  Mažiau → klientas rodo „Greitai", serveris meta „Per mažai klausimų".
- **KŪRIMO TVARKA:** naujos potemės kuriamos PRADŽIOJE po **10/lygiui (=40)**, kad greitai
  „supildytum" temas; vėliau partijomis pildoma iki 150+/lygiui.

---

## 7. VIENO KLAUSIMO FORMATAS (`TriviaQuestion`)

```ts
{
  id: "brn_fd_001",          // unikalus; prefiksas pagal potemę (žr. failus)
  category: "brands",        // TriviaCategory (arba "nature")
  subTheme: "food",          // potemės žyma
  topic: "superpowers",      // TIK Gamtai (NatureTopic); kitoms NEreikia
  level: "lengvas",          // lengvas | vidutinis | sunkus | ekstremalus
  isTrap: false,             // true tik tikriems „false friend" mitams
  sourceVerified: "…",       // EN šaltinio užrašas
  emoji: "🥤",               // NEUTRALUS, neišduoda atsakymo (žr. §9)
  translations: {
    en: { question, correct, distractors: [5], explanation },
    lt: { question, correct, distractors: [5], explanation },
  },
}
```
- `distractors` — TIKSLIAI 5 (serveris parenka 5 → 6 langeliai).
- `explanation` — 1 eilutės „fun-fact" KODĖL teisinga (mokomoji vertė).
- LT ir EN distraktoriai turi reikšti TĄ PATĮ (ta pati tvarka/sąvokos).

---

## 8. TECHNINIAI SAUGIKLIAI (PRIVALOMI)

1. **≤ 46 simboliai** — KIEKVIENAS variantas (correct + distraktoriai), KIEKVIENA kalba.
   Detales dėk į `explanation`, ne į variantą.
2. **„ILGIO KVAPAS"** (savininko exploitas „kur ilgesnis — spaudžiu, pataikau"): teisingas
   atsakymas NEGALI būti ilgiausias daugiau nei **+5 simb.** — bent vienas distraktorius
   panašaus ilgio ar ilgesnis. Tikrinti **ABIEM kalbom**. Jei teisingas ilgas → pailgink
   1–2 distraktorius (jie ir taip klaidingi — faktų tikrinti nereikia). Įrankis:
   `_audit_*.js` (kopijuok šabloną naujai temai).
3. **VIENAS neginčijamas atsakymas** (žr. §4).
4. **Jokio atsakymo klausime;** emoji neišduoda atsakymo (§9).
5. **Jokių dublikatų** — nei to paties klausimo/fakto lygyje, nei TARP lygių, nei tarp
   potemių (rotacija per temą!). Tas pats objektas kitu faktu — OK.
6. **Kultūrinis universalumas;** patarlės/citatos/posakiai — **NEKURIAMI NIEKADA**.

---

## 9. EMOJI TAISYKLĖS (savininkas skiria DU dalykus)

1. **KLAUSIMO emoji (`q.emoji`)** — vienas, prie klausimo. **NIEKADA neišduoda atsakymo:**
   jokių vėliavų, kai atsakymas yra šalis; jokio daikto, kuris IR YRA atsakymas. Turi būti
   BENDRINIS, neutralus teminis ženklas, **ĮVAIRUS** (ne vienodas ant visų klausimų).
   Pvz. gerai: 🥤 maisto temai, 🧠/🛠️/🪞 gyvūnų protui, 🚗 automobiliams.
2. **ATSAKYMŲ mygtukų emoji** (`emojiForOption`, `themeEmoji.ts`) — vėliavos prie šalių,
   instrumentai ir kt. GERAI; veikia „viskas-arba-nieko" (rodoma TIK jei VISI 6 turi savą,
   unikalų, neišduodantį) — NELIESTI logikos. Nauja tema → pridėti `THEME_FALLBACK[kodas]`.

---

## 10. LIETUVIŲ KALBA — NATŪRALI, ne pažodinė (DU DIDELI SPĄSTAI!)

Savininkas: „lietuviškai taip nesirašo." LT turi skambėti kaip parašė gimtakalbis.

**🚨 SPĄSTAS #1 — KABANTIS KLAUSIMO ŽODIS (dažniausia mano klaida!):**
NIEKADA nepalik klausimo, pasibaigiančio kabančiu klausimo žodžiu „…ką? / …kur? / …kas? /
…ko? / …kaip? / …kuo? / …kurį X?" (tai pažodinė anglų „…what/where?" kalkė). **KELK
klausimo žodį į PRIEKĮ.**
- ❌ „Aštuonkojo smegenų ląstelės netikėtai yra **kur**?"
- ✅ „**Kur** netikėtai yra daugiausia aštuonkojo smegenų ląstelių?"
- ❌ „…delfinai rodo metapažinimą — kada jie **ką**?"
- ✅ „**Ką** tiksliai pajunta delfinai, rodydami metapažinimą?"

**🚨 SPĄSTAS #2 — VIDINĖS KABUTĖS (sugriauna `tsc` build'ą!):**
LT tekste **VENK vidinių kabučių VISAI** (perfrazuok). Jei naudoji ASCII `"` viduje — ji
nutraukia JS string'ą → klaidų kaskada. (Jei BŪTINA — tik U+201E „atidaro / U+201D " uždaro,
NIEKADA ASCII `"` ir NIEKADA U+201C.) Geriausia tiesiog be jų.

**Kiti dažni LT spąstai:**
- **Giminės/linksnio nesutapimas** („juodasis dėžė" → „juodoji dėžė"; „pirmasis ataka" →
  „pirmoji ataka"; moteriškos g. daiktavardžiai).
- **Kalkės:** „išėjo į pensiją" (apie įmonę), „spaudžia saloną" (slėgis), „važiuoja" (laivas),
  „griuvėsiuose" (lėktuvo → „nuolaužose"), „laikė laiką", „balanso cisternos" (→ „balasto").
- **Sugalvoti/ne LT žodžiai:** „prikilis", „ilgaplaučius", „spūda", „nerimavo" (=nerimo, o
  reikia „nesirimuoja"), „bendraįkūris" (→ „bendraįkūrėjas"), „tranšėjinis paltas" (→
  „trenčkotas"). „famously" ≠ „garsiai" (=loudly) → „pagarsėjo".
- **EN↔LT distraktorių neatitikimas** (turi reikšti tą patį).

---

## 11. SSRS / JAUTRŪS NIUANSAI

- Atsakymas „Sovietų Sąjunga" kaip VALSTYBĖ — NE. Faktai/pavardės — OK (Gagarinas,
  Tereškova, Maskva, „Rusija didžiausia", carai, „Rusija" distraktoriuose). Paaiškinimuose
  SSRS švelninti per objektą/asmenį.

---

## 12. DVI QC BANGOS (privaloma KIEKVIENAI partijai)

Po kiekvienos naujos partijos — DU atskiri adversariniai `Workflow` (token'ų netaupom):

**🔬 1) FAKTŲ PATIKRA** — skeptikai/chunk su WEB paieška, nusiteikę PANEIGTI. Tikrina:
faktas teisingas? atsakymas VIENINTELIS gintinas? distraktorius irgi tinka? nepasenęs?
nejautrus? Schema: `{id, severity(wrong|alt-correct|outdated|sensitive|minor), problem, fix}`.

**🔤 2) LT/EN STILIAUS PATIKRA** — 1 redaktorius/failui skaito LT+EN, žymi kalkes, giminę,
spąstą #1 (kabantis žodis), typos su natūraliais rewrite'ais. Schema:
`{id, lang, field, problem, rewrite}`.

⚠️ **Rate-limit:** per daug lygiagrečių agentų → „Server is temporarily limiting requests".
Tada — mažiau agentų (po 1 failui) arba pakartoti (resume). Po pataisymų — VĖL build+validacija+
ilgio kvapas. Taisymus dideliems kiekiams patogu daryti per fix-`Workflow` (1 Opus agentas/failui).

---

## 13. DRAFT METODAS — Sonnet vs Opus (kada kuris)

| | Sonnet juodraščiai → Opus QC | Opus rašo pats |
|---|---|---|
| Pirmas juodraštis | greitas | lėtesnis |
| LT kalba | **labai nešvari** (transporte 117 stiliaus klaidų → reikėjo PILNO Opus perrašymo) | **švari iš karto** |
| Bendras laikas | ilgesnis (perrašymas) | trumpesnis |

**Išvada:** mažam/kokybės kritiškam kiekiui — **Opus rašo pats**. Sonnet apsimoka TIK
dideliems kiekiams, ir VIS TIEK reikia pilno Opus LT perrašymo po jo. Bet kuriuo atveju —
2 QC bangos privalomos.

---

## 14. RECIPE: pridėti POTEMĘ

### A) BENDRA tema (pop/geo/history/tech/food/sport/body/cosmos/mythology/records/brands/transport)
1. Naujas MAŽAS failas `src/<tema><Potemė>.ts` (40 kl., 10/lygiui, `subTheme:"<kodas>"`).
2. Indekse `src/<tema>Content.ts`: importuok + `...SPREAD`.
3. `subThemeConfig.ts` — `<tema>: { …, <kodas>: ["<kodas>"] }`.
4. Klientas `trivia_topic_screen.dart` — `case '<tema>'` pridėk potemės kortelę (`open:true`).
5. `app_strings.dart` — `sub<…>` + `Desc` (LT+EN).
6. Patikra → faktų+stiliaus Workflow → pataisos → deploy `startTriviaGame` → (jei keitei
   klientą) APK → commit.

### B) GAMTA (skiriasi! — `NatureTopic` + `startNatureGame`, NE subThemeConfig)
1. `triviaTypes.ts` — `NatureTopic` += `"<kodas>"`.
2. Naujas mažas failas `src/nature<Potemė>.ts` (klausimai su `category:"nature"`,
   `topic:"<kodas>"`, `subTheme:"<kodas>"`).
3. `natureContent.ts` — importuok + `...SPREAD` masyvo pradžioje (monolito neaugink).
4. `triviaFunctions.ts` — `NATURE_TOPICS` += `"<kodas>"`.
5. Klientas `nature_topic_screen.dart` — pridėk `_TopicEntry` kortelę.
6. `app_strings.dart` — `topic<…>` + `Desc` (LT+EN).
7. Patikra → Workflow → deploy `startNatureGame` → APK → commit.

---

## 15. RECIPE: pridėti naują TEMĄ (pilnas wiring)
1. Turinys: maži failai potemėms + plonas indeksas `src/<tema>Content.ts`.
2. `triviaTypes.ts` — `TriviaCategory` += `"<kodas>"`.
3. `triviaRegistry.ts` — import + įrašas `<kodas>: <TEMA>_QUESTIONS`.
4. `subThemeConfig.ts` — `<kodas>: { potemė:[…], … }`.
5. `unlockConfig.ts` — `OPEN_TRIVIA_CATEGORIES` += `"<kodas>"`.
6. `themeEmoji.ts` — `THEME_FALLBACK` += `<kodas>: "🙂"` ⚠️ BŪTINA (`Record<TriviaCategory>`!).
7. `app_theme.dart` — nauja SAVA spalva `themeX` (gretimos kortelės — skirtingos!).
8. `theme_catalog.dart` — `GameTheme(code, emoji, accent, kind:trivia, open:true, title, subtitle)`.
9. `trivia_topic_screen.dart` — `hasSubThemes` += kodas; `case '<kodas>'` su potemėmis (+mix).
10. `app_strings.dart` — `categoryX`/`Desc` + potemių tekstai (LT+EN).
11. Patikra → Workflow → deploy → APK → commit → atnaujink perdavimą.

---

## 16. ĮRANKIAI (`phase2_backend/functions/`, untracked `_*.js`)

- `npm run build` — `tsc` (privaloma; pagauna kabučių spąstą #2).
- `node validateContent.js src/<failas>.ts` — id unikalumas, ≤46, 5 distraktoriai, dublikatai,
  ASCII kabutė po „.
- `_audit_<tema>.js` — ilgio kvapas (correct vs ilgiausias distraktorius; ryškūs = ≥6).
  Kopijuok šabloną naujai temai (lib/ keliai).
- Deploy: `npx --prefix "<…>/functions" firebase-tools deploy --only "functions:X"
  --config "<…>/phase2_backend/firebase.json" --project math-game-9862f`.
- Telefonas: `flutter build apk --debug` (TIK debug — release crashina) → `adb -s R5CX221CT5N
  install -r …app-debug.apk`. Ekrano patikra: `adb exec-out screencap -p > file`.

---

## 17. PAMOKOS / DAŽNOS KLAIDOS (realiai pasitaikė)

- **Kabantis klausimo žodis** (§10 spąstas #1) — DAŽNIAUSIA; tikrink KIEKVIENĄ LT klausimą.
- **Vidinės kabutės** (§10 spąstas #2) — sugriauna build'ą; venk visai.
- **Ilgio kvapas** po fix'ų vėl atsiranda — VISADA peraudito po keitimų.
- **Mitai kaip faktai** — Adidas akronimas, Porsche be žirgo, mantišrimpas 16, Toblerone
  forma nuo Matterhorno — visi NETEISINGI; QC pagauna.
- **Pasenę rekordai** — Unilever ledai, maglev greitis — frazuok istoriškai/su kontekstu.
- **Sonnet LT** — labai nešvari; po Sonnet BŪTINA pilna Opus LT peržiūra.
- **Rate-limit** Workflow'uose — mažink lygiagrečių agentų.

---

## 18. ✅ KONTROLINIS SĄRAŠAS prieš deploy (kiekvienai partijai)

- [ ] 10/lygiui (=40 potemei), 4 lygiai subalansuoti.
- [ ] Visi variantai ≤46 simb. (LT+EN).
- [ ] Ilgio kvapas: 0 ryškių (`_audit`).
- [ ] Vienas neginčijamas atsakymas; jokio alt-correct distraktoriaus.
- [ ] Jokio atsakymo klausime; q.emoji neutralus + įvairus.
- [ ] Jokių dublikatų (lygyje/tarp lygių/tarp potemių).
- [ ] LT natūrali; jokio kabančio klausimo žodžio; jokių vidinių kabučių.
- [ ] Jokio nešvaraus/jautraus/pasenusio turinio; kintami skaičiai su kontekstu.
- [ ] `tsc` OK · `validateContent` OK · faktų Workflow OK · stiliaus Workflow OK.
- [ ] Deploy → (APK jei Dart keitėsi) → commit+push → perdavimas atnaujintas → pranešta.
