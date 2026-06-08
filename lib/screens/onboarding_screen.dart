import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/gen/app_localizations.dart';
import '../services/notification_service.dart';
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
    _OnboardPageMeta(
      icon: Icons.notifications_active_rounded,
      accent: BrutalistTheme.primary,
      accentLight: BrutalistTheme.primaryLight,
    ),
  ];

  bool get _isLast => _index == _pageMeta.length - 1;

  bool _enabling = false;
  bool _notifEnabled = false;

  Future<void> _enableNotifications() async {
    if (_notifEnabled || _enabling) return;
    setState(() => _enabling = true);
    try {
      await NotificationService().requestPermissions();
      final prefs = await SharedPreferences.getInstance();
      const interval = 30;
      await prefs.setInt('notificationIntervalMinutes', interval);
      await prefs.setInt('notificationWordsPerBundle', 1);
      await prefs.setInt('notificationStartHour', 9);
      await prefs.setInt('notificationStartMinute', 0);
      await prefs.setInt('notificationEndHour', 19);
      await prefs.setInt('notificationEndMinute', 0);

      final popularity = prefs.getStringList('selectedPopularity') ??
          const ['A1', 'A2', 'B1', 'B2', 'C1'];
      final topics = prefs.getStringList('selectedTopics') ?? const <String>[];
      final pool = await NotificationService.loadPool(
        popularity: popularity,
        topics: topics,
      );
      await NotificationService().scheduleVocabularyNotifications(
        pool: pool,
        intervalMinutes: interval,
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 19, minute: 0),
        wordsPerBundle: 1,
      );
      if (mounted) setState(() => _notifEnabled = true);
    } catch (_) {
      // Best-effort — user can still enable from Settings later.
    } finally {
      if (mounted) setState(() => _enabling = false);
    }
  }

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
      case 3:
        return t.onboarding4Title;
      default:
        return t.onboarding5Title;
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
      case 3:
        return t.onboarding4Body;
      default:
        return t.onboarding5Body;
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
                itemBuilder: (_, i) {
                  if (i == _pageMeta.length - 1) {
                    return _OnboardNotificationsPageView(
                      meta: _pageMeta[i],
                      title: _titleFor(t, i),
                      body: _bodyFor(t, i),
                      enabled: _notifEnabled,
                      busy: _enabling,
                      onEnable: _enableNotifications,
                    );
                  }
                  return _OnboardPageView(
                    meta: _pageMeta[i],
                    title: _titleFor(t, i),
                    body: _bodyFor(t, i),
                  );
                },
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

/// Last onboarding page — same layout as [_OnboardPageView] plus a one-tap
/// button that turns reminders on (requests permission + schedules) right away.
class _OnboardNotificationsPageView extends StatelessWidget {
  final _OnboardPageMeta meta;
  final String title;
  final String body;
  final bool enabled;
  final bool busy;
  final VoidCallback onEnable;
  const _OnboardNotificationsPageView({
    required this.meta,
    required this.title,
    required this.body,
    required this.enabled,
    required this.busy,
    required this.onEnable,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
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
          const SizedBox(height: 24),
          _enableButton(context, t),
        ],
      ),
    );
  }

  Widget _enableButton(BuildContext context, AppLocalizations t) {
    if (enabled) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: meta.accentLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: meta.accent, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded, color: meta.accent, size: 22),
            const SizedBox(width: 8),
            Text(
              t.onboardingNotificationsEnabled,
              style: TextStyle(
                color: meta.accent,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }
    return Material(
      color: meta.accent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: busy ? null : onEnable,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          child: busy
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: BrutalistTheme.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.notifications_active_rounded,
                        color: BrutalistTheme.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      t.onboardingEnableNotifications,
                      style: const TextStyle(
                        color: BrutalistTheme.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
