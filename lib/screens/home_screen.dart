import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/gen/app_localizations.dart';
import '../models/vocabulary.dart';
import '../models/word_state.dart';
import '../services/auth_service.dart';
import '../services/csv_service.dart';
import '../services/collection_service.dart';
import '../services/custom_word_service.dart';
import '../services/srs_service.dart';
import '../services/user_data_service.dart';
import '../theme/brutalist_theme.dart';
import '../utils/log.dart';
import '../widgets/brutalist_card.dart';
import 'match_game_screen.dart';
import 'speed_match_screen.dart';
import 'learning_screen.dart';

class HomeScreen extends StatefulWidget {
  final String mode; // 'POPULARITY', 'TOPIC', or 'SEARCH'
  final String? topicPath;
  final String? topicTitle;
  final bool initSearch;
  final List<String>? topicLevelsFilter;
  final Function(Vocabulary)? onWordSelected;
  final VoidCallback? onCompleted;

  const HomeScreen({
    super.key,
    this.mode = 'POPULARITY',
    this.topicPath,
    this.topicTitle,
    this.initSearch = false,
    this.topicLevelsFilter,
    this.onWordSelected,
    this.onCompleted,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<int, List<Vocabulary>> _vocabData = {};
  List<Vocabulary> _allVocabData = [];
  bool _isLoading = true;
  List<String> _selectedLevels = ['A1'];
  final List<String> _levels = ['A1', 'A2', 'B1', 'B2', 'C1'];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  /// Active part-of-speech filter. Empty = no filter (show all). When non-
  /// empty, only words whose POS column contains *any* of the selected
  /// tokens are surfaced.
  final Set<String> _selectedPos = {};
  Timer? _debounceTimer;

  final _audioPlayer = AudioPlayer();
  String _playingUrl = '';

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio(String url) async {
    if (url.isEmpty || _playingUrl == url) return;
    setState(() => _playingUrl = url);
    try {
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
    } catch (e, st) {
      logCaught(e, st, 'HomeScreen.playAudio');
    }
    if (mounted) setState(() => _playingUrl = '');
  }

  @override
  void initState() {
    super.initState();
    if (widget.initSearch || widget.mode == 'SEARCH') {
      _isSearching = true;
      _isLoading = true;
      _loadAllData().then((_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    } else if (widget.mode == 'TOPIC' && widget.topicPath != null) {
      _loadDataFromPath(widget.topicPath!);
      _loadAllData();
    } else if (widget.mode == 'KNOWN') {
      _loadKnownWordsData();
    } else if (widget.mode == 'HISTORY') {
      _loadHistoryWordsData();
    } else if (widget.mode == 'COLLECTION') {
      _loadCollectionData();
    } else {
      _loadLevelsFromPrefs();
      _loadAllData();
    }
  }

  Future<void> _loadLevelsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('selectedPopularity') ?? [];
    final levels = saved.isNotEmpty ? saved : ['A1'];
    if (mounted) setState(() => _selectedLevels = levels);
    _loadDataForLevels(levels);
  }

  Future<void> _loadDataForLevels(List<String> levels) async {
    setState(() => _isLoading = true);
    if (levels.isEmpty) {
      if (mounted) setState(() { _vocabData = {}; _isLoading = false; });
      return;
    }
    const levelOrder = ['A1', 'A2', 'B1', 'B2', 'C1'];
    final sorted = levelOrder.where((l) => levels.contains(l)).toList();
    final allVocab = await CsvService.loadSpecificPopularityVocabulary(sorted, excludeKnown: true);

    // The CSV is alphabetised, so each 20-word slice would otherwise be
    // thematically random *and* A-Z within the slice ("ability, able, about,
    // …"). Shuffle once with a deterministic seed per level combo so the
    // groupings feel mixed but stay stable across re-opens.
    final shuffled = [...allVocab];
    final seed = sorted.join(',').codeUnits.fold<int>(7919, (a, b) => a * 31 + b);
    shuffled.shuffle(Random(seed));

    final Map<int, List<Vocabulary>> grouped = {};
    int day = 1;
    for (var i = 0; i < shuffled.length; i++) {
      if (i > 0 && i % 20 == 0) day++;
      grouped.putIfAbsent(day, () => []).add(shuffled[i]);
    }
    grouped.removeWhere((_, v) => v.isEmpty);
    if (mounted) setState(() { _vocabData = grouped; _isLoading = false; });
  }

  Future<void> _loadKnownWordsData() async {
    setState(() => _isLoading = true);
    final allData = await CsvService.loadAllVocabulary();
    final knownWords = UserDataService().knownWords;
    if (mounted) {
      setState(() {
        final uniqueVocab = <String, Vocabulary>{};
        for (var v in allData) {
          if (knownWords.contains(v.word.toLowerCase())) {
            uniqueVocab.putIfAbsent(v.word, () => v);
          }
        }
        _allVocabData = uniqueVocab.values.toList();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadHistoryWordsData() async {
    setState(() {
      _isLoading = true;
    });
    final allData = await CsvService.loadAllVocabulary();
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // Force read from disk bypassing Isolate cache
    final historyWords = (prefs.getStringList('notificationHistory') ?? []);

    if (mounted) {
      setState(() {
        List<Vocabulary> orderedHistory = [];
        for (var item in historyWords) {
          final parts = item.split('|');
          final word = parts[0];
          final topic = parts.length > 1 ? parts[1] : '';

          final match = allData.where((v) => v.word == word);
          if (match.isNotEmpty) {
            final exactMatch = match.where((v) => v.topic == topic);
            orderedHistory.add(exactMatch.isNotEmpty ? exactMatch.first : match.first);
          }
        }
        _allVocabData = orderedHistory;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDataFromPath(String path) async {
    setState(() {
      _isLoading = true;
    });
    final data = await CsvService.loadVocabularyByDayFromPath(
      path, 
      excludeKnown: true,
      levelFilter: widget.mode == 'TOPIC' ? widget.topicLevelsFilter : null,
    );
    if (mounted) {
      setState(() {
        _vocabData = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCollectionData() async {
    setState(() {
      _isLoading = true;
    });
    final allData = await CsvService.loadAllVocabulary();
    final collections = await CollectionService.getCollections();
    final collectionWords = collections[widget.topicTitle!] ?? [];
    final byKey = <String, Vocabulary>{
      for (final v in allData) v.word.toLowerCase(): v,
    };
    final custom = CustomWordService();

    // Any word that's missing translation goes through Google now so the
    // list renders with meanings instead of empty rows. Cheap on re-open
    // since CustomWordService caches results.
    final needsTranslation = <String>[
      for (final w in collectionWords)
        if (!byKey.containsKey(w) && !custom.has(w)) w,
    ];
    if (needsTranslation.isNotEmpty) {
      await custom.translateAndStore(needsTranslation);
    }

    if (mounted) {
      setState(() {
        final list = <Vocabulary>[];
        for (final w in collectionWords) {
          final hit = byKey[w];
          list.add(hit ?? custom.syntheticVocabulary(w));
        }
        _allVocabData = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAllData() async {
    final bool shouldExclude = widget.mode == 'TOPIC' || widget.mode == 'POPULARITY';
    final allData = await CsvService.loadAllVocabulary(excludeKnown: shouldExclude);
    if (mounted) {
      setState(() {
        _allVocabData = allData;
      });
    }
  }


  String _screenTitle(AppLocalizations t) {
    switch (widget.mode) {
      case 'KNOWN':
        return t.homeTitleKnown;
      case 'HISTORY':
        return t.homeTitleHistory;
      case 'COLLECTION':
        return widget.topicTitle ?? t.homeTitleCollection;
      case 'TOPIC':
        return widget.topicTitle ?? t.homeTitleTopic;
      case 'SEARCH':
        return t.homeTitleSearch;
      default:
        return t.homeTitlePopularity;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (value) {
                  _debounceTimer?.cancel();
                  _debounceTimer = Timer(const Duration(milliseconds: 300), () {
                    if (mounted) setState(() => _searchQuery = value);
                  });
                },
                decoration: InputDecoration(
                  hintText: t.homeSearchFieldHint,
                  hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: context.bMuted,
                      ),
                  border: InputBorder.none,
                ),
                style: Theme.of(context).textTheme.bodyLarge,
              )
            : Text(_screenTitle(t)),
        actions: [
          if (widget.mode == 'HISTORY')
            IconButton(
              icon: Icon(Icons.delete_rounded, color: BrutalistTheme.secondary),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: context.bBg,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: Text(
                      t.homeClearHistoryTitle,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    content: Text(
                      t.homeClearHistoryBody,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: context.bMuted,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text(
                          t.commonCancel,
                          style: TextStyle(color: context.bMuted, fontWeight: FontWeight.w600),
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: BrutalistTheme.secondary,
                          foregroundColor: BrutalistTheme.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                          final messenger = ScaffoldMessenger.of(context);
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove('notificationHistory');
                          // Also clear from Firestore if signed in
                          final uid = AuthService().currentUser?.uid;
                          if (uid != null) {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .set({'notificationHistory': []}, SetOptions(merge: true));
                          }
                          setState(() => _allVocabData.clear());
                          if (mounted) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(t.homeHistoryCleared),
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        },
                        child: Text(t.commonDelete, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                );
              },
            ),

          if (widget.mode == 'COLLECTION')
            IconButton(
              icon: const Icon(Icons.add_rounded),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (searchContext) => HomeScreen(
                      mode: 'SEARCH',
                      onWordSelected: (vocab) async {
                        final messenger = ScaffoldMessenger.of(searchContext);
                        final navigator = Navigator.of(searchContext);
                        final added = await CollectionService.addWord(widget.topicTitle!, vocab.word);
                        if (added && mounted) {
                          messenger.showSnackBar(SnackBar(
                            content: Text(t.homeWordAddedToCollection),
                            duration: const Duration(seconds: 3),
                          ));
                          _loadCollectionData();
                        }
                        if (mounted) navigator.pop(); // pop search screen
                      },
                    ),
                  ),
                );
              },
            ),

          if (widget.mode != 'KNOWN' && widget.mode != 'HISTORY' && widget.mode != 'COLLECTION')
            IconButton(
              icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded),
            onPressed: () {
              if (widget.mode == 'SEARCH' && _isSearching) {
                Navigator.of(context).pop();
                return;
              }
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                } else {
                  _isSearching = true;
                  if (widget.mode == 'POPULARITY' && _allVocabData.isEmpty) {
                    _loadAllData();
                  }
                }
              });
            },
          )
        ],
      ),
      body: Column(
        children: [
          if (!_isSearching && widget.mode == 'POPULARITY') _buildLevelSelector(),
          if (!_isSearching && !_isLoading && _supportsPosFilter())
            _buildPosFilter(_posFilterPool()),
          Expanded(
            child: _isLoading
                ? _SkeletonLoader(
                    isDayList: widget.mode == 'POPULARITY' || widget.mode == 'TOPIC',
                  )
                : (widget.mode == 'KNOWN' || widget.mode == 'HISTORY' || widget.mode == 'COLLECTION')
                    ? _buildFlatList(_filteredFlatList(_allVocabData))
                    : _vocabData.isEmpty && _allVocabData.isEmpty
                        ? _buildEmptyState()
                        : (_isSearching && _searchQuery.isEmpty && widget.mode == 'SEARCH')
                            ? _buildSearchPromptState()
                            : (_isSearching && _searchQuery.isNotEmpty)
                                ? _buildSearchResults()
                                : _buildList(),
          ),
        ],
      ),
    );
  }

  bool _supportsPosFilter() {
    return widget.mode == 'POPULARITY' ||
        widget.mode == 'TOPIC' ||
        widget.mode == 'COLLECTION' ||
        widget.mode == 'KNOWN';
  }

  /// Pool of vocab used to compute the chip row. For grouped modes we
  /// flatten every Day's words; for flat modes we just hand back the list.
  List<Vocabulary> _posFilterPool() {
    if (widget.mode == 'POPULARITY' || widget.mode == 'TOPIC') {
      return [for (final list in _vocabData.values) ...list];
    }
    return _allVocabData;
  }

  List<Vocabulary> _filteredFlatList(List<Vocabulary> source) {
    if (_selectedPos.isEmpty) return source;
    return source.where(_matchesPosFilter).toList();
  }

  Widget _buildSearchPromptState() {
    final t = AppLocalizations.of(context);
    return _emptyState(
      icon: Icons.search_rounded,
      title: t.homeSearchPromptTitle,
      subtitle: t.homeSearchPromptSubtitle,
    );
  }

  /// 44x44 hit target so audio is comfortable to tap on a moving card.
  /// Shows a tiny spinner while the URL is being prepared.
  Widget _audioButton(String url) {
    final isPlaying = _playingUrl == url;
    return SizedBox(
      width: 44,
      height: 44,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _playAudio(url),
          child: Center(
            child: isPlaying
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: BrutalistTheme.primary,
                    ),
                  )
                : Icon(
                    Icons.volume_up_rounded,
                    size: 22,
                    color: BrutalistTheme.primary.withValues(alpha: 0.85),
                  ),
          ),
        ),
      ),
    );
  }

  // ── POS filter helpers ──────────────────────────────────────────────────

  /// Splits a CSV-style POS field ("noun, verb") into canonical lowercase
  /// tokens. Returns an empty list when the field has no recognised value.
  List<String> _splitPos(String raw) {
    if (raw.isEmpty) return const [];
    return raw
        .split(RegExp(r'[,/;]'))
        .map((s) => s.trim().toLowerCase())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// Maps a raw POS token to a localized display label. Falls back to the
  /// raw token (Title Case) so unmapped tokens still surface readably.
  String _posLabel(String token, AppLocalizations t) {
    switch (token) {
      case 'noun':
      case 'n.':
        return t.posNoun;
      case 'verb':
      case 'v.':
        return t.posVerb;
      case 'adjective':
      case 'adj.':
      case 'adj':
        return t.posAdjective;
      case 'adverb':
      case 'adv.':
      case 'adv':
        return t.posAdverb;
      case 'preposition':
      case 'prep.':
      case 'prep':
        return t.posPreposition;
      case 'conjunction':
      case 'conj.':
      case 'conj':
        return t.posConjunction;
      case 'pronoun':
      case 'pron.':
      case 'pron':
        return t.posPronoun;
      case 'determiner':
      case 'det.':
      case 'det':
        return t.posDeterminer;
      case 'exclamation':
      case 'excl.':
      case 'exclam':
        return t.posExclamation;
      case 'modal verb':
      case 'modal':
        return t.posModal;
      case 'number':
      case 'num.':
        return t.posNumber;
      case 'article':
        return t.posArticle;
      default:
        return token.isEmpty
            ? token
            : token[0].toUpperCase() + token.substring(1);
    }
  }

  /// Collects the unique canonical POS tokens present in [pool], sorted so
  /// the chip row is stable across rebuilds.
  List<String> _availablePos(List<Vocabulary> pool) {
    final set = <String>{};
    for (final v in pool) {
      set.addAll(_splitPos(v.partOfSpeech));
    }
    final list = set.toList()..sort();
    return list;
  }

  /// True when [vocab] passes the active POS filter — i.e. any of the
  /// vocab's POS tokens is in [_selectedPos]. Empty filter ⇒ everything
  /// passes.
  bool _matchesPosFilter(Vocabulary vocab) {
    if (_selectedPos.isEmpty) return true;
    final tokens = _splitPos(vocab.partOfSpeech);
    for (final tok in tokens) {
      if (_selectedPos.contains(tok)) return true;
    }
    return false;
  }

  /// Horizontal chip row above the list. Tap to toggle each POS token in
  /// the active filter. Hidden when the source pool has only one (or zero)
  /// POS values — a chip row of one is just noise.
  Widget _buildPosFilter(List<Vocabulary> pool) {
    final t = AppLocalizations.of(context);
    final pos = _availablePos(pool);
    if (pos.length < 2) return const SizedBox.shrink();
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        children: [
          _posChip(
            label: t.posFilterAll,
            selected: _selectedPos.isEmpty,
            onTap: () => setState(_selectedPos.clear),
          ),
          const SizedBox(width: 8),
          for (final token in pos) ...[
            _posChip(
              label: _posLabel(token, t),
              selected: _selectedPos.contains(token),
              onTap: () => setState(() {
                if (!_selectedPos.add(token)) _selectedPos.remove(token);
              }),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _posChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected
                ? BrutalistTheme.primary
                : context.bBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? BrutalistTheme.primary : context.bSubtle,
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: selected
                      ? BrutalistTheme.white
                      : context.bBorder,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
          ),
        ),
      ),
    );
  }

  /// Today-style hub injected at the top of a Collection list. Lets the
  /// user start a learning session or fire up a mini-game on the collection
  /// the same way Today does for the daily queue.
  Widget _collectionHub(List<Vocabulary> pool) {
    final t = AppLocalizations.of(context);
    // Eligibility for the games — match the Today screen's gating so the
    // pool is restricted to words the user hasn't fully mastered yet.
    final srs = SrsService();
    final gamePool = pool.where((v) {
      final stage = srs.stateFor(v.word).stage;
      return stage == SrsStage.fresh || stage == SrsStage.learning;
    }).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _collectionSessionCard(t, pool),
          if (gamePool.length >= 4) ...[
            const SizedBox(height: 8),
            _collectionQuizCta(t, gamePool),
          ],
          if (gamePool.length >= 4) ...[
            const SizedBox(height: 8),
            _collectionMatchCta(t, gamePool),
          ],
          if (gamePool.length >= 6) ...[
            const SizedBox(height: 8),
            _collectionSpeedCta(t, gamePool),
          ],
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _collectionSessionCard(AppLocalizations t, List<Vocabulary> pool) {
    // Each session is capped at a comfortable mini-pile so the user sees a
    // clear finish line even when the collection has hundreds of words.
    const sessionSize = 10;
    final total = pool.length;
    final round = pool.length > sessionSize
        ? (List.of(pool)..shuffle()).take(sessionSize).toList()
        : pool;
    final label = total == 1
        ? t.todaySessionCountSingular(total)
        : t.todaySessionCountPlural(total);
    return BrutalistCard(
      backgroundColor: BrutalistTheme.primary,
      onTap: () => Navigator.of(context).push(smoothRoute(LearningScreen(
        day: 0,
        vocabularies: round,
      ))),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: BrutalistTheme.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.bolt_rounded,
                  color: BrutalistTheme.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.todaySessionLabel,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: BrutalistTheme.white.withValues(alpha: 0.85),
                            fontSize: 12,
                            letterSpacing: 0.3,
                          )),
                  const SizedBox(height: 2),
                  Text(label,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: BrutalistTheme.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          )),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: BrutalistTheme.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.play_arrow_rounded,
                      color: BrutalistTheme.primary, size: 20),
                  const SizedBox(width: 4),
                  Text(t.todayStartSession,
                      style: const TextStyle(
                        color: BrutalistTheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _collectionQuizCta(AppLocalizations t, List<Vocabulary> pool) {
    const titleColor = Color(0xFF5A3A18);
    return BrutalistCard(
      backgroundColor: const Color(0xFFF5E4CC),
      onTap: () {
        // Mini-quiz round capped so the user gets a clear finish line even
        // when the collection has many words.
        const quizSize = 10;
        final round = (List.of(pool)..shuffle()).take(quizSize).toList();
        Navigator.of(context).push(smoothRoute(LearningScreen(
          day: 0,
          vocabularies: round,
          quizMode: true,
        )));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: titleColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.quiz_rounded,
                  color: titleColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.todayQuizTitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                          fontSize: 15)),
                  Text(t.todayQuizSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: titleColor.withValues(alpha: 0.75),
                          fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: titleColor.withValues(alpha: 0.7)),
          ],
        ),
      ),
    );
  }

  Widget _collectionMatchCta(AppLocalizations t, List<Vocabulary> pool) {
    return BrutalistCard(
      backgroundColor: BrutalistTheme.accentLight,
      onTap: () => Navigator.of(context).push(
        smoothRoute(MatchGameScreen(pool: pool)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: BrutalistTheme.accent.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.extension_rounded,
                  color: BrutalistTheme.accent, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.todayMatchGameTitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: BrutalistTheme.accent,
                          fontSize: 15)),
                  Text(t.todayMatchGameSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color:
                              BrutalistTheme.accent.withValues(alpha: 0.75),
                          fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: BrutalistTheme.accent.withValues(alpha: 0.7)),
          ],
        ),
      ),
    );
  }

