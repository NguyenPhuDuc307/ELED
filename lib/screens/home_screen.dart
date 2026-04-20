import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  const HomeScreen({
    super.key,
    this.mode = 'POPULARITY',
    this.topicPath,
    this.topicTitle,
    this.initSearch = false,
    this.topicLevelsFilter,
    this.onWordSelected,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<int, List<Vocabulary>> _vocabData = {};
  List<Vocabulary> _allVocabData = [];
  bool _isLoading = true;
  String _selectedLevel = 'A1';
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
      _loadData(_selectedLevel);
      _loadAllData();
    }
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

  Future<void> _loadData(String level) async {
    setState(() {
      _isLoading = true;
    });
    final data = await CsvService.loadVocabularyByDay(level, excludeKnown: true);
    if (mounted) {
      setState(() {
        _vocabData = data;
        _isLoading = false;
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
                  hintText: 'SEARCH ENTIRE DATABASE...',
                  hintStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.grey.shade600,
                      ),
                  border: InputBorder.none,
                ),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              )
            : Text(
                widget.mode == 'KNOWN'
                    ? 'KNOWN WORDS'
                    : widget.mode == 'HISTORY'
                        ? 'HISTORY'
                        : widget.mode == 'COLLECTION' && widget.topicTitle != null
                            ? widget.topicTitle!.toUpperCase()
                            : widget.mode == 'TOPIC' && widget.topicTitle != null 
                                ? widget.topicTitle!.toUpperCase() 
                                : 'ELED.',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: (widget.mode == 'TOPIC' || widget.mode == 'KNOWN' || widget.mode == 'HISTORY' || widget.mode == 'COLLECTION') ? 24 : 40,
                      fontWeight: FontWeight.w900,
                    ),
              ),
        actions: [
          if (widget.mode == 'HISTORY')
            IconButton(
              icon: Icon(
                Icons.delete,
                color: BrutalistTheme.secondary,
                size: 32,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: context.bBg,
                    shape: Border.all(color: context.bBorder, width: 4),
                    title: Text(
                      'CLEAR HISTORY?', 
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: context.bBorder,
                      )
                    ),
                    content: Text(
                      'Are you sure you want to completely erase the notification history? This action cannot be undone.', 
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: context.bBorder,
                      )
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text('CANCEL', style: TextStyle(color: context.bBorder, fontWeight: FontWeight.w900)),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: BrutalistTheme.secondary,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        ),
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                          final messenger = ScaffoldMessenger.of(context);
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove('notificationHistory');
                          setState(() {
                            _allVocabData.clear();
                          });
                          if (mounted) {
                            messenger.showSnackBar(
                              const SnackBar(content: Text('HISTORY CLEARED!')),
                            );
                          }
                        },
                        child: Text('DELETE', style: TextStyle(color: BrutalistTheme.black, fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                );
              },
            ),

          if (widget.mode == 'COLLECTION')
            IconButton(
              icon: Icon(
                Icons.add,
                color: context.bBorder,
                size: 32,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(
                      mode: 'SEARCH',
                      onWordSelected: (vocab) async {
                        final added = await CollectionService.addWord(widget.topicTitle!, vocab.word);
                        if (added && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ADDED COMPLETED!')));
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
              icon: Icon(
                _isSearching ? Icons.close : Icons.search,
                color: context.bBorder,
                size: 32,
              ),
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
                ? Center(
                    child: CircularProgressIndicator(
                      color: context.bBorder,
                      strokeWidth: 6,
                    ),
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
      height: 80,
      decoration: BoxDecoration(
        color: context.bBg,
        border: Border(bottom: BorderSide(color: context.bBorder, width: 4)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _levels.length,
        itemBuilder: (context, index) {
          final level = _levels[index];
          final isSelected = level == _selectedLevel;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                if (!isSelected) {
                  setState(() => _selectedLevel = level);
                  _loadData(level);
                }
              },
              child: Container(
                width: 70,
                decoration: BoxDecoration(
                  color: isSelected ? context.bBorder : context.bBg,
                  border: Border.all(color: context.bBorder, width: 3),
                  boxShadow: isSelected
                      ? null
                      : [
                          BoxShadow(
                            color: context.bBorder,
                            offset: const Offset(4, 4),
                          )
                        ],
                ),
                alignment: Alignment.center,
                child: Text(
                  level,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: isSelected ? context.bBg : context.bBorder,
                        fontWeight: FontWeight.w900,
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
      padding: const EdgeInsets.all(24),
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
            padding: const EdgeInsets.all(24.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    vocab.word,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 32,
                          color: BrutalistTheme.black,
                        ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: BrutalistTheme.black,
                            fontStyle: FontStyle.italic,
                          ),
                      children: [
                        TextSpan(text: '${vocab.partOfSpeech.toUpperCase()} | '),
                        TextSpan(
                          text: vocab.ipa,
                          style: GoogleFonts.notoSans(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: BrutalistTheme.black, thickness: 3),
                  const SizedBox(height: 16),
                  Text(
                    vocab.translation,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: BrutalistTheme.black,
                        ),
                  ),
                  if (vocab.topic.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'TOPIC: ${vocab.topic.toUpperCase()}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: BrutalistTheme.black,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                ],
              ),
            ),
        );

        if (widget.mode == 'COLLECTION') {
          return Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Dismissible(
              key: Key(vocab.word),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: const Icon(Icons.delete_forever, color: Colors.white, size: 40),
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
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
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
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: card,
        );
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
      padding: const EdgeInsets.all(24),
      itemCount: distinctResults.length,
      itemBuilder: (context, index) {
        final vocab = distinctResults[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: BrutalistCard(
            backgroundColor: levelColor(vocab.levels, fallbackIndex: index),
            onTap: () {
              if (widget.onWordSelected != null) {
                widget.onWordSelected!(vocab);
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => LearningScreen(
                      day: 0,
                      vocabularies: distinctResults,
                      initialIndex: index,
                    ),
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    vocab.word,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 32,
                          color: BrutalistTheme.black,
                        ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: BrutalistTheme.black,
                            fontStyle: FontStyle.italic,
                          ),
                      children: [
                        TextSpan(text: '${vocab.partOfSpeech.toUpperCase()} | '),
                        TextSpan(
                          text: vocab.ipa,
                          style: GoogleFonts.notoSans(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: BrutalistTheme.black, thickness: 3),
                  const SizedBox(height: 16),
                  Text(
                    vocab.translation,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: BrutalistTheme.black,
                        ),
                  ),
                  if (vocab.topic.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'TOPIC: ${vocab.topic.toUpperCase()}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: BrutalistTheme.black,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildList() {
    final days = _vocabData.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        final vocabList = _vocabData[day]!;
        final isEven = index % 2 == 0;

        return BrutalistCard(
          backgroundColor: isEven ? BrutalistTheme.primary : BrutalistTheme.accent,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => LearningScreen(
                  day: day,
                  vocabularies: vocabList,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DAY $day',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 48,
                              color: BrutalistTheme.black,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: BrutalistTheme.white,
                          border: Border.all(color: BrutalistTheme.black, width: 2),
                        ),
                        child: Text(
                          '${vocabList.length} WORDS',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: BrutalistTheme.black,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward,
                  size: 48,
                  color: BrutalistTheme.black,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
