import 'package:flutter/material.dart';
import '../l10n/gen/app_localizations.dart';
import '../services/csv_service.dart';
import '../services/vocabulary_sync_service.dart';
import '../theme/brutalist_theme.dart';
import 'menu_screen.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  double _progress = 0;
  bool _error = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _sync();
  }

  Future<void> _sync() async {
    setState(() {
      _error = false;
      _progress = 0;
    });
    try {
      await VocabularySyncService.syncIfNeeded(
        onProgress: (p) {
          if (mounted) setState(() => _progress = p);
        },
      );
      CsvService.clearCache();
    } catch (e) {
      final msg = e.toString();
      // 404 = files not uploaded yet → use bundled assets, proceed normally
      if (msg.contains('404') || msg.contains('does not exist') || msg.contains('version.json')) {
        // bundled assets will be used as fallback in CsvService
      } else {
        if (mounted) {
          setState(() {
            _error = true;
            _errorMessage = msg.replaceFirst('Exception: ', '');
          });
          return;
        }
      }
    }
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MenuScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? BrutalistTheme.black : BrutalistTheme.background;
    final fg = isDark ? BrutalistTheme.white : BrutalistTheme.black;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.appTitle,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: BrutalistTheme.primary,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error
                    ? t.syncErrorTitle
                    : _progress == 0
                        ? t.syncPreparing
                        : t.syncLoading,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
              const SizedBox(height: 32),
              if (!_error) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: _progress == 0 ? null : _progress,
                    minHeight: 6,
                    backgroundColor: BrutalistTheme.border,
                    valueColor: const AlwaysStoppedAnimation(BrutalistTheme.primary),
                  ),
                ),
                const SizedBox(height: 12),
                if (_progress > 0)
                  Text(
                    '${(_progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 13,
                      color: BrutalistTheme.textMuted,
                    ),
                  ),
              ] else ...[
                Text(
                  _errorMessage,
                  style: const TextStyle(
                    fontSize: 13,
                    color: BrutalistTheme.secondary,
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: _sync,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: BrutalistTheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      t.syncTryAgain,
                      style: const TextStyle(
                        color: BrutalistTheme.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
