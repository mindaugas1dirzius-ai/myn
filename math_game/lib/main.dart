import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/ad_service.dart';
import 'services/firebase_service.dart';
import 'l10n/language_controller.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await languageController.load(); // įkraunam išsaugotą kalbą
  // Visa inicializacija apgaubta — jei kas nepavyksta, app VIS TIEK paleidžiamas
  // (offline). Ekranas niekada nelieka tuščias.
  try {
    await FirebaseService.init();
    await AdService.requestConsent(); // UMP (L, GDPR) PIRMA
    await AdService.init(); // AdMob (M) — tik jei sutikimas leidžia
  } catch (_) {
    // ignoruojam — žaidimas veiks offline
  }
  runApp(const MathGameApp());
}

class MathGameApp extends StatelessWidget {
  const MathGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: languageController,
      builder: (context, _) => MaterialApp(
      title: 'Math Game',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      // Dvikalbystė (LT + EN) — DIZAINAS.md 0 sprendimas.
      supportedLocales: const [Locale('lt'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomeScreen(),
      ),
    );
  }
}
