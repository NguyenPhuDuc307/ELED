import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/gen/app_localizations.dart';
import '../models/speaking_set.dart';
import '../services/speaking_parser.dart';
import '../services/speaking_service.dart';
import '../theme/brutalist_theme.dart';
import '../widgets/brutalist_card.dart';

/// Paste-and-preview screen for adding a new speaking set. Live previews the
/// parsed Q&A while the user is still typing so they can see whether the
/// parser picked up the boundaries before committing.
class SpeakingImportScreen extends StatefulWidget {
  const SpeakingImportScreen({super.key});

  @override
  State<SpeakingImportScreen> createState() => _SpeakingImportScreenState();
}

class _SpeakingImportScreenState extends State<SpeakingImportScreen> {
  final _ctrl = TextEditingController();
  final _topicCtrl = TextEditingController();
  SpeakingSet? _preview;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_recompute);
    _topicCtrl.addListener(_recompute);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _topicCtrl.dispose();
    super.dispose();
  }

  void _recompute() {
    final raw = _ctrl.text;
    final topic = _topicCtrl.text.trim();
    setState(() {
      _preview =
          SpeakingParser.parse(raw, topicOverride: topic.isEmpty ? null : topic);
    });
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null) _ctrl.text = data!.text!;
  }

  Future<void> _save() async {
    final preview = _preview;
    if (preview == null) return;
    await SpeakingService().add(preview);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final canSave = _preview != null && _preview!.items.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(t.speakingImportTitle),
        actions: [
          TextButton(
            onPressed: canSave ? _save : null,
            child: Text(
              t.commonSave,
              style: TextStyle(
                color: canSave
                    ? BrutalistTheme.primary
                    : context.bMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _topicCtrl,
              decoration: InputDecoration(
                labelText: t.speakingTopicLabel,
                hintText: t.speakingTopicHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _ctrl,
              minLines: 8,
              maxLines: 16,
              decoration: InputDecoration(
                labelText: t.speakingPasteLabel,
                hintText: t.speakingPasteHint,
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  tooltip: t.speakingPasteFromClipboard,
                  icon: const Icon(Icons.content_paste_rounded),
                  onPressed: _pasteFromClipboard,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              t.speakingPreviewLabel,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            if (_preview == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Text(
                  t.speakingPreviewEmpty,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            else
              ..._buildPreview(_preview!),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPreview(SpeakingSet set) {
    final t = AppLocalizations.of(context);
    return [
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          set.topic,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          t.speakingItemCount(set.items.length),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      ...set.items.asMap().entries.map((e) {
        final i = e.key + 1;
        final item = e.value;
        return BrutalistCard(
          backgroundColor: BrutalistTheme.primaryLight,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Q$i. ${item.question}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: BrutalistTheme.black,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.answer,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: BrutalistTheme.black.withValues(alpha: 0.7),
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
        );
      }),
    ];
  }
}
