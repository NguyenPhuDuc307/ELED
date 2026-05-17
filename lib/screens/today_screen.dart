import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/vocabulary.dart';
import '../models/word_state.dart';
import '../services/srs_service.dart';
import '../services/streak_service.dart';
import '../theme/brutalist_theme.dart';
import '../widgets/brutalist_card.dart';
import 'home_screen.dart';
import 'learning_screen.dart';
import 'match_game_screen.dart';
import 'menu_screen.dart';
import 'settings_screen.dart';

/// New primary entry point — replaces the old "browse 5 mode cards then pick a
/// Day" funnel. Shows the user a single ready-to-go session built from cards
/// due for review plus a small dose of new words.
class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  bool _loading = true;
  int _dueCount = 0;
  int _freshAvailable = 0;
  int _knownCount = 0;
  List<Vocabulary> _session = const [];
  StreamSubscription<void>? _srsSub;
  StreamSubscription<void>? _streakSub;
  int _streak = 0;
  Set<String> _activeDays = const {};

  @override
  void initState() {
    super.initState();
    _refresh(initial: true);
    // SrsService.changes fires after every single rating. Re-running a full
    // session rebuild + masking the screen with a spinner every time made the
    // loading indicator look frozen on slow devices. We refresh quietly now.
    _srsSub = SrsService().changes.listen((_) => _refresh(initial: false));
    _streakSub = StreakService().changes.listen((_) => _refreshStreak());
  }

  @override
  void dispose() {
    _srsSub?.cancel();
    _streakSub?.cancel();
    super.dispose();
  }

  void _refreshStreak() {
    if (!mounted) return;
    setState(() {
      _streak = StreakService().current;
      _activeDays = StreakService().activeDays;
    });
  }

  Future<void> _refresh({bool initial = false}) async {
    // Only mask the screen on the cold load. Subsequent refreshes update in
    // place so the user doesn't see a half-rotated spinner each time SRS
    // changes fire.
    if (initial && _loading == false) {
      setState(() => _loading = true);
    } else if (initial) {
      // already loading on first frame — leave it
    }
    final srs = SrsService();
    await srs.ready;
    // Yield once so the spinner can paint a frame before we start synchronous
    // map-building over the entire vocab pool.
    await Future<void>.delayed(Duration.zero);
    final prefs = await SharedPreferences.getInstance();
    final levels = prefs.getStringList('selectedPopularity') ?? ['A1', 'A2', 'B1'];
    final session = await srs.buildTodaySession(levelFilter: levels);
    final fresh = await srs.freshPool(levelFilter: levels, limit: 200);
    if (!mounted) return;
    setState(() {
      _dueCount = srs.dueCount();
      _freshAvailable = fresh.length;
      _knownCount = srs.all
          .where((s) =>
              s.stage == SrsStage.reviewing || s.stage == SrsStage.mastered)
          .length;
      _session = session;
      _streak = StreakService().current;
      _activeDays = StreakService().activeDays;
      _loading = false;
    });
  }

  Future<void> _startSession() async {
    if (_session.isEmpty) return;
    await Navigator.of(context).push(smoothRoute(LearningScreen(
      day: 0,
      vocabularies: _session,
    )));
    _refresh();
  }

  Future<void> _startMatchGame() async {
    if (_session.length < 4) return;
    await Navigator.of(context).push(smoothRoute(MatchGameScreen(
      pool: _session,
    )));
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ELED',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: BrutalistTheme.primary,
              ),
        ),
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search_rounded),
            onPressed: () => Navigator.of(context)
                .push(smoothRoute(const HomeScreen(mode: 'SEARCH'))),
          ),
          IconButton(
            tooltip: 'Browse',
            icon: const Icon(Icons.apps_rounded),
            onPressed: () => Navigator.of(context)
                .push(smoothRoute(const MenuScreen())),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Navigator.of(context)
                .push(smoothRoute(const SettingsScreen())),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                color: context.bBorder,
                strokeWidth: 5,
              ))
          : RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  _heading(),
                  const SizedBox(height: 20),
                  _sessionCard(),
                  if (_session.length >= 4) ...[
                    const SizedBox(height: 10),
                    _matchGameCta(),
                  ],
                  const SizedBox(height: 16),
                  _statsRow(),
                  if (_streak > 0 || _activeDays.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _streakHeatmapCard(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _heading() {
    final now = DateTime.now();
    final dateLabel = _weekdayLabel(now.weekday);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dateLabel,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.bMuted,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Today',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 36,
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }

  Widget _sessionCard() {
    final total = _session.length;
    final freshInSession = total - _dueCount.clamp(0, total);
    if (total == 0) {
      return _emptyCard();
    }
    return BrutalistCard(
      backgroundColor: BrutalistTheme.primary,
      onTap: _startSession,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: BrutalistTheme.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.bolt_rounded,
                      color: BrutalistTheme.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today\'s session',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color:
                                  BrutalistTheme.white.withValues(alpha: 0.85),
                              fontSize: 13,
                              letterSpacing: 0.3,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$total ${total == 1 ? "word" : "words"}',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: BrutalistTheme.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _pill('${_dueCount.clamp(0, total)} review',
                    BrutalistTheme.white.withValues(alpha: 0.22)),
                const SizedBox(width: 8),
                if (freshInSession > 0)
                  _pill('$freshInSession new',
                      BrutalistTheme.white.withValues(alpha: 0.22)),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: BrutalistTheme.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.play_arrow_rounded,
                            color: BrutalistTheme.primary, size: 22),
                        const SizedBox(width: 6),
                        Text(
                          'Start session',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                color: BrutalistTheme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
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

  Widget _emptyCard() {
    return BrutalistCard(
      backgroundColor: BrutalistTheme.primaryLight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          children: [
            const Icon(Icons.check_circle_outline_rounded,
                color: BrutalistTheme.primary, size: 40),
            const SizedBox(height: 12),
            Text(
              'All caught up',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: BrutalistTheme.primary,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              "No reviews are due right now. Browse a topic or check back later.",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: BrutalistTheme.primary.withValues(alpha: 0.75)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String text, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: BrutalistTheme.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
      ),
    );
  }

  Widget _statsRow() {
    return Row(
      children: [
        Expanded(child: _statCard('Known', _knownCount, Icons.check_rounded)),
        const SizedBox(width: 12),
        Expanded(child: _statCard('To learn', _freshAvailable, Icons.add_rounded)),
      ],
    );
  }

  /// Secondary action next to the main "Start session" — same pool, but
  /// played as a 4-pair matching mini-game instead of a flashcard rotation.
  /// Hidden when fewer than 4 cards are queued (not enough to fill the grid).
  Widget _matchGameCta() {
    return BrutalistCard(
      backgroundColor: BrutalistTheme.accentLight,
      onTap: _startMatchGame,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: BrutalistTheme.accent.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.extension_rounded,
                  color: BrutalistTheme.accent, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Match game',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: BrutalistTheme.accent,
                          fontSize: 15)),
                  Text('Pair 4 words with their meanings',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: BrutalistTheme.accent.withValues(alpha: 0.75),
                          fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: BrutalistTheme.accent.withValues(alpha: 0.7)),
          ],
        ),
      ),
    );
  }

  /// 28-day calendar heatmap (4 weeks). A flame icon + current streak count
  /// anchor the card; the grid shows which days the user was active so
  /// momentum becomes visible.
  Widget _streakHeatmapCard() {
    final today = DateTime.now();
    // Build last 28 day keys, oldest first, grouped into 4 rows of 7.
    final cells = <DateTime>[];
    for (int i = 27; i >= 0; i--) {
      cells.add(today.subtract(Duration(days: i)));
    }
    return BrutalistCard(
      backgroundColor: context.bBg,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: BrutalistTheme.accentLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.local_fire_department_rounded,
                      color: BrutalistTheme.accent, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Streak',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: context.bMuted,
                                fontSize: 12,
                                letterSpacing: 0.3,
                              )),
                      Text(
                        _streak == 0
                            ? 'Start one today'
                            : '$_streak ${_streak == 1 ? "day" : "days"}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(builder: (context, c) {
              final cell = ((c.maxWidth - 6 * 6) / 7).clamp(14.0, 28.0);
              return Column(
                children: List.generate(4, (row) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: row == 3 ? 0 : 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (col) {
                        final dt = cells[row * 7 + col];
                        final key = StreakService.dateKeyFor(dt);
                        final active = _activeDays.contains(key);
                        final isToday = _sameDay(dt, today);
                        return _heatmapCell(cell, active, isToday);
                      }),
                    ),
                  );
                }),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _heatmapCell(double size, bool active, bool isToday) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: active
            ? BrutalistTheme.primary
            : BrutalistTheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(5),
        border: isToday
            ? Border.all(color: BrutalistTheme.accent, width: 1.5)
            : null,
      ),
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _statCard(String label, int value, IconData icon) {
    return BrutalistCard(
      backgroundColor: context.bBg,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: BrutalistTheme.accentLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: BrutalistTheme.accent, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$value',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                        ),
                  ),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.bMuted,
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _weekdayLabel(int weekday) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    final dayName = days[weekday - 1];
    final dt = DateTime.now();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '$dayName, ${months[dt.month - 1]} ${dt.day}';
  }
}
