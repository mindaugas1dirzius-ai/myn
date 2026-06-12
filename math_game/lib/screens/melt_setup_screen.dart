import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../models/melt_models.dart';
import '../services/melt_api.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/neumorphic_button.dart';
import 'melt_screen.dart';

/// „Raidžių tirpimo" nustatymai prieš startą: žaidėjas PATS pasirenka tempą.
///
/// Lėtas tempas — ramus žaidimas prie kavos; greitas — didesnė rizika, bet ir
/// didesnis maksimalus laimėjimas (×1.25 / ×1.5). Procentinė taškų formulė
/// lėto žaidėjo nebaudžia: svarbu, kokią SAVO laiko dalį sunaudojai.
class MeltSetupScreen extends StatefulWidget {
  const MeltSetupScreen({super.key});

  @override
  State<MeltSetupScreen> createState() => _MeltSetupScreenState();
}

class _MeltSetupScreenState extends State<MeltSetupScreen> {
  static const _accent = AppColors.levelMedium;

  int _limitSec = 120;
  int _intervalSec = 10;
  bool _busy = false;

  AppLang _appLang = AppLang.en;
  bool get _isLt => _appLang == AppLang.lt;
  String get _lang => _isLt ? 'lt' : 'en';
  String _t(String lt, String en) => _isLt ? lt : en;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _appLang = AppStrings.of(context).lang;
  }

  double get _speedCoef =>
      _intervalSec <= 5 ? 1.5 : (_intervalSec <= 10 ? 1.25 : 1.0);

  Future<void> _start() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final MeltView v = await MeltApi.start(_lang, _limitSec, _intervalSec);
      if (!mounted) return;
      if (v.resumed) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_t('Tęsiama pradėta partija!', 'Resuming your game!')),
          backgroundColor: AppColors.surface,
        ));
      } else if (v.pendingApplied > 0) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_t(
              'Pritaikytos ${v.pendingApplied} uždirbtos raidės — jos taškų nemažina!',
              '${v.pendingApplied} earned letters applied — they cost no points!')),
          backgroundColor: AppColors.surface,
        ));
      }
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => MeltScreen(initial: v)),
      );
      if (mounted) Navigator.of(context).pop(); // grįžus — atgal į meniu/sheet
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_t('Nepavyko pasiekti serverio. Bandyk vėliau.',
            'Could not reach the server. Try again later.')),
        backgroundColor: AppColors.surface,
      ));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
        title: Text(_t('Raidžių tirpimas', 'Letter Melt'),
            style: const TextStyle(color: AppColors.textPrimary)),
      ),
      body: AppBackground(
        accent: _accent,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _t('⏳ Raidės tirps savaime — spėk frazę, kol nesutirpo taškai!',
                            '⏳ Letters melt on their own — guess before your points melt away!'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 24),
                      _sectionLabel(_t('LAIKO LIMITAS', 'TIME LIMIT')),
                      const SizedBox(height: 8),
                      Row(children: [
                        _choice('1 min', _limitSec == 60,
                            () => setState(() => _limitSec = 60)),
                        const SizedBox(width: 8),
                        _choice('2 min', _limitSec == 120,
                            () => setState(() => _limitSec = 120)),
                        const SizedBox(width: 8),
                        _choice('5 min', _limitSec == 300,
                            () => setState(() => _limitSec = 300)),
                      ]),
                      const SizedBox(height: 20),
                      _sectionLabel(
                          _t('RAIDĖ TIRPSTA KAS', 'A LETTER MELTS EVERY')),
                      const SizedBox(height: 8),
                      Row(children: [
                        _choice('5 s  ×1.5', _intervalSec == 5,
                            () => setState(() => _intervalSec = 5)),
                        const SizedBox(width: 8),
                        _choice('10 s  ×1.25', _intervalSec == 10,
                            () => setState(() => _intervalSec = 10)),
                        const SizedBox(width: 8),
                        _choice('20 s  ×1.0', _intervalSec == 20,
                            () => setState(() => _intervalSec = 20)),
                      ]),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border:
                              Border.all(color: _accent.withValues(alpha: 0.4)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _t('Greitesnis tirpimas = didesnis maksimalus laimėjimas (×${_speedCoef.toStringAsFixed(2)})',
                                  'Faster melt = bigger maximum prize (×${_speedCoef.toStringAsFixed(2)})'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: AppColors.textPrimary, fontSize: 13),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _t('Taškai skaičiuojami pagal TAVO laiko dalį — lėtas žaidimas nebaudžiamas. Uždirbtos raidės iš viktorinų taškų nemažina!',
                                  'Points depend on the share of YOUR time used — playing slow is not punished. Letters earned in quizzes cost nothing!'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      NeumorphicButton(
                        accent: AppColors.correct,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        onTap: _busy ? null : _start,
                        child: _busy
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2))
                            : Text(
                                _t('PRADĖTI', 'START'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: AppColors.correct,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    letterSpacing: 2),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              const BannerAdWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(text,
      style: const TextStyle(
          color: AppColors.textSecondary, fontSize: 12, letterSpacing: 1.5));

  Widget _choice(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? _accent.withValues(alpha: 0.18)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: selected ? _accent : _accent.withValues(alpha: 0.3),
                width: selected ? 2 : 1),
          ),
          child: Text(label,
              style: TextStyle(
                  color: selected ? _accent : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
        ),
      ),
    );
  }
}
