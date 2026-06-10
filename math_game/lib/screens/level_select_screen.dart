import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../models/game_mode.dart';
import '../services/firebase_service.dart';
import '../services/unlock_api.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/neumorphic_button.dart';
import '../widgets/unlock_dialog.dart';
import 'game_screen.dart';

/// G1, 2-as žingsnis: pasirinkus veiksmą — renkamės sunkumo lygį.
/// Etapas 3: užrakinti lygiai rodo 🔒 + kainą ir reklamų progresą; monetų
/// balansas — viršuje. Būsena imama GYVAI iš Firestore (StreamBuilder): atrakinus
/// spyna nukrenta pati, o pasikeitus monetoms skaitiklis atsinaujina iškart.
class LevelSelectScreen extends StatefulWidget {
  final MathOp op;
  const LevelSelectScreen({super.key, required this.op});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  bool _online = false;

  @override
  void initState() {
    super.initState();
    _online = FirebaseService.ready;
  }

  /// Ar šis lygis žaidžiamas (nemokamas, atrakintas arba offline).
  bool _playable(GameLevel level, UnlockState state) {
    if (!_online) return true; // offline — viskas atviras (demo)
    if (!UnlockApi.isLockedByDefault(widget.op.id, level.name)) return true;
    return state.isUnlocked(buildModeId(widget.op, level));
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('${widget.op.label(s)}  ${widget.op.symbol}'),
      ),
      body: AppBackground(
        child: SafeArea(
        child: _online
            ? StreamBuilder<UnlockState>(
                stream: UnlockApi.stateStream(),
                builder: (context, snap) => _content(s,
                    snap.data ??
                        const UnlockState(premium: false)),
              )
            : _content(s, const UnlockState(premium: false)),
        ),
      ),
    );
  }

  Widget _content(AppStrings s, UnlockState state) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_online)
            Align(
              alignment: Alignment.centerRight,
              child: _CoinBalance(coins: state.coins),
            ),
          const SizedBox(height: 8),
          Text(s.pickLevel,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              itemCount: GameLevel.values.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (context, i) {
                final level = GameLevel.values[i];
                final mode = buildModeId(widget.op, level);
                final locked = !_playable(level, state);
                // „Mokamas" lygis = užrakintas pagal nutylėjimą (kiber-lygos).
                final paid = _online &&
                    UnlockApi.isLockedByDefault(widget.op.id, level.name);
                final left = state.playsLeft(mode);
                return NeumorphicButton(
                  accent: locked ? AppColors.textSecondary : level.color,
                  onTap: () =>
                      locked ? _onLockedTap(level) : _onPlayTap(level),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (locked) ...[
                        const Icon(Icons.lock,
                            color: AppColors.textSecondary, size: 18),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        level.title(s),
                        style: TextStyle(
                          color:
                              locked ? AppColors.textSecondary : level.color,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          fontFamily: kHeadingFont,
                        ),
                      ),
                      if (locked) ...[
                        const SizedBox(width: 10),
                        Text('${UnlockApi.unlockCostCoins}🪙',
                            style: const TextStyle(
                                color: AppColors.levelMedium, fontSize: 14)),
                      ] else if (paid && !state.premium && left > 0) ...[
                        const SizedBox(width: 10),
                        Text(s.playsLeft(left),
                            style: const TextStyle(
                                color: AppColors.neonBlue, fontSize: 14)),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onPlayTap(GameLevel level) {
    final modeId = buildModeId(widget.op, level);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            GameScreen(modeId: modeId, op: widget.op, level: level),
      ),
    );
  }

  Future<void> _onLockedTap(GameLevel level) async {
    final mode = buildModeId(widget.op, level);
    // Atrakinus, Firestore srautas pats atnaujins UI — perkrauti nereikia.
    await showUnlockDialog(context, mode, level);
  }
}

/// Monetų balanso „piliulė" viršuje — TIK rodo (read-only). Balansą keičia
/// vien serveris (anti-sukčiavimas), todėl čia jokio rašymo.
class _CoinBalance extends StatelessWidget {
  final int coins;
  const _CoinBalance({required this.coins});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: AppColors.levelMedium.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🪙', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text('$coins',
              style: const TextStyle(
                  color: AppColors.levelMedium,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
