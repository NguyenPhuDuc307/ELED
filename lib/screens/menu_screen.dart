import 'package:flutter/material.dart';
import '../theme/brutalist_theme.dart';
import '../widgets/brutalist_card.dart';
import 'home_screen.dart';
import 'topic_screen.dart';
import 'collections_screen.dart';
import 'settings_screen.dart';
import 'learning_screen.dart';
import '../services/csv_service.dart';
import '../main.dart';


class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  bool _isNavigating = false;

  Future<void> _navigate(Widget page) async {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);
    await Navigator.of(context).push(smoothRoute(page));
    if (mounted) setState(() => _isNavigating = false);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Handle "Known" action from notification when app was not in foreground
      if (pendingMarkKnownWord != null) {
        final word = pendingMarkKnownWord!;
        pendingMarkKnownWord = null;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"${word.toLowerCase()}" added to your known words'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }

      if (pendingNotificationPayload != null) {
        final payload = pendingNotificationPayload!;
        pendingNotificationPayload = null;

        final allVocab = await CsvService.loadAllVocabulary(excludeKnown: false);
        final parts = payload.split('|');
        final matchWord = parts[0].trim().toLowerCase();
        final matchTopic = parts.length > 1 ? parts[1].trim().toLowerCase() : '';
        final matches = allVocab.where((v) => v.word.trim().toLowerCase() == matchWord);

        if (matches.isNotEmpty && mounted) {
          final exact = matches.where((v) => v.topic.trim().toLowerCase() == matchTopic);
          final vocab = exact.isNotEmpty ? exact.first : matches.first;
          Navigator.push(
            context,
            smoothRoute(LearningScreen(day: 0, vocabularies: [vocab])),
          );
        }
      }
    });
  }

  Widget _menuCardGrid(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color color,
    required Color titleColor,
    required IconData icon,
    required VoidCallback onTap,
    double extraBottomPad = 20,
  }) {
    return BrutalistCard(
      backgroundColor: color,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.fromLTRB(18, 20, 18, extraBottomPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: titleColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: titleColor, size: 22),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                    fontSize: 16,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: titleColor.withValues(alpha: 0.65),
                    fontSize: 12,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ELED',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: BrutalistTheme.primary,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => Navigator.of(context).push(
              smoothRoute( const HomeScreen(mode: 'SEARCH')),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Navigator.of(context).push(
              smoothRoute( const SettingsScreen()),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Monstera — behind everything
            Positioned(
              top: -16,
              right: -20,
              child: IgnorePointer(
                child: SizedBox(
                  width: 240,
                  height: 320,
                  child: Image.asset(
                    'assets/home.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.topRight,
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header text — right padding leaves room for plant
                Padding(
                  padding: const EdgeInsets.only(right: 140),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose a mode',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: context.bMuted,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'How do you want\nto learn today?',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 26,
                              height: 1.25,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
            // 2-column staggered grid
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column
                Expanded(
                  child: Column(
                    children: [
                      _menuCardGrid(
                        context,
                        title: 'Popularity',
                        subtitle: 'Learn words from A1 to C1 level',
                        color: const Color(0xFFC8DEC4),
                        titleColor: const Color(0xFF2A4A28),
                        icon: Icons.trending_up_rounded,
                        extraBottomPad: 36,
                        onTap: () => _navigate(const HomeScreen(mode: 'POPULARITY')),
                      ),
                      _menuCardGrid(
                        context,
                        title: 'My Collections',
                        subtitle: 'Your custom word lists',
                        color: const Color(0xFFF5E4CC),
                        titleColor: const Color(0xFF5A3A18),
                        icon: Icons.bookmark_rounded,
                        onTap: () => _navigate(const CollectionsScreen()),
                      ),
                      _menuCardGrid(
                        context,
                        title: 'History',
                        subtitle: 'Words via notifications',
                        color: const Color(0xFFE8D4C8),
                        titleColor: const Color(0xFF5A3028),
                        icon: Icons.history_rounded,
                        onTap: () => _navigate(const HomeScreen(mode: 'HISTORY')),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Right column — staggered down
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: Column(
                      children: [
                        _menuCardGrid(
                          context,
                          title: 'Topics',
                          subtitle: 'By category: animals, travel…',
                          color: const Color(0xFFF5D5CC),
                          titleColor: const Color(0xFF5A2820),
                          icon: Icons.category_rounded,
                          extraBottomPad: 36,
                          onTap: () => _navigate(const TopicScreen()),
                        ),
                        _menuCardGrid(
                          context,
                          title: 'Known Words',
                          subtitle: 'Review words you already know',
                          color: const Color(0xFFF5C4B8),
                          titleColor: const Color(0xFF5A2818),
                          icon: Icons.check_circle_rounded,
                          onTap: () => _navigate(const HomeScreen(mode: 'KNOWN')),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
          ],
        ),
          ),
          // Loading overlay
          if (_isNavigating)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _isNavigating ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 150),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.15),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: BrutalistTheme.surface,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: CircularProgressIndicator(
                          color: BrutalistTheme.primary,
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
