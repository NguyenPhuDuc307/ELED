import 'package:flutter/material.dart';

import '../theme/brutalist_theme.dart';

/// Reference doc the user can revisit after the first-launch onboarding.
/// Categorised expansion tiles instead of long prose so they can scan to the
/// concept they're stuck on.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _topics = <_HelpTopic>[
    _HelpTopic(
      icon: Icons.school_rounded,
      title: 'How learning works',
      body:
          "ELED uses spaced repetition. Every time you rate a word, the app computes when you're most likely "
          "to forget it, and surfaces it again right before that — so you spend time only on what's about to "
          "slip away, not on words you've already nailed.",
    ),
    _HelpTopic(
      icon: Icons.bolt_rounded,
      title: 'What is Today\'s session?',
      body:
          "The big card on the home screen is your queue for the day. It contains:\n"
          "• Words due for review (their interval has expired)\n"
          "• A few brand-new words to keep growing your vocabulary\n\n"
          "Sessions cap around 20 words. Tap Start session to begin.",
    ),
    _HelpTopic(
      icon: Icons.tune_rounded,
      title: 'The four rating buttons',
      body:
          "After every flashcard you rate how it went. The app uses that rating to schedule the word's "
          "next appearance:\n\n"
          "• Again — \"I forgot\". Comes back tomorrow.\n"
          "• Hard — \"I knew it, but barely\". Slightly shorter interval than last time.\n"
          "• Good — \"I knew it\". Standard schedule (each Good multiplies the interval).\n"
          "• Easy — \"Way too easy\". Pushes the word out further so you don't waste time on it.",
    ),
    _HelpTopic(
      icon: Icons.extension_rounded,
      title: 'Exercise types',
      body:
          "While a word is new or you're still figuring it out, sessions mix four exercise styles to keep "
          "your brain engaged:\n\n"
          "• Recognize — classic flashcard with the four rating buttons.\n"
          "• Multiple choice — pick the right translation from 4 options.\n"
          "• Listen and type — hear the word, type it back. Lenient spelling.\n"
          "• Fill in context — a real Oxford sentence with the word blanked out.\n\n"
          "Once you've shown you know a word, sessions ease off to the gentle Recognize card. No more "
          "guessing puzzles on words you've already mastered.",
    ),
    _HelpTopic(
      icon: Icons.casino_rounded,
      title: 'The match game',
      body:
          "A 4-pair tap-to-match mini game, shown below Start session when you have at least 4 new or "
          "learning words queued. Tap a word, then its translation; correct pairs fade green, wrong picks "
          "flash red. Your accuracy auto-rates each word in the same SRS schedule as the main flow.",
    ),
    _HelpTopic(
      icon: Icons.archive_outlined,
      title: 'Skip a word forever',
      body:
          "On a Recognize card, tap the archive ⓘ icon at the top-right corner. Confirm Skip and the word "
          "is marked as mastered with a year-long interval — useful for words you imported as \"known\" "
          "but really don't need to study.",
    ),
    _HelpTopic(
      icon: Icons.local_fire_department_rounded,
      title: 'Streak & active days',
      body:
          "Each day you rate at least one card counts toward your streak. The 28-day heatmap on Today "
          "shows which of the last four weeks you practised. Miss one day and the streak survives; miss "
          "two and it resets to 0.",
    ),
    _HelpTopic(
      icon: Icons.notifications_active_rounded,
      title: 'Notifications',
      body:
          "Settings → Notifications lets you choose how often a vocabulary reminder fires and your active "
          "hours. The reminders pick words from your due queue first, so each tap is a real review — not "
          "a random word you already know.\n\n"
          "On some Android phones you'll need to allow background activity for ELED so the reminders "
          "keep firing past a day. The settings screen prompts you the first time.",
    ),
    _HelpTopic(
      icon: Icons.apps_rounded,
      title: 'Browse the dictionary',
      body:
          "The apps icon on Today opens Browse — the older mode-by-mode view. Useful when you want to "
          "look at all words at a specific level, or pull from a collection. The day grouping there is "
          "shuffled per level so it stays varied.",
    ),
    _HelpTopic(
      icon: Icons.search_rounded,
      title: 'Search',
      body:
          "The magnifier icon searches the entire vocabulary by word or translation. Use it for ad-hoc "
          "look-ups; tapping a result opens its full Recognize card with the audio, IPA, and definitions.",
    ),
    _HelpTopic(
      icon: Icons.cloud_sync_rounded,
      title: 'Backup & sync',
      body:
          "Settings → Account & data lets you Export your known words + collections to a JSON file via "
          "the system share sheet, and Import the same shape back. Sign in with Google to sync the "
          "knownWords + collections across devices automatically.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('How to use')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: _topics.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (_, i) => _topicTile(context, _topics[i]),
      ),
    );
  }

  Widget _topicTile(BuildContext context, _HelpTopic topic) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: context.bBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.bSubtle, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: BrutalistTheme.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(topic.icon, color: BrutalistTheme.primary, size: 20),
          ),
          title: Text(
            topic.title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
          ),
          children: [
            Text(
              topic.body,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.bBorder,
                    height: 1.5,
                    fontSize: 14,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpTopic {
  final IconData icon;
  final String title;
  final String body;
  const _HelpTopic({required this.icon, required this.title, required this.body});
}
