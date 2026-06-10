import 'package:flutter/material.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';

/// Garso įjungimo/išjungimo mygtukas (garsiakalbio ikona).
///
/// Klausosi [SoundService] (ChangeNotifier) → ikona atsinaujina iškart, kai
/// garsas perjungiamas (net jei tas pats mygtukas yra ir kitame ekrane).
/// Naudojamas žaidimo viršuje ir profilyje.
class SoundToggleButton extends StatelessWidget {
  const SoundToggleButton({super.key, this.size = 24});

  final double size;

  @override
  Widget build(BuildContext context) {
    final sound = SoundService.instance;
    return ListenableBuilder(
      listenable: sound,
      builder: (context, _) {
        final on = sound.enabled;
        return IconButton(
          tooltip: on ? 'Garsas: įjungtas' : 'Garsas: išjungtas',
          icon: Icon(
            on ? Icons.volume_up_rounded : Icons.volume_off_rounded,
            color: on ? AppColors.neonBlue : AppColors.textSecondary,
            size: size,
          ),
          onPressed: () {
            sound.toggle();
            if (sound.enabled) sound.tap(); // grįžtamasis ryšys įjungus
          },
        );
      },
    );
  }
}
