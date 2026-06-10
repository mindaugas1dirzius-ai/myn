import '../l10n/app_strings.dart';

/// Avatarų katalogas (kaupiamoji motyvacija) — 20 pakopų.
///
/// PRINCIPAS (sutarta): naudojame TIK aukščiausio atrakinto avataro naudą,
/// NE sumą — kad ekonomika nesugriūtų ir žaidėjas siektų geresnio, o ne
/// kolekcionuotų pigius. Kiekvienas avataras:
///   - threshold: kiek BENDRŲ (viso gyvenimo) taškų reikia atrakinti;
///   - freePlaysPerMonth: kiek nemokamų žaidimų per mėnesį duoda (be reklamų),
///     jei tai tavo aukščiausias avataras.
///
/// ⚠️ Slenksčiai SUDERINTI taip, kad būtų SUNKU (avataras atrakinamas VISAM
/// laikui ir duoda nemokamų žaidimų KAS MĖNESĮ amžinai → ekonomikos apsauga).
/// Skaičiuojant ≈300–500 tšk./partija:
///   - 1-as nemokamas žaidimas ≈ po ~200 partijų;
///   - didelės dovanos (10+/mėn) — po tūkstančių partijų;
///   - viršūnė (40/mėn) ≈ po dešimčių tūkstančių partijų.
/// Skaičius lengva keisti vienoje vietoje — tai TIK konfigūracija.
class AvatarTier {
  final int level; // 1..20 (rodymui)
  final String emoji; // vektorinę iliustraciją pakeisim vėliau
  final int threshold; // bendri taškai, reikalingi atrakinti
  final int freePlaysPerMonth; // nemokami žaidimai/mėn (jei aukščiausias)
  final String _lt; // pavadinimas LT
  final String _en; // pavadinimas EN

  const AvatarTier({
    required this.level,
    required this.emoji,
    required this.threshold,
    required this.freePlaysPerMonth,
    required String lt,
    required String en,
  })  : _lt = lt,
        _en = en;

  String name(AppLang lang) => lang == AppLang.lt ? _lt : _en;
}

/// Visas katalogas (rikiuotas pagal slenkstį didėjimo tvarka).
const List<AvatarTier> kAvatarCatalog = [
  AvatarTier(level: 1, emoji: '🥚', threshold: 0, freePlaysPerMonth: 0, lt: 'Kiaušinis', en: 'Egg'),
  AvatarTier(level: 2, emoji: '🐣', threshold: 100000, freePlaysPerMonth: 1, lt: 'Viščiukas', en: 'Chick'),
  AvatarTier(level: 3, emoji: '🐤', threshold: 220000, freePlaysPerMonth: 1, lt: 'Paukštukas', en: 'Birdie'),
  AvatarTier(level: 4, emoji: '🦋', threshold: 380000, freePlaysPerMonth: 2, lt: 'Drugelis', en: 'Butterfly'),
  AvatarTier(level: 5, emoji: '🐝', threshold: 580000, freePlaysPerMonth: 2, lt: 'Bitė', en: 'Bee'),
  AvatarTier(level: 6, emoji: '🦊', threshold: 850000, freePlaysPerMonth: 3, lt: 'Lapė', en: 'Fox'),
  AvatarTier(level: 7, emoji: '🦉', threshold: 1200000, freePlaysPerMonth: 3, lt: 'Pelėda', en: 'Owl'),
  AvatarTier(level: 8, emoji: '🐺', threshold: 1650000, freePlaysPerMonth: 4, lt: 'Vilkas', en: 'Wolf'),
  AvatarTier(level: 9, emoji: '🦅', threshold: 2200000, freePlaysPerMonth: 5, lt: 'Erelis', en: 'Eagle'),
  AvatarTier(level: 10, emoji: '🐯', threshold: 2900000, freePlaysPerMonth: 6, lt: 'Tigras', en: 'Tiger'),
  AvatarTier(level: 11, emoji: '🦁', threshold: 3800000, freePlaysPerMonth: 7, lt: 'Liūtas', en: 'Lion'),
  AvatarTier(level: 12, emoji: '🐃', threshold: 4900000, freePlaysPerMonth: 8, lt: 'Buivolas', en: 'Buffalo'),
  AvatarTier(level: 13, emoji: '🦏', threshold: 6200000, freePlaysPerMonth: 10, lt: 'Raganosis', en: 'Rhino'),
  AvatarTier(level: 14, emoji: '🐘', threshold: 7800000, freePlaysPerMonth: 12, lt: 'Dramblys', en: 'Elephant'),
  AvatarTier(level: 15, emoji: '🐋', threshold: 9800000, freePlaysPerMonth: 14, lt: 'Banginis', en: 'Whale'),
  AvatarTier(level: 16, emoji: '🦖', threshold: 12200000, freePlaysPerMonth: 16, lt: 'Dinozauras', en: 'T-Rex'),
  AvatarTier(level: 17, emoji: '🐉', threshold: 15000000, freePlaysPerMonth: 20, lt: 'Drakonas', en: 'Dragon'),
  AvatarTier(level: 18, emoji: '🦄', threshold: 18500000, freePlaysPerMonth: 25, lt: 'Vienaragis', en: 'Unicorn'),
  AvatarTier(level: 19, emoji: '🔥', threshold: 23000000, freePlaysPerMonth: 32, lt: 'Feniksas', en: 'Phoenix'),
  AvatarTier(level: 20, emoji: '🌌', threshold: 30000000, freePlaysPerMonth: 40, lt: 'Galaktika', en: 'Galaxy'),
];

/// Pagalbinė logika avatarams (gryna, be būsenos).
class AvatarLogic {
  AvatarLogic._();

  /// Aukščiausias atrakintas avataras pagal bendrus taškus (visada bent 1-as).
  static AvatarTier current(int totalPoints) {
    var result = kAvatarCatalog.first;
    for (final a in kAvatarCatalog) {
      if (totalPoints >= a.threshold) {
        result = a;
      } else {
        break;
      }
    }
    return result;
  }

  /// Kitas (dar neatrakintas) avataras arba null, jei pasiekta viršūnė.
  static AvatarTier? next(int totalPoints) {
    for (final a in kAvatarCatalog) {
      if (totalPoints < a.threshold) return a;
    }
    return null;
  }

  /// Ar konkretus avataras jau atrakintas.
  static bool isUnlocked(AvatarTier tier, int totalPoints) =>
      totalPoints >= tier.threshold;

  /// Nemokami žaidimai/mėn pagal aukščiausią avatarą (highest-only principas).
  static int monthlyFreePlays(int totalPoints) =>
      current(totalPoints).freePlaysPerMonth;
}
