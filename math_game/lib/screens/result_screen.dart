import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';
import '../services/ad_service.dart';
import '../services/profile_api.dart';
import '../widgets/app_background.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/neumorphic_button.dart';
import 'leaderboard_screen.dart';
import 'mystery_screen.dart';

/// Vieno klausimo apžvalga žaidimo pabaigoje (gamtai): kuris atsakymas
/// teisingas, ką pasirinko žaidėjas ir KODĖL teisinga (mokomoji vertė).
class AnswerReview {
  final String question; // klausimo tekstas
  final String emoji; // iliustracinis emoji (gali būti tuščias)
  final String correctAnswer; // teisingas variantas
  final String pickedAnswer; // ką pasirinko žaidėjas ("" = praleista)
  final String explanation; // kodėl teisinga
  final bool wasCorrect; // ar žaidėjas atsakė teisingai

  const AnswerReview({
    required this.question,
    required this.emoji,
    required this.correctAnswer,
    required this.pickedAnswer,
    required this.explanation,
    required this.wasCorrect,
  });
}

/// G5: rezultatų ekranas po 10 klausimų (BENDRAS — matematikai IR gamtai).
/// Taškai ČIA — kosmetiniai (oficialius patvirtina serveris submitScore).
///
/// GENERALIZUOTA: ekranas nežino, ar tai matematika, ar gamta. Akcento
/// spalvą ([accent]) ir „Žaisti dar" veiksmą ([onPlayAgain]) paduoda iškvietėjas.
/// [review] — neprivaloma: gamta paduoda klausimų apžvalgą (kodėl teisinga),
/// matematika palieka null (jokios apžvalgos).
class ResultScreen extends StatelessWidget {
  final Color accent; // lygio/temos spalva
  // SVARBU: paduodam GYVĄ (šio ekrano) context'ą, ne užfiksuotą iš seno žaidimo
  // ekrano. Antraip „Žaisti dar" naudotų jau pašalinto (defunct) widget'o
  // context'ą → Navigator nieko nedarytų (mygtukas „kabėtų").
  final void Function(BuildContext ctx) onPlayAgain;
  final String modeId;
  final int correct;
  final int total;
  final int score;
  final bool online; // ar žaista prisijungus (rodyti Top 10?)
  final int coinsEarned; // šioje sesijoje uždirbtos monetos
  final bool promptName; // raginti įvesti vardą (Top 10 + dar auto-vardas)
  final List<AnswerReview>? review; // gamtos klausimų apžvalga (arba null)
  final int earnedLetters; // „Atspėk paslaptį": raidės, uždirbtos šiame žaidime
  final int pendingMysteryLetters; // kiek iš viso laukia neatvertų raidžių

  const ResultScreen({
    super.key,
    required this.accent,
    required this.onPlayAgain,
    required this.modeId,
    required this.correct,
    required this.total,
    required this.score,
    this.online = false,
    this.coinsEarned = 0,
    this.promptName = false,
    this.review,
    this.earnedLetters = 0,
    this.pendingMysteryLetters = 0,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);

    return Scaffold(
      body: AppBackground(
        accent: accent,
        child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Text(
                s.resultTitle,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 26,
                      letterSpacing: 2,
                      color: accent,
                    ),
              ),
              const SizedBox(height: 10),
              // TITULAS „iššoka" (kaip „Tiesa ar mitas?") — smagi pabaiga.
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.3, end: 1),
                duration: const Duration(milliseconds: 550),
                curve: Curves.elasticOut,
                builder: (context, sc, child) =>
                    Transform.scale(scale: sc, child: child),
                child: Text(_rankEmoji(),
                    style: const TextStyle(fontSize: 44)),
              ),
              const SizedBox(height: 4),
              Text(_rating(s), style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),

