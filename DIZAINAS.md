# 🎨 ŽAIDIMO DIZAINAS (sprendimai „ant popieriaus")

> Čia surašom VISUS sprendimus dėl žaidimo PRIEŠ statydami.
> Sprendžiam po vieną, kartu. Nieko nestatom, kol nesutarta.
> ✅ = sutarta · 🔄 = sprendžiam dabar · ⬜ = dar nesvarstyta

| # | Sprendimas | Statusas |
|---|-----------|----------|
| 0 | **Kalbos: lietuvių + anglų (i18n nuo pradžių)** | ✅ |
| 1 | Matematikos veiksmai (+ − × ÷) | ✅ |
| 2 | Sunkumo lygiai (4 lygiai × 4 veiksmai = 16 režimų) | ✅ |
| 3 | Klausimų skaičius per žaidimą (10 visada) | ✅ |
| 4 | Atsakymų variantai (6, panašūs klaidingi) | ✅ |
| 5 | Taškų skaičiavimas (server-authoritative) | ✅ |
| 6 | Kas vyksta suklydus (ŠVELNUS — visada 10) | ✅ |
| 7 | Laikmatis (neoninis žiedas, žalia→geltona→raudona) | ✅ |
| 8 | Vizualinis stilius (Cyber-Neumorphism) | ✅ |

---

## ✅ 1. Matematikos veiksmai
**Sprendimas:** Visi keturi — **sudėtis (+), atimtis (−), daugyba (×), dalyba (÷)**.
**Pastaba:** statysim po vieną, pradėsim nuo sudėties. Kiekvienas veiksmas — atskiras režimas.

---

## ✅ 2. Sunkumo lygiai — 4 lygiai × 4 veiksmai = 16 režimų
**Struktūra:** 4 lygiai — 🟢 Lengvas, 🟡 Vidutinis, 🔴 Sunkus, 🔥 Ekstremalus. Kiekvienas su visais 4 veiksmais → **16 režimų**.

| Veiksmas | 🟢 Lengvas (~50) | 🟡 Vidutinis (~150) | 🔴 Sunkus (~300) | 🔥 Ekstremalus (500+) |
|---|---|---|---|---|
| Sudėtis (+) | vienaženkliai 1–9 | dviž.+vienaž. `24+7` | dviž.+dviž. `34+27` | triženkliai / lygtys `32+?=75` |
| Atimtis (−) | 1–9 (rez. ≥0) | `45−9` | `83−45` | triženkliai / lygtys |
| Daugyba (×) | ×2–5 (~25–30) | ×2–10 (~70–80) | iki ×12 + kvadratai iki 20² (~144) | 13–25 × vienaženklis (200+) |
| Dalyba (÷) | atvirkštinė ×2–5 | atvirkštinė ×2–10 | atvirkštinė iki ×12 | triženklis ÷ vienaženklis |

*Dalyba = daugybos atvirkštinė (visada sveikas rezultatas, be trupmenų).*
*„~50…500+" = teorinis variantų skaičius, NE saugomas sąrašas. Serveris generuoja gyvai pagal ribas.*

### Architektūra: vienas variklis, 16 nustatymų
16 režimų NEPROGRAMUOJAM 16 kartų. Viena funkcija `generateMathQuestion(veiksmas, lygis)` + nustatymų lentelė. (Mūsų 2 taisyklė — moduliai.)

### 🔄 Sunkumą reguliuoja ir klaidingi atsakymai
- 🟢 Lengvas: klaidingi dalis arti, dalis toliau (atlaidžiau).
- 🔥 Ekstremalus: visi klaidingi labai arti (tikslumas privalomas).

---

## ✅ 3. Užduočių per sesiją: **10 (visada)**
Viena sesija = 10 užduočių. Suklydus žaidimas tęsiasi (švelnus modelis, žr. 6 sprendimą). Maksimalus rekordas = teisingai ir greitai visi 10.

---

## ✅ 4. Atsakymų variantai — 6 mygtukai, 1 teisingas
**Pagrindinė taisyklė:** 6 variantai, tik 1 teisingas. Kiti 5 — **„psichologiškai artimi" klaidingi**, kad žaidėjas TURĖTŲ skaičiuoti, ne atmesti nesąmones.

