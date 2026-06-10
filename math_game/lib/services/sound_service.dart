import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SoundService — visi žaidimo garso efektai vienoje vietoje.
///
/// PRO sprendimai (kad nebūtų vėlavimo / „lago"):
///  - kiekvienam efektui SAVAS [AudioPlayer], garsas įkraunamas į RAM
///    (`setSource`) PROGRAMĖLĖS PALEIDIMO metu (preload) → paspaudus mygtuką
///    garsas suveikia akimirksniu (PlayerMode.lowLatency = Android SoundPool);
///  - garsumas subtilus (žr. gen_sounds.py) — neerzina, nerėkia;
///  - jungiklis (įjungta/išjungta) išsaugomas telefone (shared_preferences),
///    todėl išlieka ir po programėlės perkrovimo;
///  - ChangeNotifier → jungiklio mygtukas UI atsinaujina iškart;
///  - visi kvietimai apgaubti try/catch → garsas NIEKADA nesugriauna žaidimo.
class SoundService extends ChangeNotifier {
  SoundService._();
  static final SoundService instance = SoundService._();

  static const _prefKey = 'sound_enabled';

  bool _enabled = true;
  bool get enabled => _enabled;

  bool _ready = false;
  final Map<String, AudioPlayer> _players = {};

  /// Efektų failai (assets/sounds/). AssetSource prideda „assets/" pats.
  static const Map<String, String> _effects = {
    'tap': 'sounds/tap.wav',
    'swoosh': 'sounds/swoosh.wav',
    'correct': 'sounds/correct.wav',
    'wrong': 'sounds/wrong.wav',
    'points': 'sounds/points.wav',
    'win': 'sounds/win.wav',
  };

  /// Iškviečiama VIENĄ kartą per programėlės startą (main.dart).
  /// Įkrauna nustatymą ir preload'ina visus garsus į RAM.
  Future<void> init() async {
    if (_ready) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _enabled = prefs.getBool(_prefKey) ?? true;
    } catch (_) {
      _enabled = true;
    }

    for (final entry in _effects.entries) {
      try {
        final p = AudioPlayer(playerId: 'sfx_${entry.key}');
        await p.setReleaseMode(ReleaseMode.stop);
        await p.setPlayerMode(PlayerMode.lowLatency); // žaibiškas atkūrimas
        await p.setSource(AssetSource(entry.value)); // PRELOAD į RAM
        _players[entry.key] = p;
      } catch (_) {
        // Jei vienas garsas neužsikrauna — tyliai praleidžiam (ne kritinis).
      }
    }
    _ready = true;
  }

  /// Įjungti/išjungti garsą (jungiklis). Išsaugo pasirinkimą.
  Future<void> setEnabled(bool value) async {
    _enabled = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, value);
    } catch (_) {
      // nieko — kitą kartą tiesiog numatytasis
    }
  }

  Future<void> toggle() => setEnabled(!_enabled);

  /// Pagrindinis atkūrimas: nuo pradžios (kad spaudžiant greitai kartotųsi).
  ///
  /// [exclusive] = true: prieš grojant SUSTABDO visus kitus (išskyrus trumpą
  /// „tap" spragtelėjimą) → joks ankstesnis garsas (pvz. „swoosh") nepersidengia
  /// su nauju (pvz. „ding"/„buzz"). Stabdymo NELaukiam (be await), kad
  /// nevėlintume svarbaus garso (lowLatency išlieka žaibiškas).
  Future<void> _play(String key, {bool exclusive = false}) async {
    if (!_enabled) return;
    final p = _players[key];
    if (p == null) return;
    if (exclusive) {
      for (final e in _players.entries) {
        if (e.key != key && e.key != 'tap') {
          e.value.stop();
        }
      }
    }
    // SVARBU: low-latency (SoundPool) režime `seek()` NEPALAIKOMAS — meta klaidą
    // ir garsas nuskamba. Todėl perkrauname per stop()+resume() (groja nuo
    // pradžios). Atskiri try, kad net jei `stop` nepavyktų — `resume` vis tiek
    // suveiktų (garsas svarbiau nei tikslus perkrovimas).
    try {
      await p.stop();
    } catch (_) {}
    try {
      await p.resume();
    } catch (_) {}
  }

  // --- Patogūs trumpiniai (skaitomas kodas iškvietimo vietoje) ---
  // tap/points = trumpi, gali sluoksniuotis; swoosh/correct/wrong/win =
  // „solo" (sustabdo kitus), kad garsai keistų vienas kitą ŠVARIAI.
  void tap() => _play('tap');
  void swoosh() => _play('swoosh', exclusive: true);
  void correct() => _play('correct', exclusive: true);
  void wrong() => _play('wrong', exclusive: true);
  void points() => _play('points');
  void win() => _play('win', exclusive: true);

  @override
  void dispose() {
    for (final p in _players.values) {
      p.dispose();
    }
    _players.clear();
    super.dispose();
  }
}
