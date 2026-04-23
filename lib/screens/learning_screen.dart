import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vocabulary.dart';
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
  bool _showTranslation = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _loadKnownWords();
  }

  Future<void> _loadKnownWords() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _knownWords = (prefs.getStringList('knownWords') ?? []).map((w) => w.toLowerCase()).toSet();
    });
  }

  Future<void> _toggleKnownWord(String word) async {
    final messenger = ScaffoldMessenger.of(context);
    final prefs = await SharedPreferences.getInstance();
    bool isAdded = false;
    final lowerWord = word.toLowerCase();
    
    setState(() {
      if (_knownWords.contains(lowerWord)) {
        _knownWords.remove(lowerWord);
      } else {
        _knownWords.add(lowerWord);
        isAdded = true;
      }
    });
    await prefs.setStringList('knownWords', _knownWords.toList());

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

  @override
  void dispose() {
    _pageController.dispose();
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
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final vocab = widget.vocabularies[index];
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: BrutalistCard(
                    backgroundColor: levelColor(vocab.levels, fallbackIndex: index),
                    onTap: () => setState(() => _showTranslation = !_showTranslation),
                    child: Padding(
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
                          const SizedBox(height: 28),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _showTranslation ? vocab.translation : 'Tap to reveal',
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                    fontSize: 40,
                                    color: _showTranslation ? BrutalistTheme.black : BrutalistTheme.textMuted,
                                    fontStyle: _showTranslation ? FontStyle.normal : FontStyle.italic,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
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
                      'Meaning',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.bMuted,
                            fontSize: 13,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Switch(
                      value: _showTranslation,
                      onChanged: (val) => setState(() => _showTranslation = val),
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
