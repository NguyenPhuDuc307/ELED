import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback, SystemSound, SystemSoundType;
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/gen/app_localizations.dart';
import '../models/vocabulary.dart';
import '../models/word_state.dart';
import '../services/learning_state_service.dart';
import '../services/oxford_service.dart';
import '../services/srs_service.dart';
import '../services/translation_service.dart';
import '../services/user_data_service.dart';
import 'exercises/anagram_exercise.dart';
import 'exercises/fill_in_context_exercise.dart';
import 'exercises/listen_and_type_exercise.dart';
import 'exercises/multiple_choice_exercise.dart';
import 'exercises/reverse_typing_exercise.dart';
import 'session_results_screen.dart';
import '../theme/brutalist_theme.dart';
import '../utils/log.dart';
import '../widgets/brutalist_card.dart';

class LearningScreen extends StatefulWidget {
  final int day;
  final List<Vocabulary> vocabularies;
  final int initialIndex;
  final VoidCallback? onCompleted;
  /// When true, every card runs a quiz-style exercise (MC / Listen /
  /// Fill-in / Anagram / ReverseTyping). The Recognize flashcard is
  /// skipped — used by the standalone Quiz CTA on Today.
  final bool quizMode;
  /// Restricts which exercise types the quiz rotation may pick. Ignored when
  /// [quizMode] is false. Null falls back to the full six-style rotation.
  final Set<ExerciseType>? quizTypes;

  const LearningScreen({
    super.key,
    required this.day,
    required this.vocabularies,
    this.initialIndex = 0,
    this.onCompleted,
    this.quizMode = false,
    this.quizTypes,
  });

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  late final PageController _pageController;
  late int _currentIndex;
  Set<String> _knownWords = {};

  // false = show English definition (default), true = show Vietnamese translation of definition
  bool _translateDefinition = false;

  // Oxford definitions per page index
  final Map<int, List<OxfordSense>> _oxfordCache = {};
  bool _loadingDef = false;

  // Translated VI definitions per page index (list of translated strings, one per sense)
  final Map<int, List<String>> _translatedDefsCache = {};
  bool _translatingDef = false;

  final _audioPlayer = AudioPlayer();
  bool _playingAudio = false;

  // Backup timer that explicitly hides the active snackbar after a window —
  // works around a Flutter quirk we've seen on some Android builds where a
  // SnackBar with a SnackBarAction doesn't honour its `duration`.
  Timer? _snackTimer;

  // Pinned exercise + distractor pick per card so PageView rebuilds don't
  // swap exercise types mid-card.
  final Map<int, ExerciseType> _exerciseCache = {};
  final Map<int, List<Vocabulary>> _distractorsCache = {};

