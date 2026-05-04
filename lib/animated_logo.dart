import 'package:flutter/material.dart';

class AnimatedLogo extends StatefulWidget {
  const AnimatedLogo({
    super.key,
    this.size = 96,
    this.iconSize = 64,
    this.iconColor = Colors.red,
    this.backgroundColor,
    this.borderColor,
  });

  final double size;
  final double iconSize;
  final Color iconColor;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulse = Tween<double>(
      begin: 0.92,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        widget.backgroundColor ?? Colors.white.withValues(alpha: 0.12);

    final borderColor =
        widget.borderColor ?? Colors.white.withValues(alpha: 0.2);

    return ScaleTransition(
      scale: _pulse,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(widget.size * 0.29),
          border: Border.all(color: borderColor),
        ),
        child: Icon(
          Icons.favorite,
          color: widget.iconColor,
          size: widget.iconSize,
        ),
      ),
    );
  }
}
