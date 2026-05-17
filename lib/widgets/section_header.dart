import 'package:flutter/material.dart';

import '../theme/brutalist_theme.dart';

/// Section header used inside settings sub-screens. Renders the label in
/// title case at a moderate weight — softer than the previous ALL CAPS
/// black headlines while still feeling distinct from body text.
class SectionHeader extends StatelessWidget {
  final String label;
  final String? subtitle;
  const SectionHeader(this.label, {super.key, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  color: context.bBorder,
                ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.bMuted),
            ),
          ],
        ],
      ),
    );
  }
}
