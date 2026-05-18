import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../services/update_service.dart';
import '../../theme/brutalist_theme.dart';
import '../../widgets/brutalist_card.dart';
import '../../widgets/section_header.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _currentVersion = '';
  bool _autoCheck = true;
  bool _checking = false;
  bool _checked = false;
  UpdateInfo? _info;
  bool _downloading = false;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final v = await UpdateService.currentVersion();
    final auto = await UpdateService.isAutoCheckEnabled();
    if (!mounted) return;
    setState(() {
      _currentVersion = v;
      _autoCheck = auto;
    });
  }

  Future<void> _check() async {
    if (_checking) return;
    setState(() {
      _checking = true;
      _checked = false;
    });
    final v = await UpdateService.currentVersion();
    final info = await UpdateService.checkForUpdate();
    if (!mounted) return;
    setState(() {
      _currentVersion = v;
      _info = info;
      _checking = false;
      _checked = true;
    });
  }

  Future<void> _download() async {
    final info = _info;
    if (info == null || info.apkUrl.isEmpty) return;
    setState(() {
      _downloading = true;
      _progress = 0.0;
    });
    try {
      await UpdateService.downloadAndInstall(
        info.apkUrl,
        onProgress: (p) {
          if (mounted) setState(() => _progress = p < 0 ? -1.0 : p);
        },
      );
    } catch (e) {
      if (mounted) {
        final t = AppLocalizations.of(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(t.aboutDownloadFailed('$e'))));
      }
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.aboutTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(t.aboutVersion),
            _versionCard(t),
          ],
        ),
      ),
    );
  }

  Widget _versionCard(AppLocalizations t) {
    return BrutalistCard(
      backgroundColor: context.bBg,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: BrutalistTheme.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.system_update_rounded,
                      color: BrutalistTheme.primary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.aboutCurrentVersion,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: context.bMuted)),
                      Text(t.aboutVersionPrefix(_currentVersion),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                _checking
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: BrutalistTheme.primary),
                      )
                    : TextButton(
                        onPressed: _check,
                        child: Text(t.aboutCheckButton,
                            style: const TextStyle(
                                color: BrutalistTheme.primary, fontWeight: FontWeight.w700)),
                      ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(t.aboutAutoCheckOnStartup,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: context.bMuted)),
                ),
                Switch(
                  value: _autoCheck,
                  onChanged: (v) async {
                    setState(() => _autoCheck = v);
                    await UpdateService.setAutoCheck(v);
                  },
                  activeThumbColor: BrutalistTheme.white,
                  activeTrackColor: BrutalistTheme.primary,
                  inactiveThumbColor: BrutalistTheme.white,
                  inactiveTrackColor: BrutalistTheme.border,
                  trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                ),
              ],
            ),
            if (_checked) ...[
              const SizedBox(height: 12),
              if (_info != null) _newVersionBanner(t) else _upToDateRow(t),
            ],
          ],
        ),
      ),
    );
  }

  Widget _newVersionBanner(AppLocalizations t) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BrutalistTheme.primaryLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.new_releases_rounded,
                  color: BrutalistTheme.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(t.aboutNewVersionAvailable(_info!.version),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: BrutalistTheme.primary)),
              ),
              if (!_downloading)
                TextButton(
                  onPressed: _info!.apkUrl.isNotEmpty
                      ? _download
                      : () async {
                          await launchUrl(Uri.parse(_info!.releaseUrl),
                              mode: LaunchMode.externalApplication);
                        },
                  child: Text(
                    _info!.apkUrl.isNotEmpty ? t.aboutUpdateNow : t.aboutOpen,
                    style: const TextStyle(
                        color: BrutalistTheme.primary, fontWeight: FontWeight.w700),
                  ),
                )
              else
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: BrutalistTheme.primary),
                ),
            ],
          ),
          if (_downloading) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _progress < 0 ? null : _progress,
              backgroundColor: BrutalistTheme.primary.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation(BrutalistTheme.primary),
              borderRadius: BorderRadius.circular(4),
            ),
            if (_progress >= 0) ...[
              const SizedBox(height: 4),
              Text('${(_progress * 100).toInt()}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: BrutalistTheme.primary, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center),
            ],
          ],
        ],
      ),
    );
  }

  Widget _upToDateRow(AppLocalizations t) {
    return Row(
      children: [
        const Icon(Icons.check_circle_rounded,
            color: BrutalistTheme.primary, size: 20),
        const SizedBox(width: 8),
        Text(t.aboutUpToDate,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: BrutalistTheme.primary, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