  // Ratings the user submitted during this session, in card order. Handed
  // off to the results screen on completion.
  final List<ReviewRating> _sessionRatings = [];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _loadKnownWords();
    _prepareCard(_currentIndex);
    _persistContext();
  }

  /// Persists "where the user left off" so the menu's Continue tile can
  /// jump back into this session. Called on first build + every page change.
  void _persistContext() {
    if (widget.vocabularies.isEmpty) return;
    LearningStateService().saveContext(LearningContext(
      day: widget.day,
      wordKeys: widget.vocabularies.map((v) => v.word.toLowerCase()).toList(),
      currentIndex: _currentIndex,
      totalCount: widget.vocabularies.length,
      lastOpenedMs: DateTime.now().millisecondsSinceEpoch,
    ));
  }

  Future<void> _loadKnownWords() async {
    setState(() {
      _knownWords = UserDataService().knownWords;
    });
  }

  /// Fetches the English definition for the card at [index]; if the user is
  /// currently viewing Vietnamese, chains a translation so the new card
  /// arrives already translated instead of forcing them to toggle EN → VI.
  Future<void> _prepareCard(int index) async {
    await _fetchDefinition(index);
    if (_translateDefinition && mounted) {
      await _translateSenses(index);
    }
  }

  Future<void> _fetchDefinition(int index) async {
    if (_oxfordCache.containsKey(index)) return;
    if (!mounted) return;
    final vocab = widget.vocabularies[index];
    setState(() => _loadingDef = true);
    final senses = await OxfordService.fetchDefinitions(vocab.word, vocab.url);
    if (!mounted) return;
    setState(() {
      _oxfordCache[index] = senses;
      _loadingDef = false;
    });
  }

  /// AppBar "I know this" toggle. Tapping on an unmarked word promotes it
  /// to mastered + advances; tapping again on a marked word removes it from
  /// the known list (without re-resetting the SRS schedule — the next
  /// rating will adjust naturally).
  Future<void> _markKnownAndAdvance(Vocabulary vocab) async {
    final lower = vocab.word.toLowerCase();
    if (_knownWords.contains(lower)) {
      await UserDataService().removeKnownWord(vocab.word);
      if (!mounted) return;
      setState(() {
        _knownWords = UserDataService().knownWords;
      });
      _showFeedback(AppLocalizations.of(context).learningRemovedFromKnown);
      return;
    }
    await _applyMastered(vocab, advance: true);
  }

  /// Floating, 2-second snackbar without an action — used when we just need
  /// to confirm a tap landed and don't want it lingering across page swipes.
  void _showFeedback(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
    ));
    _armSnackTimer(messenger, const Duration(seconds: 2));
  }

  /// Quiz / auto-rated card feedback: "Chính xác" or "Chưa đúng" with a
  /// matching haptic + system click so the answer feels acknowledged
  /// without the user having to read the snackbar.
  void _flashAutoRatedFeedback({required bool correct}) {
    final t = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final color = correct
        ? BrutalistTheme.primary
        : const Color(0xFFD9534F);
    final icon = correct
        ? Icons.check_circle_rounded
        : Icons.cancel_rounded;
    final label = correct ? t.exerciseCorrect : t.exerciseIncorrect;

    // Tactile + audible feedback. Haptic on incorrect is heavier so a
    // wrong answer feels like a small "thunk".
    if (correct) {
      HapticFeedback.lightImpact();
      SystemSound.play(SystemSoundType.click);
    } else {
      HapticFeedback.heavyImpact();
    }

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(
      content: Row(
        children: [
          Icon(icon, color: BrutalistTheme.white, size: 18),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                color: BrutalistTheme.white,
                fontWeight: FontWeight.w700,
              )),
        ],
      ),
      backgroundColor: color,
      duration: const Duration(milliseconds: 1400),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(60, 0, 60, 100),
    ));
    _armSnackTimer(messenger, const Duration(milliseconds: 1400));
  }

  /// Brief, color-coded acknowledgement after a rating tap. Shorter than
  /// the mark-known toast (1.4s) because the card is about to swipe and we
  /// don't want the toast bleeding into the next card.
  void _flashRatingFeedback(ReviewRating rating) {
    final t = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final (label, color, icon) = switch (rating) {
      ReviewRating.again => (
          t.learningAgain,
          const Color(0xFFD9534F),
          Icons.refresh_rounded,
        ),
      ReviewRating.hard => (
          t.learningHard,
          const Color(0xFFE5874E),
          Icons.trending_down_rounded,
        ),
      ReviewRating.good => (
          t.learningGood,
          BrutalistTheme.primary,
          Icons.check_rounded,
        ),
      ReviewRating.easy => (
          t.learningGood,
          BrutalistTheme.primary,
          Icons.check_rounded,
        ),
    };
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(
      content: Row(
        children: [
          Icon(icon, color: BrutalistTheme.white, size: 18),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                color: BrutalistTheme.white,
                fontWeight: FontWeight.w700,
              )),
        ],
      ),
      backgroundColor: color,
      duration: const Duration(milliseconds: 1400),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(80, 0, 80, 90),
    ));
    _armSnackTimer(messenger, const Duration(milliseconds: 1400));
  }

  /// Schedules a hard-dismiss of the current snackbar slightly after its
  /// nominal duration — belt-and-braces against the Android quirk where
  /// SnackBar duration is ignored when an action is attached.
  void _armSnackTimer(ScaffoldMessengerState messenger, Duration after) {
    _snackTimer?.cancel();
    _snackTimer = Timer(after + const Duration(milliseconds: 100), () {
      if (!mounted) return;
      messenger.hideCurrentSnackBar();
    });
  }

  /// Shared core for "skip / mark-as-known" flows so the AppBar action, the
  /// rating-row "I know" path, and the Recognize archive icon all behave the
  /// same. Optionally advances to the next card.
  Future<void> _applyMastered(Vocabulary vocab, {required bool advance}) async {
    final messenger = ScaffoldMessenger.of(context);
    final t = AppLocalizations.of(context);
    await SrsService().markMastered(vocab.word);
    await UserDataService().addKnownWord(vocab.word);
    _sessionRatings.add(ReviewRating.easy);
    if (!mounted) return;
    setState(() {
      _knownWords = UserDataService().knownWords;
    });
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(
      content: Text(t.learningMarkedKnown),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: t.commonUndo,
        onPressed: () async {
          await UserDataService().removeKnownWord(vocab.word);
          if (!mounted) return;
          setState(() {
            _knownWords = UserDataService().knownWords;
          });
        },
      ),
    ));
    _armSnackTimer(messenger, const Duration(seconds: 2));
    if (!advance || !mounted) return;
    if (_currentIndex < widget.vocabularies.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    } else {
      widget.onCompleted?.call();
      await Navigator.of(context).pushReplacement(smoothRoute(
        SessionResultsScreen(
          ratings: List.of(_sessionRatings),
          moreDue: SrsService().dueCount() > 0,
        ),
      ));
    }
  }

  Future<void> _playAudio(String url) async {
    if (url.isEmpty || _playingAudio) return;
    setState(() => _playingAudio = true);
    try {
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
    } catch (e, st) {
      logCaught(e, st, 'LearningScreen.playAudio');
    }
    if (mounted) setState(() => _playingAudio = false);
  }

  Future<void> _toggleTranslation(int index) async {
    final newVal = !_translateDefinition;
    setState(() => _translateDefinition = newVal);
    if (newVal) await _translateSenses(index);
  }

  Future<void> _translateSenses(int index) async {
    if (_translatedDefsCache.containsKey(index)) return;
    final senses = _oxfordCache[index];
    if (senses == null || senses.isEmpty) return;
    if (!mounted) return;
    setState(() => _translatingDef = true);
    final results = await Future.wait(
      senses.map((s) => TranslationService.toVi(s.definition)),
    );
    if (!mounted) return;
    setState(() {
      _translatedDefsCache[index] = results;
      _translatingDef = false;
    });
  }

  @override
  void dispose() {
    _snackTimer?.cancel();
    _pageController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.day == 0 ? t.learningSearchTitle : t.learningDayTitle(widget.day)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (widget.vocabularies.isNotEmpty)
            IconButton(
              tooltip: t.learningTooltipKnown,
              icon: Icon(
                _knownWords.contains(widget.vocabularies[_currentIndex].word.toLowerCase())
                    ? Icons.check_circle_rounded
                    : Icons.check_circle_outline_rounded,
              ),
              onPressed: () =>
                  _markKnownAndAdvance(widget.vocabularies[_currentIndex]),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildLocationIndicator(),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.vocabularies.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
                _prepareCard(index);
                _persistContext();
              },
              itemBuilder: (context, index) {
                final vocab = widget.vocabularies[index];
                final exType = _exerciseFor(index);
                if (exType == ExerciseType.multipleChoice) {
                  return MultipleChoiceExercise(
                    word: vocab,
                    distractors: _distractorsFor(index),
                    onAnswered: (rating) => _submitRating(rating),
                  );
                }
                if (exType == ExerciseType.listenAndType) {
                  return ListenAndTypeExercise(
                    word: vocab,
                    onAnswered: (rating) => _submitRating(rating),
                  );
                }
                if (exType == ExerciseType.fillInContext) {
                  return FillInContextExercise(
                    word: vocab,
                    onAnswered: (rating) => _submitRating(rating),
                  );
                }
                if (exType == ExerciseType.anagram) {
                  return AnagramExercise(
                    word: vocab,
                    onAnswered: (rating) => _submitRating(rating),
                  );
                }
                if (exType == ExerciseType.reverseTyping) {
                  return ReverseTypingExercise(
                    word: vocab,
                    onAnswered: (rating) => _submitRating(rating),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: BrutalistCard(
                    backgroundColor: levelColor(vocab.levels, fallbackIndex: index),
                    child: SingleChildScrollView(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              vocab.word,
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontSize: 50,
                                  height: 1.1,
                                  color: BrutalistTheme.black,
                                ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Text(
                                vocab.ipa,
                                style: GoogleFonts.notoSans(
                                  textStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        color: BrutalistTheme.black,
                                        fontStyle: FontStyle.italic,
                                      ),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (vocab.audioLink.isNotEmpty)
                                Material(
                                  color: BrutalistTheme.primaryLight,
                                  borderRadius: BorderRadius.circular(24),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(24),
                                    onTap: () => _playAudio(vocab.audioLink),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: _playingAudio
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: BrutalistTheme.primary,
                                              ),
                                            )
                                          : const Icon(Icons.volume_up_rounded, color: BrutalistTheme.primary, size: 22),
                                    ),
                                  ),
                                ),
                              if (vocab.url.isNotEmpty)
                                Material(
                                  color: BrutalistTheme.primaryLight,
                                  borderRadius: BorderRadius.circular(24),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(24),
                                    onTap: () async {
                                      final Uri url = Uri.parse(vocab.url);
                                      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                            content: Text(t.learningCouldntOpenLink),
                                            duration: const Duration(seconds: 3),
                                          ));
                                        }
                                      }
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Icon(Icons.open_in_new_rounded, color: BrutalistTheme.primary, size: 22),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          if (vocab.partOfSpeech.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            // Part of speech kept inline as a subtle caption — the
                            // most learning-relevant tag. Level + topic move to the
                            // info sheet so the card isn't a wall of metadata.
                            Text(
                              vocab.partOfSpeech.toLowerCase(),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: BrutalistTheme.black.withValues(alpha: 0.55),
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          const SizedBox(height: 28),
                          // Vietnamese word translation — always visible
                          Text(
                            vocab.translation,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: BrutalistTheme.black,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          // Definitions: English by default, Vietnamese when _translateDefinition=true
                          if (_loadingDef && !_oxfordCache.containsKey(index))
                            const _DefinitionSkeleton()
                          else if ((_oxfordCache[index] ?? []).isNotEmpty)
                            ...List.generate(_oxfordCache[index]!.length, (si) {
                              final s = _oxfordCache[index]![si];
                              final viDefs = _translatedDefsCache[index];
                              final showVI = _translateDefinition && viDefs != null;
                              final defText = showVI && si < viDefs.length
                                  ? viDefs[si]
                                  : s.definition;
                              final isLast = si == _oxfordCache[index]!.length - 1;
                              return Padding(
                                padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _translatingDef && _translateDefinition && viDefs == null
                                        ? const SizedBox(
                                            height: 18,
                                            width: 18,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: BrutalistTheme.primary),
                                          )
                                        : Text(
                                            defText,
                                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                  color: BrutalistTheme.black,
                                                  height: 1.45,
                                                ),
                                          ),
                                    if (s.example.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(
                                          '"${s.example}"',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                fontStyle: FontStyle.italic,
                                                color: BrutalistTheme.textMuted,
                                                height: 1.4,
                                              ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (widget.vocabularies.isNotEmpty &&
              _exerciseFor(_currentIndex) == ExerciseType.recognize) ...[
            _buildRatingRow(),
          ],
          if (widget.vocabularies.isNotEmpty &&
              _exerciseFor(_currentIndex) == ExerciseType.recognize)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: context.bBg,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onPressed: _currentIndex > 0
                      ? () => _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          )
                      : null,
                ),
                _buildDefinitionLanguageToggle(),
                _buildNavButton(
                  icon: _currentIndex < widget.vocabularies.length - 1
                      ? Icons.arrow_forward_ios_rounded
                      : Icons.skip_next_rounded,
                  onPressed: _currentIndex < widget.vocabularies.length - 1
                      ? () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          )
                      : widget.onCompleted,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  /// Replaces the old "X / Y" + "Z%" + linear progress bar. Up to 30 vocab
  /// items render as dots (current = solid primary, others = muted). Beyond
  /// 30 we fall back to a one-line muted caption so the dot row doesn't
  /// become an unreadable smudge.
  Widget _buildLocationIndicator() {
    final t = AppLocalizations.of(context);
    final total = widget.vocabularies.length;
    if (total == 0) return const SizedBox(height: 16);
    if (total > 30) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 6),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            t.learningWordOfTotal(_currentIndex + 1, total),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.bMuted,
                ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 6),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: List.generate(total, (i) {
          final isActive = i == _currentIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isActive ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive
                  ? BrutalistTheme.primary
                  : context.bSubtle,
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }

  /// Compact segmented control: "English" / "Tiếng Việt" with a one-line label
  /// above so the user can tell what it's switching. Replaces a bare iOS-style
  /// switch with an "EN"/"VI" code that was easy to misread.
  Widget _buildDefinitionLanguageToggle() {
    final t = AppLocalizations.of(context);
    Widget seg(String label, bool active, VoidCallback onTap) {
      return InkWell(
        onTap: active ? null : onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: active ? BrutalistTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: active ? BrutalistTheme.white : context.bMuted,
                ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          t.learningDefinition,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.bMuted,
                fontSize: 11,
                letterSpacing: 0.3,
              ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: context.bSubtle.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              seg(t.learningDefinitionEnglish, !_translateDefinition, () {
                if (_translateDefinition) _toggleTranslation(_currentIndex);
              }),
              seg(t.learningDefinitionVietnamese, _translateDefinition, () {
                if (!_translateDefinition) _toggleTranslation(_currentIndex);
              }),
            ],
          ),
        ),
      ],
    );
  }

  /// Decides which exercise widget to render for the card at [index]. Cached
  /// in [_exerciseCache] so the choice is stable across rebuilds — otherwise
  /// the SRS state could mutate mid-card and the page would re-render with a
  /// different exercise type.
  ExerciseType _exerciseFor(int index) {
    final cached = _exerciseCache[index];
    if (cached != null) return cached;
    final vocab = widget.vocabularies[index];
    var type = SrsService().pickExerciseType(
      vocab.word,
      hasAudio: vocab.audioLink.isNotEmpty,
      hasExample: vocab.url.isNotEmpty,
    );
    if (widget.quizMode) {
      // In quiz mode, constrain to the user-picked types if provided —
      // otherwise fall back to the full five-style rotation. Also catches
      // the case where SRS returned Recognize (fresh/mastered word), which
      // quiz mode never wants.
      const defaultRotation = [
        ExerciseType.multipleChoice,
        ExerciseType.anagram,
        ExerciseType.reverseTyping,
        ExerciseType.fillInContext,
        ExerciseType.listenAndType,
      ];
      final allowed = widget.quizTypes == null || widget.quizTypes!.isEmpty
          ? defaultRotation
          : defaultRotation.where(widget.quizTypes!.contains).toList();
      if (allowed.isNotEmpty &&
          (type == ExerciseType.recognize || !allowed.contains(type))) {
        var candidate =
            allowed[(index + vocab.word.length) % allowed.length];
        // Audio/length-aware fallbacks — drop a candidate that can't render
        // for this word and pick the next allowed type instead.
        if (candidate == ExerciseType.listenAndType &&
            vocab.audioLink.isEmpty) {
          candidate = _nextAllowed(allowed, candidate);
        }
        if (candidate == ExerciseType.anagram && vocab.word.length <= 2) {
          candidate = _nextAllowed(allowed, candidate);
        }
        type = candidate;
      }
    }
    _exerciseCache[index] = type;
    return type;
  }

  /// Picks the next type in [allowed] after [skip], wrapping around. Falls
  /// back to [skip] itself if it's the only option.
  ExerciseType _nextAllowed(List<ExerciseType> allowed, ExerciseType skip) {
    if (allowed.length == 1) return skip;
    final idx = allowed.indexOf(skip);
    return allowed[(idx + 1) % allowed.length];
  }

  /// Picks 3 distractor words from the rest of the session for the multiple
  /// choice exercise. Stable across rebuilds.
  List<Vocabulary> _distractorsFor(int index) {
    final cached = _distractorsCache[index];
    if (cached != null) return cached;
    final pool = <Vocabulary>[];
    final correct = widget.vocabularies[index].word.toLowerCase();
    for (final v in widget.vocabularies) {
      if (v.word.toLowerCase() != correct &&
          v.translation.trim().isNotEmpty) {
        pool.add(v);
      }
    }
    pool.shuffle();
    final picks = pool.take(3).toList();
    _distractorsCache[index] = picks;
    return picks;
  }

  /// Submits an SRS rating for the current word and advances to the next card.
  /// At the end of the deck we call onCompleted so the caller can chain into
  /// the next session (e.g. next Day).
  Future<void> _submitRating(ReviewRating rating) async {
    if (widget.vocabularies.isEmpty) return;
    final word = widget.vocabularies[_currentIndex].word;
    _sessionRatings.add(rating);
    // Quiz/auto-rated cards (anything that isn't a Recognize flashcard the
    // user manually graded) get a "Chính xác / Chưa đúng" toast + haptics
    // instead of the rating label — saying "Dễ" after the system auto-rates
    // is confusing because the user didn't choose that word.
    final exType = _exerciseFor(_currentIndex);
    final autoRated = exType != ExerciseType.recognize;
    if (autoRated) {
      _flashAutoRatedFeedback(correct: rating == ReviewRating.good);
    } else {
      _flashRatingFeedback(rating);
    }
    await SrsService().submitReview(word, rating);
    // Keep the legacy known-words store in sync so notifications + browse
    // modes still exclude what the user has already mastered.
    if (rating == ReviewRating.good || rating == ReviewRating.easy) {
      await UserDataService().addKnownWord(word);
    } else if (rating == ReviewRating.again) {
      await UserDataService().removeKnownWord(word);
    }
    if (!mounted) return;
    // Keep the AppBar Know icon in sync with the rating just applied —
    // otherwise the user has to leave + return to see it reflect.
    setState(() {
      _knownWords = UserDataService().knownWords;
    });
    if (_currentIndex < widget.vocabularies.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    } else {
      // Last card — push the results screen on top so the session closes with
      // a clear summary + streak signal instead of just popping silently.
      widget.onCompleted?.call();
      await Navigator.of(context).pushReplacement(smoothRoute(
        SessionResultsScreen(
          ratings: List.of(_sessionRatings),
          moreDue: SrsService().dueCount() > 0,
        ),
      ));
    }
  }

  /// Row of three rating chips above the nav bar. Each chip stacks an icon
  /// over its label so the abstract "Again / Hard / Good" wording has a
  /// visual anchor — easier to grok at a glance, especially on the smaller
  /// localised translations.
  Widget _buildRatingRow() {
    final t = AppLocalizations.of(context);
    Widget chip(
      String label,
      IconData icon,
      ReviewRating rating,
      Color color,
    ) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Material(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _submitRating(rating),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: color, size: 22),
                    const SizedBox(height: 3),
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: color,
                            fontSize: 12,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
      child: Row(
        children: [
          chip(t.learningAgain, Icons.refresh_rounded,
              ReviewRating.again, const Color(0xFFD9534F)),
          chip(t.learningHard, Icons.trending_down_rounded,
              ReviewRating.hard, const Color(0xFFE5874E)),
          chip(t.learningGood, Icons.check_rounded,
              ReviewRating.good, BrutalistTheme.primary),
        ],
      ),
    );
  }

  Widget _buildNavButton({required IconData icon, required VoidCallback? onPressed}) {
    final active = onPressed != null;
    return Material(
      color: active ? BrutalistTheme.primaryLight : BrutalistTheme.border.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Icon(icon, color: active ? BrutalistTheme.primary : BrutalistTheme.textMuted, size: 24),
        ),
      ),
    );
  }
}

/// Subtle pulsing placeholder for the Oxford definition while it's being
/// fetched. Three skeleton lines feel like an actual paragraph is loading,
/// so the user doesn't think the screen is broken.
class _DefinitionSkeleton extends StatefulWidget {
  const _DefinitionSkeleton();

  @override
  State<_DefinitionSkeleton> createState() => _DefinitionSkeletonState();
}

class _DefinitionSkeletonState extends State<_DefinitionSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.35, end: 0.8).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _bar(double width) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (_, _) => Opacity(
        opacity: _opacity.value,
        child: Container(
          height: 14,
          width: width,
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: BrutalistTheme.black.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _bar(width * 0.65),
        _bar(width * 0.55),
        _bar(width * 0.4),
      ],
    );
  }
}
