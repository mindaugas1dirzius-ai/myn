import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Užraktų ir monetų API (Etapas 3).
/// Atrakinimas vyksta SERVERYJE (unlockMode/unlockByAds) — klientas tik kviečia.
class UnlockApi {
  UnlockApi._();

  static final _functions =
      FirebaseFunctions.instanceFor(region: 'europe-west1');

  static const int unlockCostCoins = 150;
  static const int adsToUnlock = 2;

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

  /// Atrakintų režimų sąrašas + ar premium aktyvus.
  static Future<UnlockState> state() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const UnlockState(unlocked: {}, premium: false);
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data() ?? {};
    final unlocked = ((data['unlockedModes'] as List<dynamic>?) ?? [])
        .map((e) => e.toString())
        .toSet();
    final premiumUntil = (data['premiumUntil'] as num?)?.toInt() ?? 0;
    return UnlockState(
      unlocked: unlocked,
      premium: premiumUntil > DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Atrakina lygį už coins (serveris nurašo). Grąžina naują balansą arba meta.
  static Future<int> unlockWithCoins(String mode) async {
    final res = await _functions
        .httpsCallable('unlockMode')
        .call<Map<String, dynamic>>({'mode': mode});
    return (res.data['coins'] as num?)?.toInt() ?? 0;
  }

  /// Praneša serveriui apie peržiūrėtą reklamą. Grąžina progresą/atrakinimą.
  static Future<AdUnlockResult> unlockWithAd(String mode) async {
    final res = await _functions
        .httpsCallable('unlockByAds')
        .call<Map<String, dynamic>>({'mode': mode});
    final d = Map<String, dynamic>.from(res.data);
    return AdUnlockResult(
      unlockedNow: d['unlockedNow'] == true || d['alreadyUnlocked'] == true,
      adsWatched: (d['adsWatched'] as num?)?.toInt() ?? 0,
      adsNeeded: (d['adsNeeded'] as num?)?.toInt() ?? adsToUnlock,
    );
  }
}

class UnlockState {
  final Set<String> unlocked;
  final bool premium;
  const UnlockState({required this.unlocked, required this.premium});

  bool isUnlocked(String mode) => premium || unlocked.contains(mode);
}

class AdUnlockResult {
  final bool unlockedNow;
  final int adsWatched;
  final int adsNeeded;
  const AdUnlockResult({
    required this.unlockedNow,
    required this.adsWatched,
    required this.adsNeeded,
  });
}
