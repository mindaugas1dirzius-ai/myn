# 🚀 PRADĖK ČIA — Naujos sesijos instrukcija

> Mindaugai, perduok ŠĮ failą naujai Claude sesijai. Jis viską paaiškina.
> (Pilnesnė info: `PERDAVIMAS_NAUJAI_SESIJAI.md` — perskaityk ir jį.)

---

## ⚡ PIRMIEJI 3 ŽINGSNIAI (nauja sesija — daryk IŠ KARTO)

```
1. git checkout claude/android-app-monetization-ads-RORMZ
2. git pull          ← BŪTINA! Be šito dirbsi su sena versija (žr. pamoką žemiau)
3. git log --oneline -5    ← įsitikink kad matai NAUJAUSIUS commit'us
```

Tada perskaityk: **šį failą + `PERDAVIMAS_NAUJAI_SESIJAI.md` + `DIZAINAS.md`**.

---

## 🔴 SVARBIAUSIA PAMOKA (kodėl praeitas perdavimas suklydo)

Praeita sesija **NEPADARĖ `git pull`** prieš darbą → dirbo su SENA lokalia kopija →
sukūrė naujus žaidimus (nature/mystery) ant seno pamato → jos commit'ai
NEPATEKO į GitHub → **du kodo medžiai išsiskyrė.**

**KAD TAU TAIP NENUTIKTŲ — GELEŽINĖ SINCHRONIZACIJOS TAISYKLĖ:**
- ✅ PRIEŠ darbą: **VISADA `git pull`**
- ✅ PO kiekvieno žingsnio: **`git add -A && git commit && git push`**
- ✅ NIEKADA nekaupk pakeitimų lokaliai — push'ink iškart
- ✅ NEDIRBK su dviem sesijomis vienu metu
- ✅ Jei `git log` nerodo naujausių commit'ų → PIRMA `git pull/merge`, NE push

---

## ⚠️ NEIŠSPRĘSTA PROBLEMA, KURIĄ PAVELDI

Šiuo metu yra **DU išsiskyrę git medžiai:**
- **GitHub repo:** matematikos žaidimas, Etapai 1-3, dokumentai, unlock sistema
- **Savininko kompiuterio lokali kopija:** + nauji „nature/mystery" žaidimai,
  +papildomi klausimai, IAM pataisymai (commit 600e264 — repo jo NĖRA)

**PRIVALAI tai saugiai sujungti PRIEŠ tęsdamas naują darbą:**
```
Savininko kompiuteryje (kur lokalus darbas):
1. git add -A && git commit -m "lokalus darbas"
2. git branch backup-local       ← ATSARGINĖ kopija (saugumas!)
3. git fetch origin
4. git log --oneline -10          ← ar lokalus turi commit'us c48bf95, 23d1761?
   - JEI TURI → git push (paprasta, sujungta)
   - JEI NETURI → git merge origin/claude/android-app-monetization-ads-RORMZ
     → spręsk konfliktus → git push
```
⚠️ Pirma `git branch backup-local` — kad NIEKADA neprarastum darbo.

---

## 🎯 PROJEKTAS (trumpai)

**Matematikos žaidimas** → žaidimų platforma. Flutter + Firebase + AdMob.
- Repo: `mindaugas1dirzius-ai/myn`, branch `claude/android-app-monetization-ads-RORMZ`
- Firebase: `math-game-9862f` (europe-west1, Blaze)
- Web demo: math-game-9862f.web.app (TIK peržiūrai — serverio dalies nerodo)
- Tag: `v1.0-stable-math`
- Savininkas Mindaugas — NE programuotojas, aiškinti PAPRASTAI, lietuviškai.

---

## 🛑 GELEŽINĖS DARBO TAISYKLĖS

1. **JOKIO KODO be aiškaus „OK, darom".** Pirma išdirbam, suderinam, tik tada kodas.
2. **NENAUDOTI patvirtinimo mygtukų langų (AskUserQuestion)** — savininką ERZINA.
   Klausk PAPRASTU TEKSTU („Pasirink a/b/c", „Sutinki?").
3. **Patikrinti, ne tik pritarti** — savininkas siūlo idėjas su klaidomis; PRIVALU
   jas pagauti ir sąžiningai pasakyti (jis tai vertina labiausiai).
