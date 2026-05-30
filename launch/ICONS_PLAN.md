# 🎨 Ikonos ir grafikos planas

Google Play reikalauja kelių grafikos elementų. Štai ką reikia ir kaip
padaryti pagal mūsų Cyber-Neumorphism stilių (DIZAINAS.md 8).

## Reikalinga grafika

| Elementas | Dydis | Kam |
|-----------|-------|-----|
| App ikona | 512×512 PNG | Play Store + telefonas |
| Feature graphic | 1024×500 PNG | Play Store viršuje |
| Ekrano nuotraukos | min 2, telefono dydžio | Play Store galerija |

## App ikonos koncepcija (Cyber-Neumorphism)
- Fonas: tamsus `#121214`
- Centre: stilizuotas simbolis — pvz. `×` arba `=` neon spalva
- Neon švytėjimas (mint `#3DF5A0` arba violetinė `#B14EFF`)
- Apvalūs kampai, „iškilęs" 3D jausmas (neumorfizmas)

## Kaip sukurti (3 būdai)
1. **Canva** (canva.com) — nemokama, paprasta, yra app icon šablonų
2. **AI generatorius** (pvz. dukart paprašyk manęs aprašyti promptą Midjourney/DALL-E)
3. **Figma** — jei moki dizainą

## Ekrano nuotraukos
- Padarysi **iš telefono**, kai paleisi žaidimą (`flutter run`)
- Reikia parodyti: meniu (4 veiksmai), žaidimo ekraną (langelis+žiedas), Top 10
- Telefone: Power + Volume Down = screenshot

## Flutter ikonos įdiegimas (kai turėsi 512×512)
Naudosim `flutter_launcher_icons` paketą — aš sukonfigūruosiu, tu tik
įdėsi PNG failą į projektą. (Padarysim, kai įsidiegsi Flutter.)

---
👉 Ikoną gali pradėti kurti Canva DABAR (nereikia Flutter). Ekrano nuotraukas —
tik po `flutter run`.
