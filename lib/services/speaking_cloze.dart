/// Picks "interesting" content words to blank out in cloze practice. v1
/// heuristic — anything 5+ characters that isn't on the stopword list. The
/// pick set is deterministic per sentence (seeded by sentence hash) so the
/// blanks don't reshuffle every time the user toggles the mode.
class SpeakingCloze {
  static const _stopwords = <String>{
    'about', 'above', 'after', 'again', 'against', 'because', 'before',
    'being', 'below', 'between', 'could', 'doing', 'during', 'every',
    'further', 'have', 'having', 'here', 'into', 'most', 'much', 'myself',
    'often', 'only', 'other', 'over', 'same', 'should', 'some', 'such',
    'than', 'that', 'their', 'them', 'then', 'there', 'these', 'they',
    'this', 'those', 'through', 'under', 'until', 'very', 'were', 'what',
    'when', 'where', 'which', 'while', 'with', 'would', 'your', 'yours',
    'yourself', 'just', 'also', 'still', 'really', 'usually', 'maybe',
  };

  /// Returns the lowercase set of words to hide in [sentence]. The caller is
  /// expected to walk the sentence's tokens and render blanks for any token
  /// whose lowercase form appears in the result.
  static Set<String> picksFor(String sentence) {
    final candidates = <String>[];
    final re = RegExp(r"[A-Za-z]+(?:'[A-Za-z]+)?");
    for (final m in re.allMatches(sentence)) {
      final w = m.group(0)!.toLowerCase();
      if (w.length < 5) continue;
      if (_stopwords.contains(w)) continue;
      candidates.add(w);
    }
    if (candidates.isEmpty) return <String>{};
    // Target ~30% of eligible words, capped at 3 per sentence so a short
    // sentence doesn't end up mostly blanks.
    final target = (candidates.length * 0.3).ceil().clamp(1, 3);
    final seed = sentence.hashCode & 0x7fffffff;
    final picks = <String>{};
    // Deterministic linear walk seeded by the sentence so re-renders pick the
    // same words. Using a simple LCG to avoid pulling in dart:math.Random for
    // a 3-item shuffle.
    int x = seed == 0 ? 1 : seed;
    int idx = x % candidates.length;
    while (picks.length < target && picks.length < candidates.length) {
      picks.add(candidates[idx]);
      x = (x * 1103515245 + 12345) & 0x7fffffff;
      idx = x % candidates.length;
    }
    return picks;
  }
}
