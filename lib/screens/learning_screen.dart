import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/vocabulary.dart';
import '../services/oxford_service.dart';
import '../services/user_data_service.dart';
import '../theme/brutalist_theme.dart';
import '../widgets/brutalist_card.dart';

class LearningScreen extends StatefulWidget {
  final int day;
  final List<Vocabulary> vocabularies;
  final int initialIndex;
  final VoidCallback? onCompleted;

  const LearningScreen({
    super.key,
    required this.day,
    required this.vocabularies,
    this.initialIndex = 0,
    this.onCompleted,
  });

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  late final PageController _pageController;
  late int _currentIndex;
  Set<String> _knownWords = {};

  // false = show English definition (default), true = show Vietnamese translation of definition
  bool _translateDefinition = false;

  // Oxford definitions per page index
  final Map<int, List<OxfordSense>> _oxfordCache = {};
  bool _loadingDef = false;

  // Translated VI definitions per page index (list of translated strings, one per sense)
  final Map<int, List<String>> _translatedDefsCache = {};
  bool _translatingDef = false;

  final _audioPlayer = AudioPlayer();
  bool _playingAudio = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _loadKnownWords();
    _fetchDefinition(_currentIndex);
  }

  Future<void> _loadKnownWords() async {
    setState(() {
      _knownWords = UserDataService().knownWords;
    });
  }

  Future<void> _fetchDefinition(int index) async {
    if (_oxfordCache.containsKey(index)) return;
    if (!mounted) return;
    final vocab = widget.vocabularies[index];
    setState(() => _loadingDef = true);
    final senses = await OxfordService.fetchDefinitions(vocab.word, vocab.url);
    if (!mounted) return;
    setState(() {
      _oxfordCache[index] = senses;
      _loadingDef = false;
    });
  }

  Future<void> _toggleKnownWord(String word) async {
    final messenger = ScaffoldMessenger.of(context);
    final isAdded = !_knownWords.contains(word.toLowerCase());
    await UserDataService().toggleKnownWord(word);
    setState(() {
      _knownWords = UserDataService().knownWords;
    });
    if (mounted) {
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Text(isAdded ? 'MARKED AS KNOWN!' : 'REMOVED FROM KNOWN WORDS!'),
          duration: const Duration(milliseconds: 1500),
        ),
      );
    }
  }

  Future<void> _playAudio(String url) async {
    if (url.isEmpty || _playingAudio) return;
    setState(() => _playingAudio = true);
    try {
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
    } catch (_) {}
    if (mounted) setState(() => _playingAudio = false);
  }

  Future<void> _toggleTranslation(int index) async {
    final newVal = !_translateDefinition;
    setState(() => _translateDefinition = newVal);
    if (newVal) await _translateSenses(index);
  }

  Future<void> _translateSenses(int index) async {
    if (_translatedDefsCache.containsKey(index)) return;
    final senses = _oxfordCache[index];
    if (senses == null || senses.isEmpty) return;
    if (!mounted) return;
    setState(() => _translatingDef = true);
    final results = await Future.wait(senses.map((s) => _translateToVi(s.definition)));
    if (!mounted) return;
    setState(() {
      _translatedDefsCache[index] = results;
      _translatingDef = false;
    });
  }

  static Future<String> _translateToVi(String text) async {
    if (text.isEmpty) return '';
    try {
      final uri = Uri.parse(
        'https://translate.googleapis.com/translate_a/single'
        '?client=gtx&sl=en&tl=vi&dt=t&q=${Uri.encodeComponent(text)}',
      );
      final client = HttpClient();
      final request = await client.getUrl(uri);
      final response = await request.close();
      client.close();
      if (response.statusCode != 200) return text;
      final body = await response.transform(utf8.decoder).join();
      final json = jsonDecode(body) as List;
      final segments = json[0] as List;
      return segments
          .where((s) => s is List && s.isNotEmpty && s[0] is String)
          .map((s) => s[0] as String)
          .join();
    } catch (_) {
      return text;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.day == 0 ? 'Search' : 'Day ${widget.day}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (widget.vocabularies.isNotEmpty)
            IconButton(
              icon: Icon(
                _knownWords.contains(widget.vocabularies[_currentIndex].word.toLowerCase())
                    ? Icons.check_circle_rounded
                    : Icons.check_circle_outline_rounded,
              ),
              onPressed: () => _toggleKnownWord(widget.vocabularies[_currentIndex].word),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_currentIndex + 1} / ${widget.vocabularies.length}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.bMuted,
                      ),
                ),
                Text(
                  '${((_currentIndex + 1) / widget.vocabularies.length * 100).round()}%',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: BrutalistTheme.primary,
                      ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ClipRRect(
              child: LinearProgressIndicator(
                value: widget.vocabularies.isEmpty
                    ? 0
                    : (_currentIndex + 1) / widget.vocabularies.length,
                minHeight: 8,
                color: BrutalistTheme.primary,
                backgroundColor: context.bBorder.withValues(alpha: 0.15),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.vocabularies.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
                _fetchDefinition(index);
              },
              itemBuilder: (context, index) {
                final vocab = widget.vocabularies[index];
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: BrutalistCard(
                    backgroundColor: levelColor(vocab.levels, fallbackIndex: index),
                    onTap: () => _toggleTranslation(index),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              vocab.word,
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontSize: 50,
                                  height: 1.1,
                                  color: BrutalistTheme.black,
                                ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Text(
                                vocab.ipa,
                                style: GoogleFonts.notoSans(
                                  textStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        color: BrutalistTheme.black,
                                        fontStyle: FontStyle.italic,
                                      ),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (vocab.audioLink.isNotEmpty)
                                Material(
                                  color: BrutalistTheme.primaryLight,
                                  borderRadius: BorderRadius.circular(24),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(24),
                                    onTap: () => _playAudio(vocab.audioLink),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: _playingAudio
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: BrutalistTheme.primary,
                                              ),
                                            )
                                          : const Icon(Icons.volume_up_rounded, color: BrutalistTheme.primary, size: 22),
                                    ),
                                  ),
                                ),
                              if (vocab.url.isNotEmpty)
                                Material(
                                  color: BrutalistTheme.primaryLight,
                                  borderRadius: BorderRadius.circular(24),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(24),
                                    onTap: () async {
                                      final Uri url = Uri.parse(vocab.url);
                                      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open link.')));
                                        }
                                      }
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Icon(Icons.open_in_new_rounded, color: BrutalistTheme.primary, size: 22),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _badge(context, vocab.partOfSpeech, BrutalistTheme.primary, BrutalistTheme.primaryLight),
                              _badge(context, vocab.levels.toUpperCase(), BrutalistTheme.black, BrutalistTheme.border.withValues(alpha: 0.4)),
                              if (vocab.topic.isNotEmpty)
                                _badge(context, vocab.topic, BrutalistTheme.accent, BrutalistTheme.accentLight),
                            ],
                          ),
                          const SizedBox(height: 28),
                          Divider(color: context.bSubtle, thickness: 1),
                          const SizedBox(height: 20),
                          // Vietnamese word translation — always visible
                          Text(
                            vocab.translation,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: BrutalistTheme.black,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          // Definitions: English by default, Vietnamese when _translateDefinition=true
                          if (_loadingDef && !_oxfordCache.containsKey(index))
                            const Center(
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: BrutalistTheme.primary,
                                ),
                              ),
                            )
                          else if ((_oxfordCache[index] ?? []).isNotEmpty)
                            ...List.generate(_oxfordCache[index]!.length, (si) {
                              final s = _oxfordCache[index]![si];
                              final viDefs = _translatedDefsCache[index];
                              final showVI = _translateDefinition && viDefs != null;
                              final defText = showVI && si < viDefs.length
                                  ? viDefs[si]
                                  : s.definition;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${s.number}. ',
                                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: BrutalistTheme.primary,
                                              ),
                                        ),
                                        Expanded(
                                          child: _translatingDef && _translateDefinition && viDefs == null
                                              ? const SizedBox(
                                                  height: 18,
                                                  width: 18,
                                                  child: CircularProgressIndicator(strokeWidth: 2, color: BrutalistTheme.primary),
                                                )
                                              : Text(
                                                  defText,
                                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                        fontWeight: FontWeight.w600,
                                                        color: BrutalistTheme.black,
                                                      ),
                                                ),
                                        ),
                                      ],
                                    ),
                                    if (s.example.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 18, top: 2),
                                        child: Text(
                                          '"${s.example}"',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                fontStyle: FontStyle.italic,
                                                color: BrutalistTheme.textMuted,
                                              ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: context.bBg,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onPressed: _currentIndex > 0
                      ? () => _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          )
                      : null,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _translateDefinition ? 'VI' : 'EN',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.bMuted,
                            fontSize: 13,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Switch(
                      value: _translateDefinition,
                      onChanged: (_) => _toggleTranslation(_currentIndex),
                      activeThumbColor: BrutalistTheme.white,
                      activeTrackColor: BrutalistTheme.primary,
                      inactiveThumbColor: BrutalistTheme.white,
                      inactiveTrackColor: BrutalistTheme.border,
                      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                    ),
                  ],
                ),
                _buildNavButton(
                  icon: _currentIndex < widget.vocabularies.length - 1
                      ? Icons.arrow_forward_ios_rounded
                      : Icons.skip_next_rounded,
                  onPressed: _currentIndex < widget.vocabularies.length - 1
                      ? () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          )
                      : widget.onCompleted,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(BuildContext context, String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
      ),
    );
  }

  Widget _buildNavButton({required IconData icon, required VoidCallback? onPressed}) {
    final active = onPressed != null;
    return Material(
      color: active ? BrutalistTheme.primaryLight : BrutalistTheme.border.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Icon(icon, color: active ? BrutalistTheme.primary : BrutalistTheme.textMuted, size: 24),
        ),
      ),
    );
  }
}
