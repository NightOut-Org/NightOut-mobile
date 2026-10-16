import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../motion.dart';
import '../theme/theme.dart';

class LoadWidget extends StatefulWidget {
  const LoadWidget({
    super.key,
    this.colors = const [],
    this.size = 40,
    this.strokeWidth = 5,
    this.duration = const Duration(milliseconds: 1100),
  });

  /// Empty means the theme's gold.
  final List<Color> colors;
  final double size;
  final double strokeWidth;
  final Duration duration;

  @override
  State<LoadWidget> createState() => _LoadWidgetState();
}

class _LoadWidgetState extends State<LoadWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncSpin();
  }

  @override
  void didUpdateWidget(covariant LoadWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
      _syncSpin(restart: true);
    }
  }

  /// Reduced motion shows a still ring.
  void _syncSpin({bool restart = false}) {
    if (context.reduceMotion) {
      _controller.stop();
    } else if (restart || !_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ring = CustomPaint(
      painter: _RingPainter(
        colors: widget.colors.isEmpty ? [context.colors.gold] : widget.colors,
        strokeWidth: widget.strokeWidth,
      ),
    );
    return SizedBox.square(
      dimension: widget.size,
      child: context.reduceMotion
          ? ring
          : RotationTransition(turns: _controller, child: ring),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.colors, required this.strokeWidth});

  final List<Color> colors;
  final double strokeWidth;

  static const double _sweepRatio = 0.94;

  List<Color> get _gradientColors {
    if (colors.length == 1) return _fade(colors.first);
    return colors;
  }

  List<Color> _fade(Color color) => [
    color.withValues(alpha: 0),
    color.withValues(alpha: 0.12),
    color.withValues(alpha: 0.5),
    color,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final radius = (size.shortestSide - strokeWidth) / 2;
    if (radius <= 0) return;

    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: radius,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: _gradientColors,
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect);

    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * _sweepRatio, false, paint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.strokeWidth != strokeWidth ||
        !listEquals(oldDelegate.colors, colors);
  }
}
