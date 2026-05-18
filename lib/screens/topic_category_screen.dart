import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import '../services/csv_service.dart';
import '../theme/brutalist_theme.dart';
import '../widgets/brutalist_card.dart';
import 'learning_screen.dart';

/// Drill-down screen for a single topic category (e.g. Animals). Shows its
/// subtopics as a 2-column grid of cards instead of the wrap-of-tiny-chips
/// that the old ExpansionTile produced — far less file-picker-y.
class TopicCategoryScreen extends StatelessWidget {
  final String category;
  final List<Map<String, String>> sublists;
  final List<String> levelFilter;

  const TopicCategoryScreen({
    super.key,
    required this.category,
    required this.sublists,
    required this.levelFilter,
  });

  Future<void> _openSubtopic(BuildContext context, int index) async {
    if (index >= sublists.length) return;
    final sub = sublists[index];
    final next = index + 1 < sublists.length
        ? () {
            if (!context.mounted) return;
            _openSubtopic(context, index + 1);
          }
        : null;
    final data = await CsvService.loadVocabularyByDayFromPath(
      sub['path']!,
      excludeKnown: true,
      levelFilter: levelFilter,
    );
    if (!context.mounted) return;
    final pool = data.values.expand((v) => v).toList();
    if (pool.isEmpty) return;
    final screen = LearningScreen(day: 0, vocabularies: pool, onCompleted: next);
    if (index == 0) {
      Navigator.of(context).push(smoothRoute(screen));
    } else {
      Navigator.of(context).pushReplacement(smoothRoute(screen));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final sorted = [...sublists]
      ..sort((a, b) => a['name']!.compareTo(b['name']!));

    return Scaffold(
      appBar: AppBar(title: Text(category.replaceAll('_', ' '))),
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          childAspectRatio: 1.35,
        ),
        itemCount: sorted.length,
        itemBuilder: (context, index) {
          final sub = sorted[index];
          final palette = [
            BrutalistTheme.primaryLight,
            BrutalistTheme.accentLight,
            BrutalistTheme.secondaryLight,
          ];
          final bg = palette[index % palette.length];
          return BrutalistCard(
            backgroundColor: bg,
            onTap: () => _openSubtopic(context, index),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    sub['name']!.replaceAll('_', ' '),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: BrutalistTheme.black,
                          fontSize: 16,
                          height: 1.2,
                        ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          sub['count'] == '1'
                              ? t.topicCategoryWordSingular(1)
                              : t.topicCategoryWordPlural(int.tryParse(sub['count'] ?? '0') ?? 0),
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
      ),
    );
  }
}
