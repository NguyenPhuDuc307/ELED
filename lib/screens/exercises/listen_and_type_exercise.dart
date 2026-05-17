import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

import '../../models/vocabulary.dart';
import '../../models/word_state.dart';
import '../../theme/brutalist_theme.dart';
import '../../utils/log.dart';

/// Active-recall exercise: play the audio, the user types the word back.
/// Spelling is matched leniently (lowercase, trimmed, hyphens/apostrophes
/// stripped) so a missing apostrophe doesn't count as wrong.
class ListenAndTypeExercise extends StatefulWidget {
  final Vocabulary word;
  final Future<void> Function(ReviewRating rating) onAnswered;

  const ListenAndTypeExercise({
    super.key,
    required this.word,
    required this.onAnswered,
  });

  @override
  State<ListenAndTypeExercise> createState() => _ListenAndTypeExerciseState();
}

class _ListenAndTypeExerciseState extends State<ListenAndTypeExercise> {
  final _player = AudioPlayer();
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _loadingAudio = false;
  bool _playingAudio = false;
  bool? _correctness;

  @override
  void initState() {
    super.initState();
    // Auto-play once the page is built; user shouldn't have to hunt for the
    // play button.
    WidgetsBinding.instance.addPostFrameCallback((_) => _play(autoplay: true));
  }

  @override
  void dispose() {
    _player.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _play({bool autoplay = false}) async {
    final url = widget.word.audioLink;
    if (url.isEmpty || _playingAudio) return;
    setState(() {
      _playingAudio = true;
      _loadingAudio = autoplay;
    });
    try {
      await _player.setUrl(url);
      setState(() => _loadingAudio = false);
      await _player.play();
    } catch (e, st) {
      logCaught(e, st, 'ListenAndTypeExercise._play');
    }
    if (mounted) {
      setState(() {
        _playingAudio = false;
        _loadingAudio = false;
      });
    }
  }

  String _normalise(String s) => s
      .toLowerCase()
      .trim()
      .replaceAll(RegExp(r"['\-‘’]"), '')
      .replaceAll(RegExp(r'\s+'), ' ');

  Future<void> _submit() async {
    if (_correctness != null) return;
    final typed = _controller.text;
    if (typed.trim().isEmpty) return;
    final correct = _normalise(typed) == _normalise(widget.word.word);
    setState(() => _correctness = correct);
    // Brief pause so the user sees correct/wrong feedback before advancing.
    await Future.delayed(const Duration(milliseconds: 1200));
    await widget.onAnswered(correct ? ReviewRating.good : ReviewRating.again);
  }

  @override
  Widget build(BuildContext context) {
    final showAnswer = _correctness != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Listen and type',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.bMuted,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          Center(child: _bigAudioButton()),
          const SizedBox(height: 28),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: !showAnswer,
            autocorrect: false,
            enableSuggestions: false,
            textCapitalization: TextCapitalization.none,
            textAlign: TextAlign.center,
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'\n')),
            ],
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: showAnswer
                      ? (_correctness == true
                          ? BrutalistTheme.primary
                          : const Color(0xFFD9534F))
                      : context.bBorder,
                ),
            decoration: InputDecoration(
              hintText: 'Type the word',
              hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: context.bMuted,
                    fontSize: 18,
                  ),
              filled: true,
              fillColor: context.bBg,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: context.bSubtle, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: BrutalistTheme.primary, width: 2),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: _correctness == true
                      ? BrutalistTheme.primary
                      : const Color(0xFFD9534F),
                  width: 2,
                ),
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
          if (showAnswer && _correctness == false) ...[
            const SizedBox(height: 12),
            Text(
              widget.word.word,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: BrutalistTheme.primary,
                    fontSize: 20,
                  ),
            ),
          ],
          const SizedBox(height: 18),
          if (!showAnswer)
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => widget.onAnswered(ReviewRating.again),
                    style: TextButton.styleFrom(
                      foregroundColor: context.bMuted,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: BrutalistTheme.primary,
                      foregroundColor: BrutalistTheme.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Check',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _bigAudioButton() {
    return Material(
      color: BrutalistTheme.primaryLight,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _play,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: _loadingAudio
              ? const SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: BrutalistTheme.primary,
                  ),
                )
              : const Icon(
                  Icons.volume_up_rounded,
                  size: 48,
                  color: BrutalistTheme.primary,
                ),
        ),
      ),
    );
  }
}
