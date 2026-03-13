// Internal widget — not exported as public API.
// ignore_for_file: public_member_api_docs

import 'dart:async' show unawaited;
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ButtonGlow extends StatefulWidget {
  const ButtonGlow({
    super.key,
    required this.child,
    this.glowCount = 2,
    this.glowColor = const Color(0xFF007AFF),
    this.glowShape = BoxShape.circle,
    this.glowBorderRadius,
    this.duration = const Duration(milliseconds: 800),
    this.startDelay,
    this.animate = true,
    this.repeat = true,
    this.curve = Curves.fastOutSlowIn,
    this.glowRadiusFactor = 0.25,
  });
  final Widget child;
  final int glowCount;
  final Color glowColor;
  final BoxShape glowShape;
  final BorderRadius? glowBorderRadius;
  final Duration duration;
  final Duration? startDelay;
  final bool animate;
  final bool repeat;
  final Curve curve;

  final double glowRadiusFactor;

  @override
  State<ButtonGlow> createState() => _ButtonGlowState();
}

class _ButtonGlowState extends State<ButtonGlow>
    with SingleTickerProviderStateMixin<ButtonGlow> {
  late final AnimationController _controller;
  late final _GlowPainter _painter;
  late final Tween<double> _opacityTween = Tween<double>(begin: 0.3, end: 0);

  Future<void> _startAnimation() async {
    final startDelay = widget.startDelay;
    if (startDelay != null) {
      await Future<void>.delayed(startDelay);
    }

    if (mounted) {
      if (widget.repeat) {
        unawaited(_controller.repeat());
      } else {
        unawaited(_controller.forward());
      }
    }
  }

  void _stopAnimation() {
    unawaited(_controller.reverse().then((_) {
      if (mounted) {
        _controller.stop();
      }
    }));
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _painter = _GlowPainter(progress: _controller);

    if (widget.animate) {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(covariant ButtonGlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }

    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _startAnimation();
      } else {
        _stopAnimation();
      }
    }

    if (widget.repeat != oldWidget.repeat) {
      if (widget.repeat) {
        unawaited(_controller.repeat());
      } else {
        unawaited(_controller.forward());
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _painter
          ..curve = widget.curve
          ..opacityTween = _opacityTween
          ..glowCount = widget.glowCount
          ..glowDecoration = BoxDecoration(
            color: widget.glowColor,
            shape: widget.glowShape,
            borderRadius: widget.glowBorderRadius,
          )
          ..glowRadiusFactor = widget.glowRadiusFactor,
        child: widget.child,
      ),
    );
  }
}

class _GlowPainter extends ChangeNotifier implements CustomPainter {
  _GlowPainter({required this.progress}) {
    progress.addListener(notifyListeners);
  }

  final Animation<double> progress;

  Curve get curve => _curve!;
  Curve? _curve;

  set curve(Curve value) {
    if (_curve != value) {
      _curve = value;
      notifyListeners();
    }
  }

  Tween<double> get opacityTween => _opacityTween!;
  Tween<double>? _opacityTween;

  set opacityTween(Tween<double> value) {
    if (_opacityTween != value) {
      _opacityTween = value;
      notifyListeners();
    }
  }

  int get glowCount => _glowCount!;
  int? _glowCount;

  set glowCount(int value) {
    if (_glowCount != value) {
      _glowCount = value;
      notifyListeners();
    }
  }

  BoxDecoration get glowDecoration => _glowDecoration!;
  BoxDecoration? _glowDecoration;

  set glowDecoration(BoxDecoration value) {
    if (_glowDecoration != value) {
      _glowDecoration = value;
      notifyListeners();
    }
  }

  double get glowRadiusFactor => _glowRadiusFactor!;
  double? _glowRadiusFactor;

  set glowRadiusFactor(double value) {
    if (_glowRadiusFactor != value) {
      _glowRadiusFactor = value;
      notifyListeners();
    }
  }

  final Path _glowPath = Path();

  @override
  void paint(Canvas canvas, Size size) {
    final glowColor = glowDecoration.color!;
    final opacity = opacityTween.evaluate(progress);

    final paint = Paint()
      ..color = glowColor.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    final glowSize = math.min(size.width, size.height);
    final glowRadius = glowSize / 2;

    final currentProgress = curve.transform(progress.value);

    _glowPath.reset();

    for (int i = 1; i <= glowCount; i++) {
      final currentRadius =
          glowRadius + glowRadius * glowRadiusFactor * i * currentProgress;

      final currentRect = Rect.fromCircle(
        center: size.center(Offset.zero),
        radius: currentRadius,
      );

      _addGlowPath(currentRect);
      canvas.drawPath(_glowPath, paint);
    }
  }

  void _addGlowPath(Rect glowRect) {
    _glowPath.addPath(
      glowDecoration.getClipPath(
        glowRect,
        TextDirection.ltr,
      ),
      Offset.zero,
    );
  }

  @override
  void dispose() {
    progress.removeListener(notifyListeners);
    super.dispose();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  @override
  bool? hitTest(Offset position) => null;

  @override
  SemanticsBuilderCallback? get semanticsBuilder => null;

  @override
  bool shouldRebuildSemantics(covariant CustomPainter oldDelegate) => false;

  @override
  String toString() => describeIdentity(this);
}
