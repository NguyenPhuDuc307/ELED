/// Spaced-repetition lifecycle stage for one vocabulary word.
enum SrsStage {
  /// User has never seen this word.
  fresh,

  /// Just introduced — interval still measured in days < 4.
  learning,

  /// In the long-tail review queue.
  reviewing,

  /// User rates this consistently easy — interval > 60 days.
  mastered,
}

extension SrsStageX on SrsStage {
  String get key => name;
  static SrsStage fromKey(String? raw) {
    switch (raw) {
      case 'fresh':
        return SrsStage.fresh;
      case 'learning':
        return SrsStage.learning;
      case 'reviewing':
        return SrsStage.reviewing;
      case 'mastered':
        return SrsStage.mastered;
      default:
        return SrsStage.fresh;
    }
  }
}

/// Persisted SM-2-lite state for a single word. Keyed by the lowercase word
/// itself (we don't have stable vocabulary IDs across all CSV sources).
class WordState {
  final String word;            // lowercase
  final SrsStage stage;
  final double easeFactor;      // 1.3 .. 3.0, starts at 2.5
  final int intervalDays;       // 0 for fresh
  final int repetitions;        // consecutive correct ratings
  final int dueAtMs;            // due timestamp (next review)
  final int lastReviewedMs;     // 0 if never
  final int totalSeen;          // total times the user rated this word
  final int totalLapses;        // times rated Again after Good/Easy

  const WordState({
    required this.word,
    required this.stage,
    required this.easeFactor,
    required this.intervalDays,
    required this.repetitions,
    required this.dueAtMs,
    required this.lastReviewedMs,
    required this.totalSeen,
    required this.totalLapses,
  });

  factory WordState.fresh(String word) => WordState(
        word: word.toLowerCase(),
        stage: SrsStage.fresh,
        easeFactor: 2.5,
        intervalDays: 0,
        repetitions: 0,
        dueAtMs: 0,
        lastReviewedMs: 0,
        totalSeen: 0,
        totalLapses: 0,
      );

  WordState copyWith({
    SrsStage? stage,
    double? easeFactor,
    int? intervalDays,
    int? repetitions,
    int? dueAtMs,
    int? lastReviewedMs,
    int? totalSeen,
    int? totalLapses,
  }) =>
      WordState(
        word: word,
        stage: stage ?? this.stage,
        easeFactor: easeFactor ?? this.easeFactor,
        intervalDays: intervalDays ?? this.intervalDays,
        repetitions: repetitions ?? this.repetitions,
        dueAtMs: dueAtMs ?? this.dueAtMs,
        lastReviewedMs: lastReviewedMs ?? this.lastReviewedMs,
        totalSeen: totalSeen ?? this.totalSeen,
        totalLapses: totalLapses ?? this.totalLapses,
      );

  Map<String, dynamic> toJson() => {
        'w': word,
        's': stage.key,
        'e': easeFactor,
        'i': intervalDays,
        'r': repetitions,
        'd': dueAtMs,
        'l': lastReviewedMs,
        't': totalSeen,
        'p': totalLapses,
      };

  factory WordState.fromJson(Map<String, dynamic> j) => WordState(
        word: (j['w'] as String).toLowerCase(),
        stage: SrsStageX.fromKey(j['s'] as String?),
        easeFactor: (j['e'] as num?)?.toDouble() ?? 2.5,
        intervalDays: (j['i'] as int?) ?? 0,
        repetitions: (j['r'] as int?) ?? 0,
        dueAtMs: (j['d'] as int?) ?? 0,
        lastReviewedMs: (j['l'] as int?) ?? 0,
        totalSeen: (j['t'] as int?) ?? 0,
        totalLapses: (j['p'] as int?) ?? 0,
      );

  bool get isDue => dueAtMs > 0 && dueAtMs <= DateTime.now().millisecondsSinceEpoch;
}

/// User rating after seeing a word. The mapping to SM-2 interval/ease updates
/// happens inside SrsService.applyReview.
enum ReviewRating { again, hard, good, easy }
