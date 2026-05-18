import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/brutalist_theme.dart';

/// IP-address-style input: one boxed slot per letter in the answer
/// [template], with a wider gap between words and fixed display of
/// punctuation (apostrophes, hyphens). The user only types letters —
/// spaces/punctuation are skipped automatically.
///
/// Uses a single hidden TextField for keyboard input; tapping anywhere on
/// the slot row focuses it. The visible slots mirror the controller text
/// character by character.
class SlotAnswerField extends StatefulWidget {
  final String template;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  /// null = neutral, true = correct, false = wrong. Drives slot colouring
  /// once the answer is revealed.
  final bool? correctness;
  final VoidCallback onSubmit;

  const SlotAnswerField({
    super.key,
    required this.template,
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
    this.enabled = true,
    this.correctness,
  });

  @override
  State<SlotAnswerField> createState() => _SlotAnswerFieldState();
}

class _SlotAnswerFieldState extends State<SlotAnswerField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  /// Total number of typeable letter slots (excludes spaces + punctuation).
  int get _letterCount {
    var n = 0;
    for (final c in widget.template.runes) {
      if (_isLetter(String.fromCharCode(c))) n++;
    }
    return n;
  }

  static bool _isLetter(String c) {
    return RegExp(r'[a-zA-Z]').hasMatch(c);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.enabled ? () => widget.focusNode.requestFocus() : null,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(width: double.infinity, child: Center(child: _slotsRow())),
          // Hidden TextField sized to zero — captures keyboard input only.
          // We keep it in the tree (not Offstage) so it can hold focus.
          SizedBox(
            width: 0,
            height: 0,
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              enabled: widget.enabled,
              autofocus: true,
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.none,
              showCursor: false,
              maxLength: _letterCount,
              inputFormatters: [
                // Letters only — spaces/punctuation are part of the template.
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
              ],
              style: const TextStyle(color: Colors.transparent, height: 0.01),
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: (_) => widget.onSubmit(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _slotsRow() {
    final typed = widget.controller.text;
    final showAnswer = widget.correctness != null;
    final correct = widget.correctness == true;
    final wrong = widget.correctness == false;
    final caretAt = widget.focusNode.hasFocus && widget.enabled ? typed.length : -1;

    final children = <Widget>[];
    var typedIndex = 0;
    for (var i = 0; i < widget.template.length; i++) {
      final ch = widget.template[i];
      if (ch == ' ') {
        children.add(const SizedBox(width: 14));
        continue;
      }
      if (!_isLetter(ch)) {
        // Punctuation (apostrophe, hyphen) — show literal, locked.
        children.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: Text(
            ch,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: context.bMuted,
                ),
          ),
        ));
        continue;
      }
      final filled = typedIndex < typed.length ? typed[typedIndex] : null;
      final isCaret = typedIndex == caretAt;
      children.add(_slot(
        letter: filled,
        showCaret: isCaret,
        correct: correct,
        wrong: wrong,
        showAnswer: showAnswer,
      ));
      typedIndex++;
    }
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 4,
      runSpacing: 8,
      children: children,
    );
  }

  Widget _slot({
    required String? letter,
    required bool showCaret,
    required bool correct,
    required bool wrong,
    required bool showAnswer,
  }) {
    Color border = context.bSubtle;
    Color fg = context.bBorder;
    if (correct) {
      border = BrutalistTheme.primary;
      fg = BrutalistTheme.primary;
    } else if (wrong) {
      border = const Color(0xFFD9534F);
      fg = const Color(0xFFD9534F);
    } else if (letter != null) {
      border = BrutalistTheme.primary;
      fg = BrutalistTheme.primary;
    }
    return Container(
      width: 28,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: border, width: 2.5)),
      ),
      child: letter != null
          ? Text(
              letter,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: fg,
                    fontSize: 22,
                  ),
            )
          : (showCaret && !showAnswer
              ? Container(
                  width: 2,
                  height: 22,
                  color: BrutalistTheme.primary,
                )
              : null),
    );
  }
}