**Klaidingų generavimas pagal žmogiškų klaidų šablonus:**
- **A — kaimyninė lentelė:** `(a±1)×b` arba `a×(b±1)` (pvz. `6×7` → `5×7=35`, `6×8=48`)
- **B — skaitmenų sukeitimas:** `42` → `24`
- **C — operacijos sumaišymas:** `a+b` (pvz. `6+7=13`)
- **D — maža paklaida:** `atsakymas ±1, ±2, ±10`

**Pavyzdys ekrane:** `6×7` → variantai `35, 44, 42, 13, 24, 48`.

**🔒 Privalomos apsaugos (kraštutiniai atvejai):**
1. Joks klaidingas ≠ teisingam (jei sutampa — generuoti kitą).
2. Skaitmenų sukeitimas tik kai ≥ 2 skaitmenys (kitaip atsarginis šablonas).
3. Visi klaidingi variantai > 0 (jokių neigiamų / nulio).
4. Visada 6 SKIRTINGI variantai; jei trūksta — pildyti atsarginiu (`±3, ±4`, ir aukštyn, IR žemyn).
5. Teisingas atsidūręs atsitiktinėje pozicijoje (shuffle).
6. Maišymas — **TIKRAS Fisher-Yates**, NE `sort(()=>Math.random()-0.5)` (tas šališkas).
7. Generatorius dengia **visus 4 veiksmus** (+ − × ÷): bendri klaidingi „pagal atsakymą" (`answer±1/±2/±10`, skaitmenų sukeitimas) + operacijos-specifiniai „kaimynai" tik ×/÷.

**Generavimas vyksta SERVERYJE (Fazė 2):** `generateMathQuestion` sugeneruoja veiksmą + 5 klaidingus + sumaišo, ir siunčia telefonui gatavą masyvą `[35,44,42,13,24,48]`. Telefonas „kvailas" — tik nupiešia 6 mygtukus.

**Apimtis:** v1 = klasikinis `6×7=?` + trūkstamas narys `6×?=42`. v2 (vėliau) = „kuris veiksmas lygus 42?".

---

## ✅ Rotacijos sistema (kad neatsibostų)
- `users/{uid}` saugo paskutinių **N** parodytų klausimų ID (pvz. `"6x7"`).
- `startGame` generuodamas tikrina sąrašą; jei klausimas jame — metam, generuojam kitą.
- ⚠️ **Apsauga (kritinė):** atmintis negali viršyti (sandėlis − 10), kitaip neužteks 10 unikalių vienai sesijai → `N = min(30, sandėlis − 10)`. Pvz. Lengva × (sandėlis 25) → N ≤ 15.
- Garantija: tas pats klausimas nepasirodo du žaidimus iš eilės.

---

## ✅ 5. Taškų skaičiavimas (server-authoritative)
**Idėja:** teisingas atsakymas = BAZĖ + greičio bonusas. Klaida = 0.

| Lygis | MAX laikas/langelį | BAZĖ | Maks. bonusas | Maks./langelį |
|-------|--------------------|------|---------------|---------------|
| 🟢 Lengvas | 3000 ms | 50 | +300 | 350 |
| 🟡 Vidutinis | 4000 ms | 100 | +400 | 500 |
| 🔴 Sunkus | 5000 ms | 150 | +500 | 650 |
| 🔥 Ekstremalus | 6000 ms | 200 | +600 | 800 |

**🔒 Saugi formulė (skaičiuojama SERVERYJE iš patikimų duomenų):**
```
score = teisingų × BAZĖ + max(0, (teisingų × MAX − serverioBendrasLaikas) / 10)
```
- `teisingų` ir `serverioBendrasLaikas` — abu iš serverio (telefonu NEpasitikim).
- Greičio bonusas NEskaičiuojamas iš telefono per-langelį laikų (nes sukčius galėtų meluoti, kad atsakė greičiau). Formulė tiesinė → svarbu tik bendras laikas.
- Telefonas gali RODYTI apytikslius „+280" (kosmetika), bet oficialų rezultatą sprendžia serveris.
- `Math.floor` (sveiki taškai). Teisingas užskaitomas tik jei langelio laikas < MAX.