              // Teisingų santykis
              Text('$correct / $total', style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 52, fontWeight: FontWeight.bold,
                fontFamily: kHeadingFont)),
              // „Egzamino lapas" — žali/raudoni taškučiai (kai turim apžvalgą).
              if (review != null && review!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 5,
                  children: [
                    for (final r in review!)
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (r.wasCorrect
                                  ? AppColors.levelEasy
                                  : AppColors.wrong)
                              .withValues(alpha: 0.9),
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 16),

              // Animuotas taškų skaičius (0 -> score), dopamino efektas
              Text(s.score, style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 14, letterSpacing: 2)),
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: score),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOut,
                builder: (context, value, _) => Text(
                  '$value',
                  style: TextStyle(
                    color: accent,
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    fontFamily: kHeadingFont,
                  ),
                ),
              ),

              // Uždirbtos monetos (jei online)
              if (online && coinsEarned > 0) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.monetization_on,
                        color: AppColors.levelMedium, size: 20),
                    const SizedBox(width: 6),
                    Text('+$coinsEarned ${s.coinsEarned}',
                        style: const TextStyle(
                            color: AppColors.levelMedium,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ],

              // 🕵️ „Atspėk paslaptį" kabliukas: uždirbtos raidės + „Eiti spėti".
              // Rodom tik online ir tik jei šiame žaidime uždirbom raidžių
              // ARBA iš viso laukia neatvertų (kad žaidėjas grįžtų prie spėjimo).
              if (online && (earnedLetters > 0 || pendingMysteryLetters > 0)) ...[
                const SizedBox(height: 20),
                _MysteryHook(
                  earnedLetters: earnedLetters,
                  pendingLetters: pendingMysteryLetters,
                ),
              ],

              // 🏆 Raginimas įvesti vardą (variantas C: Top 10 + dar auto-vardas)
              if (promptName) ...[
                const SizedBox(height: 20),
                _Top10Prompt(accent: accent),
              ],

              // ⚠️ Offline — paaiškinam, kodėl nėra taškų/monetų/Top 10.
              if (!online) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.levelMedium.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.levelMedium.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.wifi_off,
                          color: AppColors.levelMedium, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          s.offlineResultNote,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Atsakymų apžvalga (tik gamta — kodėl teisinga / ką pasirinkai)
              if (review != null && review!.isNotEmpty) ...[
                _ReviewSection(review: review!, accent: accent),
                const SizedBox(height: 32),
              ],

              // Top 10 lentelė (tik online; offline — kvietimas prisijungti)
              LeaderboardView(mode: modeId, accent: accent, online: online),

              const SizedBox(height: 32),

              // Žaisti dar — to paties režimo (interstitial su cooldown PRIEŠ)
              SizedBox(
                width: 240,
                child: NeumorphicButton(
                  accent: accent,
                  onTap: () {
                    AdService.maybeShowInterstitial(); // tik po sesijos, su cooldown
                    onPlayAgain(context); // GYVAS context — iškvietėjas naviguoja
                  },
                  child: Text(s.playAgain, style: TextStyle(
                    color: accent, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),

              // Į meniu (interstitial su cooldown PRIEŠ)
              SizedBox(
                width: 240,
                child: NeumorphicButton(
                  accent: AppColors.textSecondary,
                  onTap: () {
                    AdService.maybeShowInterstitial();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: Text(s.toMenu, style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 16)),
                ),
              ),

              const SizedBox(height: 24),
              // Banner — rezultatų ekrane (leista; ne žaidimo metu)
              const BannerAdWidget(),
            ],
          ),
        ),
        ),
      ),
    );
  }

  // (apžvalgos sekcija — žemiau, _ReviewSection)

  /// Įvertinimo žinutė pagal teisingų skaičių.
  String _rating(AppStrings s) {
    if (correct == total) return s.ratingPerfect;
    if (correct >= total * 0.7) return s.ratingGood;
    if (correct >= total * 0.4) return s.ratingOk;
    return s.ratingTryAgain;
  }

  /// Titulo emoji pagal rezultatą (kaip „Tiesa ar mitas?" rangai).
  String _rankEmoji() {
    if (correct == total) return '🏆';
    if (correct >= total * 0.7) return '🥇';
    if (correct >= total * 0.4) return '🥈';
    return '🔎';
  }
}

/// Atsakymų apžvalga (gamta): kiekvienas klausimas — emoji, teisingas
/// atsakymas (žaliai), ką pasirinko žaidėjas, ir paaiškinimas KODĖL teisinga.
/// Mokomoji vertė + retencija (žaidėjas sužino, kodėl klydo).
class _ReviewSection extends StatelessWidget {
  final List<AnswerReview> review;
  final Color accent;
  const _ReviewSection({required this.review, required this.accent});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          s.reviewTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: accent, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        for (final r in review) _reviewCard(s, r),
      ],
    );
  }

  Widget _reviewCard(AppStrings s, AnswerReview r) {
    const green = AppColors.levelEasy;
    const red = Color(0xFFEF5350);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: (r.wasCorrect ? green : red).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Klausimas su emoji
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (r.emoji.isNotEmpty) ...[
                Text(r.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(r.question,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
              ),
              Icon(r.wasCorrect ? Icons.check_circle : Icons.cancel,
                  color: r.wasCorrect ? green : red, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          // Teisingas atsakymas (visada žaliai)
          Row(
            children: [
              Text(s.reviewCorrectLabel,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(r.correctAnswer,
                    style: const TextStyle(
                        color: green,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          // Žaidėjo atsakymas (tik jei klydo — parodom, ką pasirinko)
          if (!r.wasCorrect) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Text(s.reviewYourAnswer,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                      r.pickedAnswer.isEmpty ? s.reviewSkipped : r.pickedAnswer,
                      style: const TextStyle(color: red, fontSize: 14)),
                ),
              ],
            ),
          ],
          // Paaiškinimas (kodėl teisinga)
          if (r.explanation.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(r.explanation,
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.35)),
          ],
        ],
      ),
    );
  }
}

