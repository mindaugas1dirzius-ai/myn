import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

/// Firebase paleidimas (D žingsnis): init + App Check + Anonymous Auth.
///
/// Saugu offline: jei konfigūracija dar placeholder (isConfigured == false),
/// init praleidžiamas ir žaidimas veikia su lokaliais klausimais.
class FirebaseService {
  FirebaseService._();

  /// App Check provideris (I žingsnis).
  /// - `debug`        — KŪRIMUI/TESTAVIMUI telefone (reikia debug token'o konsolėje).
  /// - `playIntegrity`— PALEIDIMUI iš Play Store (S žingsnis).
  /// Perjungti S žingsnyje TIK ČIA — viena vieta.
  /// (Web'e nenaudojamas, nes Firebase praleidžiamas — todėl ignore.)
  // ignore: unused_field
  static const AndroidProvider _appCheckProvider = AndroidProvider.debug;

  static bool _ready = false;
  static bool get ready => _ready;

  /// Iškviečiama main() pradžioje. Tylom grįžta, jei dar nesukonfigūruota.
  static Future<void> init() async {
    // Web'e (naršyklės demo) Firebase praleidžiam — Android konfigūracija
    // netinka web'ui ir nukirstų paleidimą. Žaidimas veikia offline.
    if (kIsWeb) return;

    if (!DefaultFirebaseOptions.isConfigured) {
      // Dar nėra tikrų raktų — liekam offline režime.
      return;
    }

    // Visa Firebase init apgaubta try/catch — jei kas nepavyksta,
    // žaidimas TĘSIASI offline, ekranas niekada nelieka tuščias.
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.android);

      await FirebaseAppCheck.instance.activate(
        androidProvider: _appCheckProvider,
      );

      final auth = FirebaseAuth.instance;
      if (auth.currentUser == null) {
        await auth.signInAnonymously();
      }

      _ready = true;
    } catch (_) {
      _ready = false; // offline fallback
    }
  }
}
