# 📈 STRATEGIJA — pritraukti žaidėjus ir uždirbti (gairės)

> Baltosios (legalios, ilgalaikės) strategijos mobiliam žaidimui 2025-26.
> ✅ = jau turim · 💡 = siūloma pritaikyti · ⚠️ = rizika / Google Play
> Tai GAIRĖS planavimui, ne kodas. Įgyvendinsim etapais, su „OK, darom".

---

## 🪝 1. PIRMOS 60 SEKUNDŽIŲ (Hook — ar žaidėjas „prilips")
Žaidėjas sprendžia per 1 min, ar liks. Lemia 80% retention.

- ✅ Žaidi iškart (be registracijos, auto Player_XXXX)
- ✅ Greitas tempas (30s/klausimas, gyvi taškai)
- 💡 **Pirmas žaidimas — lengvas „pergalės" jausmas** (pirmi 3 klausimai labai lengvi, kad pajustų sėkmę)
- 💡 **Onboarding be teksto** — pirmas ekranas tiesiog parodo žaidimą, ne instrukcijas

## 🔁 2. RETENTION (kad grįžtų kasdien)
Pelningiausi žaidėjai — tie, kurie grįžta. D1/D7 retention = svarbiausia metrika.

- 💡 **Dienos serija (streak)** 🔥 — „Žaidei 3 dienas iš eilės!" Nutrūksta — pradedi iš naujo. Galingiausias retention įrankis.
- 💡 **Dienos iššūkis** — kasdien naujas tikslas („Šiandien: 10 teisingų Daugyboje → +50 coins")
- 💡 **Pranešimai** (push) — „Tavo rekordą pagerino! Atsirevanšuok" (BET saikingai — per daug = ištrina)
- 💡 **Dienos dovana** — prisijungęs gauni coins (didėja su serija: 1d=10, 7d=100)
- ⚠️ Pranešimai: Google reikalauja leidimo (Android 13+). Neagresyvūs.

## 💰 3. MONETIZACIJA (ką jau turim + ką pridėti)

### Jau turim:
- ✅ Interstitial (po sesijos, 90s cooldown)
- ✅ Banner (meniu/rezultatai)
- ✅ Coins (1/teisingą + greičio bonusas)
- ✅ Užraktai (150 coins / 2 reklamos / lygis)
- ✅ Premium pamatas ($2.99/mėn — Etapas 5)

### Siūloma pridėti:
- 💡 **Rewarded „dvigubink rezultatą"** — po sesijos: „Žiūrėk reklamą → ×2 coins"
- 💡 **„Pirmo pirkimo" nuolaida** — naujam žaidėjui premium $0.99 (vietoj $2.99) pirmą savaitę. Konvertuoja daug geriau.
- 💡 **Coins paketai** (IAP) — kam nepatinka reklamos: 500 coins = $1.99 (Etapas 5)
- 💡 **„No ads" vienkartinis** $3.99 — dalis žmonių MOKA, kad nematytų reklamų
- ⚠️ Reklamų DAŽNIS: ne dažniau kaip kas 2-3 žaidimus. Per dažnai = ištrina + 1★.

## 📲 4. ASO (Play Store optimizacija — kad rastų brangūs vartotojai)
JAV/UK/Vakarų Europos vartotojai = brangiausia reklama. Reikia, kad jie RASTŲ.

- 💡 **Raktažodžiai pavadinime:** „Math Games — Brain Training" (ne tik „Math Game")
- 💡 **Vaikų raktažodžiai** (kai bus Kids): „math for kids", „kindergarten math" — milžiniška JAV paklausa
- 💡 **Lokalizuotas listing** — EN (JAV/UK), vėliau DE/FR/ES (brangios rinkos)
- 💡 **Ekrano nuotraukos su tekstu** — „Beat the clock!", „Climb global Top 10!" (ne tušti screenshotai)
- ✅ Listing tekstai paruošti (launch/STORE_LISTING.md)

## 🏆 5. SOCIALINIS / AZARTAS (kad varžytųsi)
- ✅ Globali Top 10 + tavo pozicija (getMyRank)
- 💡 **Draugų iššūkis** — „Pasidalink rezultatu" (share mygtukas → social = nemokama reklama)
- 💡 **Savaitės lyga** — kas savaitę nauja lentelė (visi turi šansą, ne tik seni žaidėjai)
- 💡 **„Tau iki Top 10 trūksta 200 taškų!"** — rodyti, kaip arti viršūnės (motyvuoja žaisti)

## 📊 6. METRIKOS (ką stebėti — Firebase Analytics, Etapas Z)
- **D1/D7/D30 retention** (kiek grįžta po 1/7/30 dienų)
- **ARPDAU** (vidutinės pajamos iš aktyvaus žaidėjo/dieną)
- **eCPM pagal šalį** (kur brangiausia reklama)
- **Konversija** (kiek % perka premium)
- **Funnel** (kur žaidėjai meta — kuriame ekrane)

---

## 🎯 KAS DUODA DAUGIAUSIA (prioritetai mums)

| Prioritetas | Kodėl | Etapas |
|-------------|-------|--------|
| 1. **Dienos serija (streak)** | Stipriausias retention | naujas (po 3) |
| 2. **Rewarded „×2 coins"** | Lengvos pajamos, žaidėjai mėgsta | Etapas 4 |
| 3. **Naujos temos** (geografija...) | Daugiau turinio = daugiau prenumeratų | Grupė B |
| 4. **ASO + vaikų raktažodžiai** | Pritraukia JAV srautą | prieš paleidimą |
| 5. **Pirmo pirkimo nuolaida** | Daugiau konversijų | Etapas 5 |

---

## ⚠️ KO NEDARYTI (Google Play baudžia / žudo žaidimą)
- ❌ Reklama kas 30 sek / per žaidimą
- ❌ Klaidinantys mygtukai („X" kuris atidaro reklamą)
- ❌ Fake urgency („Liko 2 min!" netiesa)
- ❌ Coins atrakinimas, kuris DINGSTA (1★ atsiliepimai)
- ❌ Sunkiai randamas „atšaukti prenumeratą"
- → Visa tai duoda greitų pinigų, bet užmuša žaidimą per 1-2 mėn + Google blokuoja.

---

## 💡 IŠVADA
Mūsų pamatas JAU stiprus (server-authoritative, Top 10, coins, užraktai, reklamos).
Didžiausi „greiti laimėjimai" likę:
1. **Dienos serija** (retention)
2. **Rewarded ×2** (pajamos)
3. **Naujos temos** (turinys → prenumeratos)
4. **ASO** (srautas iš brangių rinkų)

Visa tai — baltosios strategijos, ilgalaikės, Google Play saugios.
