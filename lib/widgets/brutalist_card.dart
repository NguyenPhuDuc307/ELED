import 'package:flutter/material.dart';
import '../theme/brutalist_theme.dart';

class BrutalistCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const BrutalistCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? context.bBg;
    final isNeon = effectiveBg == BrutalistTheme.primary ||
        effectiveBg == BrutalistTheme.secondary ||
        effectiveBg == BrutalistTheme.accent;

    Widget content = child;

    if (isNeon) {
      content = Theme(
        data: BrutalistTheme.lightTheme,
        child: child,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, right: 8),
        decoration: BoxDecoration(
          color: effectiveBg,
          border: Border.all(color: context.bBorder, width: 4),
          boxShadow: [
            BoxShadow(
              color: context.bBorder,
              offset: const Offset(8, 8),
              blurRadius: 0,
              spreadRadius: 0,
            ),
          ],
        ),
        child: content,
      ),
    );
  }
}
