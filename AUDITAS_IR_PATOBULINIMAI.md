# BRAIN ARENA — pilnas auditas ir patobulinimų planas

Data: 2026-06-12 · Pagrindas: [ZAIDIMO_VEIKIMAS_IR_AUDITAS.md](ZAIDIMO_VEIKIMAS_IR_AUDITAS.md)
Tikslas: komercinis žaidimas, kuriame žmonės **norėtų praleisti valandų valandas**.

---

## 1. PLIUSAI — kas jau padaryta gerai (ir kodėl tai vertinga)

| # | Pliusas | Kodėl tai svarbu |
|---|---------|------------------|
| 1 | **Serveris — teisėjas** (visi taškai/monetai skaičiuojami serveryje) | Dauguma mažų žaidimų to NETURI. Tai reiškia: nulaužtas telefonas negali prisirašyti monetų ar rekordų. Rezultatų lentelė lieka sąžininga — o sąžininga lentelė yra varžymosi pagrindas. |
| 2 | **Firestore taisyklės — tvarkingos** (patikrinau kodą) | Klientas gali keisti TIK savo vardą (2–16 simbolių). Monetai, premium, paketai — užrakinta. Lentelė — tik skaitymui. `active_games` — visiškai uždara. Tai tikrai geras lygis. |
| 3 | **Anti-botas** | Per greiti atsakymai (<200 ms/klausimas) atmetami; žaidimas po įvertinimo ištrinamas (negalima siųsti dukart). |
| 4 | **Didelė patikrinto turinio bazė** | ~2 170 klausimų/frazių su `sourceVerified`, 2 kalbos, 46 simb. riba, validatorius. Turinys — brangiausia žaidimo dalis, ji jau yra. |
| 5 | **Rotacija** (atsimenami ~150 paskutinių klausimų) | Žaidėjas ~14 partijų nemato pasikartojimų — „šviežumo“ jausmas išlieka. |
| 6 | **Kryžminė ekonomika** (trivijos → paslapties raidės) | Protingas ryšys: gerai sužaidei viktoriną → gauni nemokamų raidžių paslapčiai. Tai skatina žaisti ABU žaidimus. Šį principą verta plėsti (žr. 4.6). |
| 7 | **Švelni monetizacija** | Reklama niekada netrukdo žaidimo metu; interstitial tik kas 3 partiją su 90 s pauze. Tai teisinga kryptis — nepykdo žaidėjų. |
| 8 | **Tvarkinga architektūra** | Temos, spalvos, tekstai, režimai — centralizuoti; nauja tema pridedama be perdarymo. Tai pigus augimas ateityje. |

**Apibendrinant:** techninis pamatas (sauga + turinys + architektūra) yra **stipresnis nei
daugumos pradedančių komercinių žaidimų**. Silpnoji vieta — ne technika, o **žaidimo
psichologija**: kas verčia grįžti ir žaisti dar vieną partiją.

---

## 2. MINUSAI — kas šiandien trukdo žaisti valandų valandas

### 2.1. Taškų sistema — „plokščia“, be azarto (DIDŽIAUSIAS minusas)

Dabar: `taškai = max(10, 100 − sekundės × 3)`, klaida = 0, ir viskas.

Kodėl tai silpna:
- **Bauda −3/sek. nejaučiama.** Žaidėjas nemato skirtumo tarp 4 ir 6 sekundžių — skaičius
  tiesiog būna kitoks. Nėra „WOW” momento.
- **Kiekvienas klausimas — atskiras.** Atsakei 7 iš eilės teisingai? Sistema to net
  nepastebi. Nėra įtampos „tik nesuklysk dabar!“.
- **9/10 ir 10/10 beveik nesiskiria.** Paskutinis klausimas turėtų būti širdies dūžis,
  o dabar — eilinis.
- **Nėra „vos vos“ momento.** Pralaimėjai rekordui 15 taškų? Žaidėjas to nemato — o tai
  stipriausias pasaulyje „dar kartą!“ mygtukas.

### 2.2. Progresas per toli — žaidėjas „nieko nepasiekia“

Patikrinau avatarų lentelę: **2-as lygis (Viščiukas 🐣) — nuo 100 000 taškų.**
Vidutinė partija duoda ~500–800 taškų → **pirmas pasiekimas po ~150 partijų.**
Tai katastrofa pradedančiajam: žaidi vakarą — ir jokio matomo progreso.
(Aukščiausias lygis 30 mln. ≈ 40 000+ partijų — praktiškai nepasiekiamas.)

