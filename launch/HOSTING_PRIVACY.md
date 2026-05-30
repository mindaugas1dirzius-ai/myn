# 🌐 Kaip nemokamai patalpinti Privacy Policy (reikia viešos URL)

Google Play reikalauja **viešos nuorodos** į privatumo politiką. Štai 3
nemokami būdai (rinkis vieną):

## Variantas A — GitHub Pages (rekomenduoju, jau turim GitHub)
1. Šitame repo jau yra `launch/PRIVACY_POLICY_EN.md`
2. GitHub → repo Settings → Pages → įjungti (Source: main branch)
3. Gausi URL: `https://mindaugas1dirzius-ai.github.io/myn/...`
4. Arba paprasčiau — atskiras viešas Gist (gist.github.com): įklijuoji tekstą,
   gauni nuorodą iškart

## Variantas B — Google Sites (paprasčiausia ne-techniškai)
1. sites.google.com → New site
2. Įklijuoji Privacy Policy tekstą (iš PRIVACY_POLICY_EN.md)
3. Publish → gauni viešą URL

## Variantas C — app-ads.txt + sava svetainė
Jei turėsi domeną — patalpini ten. (Vėliau, neprivaloma v1.)

---

## app-ads.txt (rekomenduojama, ne privaloma)
Kai turėsi developer website Play Console, įdėk failą
`tavosvetaine.com/app-ads.txt` su turiniu (gausi iš AdMob konsolės):
```
google.com, pub-XXXXXXXXXXXXXXXX, DIRECT, f08c47fec0942fa0
```
(`pub-XXX` = tavo tikras AdMob publisher ID). Tai apsaugo nuo reklamų
sukčiavimo ir gerina pasiūlymus.

---
👉 Greičiausias kelias: **Google Sites** (variantas B) — 5 min, nereikia kodo.
