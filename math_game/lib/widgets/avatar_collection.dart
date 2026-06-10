import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../models/avatar_catalog.dart';
import '../theme/app_theme.dart';

/// Avatarų kolekcija profilyje (kaupiamoji motyvacija).
///
/// Rodo:
///   - dabartinį (aukščiausią atrakintą) avatarą didelį;
///   - progreso juostą iki kito avataro (dar N taškų);
///   - 20 avatarų tinklelį: atrakinti spalvoti, užrakinti pilki su slenksčiu.
///
/// PRINCIPAS: nauda skaičiuojama TIK iš aukščiausio avataro (ne suma).
class AvatarCollection extends StatelessWidget {
  final int totalPoints;
  final AppLang lang;

  const AvatarCollection({
    super.key,
    required this.totalPoints,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final current = AvatarLogic.current(totalPoints);
    final next = AvatarLogic.next(totalPoints);
    const accent = AppColors.neonBlue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _progressCard(s, current, next, accent),
        const SizedBox(height: 16),
        Text(s.avatarsTitle,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: kHeadingFont)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.78,
          children: [
            for (final tier in kAvatarCatalog)
              _avatarCell(s, tier, tier.level == current.level),
          ],
        ),
      ],
    );
  }

  /// Viršutinė kortelė: dabartinis avataras + progresas iki kito.
  Widget _progressCard(
      AppStrings s, AvatarTier current, AvatarTier? next, Color accent) {
    final span = next == null ? 1 : next.threshold - current.threshold;
    final done = (totalPoints - current.threshold).clamp(0, span);
    final ratio = next == null ? 1.0 : (done / span).clamp(0.0, 1.0);
    final left = next == null ? 0 : (next.threshold - totalPoints);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          // Dabartinis avataras — didelis emoji.
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: accent.withValues(alpha: 0.6), width: 2),
            ),
            child: Text(current.emoji, style: const TextStyle(fontSize: 34)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(current.name(lang),
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: kHeadingFont)),
                const SizedBox(height: 2),
                Text(s.freePlaysPerMonth(current.freePlaysPerMonth),
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 7,
                    backgroundColor: AppColors.shadowLight,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 6),
                if (next == null)
                  Text(s.maxAvatarReached,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12))
                else
                  Row(
                    children: [
                      Text('${s.nextAvatar}: ${next.emoji} ',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                      Text(s.pointsToNext(left),
                          style: const TextStyle(
                              color: AppColors.neonBlue, fontSize: 12)),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Vieno avataro langelis tinklelyje.
  Widget _avatarCell(AppStrings s, AvatarTier tier, bool isCurrent) {
    final unlocked = AvatarLogic.isUnlocked(tier, totalPoints);
    final color = unlocked ? AppColors.neonBlue : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        color: isCurrent
            ? AppColors.neonBlue.withValues(alpha: 0.14)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent
              ? AppColors.neonBlue
              : color.withValues(alpha: unlocked ? 0.4 : 0.2),
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Užrakinti — pilkšvi (mažesnis ryškumas).
          Opacity(
            opacity: unlocked ? 1.0 : 0.35,
            child: Text(tier.emoji, style: const TextStyle(fontSize: 26)),
          ),
          const SizedBox(height: 2),
          Text(
            unlocked ? tier.name(lang) : '${tier.threshold ~/ 1000}k',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: unlocked ? AppColors.textPrimary : AppColors.textSecondary,
                fontSize: 9,
                fontWeight: FontWeight.w600),
          ),
          Text(
            '${tier.freePlaysPerMonth}🎮',
            style: TextStyle(color: color, fontSize: 9),
          ),
        ],
      ),
    );
  }
}