/// 🕵️ „Atspėk paslaptį" kabliukas rezultatų ekrane.
///
/// Parodo, kiek raidžių uždirbta šiame žaidime („+N raidės!"), kiek iš viso
/// laukia neatvertų, ir pulsuojantį mygtuką „Eiti spėti" → MysteryScreen.
/// Pulsavimas (jei yra laukiančių raidžių) atkreipia dėmesį — žaidėjas grįžta.
class _MysteryHook extends StatefulWidget {
  final int earnedLetters;
  final int pendingLetters;
  const _MysteryHook({required this.earnedLetters, required this.pendingLetters});

  @override
  State<_MysteryHook> createState() => _MysteryHookState();
}

class _MysteryHookState extends State<_MysteryHook>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  static const Color _accent = AppColors.neonBlue;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    // Pulsuojam tik jei tikrai yra ką spėti (laukia neatvertų raidžių).
    if (widget.pendingLetters > 0) _pulse.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  // Tikroji (resolved) kalba per AppStrings.of(context) — NE languageController
  // tiesiogiai. Kitaip, nepasirinkus kalbos rankiniu būdu (lang == null), UI
  // būtų LT, o šis tekstas EN (nesutapimas).
  bool _lt(BuildContext context) => AppStrings.of(context).lang == AppLang.lt;

  @override
  Widget build(BuildContext context) {
    final earned = widget.earnedLetters;
    final pending = widget.pendingLetters;
    final lt = _lt(context);

    final title = lt ? '🕵️ Atspėk paslaptį' : '🕵️ Guess the Mystery';
    final earnedLine = earned > 0
        ? (lt ? '+$earned raidės!' : '+$earned letters!')
        : null;
    final pendingLine = pending > 0
        ? (lt
            ? 'Laukia $pending neatvertų raidžių'
            : '$pending letters waiting to reveal')
        : null;
    final btn = lt ? 'Eiti spėti' : 'Go guess';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _accent.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
              color: _accent.withValues(alpha: 0.2),
              blurRadius: 12,
              spreadRadius: 1),
        ],
      ),
      child: Column(
        children: [
          Text(title,
              style: const TextStyle(
                  color: _accent, fontSize: 17, fontWeight: FontWeight.bold)),
          if (earnedLine != null) ...[
            const SizedBox(height: 8),
            Text(earnedLine,
                style: const TextStyle(
                    color: AppColors.levelEasy,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ],
          if (pendingLine != null) ...[
            const SizedBox(height: 6),
            Text(pendingLine,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
          ],
          const SizedBox(height: 14),
          // Pulsuojantis mygtukas (jei laukia raidžių). Be laukiančių — statiškas.
          ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 1.06).animate(
              CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
            ),
            child: SizedBox(
              width: 200,
              child: NeumorphicButton(
                accent: _accent,
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const MysteryScreen()));
                },
                child: Text(btn,
                    style: const TextStyle(
                        color: _accent,
                        fontSize: 17,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Raginimas įvesti vardą patekus į Top 10 (variantas C).
/// Dingsta po sėkmingo įvedimo (todėl Stateful).
class _Top10Prompt extends StatefulWidget {
  final Color accent;
  const _Top10Prompt({required this.accent});

  @override
  State<_Top10Prompt> createState() => _Top10PromptState();
}

class _Top10PromptState extends State<_Top10Prompt> {
  bool _done = false;

  Future<void> _enterName() async {
    final s = AppStrings.of(context);
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(s.enterName,
            style: const TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: controller,
          maxLength: 16,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(s.save,
                style: const TextStyle(color: AppColors.levelEasy)),
          ),
        ],
      ),
    );
    if (name != null && name.length >= 2) {
      await ProfileApi.saveUsername(name);
      if (mounted) setState(() => _done = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return const SizedBox.shrink();
    final s = AppStrings.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.accent.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
              color: widget.accent.withValues(alpha: 0.2),
              blurRadius: 12,
              spreadRadius: 1),
        ],
      ),
      child: Column(
        children: [
          Text(s.top10Title,
              style: TextStyle(
                  color: widget.accent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(s.top10Body,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => setState(() => _done = true),
                child: Text(s.later,
                    style: const TextStyle(color: AppColors.textSecondary)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _enterName,
                style: ElevatedButton.styleFrom(
                    backgroundColor: widget.accent.withValues(alpha: 0.2)),
                child: Text(s.enterNameBtn,
                    style: TextStyle(color: widget.accent)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
