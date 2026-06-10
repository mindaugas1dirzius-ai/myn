import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Žaidėjo profilio duomenys vienoje vietoje (gyvas srautas iš users/{uid}).
///
/// SVARBU (suderinamumas su ateitimi): kai kurių laukų serveris DAR nerašo
/// (totalPoints, pointsByCategory, learnedFacts, streakDays, freePlaysUsed).
/// Juos skaitome saugiai su numatytąja 0/tuščia reikšme — kai Etapas C įjungs
/// jų kaupimą serveryje, profilis pradės rodyti tikras reikšmes BE jokių
/// kliento pakeitimų. Taip ekonomikos funkcijų neliečiame anksčiau laiko.
class PlayerProfile {
  /// Bendri (viso gyvenimo) taškai — kaupiamoji motyvacija avatarams.
  final int totalPoints;

  /// Taškai pagal temą: {'math': 1234, 'nature': 567}.
  final Map<String, int> pointsByCategory;

  /// Monetų balansas (perkamiems paketams).
  final int coins;

  /// Paslapties raktų (🔑) balansas — atskira valiuta „Atspėk paslaptį"
  /// galios priemonėms (atskleisti raidę, +1 spėjimas).
  final int mysteryKeys;

  /// Premium prenumeratos pabaiga (ms; 0 = neturi).
  final int premiumUntilMs;

  /// Išmokti faktai = teisingai atsakyti SUNKAUS/EKSTREMALAUS lygio klausimai.
  final int learnedFacts;

  /// Žaidimų serija (kiek dienų iš eilės žaista).
  final int streakDays;

  /// Kiek nemokamų (avataro) žaidimų jau panaudota šį mėnesį.
  final int freePlaysUsed;

  const PlayerProfile({
    this.totalPoints = 0,
    this.pointsByCategory = const {},
    this.coins = 0,
    this.mysteryKeys = 0,
    this.premiumUntilMs = 0,
    this.learnedFacts = 0,
    this.streakDays = 0,
    this.freePlaysUsed = 0,
  });

  /// Ar premium aktyvus dabar.
  bool get premium =>
      premiumUntilMs > DateTime.now().millisecondsSinceEpoch;

  /// Taškai konkrečioje temoje (0, jei dar nežaista).
  int categoryPoints(String key) => pointsByCategory[key] ?? 0;

  /// Tuščias profilis (neprisijungus / kraunant).
  static const empty = PlayerProfile();
}

/// API gyvam profilio srautui.
class PlayerProfileApi {
  PlayerProfileApi._();

  /// Gyvas users/{uid} srautas → PlayerProfile. Neprisijungus — tuščias.
  static Stream<PlayerProfile> stream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value(PlayerProfile.empty);
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snap) => _from(snap.data() ?? const {}));
  }

  /// Saugus parsinimas — visi nauji laukai gali nebūti (default 0/tuščia).
  static PlayerProfile _from(Map<String, dynamic> data) {
    final rawCats =
        (data['pointsByCategory'] as Map<String, dynamic>?) ?? const {};
    final cats = rawCats.map(
      (key, value) => MapEntry(key, (value as num?)?.toInt() ?? 0),
    );
    return PlayerProfile(
      totalPoints: (data['totalPoints'] as num?)?.toInt() ?? 0,
      pointsByCategory: cats,
      coins: (data['coins'] as num?)?.toInt() ?? 0,
      mysteryKeys: (data['mysteryKeys'] as num?)?.toInt() ?? 0,
      premiumUntilMs: (data['premiumUntil'] as num?)?.toInt() ?? 0,
      learnedFacts: (data['learnedFacts'] as num?)?.toInt() ?? 0,
      streakDays: (data['streakDays'] as num?)?.toInt() ?? 0,
      freePlaysUsed: (data['freePlaysUsed'] as num?)?.toInt() ?? 0,
    );
  }
}
