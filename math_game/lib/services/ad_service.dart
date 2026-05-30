import 'dart:io';
import 'package:flutter/foundation.dart' show VoidCallback;
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

  /// L žingsnyje čia gražinsim UMP sutikimo rezultatą. Kol kas — leidžiam (test).
  static bool adsAllowed = true;

  /// Test Ad Unit ID (Google oficialūs). S žingsnyje keisim į tikrus.
  static String get _bannerUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  static String get _interstitialUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';

  /// Inicializacija — kviečiama main() (po Firebase). Saugu kelis kartus.
  static Future<void> init() async {
    if (_initialized) return;
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
