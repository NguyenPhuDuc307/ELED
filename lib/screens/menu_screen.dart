import 'package:flutter/material.dart';
import '../theme/brutalist_theme.dart';
import '../widgets/brutalist_card.dart';
import 'home_screen.dart';
import 'topic_screen.dart';
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
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Text(
                      'POPULARITY\n(A1 - C1)',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: BrutalistTheme.black,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
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
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Text(
                      'TOPICS\n(BY CATEGORY)',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: BrutalistTheme.black,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
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
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Text(
                      'KNOWN WORDS',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: BrutalistTheme.black,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
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
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Text(
                      'NOTIFICATIONS\nHISTORY',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: context.bBorder,
                          ),
                      textAlign: TextAlign.center,
                    ),
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
