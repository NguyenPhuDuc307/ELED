import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../services/tts_prefs_service.dart';
import '../../theme/brutalist_theme.dart';
import '../../utils/log.dart';
import '../../widgets/section_header.dart';

/// Settings screen for the Speaking flow's TTS voice. Lets the user pick:
///   1) Accent — US (`en-US`) or UK (`en-GB`).
///   2) Specific voice — chosen directly from the list of voices the device
///      has installed for that accent. We do NOT try to infer gender from
///      voice names because Android's Google TTS often returns names like
///      `en-us-x-iol-local` with no reliable gender signal; instead each
///      voice has a "preview" button so the user can hear it before picking.
class SpeakingVoiceSettingsScreen extends StatefulWidget {
  const SpeakingVoiceSettingsScreen({super.key});

  @override
  State<SpeakingVoiceSettingsScreen> createState() =>
      _SpeakingVoiceSettingsScreenState();
}

class _SpeakingVoiceSettingsScreenState
    extends State<SpeakingVoiceSettingsScreen> {
  final FlutterTts _tts = FlutterTts();
  late TtsAccent _accent;
  List<_VoiceEntry> _voices = const [];
  bool _loading = true;
  String? _previewingName;

  @override
  void initState() {
    super.initState();
    _accent = TtsPrefsService().accent;
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setSpeechRate(0.5);
      await _tts.awaitSpeakCompletion(true);
      _tts.setCompletionHandler(() {
        if (mounted) setState(() => _previewingName = null);
      });
    } catch (e, st) {
      logCaught(e, st, 'SpeakingVoiceSettings.initTts');
    }
    await _loadVoices();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _loadVoices() async {
    setState(() => _loading = true);
    final raw = <_RawVoice>[];
    try {
      final list = await _tts.getVoices;
      if (list is List) {
        for (final v in list) {
          if (v is! Map) continue;
          final m = v.map((k, value) => MapEntry(k.toString(), value.toString()));
          final loc = m['locale'] ?? '';
          if (loc.toLowerCase() != _accent.locale.toLowerCase()) continue;
          raw.add(_RawVoice(
            name: m['name'] ?? '',
            locale: loc,
            gender: _inferGender(m),
          ));
        }
      }
    } catch (e, st) {
      logCaught(e, st, 'SpeakingVoiceSettings.loadVoices');
    }

    // Pass 1: collect Google-TTS variant codes (e.g. "gba", "gbb", "sfg") so we
    // can re-letter them A, B, C... in display order — much friendlier than
    // raw `en-gb-x-gba-local` strings.
    final variants = <String>{};
    for (final r in raw) {
      final variant = _parseVariant(r.name);
      if (variant != null) variants.add(variant);
    }
    final sortedVariants = variants.toList()..sort();
    final variantLabel = <String, String>{};
    for (var i = 0; i < sortedVariants.length; i++) {
      variantLabel[sortedVariants[i]] = String.fromCharCode(65 + i); // A, B, C
    }

    // Pass 2: compute display name + sort key per voice.
    if (!mounted) return;
    final t = AppLocalizations.of(context);
    final entries = raw
        .map((r) => _VoiceEntry(
              name: r.name,
              locale: r.locale,
              gender: r.gender,
              displayName: _computeDisplayName(r.name, variantLabel, t),
              sortKey: _computeSortKey(r.name, variantLabel),
            ))
        .toList();
    entries.sort((a, b) {
      // Female first (most users prefer it as default), then male, then
      // unknown. Within the same gender, sort by computed sort key so the
      // base "Default voice" sits on top and variants run A→Z.
      const order = {'female': 0, 'male': 1, 'unknown': 2};
      final ga = order[a.gender] ?? 2;
      final gb = order[b.gender] ?? 2;
      if (ga != gb) return ga.compareTo(gb);
      return a.sortKey.compareTo(b.sortKey);
    });

    if (!mounted) return;
    setState(() {
      _voices = entries;
      _loading = false;
    });
  }

  /// Returns the variant code (e.g. "gba", "sfg") for Google TTS voice names
  /// of the form `en-XX-x-VARIANT-(local|network)`. Returns null for other
  /// patterns (Apple voices, the base `en-XX-language`, custom engines).
  String? _parseVariant(String name) {
    final m = RegExp(
      r'^en-(?:gb|us)-x-([a-z]+)-(?:local|network)$',
      caseSensitive: false,
    ).firstMatch(name);
    return m?.group(1)?.toLowerCase();
  }

  String _computeDisplayName(
      String rawName, Map<String, String> variantLabel, AppLocalizations t) {
    // Apple voices: `com.apple.voice.compact.en-US.Samantha` → "Samantha".
    if (rawName.contains('com.apple.voice')) {
      return rawName.split('.').last;
    }
    // Google base voice (no variant): "Default voice".
    if (RegExp(r'^en-(?:gb|us)-language$', caseSensitive: false)
        .hasMatch(rawName)) {
      return t.speakingVoiceLabelDefault;
    }
    // Google variant voice: "Voice A · Offline" / "Voice A · Online".
    final m = RegExp(
      r'^en-(?:gb|us)-x-([a-z]+)-(local|network)$',
      caseSensitive: false,
    ).firstMatch(rawName);
    if (m != null) {
      final variant = m.group(1)!.toLowerCase();
      final quality = m.group(2)!.toLowerCase();
      final letter = variantLabel[variant] ?? variant.toUpperCase();
      return quality == 'local'
          ? t.speakingVoiceLabelOffline(letter)
          : t.speakingVoiceLabelOnline(letter);
    }
    return rawName;
  }

  /// Stable sort key: base voice ("00"), then variant letter + quality.
  /// Local (offline) sorts before network (online) so the pair shows together.
  String _computeSortKey(String rawName, Map<String, String> variantLabel) {
    if (RegExp(r'^en-(?:gb|us)-language$', caseSensitive: false)
        .hasMatch(rawName)) {
      return '00';
    }
    final m = RegExp(
      r'^en-(?:gb|us)-x-([a-z]+)-(local|network)$',
      caseSensitive: false,
    ).firstMatch(rawName);
    if (m != null) {
      final letter = variantLabel[m.group(1)!.toLowerCase()] ?? 'Z';
      final qualityKey = m.group(2)!.toLowerCase() == 'local' ? '0' : '1';
      return '10$letter$qualityKey';
    }
    return '99$rawName';
  }

  String _inferGender(Map<String, String> voice) {
    final explicit = voice['gender']?.toLowerCase();
    if (explicit == 'female' || explicit == 'male') return explicit!;
    final name = (voice['name'] ?? '').toLowerCase();
    // Check female first because the string 'female' itself contains 'male'.
    if (name.contains('female')) return 'female';
    if (name.contains('male')) return 'male';
    return 'unknown';
  }

  Future<void> _setAccent(TtsAccent a) async {
    if (a == _accent) return;
    setState(() => _accent = a);
    await TtsPrefsService().setAccent(a);
    await _loadVoices();
  }

  Future<void> _pickVoice(_VoiceEntry v) async {
    await TtsPrefsService().setVoiceFor(_accent, v.name);
    if (!mounted) return;
    setState(() {});
    // Apply + preview so the tap feels instantly reactive.
    await _applySelectedToTts();
    await _previewVoice(v);
  }

  Future<void> _applySelectedToTts() async {
    try {
      await _tts.setLanguage(_accent.locale);
      final saved = TtsPrefsService().voiceFor(_accent);
      if (saved != null && saved.isNotEmpty) {
        await _tts.setVoice({'name': saved, 'locale': _accent.locale});
      }
    } catch (e, st) {
      logCaught(e, st, 'SpeakingVoiceSettings.applySelected');
    }
  }

  /// Short English sample played when the user taps "Preview" on a voice.
  /// Hardcoded English (not localized) because the user is auditioning an
  /// English TTS voice — the engine would mangle Vietnamese text anyway.
  static const _previewSample =
      'Hi, this is how I sound. I will read your speaking practice in this voice.';

  Future<void> _previewVoice(_VoiceEntry v) async {
    setState(() => _previewingName = v.name);
    try {
      await _tts.stop();
      await _tts.setVoice({'name': v.name, 'locale': v.locale});
      await _tts.speak(_previewSample);
    } catch (e, st) {
      logCaught(e, st, 'SpeakingVoiceSettings.previewVoice');
      if (mounted) setState(() => _previewingName = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final selectedName = TtsPrefsService().voiceFor(_accent);
    return Scaffold(
      appBar: AppBar(title: Text(t.speakingVoiceTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(
              t.speakingVoiceTitle,
              subtitle: t.settingsSpeakingVoiceSubtitle,
            ),
            const SizedBox(height: 8),
            _label(t.speakingVoiceAccent),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _accentPill(
                    label: TtsAccent.us.label,
                    active: _accent == TtsAccent.us,
                    onTap: () => _setAccent(TtsAccent.us),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _accentPill(
                    label: TtsAccent.uk.label,
                    active: _accent == TtsAccent.uk,
                    onTap: () => _setAccent(TtsAccent.uk),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _label(t.speakingVoiceList),
            const SizedBox(height: 8),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_voices.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  t.speakingVoiceNoneInstalled,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.bMuted,
                        height: 1.4,
                      ),
                ),
              )
            else
              ..._voices.map((v) => _voiceRow(v, v.name == selectedName, t)),
            const SizedBox(height: 16),
            Text(
              t.speakingVoiceFallbackNote,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.bMuted,
                    fontSize: 12,
                    height: 1.4,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: context.bMuted,
            fontSize: 11,
            letterSpacing: 0.4,
          ),
    );
  }

  Widget _accentPill({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Material(
      color: active
          ? BrutalistTheme.primary
          : BrutalistTheme.primaryLight.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: active
                    ? BrutalistTheme.white
                    : BrutalistTheme.primary,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _voiceRow(_VoiceEntry v, bool selected, AppLocalizations t) {
    final previewing = _previewingName == v.name;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: selected
            ? BrutalistTheme.primary.withValues(alpha: 0.10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected
              ? BrutalistTheme.primary
              : context.bSubtle,
          width: selected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _pickVoice(v),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          v.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                        ),
                      ),
                      if (v.gender != 'unknown') ...[
                        const SizedBox(width: 8),
                        _genderBadge(v.gender, t),
                      ],
                    ],
                  ),
                ),
                TextButton(
                  onPressed: previewing ? null : () => _previewVoice(v),
                  style: TextButton.styleFrom(
                    foregroundColor: BrutalistTheme.primary,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    previewing ? t.speakingListening : t.speakingVoicePreview,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _genderBadge(String gender, AppLocalizations t) {
    if (gender == 'unknown') return const SizedBox.shrink();
    final isFemale = gender == 'female';
    final color = isFemale
        ? const Color(0xFFD96BA0)
        : const Color(0xFF5B8CD9);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isFemale ? t.speakingVoiceFemale : t.speakingVoiceMale,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: color,
          fontSize: 10,
        ),
      ),
    );
  }

}

class _VoiceEntry {
  final String name;
  final String locale;
  final String gender; // 'female' | 'male' | 'unknown'
  final String displayName;
  final String sortKey;
  const _VoiceEntry({
    required this.name,
    required this.locale,
    required this.gender,
    required this.displayName,
    required this.sortKey,
  });
}

/// Lightweight intermediate used between the platform `getVoices` call and the
/// final `_VoiceEntry` — lets us compute display name + sort key after we know
/// the full set of variant codes for the chosen accent.
class _RawVoice {
  final String name;
  final String locale;
  final String gender;
  const _RawVoice({
    required this.name,
    required this.locale,
    required this.gender,
  });
}
