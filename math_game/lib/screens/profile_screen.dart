import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../models/game_mode.dart';
import '../services/firebase_service.dart';
import '../services/profile_api.dart';
import '../theme/app_theme.dart';
import '../widgets/rank_dialog.dart';

/// Profilio ekranas (Etapas 1, DIZAINAS.md): grupuota ExpansionTile.
/// 4 veiksmai → išsiskleidžia 4 lygiai su Personal Best.
/// Paspaudus lygį → getMyRank popup (pozicija + Top 10).
/// Vardas viršuje + ✏️ redagavimas.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _username;
  bool _online = false;

  @override
  void initState() {
    super.initState();
    _online = FirebaseService.ready;
    if (_online) _loadName();
  }

  Future<void> _loadName() async {
    final name = await ProfileApi.username();
    if (mounted) setState(() => _username = name);
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
          decoration: const InputDecoration(counterStyle: TextStyle(color: AppColors.textSecondary)),
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Vardas + ✏️
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person, color: AppColors.levelEasy),
                  const SizedBox(width: 8),
                  Text(_username ?? (_online ? '…' : 'Offline'),
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  if (_online)
                    IconButton(
                      icon: const Icon(Icons.edit,
                          color: AppColors.textSecondary, size: 18),
                      onPressed: _editName,
                    ),
                ],
              ),
            ),
            // 4 veiksmai — ExpansionTile (grupuota)
            Expanded(
              child: ListView(
                children: [
                  for (final op in MathOp.values) _opSection(s, op),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _opSection(AppStrings s, MathOp op) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Text(op.symbol,
            style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 24)),
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
