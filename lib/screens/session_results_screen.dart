import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import '../models/word_state.dart';
import '../services/streak_service.dart';
import '../theme/brutalist_theme.dart';
import '../widgets/brutalist_card.dart';

/// Shown right after a session finishes. Gives the user closure — they
/// see what they did, the streak count, and a single primary action to
/// either head back to Today or run another round. Without this, sessions
/// just fade silently into a list screen, which is the #1 reason habit
/// apps fail at retention.
class SessionResultsScreen extends StatefulWidget {
  /// Ratings the user submitted, in card order. Length == cards reviewed.
  final List<ReviewRating> ratings;

  /// Whether anything else is still due after this session — drives the
  /// secondary CTA copy ("Another session" vs "Back to Today").
  final bool moreDue;

  /// Optional callback to start a fresh session from the same place this
  /// screen was launched from. If null, that button is hidden.
  final VoidCallback? onAnotherSession;

  const SessionResultsScreen({
    super.key,
    required this.ratings,
    required this.moreDue,
    this.onAnotherSession,
  });

  @override
  State<SessionResultsScreen> createState() => _SessionResultsScreenState();
}

class _SessionResultsScreenState extends State<SessionResultsScreen> {
  int _streakBefore = 0;
  int _streakAfter = 0;

  @override
  void initState() {
    super.initState();
    _bumpStreak();
  }

  Future<void> _bumpStreak() async {
    if (widget.ratings.isEmpty) {
      setState(() {
        _streakBefore = StreakService().current;
        _streakAfter = _streakBefore;
      });
      return;
    }
    final before = StreakService().current;
    await StreakService().recordActivity();
    if (!mounted) return;
    setState(() {
      _streakBefore = before;
      _streakAfter = StreakService().current;
    });
  }

  int get _correct => widget.ratings
      .where((r) => r == ReviewRating.good || r == ReviewRating.easy)
      .length;

  int get _struggled => widget.ratings
      .where((r) => r == ReviewRating.again || r == ReviewRating.hard)
      .length;

  String _headlineFor(AppLocalizations t) {
    if (widget.ratings.isEmpty) return t.resultsHeadlineEnded;
    final pct = (_correct / widget.ratings.length * 100).round();
    if (pct >= 90) return t.resultsHeadlineOutstanding;
    if (pct >= 70) return t.resultsHeadlineNice;
    if (pct >= 40) return t.resultsHeadlineKeepGoing;
    return t.resultsHeadlineTough;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final newStreak = _streakAfter > _streakBefore;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: BrutalistTheme.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.celebration_rounded,
                            size: 44,
                            color: BrutalistTheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _headlineFor(t),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.ratings.isEmpty
                            ? t.resultsNoCardsRated
                            : widget.ratings.length == 1
                                ? t.resultsReviewedSingular(widget.ratings.length)
                                : t.resultsReviewedPlural(widget.ratings.length),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: context.bMuted,
                            ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(child: _statTile(
                            label: t.resultsCorrect,
                            value: _correct,
                            icon: Icons.check_circle_rounded,
                            tone: BrutalistTheme.primary,
                            toneLight: BrutalistTheme.primaryLight,
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: _statTile(
                            label: t.resultsStruggled,
                            value: _struggled,
                            icon: Icons.refresh_rounded,
                            tone: const Color(0xFFE5874E),
                            toneLight: const Color(0xFFFCEFE0),
                          )),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _streakCard(t, highlight: newStreak),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (widget.onAnotherSession != null && widget.moreDue) ...[
                _secondaryButton(
                  label: t.resultsAnotherSession,
                  onTap: () {
                    Navigator.of(context).pop();
                    widget.onAnotherSession?.call();
                  },
                ),
                const SizedBox(height: 10),
              ],
              _primaryButton(
                label: t.resultsBackToToday,
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statTile({
    required String label,
    required int value,
    required IconData icon,
    required Color tone,
    required Color toneLight,
  }) {
    return BrutalistCard(
      backgroundColor: context.bBg,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: toneLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: tone, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              '$value',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 28,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.bMuted,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _streakCard(AppLocalizations t, {required bool highlight}) {
    return BrutalistCard(
      backgroundColor: highlight ? BrutalistTheme.accent : context.bBg,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: highlight
                    ? BrutalistTheme.white.withValues(alpha: 0.18)
                    : BrutalistTheme.accentLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.local_fire_department_rounded,
                color: highlight ? BrutalistTheme.white : BrutalistTheme.accent,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    highlight ? t.resultsStreakExtended : t.resultsStreak,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: highlight
                              ? BrutalistTheme.white.withValues(alpha: 0.85)
                              : context.bMuted,
                          fontSize: 12,
                          letterSpacing: 0.3,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _streakAfter == 1
                        ? t.resultsStreakDaysSingular(_streakAfter)
                        : t.resultsStreakDaysPlural(_streakAfter),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          color: highlight ? BrutalistTheme.white : null,
                        ),
                  ),
                ],
              ),
            ),
            if (highlight)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: BrutalistTheme.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '+1',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: BrutalistTheme.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _primaryButton({required String label, required VoidCallback onTap}) {
    return Material(
      color: BrutalistTheme.primary,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
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

  Widget _secondaryButton({required String label, required VoidCallback onTap}) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: BrutalistTheme.primary,
        side: const BorderSide(color: BrutalistTheme.primary, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    );
  }
}
