import 'package:flutter/material.dart';
import '../l10n/gen/app_localizations.dart';
import '../theme/brutalist_theme.dart';
import '../widgets/brutalist_card.dart';
import 'home_screen.dart';
import 'topic_screen.dart';
import 'collections_screen.dart';
import 'settings_screen.dart';
import 'learning_screen.dart';
import '../services/collection_service.dart';
import '../services/csv_service.dart';
import '../services/learning_state_service.dart';
import '../services/user_data_service.dart';
import '../main.dart';


class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  bool _isNavigating = false;

  LearningContext? _continueCtx;
  bool _continueReady = false;

  // Counts surfaced on each menu card. -1 = not loaded yet (don't render).
  int _popularityCount = -1;
  int _topicsCount = -1;
  int _collectionsCount = -1;
  int _knownCount = -1;

  Future<void> _navigate(Widget page) async {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);
    await Navigator.of(context).push(smoothRoute(page));
    if (mounted) {
      setState(() => _isNavigating = false);
      _refreshQuickAccess(); // continue context may have changed while away
      _refreshCounts(); // collection/known/history may have changed too
    }
  }

  Future<void> _refreshQuickAccess() async {
    final ctx = await LearningStateService().loadContext();
    if (!mounted) return;
    setState(() {
      _continueCtx = ctx;
      _continueReady = true;
    });
  }

  Future<void> _refreshCounts() async {
    // These run in parallel — none of them depend on each other.
    final results = await Future.wait([
      CsvService.loadAllVocabulary(excludeKnown: false),
      CsvService.getAvailableTopics(),
      CollectionService.getCollections(),
    ]);
    if (!mounted) return;
    final vocab = results[0] as List;
    final topics = results[1] as List;
    final collections = results[2] as Map;
    setState(() {
      _popularityCount = vocab.length;
      _topicsCount = topics.length;
      _collectionsCount = collections.length;
      _knownCount = UserDataService().knownWords.length;
    });
  }

  Future<void> _resumeContinue() async {
    final ctx = _continueCtx;
    if (ctx == null) return;
    setState(() => _isNavigating = true);
    final vocab = await LearningStateService().hydrateContext(ctx);
    if (!mounted) {
      return;
    }
    setState(() => _isNavigating = false);
    if (vocab == null || vocab.isEmpty) {
      final t = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.menuCouldNotResume),
          duration: const Duration(seconds: 3),
        ),
      );
      await LearningStateService().clearContext();
      _refreshQuickAccess();
      return;
    }
    await Navigator.of(context).push(smoothRoute(LearningScreen(
      day: ctx.day,
      vocabularies: vocab,
      initialIndex: ctx.currentIndex.clamp(0, vocab.length - 1),
    )));
    if (mounted) _refreshQuickAccess();
  }

  @override
  void initState() {
    super.initState();
    _refreshQuickAccess();
    _refreshCounts();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Handle "Known" action from notification when app was not in foreground
      if (pendingMarkKnownWord != null) {
        final word = pendingMarkKnownWord!;
        pendingMarkKnownWord = null;
        if (mounted) {
          final t = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.menuMarkedKnownToast(word.toLowerCase())),
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

  /// Top-of-menu shortcuts: pick up where the user left off, plus a one-tap
  /// review of words they've already marked as known.
  Widget _buildQuickAccess(AppLocalizations t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: _continueTile(t, _continueCtx!),
    );
  }

  Widget _continueTile(AppLocalizations t, LearningContext ctx) {
    final progress = ctx.totalCount == 0 ? 0.0 : (ctx.currentIndex + 1) / ctx.totalCount;
    return BrutalistCard(
      backgroundColor: BrutalistTheme.primary,
      onTap: _resumeContinue,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: BrutalistTheme.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: BrutalistTheme.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.menuContinueLearning,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: BrutalistTheme.white.withValues(alpha: 0.85),
                              fontSize: 12,
                              letterSpacing: 0.3)),
                      const SizedBox(height: 2),
                      Text(
                        t.menuContinueProgress(ctx.localizedLabel(t), ctx.currentIndex + 1, ctx.totalCount),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: BrutalistTheme.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: BrutalistTheme.white.withValues(alpha: 0.85)),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 5,
                backgroundColor: BrutalistTheme.white.withValues(alpha: 0.22),
                valueColor: const AlwaysStoppedAnimation(BrutalistTheme.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuCardGrid(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color color,
    required Color titleColor,
    required IconData icon,
    required VoidCallback onTap,
    int? count, // -1 / null = don't render a chip
    double extraBottomPad = 20,
  }) {
    final showCount = count != null && count >= 0;
    return BrutalistCard(
      backgroundColor: color,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.fromLTRB(18, 20, 18, extraBottomPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                if (showCount)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: titleColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _formatCount(count),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                            fontSize: 11,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                    ),
                  ),
              ],
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

  /// Compact number formatter — keeps the count chip narrow on small cards.
  /// 1234 → "1,234", 12345 → "12.3k".
  String _formatCount(int n) {
    if (n < 1000) return '$n';
    if (n < 10000) {
      final thousands = n ~/ 1000;
      final hundreds = (n % 1000) ~/ 100;
      return hundreds == 0 ? '${thousands}k' : '$thousands.${hundreds}k';
    }
    return '${(n / 1000).round()}k';
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final canPop = Navigator.canPop(context);
    return Scaffold(
      appBar: AppBar(
        // When pushed from Today this screen is a sub-screen — show an explicit
        // back arrow and the "Browse" label so the user always knows they can
        // return. When opened as the root (legacy entry) keep the ELED title.
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: canPop
            ? Text(t.menuTitle)
            : Text(
                t.appTitle,
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
              smoothRoute(const HomeScreen(mode: 'SEARCH')),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Navigator.of(context).push(
              smoothRoute(const SettingsScreen()),
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
                        t.menuChooseModeLabel,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: context.bMuted,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        t.menuChooseModeQuestion,
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 26,
                              height: 1.25,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (_continueReady && _continueCtx != null) _buildQuickAccess(t),
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
                        title: t.menuCardPopularityTitle,
                        subtitle: t.menuCardPopularitySubtitle,
                        color: const Color(0xFFC8DEC4),
                        titleColor: const Color(0xFF2A4A28),
                        icon: Icons.trending_up_rounded,
                        count: _popularityCount,
                        extraBottomPad: 36,
                        onTap: () => _navigate(const HomeScreen(mode: 'POPULARITY')),
                      ),
                      _menuCardGrid(
                        context,
                        title: t.menuCardCollectionsTitle,
                        subtitle: t.menuCardCollectionsSubtitle,
                        color: const Color(0xFFF5E4CC),
                        titleColor: const Color(0xFF5A3A18),
                        icon: Icons.bookmark_rounded,
                        count: _collectionsCount,
                        onTap: () => _navigate(const CollectionsScreen()),
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
                          title: t.menuCardTopicsTitle,
                          subtitle: t.menuCardTopicsSubtitle,
                          color: const Color(0xFFF5D5CC),
                          titleColor: const Color(0xFF5A2820),
                          icon: Icons.category_rounded,
                          count: _topicsCount,
                          extraBottomPad: 36,
                          onTap: () => _navigate(const TopicScreen()),
                        ),
                        _menuCardGrid(
                          context,
                          title: t.menuCardKnownTitle,
                          subtitle: t.menuCardKnownSubtitle,
                          color: const Color(0xFFF5C4B8),
                          titleColor: const Color(0xFF5A2818),
                          icon: Icons.check_circle_rounded,
                          count: _knownCount,
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
