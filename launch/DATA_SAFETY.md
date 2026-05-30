# 📋 Data Safety forma (Google Play Console atsakymai)

> Pildoma: Play Console → App content → Data safety. Žemiau — tikslūs atsakymai
> pagal mūsų realią architektūrą (Firebase + AdMob).

## 1. Ar renkate/dalinatės vartotojų duomenis?
**TAIP** (dėl AdMob ir Firebase).

## 2. Surenkami duomenų tipai

| Duomenų tipas | Renkama? | Kam | Bendrinama? |
|---------------|----------|-----|-------------|
| **Device or other IDs** (Advertising ID) | ✅ Taip | Reklamos | ✅ Taip (AdMob) |
| **App activity** (žaidimo rezultatai/score) | ✅ Taip | App funkcijos (leaderboard) | ❌ Ne |
| **App info & performance** (crash logs) | ✅ Taip* | Diagnostika | ❌ Ne |

\* jei vėliau pridėsim Crashlytics; jei ne — nežymėti.

## 3. Kiekvienam tipui — Google klaus:

### Device / other IDs (Advertising ID)
- **Collected:** Yes
- **Shared:** Yes (su AdMob reklamoms)
- **Processed ephemerally:** No
- **Required or optional:** Optional (priklauso nuo UMP sutikimo)
- **Purpose:** Advertising or marketing

### App activity (scores)
- **Collected:** Yes
- **Shared:** No
- **Required or optional:** Required (žaidimo veikimui)
- **Purpose:** App functionality

## 4. Saugumas
- ✅ Data is encrypted in transit (Firebase naudoja HTTPS/TLS)
- ✅ Users can request data deletion (per el. paštą — Privacy Policy)

## 5. Privacy Policy URL
Reikės viešos nuorodos (žr. HOSTING_PRIVACY.md, kaip patalpinti nemokamai).

---
⚠️ SVARBU: kai pridėsi tikrą AdMob ID ir UMP, atsakymai turi atitikti realybę.
Jei kažko nepridėsi (pvz. Crashlytics) — to ir nežymėk.
