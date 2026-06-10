import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/ad_service.dart';
import 'services/firebase_service.dart';
import 'services/sound_service.dart';
import 'l10n/app_strings.dart';
import 'l10n/language_controller.dart';
import 'theme/app_theme.dart';
import 'screens/category_home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await languageController.load(); // įkraunam išsaugotą kalbą
  // Firebase paliekam prieš runApp() — jis greitas ir lokalus, o ekranams
  // jo reikia (kitaip skaitytų Firestore prieš inicializaciją). Apgaubta:
  // jei nepavyksta, žaidimas tęsiasi offline.
  try {
    await FirebaseService.init();
  } catch (_) {
    // ignoruojam — žaidimas veiks offline
  }
  runApp(const MathGameApp()); // ← ekranas pasirodo IŠKART, niekada nelieka tuščias
  // Garsai — preload į RAM FONE (be await), kad mygtukai grotų be vėlavimo.
  SoundService.instance.init();
  // Sutikimas + reklamos — FONE, be await. UMP forma negali blokuoti paleidimo:
  // jei Google serveris/regionas užstringa, vartotojas vis tiek mato meniu.
  _initAdsInBackground();
}

/// Reklamų inicializacija fone — niekada neblokuoja UI.
Future<void> _initAdsInBackground() async {
  try {
    await AdService.requestConsent(); // UMP (L, GDPR) PIRMA
    await AdService.init(); // AdMob (M) — tik jei sutikimas leidžia
  } catch (_) {
    // UMP/AdMob klaida — žaidimas veikia ir be reklamų
  }
}

class MathGameApp extends StatelessWidget {
  const MathGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: languageController,
      builder: (context, _) {
        // Žaidėjo pasirinkta kalba nustato MaterialApp locale (override).
        // Jei dar nepasirinkta — null, tada sek sistemos/naršyklės kalbą.
        final chosen = languageController.lang;
        final locale = chosen == null
            ? null
            : Locale(chosen == AppLang.lt ? 'lt' : 'en');
        return MaterialApp(
          title: 'Math Game',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          locale: locale, // ← perjungimas veikia per čia
          supportedLocales: const [Locale('lt'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const CategoryHomeScreen(),
        );
      },
    );
  }
}
