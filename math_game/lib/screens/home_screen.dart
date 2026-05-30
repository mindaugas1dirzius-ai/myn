import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Pradinis ekranas — laikinas C žingsnio karkasas.
/// G žingsnyje čia atsiras režimų pasirinkimas (4 veiksmai × 4 lygiai).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'MATH GAME',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: 36,
                    letterSpacing: 4,
                    color: AppColors.levelEasy,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Pamatas paruoštas · C žingsnis',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
