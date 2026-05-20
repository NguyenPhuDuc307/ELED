/// Word-level scoring for STT-based speaking practice.
///
/// Tokenises both the model answer and what the user actually said, then uses
/// longest-common-subsequence to match in-order — so "I really enjoy playing"
/// vs "really enjoy playing" still scores correctly even with a missed first
/// word. Punctuation/case are stripped before comparison.
class SpeakingScore {
  /// Result of comparing [target] against [spoken].
  final List<TargetToken> tokens;
  final int matched;
  final int total;

  const SpeakingScore({
    required this.tokens,
    required this.matched,
    required this.total,
  });

  /// 0..100 — percentage of target words found, in order, in the transcript.
  int get percent {
    if (total == 0) return 0;
    return ((matched / total) * 100).round();
  }

  static SpeakingScore compare(String target, String spoken) {
    final tgt = _tokenize(target);
    final spk = _tokenize(spoken);
    final matchedSet = _lcsMatchIndexes(tgt.map((t) => t.norm).toList(),
        spk.map((t) => t.norm).toList());
    final tokens = <TargetToken>[];
    for (var i = 0; i < tgt.length; i++) {
      tokens.add(TargetToken(
        display: tgt[i].display,
        matched: matchedSet.contains(i),
      ));
    }
    return SpeakingScore(
      tokens: tokens,
      matched: matchedSet.length,
      total: tgt.length,
    );
  }

  static List<_Tok> _tokenize(String text) {
    final out = <_Tok>[];
    final re = RegExp(r"[A-Za-z]+(?:'[A-Za-z]+)?");
    for (final m in re.allMatches(text)) {
      final display = m.group(0)!;
      out.add(_Tok(display: display, norm: display.toLowerCase()));
    }
    return out;
  }

  /// Returns the set of indexes in [a] that participate in the LCS with [b].
  /// Classic DP, O(|a|*|b|) — fine for IELTS answer-sized inputs (<200 words).
  static Set<int> _lcsMatchIndexes(List<String> a, List<String> b) {
    final n = a.length, m = b.length;
    if (n == 0 || m == 0) return <int>{};
    final dp = List.generate(n + 1, (_) => List<int>.filled(m + 1, 0));
    for (var i = 1; i <= n; i++) {
      for (var j = 1; j <= m; j++) {
        if (a[i - 1] == b[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1] + 1;
        } else {
          dp[i][j] = dp[i - 1][j] > dp[i][j - 1] ? dp[i - 1][j] : dp[i][j - 1];
        }
      }
    }
    final picked = <int>{};
    int i = n, j = m;
    while (i > 0 && j > 0) {
      if (a[i - 1] == b[j - 1]) {
        picked.add(i - 1);
        i--;
        j--;
      } else if (dp[i - 1][j] >= dp[i][j - 1]) {
        i--;
      } else {
        j--;
      }
    }
    return picked;
  }
}

class TargetToken {
  final String display;
  final bool matched;
  const TargetToken({required this.display, required this.matched});
}

class _Tok {
  final String display;
  final String norm;
  const _Tok({required this.display, required this.norm});
}