4. **Po vieną žingsnį.** Kokybė > greitis.
5. **Moduliai, jokio dubliavimo** — seną kodą trinam.
6. **Po kiekvieno žingsnio:** `flutter analyze` (0 klaidų) + testai + commit + PUSH.
7. **Sinchronizacija** (žr. viršuje) — pull prieš, push po.

---

## ✅ KAS PADARYTA (GitHub repo versija)

- Bazinis žaidimas: 30s laikmatis, taškai max(10,100−sek×3), gyvi taškai,
  švelnus modelis, Cyber-Neumorphism, LT/EN, mygtukai
- 7 režimai (skaičiai): + − × ÷ Mix Skliaustai Algebra (registro architektūra)
- Serveris: 5 Cloud Functions (startGame, submitScore, getMyRank, unlockMode,
  unlockByAds), enforceAppCheck:true, deployinta
- Etapas 1: Profilis + getMyRank + coins
- Etapas 3: Užraktai (150 coins / 2 reklamos / $2.99 prenumerata)
- Cloud Run IAM: allUsers invoker pridėtas (būtinas onCall — saugu su App Check)

⚠️ Lokali kopija turi DAUGIAU (nature/mystery žaidimai) — žr. „neišspręsta problema".

---

## ⬜ KAS LIKO

```
🔴 PIRMA: sujungti du git medžius (žr. viršuje) — kad niekas nedingtų
🔧 nested-map bug fix: game_api/unlock_api/profile_api naudoja
   Map<String,dynamic>.from() — nested objektai lūžta. Reikia jsonDecode(jsonEncode()).
   (Be šito telefone „offline" net kai serveris veikia.)
⚠️ Patvirtinti enforceAppCheck:true gale (po visų testų) + išvalyti debug print'us
(B) Dienos serija (streak) — retention
Etapas 4-5: Rewarded ×2, IAP prenumerata
Grupė B: kontrakto išplėtimas (variantai=tekstas/foto) → nauji žaidimai
Paleidimas: Flutter→AAB→Play Console→12 testerių 14d→Production (launch/)
```

---

## 🔑 SVARBIAUSI TECHNINIAI FAKTAI

- **Telefono „offline" priežastis** (paskutinė kova): buvo (1) Cloud Run IAM
  trūko allUsers → IŠSPRĘSTA; (2) nested-map bug kliente → DAR taisyti.
- **App Check:** kode `enforceAppCheck:true`. Debug testavimui telefone reikia
  debug token konsolėje ARBA laikinai false (po testo grąžinti true!).
- Android SDK debesyje BLOKUOJAMAS → APK/AAB build TIK savininko kompiuteryje.
- Web build: `cd math_game && ./deploy_web.sh` (reikia FIREBASE_TOKEN env).

---

## ❓ PATIKRINIMO KLAUSIMAI (atsakyk, kad savininkas matytų jog supranti)

1. Ką PRIVALAI padaryti PRIEŠ pradėdamas dirbti? (atsakymas: `git pull`)
2. Kodėl praeitas perdavimas suklydo? (medžiai išsiskyrė — nedaryta pull/push)
3. Kas yra „du išsiskyrę medžiai" ir kaip saugiai sujungti? (backup-local → merge)
4. Kur skaičiuojami taškai/coins ir kodėl? (serveryje — server-authoritative)
5. Kuo skiriasi SCORE nuo COINS? (score=prestižas nedingsta; coins=valiuta nusirašo)
6. Koks nested-map bug ir kaip taisomas? (jsonDecode(jsonEncode), nested objektai)
7. Ar galima naudoti AskUserQuestion langus? (NE — tik tekstas)
8. Ką PO kiekvieno žingsnio? (analyze + testai + commit + PUSH)

Jei atsakai teisingai → perdavimas pavyko, gali tęsti.
PIRMAS DARBAS: sujungti du git medžius (saugiai, su backup), TADA nested-map fix.

---

## 🎓 PRINCIPAI, KURIE SUSIFORMAVO (svarbu — perskaityk!)

> Šie principai išmokti per darbą su savininku. Laikytis VISŲ.

### 🔒 SAUGUMO principai (Google Play + anti-cheat)
- **Server-authoritative VISKAS:** serveris generuoja klausimus, tikrina
  atsakymus, skaičiuoja taškus/coins, atrakina lygius. Klientas — „kvailas".
- **Jokio `eval()`** — serveris pats apskaičiuoja (a,b,op → answer).
- **App Check (enforceAppCheck:true)** ant visų funkcijų. Po debug testų —
  VISADA grąžinti į true. Prieš Play → playIntegrity.
