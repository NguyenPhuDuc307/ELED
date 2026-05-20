import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../l10n/gen/app_localizations.dart';
import '../models/vocabulary.dart';
import '../services/csv_service.dart';
import '../services/oxford_service.dart';
import '../services/translation_service.dart';
import '../theme/brutalist_theme.dart';
import '../utils/log.dart';

/// Bottom-sheet word lookup. Triggered from long-press inside the Speaking
/// practice text. Pulls the bundled CSV row for the word when available (IPA,
/// audio, Oxford URL), otherwise synthesises a minimal entry with a guessed
/// Oxford URL. Translation + Oxford definitions are fetched in parallel and
/// rendered as they come in so the user gets something on screen immediately.
class WordLookupSheet extends StatefulWidget {
  final String word;
  const WordLookupSheet({super.key, required this.word});

  @override
  State<WordLookupSheet> createState() => _WordLookupSheetState();
}

class _WordLookupSheetState extends State<WordLookupSheet> {
  Vocabulary? _vocab;
  bool _resolvingVocab = true;

  String? _translation;
  bool _translating = true;

  List<OxfordSense> _senses = const [];
  bool _fetchingDef = true;

  final _audio = AudioPlayer();
  bool _playingAudio = false;

  @override
  void initState() {
    super.initState();
    _resolveVocabThenFetch();
    _runTranslate();
  }

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  /// First tries the bundled CSV for an exact match (gives us IPA + audio).
  /// Falls back to a synthetic Vocabulary with a guessed Oxford URL so the
  /// Oxford fetch still has something to work with.
  Future<void> _resolveVocabThenFetch() async {
    Vocabulary? vocab;
    try {
      final all = await CsvService.loadAllVocabulary(excludeKnown: false);
      final matches =
          all.where((v) => v.word.trim().toLowerCase() == widget.word);
      if (matches.isNotEmpty) vocab = matches.first;
    } catch (e, st) {
      logCaught(e, st, 'WordLookupSheet.csv');
    }
    vocab ??= Vocabulary(
      id: 'lookup:${widget.word}',
      url:
          'https://www.oxfordlearnersdictionaries.com/definition/english/${widget.word}',
      levels: '',
      word: widget.word,
      translation: '',
      partOfSpeech: '',
      ipa: '',
      audioLink: '',
    );
    if (!mounted) return;
    setState(() {
      _vocab = vocab;
      _resolvingVocab = false;
    });
    await _runOxford(vocab);
  }

  Future<void> _runTranslate() async {
    try {
      final result = await TranslationService.toVi(widget.word);
      if (!mounted) return;
      setState(() {
        _translation = result.trim();
        _translating = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _translating = false);
    }
  }

  Future<void> _runOxford(Vocabulary vocab) async {
    try {
      final senses =
          await OxfordService.fetchDefinitions(vocab.word, vocab.url);
      if (!mounted) return;
      setState(() {
        _senses = senses;
        _fetchingDef = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _fetchingDef = false);
    }
  }

  Future<void> _playAudio(String url) async {
    if (url.isEmpty || _playingAudio) return;
    setState(() => _playingAudio = true);
    try {
      await _audio.setUrl(url);
      await _audio.play();
    } catch (e, st) {
      logCaught(e, st, 'WordLookupSheet.audio');
    }
    if (mounted) setState(() => _playingAudio = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final vocab = _vocab;
    final hasTranslation = !_translating &&
        _translation != null &&
        _translation!.isNotEmpty &&
        _translation!.toLowerCase() != widget.word.toLowerCase();
    final hasDefinitions = !_fetchingDef && _senses.isNotEmpty;
    final allLoaded = !_translating && !_fetchingDef && !_resolvingVocab;
    final showNoData = allLoaded && !hasTranslation && !hasDefinitions;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollCtrl) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 6),
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.bMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _headerBlock(context, vocab),
                      const SizedBox(height: 18),
                      _translationBlock(context, hasTranslation, t),
                      const SizedBox(height: 20),
                      _definitionsBlock(context, hasDefinitions, t),
                      if (showNoData)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            t.speakingLookupError,
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: context.bMuted,
                                    ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _headerBlock(BuildContext context, Vocabulary? vocab) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.word,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 34,
                color: BrutalistTheme.black,
                fontWeight: FontWeight.w700,
                height: 1.05,
              ),
        ),
        const SizedBox(height: 6),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          runSpacing: 6,
          children: [
            if (vocab != null && vocab.ipa.isNotEmpty)
              Text(
                vocab.ipa,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: context.bMuted,
                      fontSize: 16,
                    ),
              ),
            if (vocab != null && vocab.partOfSpeech.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: BrutalistTheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  vocab.partOfSpeech.toLowerCase(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: BrutalistTheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                ),
              ),
            if (vocab != null && vocab.audioLink.isNotEmpty)
              Material(
                color: BrutalistTheme.primaryLight,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _playAudio(vocab.audioLink),
                  child: Padding(
                    padding: const EdgeInsets.all(7),
                    child: _playingAudio
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: BrutalistTheme.primary,
                            ),
                          )
                        : const Icon(Icons.volume_up_rounded,
                            color: BrutalistTheme.primary, size: 18),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _translationBlock(
      BuildContext context, bool hasTranslation, AppLocalizations t) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: BrutalistTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: BrutalistTheme.primary.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.speakingLookupTranslation,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: BrutalistTheme.primary.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
          ),
          const SizedBox(height: 6),
          if (_translating)
            const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: BrutalistTheme.primary),
            )
          else if (hasTranslation)
            Text(
              _translation!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: BrutalistTheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 19,
                    height: 1.35,
                  ),
            )
          else
            Text(
              '—',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: context.bMuted,
                  ),
            ),
        ],
      ),
    );
  }

  Widget _definitionsBlock(
      BuildContext context, bool hasDefinitions, AppLocalizations t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.speakingLookupDefinition,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.bMuted,
                fontWeight: FontWeight.w700,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
        ),
        const SizedBox(height: 8),
        if (_fetchingDef)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (hasDefinitions)
          ...List.generate(_senses.length, (i) {
            final s = _senses[i];
            final isLast = i == _senses.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 22,
                    child: Text(
                      '${i + 1}.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: context.bMuted,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.definition,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: BrutalistTheme.black,
                                    height: 1.45,
                                  ),
                        ),
                        if (s.example.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            '"${s.example}"',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: context.bMuted,
                                  height: 1.4,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          })
        else
          Text(
            t.speakingLookupNoDefinition,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.bMuted,
                ),
          ),
      ],
    );
  }
}