  Widget _collectionSpeedCta(AppLocalizations t, List<Vocabulary> pool) {
    return BrutalistCard(
      backgroundColor: BrutalistTheme.primaryLight,
      onTap: () => Navigator.of(context).push(
        smoothRoute(SpeedMatchScreen(pool: pool)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: BrutalistTheme.primary.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.timer_rounded,
                  color: BrutalistTheme.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.speedMatchTitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: BrutalistTheme.primary,
                          fontSize: 15)),
                  Text(t.speedMatchSubtitle(SpeedMatchScreen.gameSeconds),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color:
                              BrutalistTheme.primary.withValues(alpha: 0.75),
                          fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: BrutalistTheme.primary.withValues(alpha: 0.7)),
          ],
        ),
      ),
    );
  }

  /// Brutalist-themed swipe-to-delete background — soft brick red with
  /// rounded corners matching the surrounding card. Replaces the harsh
  /// Material default red that clashed with the cream/pink palette.
  Widget _dismissBackground() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 2, 4, 10),
      child: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 28),
        decoration: BoxDecoration(
          color: const Color(0xFFD9534F),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.delete_outline_rounded,
              color: BrutalistTheme.white,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).commonDelete,
              style: const TextStyle(
                color: BrutalistTheme.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Centred empty/zero state with a soft icon, sentence-case title, and an
  /// optional subtitle that explains the next action the user can take.
  Widget _customBadge(AppLocalizations t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: BrutalistTheme.black.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        t.bulkImportCustomBadge.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: BrutalistTheme.black.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: BrutalistTheme.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: BrutalistTheme.primary),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: context.bBorder,
                  ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.bMuted,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 20),
              action,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLevelSelector() {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: context.bBg,
        border: Border(bottom: BorderSide(color: context.bSubtle, width: 1)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: _levels.length,
        itemBuilder: (context, index) {
          final level = _levels[index];
          final isSelected = _selectedLevels.contains(level);
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                final updated = List<String>.from(_selectedLevels);
                if (isSelected) {
                  if (updated.length == 1) return;
                  updated.remove(level);
                } else {
                  updated.add(level);
                }
                setState(() => _selectedLevels = updated);
                _loadDataForLevels(updated);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 64,
                decoration: BoxDecoration(
                  color: isSelected ? BrutalistTheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? BrutalistTheme.primary : context.bSubtle,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  level,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isSelected ? BrutalistTheme.white : context.bMuted,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final t = AppLocalizations.of(context);
    return _emptyState(
      icon: Icons.menu_book_rounded,
      title: t.homeNoWordsTitle,
      subtitle: widget.mode == 'POPULARITY'
          ? t.homeNoWordsPopularitySubtitle
          : t.homeNoWordsGenericSubtitle,
    );
  }

  Widget _buildFlatList(List<Vocabulary> results) {
    final t = AppLocalizations.of(context);
    if (results.isEmpty) {
      if (widget.mode == 'COLLECTION') {
        return _emptyState(
          icon: Icons.bookmark_add_outlined,
          title: t.homeEmptyCollectionTitle,
          subtitle: t.homeEmptyCollectionSubtitle,
        );
      }
      if (widget.mode == 'HISTORY') {
        return _emptyState(
          icon: Icons.history_rounded,
          title: t.homeEmptyHistoryTitle,
          subtitle: t.homeEmptyHistorySubtitle,
        );
      }
      return _emptyState(
        icon: Icons.check_circle_outline_rounded,
        title: t.homeEmptyKnownTitle,
        subtitle: t.homeEmptyKnownSubtitle,
      );
    }

    final showCollectionHub = widget.mode == 'COLLECTION';
    final headerCount = showCollectionHub ? 1 : 0;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: results.length + headerCount,
      itemBuilder: (context, rawIndex) {
        if (showCollectionHub && rawIndex == 0) {
          return _collectionHub(results);
        }
        final index = rawIndex - headerCount;
        final vocab = results[index];

        Widget card = BrutalistCard(
          backgroundColor: levelColor(vocab.levels, fallbackIndex: index),
          onTap: () {
            if (widget.onWordSelected != null) {
              widget.onWordSelected!(vocab);
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => LearningScreen(
                    day: 0,
                    vocabularies: results,
                    initialIndex: index,
                  ),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Flexible(
                            child: Text(
                              vocab.word,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: BrutalistTheme.black,
                                    fontSize: 18,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (vocab.id.startsWith('custom:')) ...[
                            const SizedBox(width: 8),
                            _customBadge(t),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        vocab.translation,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: BrutalistTheme.black.withValues(alpha: 0.55),
                              fontSize: 13,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (vocab.audioLink.isNotEmpty) _audioButton(vocab.audioLink),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 22,
                        color: BrutalistTheme.black.withValues(alpha: 0.55),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );

        if (widget.mode == 'COLLECTION') {
          return Dismissible(
              key: Key(vocab.word),
              direction: DismissDirection.endToStart,
              background: _dismissBackground(),
              confirmDismiss: (direction) async {
                return await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: context.bBg,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: Text(
                      t.homeRemoveFromCollectionTitle,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    content: Text(
                      t.homeRemoveFromCollectionBody(vocab.word),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: context.bMuted,
                      ),
                    ),
                    actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        style: TextButton.styleFrom(
                          foregroundColor: context.bMuted,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        child: Text(
                          t.commonCancel,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFD9534F),
                          foregroundColor: BrutalistTheme.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        ),
                        child: Text(
                          t.commonRemove,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ) ?? false;
              },
              onDismissed: (dir) async {
                final messenger = ScaffoldMessenger.of(context);
                final removedIndex = _allVocabData.indexOf(vocab);
                await CollectionService.removeWord(widget.topicTitle!, vocab.word);
                if (!mounted) return;
                setState(() { _allVocabData.remove(vocab); });
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(t.homeRemovedWord(vocab.word)),
                    duration: const Duration(seconds: 3),
                    action: SnackBarAction(
                      label: t.commonUndo,
                      onPressed: () async {
                        await CollectionService.addWord(
                            widget.topicTitle!, vocab.word);
                        if (!mounted) return;
                        setState(() {
                          // Put it back at its original index so the list order
                          // matches what the user saw before they swiped.
                          if (removedIndex >= 0 &&
                              removedIndex <= _allVocabData.length) {
                            _allVocabData.insert(removedIndex, vocab);
                          } else {
                            _allVocabData.add(vocab);
                          }
                        });
                      },
                    ),
                  ),
                );
              },
              child: card,
            );
        }

        return card;
      },
    );
  }

  Widget _buildSearchResults() {
    final String query = _searchQuery.toLowerCase().trim();
    List<Vocabulary> results = [];
    
    final sourceData = _allVocabData.isNotEmpty 
        ? _allVocabData 
        : _vocabData.values.expand((v) => v).toList();

    for (var vocab in sourceData) {
      if (vocab.word.toLowerCase().contains(query) || 
          vocab.translation.toLowerCase().contains(query)) {
        results.add(vocab);
      }
    }

    int getPopularityRank(String levels) {
      if (levels.isEmpty) return 99;
      final upper = levels.toUpperCase();
      if (upper.contains('A1')) return 1;
      if (upper.contains('A2')) return 2;
      if (upper.contains('B1')) return 3;
      if (upper.contains('B2')) return 4;
      if (upper.contains('C1')) return 5;
      return 99;
    }

    int getMatchTier(Vocabulary vocab) {
      final String w = vocab.word.toLowerCase();
      if (w == query) return 0;
      if (w.startsWith(query)) return 1;
      if (w.contains(query)) return 2;
      return 3;
    }

    results.sort((a, b) {
      final tierA = getMatchTier(a);
      final tierB = getMatchTier(b);
      if (tierA != tierB) return tierA.compareTo(tierB);

      final popA = getPopularityRank(a.levels);
      final popB = getPopularityRank(b.levels);
      if (popA != popB) return popA.compareTo(popB);

      if (a.word.length != b.word.length) {
         return a.word.length.compareTo(b.word.length);
      }
      return a.word.toLowerCase().compareTo(b.word.toLowerCase());
    });

    if (results.isEmpty) {
      final t = AppLocalizations.of(context);
      // When Search is opened from a collection's "+" picker, offer to keep
      // the typed query as a custom word — translated on the fly, added to
      // that collection. Plain Search (no callback) doesn't have a target
      // collection, so we don't surface the CTA there.
      final cb = widget.onWordSelected;
      final canAddCustom = cb != null && query.isNotEmpty;
      return _emptyState(
        icon: Icons.search_off_rounded,
        title: t.homeNoMatchesTitle,
        subtitle: t.homeNoMatchesSubtitle,
        action: canAddCustom
            ? FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: BrutalistTheme.primary,
                  foregroundColor: BrutalistTheme.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  await CustomWordService().translateAndStore([query]);
                  if (!mounted) return;
                  cb(CustomWordService().syntheticVocabulary(query));
                },
                icon: const Icon(Icons.add_rounded),
                label: Text(t.searchAddCustomCta(query)),
              )
            : null,
      );
    }

    Map<String, Vocabulary> collapsed = {};
    for (var vocab in results) {
      final key = vocab.word.toLowerCase();
      if (collapsed.containsKey(key)) {
        final existing = collapsed[key]!;
        final topicsList = existing.topic.split(', ').where((s) => s.isNotEmpty).toList();
        if (vocab.topic.isNotEmpty && !topicsList.contains(vocab.topic)) {
          topicsList.add(vocab.topic);
        }
        collapsed[key] = Vocabulary(
          id: existing.id,
          url: existing.url.isNotEmpty ? existing.url : vocab.url,
          levels: existing.levels,
          word: existing.word,
          translation: existing.translation,
          partOfSpeech: existing.partOfSpeech,
          ipa: existing.ipa,
          audioLink: existing.audioLink.isNotEmpty ? existing.audioLink : vocab.audioLink,
          topic: topicsList.join(', '),
        );
      } else {
        collapsed[key] = vocab;
      }
    }

    final distinctResults = collapsed.values.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: distinctResults.length,
      itemBuilder: (context, index) {
        final vocab = distinctResults[index];

        return BrutalistCard(
            backgroundColor: levelColor(vocab.levels, fallbackIndex: index),
            onTap: () {
              if (widget.onWordSelected != null) {
                widget.onWordSelected!(vocab);
              } else {
                Navigator.of(context).push(smoothRoute(LearningScreen(
                  day: 0,
                  vocabularies: distinctResults,
                  initialIndex: index,
                  onCompleted: widget.onCompleted,
                )));
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vocab.word,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: BrutalistTheme.black,
                                fontSize: 18,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          vocab.translation,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: BrutalistTheme.black.withValues(alpha: 0.55),
                                fontSize: 13,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (vocab.audioLink.isNotEmpty) _audioButton(vocab.audioLink),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 22,
                        color: BrutalistTheme.black.withValues(alpha: 0.55),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        );
      },
    );
  }

  VoidCallback? _buildNextDayCallback(BuildContext context, List<int> days, int index) {
    if (index + 1 >= days.length) return null;
    return () {
      final nextDay = days[index + 1];
      final raw = _vocabData[nextDay] ?? const <Vocabulary>[];
      // Honour the active POS filter when chaining day → day, otherwise
      // the next session would silently include filtered-out words.
      final words = _selectedPos.isEmpty
          ? raw
          : raw.where(_matchesPosFilter).toList();
      Navigator.of(context).pushReplacement(smoothRoute(LearningScreen(
        day: nextDay,
        vocabularies: words,
        onCompleted: _buildNextDayCallback(context, days, index + 1),
      )));
    };
  }

  Widget _buildList() {
    final t = AppLocalizations.of(context);
    // Build a POS-filtered view of every day. Days that have zero matching
    // words after filtering disappear from the grid so the user isn't left
    // tapping into an empty session.
    final allDays = _vocabData.keys.toList()..sort();
    final dayWords = <int, List<Vocabulary>>{};
    for (final d in allDays) {
      final list = _selectedPos.isEmpty
          ? _vocabData[d]!
          : _vocabData[d]!.where(_matchesPosFilter).toList();
      if (list.isNotEmpty) dayWords[d] = list;
    }
    final days = dayWords.keys.toList();

    if (days.isEmpty) {
      return _emptyState(
        icon: Icons.filter_alt_outlined,
        title: t.homeNoMatchesTitle,
        subtitle: t.homeNoMatchesSubtitle,
      );
    }

    // Compact 2-column grid so 8-10 days fit on one screen instead of 5.
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 1.35,
      ),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        final vocabList = dayWords[day]!;
        final dominantLevel = vocabList.isNotEmpty ? vocabList.first.levels : '';

        VoidCallback? onCompleted;
        if (index + 1 < days.length) {
          onCompleted = () {
            final nextDay = days[index + 1];
            Navigator.of(context).pushReplacement(smoothRoute(LearningScreen(
              day: nextDay,
              vocabularies: dayWords[nextDay]!,
              onCompleted: _buildNextDayCallback(context, days, index + 1),
            )));
          };
        }

        return BrutalistCard(
          backgroundColor: levelColor(dominantLevel, fallbackIndex: index),
          onTap: () {
            Navigator.of(context).push(smoothRoute(LearningScreen(
              day: day,
              vocabularies: vocabList,
              onCompleted: onCompleted,
            )));
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t.homeDayLabel(day),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: BrutalistTheme.black,
                        fontSize: 20,
                      ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        t.homeWordsCount(vocabList.length),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: BrutalistTheme.black.withValues(alpha: 0.55),
                              fontSize: 12,
                            ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: BrutalistTheme.black.withValues(alpha: 0.55),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Skeleton loader ──────────────────────────────────────────────────────────

class _SkeletonLoader extends StatefulWidget {
  final bool isDayList; // true = DAY X cards, false = flat vocab cards
  const _SkeletonLoader({this.isDayList = true});

  @override
  State<_SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<_SkeletonLoader>
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

  Widget _block(double w, double h, {double radius = 8}) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (_, _) => Opacity(
        opacity: _opacity.value,
        child: Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: BrutalistTheme.border,
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
    );
  }

  Widget _dayCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: BrutalistTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _block(100, 36, radius: 6),
                const SizedBox(height: 10),
                _block(70, 22, radius: 6),
              ],
            ),
          ),
          _block(28, 28, radius: 14),
        ],
      ),
    );
  }

  Widget _vocabCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: BrutalistTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _block(140, 28, radius: 6),
          const SizedBox(height: 10),
          _block(90, 18, radius: 6),
          const SizedBox(height: 16),
          _block(double.infinity, 1, radius: 0),
          const SizedBox(height: 16),
          _block(180, 22, radius: 6),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: 6,
      itemBuilder: (_, i) =>
          widget.isDayList ? _dayCard() : _vocabCard(),
    );
  }
}
