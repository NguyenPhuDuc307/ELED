import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vocabulary.dart';
import '../services/csv_service.dart';
import '../services/collection_service.dart';
import '../theme/brutalist_theme.dart';
import '../widgets/brutalist_card.dart';
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
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
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
    final Map<int, List<Vocabulary>> grouped = {};
    int day = 1;
    for (var i = 0; i < allVocab.length; i++) {
      if (i > 0 && i % 20 == 0) day++;
      grouped.putIfAbsent(day, () => []).add(allVocab[i]);
    }
    grouped.removeWhere((_, v) => v.isEmpty);
    if (mounted) setState(() { _vocabData = grouped; _isLoading = false; });
  }

  Future<void> _loadKnownWordsData() async {
    setState(() {
      _isLoading = true;
    });
    final allData = await CsvService.loadAllVocabulary(); // Notice excludeKnown is natively false here, perfect for retaining the pool
    final prefs = await SharedPreferences.getInstance();
    final knownWords = (prefs.getStringList('knownWords') ?? []).map((w) => w.toLowerCase()).toSet();

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

    if (mounted) {
      setState(() {
        List<Vocabulary> list = [];
        for (var w in collectionWords) {
          final matches = allData.where((v) => v.word.toLowerCase() == w);
          if (matches.isNotEmpty) {
            list.add(matches.first);
          }
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


  @override
  Widget build(BuildContext context) {
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
                  hintText: 'Search entire database...',
                  hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: context.bMuted,
                      ),
                  border: InputBorder.none,
                ),
                style: Theme.of(context).textTheme.bodyLarge,
              )
            : Text(
                widget.mode == 'KNOWN'
                    ? 'Known Words'
                    : widget.mode == 'HISTORY'
                        ? 'History'
                        : widget.mode == 'COLLECTION' && widget.topicTitle != null
                            ? widget.topicTitle!
                            : widget.mode == 'TOPIC' && widget.topicTitle != null
                                ? widget.topicTitle!
                                : 'Popularity',
              ),
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
                      'Clear history?',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    content: Text(
                      'This will erase all notification history. This action cannot be undone.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: context.bMuted,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text(
                          'Cancel',
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
                          setState(() => _allVocabData.clear());
                          if (mounted) {
                            messenger.showSnackBar(
                              const SnackBar(content: Text('History cleared.')),
                            );
                          }
                        },
                        child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w600)),
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
                    builder: (context) => HomeScreen(
                      mode: 'SEARCH',
                      onWordSelected: (vocab) async {
                        final added = await CollectionService.addWord(widget.topicTitle!, vocab.word);
                        if (added && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Word added to collection!')));
                          _loadCollectionData();
                        }
                        if (mounted) Navigator.of(context).pop(); // pop search screen
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
          Expanded(
            child: _isLoading
                ? _SkeletonLoader(
                    isDayList: widget.mode == 'POPULARITY' || widget.mode == 'TOPIC',
                  )
                : (widget.mode == 'KNOWN' || widget.mode == 'HISTORY' || widget.mode == 'COLLECTION')
                    ? _buildFlatList(_allVocabData)
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

  Widget _buildSearchPromptState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Text(
          'ENTER KEYWORD TO SEARCH...',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w900,
              ),
          textAlign: TextAlign.center,
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: BrutalistCard(
          backgroundColor: BrutalistTheme.secondary,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'NO DATA FOUND IN CSV.\nPLEASE ADD VOCABULARY.',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: context.bBg,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlatList(List<Vocabulary> results) {
    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            widget.mode == 'COLLECTION'
                ? 'COLLECTION IS EMPTY.\nTAP + TO ADD WORDS!'
                : 'NO KNOWN WORDS YET.\nKEEP LEARNING!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: context.bBorder,
                  fontWeight: FontWeight.w900,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: results.length,
      itemBuilder: (context, index) {
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
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: BrutalistTheme.black.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        );

        if (widget.mode == 'COLLECTION') {
          return Dismissible(
              key: Key(vocab.word),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: const Icon(Icons.delete_forever_rounded, color: Colors.white, size: 40),
              ),
              confirmDismiss: (direction) async {
                return await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: context.bBg,
                    shape: Border.all(color: context.bBorder, width: 4),
                    title: Text(
                      'REMOVE FROM COLLECTION?',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: context.bBorder,
                      ),
                    ),
                    content: Text(
                      'Remove "${vocab.word}" from this collection?',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: context.bBorder,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: Text('CANCEL', style: TextStyle(color: context.bBorder, fontWeight: FontWeight.w900)),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: BrutalistTheme.secondary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: Text('REMOVE', style: TextStyle(color: BrutalistTheme.black, fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                ) ?? false;
              },
              onDismissed: (dir) async {
                await CollectionService.removeWord(widget.topicTitle!, vocab.word);
                setState(() {
                  _allVocabData.remove(vocab);
                });
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
      return Center(
        child: Text(
          'NO RESULTS FOUND.',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: context.bBorder,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
    }

    Map<String, Vocabulary> collapsed = {};
    for (var vocab in results) {
      final key = vocab.word.toLowerCase();
      if (collapsed.containsKey(key)) {
        final existing = collapsed[key]!;
        if (vocab.topic.isNotEmpty) {
           final topicsList = existing.topic.split(', ').where((s) => s.isNotEmpty).toList();
           if (!topicsList.contains(vocab.topic)) {
              topicsList.add(vocab.topic);
           }
           final newTopic = topicsList.join(', ');
           collapsed[key] = Vocabulary(
              id: existing.id,
              url: existing.url,
              levels: existing.levels,
              word: existing.word,
              translation: existing.translation,
              partOfSpeech: existing.partOfSpeech,
              ipa: existing.ipa,
              audioLink: existing.audioLink,
              topic: newTopic,
           );
        }
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
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: BrutalistTheme.black.withValues(alpha: 0.5),
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
      Navigator.of(context).pushReplacement(smoothRoute(LearningScreen(
        day: nextDay,
        vocabularies: _vocabData[nextDay]!,
        onCompleted: _buildNextDayCallback(context, days, index + 1),
      )));
    };
  }

  Widget _buildList() {
    final days = _vocabData.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        final vocabList = _vocabData[day]!;
        final dominantLevel = vocabList.isNotEmpty ? vocabList.first.levels : '';

        VoidCallback? onCompleted;
        if (index + 1 < days.length) {
          onCompleted = () {
            final nextDay = days[index + 1];
            Navigator.of(context).pushReplacement(smoothRoute(LearningScreen(
              day: nextDay,
              vocabularies: _vocabData[nextDay]!,
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
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Day $day',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: BrutalistTheme.black,
                              fontSize: 18,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        () {
                          final levels = vocabList
                              .map((v) => v.levels.toUpperCase())
                              .where((l) => l.isNotEmpty)
                              .toSet()
                              .toList()
                            ..sort();
                          final levelStr = levels.isNotEmpty ? ' · ${levels.join(', ')}' : '';
                          return '${vocabList.length} words$levelStr';
                        }(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: BrutalistTheme.black.withValues(alpha: 0.55),
                              fontSize: 13,
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: BrutalistTheme.black.withValues(alpha: 0.5),
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
      builder: (_, __) => Opacity(
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
