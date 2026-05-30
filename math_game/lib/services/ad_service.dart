import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show VoidCallback, kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob reklamų servisas (M žingsnis).
///
/// Formatai (DIZAINAS.md): banner (tik meniu/rezultatuose), interstitial
/// (tik po sesijos pabaigos, su cooldown). NIEKADA per žaidimo eigą.
///
/// ⚠️ ID: dabar Google oficialūs TEST ID (saugu kūrimui). Tikrus įdėsim S.
/// ⚠️ UMP: rodyti reklamas LEIDŽIAMA tik po sutikimo (L žingsnis). Kol kas
///    `adsAllowed` = true (test). L žingsnyje pajungsim UMP patikrą čia.
class AdService {
  AdService._();

  static bool _initialized = false;

  // Cooldown: interstitial ne dažniau kaip kas 90 s (DIZAINAS.md).
  static DateTime? _lastInterstitial;
  static const Duration _cooldown = Duration(seconds: 90);

  static InterstitialAd? _interstitial;

  /// Ar leidžiama rodyti reklamas. Nustatoma per requestConsent() (UMP, L žingsnis).
  /// SVARBU: „atmetęs" ES vartotojas vis tiek mato NE-personalizuotas reklamas
  /// (pajamos išlieka). false tik jei UMP reikalingas, bet negautas.
  static bool adsAllowed = false;

  /// Ar platforma palaiko AdMob (tik Android/iOS; web — ne).
  static bool get _adsSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static bool get _isAndroid => !kIsWeb && Platform.isAndroid;

  /// Test Ad Unit ID (Google oficialūs). S žingsnyje keisim į tikrus.
  static String get _bannerUnitId => _isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  static String get _interstitialUnitId => _isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';

  /// UMP sutikimas (L žingsnis) — kviečiama main() PRIEŠ init().
  /// Parodo GDPR sutikimo langą (ES) ar automatiškai praleidžia (ne-ES).
  /// Po atsakymo leidžia reklamas (personalizuotas ar ne — sprendžia AdMob).
  static Future<void> requestConsent() async {
    if (!_adsSupported) return; // web — reklamų nėra, praleidžiam
    try {
      final params = ConsentRequestParameters();
      // Atnaujinam sutikimo info; jei reikia formos — parodom.
      await _updateAndShowConsent(params);
    } catch (_) {
      // UMP klaida — saugiausia NErodyti reklamų (privatumas pirma).
      adsAllowed = false;
      return;
    }
    // Formą parodėm/praleidom — reklamas leidžiam (AdMob pats personalizuoja).
    adsAllowed = true;
  }

  static Future<void> _updateAndShowConsent(
      ConsentRequestParameters params) async {
    // requestConsentInfoUpdate naudoja callback'us — apvyniojam į Completer.
    final updated = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      updated.complete,
      (error) => updated.complete(),
    );
    await updated.future;

    final shown = Completer<void>();
    ConsentForm.loadAndShowConsentFormIfRequired((error) => shown.complete());
    await shown.future;
  }

  /// Inicializacija — kviečiama main() (po requestConsent). Saugu kelis kartus.
  /// Jei reklamos neleidžiamos — AdMob neinicijuojam (taupom bateriją/privatumą).
  static Future<void> init() async {
    if (!_adsSupported) return; // web — AdMob neinicijuojam
    if (_initialized || !adsAllowed) return;
    await MobileAds.instance.initialize();
    _initialized = true;
    _preloadInterstitial();
  }

  /// Banner reklama meniu/rezultatų ekranui. Grąžina null, jei neleidžiama.
  /// [onLoaded]/[onFailed] — widget'ui pranešti būseną (listener final, todėl
  /// paduodam čia konstruktoriuje).
  static BannerAd? createBanner({
    required VoidCallback onLoaded,
    required VoidCallback onFailed,
  }) {
    if (!adsAllowed || !_initialized) return null;
    return BannerAd(
      adUnitId: _bannerUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => onLoaded(),
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          onFailed();
        },
      ),
    )..load();
  }

  /// Iš anksto užkrauna interstitial (kad suveiktų akimirksniu).
  static void _preloadInterstitial() {
    if (!adsAllowed) return;
    InterstitialAd.load(
      adUnitId: _interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (_) => _interstitial = null,
      ),
    );
  }

  /// Parodo interstitial, JEI praėjo cooldown ir reklama paruošta.
  /// Žaidimas tęsiasi net jei reklamos nėra (niekada neblokuoja).
  static void maybeShowInterstitial() {
    if (!adsAllowed) return;
    final now = DateTime.now();
    if (_lastInterstitial != null &&
        now.difference(_lastInterstitial!) < _cooldown) {
      return; // dar cooldown
    }
    final ad = _interstitial;
    if (ad == null) {
      _preloadInterstitial(); // nebuvo paruošta — užkraunam kitam kartui
      return;
    }
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitial = null;
        _preloadInterstitial(); // paruošiam kitą
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _interstitial = null;
        _preloadInterstitial();
      },
    );
    _lastInterstitial = now;
    ad.show();
  }
}
