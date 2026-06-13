# 🎓 EGZAMINŲ CENTRAS — planas (savininko idėja 2026-06-13)

> NAUJAS META-ŽAIDIMAS (ne paprasta turinio tema). Potemes/detalės savininkas
> tikslins VĖLIAU. Kodą rašom TIK gavus aiškų „darom". Šis dokumentas — idėjos
> eskizas aptarimui, ne galutinė specifikacija.

## 1. SAVININKO VIZIJA (jo žodžiais 2026-06-13)
- Nauja tema/skiltis „Egzaminų centras".
- Žaidėjas laiko EGZAMINUS iš mūsų temų (matematika, gamta, geo, istorija, kosmosas…).
- Atitikus tam tikrus REIKALAVIMUS → DIPLOMAS su žaidėjo VARDU + kažkokios PRIVILEGIJOS.
- IŠLAIKYTI NEBUS LENGVA (rimtas iššūkis, ne dovana).
- Potemės/struktūra — sugalvosim vėliau atskirai.

## 2. IDĖJOS ESKIZAS (mano pasiūlymas — savininkas tvirtins/keis)
- **Egzaminas ≠ paprastas žaidimas:** daugiau klausimų (pvz. 20–30 vietoj 10),
  griežtesnis laikas, IŠLAIKYMO RIBA aukšta (pvz. ≥85–90 % teisingų). Klaidų
  tolerancija maža → tikras iššūkis.
- **Egzaminų pakopos (pvz.):** kiekvienai temai — „Pradinis" / „Žinovo" egzaminas;
  o gale — „MAGISTRO" egzaminas iš VISŲ temų (sunkiausias). (Pavadinimai derinami.)
- **Diplomas:** su žaidėjo vardu (username) + dalykas + data + laipsnis
  (pvz. „Gamtos žinovas", „Kosmoso magistras"). Rodomas PROFILYJE; gal pasidalijimo kortelė.
- **Privilegijos (variantai aptarimui):** titulas/ženkliukas prie vardo lentelėje;
  premijinės monetos; specialus avataro rėmas; atrakinta kažkas; ar prieiga prie
  sunkesnio turinio. (Savininkas nuspręs, kokias.)
- **Pakartojimas:** ribotas (pvz. cooldown arba kaina monetom/reklama), kad
  „išlaikyti nebūtų lengva" ir nebūtų bandoma be galo.

## 3. SAUGA (KRITIŠKA — #1 prioritetas)
- **VISKAS SERVERYJE (server-authoritative):** egzamino klausimai, atsakymai,
  vertinimas, IŠLAIKYTA/NEIŠLAIKYTA sprendimas, diplomo išdavimas IR privilegijos —
  skaičiuojama ir saugoma TIK Cloud Functions. Klientas tik rodo.
- **Diplomai/privilegijos Firestore** rašomi TIK serverio (kaip coins/premium);
  klientas NEGALI sau išrašyti diplomo ar privilegijos (firestore.rules blokuoja).
- Tas pats anti-cheat kaip žaidimuose (laiko matavimas serveryje, no-replay,
  enforceAppCheck). Egzaminas naudoja esamą klausimų banką per registrą.
- Diplomas saugo `username` reikšmę išdavimo metu (jei vėliau keičia vardą — diplomas lieka).

## 4. ATVIRI KLAUSIMAI SAVININKUI (prieš kodą)
1. Egzaminų struktūra: po vieną kiekvienai temai? pakopos (pradinis/žinovo)? +bendras magistro?
2. Kiek klausimų ir kokia išlaikymo riba (pvz. 25 kl., reikia ≥90 %)?
3. Kokios PRIVILEGIJOS tiksliai (titulas / monetos / avataro rėmas / atrakinimai)?
4. Pakartojimas: ribotas laiku, kaina, ar laisvas?
5. Ar reikia „prielaidos" (pvz. pirma sužaisti temą / surinkti X), kad galėtum laikyti?

## 5. EILIŠKUMAS
Daryti PO dabartinio turinio darbo (naujos temos: Mitologija → Rekordai → Prekių
ženklai → Transportas) ir #50/„3 banga" potemių — NEBENT savininkas pasakys daryti anksčiau.
Prieš kodą — aptarti §4 klausimus ir patvirtinti dizainą.
