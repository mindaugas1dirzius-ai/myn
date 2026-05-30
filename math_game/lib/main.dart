import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/ad_service.dart';
import 'services/firebase_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase init (saugu offline — praleidžiama, kol nėra tikros konfigūracijos).
  await FirebaseService.init();
  // UMP sutikimas PIRMA (L žingsnis, GDPR) — tik tada reklamos.
  await AdService.requestConsent();
  // AdMob init (M) — vyksta tik jei sutikimas leidžia (adsAllowed).
  await AdService.init();
  runApp(const MathGameApp());
}

class MathGameApp extends StatelessWidget {
  const MathGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
    );
  }
}