**Lyderių lentelė:** atskira kiekvienam iš 16 režimų (`leaderboard/{uid}_{mode}`) — kad lygiai nesimaišytų.

### 🔑 Atsakymų matomumas telefone (sprendimas J žingsniui)
**Sprendimas: serveris GRĄŽINA atsakymus su klausimais** (variantas C).
- **Kodėl saugu:** taškus skaičiuoja serveris iš BENDRO LAIKO, ne iš „kiek teisingų telefonas sako". Net jei sukčius ištraukia atsakymus iš atminties — laimi 0 (laikas tikras, botų filtras veikia). Atsakymų slėpimas nieko negina.
- **Kodėl gerai:** telefonas rodo momentinį žalia/raudona feedback (geras UX).
- **Privaloma sąlyga:** `submitScore` serveryje PATS perskaičiuoja teisingus (jau daro). Telefono verdiktas — tik vizualas; oficialus — iš serverio.
- **Migracija J:** `startGame` grąžina ir `answer` lauką (1 eil.); `GameProvider` ima atsakymą iš serverio duomenų (logika ta pati).

---

## ✅ 6. Kas vyksta suklydus — Švelnus modelis (visada 10 langelių)
- Klaida (neteisingas atsakymas ARBA pasibaigęs laikas) → langelis raudonas (shake), 0 taškų UŽ TĄ LANGELĮ, bet žaidimas **TĘSIASI** iki 10-to.
- Rezultatų ekrane: „Atsakei 7/10" + taškai. Draugiška, motyvuoja bandyti vėl.
- **Tunable per Remote Config** (Fazė 6): galėsim įjungti „staigią mirtį" ar „N gyvybių" be naujo leidimo.

### 🔄 Rewarded reklama — mechanika LAUKIA sprendimo (leaderboard sąžiningumas)
⚠️ „+2 langeliai už reklamą" leistų ad-žiūrovams surinkti daugiau taškų nei nežiūrintiems → „nusiperka" vietą lentelėje (prieštarauja prestižui). Variantai:
- **(A)** Rewarded → monetos → temos/avatarai (NEliečia leaderboard) — sąžiningiausia ⭐
- **(B)** „+2 langeliai" tik į asmeninį rezultatą, NE į globalų top
- **(C)** Priimam „ad-boosted" lentelę (praranda prestižą)
Interstitial (po žaidimo, su cooldown) — pagrindinės pajamos, fairness netaikoma.

---

## ✅ 7. Laikmatis — hibridinis (neoninė juosta + skaitiklis)
- Ekrano viršuje tolygiai mažėja neoninė linija (lygio spalva: žalia/geltona/oranžinė/raudona).
- Šalia — minimalistiškas skaitiklis (pvz. `3.4s`).
- < 1.5 s likus: juosta + skaitiklis pulsuoja raudonai (streso dozė).
- Laikas pagal lygį (5 sprendimas): 3/4/5/6 s. Laikui baigusis = klaida (0 taškų), pereina prie kito langelio.
- **Vizualas:** plonas neoninis ŽIEDAS aplink langelį, tuštėja pagal laikrodžio rodyklę; spalva žalia→geltona→raudona; < 1.5 s pulsuoja (ScaleTransition). Flutter: `AnimationController` + custom painter / `CircularProgressIndicator`.

---

## ✅ 8. Vizualinis stilius — Cyber-Neumorphism (tamsus + neon)
| Rolė | Spalva |
|------|--------|
| Fonas | `#121214` (kiber-anglis) |
| Langeliai | `#1A1A1E` + dvigubi šešėliai (tamsus `#0A0A0C` apačia-dešinė, šviesus `#232329` viršus-kairė) |
| Skaičiai (tekstas) | `#F5F7FA` (aukštas kontrastas, NE neon) |
| Antrinis tekstas | `#9AA0AD` |
| 🟢 Lengvas | mint `#3DF5A0` |
| 🟡 Vidutinis | elektrinė geltona `#FFE03D` |
| 🔴 Sunkus | neon rožinė `#FF4D8D` |
| 🔥 Ekstremalus | ultravioletinė `#B14EFF` |
| Teisinga | žalias pulse `#2BD576` + ✓ |
| Klaida | shake + raudonas blyksnis `#FF3B5C` |

