/// „Raidžių tirpimas" serverio kontrakto modeliai (klientas).
///
/// SAUGUMAS: klientas NIEKADA negauna pilno teksto, kol partija nesibaigė.
/// Visi laikai skaičiuojami serveryje; klientas gauna serverNow ir laiko
/// poslinkį naudoja tik kosmetiniam laikrodžiui.
///
/// EKONOMIKA: jokio banko ir mokamų pagalbų. Taškai tirpsta su laiku ir
/// savaime atsiverenčiomis raidėmis: P = pMax × (likęs laikas %) ×
/// (neatvertų raidžių %). Nemokamos raidės iš viktorinų laimėjimo NEMAŽINA.
library;

import 'mystery_models.dart' show MysteryCell;

/// Aktyvios tirpimo partijos būsena (startMelt / syncMelt).
class MeltView {
  final String mysteryId;
  final String hint;
  final String category;
  final int level;
  final List<MysteryCell> mask;
  final List<String> pool;
  final int totalLetters;
  final int autoRevealed; // automatiškai atsivėrusios (baudžia formulę)
  final int freeRevealed; // nemokamos iš viktorinų (nebaudžia)
  final int limitSec;
  final int intervalSec;
  final int startedAt; // serverio ms
  final int serverNow; // serverio ms atsakymo momentu (laikrodžio sinchronui)
  final int remainingMs;
  final int nextRevealInMs;
  final int pMax;
  final int potentialPointsNow;
  final int keys;
  final bool resumed;
  final int pendingApplied; // kiek nemokamų raidžių pritaikyta starte
  // Spėjimo langas: SPĖTI sustabdo laiką 30 s atsakymui suvesti.
  final bool freezeUsed;
  final int frozenLeftMs; // kiek ms dar užšaldyta (0 — nešaldoma)
  final int lockedAt; // 0 — langas neatidarytas; kitaip serverio ms
  final int lockMsUsed; // ankstesnių langų susikaupęs užšaldytas laikas ms
  final int freezesLeft; // kiek spėjimo langų liko šioje partijoje
  final int wrongPenalty; // bauda 🔑 už klaidingą spėjimą (rodymui)

  const MeltView({
    required this.mysteryId,
    required this.hint,
    required this.category,
    required this.level,
    required this.mask,
    required this.pool,
    required this.totalLetters,
    required this.autoRevealed,
    required this.freeRevealed,
    required this.limitSec,
    required this.intervalSec,
    required this.startedAt,
    required this.serverNow,
    required this.remainingMs,
    required this.nextRevealInMs,
    required this.pMax,
    required this.potentialPointsNow,
    required this.keys,
    this.resumed = false,
    this.pendingApplied = 0,
    this.freezeUsed = false,
    this.frozenLeftMs = 0,
    this.lockedAt = 0,
    this.lockMsUsed = 0,
    this.freezesLeft = 0,
    this.wrongPenalty = 0,
  });

