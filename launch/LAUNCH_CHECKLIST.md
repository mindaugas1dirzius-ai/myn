# 🚀 PALEIDIMO CHECKLISTAS (E · O · S · R)

Eiga nuo „kodas baigtas" iki „Play Store". Žymėk ✅ einant.

## ⛔ BLOKERIS prieš viską
- [ ] **Flutter + Android Studio įdiegti TAVO Windows** (be to nėra AAB)
- [ ] `flutter doctor` rodo ✓
- [ ] Žaidimas paleistas telefone (`flutter run`) — pamatytas gyvai

## 🔐 App Check užbaigimas (I)
- [ ] Paleidus app, iš logų nukopijuotas **debug token**
- [ ] Token įrašytas: Firebase → App Check → app → Manage debug tokens
- [ ] App Check **Enforce** įjungtas Cloud Functions + Firestore
- [ ] Patikrinta: serveris veikia (žaidimas online, Top 10 rašo)

## 📄 Dokumentai (paruošti debesyje ✅)
- [ ] Privacy Policy patalpinta viešai (žr. HOSTING_PRIVACY.md) → gauta URL
- [ ] Store listing tekstai (LT+EN) — iš STORE_LISTING.md
- [ ] Data Safety atsakymai — iš DATA_SAFETY.md

## 🎨 Grafika (reikia sukurti)
- [ ] App ikona 512×512 PNG
- [ ] Feature graphic 1024×500 PNG
- [ ] Bent 2-4 ekrano nuotraukos (iš telefono, kai paleisi)

## 🌟 E — Play Console: nauja programa
- [ ] Create app → pavadinimas, kalba (LT), Game, Free
- [ ] Store listing užpildytas (tekstai + grafika)
- [ ] Content rating klausimynas
- [ ] Target audience: 13+
- [ ] **Contains ads: TAIP**
- [ ] Data Safety forma
- [ ] Privacy Policy URL įdėtas

## 🔑 S — Tikrieji raktai (finaliniam build'ui)
- [ ] AdMob konsolė → sukurti tikrą App ID + Banner + Interstitial ID
- [ ] Pakeisti test ID → tikrus (AndroidManifest + ad_service.dart)
- [ ] App Check provider: `debug` → `playIntegrity` (firebase_service.dart, 1 eil.)
- [ ] SHA-1 + SHA-256 iš `gradlew signingReport` → Firebase + Play Integrity
- [ ] **Upload key sukurtas ir SAUGIAI išsaugotas** (NIEKADA neprarask!)
- [ ] `flutter build appbundle --release` → .aab failas

## 📱 R — Closed Testing (privaloma!)
- [ ] **12+ testerių el. paštai surinkti** (PRADĖK DABAR!)
- [ ] AAB įkeltas į Closed testing track
- [ ] Testeriai pakviesti, atsisiuntė
- [ ] **14 dienų laukimas** (Google reikalavimas)

## 🏁 Production
- [ ] Po 14 d. → Production release
- [ ] Žaidimas viešai Play Store! 🎉

---
## ⏰ KRITINIS LAIKO DALYKAS
**Closed testing = 14 dienų su 12+ testerių.** Šito NEPAGREITINSI.
👉 Rink testerius (draugus/šeimą) JAU DABAR, kol ruošiamės.
