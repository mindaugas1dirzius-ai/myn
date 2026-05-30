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

  static bool _ready = false;
  static bool get ready => _ready;

  /// Iškviečiama main() pradžioje. Tylom grįžta, jei dar nesukonfigūruota.
  static Future<void> init() async {
    if (!DefaultFirebaseOptions.isConfigured) {
      // Dar nėra tikrų raktų — liekam offline režime.
      return;
    }

    await Firebase.initializeApp(options: DefaultFirebaseOptions.android);

    // App Check (Play Integrity) — DIZAINAS.md saugumas.
    // Debug provider kūrimui; gamyboje keisime į playIntegrity (J/I žingsnis).
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
    );

    // Anonymous Auth — kiekvienas žaidėjas gauna stabilų ID be registracijos.
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      await auth.signInAnonymously();
    }

    _ready = true;
  }
}
