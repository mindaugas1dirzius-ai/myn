import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Užraktų ir monetų API (Etapas 3 — PAKETŲ modelis).
///
/// Atrakinimas duoda žaidimų PAKETĄ (ne amžiną prieigą):
///  - 150 🪙  → +2 žaidimai  (unlockMode)
///  - 1 reklama → +2 žaidimai (unlockByAd, max 25 paketai/parą)
/// Po kiekvieno žaidimo serveris (startGame) nuskaičiuoja po 1; pasiekus 0
/// lygis vėl užsirakina. Visi skaičiavimai vyksta SERVERYJE (anti-sukčiavimas).
class UnlockApi {
  UnlockApi._();

  static final _functions =
      FirebaseFunctions.instanceFor(region: 'europe-west1');

  /// Vieno paketo kaina monetomis.
  static const int unlockCostCoins = 150;

  /// Kiek žaidimų duoda vienas paketas (turi sutapti su serverio PLAYS_PER_PACK).
  static const int playsPerPack = 2;

  /// Demo lygis (nemokamas) užrakintose šeimose.
  static const String demoLevel = 'vidutinis';
  static const Set<String> lockedFamilies = {'mix', 'brackets', 'algebra'};

  /// Ar režimas užrakintas pagal nutylėjimą (nepriklauso nuo žaidėjo).
  static bool isLockedByDefault(String family, String level) {
    if (!lockedFamilies.contains(family)) return false;
    return level != demoLevel;
  }

  /// Žaidėjo monetų balansas (pigus skaitymas).
  static Future<int> coins() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return 0;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return (doc.data()?['coins'] as num?)?.toInt() ?? 0;
  }

  /// Atrakintų paketų būsena + ar premium aktyvus (vienkartinis skaitymas).
  static Future<UnlockState> state() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const UnlockState(premium: false);
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return _stateFrom(doc.data() ?? const {});
  }

  /// Gyvas users/{uid} srautas — UI atsinaujina realiu laiku (monetos, paketai).
  /// Neprisijungus grąžina tuščią būseną (viskas užrakinta).
  static Stream<UnlockState> stateStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Stream.value(const UnlockState(premium: false));
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snap) => _stateFrom(snap.data() ?? const {}));
  }

  /// Firestore dokumentą paverčia UnlockState (saugus parsinimas — null laukai OK).
  static UnlockState _stateFrom(Map<String, dynamic> data) {
    final premiumUntil = (data['premiumUntil'] as num?)?.toInt() ?? 0;
    final rawPacks = (data['playPacks'] as Map<String, dynamic>?) ?? const {};
    final playPacks = rawPacks.map(
      (key, value) => MapEntry(key, (value as num?)?.toInt() ?? 0),
    );
    return UnlockState(
      premium: premiumUntil > DateTime.now().millisecondsSinceEpoch,
      premiumUntilMs: premiumUntil,
      playPacks: playPacks,
      coins: (data['coins'] as num?)?.toInt() ?? 0,
    );
  }

  /// Perka paketą (+2 žaidimai) už coins. Grąžina likusį žaidimų skaičių.
  static Future<int> unlockWithCoins(String mode) async {
    final res = await _functions
        .httpsCallable('unlockMode')
        .call(<String, dynamic>{'mode': mode});
    final data = jsonDecode(jsonEncode(res.data)) as Map<String, dynamic>;
    return (data['playsLeft'] as num?)?.toInt() ?? 0;
  }

  /// Praneša serveriui apie peržiūrėtą reklamą → +2 žaidimų paketas.
  /// Meta resource-exhausted, jei pasiektas dienos reklamų limitas.
  static Future<AdUnlockResult> unlockWithAd(String mode) async {
    final res = await _functions
        .httpsCallable('unlockByAd')
        .call(<String, dynamic>{'mode': mode});
    final d = jsonDecode(jsonEncode(res.data)) as Map<String, dynamic>;
    return AdUnlockResult(
      unlockedNow: d['unlockedNow'] == true,
      playsLeft: (d['playsLeft'] as num?)?.toInt() ?? playsPerPack,
      adsLeftToday: (d['adsLeftToday'] as num?)?.toInt() ?? 0,
    );
  }
}

class UnlockState {
  final bool premium;

  /// Premium prenumeratos pabaiga (ms nuo epochos; 0 = niekada). Rodymui profilyje.
  final int premiumUntilMs;

  /// Likę žaidimai pagal režimą, pvz. {'mix_sunkus': 3}.
  final Map<String, int> playPacks;

  /// Žaidėjo monetų balansas iš users/{uid}.coins (rodymui meniu/dialoge).
  final int coins;

  const UnlockState({
    required this.premium,
    this.premiumUntilMs = 0,
    this.playPacks = const {},
    this.coins = 0,
  });

  /// Ar lygis šiuo metu žaidžiamas (premium arba liko žaidimų pakete).
  bool isUnlocked(String mode) => premium || playsLeft(mode) > 0;

  /// Kiek žaidimų liko šiam režimui (0, jei paketas tuščias / neturėtas).
  int playsLeft(String mode) => playPacks[mode] ?? 0;
}

class AdUnlockResult {
  final bool unlockedNow;
  final int playsLeft;
  final int adsLeftToday;
  const AdUnlockResult({
    required this.unlockedNow,
    required this.playsLeft,
    required this.adsLeftToday,
  });
}
