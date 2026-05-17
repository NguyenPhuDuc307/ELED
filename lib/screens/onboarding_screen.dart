import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/brutalist_theme.dart';
import '../widgets/brutalist_card.dart';

/// Shown once on first launch (gated by `onboardedV1` in SharedPreferences).
/// 4 swipeable pages explaining the core ideas the rest of the app assumes
/// the user already understands: spaced repetition, daily session, rating
/// buttons, and the variety of exercise types.
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onDone;

  const OnboardingScreen({super.key, required this.onDone});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _index = 0;

  static const _pages = <_OnboardPage>[
    _OnboardPage(
      icon: Icons.school_rounded,
      accent: BrutalistTheme.primary,
      accentLight: BrutalistTheme.primaryLight,
      title: 'Learn smarter, not harder',
      body:
          "ELED uses spaced repetition — you see each word again right before you'd forget it. "
          "Hundreds of words stick in your head with just a few minutes a day.",
    ),
    _OnboardPage(
      icon: Icons.bolt_rounded,
      accent: BrutalistTheme.primary,
      accentLight: BrutalistTheme.primaryLight,
      title: 'One session a day',
      body:
          "Each morning the app picks the words you're closest to forgetting plus a few new ones. "
          "Tap Start session — usually ~20 words, ~5 minutes.",
    ),
    _OnboardPage(
      icon: Icons.tune_rounded,
      accent: BrutalistTheme.accent,
      accentLight: BrutalistTheme.accentLight,
      title: 'Rate as you go',
      body:
          "After each card tell us how it went: Again / Hard / Good / Easy. We use your rating to "
          "decide when the word reappears — Easy disappears for a month, Again comes back tomorrow.",
    ),
    _OnboardPage(
      icon: Icons.extension_rounded,
      accent: BrutalistTheme.secondary,
      accentLight: BrutalistTheme.secondaryLight,
      title: 'Variety beats grind',
      body:
          "As you learn, sessions mix flashcards with multiple choice, listen-and-type, "
          "fill-in-context, and a 4-pair match game. Same vocabulary, fresh angle every time.",
    ),
  ];

  bool get _isLast => _index == _pages.length - 1;

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardedV1', true);
    widget.onDone();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ELED',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: BrutalistTheme.primary,
                        ),
                  ),
                  if (!_isLast)
                    TextButton(
                      onPressed: _finish,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: context.bMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => _OnboardPageView(page: _pages[i]),
              ),
            ),
            _buildDots(),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: _isLast
                  ? _primaryButton('Get started', _finish)
                  : _primaryButton('Next', () {
                      _pageCtrl.nextPage(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOut,
                      );
                    }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (i) {
        final active = i == _index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? BrutalistTheme.primary : context.bSubtle,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _primaryButton(String label, VoidCallback onTap) {
    return Material(
      color: BrutalistTheme.primary,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: BrutalistTheme.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
          ),
        ),
      ),
    );
  }
}

class _OnboardPage {
  final IconData icon;
  final Color accent;
  final Color accentLight;
  final String title;
  final String body;

  const _OnboardPage({
    required this.icon,
    required this.accent,
    required this.accentLight,
    required this.title,
    required this.body,
  });
}

class _OnboardPageView extends StatelessWidget {
  final _OnboardPage page;
  const _OnboardPageView({required this.page});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: BrutalistCard(
              backgroundColor: page.accentLight,
              child: Padding(
                padding: const EdgeInsets.all(36),
                child: Icon(page.icon, size: 80, color: page.accent),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            page.title,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Text(
            page.body,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: context.bMuted,
                  height: 1.5,
                  fontSize: 15,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
