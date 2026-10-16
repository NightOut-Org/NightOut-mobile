import 'package:flutter/material.dart';
import 'package:nightout/models/app/splash.model.dart';

/// เลื่อนเข้าพร้อม fade in หลังเฟรมแรก — ต้องอยู่ภายใต้ [Stack]
class TFadeInAnimation extends StatefulWidget {
  const TFadeInAnimation({
    super.key,
    required this.durationInMs,
    this.animationPosition,
    this.delay = Duration.zero,
    required this.child,
  });

  final int durationInMs;
  final TAnimationPosition? animationPosition;
  final Duration delay;
  final Widget child;

  @override
  State<TFadeInAnimation> createState() => _TFadeInAnimationState();
}

class _TFadeInAnimationState extends State<TFadeInAnimation> {
  bool _animate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.delay > Duration.zero) {
        await Future<void>.delayed(widget.delay);
      }
      if (!mounted) return;
      setState(() => _animate = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final position = widget.animationPosition;
    final duration = Duration(milliseconds: widget.durationInMs);

    return AnimatedPositioned(
      duration: duration,
      curve: Curves.easeOutCubic,
      top: _animate ? position?.topAfter : position?.topBefore,
      left: _animate ? position?.leftAfter : position?.leftBefore,
      bottom: _animate ? position?.bottomAfter : position?.bottomBefore,
      right: _animate ? position?.rightAfter : position?.rightBefore,
      child: AnimatedOpacity(
        duration: duration,
        opacity: _animate ? 1 : 0,
        child: widget.child,
      ),
    );
  }
}
