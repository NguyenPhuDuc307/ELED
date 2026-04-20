import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/brutalist_theme.dart';
import '../widgets/brutalist_card.dart';
import 'home_screen.dart';
import 'topic_screen.dart';
import 'collections_screen.dart';
import 'settings_screen.dart';
import 'learning_screen.dart';
import '../services/csv_service.dart';
import '../main.dart';

// Inline SVG leaf decorations — no asset files required
const _svgLeafTall = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 60 120">
  <path d="M30,115 C6,92 0,58 14,20 C20,6 30,2 30,2 C30,2 40,6 46,20 C60,58 54,92 30,115 Z"
        fill="#6B9B66" opacity="0.65"/>
  <path d="M30,115 Q29,72 30,2" stroke="#3D6B38" stroke-width="1.5" fill="none" opacity="0.5"/>
  <path d="M30,88 Q15,74 10,52" stroke="#3D6B38" stroke-width="1" fill="none" opacity="0.4"/>
  <path d="M30,88 Q45,74 50,52" stroke="#3D6B38" stroke-width="1" fill="none" opacity="0.4"/>
  <path d="M30,62 Q16,50 12,30" stroke="#3D6B38" stroke-width="1" fill="none" opacity="0.4"/>
  <path d="M30,62 Q44,50 48,30" stroke="#3D6B38" stroke-width="1" fill="none" opacity="0.4"/>
</svg>
''';

const _svgLeafWide = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 80">
  <path d="M8,72 C4,44 18,12 52,4 C82,0 100,18 96,46 C92,68 66,80 40,77 C24,74 8,72 8,72 Z"
        fill="#7BAF76" opacity="0.55"/>
  <path d="M8,72 C32,54 64,28 96,46" stroke="#3D6B38" stroke-width="1.5" fill="none" opacity="0.4"/>
  <path d="M22,70 C32,50 50,30 70,16" stroke="#3D6B38" stroke-width="1" fill="none" opacity="0.3"/>
  <path d="M40,74 C50,55 64,38 80,26" stroke="#3D6B38" stroke-width="1" fill="none" opacity="0.3"/>
</svg>
''';

const _svgLeafFrond = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 80 100">
  <path d="M72,92 Q42,62 8,8" stroke="#6B9B66" stroke-width="2.5" fill="none" opacity="0.6"/>
  <path d="M28,48 Q14,30 4,26" stroke="#6B9B66" stroke-width="2" fill="none" opacity="0.55"/>
  <path d="M38,38 Q28,18 22,8" stroke="#6B9B66" stroke-width="1.8" fill="none" opacity="0.5"/>
  <path d="M50,30 Q44,10 40,2" stroke="#6B9B66" stroke-width="1.8" fill="none" opacity="0.5"/>
  <path d="M60,22 Q58,4 57,0" stroke="#6B9B66" stroke-width="1.5" fill="none" opacity="0.45"/>
</svg>
''';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (pendingNotificationPayload != null) {
        final word = pendingNotificationPayload!;
        pendingNotificationPayload = null;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('BOOT INTENT: $word')));
        }

        final allVocab = await CsvService.loadAllVocabulary(excludeKnown: false);
        final matchPayload = word.trim().toLowerCase();
        final matchList = allVocab.where((v) => v.word.trim().toLowerCase() == matchPayload);

        if (matchList.isNotEmpty && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LearningScreen(
                day: 0,
                vocabularies: [matchList.first],
              ),
            ),
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
              MaterialPageRoute(builder: (_) => const HomeScreen(mode: 'SEARCH')),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with decorative leaf illustration
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text — takes remaining space
                Expanded(
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
                // Leaf cluster — fixed 100px column, overflow allowed
                SizedBox(
                  width: 100,
                  height: 130,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        right: -8,
                        top: -16,
                        child: Transform.rotate(
                          angle: 0.18,
                          child: SvgPicture.string(_svgLeafTall, width: 58),
                        ),
                      ),
                      Positioned(
                        right: 36,
                        top: -4,
                        child: Transform.rotate(
                          angle: -0.35,
                          child: SvgPicture.string(_svgLeafTall, width: 44),
                        ),
                      ),
                      Positioned(
                        right: -10,
                        top: 36,
                        child: Transform.rotate(
                          angle: 1.2,
                          child: SvgPicture.string(_svgLeafFrond, width: 66),
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 52,
                        child: Transform.rotate(
                          angle: -0.1,
                          child: SvgPicture.string(_svgLeafWide, width: 74),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const HomeScreen(mode: 'POPULARITY')),
                        ),
                      ),
                      _menuCardGrid(
                        context,
                        title: 'My Collections',
                        subtitle: 'Your custom word lists',
                        color: const Color(0xFFF5E4CC),
                        titleColor: const Color(0xFF5A3A18),
                        icon: Icons.bookmark_rounded,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CollectionsScreen()),
                        ),
                      ),
                      _menuCardGrid(
                        context,
                        title: 'History',
                        subtitle: 'Words via notifications',
                        color: const Color(0xFFE8D4C8),
                        titleColor: const Color(0xFF5A3028),
                        icon: Icons.history_rounded,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const HomeScreen(mode: 'HISTORY')),
                        ),
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
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const TopicScreen()),
                          ),
                        ),
                        _menuCardGrid(
                          context,
                          title: 'Known Words',
                          subtitle: 'Review words you already know',
                          color: const Color(0xFFF5C4B8),
                          titleColor: const Color(0xFF5A2818),
                          icon: Icons.check_circle_rounded,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const HomeScreen(mode: 'KNOWN')),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
