import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../services/ad_service.dart';
import '../services/unlock_api.dart';
import '../theme/app_theme.dart';

/// Atrakinimo dialogas (Etapas 3): coins arba reklama.
/// Grąžina true, jei lygis atrakintas.
Future<bool?> showUnlockDialog(
    BuildContext context, String mode, GameLevel level) {
  return showDialog<bool>(
    context: context,
    builder: (_) => _UnlockDialog(mode: mode, level: level),
  );
}

class _UnlockDialog extends StatefulWidget {
  final String mode;
  final GameLevel level;
  const _UnlockDialog({required this.mode, required this.level});

  @override
  State<_UnlockDialog> createState() => _UnlockDialogState();
}

class _UnlockDialogState extends State<_UnlockDialog> {
  int _coins = 0;
  bool _busy = false;
  String? _msg;

  @override
  void initState() {
    super.initState();
    UnlockApi.coins().then((c) {
      if (mounted) setState(() => _coins = c);
    });
  }

  Future<void> _buyWithCoins() async {
    final s = AppStrings.of(context);
    if (_coins < UnlockApi.unlockCostCoins) {
      setState(() => _msg = s.notEnoughCoins);
      return;
    }
    setState(() => _busy = true);
    try {
      await UnlockApi.unlockWithCoins(widget.mode);
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) setState(() { _busy = false; _msg = s.notEnoughCoins; });
    }
  }

  Future<void> _watchAd() async {
    setState(() => _busy = true);
    // Rodom rewarded reklamą; po peržiūros pranešam serveriui (→ +5 žaidimai).
    final watched = await AdService.showRewarded();
    if (!watched) {
      if (mounted) setState(() => _busy = false);
      return;
    }
    try {
      final r = await UnlockApi.unlockWithAd(widget.mode);
      if (!mounted) return;
      if (r.unlockedNow) {
        Navigator.pop(context, true);
      } else {
        setState(() => _busy = false);
      }
    } on FirebaseFunctionsException catch (e) {
      // Tik resource-exhausted = tikras dienos limitas. Kitkas — bendra klaida
      // (pvz. App Check, tinklas) — kad žaidėjas nebūtų klaidinamas.
      if (mounted) {
        final s = AppStrings.of(context);
        setState(() {
          _busy = false;
          _msg = e.code == 'resource-exhausted' ? s.adLimitReached : s.adFailed;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _msg = AppStrings.of(context).adFailed;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final accent = widget.level.color;
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: accent.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🔒 ${s.unlockTitle}',
                style: TextStyle(
                    color: accent, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('${s.yourCoins}: $_coins 🪙',
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            if (_busy)
              CircularProgressIndicator(color: accent)
            else ...[
              // Kelias 1: coins
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _buyWithCoins,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: accent.withValues(alpha: 0.2)),
                  child: Text(s.unlockWithCoins(UnlockApi.unlockCostCoins),
                      style: TextStyle(color: accent)),
                ),
              ),
              const SizedBox(height: 10),
              // Kelias 2: reklama
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _watchAd,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.levelMedium.withValues(alpha: 0.15)),
                  icon: const Icon(Icons.ondemand_video,
                      color: AppColors.levelMedium, size: 18),
                  label: Text(s.unlockWithAd,
                      style: const TextStyle(color: AppColors.levelMedium)),
                ),
              ),
            ],
            if (_msg != null) ...[
              const SizedBox(height: 12),
              Text(_msg!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
            ],
          ],
        ),
      ),
    );
  }
}
