import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import '../models/vocabulary.dart';
import '../services/collection_service.dart';
import '../services/csv_service.dart';
import '../services/custom_word_service.dart';
import '../theme/brutalist_theme.dart';
import '../widgets/brutalist_card.dart';

/// Lets the user paste a list of words and add them to a collection in one
/// go. Words are matched (case-insensitive) against the bundled vocabulary
/// so we don't pollute collections with typos or words the rest of the app
/// can't render.
class BulkImportScreen extends StatefulWidget {
  const BulkImportScreen({super.key});

  @override
  State<BulkImportScreen> createState() => _BulkImportScreenState();
}

class _BulkImportScreenState extends State<BulkImportScreen> {
  // Sentinel for the dropdown's "create new" entry — anything that's
  // not a valid collection name works.
  static const _kCreateNewSentinel = '__create_new__';

  final TextEditingController _pasteCtrl = TextEditingController();
  final TextEditingController _newNameCtrl = TextEditingController();

  Map<String, List<String>> _collections = const {};
  String? _selectedCollection; // null = nothing chosen
  bool _creatingNew = false;
  bool _loadingVocab = true;
  bool _busy = false;
  bool _showSkipped = false;

  Set<String> _vocabKeys = const {};
  _PreviewResult? _preview;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _pasteCtrl.dispose();
    _newNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final collections = await CollectionService.getCollections();
    final vocab = await CsvService.loadAllVocabulary(excludeKnown: false);
    if (!mounted) return;
    setState(() {
      _collections = collections;
      _vocabKeys = {for (final Vocabulary v in vocab) v.word.toLowerCase()};
      _loadingVocab = false;
      // Pre-select the first existing collection so the picker isn't empty.
      if (collections.isNotEmpty) {
        _selectedCollection = collections.keys.first;
      }
    });
  }

  /// Splits the pasted text on newlines + commas + semicolons + tabs.
  /// Trims whitespace, lowercases, dedupes while preserving order.
  List<String> _tokenize(String raw) {
    final seen = <String>{};
    final out = <String>[];
    for (final part in raw.split(RegExp(r'[\n,;\t]'))) {
      final t = part.trim().toLowerCase();
      if (t.isEmpty) continue;
      if (seen.add(t)) out.add(t);
    }
    return out;
  }

  void _runPreview() {
    final t = AppLocalizations.of(context);
    final tokens = _tokenize(_pasteCtrl.text);
    if (tokens.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.bulkImportEmptyInput),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
    final existing = _resolveTargetWords();
    final matched = <String>[];
    final custom = <String>[];
    final already = <String>[];
    for (final tok in tokens) {
      if (existing.contains(tok)) {
        already.add(tok);
      } else if (_vocabKeys.contains(tok)) {
        matched.add(tok);
      } else {
        // Not in the bundled CSV — treated as "custom", will be translated
        // via Google at commit time and stored in CustomWordService.
        custom.add(tok);
      }
    }
    setState(() {
      _preview = _PreviewResult(
        matched: matched,
        custom: custom,
        already: already,
      );
      _showSkipped = false;
    });
  }

  /// Words already in the target collection — so the preview can say
  /// "12 already in collection" instead of silently double-counting.
  Set<String> _resolveTargetWords() {
    if (_creatingNew) return const {};
    final name = _selectedCollection;
    if (name == null) return const {};
    return (_collections[name] ?? const []).map((w) => w.toLowerCase()).toSet();
  }

  Future<void> _commitAdd() async {
    final t = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final preview = _preview;
    if (preview == null || preview.toAdd.isEmpty) return;

    String? targetName = _selectedCollection;
    if (_creatingNew) {
      final newName = _newNameCtrl.text.trim();
      if (newName.isEmpty) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(t.bulkImportNeedCollection),
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }
      targetName = newName;
    }
    if (targetName == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(t.bulkImportNeedCollection)),
      );
      return;
    }

    setState(() => _busy = true);

    if (_creatingNew && !_collections.containsKey(targetName)) {
      await CollectionService.createCollection(targetName);
    }

    // Translate + persist custom words first so the collection renderer
    // has their meaning ready by the time it opens.
    if (preview.custom.isNotEmpty) {
      await CustomWordService().translateAndStore(preview.custom);
    }

    for (final w in preview.toAdd) {
      await CollectionService.addWord(targetName, w);
    }

    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          t.bulkImportDoneToast(preview.toAdd.length, targetName),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
    navigator.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.bulkImportTitle)),
      body: _loadingVocab
          ? LinearProgressIndicator(
              minHeight: 3,
              backgroundColor: context.bBorder.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation(context.bBorder),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _label(t.bulkImportTargetLabel),
                  const SizedBox(height: 8),
                  _collectionPicker(t),
                  if (_creatingNew) ...[
                    const SizedBox(height: 8),
                    _newNameField(t),
                  ],
                  const SizedBox(height: 20),
                  _label(t.bulkImportPasteLabel),
                  const SizedBox(height: 8),
                  _pasteField(t),
                  const SizedBox(height: 16),
                  _previewButton(t),
                  if (_preview != null) ...[
                    const SizedBox(height: 16),
                    _previewCard(t, _preview!),
                    const SizedBox(height: 16),
                    _confirmButton(t, _preview!),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.bMuted,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
      );

  Widget _collectionPicker(AppLocalizations t) {
    final names = _collections.keys.toList();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: context.bBg,
        border: Border.all(color: context.bSubtle, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _creatingNew
              ? _kCreateNewSentinel
              : (names.contains(_selectedCollection) ? _selectedCollection : null),
          hint: Text(t.bulkImportPickCollection,
              style: TextStyle(color: context.bMuted)),
          items: [
            for (final n in names)
              DropdownMenuItem(value: n, child: Text(n)),
            DropdownMenuItem(
              value: _kCreateNewSentinel,
              child: Text(
                t.bulkImportCreateNew,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: BrutalistTheme.primary,
                ),
              ),
            ),
          ],
          onChanged: (v) {
            setState(() {
              if (v == _kCreateNewSentinel) {
                _creatingNew = true;
                _selectedCollection = null;
              } else {
                _creatingNew = false;
                _selectedCollection = v;
              }
              // Target change invalidates any prior preview's already-in count.
              if (_preview != null) _preview = null;
            });
          },
        ),
      ),
    );
  }

  Widget _newNameField(AppLocalizations t) {
    return TextField(
      controller: _newNameCtrl,
      autofocus: true,
      decoration: InputDecoration(
        hintText: t.bulkImportNewNameHint,
        hintStyle: TextStyle(color: context.bMuted),
        filled: true,
        fillColor: context.bBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.bSubtle, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.bSubtle, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: BrutalistTheme.primary, width: 2),
        ),
      ),
    );
  }

  Widget _pasteField(AppLocalizations t) {
    return TextField(
      controller: _pasteCtrl,
      minLines: 6,
      maxLines: 16,
      textCapitalization: TextCapitalization.none,
      decoration: InputDecoration(
        hintText: t.bulkImportPasteHint,
        hintStyle: TextStyle(color: context.bMuted),
        filled: true,
        fillColor: context.bBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.bSubtle, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.bSubtle, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: BrutalistTheme.primary, width: 2),
        ),
      ),
      onChanged: (_) {
        if (_preview != null) setState(() => _preview = null);
      },
    );
  }

  Widget _previewButton(AppLocalizations t) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: context.bBorder, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          foregroundColor: context.bBorder,
        ),
        onPressed: _busy ? null : _runPreview,
        icon: const Icon(Icons.search_rounded, size: 20),
        label: Text(t.bulkImportPreview,
            style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _previewCard(AppLocalizations t, _PreviewResult p) {
    return BrutalistCard(
      backgroundColor: context.bBg,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _statLine(
              Icons.check_circle_rounded,
              BrutalistTheme.primary,
              t.bulkImportPreviewMatched(p.matched.length),
            ),
            if (p.custom.isNotEmpty) ...[
              const SizedBox(height: 8),
              _statLine(
                Icons.translate_rounded,
                BrutalistTheme.accent,
                t.bulkImportPreviewCustom(p.custom.length),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => setState(() => _showSkipped = !_showSkipped),
                child: Text(
                  _showSkipped ? t.bulkImportHideSkipped : t.bulkImportShowSkipped,
                  style: const TextStyle(
                    color: BrutalistTheme.primary,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              if (_showSkipped) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final w in p.custom) _chip(w),
                  ],
                ),
              ],
            ],
            if (p.already.isNotEmpty) ...[
              const SizedBox(height: 8),
              _statLine(
                Icons.info_outline_rounded,
                context.bMuted,
                t.bulkImportAlreadyIn(p.already.length),
              ),
            ],
            if (p.matched.isEmpty && p.custom.isEmpty && p.already.isEmpty)
              Text(t.bulkImportNoMatches,
                  style: TextStyle(color: context.bMuted)),
          ],
        ),
      ),
    );
  }

  Widget _statLine(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: BrutalistTheme.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: context.bBorder,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _confirmButton(AppLocalizations t, _PreviewResult p) {
    final addCount = p.toAdd.length;
    final canAdd = addCount > 0 && !_busy;
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: BrutalistTheme.primary,
          foregroundColor: BrutalistTheme.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: canAdd ? _commitAdd : null,
        icon: _busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: BrutalistTheme.white,
                ),
              )
            : const Icon(Icons.add_rounded, size: 22),
        label: Text(
          _busy && p.custom.isNotEmpty
              ? t.bulkImportTranslating
              : t.bulkImportConfirmAdd(addCount),
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
    );
  }
}

class _PreviewResult {
  final List<String> matched;  // in vocab CSV, not yet in collection
  final List<String> custom;   // not in vocab CSV — will be auto-translated
  final List<String> already;  // already in target collection
  const _PreviewResult({
    required this.matched,
    required this.custom,
    required this.already,
  });

  /// All words that the commit step will need to write.
  List<String> get toAdd => [...matched, ...custom];
}
