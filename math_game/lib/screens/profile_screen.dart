import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../models/avatar_catalog.dart';
import '../models/game_mode.dart';
import '../services/firebase_service.dart';
import '../services/mystery_api.dart';
import '../services/player_profile_api.dart';
import '../services/profile_api.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/avatar_collection.dart';
import '../widgets/rank_dialog.dart';

/// Profilio ekranas — patogi, informatyvi apžvalga vienoje vietoje.
///
/// IŠDĖSTYMAS (sutarta su žaidėju):
///   1. Avataras + vardas (viršuje);
///   2. Greita statistika: bendri taškai · monetos · serija · išmokti faktai;
///   3. Planas (Premium / Nemokamas);
///   4. Rezultatai pagal temą (rekordai + Top 10 pozicija);
///   5. Avatarų tinklelis su progresu iki kito.
///
/// Visi gyvi duomenys ateina per `StreamBuilder<PlayerProfile>` (users/{uid}).
/// Naujus laukus (totalPoints ir kt.) serveris pradės rašyti Etape C — kol kas
/// rodom 0, BE jokių ekonomikos funkcijų pakeitimų.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _username;
  bool _online = false;
  int _solvedMysteries = 0; // „Atspėk paslaptį": išspręsta (istorinis nuopelnas)

  @override
  void initState() {
    super.initState();
    _online = FirebaseService.ready;
    if (_online) {
      _loadName();
      _loadMysteryStatus();
    }
  }

  Future<void> _loadName() async {
    final name = await ProfileApi.username();
    if (mounted) setState(() => _username = name);
  }

  /// Tyliai užkraunam paslapčių statistiką (klaida → lieka 0).
  Future<void> _loadMysteryStatus() async {
    final status = await MysteryApi.status();
    if (!mounted || status == null) return;
    setState(() => _solvedMysteries = status.solvedCount);
  }

  Future<void> _editName() async {
    final s = AppStrings.of(context);
    final controller = TextEditingController(text: _username ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(s.enterName,
            style: const TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: controller,
          maxLength: 16,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
              counterStyle: TextStyle(color: AppColors.textSecondary)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child:
                Text(s.save, style: const TextStyle(color: AppColors.levelEasy)),
          ),
        ],
      ),
    );
    if (result != null && result.length >= 2) {
      await ProfileApi.saveUsername(result);
      if (mounted) setState(() => _username = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(s.profile),
      ),
      body: AppBackground(
        child: SafeArea(
        child: StreamBuilder<PlayerProfile>(
          stream: _online ? PlayerProfileApi.stream() : null,
          builder: (context, snap) {
            final profile = snap.data ?? PlayerProfile.empty;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _header(s, profile),
                const SizedBox(height: 16),
                _statsRow(s, profile),
                const SizedBox(height: 12),
                _planCard(s, profile),
                const SizedBox(height: 12),
                _soundCard(s),
                const SizedBox(height: 12),
                _mysteryCard(s),
                const SizedBox(height: 20),
                Text(s.resultsByTheme,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: kHeadingFont)),
                const SizedBox(height: 4),
                _categorySection(
                  emoji: '🧮',
                  title: s.categoryMath,
                  accent: AppColors.levelEasy,
                  initiallyExpanded: false,
                  children: [for (final op in MathOp.values) _opSection(s, op)],
                ),
                _categorySection(
                  emoji: '🌿',
                  title: s.categoryNature,
                  accent: AppColors.levelExtreme,
                  initiallyExpanded: false,
                  children: [
                    for (final level in _natureLevels) _natureLevelRow(s, level),
                  ],
                ),
                const SizedBox(height: 20),
                // Avatarų progresas + tinklelis (kaupiamoji motyvacija).
                AvatarCollection(
                  totalPoints: profile.totalPoints,
                  lang: s.lang,
                ),
              ],
            );
          },
        ),
        ),
      ),
    );
  }

  /// Viršus: dabartinio avataro emoji + vardas + redagavimas.
  Widget _header(AppStrings s, PlayerProfile profile) {
    final tier = AvatarLogic.current(profile.totalPoints);
    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.neonBlue.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border:
                Border.all(color: AppColors.neonBlue.withValues(alpha: 0.6), width: 2),
          ),
          child: Text(tier.emoji, style: const TextStyle(fontSize: 44)),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_username ?? (_online ? '…' : 'Offline'),
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: kHeadingFont)),
            if (_online)
              IconButton(
                icon: const Icon(Icons.edit,
                    color: AppColors.textSecondary, size: 18),
                onPressed: _editName,
              ),
          ],
        ),
        Text(tier.name(s.lang),
            style: const TextStyle(
                color: AppColors.neonBlue,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: kHeadingFont,
                letterSpacing: 1)),
      ],
    );
  }

  /// Greita statistikos eilutė — 4 plytelės.
  Widget _statsRow(AppStrings s, PlayerProfile profile) {
    return Row(
      children: [
        _statTile('⭐', s.totalPoints, '${profile.totalPoints}'),
        const SizedBox(width: 10),
        _statTile('🪙', s.coins, '${profile.coins}'),
        const SizedBox(width: 10),
        _statTile('🔥', s.streakDays, s.dayShort(profile.streakDays)),
        const SizedBox(width: 10),
        _statTile('🧠', s.learnedFacts, '${profile.learnedFacts}'),
      ],
    );
  }

  Widget _statTile(String emoji, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: kHeadingFont)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  /// Plano kortelė (Premium / Nemokamas) — gyvai iš profilio.
  /// Neaktyvuotam planui rodom prenumeratos pasiūlymą (mokėjimas per Google Play).
  Widget _planCard(AppStrings s, PlayerProfile profile) {
    const gold = Color(0xFFFFD54F);
    final active = profile.premium;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: (active ? gold : AppColors.textSecondary)
                .withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(active ? Icons.workspace_premium : Icons.person_outline,
                  color: active ? gold : AppColors.textSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.planLabel,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                    Text(active ? s.planPremium : s.planFree,
                        style: TextStyle(
                            color: active ? gold : AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              if (active)
                Text(_fmtDate(profile.premiumUntilMs),
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
          if (!active && _online) ...[
            const SizedBox(height: 10),
            Text(s.subscribeOffer,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showSubscribeInfo(s),
                style: ElevatedButton.styleFrom(
                    backgroundColor: gold.withValues(alpha: 0.2)),
                child: Text(s.subscribeBtn,
                    style: const TextStyle(
                        color: gold, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Garso nustatymo kortelė — jungiklis (įjungta/išjungta), gyvai iš
  /// SoundService (išsaugoma telefone). Žaidėjas renkasi „kaip nori".
  Widget _soundCard(AppStrings s) {
    final lt = s.lang == AppLang.lt;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.neonBlue.withValues(alpha: 0.25)),
      ),
      child: ListenableBuilder(
        listenable: SoundService.instance,
        builder: (context, _) {
          final on = SoundService.instance.enabled;
          return Row(
            children: [
              Icon(on ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                  color: on ? AppColors.neonBlue : AppColors.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(lt ? 'Garso efektai' : 'Sound effects',
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
              ),
              Switch(
                value: on,
                activeThumbColor: AppColors.neonBlue,
                onChanged: (v) {
                  SoundService.instance.setEnabled(v);
                  if (v) SoundService.instance.tap();
                },
              ),
            ],
          );
        },
      ),
    );
  }

  /// „Atspėk paslaptį" statistika — kiek paslapčių išspręsta (istorinis nuopelnas).
  Widget _mysteryCard(AppStrings s) {
    final lt = s.lang == AppLang.lt;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.neonBlue.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Text('🕵️', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(lt ? 'Išspręsta paslapčių' : 'Mysteries solved',
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
          ),
          Text('$_solvedMysteries',
              style: const TextStyle(
                  color: AppColors.neonBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: kHeadingFont)),
        ],
      ),
    );
  }

  Future<void> _showSubscribeInfo(AppStrings s) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(s.subscribeTitle,
            style: const TextStyle(color: AppColors.textPrimary)),
        content: Text(s.subscribeComingSoon,
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('OK', style: TextStyle(color: AppColors.levelEasy)),
          ),
        ],
      ),
    );
  }

  /// ms → „YYYY-MM-DD".
  String _fmtDate(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  /// Atviri gamtos lygiai (turi patvirtintą turinį serveryje).
  static const List<GameLevel> _natureLevels = [
    GameLevel.lengvas,
    GameLevel.vidutinis,
  ];

  /// Temos (kategorijos) grupė — kad temos nesimaišytų.
  Widget _categorySection({
    required String emoji,
    required String title,
    required Color accent,
    required bool initiallyExpanded,
    required List<Widget> children,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        leading: Text(emoji, style: const TextStyle(fontSize: 24)),
        title: Text(title,
            style: TextStyle(
                color: accent, fontSize: 18, fontWeight: FontWeight.bold)),
        childrenPadding: const EdgeInsets.only(left: 8),
        children: children,
      ),
    );
  }

  /// Vieno gamtos lygio eilutė (rekordas + Top 10 popup).
  Widget _natureLevelRow(AppStrings s, GameLevel level) {
    final mode = 'nature_${level.name}';
    return ListTile(
      leading: const SizedBox(width: 8),
      title: Text(level.title(s), style: TextStyle(color: level.color)),
      trailing: FutureBuilder<int?>(
        future: _online ? ProfileApi.personalBest(mode) : Future.value(null),
        builder: (context, snap) {
          final text = !_online
              ? 'Offline'
              : snap.connectionState == ConnectionState.waiting
                  ? '…'
                  : snap.data == null
                      ? s.noRecord
                      : '🏆 ${snap.data}';
          return Text(text,
              style: const TextStyle(color: AppColors.textSecondary));
        },
      ),
      onTap: _online ? () => showRankDialog(context, mode, level) : null,
    );
  }

  Widget _opSection(AppStrings s, MathOp op) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Text(op.symbol,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 24)),
        title: Text(op.label(s),
            style: const TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        children: [
          for (final level in GameLevel.values) _levelRow(s, op, level),
        ],
      ),
    );
  }

  Widget _levelRow(AppStrings s, MathOp op, GameLevel level) {
    final mode = buildModeId(op, level);
    return ListTile(
      title: Text(level.title(s), style: TextStyle(color: level.color)),
      trailing: FutureBuilder<int?>(
        future: _online ? ProfileApi.personalBest(mode) : Future.value(null),
        builder: (context, snap) {
          final text = !_online
              ? 'Offline'
              : snap.connectionState == ConnectionState.waiting
                  ? '…'
                  : snap.data == null
                      ? s.noRecord
                      : '🏆 ${snap.data}';
          return Text(text,
              style: const TextStyle(color: AppColors.textSecondary));
        },
      ),
      onTap: _online ? () => showRankDialog(context, mode, level) : null,
    );
  }
}
