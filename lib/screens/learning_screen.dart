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

  const LearningScreen({
    super.key,
    required this.day,
    required this.vocabularies,
    this.initialIndex = 0,
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
        title: Text(
          widget.day == 0 ? 'SEARCH' : 'DAY ${widget.day}',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.bBorder, size: 32),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (widget.vocabularies.isNotEmpty)
            IconButton(
              icon: Icon(
                _knownWords.contains(widget.vocabularies[_currentIndex].word.toLowerCase())
                    ? Icons.check_circle
                    : Icons.check_circle_outline,
                color: context.bBorder,
                size: 32,
              ),
              onPressed: () => _toggleKnownWord(widget.vocabularies[_currentIndex].word),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PROGRESS',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  '${_currentIndex + 1} / ${widget.vocabularies.length}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
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
                    backgroundColor: index % 2 == 0 
                        ? BrutalistTheme.primary 
                        : BrutalistTheme.accent,
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
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: BrutalistTheme.black, width: 2),
                                    color: BrutalistTheme.primary,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.open_in_new, color: BrutalistTheme.black),
                                    onPressed: () async {
                                      final Uri url = Uri.parse(vocab.url);
                                      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open link.')));
                                        }
                                      }
                                    },
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
                               Container(
                                color: BrutalistTheme.black,
                                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                child: Text(
                                  vocab.partOfSpeech.toUpperCase(),
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: BrutalistTheme.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: BrutalistTheme.white,
                                  border: Border.all(color: BrutalistTheme.black, width: 2),
                                ),
                                child: Text(
                                  vocab.levels.toUpperCase(),
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: BrutalistTheme.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              if (vocab.topic.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: BrutalistTheme.secondary,
                                    border: Border.all(color: BrutalistTheme.black, width: 2),
                                  ),
                                  child: Text(
                                    vocab.topic.toUpperCase(),
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: BrutalistTheme.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          const Divider(color: BrutalistTheme.black, thickness: 4),
                          const SizedBox(height: 32),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _showTranslation ? vocab.translation : '???',
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                    fontSize: 40,
                                    color: BrutalistTheme.black,
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
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavButton(
                  icon: Icons.arrow_back_ios_new,
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
                      'MEANING',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.bBorder,
                          ),
                    ),
                    Switch(
                      value: _showTranslation,
                      onChanged: (val) {
                        setState(() {
                          _showTranslation = val;
                        });
                      },
                      activeThumbColor: context.bBg,
                      activeTrackColor: context.bBorder,
                      inactiveThumbColor: context.bBorder,
                      inactiveTrackColor: context.bBg,
                      trackOutlineColor: WidgetStateProperty.all(context.bBorder),
                    ),
                  ],
                ),
                _buildNavButton(
                  icon: Icons.arrow_forward_ios,
                  onPressed: _currentIndex < widget.vocabularies.length - 1
                      ? () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          )
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({required IconData icon, required VoidCallback? onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: onPressed != null ? BrutalistTheme.secondary : Colors.grey.shade400,
          border: Border.all(color: BrutalistTheme.black, width: 4),
          boxShadow: onPressed != null
              ? const [
                  BoxShadow(
                    color: BrutalistTheme.black,
                    offset: Offset(4, 4),
                    blurRadius: 0,
                  )
                ]
              : null,
        ),
        child: Icon(icon, color: BrutalistTheme.black, size: 32),
      ),
    );
  }
}
