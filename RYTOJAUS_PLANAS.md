# 🌅 RYTOJAUS PLANAS

> Kai grįši — perskaityk šitą ir pasakyk, nuo ko pradedam. Viskas saugiai
> branch'e, žaidimas gyvas: https://math-game-9862f.web.app (inkognito lange)

---

## ✅ KAS JAU PADARYTA (didelis darbas!)

**Žaidimas pilnai veikia:**
- 16 režimų (4 veiksmai × 4 lygiai)
- 30s laikmatis kiekvienam klausimui (be streso, taškai pagal greitį)
- Gyvi mažėjantys taškai kampe (+100 → ... → 10)
- 6 atsakymai, animacijos (žalia/raudona shake)
- Kalbos jungiklis LT/EN (veikia)
- Mygtukai: ✕ Baigti (su patvirtinimu) + Išeiti
- Serveris (Cloud Functions) + Top 10 + anti-cheat — GYVA debesyje
- Reklamos (AdMob test) + UMP sutikimas
- Web demo telefonui + cache problema išspręsta visam laikui

---

## 🔄 KĄ GALIMA DARYTI RYTOJ (pasirink)

### A. Profilio užbaigimas
- `getMyRank` Cloud Function (tavo pozicija „14-as iš 320")
- Personal Best skaitymas iš serverio
- ⚠️ Veiks tik online (tikroje app); web demo dažnai offline

### B. Sudėtingumo tobulinimas (V3) — TU PATS minėjai
- Ekstremalų ×/÷ pasunkinti (dabar tik ~189 variantų, per lengva)
- Gal 5-tas lygis „Genijus"?
- Subalansuoti visus 16 režimų (kad nesikartotų)
- Gal mišrūs veiksmai (`3+4×2`)?

### C. Paleidimo kelias (rimtas žingsnis)
- Flutter diegimas tavo Windows kompiuteryje (~1 val.)
- → tikra Android app (su serveriu, reklamomis, Top 10)
- → Play Store (E, O, R, S — dokumentai paruošti launch/ aplanke)
- ⚠️ Pradėk rinkti 12 testerių (14 d. testavimo taisyklė!)

### D. Smulkūs UX patobulinimai
- Spalvos, dydžiai, garsai, animacijos — ką tik nori

---

## 💡 MANO REKOMENDACIJA RYTOJUI

Siūlau **B (sudėtingumas)** — nes tu pats pajutai, kad Ekstremalus per lengvas,
o tai tiesiogiai veikia žaidimo kokybę. Greita keisti, iškart pamatysi web'e.
Tada, kai turinys patiks — **C (paleidimas)**.

Bet TU sprendi. Tiesiog parašyk raidę (A/B/C/D) arba savo idėją.

---

## 📌 ATSIMINK
- Viskas keičiama/tobulinama bet kada
- Po pakeitimo perdeployinu web → pamatai telefone (inkognito)
- Branch: `claude/android-app-monetization-ads-RORMZ`
- Web testas: inkognito langas (kitaip sena versija)

---

## 🎨 D+. DIZAINO PATOBULINIMAS (naujas — pagal koncepcinį vaizdą)

**Kryptis:** priartinti prie „CYBER BLITZ" mockup (ryškesnis neon, gražesni langeliai).

**Spalvos — atnaujinti AppColors (priimta):**
- bgDark: `#0F141C` (gilesnė nei dabar)
- bgCard: `#161C26`
- neonGreen `#00FF9D`, neonYellow `#FFD000`, neonPink `#FF2E93`,
  neonPurple `#B026FF`, neonBlue `#00E5FF` (nauja!)

**Ką daryti (BE dubliavimo — atnaujinti ESAMUS, ne kurti naujus):**
- AppColors → naujos spalvos
- NeumorphicButton → pridėti glow (išorinis švytėjimas + vidinis šešėlis)
- Pridėti „CYBER BLITZ" paantraštę po MATH GAME
- Didesnis taškų rodymas viršuje („+93 Correct!")
- Gražesnis 3D klausimo langelis (glow border)

**⚠️ Kodo klaidos iš pasiūlymo (NEnaudoti tiesiai):**
- `padding: Offset(...)` → turi būti `EdgeInsets.symmetric(...)`
- `withOpacity()` → mūsų projekte `withValues(alpha: ...)` (deprecated kitaip)
- NEkurti `CyberStyles`/`CyberButton` — turim AppColors + NeumorphicButton (3 taisyklė)

**AI promptai (ateičiai, NE v1):**
- Fono circuit-board raštas — gali praversti
- Miestai/Eiffelio bokštas/kiber-šefas — BŪSIMIEMS žaidimams, ne matematikai

**Realybės pastaba:** Flutter pasieks ~90% to mockup (be foto-realistinio 3D).
Pigūs telefonai: glow/blur saikingai (60fps).
