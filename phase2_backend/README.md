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

## active_games valymas
Firestore Console → TTL policy laukui `createdAt` (pvz. 1 val.), kad seni
nepanaudoti žaidimai nesikauptų. (Panaudoti pažymimi `used:true`.)

## Srautas
```
startGame()  -> serveris kuria 10 klausimų, slepia atsakymus, grąžina tik tekstus
[žaidimas]
submitScore()-> serveris: tikrina used/uid, matuoja laiką, filtruoja botus,
                skaičiuoja taškus pagal serverio atsakymus, rašo rekordą
```
