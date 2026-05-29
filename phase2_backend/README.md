# Fazė 2 — Server-Authoritative Anti-Cheat backend

Serverio „smegenys", atsakingos už saugumą. Trys sluoksniai:

1. **Cloud Functions** (`functions/src/index.ts`) — `startGame` + `submitScore`.
2. **Security Rules** (`firestore.rules`) — užrakina DB nuo tiesioginio kliento rašymo.
3. **App Check** — įjungiamas Firebase konsolėje (Play Integrity), funkcijose jau `enforceAppCheck: true`.

## Diegimas

```bash
# 1. Inicijuoti Firebase (jei dar ne)
firebase init functions firestore   # pasirink TypeScript

# 2. Įdėti kodą
#    functions/src/index.ts  <- iš čia
#    firestore.rules         <- iš čia

# 3. Priklausomybės
cd functions && npm install firebase-admin firebase-functions

# 4. Deploy
firebase deploy --only functions,firestore:rules
```

## App Check (būtina!)
Firebase Console → App Check → registruok Android app su **Play Integrity**.
Flutter pusėje: `firebase_app_check` + aktyvuok prieš pirmą Cloud Function kvietimą.

## active_games valymas (SVARBU — dvi situacijos)
1. **Užbaigti žaidimai** — ištrinami automatiškai `submitScore` metu
   (`transaction.delete`). DB nesikaupia + apsauga nuo Replay Attack.
2. **APLEISTI žaidimai** — žaidėjas pradėjo, bet uždarė app nesužaidęs.
   `submitScore` neiškviečiamas, todėl `delete` NEĮVYKSTA ir dokumentas lieka.
   👉 Todėl VIS TIEK reikia **Firestore TTL policy** laukui `createdAt`
   (pvz. 2 val.): Firestore Console → Firestore → TTL → nauja policy ant
   `active_games.createdAt`. Ji išvalys tik „pamestus" žaidimus.

## Vėlesni patobulinimai (užsirašyta, ne dabar)
- **Rate-limiting:** App Check įrodo app tapatybę, bet ne piktnaudžiavimą.
  Vėliau pridėti limitą „ne daugiau X startGame per minutę vienam uid".
- **Atsakymų tipai:** Flutter pusėje užtikrinti, kad `clientAnswers` siunčia
  skaičius (ne tekstą), nes serveris lygina griežtai (`===`).

## Srautas
```
startGame()  -> serveris kuria 10 klausimų, slepia atsakymus, grąžina tik tekstus
[žaidimas]
submitScore()-> serveris: tikrina used/uid, matuoja laiką, filtruoja botus,
                skaičiuoja taškus pagal serverio atsakymus, rašo rekordą
```
