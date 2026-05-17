import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/log.dart';
import 'analytics_service.dart';

/// Asks the OS to show its in-app review prompt at carefully chosen moments.
///
/// Rules:
/// - First trigger is only attempted once the user has marked at least
///   [_minKnownWords] words as known — this filters out users who never engaged.
/// - We re-attempt at most once every [_cooldownDays] days.
/// - Both Apple and Google rate-limit the prompt; even when we call it, the
///   OS may silently no-op (e.g. the user has dismissed it recently). That's
///   fine — we still respect our own cooldown.
class ReviewService {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  static const _kLastPromptKey = 'reviewPromptLastMs';
  static const _kMilestoneKey = 'reviewMilestoneReached';
  static const _minKnownWords = 25;
  static const _cooldownDays = 60;

  final _impl = InAppReview.instance;

  /// Call after [knownCount] increments. Triggers the OS review prompt the
  /// first time the user crosses [_minKnownWords] and then once every
  /// [_cooldownDays] thereafter if they keep adding words.
  Future<void> maybePromptAfterMilestone(int knownCount) async {
    if (knownCount < _minKnownWords) return;
    final prefs = await SharedPreferences.getInstance();

    final lastMs = prefs.getInt(_kLastPromptKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final cooldownMs = _cooldownDays * 24 * 60 * 60 * 1000;
    if (lastMs > 0 && (now - lastMs) < cooldownMs) return;

    // Only one prompt per milestone crossing — avoids spamming within one day.
    final lastMilestone = prefs.getInt(_kMilestoneKey) ?? 0;
    final currentMilestone = knownCount ~/ _minKnownWords;
    if (currentMilestone <= lastMilestone) return;

    try {
      if (!await _impl.isAvailable()) return;
      await _impl.requestReview();
      await prefs.setInt(_kLastPromptKey, now);
      await prefs.setInt(_kMilestoneKey, currentMilestone);
      AnalyticsService().logEvent('review_prompt_shown', {
        'known_count': knownCount,
        'milestone': currentMilestone,
      });
    } catch (e, st) {
      logCaught(e, st, 'ReviewService.maybePromptAfterMilestone');
    }
  }

  /// Manual entry point from the Settings screen — sends the user to the
  /// store listing where they can leave a real review.
  Future<void> openStoreListing() async {
    try {
      await _impl.openStoreListing();
    } catch (e, st) {
      logCaught(e, st, 'ReviewService.openStoreListing');
    }
  }
}
