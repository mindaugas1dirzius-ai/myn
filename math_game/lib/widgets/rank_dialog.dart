import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../services/profile_api.dart';
import '../theme/app_theme.dart';
import '../screens/leaderboard_screen.dart';

/// Popup (DIZAINAS.md): paspaudus režimą profilyje — pozicija + Top 10.
/// getMyRank kviečiama TIK čia (taupom serverio resursus).
Future<void> showRankDialog(
    BuildContext context, String mode, GameLevel level) async {
  await showDialog<void>(
    context: context,
    builder: (context) {
      final s = AppStrings.of(context);
      return Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: level.color.withValues(alpha: 0.5)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pozicija (getMyRank)
              FutureBuilder<RankResult>(
                future: ProfileApi.myRank(mode),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(color: level.color);
                  }
                  if (!snap.hasData || !snap.data!.hasScore) {
                    return Text(s.noRecord,
                        style: const TextStyle(color: AppColors.textSecondary));
                  }
                  final r = snap.data!;
                  return Column(
                    children: [
                      Text('🏆', style: const TextStyle(fontSize: 28)),
                      Text(s.yourRank(r.rank, r.total),
                          style: TextStyle(
                              color: level.color,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ],
                  );
                },
              ),
              const Divider(color: AppColors.shadowLight, height: 24),
              // Top 10 to režimo (realaus laiko)
              LeaderboardView(mode: mode, accent: level.color, online: true),
            ],
          ),
        ),
      );
    },
  );
}
