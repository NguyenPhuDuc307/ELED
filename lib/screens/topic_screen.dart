import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, AssetManifest;
import '../theme/brutalist_theme.dart';
import '../widgets/brutalist_card.dart';
import 'home_screen.dart';

class TopicScreen extends StatefulWidget {
  const TopicScreen({super.key});

  @override
  State<TopicScreen> createState() => _TopicScreenState();
}

class _TopicScreenState extends State<TopicScreen> {
  bool _isLoading = true;
  Map<String, List<Map<String, String>>> _topics = {};

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  Future<void> _loadTopics() async {
    try {
      final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final topicFiles = assetManifest.listAssets()
          .where((String key) => key.startsWith('assets/data/topic/') && key.endsWith('.csv'))
          .toList();

      Map<String, List<Map<String, String>>> topics = {};

      for (var path in topicFiles) {
        final parts = path.split('/');
        if (parts.length >= 5) {
          final category = parts[3];
          final filename = parts.last.replaceAll('.csv', '');
          
          if (!topics.containsKey(category)) {
            topics[category] = [];
          }
          topics[category]!.add({
            'name': filename,
            'path': path,
          });
        } else if (parts.length == 4) {
          // If file is directly in topic/, give it a category "Other" or its filename
          final filename = parts.last.replaceAll('.csv', '');
          final category = 'Others';
          if (!topics.containsKey(category)) {
            topics[category] = [];
          }
          topics[category]!.add({
            'name': filename,
            'path': path,
          });
        }
      }

      setState(() {
        _topics = topics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
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
                              sublist['name']!,
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
