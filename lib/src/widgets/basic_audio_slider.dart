import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../styles.dart';

enum ThumbShape {
  circle,
  verticalBar,
  roundedBar,
}

class BasicAudioSlider extends StatefulWidget {
  const BasicAudioSlider({
    super.key,
    required this.value,
    required this.max,
    required this.onChanged,
    required this.onChangeStart,
    required this.onChangeEnd,
    required this.waveformData,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
    this.height = 20.0,
    this.thumbSize = 20.0,
    this.thumbShape = ThumbShape.circle,
    this.barWidth = 4.0,
    this.barSpacing = 1.0,
    this.animationProgress = 1.0, // 0.0 = not animated, 1.0 = fully animated
  });

  final double value;
  final double max;
  final ValueChanged<double> onChanged;
  final VoidCallback onChangeStart;
  final VoidCallback onChangeEnd;
  final List<double> waveformData;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? thumbColor;
  final double height;
  final double thumbSize;
  final ThumbShape thumbShape;
  final double barWidth;
  final double barSpacing;
  final double animationProgress;

  @override
  State<BasicAudioSlider> createState() => _BasicAudioSliderState();
}

class _BasicAudioSliderState extends State<BasicAudioSlider>
    with TickerProviderStateMixin {
  late AnimationController _thumbAnimationController;
  late Animation<double> _thumbScaleAnimation;

  bool _isDragging = false;
  double _dragValue = 0.0;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _thumbAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _thumbScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _thumbAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _thumbAnimationController.dispose();
    super.dispose();
  }

  double _getProgress() {
    if (_isDragging) {
      return widget.max > 0 ? (_dragValue / widget.max).clamp(0.0, 1.0) : 0.0;
    }

    // Return exact progress without interpolation to maintain sync with audio
    return widget.max > 0 ? (widget.value / widget.max).clamp(0.0, 1.0) : 0.0;
  }

  void _handlePanStart(DragStartDetails details) {
    if (!mounted) return;

    setState(() {
      _isDragging = true;
      _dragValue = widget.value;
    });

    widget.onChangeStart();
    _thumbAnimationController.forward();
    HapticFeedback.lightImpact();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!_isDragging || !mounted) return;

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final localPosition = renderBox.globalToLocal(details.globalPosition);
    final trackWidth = renderBox.size.width;

    final progress = (localPosition.dx / trackWidth).clamp(0.0, 1.0);
    final newValue = progress * widget.max;

    setState(() {
      _dragValue = newValue;
    });

    widget.onChanged(newValue);
  }

  void _handlePanEnd(DragEndDetails details) {
    if (!_isDragging || !mounted) return;

    setState(() {
      _isDragging = false;
    });

    _thumbAnimationController.reverse();
    widget.onChangeEnd();
    HapticFeedback.selectionClick();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!mounted) return;

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final localPosition = renderBox.globalToLocal(details.globalPosition);
    final trackWidth = renderBox.size.width;

    final progress = (localPosition.dx / trackWidth).clamp(0.0, 1.0);
    final newValue = progress * widget.max;

    widget.onChangeStart();
    widget.onChanged(newValue);
    widget.onChangeEnd();

    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _getProgress();
    final activeColor = widget.activeColor ?? WavePlayerColors.primary70;
    final inactiveColor = widget.inactiveColor ?? WavePlayerColors.neutral50;
    final thumbColor = widget.thumbColor ?? WavePlayerColors.black;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: SizedBox(
        height: widget.height,
        child: CustomPaint(
          painter: BasicAudioSliderPainter(
            waveformData: widget.waveformData,
            progress: progress,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
            thumbColor: thumbColor,
            thumbSize: widget.thumbSize,
            isDragging: _isDragging,
            thumbScale: _thumbScaleAnimation.value,
            thumbShape: widget.thumbShape,
            barWidth: widget.barWidth,
            barSpacing: widget.barSpacing,
            animationProgress: widget.animationProgress,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class BasicAudioSliderPainter extends CustomPainter {
  BasicAudioSliderPainter({
    required this.waveformData,
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
    required this.thumbColor,
    required this.thumbSize,
    required this.isDragging,
    required this.thumbScale,
    required this.thumbShape,
    required this.barWidth,
    required this.barSpacing,
    required this.animationProgress,
  });

  final List<double> waveformData;
  final double progress;
  final Color activeColor;
  final Color inactiveColor;
  final Color thumbColor;
  final double thumbSize;
  final bool isDragging;
  final double thumbScale;
  final ThumbShape thumbShape;
  final double barWidth;
  final double barSpacing;
  final double animationProgress;

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate waveform dimensions
    final totalBarWidth =
        (barWidth + barSpacing) * waveformData.length - barSpacing;
    final startX = (size.width - totalBarWidth) / 2;

    // Draw waveform bars
    _drawWaveform(canvas, size, startX, barWidth, barSpacing);

    // Draw thumb
    _drawThumb(canvas, size, startX, totalBarWidth);
  }

  void _drawWaveform(Canvas canvas, Size size, double startX, double barWidth,
      double barSpacing) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Simple and smooth bar-by-bar animation
    final totalBars = waveformData.length;
    final visibleBars = (totalBars * animationProgress).round();

    // Don't draw anything if animationProgress is 0
    if (animationProgress <= 0) return;

    for (int i = 0; i < totalBars; i++) {
      if (i < visibleBars) {
        // Bar is fully visible
        _drawWaveformBarWithOpacity(
            canvas, size, startX, barWidth, barSpacing, i, paint, 1.0);
      } else if (i == visibleBars && animationProgress > 0) {
        // Current bar is animating in
        final partialProgress = (totalBars * animationProgress) - visibleBars;
        final clampedPartialProgress = partialProgress.clamp(0.0, 1.0);
        final smoothProgress = Curves.easeOut.transform(clampedPartialProgress);
        _drawWaveformBarWithOpacity(canvas, size, startX, barWidth, barSpacing,
            i, paint, smoothProgress);
      }
      // Bars after visibleBars are not drawn yet
    }
  }

  void _drawWaveformBarWithOpacity(
      Canvas canvas,
      Size size,
      double startX,
      double barWidth,
      double barSpacing,
      int index,
      Paint paint,
      double opacity) {
    // Don't draw if opacity is too low
    if (opacity <= 0.01) return;

    final barProgress = index / waveformData.length;
    final isPlayed = barProgress <= progress;

    final height = waveformData[index].clamp(4.0, size.height - 4);
    final x = startX + index * (barWidth + barSpacing);
    final y = (size.height - height) / 2;

    // Apply subtle scale effect for smooth appearance
    final clampedOpacity = opacity.clamp(0.0, 1.0);
    final scale = Curves.easeOut.transform(clampedOpacity);
    final scaledHeight = height * (0.3 + 0.7 * scale); // Scale from 30% to 100%
    final scaledY = y + (height - scaledHeight) / 2;

    // Configure paint first, then apply opacity
    _configureBarPaint(paint, isPlayed, x, scaledY, barWidth, scaledHeight);

    // Apply opacity to the final color
    final originalColor = paint.color;
    paint.color = originalColor.withValues(alpha: opacity);

    _drawBarWithRoundedCorners(
        canvas, x, scaledY, barWidth, scaledHeight, paint);

    // Restore original color
    paint.color = originalColor;
  }

  void _configureBarPaint(Paint paint, bool isPlayed, double x, double y,
      double barWidth, double height) {
    if (isPlayed) {
      _applyGradientShader(paint, x, y, barWidth, height);
    } else {
      paint.shader = null;
      paint.color = inactiveColor;
    }
  }

  void _applyGradientShader(
      Paint paint, double x, double y, double barWidth, double height) {
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        activeColor,
        activeColor.withValues(alpha: 0.8),
      ],
    );
    final rect = Rect.fromLTWH(x, y, barWidth, height);
    paint.shader = gradient.createShader(rect);
  }

  void _drawBarWithRoundedCorners(Canvas canvas, double x, double y,
      double barWidth, double height, Paint paint) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, height),
        const Radius.circular(2.0),
      ),
      paint,
    );
  }

  void _drawThumb(
      Canvas canvas, Size size, double startX, double totalBarWidth) {
    // Don't draw thumb if animation hasn't started
    if (animationProgress <= 0) return;

    // Smooth thumb movement with slight anticipation
    final targetX = startX + progress * totalBarWidth + (barWidth / 2);
    final thumbX = targetX;
    final thumbY = size.height / 2;

    final shadowPaint = _createShadowPaint();
    final thumbPaint = _createThumbPaint();

    // Apply opacity to thumb based on animation progress
    final clampedProgress = animationProgress.clamp(0.0, 1.0);
    final thumbOpacity = Curves.easeOut.transform(clampedProgress);
    final originalShadowAlpha = shadowPaint.color.a.toDouble();
    final originalThumbAlpha = thumbPaint.color.a.toDouble();

    shadowPaint.color = shadowPaint.color
        .withValues(alpha: (originalShadowAlpha * thumbOpacity));
    thumbPaint.color =
        thumbPaint.color.withValues(alpha: (originalThumbAlpha * thumbOpacity));

    _drawThumbByShape(canvas, thumbX, thumbY, size, shadowPaint, thumbPaint);

    // Restore original alpha values
    shadowPaint.color =
        shadowPaint.color.withValues(alpha: originalShadowAlpha);
    thumbPaint.color = thumbPaint.color.withValues(alpha: originalThumbAlpha);
  }

  Paint _createShadowPaint() {
    return Paint()
      ..color = thumbColor.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
  }

  Paint _createThumbPaint() {
    return Paint()
      ..color = thumbColor
      ..style = PaintingStyle.fill;
  }

  void _drawThumbByShape(Canvas canvas, double thumbX, double thumbY, Size size,
      Paint shadowPaint, Paint thumbPaint) {
    switch (thumbShape) {
      case ThumbShape.circle:
        _drawCircleThumb(canvas, thumbX, thumbY, shadowPaint, thumbPaint);
        break;
      case ThumbShape.verticalBar:
        _drawVerticalBarThumb(
            canvas, thumbX, thumbY, size, shadowPaint, thumbPaint);
        break;
      case ThumbShape.roundedBar:
        _drawRoundedBarThumb(
            canvas, thumbX, thumbY, size, shadowPaint, thumbPaint);
        break;
    }
  }

  void _drawCircleThumb(Canvas canvas, double thumbX, double thumbY,
      Paint shadowPaint, Paint thumbPaint) {
    // Draw shadow
    canvas.drawCircle(
      Offset(thumbX, thumbY),
      (thumbSize * thumbScale) / 2 + 2,
      shadowPaint,
    );

    // Draw thumb
    canvas.drawCircle(
      Offset(thumbX, thumbY),
      (thumbSize * thumbScale) / 2,
      thumbPaint,
    );

    // Draw center dot
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(thumbX, thumbY),
      3.0,
      dotPaint,
    );
  }

  void _drawVerticalBarThumb(Canvas canvas, double thumbX, double thumbY,
      Size size, Paint shadowPaint, Paint thumbPaint) {
    final barHeight = size.height + 6.0;
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(thumbX, thumbY),
        width: barWidth * thumbScale,
        height: barHeight,
      ),
      const Radius.circular(2.0),
    );

    canvas.drawRRect(rect, thumbPaint);
  }

  void _drawRoundedBarThumb(Canvas canvas, double thumbX, double thumbY,
      Size size, Paint shadowPaint, Paint thumbPaint) {
    final barHeight = size.height + 4.0;
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(thumbX, thumbY),
        width: barWidth * thumbScale,
        height: barHeight,
      ),
      const Radius.circular(3.0),
    );

    // Draw shadow
    final shadowRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(thumbX, thumbY),
        width: (barWidth + 2) * thumbScale,
        height: barHeight + 2,
      ),
      const Radius.circular(4.0),
    );
    canvas.drawRRect(shadowRect, shadowPaint);

    // Draw thumb
    canvas.drawRRect(rect, thumbPaint);

    // Draw center dot
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(thumbX, thumbY),
      2.0,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(BasicAudioSliderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isDragging != isDragging ||
        oldDelegate.thumbScale != thumbScale ||
        oldDelegate.thumbShape != thumbShape ||
        oldDelegate.barWidth != barWidth ||
        oldDelegate.barSpacing != barSpacing ||
        oldDelegate.animationProgress != animationProgress;
  }
}
