import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import '../models/speaking_set.dart';
import '../services/speaking_service.dart';
import '../theme/brutalist_theme.dart';
import '../widgets/brutalist_card.dart';
import 'speaking_import_screen.dart';
import 'speaking_practice_screen.dart';

/// Lists saved speaking sets. Entry point from the menu — empty state pushes
/// the import screen directly so a brand-new user isn't staring at "no
/// content" with no obvious next step.
class SpeakingListScreen extends StatefulWidget {
  const SpeakingListScreen({super.key});

  @override
  State<SpeakingListScreen> createState() => _SpeakingListScreenState();
}

class _SpeakingListScreenState extends State<SpeakingListScreen> {
  List<SpeakingSet> _sets = const [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    await SpeakingService().ready;
    if (!mounted) return;
    setState(() {
      _sets = SpeakingService().all();
      _loaded = true;
    });
  }

  Future<void> _openImport() async {
    await Navigator.of(context).push(smoothRoute(const SpeakingImportScreen()));
    await _refresh();
  }

  Future<void> _openPractice(SpeakingSet set) async {
    await Navigator.of(context)
        .push(smoothRoute(SpeakingPracticeScreen(setId: set.id)));
    await _refresh();
  }

  Future<void> _confirmDelete(SpeakingSet set) async {
    final t = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.speakingDeleteTitle),
        content: Text(t.speakingDeleteConfirm(set.topic)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(t.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(t.commonDelete),
          ),
        ],
      ),
    );
    if (ok == true) {
      await SpeakingService().remove(set.id);
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(t.speakingTitle),
        actions: [
          IconButton(
            tooltip: t.speakingAddNew,
            icon: const Icon(Icons.add_rounded),
            onPressed: _openImport,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : _sets.isEmpty
              ? _buildEmpty(t)
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  itemCount: _sets.length,
                  itemBuilder: (_, i) => _setCard(_sets[i]),
                ),
    );
  }

  Widget _buildEmpty(AppLocalizations t) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mic_none_rounded, size: 56, color: context.bMuted),
            const SizedBox(height: 16),
            Text(
              t.speakingEmptyTitle,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              t.speakingEmptySubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _openImport,
              icon: const Icon(Icons.add_rounded),
              label: Text(t.speakingAddNew),
              style: FilledButton.styleFrom(
                backgroundColor: BrutalistTheme.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _setCard(SpeakingSet set) {
    final t = AppLocalizations.of(context);
    return BrutalistCard(
      backgroundColor: BrutalistTheme.primaryLight,
      onTap: () => _openPractice(set),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: BrutalistTheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.record_voice_over_rounded,
                  color: BrutalistTheme.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    set.topic,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: BrutalistTheme.black,
                          fontSize: 15,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    t.speakingItemCount(set.items.length),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: BrutalistTheme.black.withValues(alpha: 0.55),
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: t.commonDelete,
              icon: Icon(Icons.delete_outline_rounded,
                  color: BrutalistTheme.black.withValues(alpha: 0.55)),
              onPressed: () => _confirmDelete(set),
            ),
          ],
        ),
      ),
    );
  }
}
