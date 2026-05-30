# 🎨 ŽAIDIMO DIZAINAS (sprendimai „ant popieriaus")

> Čia surašom VISUS sprendimus dėl žaidimo PRIEŠ statydami.
> Sprendžiam po vieną, kartu. Nieko nestatom, kol nesutarta.
> ✅ = sutarta · 🔄 = sprendžiam dabar · ⬜ = dar nesvarstyta

| # | Sprendimas | Statusas |
|---|-----------|----------|
| 1 | Matematikos veiksmai | ✅ |
| 2 | Sunkumo lygiai (4 lygiai × 4 veiksmai = 16 režimų) | 🔄 |
| 3 | Klausimų skaičius per žaidimą (iki 10) | ✅ |
| 4 | Atsakymų variantai (6, panašūs klaidingi) | ✅ |
| 5 | Taškų skaičiavimas (server-authoritative) | ✅ |
| 6 | Kas vyksta suklydus (staigi mirtis + 1 Rewarded) | ✅ |
| 6 | Kas vyksta suklydus | ⬜ |
| 7 | Laikmatis | ⬜ |
| 8 | Vizualinis stilius (spalvos) | ⬜ |

---

## ✅ 1. Matematikos veiksmai
**Sprendimas:** Visi keturi — **sudėtis (+), atimtis (−), daugyba (×), dalyba (÷)**.
**Pastaba:** statysim po vieną, pradėsim nuo sudėties. Kiekvienas veiksmas — atskiras režimas.

---

## 🔄 2. Sunkumo lygiai — 4 lygiai × 4 veiksmai = 16 režimų (PASIŪLYMAS)
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

## ✅ 3. Užduočių per sesiją: **iki 10**
Viena sesija = iki 10 užduočių. Staigi mirtis (žr. 6 sprendimą) gali nutraukti anksčiau. Maksimalus rekordas pasiekiamas teisingai ir greitai sužaidus visus 10.

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

---

## ✅ 6. Kas vyksta suklydus — Staigi mirtis + 1 Rewarded tęsimas
- Klaida (neteisingas atsakymas ARBA pasibaigęs langelio laikas) → langelis raudonas (shake), 0 taškų, žaidimas **NUTRŪKSTA** → rezultatų ekranas.
- **Rewarded „Continue":** nutrūkus gali žiūrėti reklamą → tęsia nuo kito langelio, surinkti taškai lieka. **TIK 1×/sesiją** (kad leaderboard „nenusipirktų").
- **Anti-cheat:** telefonas siunčia tik tiek atsakymų, kiek atsakyta; serveris suskaičiuoja teisingus + pritaiko bendro laiko formulę (5 sprendimas). Nepameluosi.
- ⚠️ **TUNABLE (retention saugiklis):** staigi mirtis = didžiausia įtampa, BET didžiausia churn rizika. Modelis valdomas per **Firebase Remote Config** (Fazė 6) — galėsim perjungti į „1 gyvybė" ar A/B testuoti BE naujo leidimo.