**Kokybės saugikliai:** (1) skaičiai aukšto kontrasto, neon tik briaunoms/žiedui; (2) sunkus lygis = rožinė (ne raudona), kad nesimaišytų su „klaida=raudona", kurią skiria judesys (shake); (3) langeliai aiškiai atrodo paspaudžiami (neon briauna); (4) švytėjimai subtilūs — testuoti 60fps ant pigių telefonų.

---

## ✅ 0. Kalbos — Lietuvių + Anglų (i18n nuo pradžių)
Visas vartotojui matomas tekstas turi turėti **LT ir EN** versijas. Įgyvendinam centralizuotai (vienas `AppStrings`/`l10n` modulis), kad nereikėtų vėliau perrašinėti visų ekranų.
- **Niekada nehardcodinam teksto** ekranuose — visada per vertimų raktą (mūsų 2 ir 3 taisyklės).
- Kalbos perjungimas: pagal telefono kalbą + rankinis perjungiklis nustatymuose (vėliau).
- Pradžioje statom su LT+EN paruošta struktūra, kitas kalbas galima pridėti vėliau be perrašymo.

---

## 🔄 V2 PATOBULINIMAI (sutarta, programuojam rytoj)

### 9. Laikmatis — keičiam į „skaičiuoja AUKŠTYN" + 30s riba
**Senas modelis (atmestas):** laikas mažėja, baigėsi = klaida.
**Naujas (sutarta):**
- Laikas **tiksi aukštyn**, žiedas **pilnėja** (nuo tuščio iki pilno per 30s).
- **NEsibaigia**, kol nepaspaudi atsakymo (be streso).
- Taškai = pagal tai, per kiek laiko atsakei (greičiau = daugiau).
- **Viršutinė riba: 30 s** — pasiekus, langelis automatiškai užskaitomas kaip
  praleistas/minimumas (kad žaidimas nekabėtų, statistika nesugestų).

**Nauja taškų formulė (serveris):**
`score = max(10, MaxPoints − (sekundės × PenaltyMultiplier))`
- Greitas atsakymas → ~MaxPoints; lėtas (iki 30s) → stabilus minimumas (~10).
- Klaida = 0.
- **Saugumas išlieka:** serveris matuoja bendrą laiką (dabar−createdAt);
  lėtas atsakymas = mažiau taškų; laukti neapsimoka. Reikės perskaičiuoti
  formulę serveryje + naujas deploy.

### 10. Mygtukai: Baigti / Išeiti
- **Žaidimo ekrane:** „✕ Baigti" → kiber-neumorfinis popup „Ar tikrai? Šios
  sesijos taškai bus prarasti" → grįžta į meniu (rezultatas NEsiunčiamas).
- **Meniu:** „Išeiti iš žaidimo" → `SystemNavigator.pop()`.
- Saugumas: nebaigtas žaidimas nesiunčiamas; `active_games` valo TTL.

