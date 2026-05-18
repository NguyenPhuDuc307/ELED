import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, AssetManifest;

import '../l10n/gen/app_localizations.dart';
import '../services/csv_service.dart';
import '../theme/brutalist_theme.dart';
import '../widgets/brutalist_card.dart';
import 'topic_category_screen.dart';

class TopicScreen extends StatefulWidget {
  const TopicScreen({super.key});

  @override
  State<TopicScreen> createState() => _TopicScreenState();
}

class _TopicScreenState extends State<TopicScreen> {
  bool _isLoading = true;
  Map<String, List<Map<String, String>>> _topics = {};

  static const _levels = ['A1', 'A2', 'B1', 'B2', 'C1'];
  List<String> _selectedLevels = ['A1', 'A2', 'B1'];

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  Future<void> _loadTopics() async {
    setState(() => _isLoading = true);
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final topicFiles = manifest
          .listAssets()
          .where((k) => k.startsWith('assets/data/topic/') && k.endsWith('.csv'))
          .toList();

      final topics = <String, List<Map<String, String>>>{};
      for (final path in topicFiles) {
        final parts = path.split('/');
        final category = parts.length >= 5 ? parts[3] : 'Others';
        final filename = parts.last.replaceAll('.csv', '');

        final vocabList =
            await CsvService.loadVocabularyFromPath(path, excludeKnown: true);
        final filteredCount = _selectedLevels.isEmpty
            ? vocabList.length
            : vocabList.where((v) {
                final vLevel = v.levels.toUpperCase();
                return _selectedLevels
                    .any((f) => vLevel.contains(f.toUpperCase()));
              }).length;

        if (filteredCount > 0) {
          topics
              .putIfAbsent(category, () => [])
              .add({'name': filename, 'path': path, 'count': '$filteredCount'});
        }
      }

      if (!mounted) return;
      setState(() {
        _topics = topics;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleLevel(String level) {
    final updated = List<String>.from(_selectedLevels);
    if (updated.contains(level)) {
      if (updated.length == 1) return;
      updated.remove(level);
    } else {
      updated.add(level);
    }
    setState(() => _selectedLevels = updated);
    _loadTopics();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.topicsTitle)),
      body: Column(
        children: [
          _buildLevelSelector(),
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: context.bBorder,
                      strokeWidth: 5,
                    ),
                  )
                : _topics.isEmpty
                    ? _buildEmptyState()
                    : _buildCategoryList(),
          ),
        ],
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
              onTap: () => _toggleLevel(level),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: BrutalistTheme.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.category_outlined,
                  size: 36, color: BrutalistTheme.primary),
            ),
            const SizedBox(height: 20),
            Text(
              t.topicsEmptyTitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: context.bBorder,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              t.topicsEmptyHint,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: context.bMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    final t = AppLocalizations.of(context);
    final categories = _topics.keys.toList()..sort();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final sublists = _topics[category]!;
        final wordCount = sublists.fold<int>(
            0, (sum, e) => sum + (int.tryParse(e['count'] ?? '0') ?? 0));

        return BrutalistCard(
          backgroundColor: context.bBg,
          onTap: () {
            Navigator.of(context).push(smoothRoute(TopicCategoryScreen(
              category: category,
              sublists: sublists,
              levelFilter: _selectedLevels,
            )));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: BrutalistTheme.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_iconFor(category),
                      color: BrutalistTheme.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.replaceAll('_', ' '),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sublists.length == 1
                            ? t.topicsCategorySummarySingular(sublists.length, wordCount)
                            : t.topicsCategorySummaryPlural(sublists.length, wordCount),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: context.bMuted),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: context.bMuted),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Pick a passable icon for each top-level category. Falls back to a
  /// generic tag if the name doesn't match anything below.
  IconData _iconFor(String category) {
    final c = category.toLowerCase();
    if (c.contains('animal')) return Icons.pets_rounded;
    if (c.contains('appearance')) return Icons.face_rounded;
    if (c.contains('communication')) return Icons.chat_bubble_outline_rounded;
    if (c.contains('culture')) return Icons.theater_comedy_rounded;
    if (c.contains('food') || c.contains('drink')) return Icons.restaurant_rounded;
    if (c.contains('function')) return Icons.build_rounded;
    if (c.contains('health')) return Icons.favorite_border_rounded;
    if (c.contains('home') || c.contains('building')) return Icons.home_rounded;
    if (c.contains('leisure')) return Icons.sports_esports_rounded;
    if (c.contains('notion')) return Icons.lightbulb_outline_rounded;
    if (c.contains('people')) return Icons.people_rounded;
    if (c.contains('politic') || c.contains('society')) return Icons.account_balance_rounded;
    if (c.contains('science') || c.contains('tech')) return Icons.science_rounded;
    if (c.contains('sport')) return Icons.sports_basketball_rounded;
    if (c.contains('natural')) return Icons.park_rounded;
    if (c.contains('time') || c.contains('space')) return Icons.schedule_rounded;
    if (c.contains('travel')) return Icons.flight_rounded;
    if (c.contains('work') || c.contains('business')) return Icons.work_outline_rounded;
    return Icons.label_outline_rounded;
  }
}
