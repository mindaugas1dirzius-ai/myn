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
    apiKey: 'TODO_API_KEY',
    appId: 'TODO_APP_ID',
    messagingSenderId: 'TODO_SENDER_ID',
    projectId: 'TODO_PROJECT_ID',
    storageBucket: 'TODO_STORAGE_BUCKET',
  );
}
