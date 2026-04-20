import 'package:flutter/material.dart';
import '../theme/brutalist_theme.dart';

class BrutalistCard extends StatefulWidget {
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
  State<BrutalistCard> createState() => _BrutalistCardState();
}

class _BrutalistCardState extends State<BrutalistCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveBg = widget.backgroundColor ?? context.bBg;
    final isNeon = effectiveBg == BrutalistTheme.primary ||
        effectiveBg == BrutalistTheme.secondary ||
        effectiveBg == BrutalistTheme.accent;

    Widget content = widget.child;
    if (isNeon) {
      content = Theme(data: BrutalistTheme.lightTheme, child: content);
    }

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: widget.onTap != null ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.onTap != null ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: widget.onTap != null ? () => setState(() => _isPressed = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        margin: _isPressed
            ? const EdgeInsets.only(top: 4, left: 4, bottom: 8, right: 4)
            : const EdgeInsets.only(bottom: 12, right: 8),
        decoration: BoxDecoration(
          color: effectiveBg,
          border: Border.all(color: context.bBorder, width: 4),
          boxShadow: _isPressed
              ? []
              : [
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