### 2.3. Serija (streak) skaičiuojama, bet... nieko neduoda

Patikrinau kodą: `streakDays` serveryje skaičiuojamas ir saugomas, bet už jį **nėra jokio
atlygio**. Dienų serija yra stipriausias žinomas grįžimo variklis (Duolingo ant jos pastatė
visą imperiją) — pas mus ji tik skaičius profilyje.

### 2.4. Monetų ekonomika — per šykšti

- Uždarbis: 1 moneta už teisingą (+1 jei <3 sek.) → realiai **~8–14 monetų/partija**.
- Atrakinimas: **150 monetų = tik 2 žaidimai**.
- Vadinasi: ~12–15 partijų darbo → 2 partijos atrakintame turinyje. Žaidėjas jaučiasi
  apgautas, ne motyvuotas.

### 2.5. Nėra dienos tikslo

Atsidarei žaidimą — ir... pats sugalvok, ką žaisti. Nėra „šiandienos iššūkio“, nėra
užduočių („atsakyk 20 geografijos klausimų“), nėra priežasties grįžti BŪTENT šiandien.

### 2.6. Nėra analitikos — komercinis žaidimas „aklas“

Nėra Firebase Analytics / Crashlytics. Be jų nežinosi: kiek žaidėjų grįžta kitą dieną (D1),
po savaitės (D7), kur jie „nubyra“, kuri tema populiariausia, ar reklamos nepykdo.
**Komerciniam žaidimui tai privaloma** — kitaip tobulinsi spėliodamas.

### 2.7. Techniniai / tvarkos minusai (mažesni, bet taisytini)

- App Check `debug` režimas ir testiniai reklamų ID (žinoma — iki paleidimo).
- `pendingMysteryLetters` be viršutinės ribos (galima sukaupti šimtus).
- Senas `README.md` aprašo kitą žaidimą; repo šaknyje mėtosi laikini failai (`_*.png`, `_*.js`, logai).
- Serverio funkcijoms nėra automatinių testų (taškų formulę pakeitus — tik rankinis tikrinimas).
- Deklaruoti klausimų skaičiai dokumentuose nesutampa su tikrais.

---

## 3. TAŠKŲ SISTEMOS PERTVARKA — kad būtų azartiška

Visa tai skaičiuojama **serveryje iš laikų, kuriuos jau siunčiame** — saugumo modelis
nesikeičia, telefonui tereikia gražiai parodyti.

### 3.1. KOMBO daugiklis (svarbiausias pakeitimas)

Teisingi atsakymai iš eilės augina daugiklį:

| Iš eilės | Daugiklis | Ekrane |
|----------|-----------|--------|
| 1–2 | ×1.0 | — |
| 3–4 | ×1.2 | „KOMBO ×1.2!“ 🔥 |
| 5–6 | ×1.5 | „KOMBO ×1.5!“ 🔥🔥 |
| 7–9 | ×2.0 | „KOMBO ×2!“ ⚡ |
| 10 | ×3.0 paskutiniam | „TOBULA!“ 🏆 |

Klaida → daugiklis krenta į ×1.0 (su matomu „dzin“ — skausminga, bet sąžininga).

**Kodėl tai veikia:** kiekvienas kitas klausimas darosi VERTINGESNIS už ankstesnį.
Prie 7-o klausimo su ×2 daugikliu žaidėjo pirštai jau prakaituoja — būtent šito jausmo
dabar nėra. Tai paverčia 10 klausimų iš „sąrašo“ į **įtampos kreivę**.

### 3.2. Greičio pakopos vietoj nematomos baudos

Vietoj tylaus −3/sek. — trys aiškios pakopos su grįžtamuoju ryšiu:

| Greitis | Bazė | Ekrane |
|---------|------|--------|
| < 3 sek. | 100 | „ŽAIBAS!“ ⚡ (auksinis blyksnis) |
| < 8 sek. | 70 | „Greitas!“ ✨ |
| ≥ 8 sek. | 40 | „Teisingai“ ✅ |

**Kodėl:** pakopa JAUČIAMA („gavau ŽAIBĄ!“), procentai — ne. Žaidėjas pradeda medžioti
žaibus — tai savaiminis tikslas kiekviename klausime.

### 3.3. Tobulos partijos premija

