import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// Firebase konfigūracija (D žingsnis).
///
/// ⚠️ PLACEHOLDER: reikšmės su `TODO_` — laukia tavo Firebase projekto duomenų
/// iš `google-services.json`. Kai atsiųsi reikšmes, jas įstatysiu čia.
/// (Tai NĖRA slapti duomenys — vieši app identifikatoriai, saugu git'e.)
///
/// Kol placeholder'iai — Firebase init praleidžiamas (žr. main.dart),
/// kad žaidimas veiktų offline ir nelūžtų.
class DefaultFirebaseOptions {
  /// Ar konfigūracija jau užpildyta tikromis reikšmėmis?
  static bool get isConfigured => !android.apiKey.startsWith('TODO_');

  // Android (kol kas vienintelė platforma; iOS pridėsim vėliau jei reikės).
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAzEIR5dko4iJRyWhbb3_oxl1aZUhOUrVE',
    appId: '1:140827271266:android:a55e35a97ca6e141e3313b',
    messagingSenderId: '140827271266',
    projectId: 'math-game-9862f',
    storageBucket: 'math-game-9862f.firebasestorage.app',
  );
}
