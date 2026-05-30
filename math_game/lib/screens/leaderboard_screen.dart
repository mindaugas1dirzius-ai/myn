import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../services/leaderboard_api.dart';
import '../theme/app_theme.dart';

/// K: Top 10 lyderių lentelė konkrečiam režimui (realaus laiko per Firestore).
/// Rodoma rezultatų ekrane. Offline — nerodoma (taupom resursus).
class LeaderboardView extends StatelessWidget {
  final String mode;
  final Color accent;
  final bool online; // ar žaista prisijungus (server režimas)

  const LeaderboardView({
    super.key,
    required this.mode,
    required this.accent,
    required this.online,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);

    // Offline: netraukiam Firestore, rodom blausų kvietimą prisijungti.
    if (!online) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          s.leaderboardOffline,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      );
    }

    return StreamBuilder<List<LeaderboardEntry>>(
      stream: LeaderboardApi.top10(mode),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: CircularProgressIndicator(color: accent),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(s.leaderboardError,
                style: const TextStyle(color: AppColors.textSecondary)),
          );
        }
        final entries = snapshot.data ?? const [];
        if (entries.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(s.leaderboardEmpty,
                style: const TextStyle(color: AppColors.textSecondary)),
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(s.leaderboardTitle,
                style: TextStyle(
                    color: accent, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            for (var i = 0; i < entries.length; i++)
              _row(i + 1, entries[i]),
          ],
        );
      },
    );
  }

  Widget _row(int rank, LeaderboardEntry e) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text('$rank.',
                style: TextStyle(color: accent, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(e.username,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textPrimary)),
          ),
          Text('${e.score}',
              style: const TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