10/10 → **+500 taškų** premija su atskira animacija ir garsu.
**Kodėl:** kai turi 9/10, paskutinis klausimas tampa viso vakaro įvykiu. Vienas klausimas —
ir arba fejerverkai, arba „taip arti…“. Abu atvejai veda į „dar kartą!“.

### 3.4. „Vos vos“ pranešimai

Po partijos, jei pritrūko iki rekordo ≤ 20 %:
> „Iki tavo rekordo pritrūko vos **23 taškų**! 😤“

**Kodėl:** tai stipriausias žinomas pakartotinio žaidimo paleidiklis (slot machine „near
miss“ efektas, bet sąžiningoje formoje — be jokios apgaulės, tik faktas).

### 3.5. Nauja taškų formulė (apibendrinta)

```
klausimo taškai = greičio_pakopa(3s/8s) × kombo_daugiklis
partijos taškai = suma + tobulos_partijos_premija(500, jei 10/10)
```

Maksimumas: ~10×100×(augantis kombo) + 500 ≈ **2 500–3 000** vietoj dabartinių ~1 000.
Skaičiai didesni → maloniau (psichologija: 2 480 taškų skamba geriau nei 870).
Senus lentelės rekordus galima padauginti iš ~2.5 arba pradėti naują sezoną (žr. 4.3).

---

## 4. ĮTRAUKIMO MECHANIKOS — kad norėtųsi grįžti kasdien

Surikiuota pagal naudą/pastangas.

### 4.1. Serijos (streak) atlygiai — JAU TURIM SKAIČIAVIMĄ, tik pridėti prizus

| Diena | Prizas |
|-------|--------|
| 2 | +20 monetų |
| 3 | +50 monetų |
| 7 | +200 monetų + 1 nemokamas paketas |
| 14 | +500 monetų |
| 30 | speciali avataro emblema 🏆 |

Plius **„serijos užšaldymas“** (1 praleista diena nenutraukia serijos) — perkamas už
~200 monetų. Tai Duolingo galingiausia mechanika: žmonės žaidžia vidurnaktį, kad
neprarastų serijos, o užšaldymas yra ir monetų „skylė“ (kam jas leisti).

### 4.2. Dienos iššūkis

Kasdien visi žaidėjai gauna **tą pačią** 10 klausimų partiją (mišri tema) su atskira
dienos lentele. **Kodėl:** (1) priežastis atsidaryti žaidimą BŪTENT šiandien; (2) sąžininga
lygiava — visi gavo tuos pačius klausimus; (3) techniškai pigu — viena partija per dieną,
serveris parenka pagal datą.

### 4.3. Savaitės lyga (didžiausias „valandų“ variklis — vėlesniam etapui)

Žaidėjai dalijami į grupes po ~30. Savaitės taškai lemia: top 10 kyla į aukštesnę lygą
(Bronza → Sidabras → Auksas → Deimantas...), paskutiniai 5 krenta. **Kodėl:** varžaisi ne
su pasauliu (kur visada pralaimi), o su 29 panašiais — ir visada esi „beveik top 10“.
Tai mechanika, dėl kurios Duolingo žmonės sėdi po valandą per dieną. Reikia daugiau
serverio darbo, todėl — 2-as etapas.

### 4.4. Skrynia po partijos (kintamas atlygis)

Po kiekvienos partijos — skrynia: dažniausiai 5–15 monetų, kartais 50, retai 200 🎰.
**Kodėl:** nenuspėjamas atlygis formuoja įprotį stipriau nei pastovus (tai įrodyta
psichologija). Svarbu: tik PRIEDAS prie uždarbio, ne vietoj jo, ir be tikrų pinigų —
tada tai smagu, o ne lošimas.

### 4.5. „Rizikuok!“ mygtukas (azartas + pajamos)

Po partijos: „Žiūrėk reklamą ir mesk monetą: **×2 arba nieko** iš ŠIOS partijos monetų.“
**Kodėl:** grynas azarto momentas + rewarded reklamos peržiūra (brangiausia reklamos rūšis).
Etikos riba: rizikuojama TIK šios partijos uždarbiu, niekada — bendru balansu.

### 4.6. Užduotys (quests) — 3 per dieną

Pvz.: „Atsakyk 15 gamtos klausimų“ / „Gauk 5 ŽAIBUS“ / „Sužaisk 1 paslaptį“ → po 30–50 monetų.
**Kodėl:** duoda kryptį („ką dabar žaisti?“) ir natūraliai išvedžioja žaidėją po visas
temas — o tai didina ir paslapties raidžių srautą (jau esama kryžminė ekonomika pradeda
suktis pilnu ratu).

