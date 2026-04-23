import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, AssetManifest;
import '../theme/brutalist_theme.dart';
import '../widgets/brutalist_card.dart';
import '../services/csv_service.dart';
import 'learning_screen.dart';

class TopicScreen extends StatefulWidget {
  const TopicScreen({super.key});

  @override
  State<TopicScreen> createState() => _TopicScreenState();
}

class _TopicScreenState extends State<TopicScreen> {
  bool _isLoading = true;
  Map<String, List<Map<String, String>>> _topics = {};
  
  final List<String> _levels = ['A1', 'A2', 'B1', 'B2', 'C1'];
  List<String> _selectedTopicLevels = ['A1', 'A2', 'B1'];

  void _openSubtopic(BuildContext context, List<Map<String, String>> sublists, int index, {bool replace = false}) {
    if (index >= sublists.length) return;
    final sub = sublists[index];
    final onCompleted = index + 1 < sublists.length
        ? () => _openSubtopic(context, sublists, index + 1, replace: true)
        : null;
    CsvService.loadVocabularyByDayFromPath(
      sub['path']!,
      excludeKnown: true,
      levelFilter: _selectedTopicLevels,
    ).then((data) {
      final pool = data.values.expand((v) => v).toList();
      if (!context.mounted || pool.isEmpty) return;
      final screen = LearningScreen(day: 0, vocabularies: pool, onCompleted: onCompleted);
      if (replace) {
        Navigator.of(context).pushReplacement(smoothRoute(screen));
      } else {
        Navigator.of(context).push(smoothRoute(screen));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  Future<void> _loadTopics() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final topicFiles = assetManifest.listAssets()
          .where((String key) => key.startsWith('assets/data/topic/') && key.endsWith('.csv'))
          .toList();

      Map<String, List<Map<String, String>>> topics = {};

      for (var path in topicFiles) {
        final parts = path.split('/');
        String category = 'Others';
        String filename = parts.last.replaceAll('.csv', '');
        
        if (parts.length >= 5) {
          category = parts[3];
        }

        final vocabList = await CsvService.loadVocabularyFromPath(path, excludeKnown: true);
        final filteredCount = _selectedTopicLevels.isEmpty ? vocabList.length : vocabList.where((v) {
          final vLevel = v.levels.toUpperCase();
          return _selectedTopicLevels.any((filter) => vLevel.contains(filter.toUpperCase()));
        }).length;

        if (filteredCount > 0) {
          if (!topics.containsKey(category)) {
            topics[category] = [];
          }
          topics[category]!.add({
            'name': filename,
            'path': path,
            'count': filteredCount.toString(),
          });
        }
      }

      setState(() {
        _topics = topics;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Topics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) {
                  return StatefulBuilder(
                    builder: (context, setDialogState) {
                      return AlertDialog(
                        backgroundColor: context.bBg,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: Text(
                          'Filter by Level',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: _levels.map((level) {
                              return CheckboxListTile(
                                title: Text(level, style: TextStyle(fontWeight: FontWeight.w600, color: context.bBorder)),
                                value: _selectedTopicLevels.contains(level),
                                activeColor: BrutalistTheme.primary,
                                checkColor: BrutalistTheme.white,
                                side: BorderSide(color: context.bSubtle, width: 1.5),
                                onChanged: (bool? value) {
                                  setDialogState(() {
                                    if (value == true) {
                                      _selectedTopicLevels.add(level);
                                    } else {
                                      _selectedTopicLevels.remove(level);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                        actions: [
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: BrutalistTheme.primary,
                              foregroundColor: BrutalistTheme.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            ),
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              _loadTopics();
                            },
                            child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ],
                      );
                    }
                  );
                },
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: context.bBorder,
                strokeWidth: 6,
              ),
            )
          : _topics.isEmpty
              ? _buildEmptyState()
              : _buildTopicList(),
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
              'NO TOPIC DATA FOUND.\nPLEASE USE THE SCRAPER TO FETCH DATA!',
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

  Widget _buildTopicList() {
    final categories = _topics.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      clipBehavior: Clip.none,
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final sublists = _topics[category]!;
        sublists.sort((a, b) => a['name']!.compareTo(b['name']!));

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cardBg = index % 2 == 0
            ? (isDark ? const Color(0xFF1A3020) : BrutalistTheme.primaryLight)
            : (isDark ? const Color(0xFF2A1810) : BrutalistTheme.accentLight);

        return BrutalistCard(
            backgroundColor: cardBg,
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                shape: const Border(),
                collapsedShape: const Border(),
                iconColor: context.bBorder,
                collapsedIconColor: context.bBorder,
                title: Text(
                  category.replaceAll('_', ' ').toUpperCase(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.bBorder,
                        fontSize: 18,
                      ),
                ),
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: context.bSubtle, width: 1)),
                      color: context.bBg,
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: sublists.map((sublist) {
                        return IntrinsicWidth(
                          child: GestureDetector(
                            onTap: () {
                              final i = sublists.indexOf(sublist);
                              _openSubtopic(context, sublists, i);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E3A28) : BrutalistTheme.primaryLight,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${sublist['name']!.replaceAll('_', ' ')} (${sublist['count']!})',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: context.bBorder,
                                      fontSize: 13,
                                    ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
        );
      },
    );
  }
}