- **Coins/unlock/IAP — TIK serveryje**, atominėmis transakcijomis. Klientas
  negali pats pridėti coins ar atrakinti.
- **Anti-cheat laikui:** sum(clientTimesMs) ≤ serverioBendrasLaikas + tolerance.
- **Cloud Run:** onCall funkcijoms allUsers invoker BŪTINAS (saugu — App Check
  tikrina viduje). Tai NE saugumo skylė.
- **Atsakymai grąžinami klientui (variantas C)** — saugu, nes taškus skaičiuoja
  serveris iš laiko, ne iš „kiek teisingų telefonas sako".

### 💻 PROGRAMAVIMO principai
- **Moduliai (SRP):** maži failai, viena atsakomybė. Dizainas (widgets) atskirai
  nuo logikos (services/providers). Didžiausias failas ~280-426 eil.
- **Jokio dubliavimo (DRY):** seną/pakeistą kodą TRINAM (ne komentuojam).
  Kartojimąsi keliam į bendrą funkciją (pvz. NeumorphicButton naudojamas visur).
- **Registro pattern:** nauja žaidimo tema = 1 funkcija questionRegistry.ts,
  ne išbarstytas kodas.
- **Fisher-Yates** maišymui (NE sort(()=>Math.random()-0.5) — šališkas).
- **fromJson su atsargom** (?? default) — kad trūkstamas laukas nelaužtų app.
- **Nested-map:** Cloud Functions atsakymą skaityti per jsonDecode(jsonEncode())
  kai yra įdėtų objektų (kitaip Map<Object?,Object?> lūžta).
- **Po kiekvieno žingsnio:** flutter analyze (0 klaidų) + testai + commit + PUSH.

### 🧪 KOKYBĖS principai
- **Smoke testai** generatoriams (pvz. 16 režimų × 5000 — tikrini invariantus:
  6 variantai, jokių dublikatų, teisingas tarp jų, >0, sveiki).
- **Patikrinti faktais, ne spėti** — perskaityti kodą/logą prieš teigiant.
- **Offline fallback:** jei serveris nepasiekiamas → lokalus generatorius
  (žaidimas niekada nelūžta, tik „offline" — rezultatas neįskaitomas).

### 🎮 ŽAIDIMO DIZAINO principai (sutarti su savininku)
- **30s laikmatis/klausimui** (tiksi aukštyn, be streso), taškai pagal greitį.
- **Švelnus modelis:** klaida = 0, žaidimas tęsiasi 10 klausimų.
- **Spąstai (trap):** klaidingi atsakymai = realios žmogiškos klaidos (veiksmų
  eilė, mokyklinės), garantuotai tarp 6 variantų — kad reikėtų galvoti.
- **Rotacija:** klausimai nesikartoja (sesijoje + tarp sesijų).
- **SCORE = prestižas** (nedingsta) · **COINS = valiuta** (nusirašo atrakinant).
- **Coins teisingiau nei „20 sužaistų":** tinginys spaudžiantis bet ką negauna
  coins → atrakina tik tas, kas stengiasi.
- **Reklamos saikingai:** interstitial kas 3 partijas + cooldown (ne per dažnai).
- **Atrakinimas amžinas** (coins/reklama) · prenumerata = 30 dienų.

### 🤝 BENDRAVIMO principai (su savininku)
- Aiškinti PAPRASTAI, lietuviškai, be žargono (savininkas NE programuotojas).
- KODĖL → KAIP struktūra. Emoji, „šviesoforo" stilius.
- Jokio kodo be „OK, darom". Jokių AskUserQuestion popup langų.
- Savininkas siūlo idėjas su klaidomis → pagauti ir sąžiningai pasakyti.
- Sąžiningai apie ribas (web demo, debesų aplinka) — neapsimesti.

### 📚 KUR IEŠKOTI DETALIŲ (kiti dokumentai)
- `DIZAINAS.md` — VISI žaidimo sprendimai (laikmatis, taškai, spąstai, spalvos)
- `PLETROS_PLANAS.md` — etapai (kas padaryta/liko)
- `PERDAVIMAS_NAUJAI_SESIJAI.md` — pilnas kontraktas, failų žemėlapis
- `STRATEGIJA.md` — retention/monetizacija/ASO
- `PLANAS.md` — A→Z bendras planas
- `launch/` — paleidimo dokumentai
