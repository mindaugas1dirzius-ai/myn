import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../models/game_mode.dart';
import '../services/firebase_service.dart';
import '../services/unlock_api.dart';
import '../theme/app_theme.dart';
import '../widgets/neumorphic_button.dart';
import '../widgets/unlock_dialog.dart';
import 'game_screen.dart';

/// G1, 2-as žingsnis: pasirinkus veiksmą — renkamės sunkumo lygį.
/// Etapas 3: užrakinti lygiai rodo 🔒 + atrakinimo dialogą.
class LevelSelectScreen extends StatefulWidget {
  final MathOp op;
  const LevelSelectScreen({super.key, required this.op});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  UnlockState _state = const UnlockState(unlocked: {}, premium: false);
  bool _online = false;

  @override
  void initState() {
    super.initState();
    _online = FirebaseService.ready;
    if (_online) _loadState();
  }

  Future<void> _loadState() async {
    final st = await UnlockApi.state();
    if (mounted) setState(() => _state = st);
  }

  /// Ar šis lygis žaidžiamas (nemokamas, atrakintas arba offline).
  bool _playable(GameLevel level) {
    if (!_online) return true; // offline — viskas atviras (demo)
    final mode = buildModeId(widget.op, level);
    if (!UnlockApi.isLockedByDefault(widget.op.id, level.name)) return true;
    return _state.isUnlocked(mode);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('${widget.op.label(s)}  ${widget.op.symbol}'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                    final locked = !_playable(level);
                    return NeumorphicButton(
                      accent: locked ? AppColors.textSecondary : level.color,
                      onTap: () => locked
                          ? _onLockedTap(level)
                          : _onPlayTap(level),
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
                              color: locked
                                  ? AppColors.textSecondary
                                  : level.color,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          if (locked) ...[
                            const SizedBox(width: 10),
                            Text('${UnlockApi.unlockCostCoins}🪙',
                                style: const TextStyle(
                                    color: AppColors.levelMedium,
                                    fontSize: 14)),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
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
    final unlocked = await showUnlockDialog(context, mode, level);
    if (unlocked == true && mounted) {
      await _loadState(); // atsinaujinam — langelis atsidaro
    }
  }
}
