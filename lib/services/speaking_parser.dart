import '../models/speaking_set.dart';

/// Parses a pasted IELTS-style speaking transcript into a [SpeakingSet].
///
/// Expected shape (typical Part-1 sample):
///
///   Topic Line
///   Question one?
///   Answer paragraph(s)...
///   Question two?
///   Answer paragraph(s)...
///
/// Heuristics:
///   - Any non-blank line ending in `?` is treated as a question boundary.
///   - Everything before the first question (if non-empty) becomes the topic.
///   - All lines between question N and question N+1 (or EOF) are the answer
///     for question N, joined with a single space.
///   - Each answer is sentence-split on `.`/`!`/`?` followed by whitespace.
class SpeakingParser {
  /// Returns null if no questions could be identified.
  static SpeakingSet? parse(String raw, {String? topicOverride}) {
    final lines = raw
        .replaceAll('\r\n', '\n')
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    if (lines.isEmpty) return null;

    String topic = topicOverride?.trim() ?? '';
    final items = <SpeakingItem>[];

    String? currentQ;
    final currentA = <String>[];

    void flush() {
      if (currentQ == null) return;
      final answer = currentA.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();
      items.add(SpeakingItem(
        question: currentQ!,
        answer: answer,
        sentences: _splitSentences(answer),
      ));
      currentQ = null;
      currentA.clear();
    }

    for (final line in lines) {
      final isQuestion = line.endsWith('?');
      if (isQuestion) {
        flush();
        currentQ = line;
      } else if (currentQ == null) {
        // Pre-question prose → topic header. Only the first such line is used;
        // subsequent stray lines before the first `?` get concatenated so we
        // don't silently drop content from multi-line headers.
        if (topic.isEmpty) {
          topic = line;
        } else {
          topic = '$topic $line';
        }
      } else {
        currentA.add(line);
      }
    }
    flush();

    if (items.isEmpty) return null;
    return SpeakingSet(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      topic: topic.isEmpty ? 'Speaking practice' : topic,
      items: items,
      createdMs: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Splits [text] into sentences on `.`, `!`, `?` boundaries. Keeps the
  /// terminator with the preceding sentence so display reads naturally. Falls
  /// back to the whole string when no terminator is present.
  static List<String> _splitSentences(String text) {
    if (text.isEmpty) return const [];
    final out = <String>[];
    final re = RegExp(r'[^.!?]+[.!?]+');
    int lastEnd = 0;
    for (final m in re.allMatches(text)) {
      out.add(m.group(0)!.trim());
      lastEnd = m.end;
    }
    if (lastEnd < text.length) {
      final tail = text.substring(lastEnd).trim();
      if (tail.isNotEmpty) out.add(tail);
    }
    return out.isEmpty ? [text] : out;
  }
}