  factory MeltView.fromJson(Map<String, dynamic> j) {
    final rawMask = (j['mask'] as List<dynamic>?) ?? const [];
    final rawPool = (j['pool'] as List<dynamic>?) ?? const [];
    return MeltView(
      mysteryId: j['mysteryId'] as String? ?? '',
      hint: j['hint'] as String? ?? '',
      category: j['category'] as String? ?? '',
      level: (j['level'] as num?)?.toInt() ?? 1,
      mask: rawMask
          .map((e) => MysteryCell.fromJson(e as Map<String, dynamic>))
          .toList(),
      pool: rawPool.map((e) => e.toString()).toList(),
      totalLetters: (j['totalLetters'] as num?)?.toInt() ?? 0,
      autoRevealed: (j['autoRevealed'] as num?)?.toInt() ?? 0,
      freeRevealed: (j['freeRevealed'] as num?)?.toInt() ?? 0,
      limitSec: (j['limitSec'] as num?)?.toInt() ?? 120,
      intervalSec: (j['intervalSec'] as num?)?.toInt() ?? 10,
      startedAt: (j['startedAt'] as num?)?.toInt() ?? 0,
      serverNow: (j['serverNow'] as num?)?.toInt() ?? 0,
      remainingMs: (j['remainingMs'] as num?)?.toInt() ?? 0,
      nextRevealInMs: (j['nextRevealInMs'] as num?)?.toInt() ?? 0,
      pMax: (j['pMax'] as num?)?.toInt() ?? 0,
      potentialPointsNow: (j['potentialPointsNow'] as num?)?.toInt() ?? 0,
      keys: (j['keys'] as num?)?.toInt() ?? 0,
      resumed: j['resumed'] as bool? ?? false,
      pendingApplied: (j['pendingApplied'] as num?)?.toInt() ?? 0,
      freezeUsed: j['freezeUsed'] as bool? ?? false,
      frozenLeftMs: (j['frozenLeftMs'] as num?)?.toInt() ?? 0,
      lockedAt: (j['lockedAt'] as num?)?.toInt() ?? 0,
      lockMsUsed: (j['lockMsUsed'] as num?)?.toInt() ?? 0,
      freezesLeft: (j['freezesLeft'] as num?)?.toInt() ?? 0,
      wrongPenalty: (j['wrongPenalty'] as num?)?.toInt() ?? 0,
    );
  }
}

/// syncMelt rezultatas: arba atnaujinta lenta, arba pasibaigęs laikas.
class MeltSync {
  final bool expired;
  final String? answer; // tik kai expired
  final MeltView? view; // tik kai NE expired

  const MeltSync({required this.expired, this.answer, this.view});

  factory MeltSync.fromJson(Map<String, dynamic> j) {
    final expired = j['expired'] as bool? ?? false;
    return MeltSync(
      expired: expired,
      answer: j['answer'] as String?,
      view: expired ? null : MeltView.fromJson(j),
    );
  }
}

/// Spėjimo rezultatas (guessMelt).
class MeltGuessOutcome {
  final bool correct;
  final bool expired;
  final String? answer; // kai teisinga arba laikas baigėsi
  final int awarded;
  final int totalKeys;
  final int nextGuessInMs; // cooldown iki kito spėjimo (po klaidos)
  final int penalty; // nominali bauda už klaidą 🔑
  final int penaltyApplied; // kiek realiai nuskaičiuota (balansas ne <0)
  // Sąžiningas laimėjimo paaiškinimas.
  final int pMax;
  final int elapsedMs;
  final int limitMs;
  final int autoPenaltyCount;
  final int totalLetters;

  const MeltGuessOutcome({
    required this.correct,
    required this.expired,
    this.answer,
    this.awarded = 0,
    this.totalKeys = 0,
    this.nextGuessInMs = 0,
    this.penalty = 0,
    this.penaltyApplied = 0,
    this.pMax = 0,
    this.elapsedMs = 0,
    this.limitMs = 0,
    this.autoPenaltyCount = 0,
    this.totalLetters = 0,
  });

  factory MeltGuessOutcome.fromJson(Map<String, dynamic> j) {
    final b = (j['breakdown'] as Map<String, dynamic>?) ?? const {};
    return MeltGuessOutcome(
      correct: j['correct'] as bool? ?? false,
      expired: j['expired'] as bool? ?? false,
      answer: j['answer'] as String?,
      awarded: (j['awarded'] as num?)?.toInt() ?? 0,
      totalKeys: (j['totalKeys'] as num?)?.toInt() ?? 0,
      nextGuessInMs: (j['nextGuessInMs'] as num?)?.toInt() ?? 0,
      penalty: (j['penalty'] as num?)?.toInt() ?? 0,
      penaltyApplied: (j['penaltyApplied'] as num?)?.toInt() ?? 0,
      pMax: (b['pMax'] as num?)?.toInt() ?? 0,
      elapsedMs: (b['elapsedMs'] as num?)?.toInt() ?? 0,
      limitMs: (b['limitMs'] as num?)?.toInt() ?? 0,
      autoPenaltyCount: (b['autoPenaltyCount'] as num?)?.toInt() ?? 0,
      totalLetters: (b['totalLetters'] as num?)?.toInt() ?? 0,
    );
  }
}
