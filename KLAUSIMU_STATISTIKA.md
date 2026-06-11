# 📊 KLAUSIMŲ STATISTIKA — „BRAIN ARENA"

> Atnaujinta: 2026-06-11
> Skaičiuojama unikalių klausimų (po vieną EN+LT vertimą = vienas klausimas).

---

## 🎯 Trivia temos (universalus `startTriviaGame` variklis)

Kiekviena tema: **15 klausimų × 4 lygiai = 120 klausimų**.
Lygiai: lengvas / vidutinis / sunkus / ekstremalus.

| # | Tema | Klausimų | Lygiai (15 kiekviename) |
|---|------|---------:|:---:|
| 1 | 🌍 Geografija | 120 | ✅ ✅ ✅ ✅ |
| 2 | 🏛️ Istorija | 120 | ✅ ✅ ✅ ✅ |
| 3 | 🍎 Maistas | 120 | ✅ ✅ ✅ ✅ |
| 4 | ⚽ Sportas | 120 | ✅ ✅ ✅ ✅ |
| 5 | 🫀 Žmogaus kūnas | 120 | ✅ ✅ ✅ ✅ |
| 6 | 🎭 Pop kultūra | 120 | ✅ ✅ ✅ ✅ |
| 7 | 💻 Technologijos | 120 | ✅ ✅ ✅ ✅ |
| | **Trivia iš viso** | **840** | |

---

## 🌿 Atskiros temos

| Tema | Variklis | Klausimų |
|------|----------|---------:|
| 🌿 Gamta (iš viso) | `startNatureGame` | 720 |
| → potemė „Įdomūs faktai" (facts) | | 600 |
| → potemė „Išnykę gyvūnai" (extinct) | | 60 (15×4) |
| → potemė „Augalai" (plants) | | 60 (15×4) |
| → potemė „Viskas iš eilės" (mix) | | traukia iš visų |
| 🧮 Matematika | generuojama | — (dinaminė) |
| 🔍 Mistika | atskiras | — |
| ⚡ Blitz „taip ir ne" | rezervas | — (dar neliesta) |

---

## 📈 Suvestinė

- **Trivia (7 temos × 120):** 840 klausimų
- **Gamta:** 600 klausimų
- **Iš viso patikrinto trivia+gamta turinio:** **1 440 klausimų**
- Kiekvienas klausimas: 1 teisingas + 5 klaidingi atsakymai, EN + LT vertimai, faktai patikrinti (`sourceVerified`).

---

## ✅ Kokybės taisyklės (kiekvienam klausimui)

- Lygis ATITINKA sunkumą (lengvas = visuotinai žinoma, ekstremalus = ekspertinis).
- Įvairūs ir įdomūs, be pasikartojimų temoje.
- Neutralūs — niekam neįžeidžiantys (be politikos/religijos/rasių/ginčytinų teritorijų).
- Tinka visoms šalims pagal kultūrą (verčiant į kt. kalbas).
- Validuota: `node validateContent.js src/<failas>.ts` + `npx tsc --noEmit` (visi praėjo švariai).
