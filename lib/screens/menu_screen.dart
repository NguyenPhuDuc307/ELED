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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ELED.',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 40,
              ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              color: context.bBorder,
              size: 32,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.search,
              color: context.bBorder,
              size: 32,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(mode: 'SEARCH'),
                ),
              );
            },
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'LEARNING MODE',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 28,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              BrutalistCard(
                backgroundColor: BrutalistTheme.primary,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const HomeScreen(mode: 'POPULARITY'),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'POPULARITY',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: BrutalistTheme.black,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Học từ theo cấp độ A1 → C1',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: BrutalistTheme.black.withValues(alpha: 0.7),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              BrutalistCard(
                backgroundColor: BrutalistTheme.accent,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TopicScreen(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOPICS',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: BrutalistTheme.black,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Học theo chủ đề: động vật, du lịch…',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: BrutalistTheme.black.withValues(alpha: 0.7),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              BrutalistCard(
                backgroundColor: context.bBorder,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CollectionsScreen(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MY COLLECTIONS',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: context.bBg,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Danh sách từ vựng tự tạo',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: context.bBg.withValues(alpha: 0.7),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              BrutalistCard(
                backgroundColor: BrutalistTheme.secondary,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const HomeScreen(mode: 'KNOWN'),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KNOWN WORDS',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: BrutalistTheme.black,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ôn lại những từ đã thuộc',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: BrutalistTheme.black.withValues(alpha: 0.7),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              BrutalistCard(
                backgroundColor: context.bBg,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const HomeScreen(mode: 'HISTORY'),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HISTORY',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: context.bBorder,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Từ đã nhận qua thông báo',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: context.bBorder.withValues(alpha: 0.7),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
