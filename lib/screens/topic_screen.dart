import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, AssetManifest;
import '../theme/brutalist_theme.dart';
import '../widgets/brutalist_card.dart';
import '../services/csv_service.dart';
import 'home_screen.dart';

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
        title: Text(
          'SELECT TOPIC',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: context.bBorder,
              size: 32,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) {
                  return StatefulBuilder(
                    builder: (context, setDialogState) {
                      return AlertDialog(
                        backgroundColor: context.bBg,
                        shape: Border.all(color: context.bBorder, width: 4),
                        title: Text(
                          'FILTER BY LEVEL', 
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: context.bBorder,
                          )
                        ),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: _levels.map((level) {
                              return CheckboxListTile(
                                title: Text(level, style: TextStyle(fontWeight: FontWeight.bold, color: context.bBorder)),
                                value: _selectedTopicLevels.contains(level),
                                activeColor: BrutalistTheme.secondary,
                                checkColor: BrutalistTheme.black,
                                side: BorderSide(color: context.bBorder, width: 2),
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
                              backgroundColor: BrutalistTheme.secondary,
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                              side: BorderSide(color: context.bBorder, width: 2),
                            ),
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              _loadTopics();
                            },
                            child: Text('APPLY', style: TextStyle(color: BrutalistTheme.black, fontWeight: FontWeight.w900)),
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
      padding: const EdgeInsets.all(24),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final sublists = _topics[category]!;
        sublists.sort((a, b) => a['name']!.compareTo(b['name']!));

        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: BrutalistCard(
            backgroundColor: index % 2 == 0 ? BrutalistTheme.primary : BrutalistTheme.accent,
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                iconColor: BrutalistTheme.black,
                collapsedIconColor: BrutalistTheme.black,
                title: Text(
                  category.toUpperCase(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: BrutalistTheme.black,
                      ),
                ),
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: BrutalistTheme.black, width: 3)),
                      color: BrutalistTheme.white,
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: sublists.map((sublist) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => HomeScreen(
                                  mode: 'TOPIC',
                                  topicPath: sublist['path'],
                                  topicTitle: sublist['name'],
                                  topicLevelsFilter: _selectedTopicLevels,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: BrutalistTheme.white,
                              border: Border.all(color: BrutalistTheme.black, width: 2),
                              boxShadow: const [
                                BoxShadow(
                                  color: BrutalistTheme.black,
                                  offset: Offset(2, 2),
                                )
                              ],
                            ),
                            child: Text(
                              '${sublist['name']!} (${sublist['count']!})',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: BrutalistTheme.black,
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
          ),
        );
      },
    );
  }
}
