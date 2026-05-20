import 'dart:convert';

/// A single Question/Answer pair within a speaking set. The answer is stored
/// both as raw text (for shadowing/display) and as a pre-split sentence list
/// so each practice mode can iterate sentence-by-sentence without re-parsing.
class SpeakingItem {
  final String question;
  final String answer;
  final List<String> sentences;

  const SpeakingItem({
    required this.question,
    required this.answer,
    required this.sentences,
  });

  Map<String, dynamic> toJson() => {
        'q': question,
        'a': answer,
        's': sentences,
      };

  factory SpeakingItem.fromJson(Map<String, dynamic> j) => SpeakingItem(
        question: j['q'] as String? ?? '',
        answer: j['a'] as String? ?? '',
        sentences: (j['s'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      );
}

/// A user-pasted speaking sample — typically one IELTS Part-1 topic with N
/// questions. Identified by [id] (millisecond timestamp at create time).
class SpeakingSet {
  final String id;
  final String topic;
  final List<SpeakingItem> items;
  final int createdMs;

  const SpeakingSet({
    required this.id,
    required this.topic,
    required this.items,
    required this.createdMs,
  });

  SpeakingSet copyWith({String? topic, List<SpeakingItem>? items}) =>
      SpeakingSet(
        id: id,
        topic: topic ?? this.topic,
        items: items ?? this.items,
        createdMs: createdMs,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'topic': topic,
        'items': items.map((e) => e.toJson()).toList(),
        'createdMs': createdMs,
      };

  factory SpeakingSet.fromJson(Map<String, dynamic> j) => SpeakingSet(
        id: j['id'] as String? ?? '',
        topic: j['topic'] as String? ?? '',
        items: (j['items'] as List?)
                ?.map((e) => SpeakingItem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        createdMs: j['createdMs'] as int? ?? 0,
      );

  String encode() => jsonEncode(toJson());
  static SpeakingSet decode(String raw) =>
      SpeakingSet.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}
