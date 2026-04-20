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

class _BrutalistCardState extends State<BrutalistCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 150),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onTap != null) _controller.forward();
  }

  void _onTapUp(TapUpDetails _) {
    if (widget.onTap != null) _controller.reverse();
  }

  void _onTapCancel() {
    if (widget.onTap != null) _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBg = widget.backgroundColor ?? context.bBg;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          margin: const EdgeInsets.fromLTRB(4, 2, 4, 10),
          decoration: BoxDecoration(
            color: effectiveBg,
            borderRadius: BorderRadius.circular(20),
            border: isDark
                ? Border.all(color: const Color(0xFF334155), width: 1)
                : Border.all(color: const Color(0xFFEDE0D8).withValues(alpha: 0.8), width: 1),
            boxShadow: isDark
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: const Color(0xFF7A5C4A).withValues(alpha: 0.10),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: const Color(0xFF7A5C4A).withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