### 4.7. Blitz ⚡ — jau rezervuota vieta, ideali azartui

90 sekundžių, klausimai be galo, kombo daugiklis auga be ribų, 1 klaida = pabaiga
(arba −15 sek.). Atskira lentelė. **Kodėl:** trumpa, aštri, „dar vieną!“ formato partija —
idealiai tinka naujai taškų sistemai pademonstruoti. Turinys jau yra (visi klausimai tinka).

---

## 5. EKONOMIKOS PERTVARKA

| Kas | Dabar | Siūlau | Kodėl |
|-----|-------|--------|-------|
| Avataro 2 lygis | 100 000 tšk. | **1 500 tšk.** | Pirmas pasiekimas — pirmą vakarą, ne po 150 partijų. Toliau: 5k, 15k, 40k, 100k, 250k… (eksponentė, bet pasiekiama). |
| Atrakinimo paketas | 150 monetų = 2 žaidimai | **100 monetų = 5 žaidimai** | Dabar santykis baudžia. Turi būti: „pasistengiau vakarą → atsirakinau rimtam pažaidimui“. |
| Monetos už partiją | ~8–14 | ~15–25 (su kombo/skrynia) | Suderinta su naujais prizais; ekonomika turi kvėpuoti. |
| Serija | nieko | prizai (4.1) | Grįžimo variklis №1. |
| Rewarded po partijos | nėra | „×2 monetos už reklamą“ | Industrijos standartas; žaidėjas laimi, tu uždirbi. |
| `pendingMysteryLetters` | be ribos | riba ~10 | Kad raidės būtų „šviežias“ prizas, ne sandėlis. |

Visus skaičius vėliau kalibruosim pagal analitiką (6.1) — tai pradinis balansas.

---

## 6. TECHNINIAI DARBAI (komerciniam paleidimui)

1. **Firebase Analytics + Crashlytics** — įdėti DABAR, prieš visus kitus pakeitimus.
   Kitaip nematysi, ar kombo sistema realiai pagerino grįžtamumą. Matuoti: D1/D7
   grįžtamumas, partijų skaičius per sesiją, kur žaidėjai išeina.
2. **Prieš Google Play:** App Check → `playIntegrity`; tikri AdMob ID; UMP sutikimo
   logikos patikra; temų atidarymo/užrakto galutinis sprendimas.
3. **Serverio testai** taškų formulei ir ekonomikai (kad pakeitus balansą niekas nesugriūtų).
4. **Tvarka:** senas `README.md` → pervadinti/perrašyti apie BRAIN ARENA; išvalyti
   laikinus failus; suvienodinti klausimų statistiką.
5. **Firestore indeksai** lentelės užklausoms (patikrinti, ar sukurti).

---

## 7. SIŪLOMA DARBŲ EILĖ (pagal naudą)

| Etapas | Darbai | Kodėl pirmiau |
|--------|--------|---------------|
| **1** | Analitika (6.1) + Kombo/pakopos/premija/„vos vos“ (3.1–3.4) + avatarų slenksčiai (5) | Didžiausias įtraukimo šuolis už mažiausiai darbo; analitika iškart matuos efektą. |
| **2** | Serijos prizai + užšaldymas (4.1) + monetų rebalansas (5) + rewarded ×2 | Grįžimas kasdien. |
| **3** | Dienos iššūkis (4.2) + užduotys (4.6) + skrynia (4.4) | Dienos tikslas ir įprotis. |
| **4** | Blitz ⚡ (4.7) + „Rizikuok!“ (4.5) | Azarto viršūnė ant jau veikiančios sistemos. |
| **5** | Savaitės lyga (4.3) | Galingiausia, bet daugiausiai darbo — kai jau yra žaidėjų srautas. |
| **6** | Paleidimo paruošimas (6.2–6.5) | Prieš Google Play. |

---

## 8. Sąžininga riba (trumpai)

Visos siūlomos mechanikos — be tikrų pinigų lošimo, be „pay-to-win“, rizika tik partijos
uždarbiu, skrynios be pirkimo už eurus. Žaidimas turi būti kabinantis dėl **gero žaidimo
jausmo** (kombo įtampa, tobula partija, lygos varžybos), o ne dėl išnaudojimo — taip ir
įvertinimai Google Play bus geri, o tai irgi komercija.
