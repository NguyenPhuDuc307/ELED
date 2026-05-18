import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/gen/app_localizations.dart';
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

  static const _pageMeta = <_OnboardPageMeta>[
    _OnboardPageMeta(
      icon: Icons.school_rounded,
      accent: BrutalistTheme.primary,
      accentLight: BrutalistTheme.primaryLight,
    ),
    _OnboardPageMeta(
      icon: Icons.bolt_rounded,
      accent: BrutalistTheme.primary,
      accentLight: BrutalistTheme.primaryLight,
    ),
    _OnboardPageMeta(
      icon: Icons.tune_rounded,
      accent: BrutalistTheme.accent,
      accentLight: BrutalistTheme.accentLight,
    ),
    _OnboardPageMeta(
      icon: Icons.extension_rounded,
      accent: BrutalistTheme.secondary,
      accentLight: BrutalistTheme.secondaryLight,
    ),
  ];

  bool get _isLast => _index == _pageMeta.length - 1;

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

  String _titleFor(AppLocalizations t, int i) {
    switch (i) {
      case 0:
        return t.onboarding1Title;
      case 1:
        return t.onboarding2Title;
      case 2:
        return t.onboarding3Title;
      default:
        return t.onboarding4Title;
    }
  }

  String _bodyFor(AppLocalizations t, int i) {
    switch (i) {
      case 0:
        return t.onboarding1Body;
      case 1:
        return t.onboarding2Body;
      case 2:
        return t.onboarding3Body;
      default:
        return t.onboarding4Body;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
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
                    t.appTitle,
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
                        t.onboardingSkip,
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
                itemCount: _pageMeta.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => _OnboardPageView(
                  meta: _pageMeta[i],
                  title: _titleFor(t, i),
                  body: _bodyFor(t, i),
                ),
              ),
            ),
            _buildDots(),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: _isLast
                  ? _primaryButton(t.onboardingGetStarted, _finish)
                  : _primaryButton(t.onboardingNext, () {
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
      children: List.generate(_pageMeta.length, (i) {
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

class _OnboardPageMeta {
  final IconData icon;
  final Color accent;
  final Color accentLight;

  const _OnboardPageMeta({
    required this.icon,
    required this.accent,
    required this.accentLight,
  });
}

class _OnboardPageView extends StatelessWidget {
  final _OnboardPageMeta meta;
  final String title;
  final String body;
  const _OnboardPageView({
    required this.meta,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: BrutalistCard(
              backgroundColor: meta.accentLight,
              child: Padding(
                padding: const EdgeInsets.all(36),
                child: Icon(meta.icon, size: 80, color: meta.accent),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            title,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Text(
            body,
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
