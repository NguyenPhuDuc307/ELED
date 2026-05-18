import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import '../theme/brutalist_theme.dart';

/// Reference doc the user can revisit after the first-launch onboarding.
/// Categorised expansion tiles instead of long prose so they can scan to the
/// concept they're stuck on.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _topicIcons = <IconData>[
    Icons.school_rounded,
    Icons.bolt_rounded,
    Icons.tune_rounded,
    Icons.auto_awesome_rounded,
    Icons.casino_rounded,
    Icons.check_circle_outline_rounded,
    Icons.local_fire_department_rounded,
    Icons.notifications_active_rounded,
    Icons.apps_rounded,
    Icons.search_rounded,
    Icons.cloud_sync_rounded,
    Icons.file_upload_outlined,
    Icons.videogame_asset_rounded,
    Icons.tune_rounded,
  ];

  List<_HelpTopic> _topics(AppLocalizations t) => [
        _HelpTopic(icon: _topicIcons[0], title: t.helpTopic1Title, body: t.helpTopic1Body),
        _HelpTopic(icon: _topicIcons[1], title: t.helpTopic2Title, body: t.helpTopic2Body),
        _HelpTopic(icon: _topicIcons[2], title: t.helpTopic3Title, body: t.helpTopic3Body),
        _HelpTopic(icon: _topicIcons[3], title: t.helpTopic4Title, body: t.helpTopic4Body),
        _HelpTopic(icon: _topicIcons[4], title: t.helpTopic5Title, body: t.helpTopic5Body),
        _HelpTopic(icon: _topicIcons[5], title: t.helpTopic6Title, body: t.helpTopic6Body),
        _HelpTopic(icon: _topicIcons[6], title: t.helpTopic7Title, body: t.helpTopic7Body),
        _HelpTopic(icon: _topicIcons[7], title: t.helpTopic8Title, body: t.helpTopic8Body),
        _HelpTopic(icon: _topicIcons[8], title: t.helpTopic9Title, body: t.helpTopic9Body),
        _HelpTopic(icon: _topicIcons[9], title: t.helpTopic10Title, body: t.helpTopic10Body),
        _HelpTopic(icon: _topicIcons[10], title: t.helpTopic11Title, body: t.helpTopic11Body),
        _HelpTopic(icon: _topicIcons[11], title: t.helpTopic12Title, body: t.helpTopic12Body),
        _HelpTopic(icon: _topicIcons[12], title: t.helpTopic13Title, body: t.helpTopic13Body),
        _HelpTopic(icon: _topicIcons[13], title: t.helpTopic14Title, body: t.helpTopic14Body),
      ];

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final topics = _topics(t);
    return Scaffold(
      appBar: AppBar(title: Text(t.helpAppBarTitle)),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: topics.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (_, i) => _topicTile(context, topics[i]),
      ),
    );
  }

  Widget _topicTile(BuildContext context, _HelpTopic topic) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: context.bBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.bSubtle, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: BrutalistTheme.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(topic.icon, color: BrutalistTheme.primary, size: 20),
          ),
          title: Text(
            topic.title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
          ),
          children: [
            Text(
              topic.body,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.bBorder,
                    height: 1.5,
                    fontSize: 14,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpTopic {
  final IconData icon;
  final String title;
  final String body;
  const _HelpTopic({required this.icon, required this.title, required this.body});
}
