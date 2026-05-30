# 🎨 ŽAIDIMO DIZAINAS (sprendimai „ant popieriaus")

> Čia surašom VISUS sprendimus dėl žaidimo PRIEŠ statydami.
> Sprendžiam po vieną, kartu. Nieko nestatom, kol nesutarta.
> ✅ = sutarta · 🔄 = sprendžiam dabar · ⬜ = dar nesvarstyta

| # | Sprendimas | Statusas |
|---|-----------|----------|
| 1 | Matematikos veiksmai | ✅ |
| 2 | Sunkumo lygiai (4 lygiai × 4 veiksmai = 16 režimų) | 🔄 |
| 3 | Klausimų skaičius per žaidimą (10) | ✅ |
| 4 | Atsakymų variantai (6, panašūs klaidingi) | ✅ |
| 5 | Taškų skaičiavimas | ⬜ |
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

## ✅ 3. Užduočių per sesiją: **10**
Viena žaidimo sesija = 10 užduočių. Pakanka azarto, neperkrauna.

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
4. Visada 6 SKIRTINGI variantai; jei trūksta — pildyti atsarginiu (`±3, ±4`).
5. Teisingas atsidūręs atsitiktinėje pozicijoje (shuffle).

**Generavimas vyksta SERVERYJE (Fazė 2):** `generateMathQuestion` sugeneruoja veiksmą + 5 klaidingus + sumaišo, ir siunčia telefonui gatavą masyvą `[35,44,42,13,24,48]`. Telefonas „kvailas" — tik nupiešia 6 mygtukus.

**Apimtis:** v1 = klasikinis `6×7=?` + trūkstamas narys `6×?=42`. v2 (vėliau) = „kuris veiksmas lygus 42?".

---

## ✅ Rotacijos sistema (kad neatsibostų)
- `users/{uid}` saugo paskutinių **N** parodytų klausimų ID (pvz. `"6x7"`).
- `startGame` generuodamas tikrina sąrašą; jei klausimas jame — metam, generuojam kitą.
- ⚠️ **Apsauga (kritinė):** atmintis negali viršyti (sandėlis − 10), kitaip neužteks 10 unikalių vienai sesijai → `N = min(30, sandėlis − 10)`. Pvz. Lengva × (sandėlis 25) → N ≤ 15.
- Garantija: tas pats klausimas nepasirodo du žaidimus iš eilės.