### 11. Vartotojo profilis + getMyRank
- Naujas **Profilio** ekranas (mygtukas meniu).
- Rodo 16 režimų; prie kiekvieno — tavo geriausias rezultatas.
- Paspaudus režimą → Top 10 + **tavo pozicija** („14-as iš 320").
- **Nauja Cloud Function `getMyRank`** (serveris suskaičiuoja poziciją —
  saugu + pigu, NE klientas skaito visus). Dera su „serveris=smegenys".
- **Vardo įvedimas:** pirmą kartą profilyje — „Įvesk kiber-vardą"; rašom į
  `users/{uid}`, serveris SANITIZUOJA (jau turim logiką).

### 12. Kalbos perjungiklis
- Mygtukas meniu (🌐 LT/EN), pasirinkimas išsaugomas (shared_preferences).
- `language_controller.dart` jau paruoštas — liko prijungti.

---

## 📝 V3 DARBAI (vėliau — sudėtingumo tobulinimas)
**Problema:** Ekstremalus lygis per lengvas, ypač daugyba/dalyba (~189 variantų,
kartojasi). Sudėtis/atimtis ten 90 000 — disbalansas.

**Ką daryti (sutarta, ne dabar):**
- Padidinti Ekstremalaus ×/÷ ribas (pvz. 15-50 × 6-15 → tūkstančiai variantų).
- Apsvarstyti 5-tą lygį („Genijus"?) — dar sunkesnis.
- Subalansuoti visus 16 režimų, kad kiekvienas turėtų pakankamai variantų.
- Galbūt mišrūs veiksmai Ekstremaliame (pvz. `3+4×2`).
- Tikslas: kiekvienas režimas ≥ 300 variantų, kad rotacija (30) veiktų gerai.

**Priminimas (variantų skaičiai dabar):**
| | Lengv | Vidut | Sunk | Ekstr |
|-|-------|-------|------|-------|
| + − | ~45 | ~900 | ~8100 | ~90000 |
| × ÷ | ~16 | ~81 | ~121 | ~189 ← per mažai |

**Sesija:** 10 unikalių/žaidimą; rotacija atsimena paskutinius N=min(30, sandėlis−10).
**Rotacija veikia TIK online** (serveryje); offline (web) — atsitiktinai.

---

## 💰 COINS SISTEMA (išdirbta, NE dabar — po profilio)
**Score ≠ Coins (variantas a):** Score = leaderboard prestižas (nesikeičia perkant);
Coins = atskira valiuta atrakinimui.

**Kiek coins/sesiją:** 1 teisingas = 1 coin + greičio bonusas (<3s = +1 coin).
Maks. idealus = 20/sesiją; vidutinis ~10-12. (NE fiksuotai — kitaip aklai spaudžia.)

**Kur saugomi:** SERVERYJE `users/{uid}.coins` (NIEKADA telefone — sukčiai).
Pridedami serverio submitScore metu (kartu su score skaičiavimu).

**Už ką:** universali piniginė — VISI žaidimai (matematika, geografija...) renka
į tą patį balansą. Apjungia ekosistemą.

**Kainos:** lygio atrakinimas ~150 coins (~10-15 sesijų); pilnos temos ~500 coins
(arba rewarded reklamos / IAP prenumerata).

**Sauga (Google Play):** atrakinimas/coins keitimas TIK per serverį (Cloud Function),
klientas negali pats pridėti. IAP validuojami serveryje.

---

## 👤 PROFILIS + getMyRank (IŠDIRBTA — Etapas 1)
**1. Vardas — NEprivalomas:** pirmą kartą auto `Player_XXXX` (4 atsitiktiniai skaičiai)
→ `users/{uid}.username`. Redaguojamas ✏️ (serveris sanitizuoja). Jokios „trinties".

**2. Vaizdas — GRUPUOTA (ExpansionTile):** 4 sekcijos (Sudėtis/Atimtis/Daugyba/Dalyba),
paspaudus išsiskleidžia 4 lygiai su Personal Best. Be skrolinimo.

**3. getMyRank — TIK paspaudus režimą:**
- Profilis rodo Personal Best (pigus skaitymas iš `leaderboard/{uid}_{mode}`).
- Paspaudus režimą → popup → TADA getMyRank Cloud Function: „pozicija 14 iš 320" + Top10.
- Taupo 90% serverio resursų (NE 16 kvietimų iškart).

**getMyRank logika:** `count(score > tavo_score) + 1` (Firestore count query — pigu).
enforceAppCheck + Auth (kaip kitos funkcijos).

**Web/offline:** jei Firebase nepasiekiamas → „Offline" vietoj „Dar nežaista".
Tikri duomenys — tikroje Android app.

---

## 🆕 „TAIP / NE" MECHANIKA — DU ATSKIRI REŽIMAI (sprendimas ant popieriaus, NE dabar)

> ⚠️ Svarbu: „Taip / Ne" NĖRA vien Blitz. Tas pats mygtukų principas (Taip/Ne)
> naudojamas DVIEM VISIŠKAI skirtingiems žaidimams. Aprašom, **kaip atrodys**,
> kad vėliau nereikėtų perdaryti. Nieko nestatom, kol nesutarta + „OK, darom".
> Bendra su trivija: serveris=smegenys, App Check, taškai/monetos iš serverio.

### A) ⚡ BLITZ — greitas „Taip ar Ne" (faktų patikra)
**Idėja:** ekrane vienas TEIGINYS (faktas), žaidėjas kuo greičiau spaudžia
**TAIP** arba **NE**. Tempas — pagrindinis jausmas (adrenalinas).

**Kaip atrodys (ekranas):**
- Viršuje — neoninis laikmačio žiedas (kaip trivijoje), bet **trumpas: ~2–3 s**.
- Centre — didelis teiginys, pvz. „Banginis yra žuvis".
- Apačioje — **2 dideli mygtukai:** ✅ TAIP (žalias) · ❌ NE (raudonas).
- Po atsakymo — žalias pulse / raudonas shake (kaip trivijoje), iškart kitas.

**Mechanika (skiriasi nuo trivijos):**
- **Gyvybės** (pvz. 3 ❤️) — suklydus arba pavėlavus dingsta 1; 0 → žaidimas baigtas.
- **Serija (streak)** — kuo daugiau teisingų iš eilės, tuo didesnis taškų daugiklis.
- Klausimų NĖRA fiksuotai 10 — žaidi, kol turi gyvybių (begalinis srautas).
- Turinys: trumpi teiginiai su lauku „ar tiesa?" (`true/false`) — NE 6 variantai.

### B) 🕵️ ATSPĖK ŽODĮ — dedukcija per „Taip / Ne" užuominas
**Idėja:** mes iš anksto sukuriam temą su **paslėptu žodžiu** ir prie jo ~**50 paruoštų
klausimų** su atsakymais Taip/Ne. Žaidėjas **spaudžia klausimus**, žaidimas atsako
**Taip arba Ne** (iš įrašytų duomenų), o žaidėjas iš užuominų turi **atspėti žodį**.
Stilius: Akinator / „20 klausimų". (Tai NE Blitz — tempo nėra, čia galvosūkis.)

**Kaip atrodys (ekranas):**
- Viršuje — tema ir „Atspėk paslėptą žodį" + skaitliukas (kiek klausimų panaudota).
- Centre — **paruoštų klausimų sąrašas** (pvz. „Ar tai gyvas?", „Ar didesnis už katę?").
  Žaidėjas spaudžia klausimą → šalia atsiranda atsakymas **✅ Taip** arba **❌ Ne**.
- Panaudoti klausimai lieka istorijoje (kad matytum surinktas užuominas).
- Apačioje — mygtukas **„Spėti žodį"** → laukelis įvesti spėjimą (kaip mįslėse).

**Mechanika:**
- **Riboti spaudimai/spėjimai** — kuo mažiau klausimų panaudoji iki teisingo spėjimo,
  tuo daugiau taškų (skatina mąstyti, ne spausti viską iš eilės).
- Atsakymai Taip/Ne — **iš anksto įrašyti** prie kiekvieno žodžio (serveris saugo,
  klientas tik rodo) → jokio „gyvo" sprendimo telefone, sukčiauti neapsimoka.
- Spėjimo tikrinimas — kaip mįslėse (`normalizeGuess`: mažosios raidės, diakritikai
  išlaikomi, tarpai/skyryba suvienodinami).
- Turinio vienetas: `{ žodis, [50 klausimų su true/false], užuominos kalboms }`.

### Kodėl du atskiri turinio modeliai (svarbu turiniui)
| | ⚡ Blitz | 🕵️ Atspėk žodį |
|---|---|---|
| Turinio vienetas | teiginys + `true/false` | žodis + ~50 klausimų(`true/false`) |
| Žaidėjo veiksmas | spaudžia Taip/Ne į teiginį | spaudžia klausimus, tada spėja žodį |
| Jausmas | greitis, adrenalinas | dedukcija, galvosūkis |
| Laikmatis | trumpas (~2–3 s) | nėra spaudimo (mąstymas) |
| Pabaiga | gyvybės baigėsi | atspėjo / baigėsi spėjimai |

**Statusas dabar:** abiem režimams paruošta tik STRUKTŪRINĖ vieta
(`blitz_placeholder_screen.dart` rodo „Greitai"). Mechanika ir turinys — vėliau,
atskirai (potemes ir tikslias turinio taisykles savininkas pateiks atskirai).
