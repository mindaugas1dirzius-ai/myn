import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_strings.dart';

/// Kalbos valdiklis — leidžia žaidėjui rankiniu būdu perjungti LT↔EN.
/// Pasirinkimas išsaugomas įrenginyje (shared_preferences).
///
/// Jei žaidėjas dar nepasirinko — naudojam telefono/naršyklės kalbą.
class LanguageController extends ChangeNotifier {
  static const _prefKey = 'app_lang';

  AppLang? _lang; // null = dar nepasirinkta (sek sistemos kalbą)

  AppLang? get lang => _lang;

  /// Įkrauna išsaugotą pasirinkimą (kviečiama main() starte).
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      if (saved == 'lt') _lang = AppLang.lt;
      if (saved == 'en') _lang = AppLang.en;
    } catch (_) {
      // jei nepavyko — liekam prie sistemos kalbos
    }
    notifyListeners();
  }

  /// Perjungia LT↔EN ir išsaugo.
  Future<void> toggle(AppLang current) async {
    _lang = current == AppLang.lt ? AppLang.en : AppLang.lt;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, _lang == AppLang.lt ? 'lt' : 'en');
    } catch (_) {}
  }

  /// Galutinė kalba: žaidėjo pasirinkta arba (jei nepasirinkta) sistemos.
  AppLang resolve(Locale systemLocale) {
    if (_lang != null) return _lang!;
    return systemLocale.languageCode == 'en' ? AppLang.en : AppLang.lt;
  }
}

/// Globalus vienetas (paprasta — be papildomų DI paketų).
final languageController = LanguageController();
