import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/backup_service.dart';
import '../../services/review_service.dart';
import '../../theme/brutalist_theme.dart';
import '../../widgets/brutalist_card.dart';
import '../../widgets/section_header.dart';

class DataSettingsScreen extends StatefulWidget {
  const DataSettingsScreen({super.key});

  @override
  State<DataSettingsScreen> createState() => _DataSettingsScreenState();
}

class _DataSettingsScreenState extends State<DataSettingsScreen> {
  User? _user;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _user = AuthService().currentUser;
    AuthService().userStream.listen((u) {
      if (mounted) setState(() => _user = u);
    });
  }

  Future<void> _signIn() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final user = await AuthService().signInWithGoogle();
      if (user != null) {
        messenger.showSnackBar(const SnackBar(content: Text('Signed in')));
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Sign-in failed: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signOut() async {
    final messenger = ScaffoldMessenger.of(context);
    await AuthService().signOut();
    if (mounted) {
      messenger.showSnackBar(const SnackBar(content: Text('Signed out')));
    }
  }

  Future<void> _export() async {
    final messenger = ScaffoldMessenger.of(context);
    final path = await BackupService().exportToShareSheet();
    if (!mounted) return;
    messenger.showSnackBar(SnackBar(
      content: Text(path == null ? 'Export failed' : 'Backup ready to share'),
    ));
  }

  Future<void> _import() async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await BackupService().importFromPicker();
    if (!mounted) return;
    if (result == null) {
      messenger.showSnackBar(const SnackBar(content: Text('Import cancelled or failed')));
    } else {
      messenger.showSnackBar(SnackBar(
        content: Text(
          'Added ${result.knownAdded} known words and ${result.collectionsAdded} new collections',
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account & data')),
      body: _busy
          ? Center(child: CircularProgressIndicator(color: context.bBorder, strokeWidth: 5))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader(
                    'Account',
                    subtitle: 'Sign in to sync known words and collections across devices',
                  ),
                  _user == null ? _signedOutCard() : _signedInCard(),
                  const SizedBox(height: 32),

                  const SectionHeader(
                    'Backup',
                    subtitle: 'Save your known words and collections as a JSON file',
                  ),
                  _backupRow(),
                  const SizedBox(height: 32),

                  const SectionHeader('Feedback'),
                  _rateRow(),
                ],
              ),
            ),
    );
  }

  Widget _signedOutCard() {
    return BrutalistCard(
      backgroundColor: context.bBg,
      onTap: _signIn,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: BrutalistTheme.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.account_circle_outlined,
                  color: BrutalistTheme.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sign in with Google',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  Text('Sync known words, collections & history',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: context.bMuted)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: context.bMuted),
          ],
        ),
      ),
    );
  }

  Widget _signedInCard() {
    return BrutalistCard(
      backgroundColor: BrutalistTheme.primaryLight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: _user!.photoURL != null ? NetworkImage(_user!.photoURL!) : null,
              backgroundColor: BrutalistTheme.primary,
              child: _user!.photoURL == null
                  ? Text(_user!.displayName?[0] ?? '?',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_user!.displayName ?? 'Google user',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600, color: const Color(0xFF2A4A28))),
                  Text(_user!.email ?? '',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF2A4A28).withValues(alpha: 0.7))),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: Color(0xFF2A4A28)),
              tooltip: 'Sign out',
              onPressed: _signOut,
            ),
          ],
        ),
      ),
    );
  }

  Widget _backupRow() {
    return BrutalistCard(
      backgroundColor: context.bBg,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: TextButton.icon(
                icon: const Icon(Icons.upload_file_rounded, color: BrutalistTheme.primary),
                label: const Text('Export',
                    style: TextStyle(color: BrutalistTheme.primary, fontWeight: FontWeight.w700)),
                onPressed: _export,
              ),
            ),
            Container(width: 1, height: 28, color: context.bSubtle),
            Expanded(
              child: TextButton.icon(
                icon: const Icon(Icons.download_rounded, color: BrutalistTheme.primary),
                label: const Text('Import',
                    style: TextStyle(color: BrutalistTheme.primary, fontWeight: FontWeight.w700)),
                onPressed: _import,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rateRow() {
    return BrutalistCard(
      backgroundColor: context.bBg,
      onTap: () => ReviewService().openStoreListing(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: BrutalistTheme.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.star_rate_rounded,
                  color: BrutalistTheme.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text('Rate ELED',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ),
            Icon(Icons.chevron_right_rounded, color: context.bMuted),
          ],
        ),
      ),
    );
  }
}
