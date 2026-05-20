# 🎮 MYN – Mine Yes, Yours No

Realaus laiko žaidimas: vienas žaidėjas sugalvoja žodį, kiti klausinėja
ir bando atspėti. Atsakymai tik mygtukais: TAIP / NE / GALI BŪTI / YRA.

---

## ⚙️ KAIP PALEISTI — 2 BŪDAI

## A BŪDAS — testuoti savo kompiuteryje (greičiausias)

Tinka pažiūrėti kaip atrodo, bet kiti telefonai neprisijungs be Supabase.

1. Įdiek Node.js → https://nodejs.org (LTS versija)
2. Atpakuok šį ZIP į aplanką
3. Atidaryk terminalą tame aplanke ir paleisk:
       npm install
   (palauk ~2 min kol parsisiunčia)
4. Sukurk .env failą (apie tai B būdo 2 žingsnyje)
5. Paleisk:
       npm start
6. Atsidarys naršyklėje: http://localhost:3000

---

## B BŪDAS — paleisti internete (veiks visuose telefonuose) ✅

Tikrasis būdas testuoti su draugais skirtinguose telefonuose.
Viskas NEMOKAMA.

### 1 žingsnis – Supabase (duomenų bazė)

1. Eik į https://supabase.com → užsiregistruok → New project
2. Pavadinimas: myn, sugalvok DB slaptažodį, regionas: Europe
3. Palauk ~2 min kol sukuriama
4. Kairėje meniu paspausk SQL Editor → New query
5. Atidaryk failą SUPABASE_SCHEMA.sql, nukopijuok VISĄ turinį,
   įklijuok ir paspausk Run
6. Turi pamatyti "Success"
7. Kairėje paspausk Project Settings → API
8. Nukopijuok du dalykus:
   - Project URL (pvz. https://abcd1234.supabase.co)
   - anon public raktą (ilgas tekstas prasidedantis eyJ...)

### 2 žingsnis – sukurk .env failą

Projekto aplanke sukurk failą pavadinimu .env (su tašku priekyje):

   REACT_APP_SUPABASE_URL=https://abcd1234.supabase.co
   REACT_APP_SUPABASE_ANON_KEY=eyJhbGci....tavo_raktas

Įrašyk savo tikras reikšmes iš 1 žingsnio.

### 3 žingsnis – įkelk į GitHub

1. Susikurk paskyrą https://github.com
2. New repository → pavadinimas myn → Create
3. Paspausk "uploading an existing file"
4. Nutempk visus projekto failus (BET NE .env ir NE node_modules!)
5. Commit changes

### 4 žingsnis – paleisk per Vercel

1. Eik į https://vercel.com → registruokis su GitHub paskyra
2. Add New → Project → pasirink savo myn repozitoriją → Import
3. Skiltyje Environment Variables pridėk DU kintamuosius:
   - REACT_APP_SUPABASE_URL  = tavo Supabase URL
   - REACT_APP_SUPABASE_ANON_KEY = tavo anon raktas
4. Paspausk Deploy
5. Po ~2 min gausi nuorodą, pvz. https://myn.vercel.app

### 5 žingsnis – testuok telefonuose 📱

1. Atidaryk nuorodą BET KURIAME telefone
2. iPhone (Safari): Dalintis → "Pridėti į pagrindinį ekraną"
3. Android (Chrome): ⋮ meniu → "Pridėti į pagrindinį ekraną"
4. Dabar veikia kaip tikra programėlė!

---

## 🎯 KAIP ŽAISTI

Šeimininkas:
1. Įveda vardą → Kurti kambarį
2. Sugalvoja slaptą žodį (pvz. katė) + kategoriją
3. Parodo draugams kambario kodą
4. Kai visi prisijungę → Pradėti žaidimą
5. Žaidimo metu atsakinėja į klausimus mygtukais
6. Kai kažkas atspėja → spaudžia "Atspėta! 🎉"

Žaidėjai:
1. Įveda vardą → Prisijungti → įveda kodą
2. Eilės tvarka užduoda po vieną klausimą
3. 🎙 mygtuku gali įjungti balso pokalbį

---

## ❗ DAŽNOS KLAIDOS

- "Kambarys nerastas" → patikrink ar gerai įvedei kodą (didžiosios raidės)
- Tuščias ekranas → patikrink ar .env faile teisingi Supabase duomenys
- Realaus laiko neveikia → ar paleidai VISĄ SQL schemą?
- Balsas neveikia → reikia mikrofono leidimo; veikia tik per HTTPS
  (Vercel turi HTTPS automatiškai)

---

## 📁 FAILŲ STRUKTŪRA

   myn/
   ├── public/
   │   ├── index.html      – pagrindinis HTML
   │   ├── manifest.json   – PWA nustatymai
   │   └── icon.svg        – programėlės ikona
   ├── src/
   │   ├── App.js          – visa žaidimo logika
   │   ├── App.css         – MYN dizainas
   │   ├── index.js        – paleidimo taškas
   │   └── lib/
   │       └── supabase.js – duomenų bazės ryšys
   ├── SUPABASE_SCHEMA.sql – DB lentelės
   ├── package.json        – priklausomybės
   └── .env.example        – aplinkos kintamųjų pavyzdys
