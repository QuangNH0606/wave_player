import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../styles.dart';

/// Shape options for the slider thumb.
enum ThumbShape {
  /// Standard circular thumb.
  circle,

  /// Tall vertical bar thumb.
  verticalBar,

  /// Vertical bar with rounded corners.
  roundedBar,
}

/// A custom audio slider widget that renders waveform bars with a draggable thumb.
///
/// Displays audio progress over a waveform visualization, with support for
/// different thumb shapes, customizable colors, and animated bar entrance.
///
/// Premium UX features:
/// - Thumb scales up with a spring animation when grabbed
/// - Subtle glow and shadow expand during drag
/// - Waveform bars near the thumb "lift" for a magnetic feel
/// - Haptic feedback on grab, release, and tap-to-seek
class BasicAudioSlider extends StatefulWidget {
  /// Creates a [BasicAudioSlider].
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
    this.animationProgress = 1.0,
  });

  /// Current playback value in milliseconds.
  final double value;

  /// Maximum value (total duration) in milliseconds.
  final double max;

  /// Called when the user drags the slider.
  final ValueChanged<double> onChanged;

  /// Called when the user starts dragging.
  final VoidCallback onChangeStart;

  /// Called when the user stops dragging.
  final VoidCallback onChangeEnd;

  /// Bar heights for the waveform visualization.
  final List<double> waveformData;

  /// Color for the played portion of the waveform.
  final Color? activeColor;

  /// Color for the unplayed portion of the waveform.
  final Color? inactiveColor;

  /// Color of the draggable thumb.
  final Color? thumbColor;

  /// Height of the slider.
  final double height;

  /// Diameter of the thumb.
  final double thumbSize;

  /// Shape of the thumb.
  final ThumbShape thumbShape;

  /// Width of each waveform bar.
  final double barWidth;

  /// Spacing between waveform bars.
  final double barSpacing;

  /// Progress of the waveform entrance animation (0.0–1.0).
  final double animationProgress;

  @override
  State<BasicAudioSlider> createState() => _BasicAudioSliderState();
}

class _BasicAudioSliderState extends State<BasicAudioSlider>
    with TickerProviderStateMixin {
  // --- Thumb grab / release spring ---
  late AnimationController _thumbScaleController;
  late Animation<double> _thumbScaleAnim;

  // --- Glow intensity when dragging ---
  late AnimationController _glowController;
  late Animation<double> _glowAnim;

  bool _isDragging = false;
  double _dragValue = 0.0;

  @override
  void initState() {
    super.initState();

    // Spring-like scale: 1.0 → 1.35 with overshoot
    _thumbScaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _thumbScaleAnim = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(
        parent: _thumbScaleController,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInOutCubic,
      ),
    );

    // Glow intensity: 0.0 → 1.0
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 250),
      reverseDuration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _glowAnim = CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _thumbScaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Progress helpers
  // ---------------------------------------------------------------------------

  double _getProgress() {
    if (_isDragging) {
      return widget.max > 0 ? (_dragValue / widget.max).clamp(0.0, 1.0) : 0.0;
    }
    return widget.max > 0 ? (widget.value / widget.max).clamp(0.0, 1.0) : 0.0;
  }

  // ---------------------------------------------------------------------------
  // Gesture handlers
  // ---------------------------------------------------------------------------

  void _handlePanStart(DragStartDetails details) {
    if (!mounted) return;
    setState(() {
      _isDragging = true;
      _dragValue = widget.value;
    });
    widget.onChangeStart();
    _thumbScaleController.forward();
    _glowController.forward();
    HapticFeedback.lightImpact();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!_isDragging || !mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final local = box.globalToLocal(details.globalPosition);
    final progress = (local.dx / box.size.width).clamp(0.0, 1.0);
    final newValue = progress * widget.max;

    setState(() => _dragValue = newValue);
    widget.onChanged(newValue);
  }

  void _handlePanEnd(DragEndDetails details) {
    if (!_isDragging || !mounted) return;
    setState(() => _isDragging = false);
    _thumbScaleController.reverse();
    _glowController.reverse();
    widget.onChangeEnd();
    HapticFeedback.selectionClick();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!mounted) return;
    // Visual feedback only — no position change, no audio seek
    _thumbScaleController.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final local = box.globalToLocal(details.globalPosition);
    final progress = (local.dx / box.size.width).clamp(0.0, 1.0);
    final newValue = progress * widget.max;

    widget.onChangeStart();
    widget.onChanged(newValue);
    widget.onChangeEnd();
    _thumbScaleController.reverse();
    HapticFeedback.selectionClick();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final progress = _getProgress();
    final activeColor = widget.activeColor ?? WavePlayerColors.primary70;
    final inactiveColor = widget.inactiveColor ?? WavePlayerColors.neutral50;
    final thumbColor = widget.thumbColor ?? WavePlayerColors.black;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: AnimatedBuilder(
        animation: Listenable.merge([_thumbScaleAnim, _glowAnim]),
        builder: (context, _) {
          return CustomPaint(
            painter: BasicAudioSliderPainter(
              waveformData: widget.waveformData,
              progress: progress,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
              thumbColor: thumbColor,
              thumbSize: widget.thumbSize,
              isDragging: _isDragging,
              thumbScale: _thumbScaleAnim.value,
              glowIntensity: _glowAnim.value,
              thumbShape: widget.thumbShape,
              barWidth: widget.barWidth,
              barSpacing: widget.barSpacing,
              animationProgress: widget.animationProgress,
            ),
            size: Size(double.infinity, widget.height),
          );
        },
      ),
    );
  }
}

// =============================================================================
// PAINTER
// =============================================================================

/// Custom painter that draws the waveform bars and thumb for [BasicAudioSlider].
class BasicAudioSliderPainter extends CustomPainter {
  /// Creates a [BasicAudioSliderPainter].
  BasicAudioSliderPainter({
    required this.waveformData,
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
    required this.thumbColor,
    required this.thumbSize,
    required this.isDragging,
    required this.thumbScale,
    required this.glowIntensity,
    required this.thumbShape,
    required this.barWidth,
    required this.barSpacing,
    required this.animationProgress,
  });

  /// Bar heights for the waveform.
  final List<double> waveformData;

  /// Current playback progress (0.0–1.0).
  final double progress;

  /// Color for bars in the played portion.
  final Color activeColor;

  /// Color for bars in the unplayed portion.
  final Color inactiveColor;

  /// Color of the thumb.
  final Color thumbColor;

  /// Diameter of the thumb.
  final double thumbSize;

  /// Whether the user is currently dragging.
  final bool isDragging;

  /// Scale factor for the thumb (animated during drag).
  final double thumbScale;

  /// Glow intensity around the thumb (0.0–1.0, animated during drag).
  final double glowIntensity;

  /// Shape of the thumb.
  final ThumbShape thumbShape;

  /// Width of each waveform bar.
  final double barWidth;

  /// Spacing between waveform bars.
  final double barSpacing;

  /// Progress of the waveform entrance animation (0.0–1.0).
  final double animationProgress;

  // ---------------------------------------------------------------------------
  // Main paint
  // ---------------------------------------------------------------------------

  @override
  void paint(Canvas canvas, Size size) {
    if (waveformData.isEmpty) return;

    final totalBarWidth =
        (barWidth + barSpacing) * waveformData.length - barSpacing;
    final startX = (size.width - totalBarWidth) / 2;

    _drawWaveform(canvas, size, startX);
    _drawThumb(canvas, size, startX, totalBarWidth);
  }

  // ---------------------------------------------------------------------------
  // Waveform bars
  // ---------------------------------------------------------------------------

  void _drawWaveform(Canvas canvas, Size size, double startX) {
    final paint = Paint()..style = PaintingStyle.fill;
    final totalBars = waveformData.length;

    if (animationProgress <= 0) return;

    final exactVisible = totalBars * animationProgress;
    final fullyVisible = exactVisible.floor();

    for (int i = 0; i < totalBars; i++) {
      double entranceOpacity;
      if (i < fullyVisible) {
        entranceOpacity = 1.0;
      } else if (i == fullyVisible) {
        entranceOpacity = Curves.easeOutCubic
            .transform((exactVisible - fullyVisible).clamp(0.0, 1.0));
      } else {
        continue;
      }

      _drawBar(canvas, size, startX, i, paint, entranceOpacity);
    }
  }

  void _drawBar(Canvas canvas, Size size, double startX, int index, Paint paint,
      double entranceOpacity) {
    if (entranceOpacity <= 0.01) return;

    final isPlayed = (index / waveformData.length) <= progress;
    final height = waveformData[index].clamp(4.0, size.height - 4);
    final x = startX + index * (barWidth + barSpacing);

    // Entrance scale only — no proximity distortion
    final scale =
        Curves.easeOutCubic.transform(entranceOpacity.clamp(0.0, 1.0));
    final scaledH = height * (0.4 + 0.6 * scale);
    final y = (size.height - scaledH) / 2;

    // Color
    if (isPlayed) {
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [activeColor, activeColor.withValues(alpha: 0.8)],
      );
      paint.shader =
          gradient.createShader(Rect.fromLTWH(x, y, barWidth, scaledH));
    } else {
      paint.shader = null;
      paint.color = inactiveColor;
    }

    // Entrance opacity
    if (entranceOpacity < 1.0) {
      final c = paint.shader != null ? activeColor : paint.color;
      paint.shader = null;
      paint.color =
          c.withValues(alpha: Curves.easeOut.transform(entranceOpacity));
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, scaledH),
        const Radius.circular(2.0),
      ),
      paint,
    );
  }

  // ---------------------------------------------------------------------------
  // Thumb — clean, no shadow/glow/blur, just the crisp shape
  // ---------------------------------------------------------------------------

  void _drawThumb(
      Canvas canvas, Size size, double startX, double totalBarWidth) {
    if (animationProgress <= 0) return;

    final thumbX = startX + progress * totalBarWidth + barWidth / 2;
    final thumbY = size.height / 2;
    final entranceFade =
        Curves.easeOutCubic.transform(animationProgress.clamp(0.0, 1.0));

    switch (thumbShape) {
      case ThumbShape.circle:
        _drawCircleThumb(canvas, thumbX, thumbY, entranceFade);
      case ThumbShape.verticalBar:
        _drawVerticalBarThumb(canvas, thumbX, thumbY, size, entranceFade);
      case ThumbShape.roundedBar:
        _drawRoundedBarThumb(canvas, thumbX, thumbY, size, entranceFade);
    }
  }

  void _drawCircleThumb(
      Canvas canvas, double cx, double cy, double entranceFade) {
    final radius = (thumbSize * thumbScale) / 2;

    // Solid circle
    canvas.drawCircle(
      Offset(cx, cy),
      radius,
      Paint()..color = thumbColor.withValues(alpha: entranceFade),
    );

    // Center dot
    final dotR = (3.0 * thumbScale).clamp(2.0, 4.5);
    canvas.drawCircle(
      Offset(cx, cy),
      dotR,
      Paint()..color = Colors.white.withValues(alpha: entranceFade),
    );
  }

  void _drawVerticalBarThumb(
      Canvas canvas, double cx, double cy, Size size, double entranceFade) {
    final barH = size.height + 6.0;
    final scaledW =
        (barWidth * thumbScale * 1.2).clamp(barWidth, barWidth * 2.0);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: scaledW, height: barH),
        const Radius.circular(4.0),
      ),
      Paint()..color = thumbColor.withValues(alpha: entranceFade),
    );
  }

  void _drawRoundedBarThumb(
      Canvas canvas, double cx, double cy, Size size, double entranceFade) {
    final barH = size.height + 4.0;
    final scaledW =
        (barWidth * thumbScale * 1.05).clamp(barWidth, barWidth * 2.0);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: scaledW, height: barH),
        const Radius.circular(16.0),
      ),
      Paint()..color = thumbColor.withValues(alpha: entranceFade),
    );

    // Center dot
    final dotR = (2.0 * thumbScale).clamp(1.5, 3.0);
    canvas.drawCircle(
      Offset(cx, cy),
      dotR,
      Paint()..color = Colors.white.withValues(alpha: entranceFade),
    );
  }

  // ---------------------------------------------------------------------------
  // Repaint
  // ---------------------------------------------------------------------------

  @override
  bool shouldRepaint(BasicAudioSliderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isDragging != isDragging ||
        oldDelegate.thumbScale != thumbScale ||
        oldDelegate.glowIntensity != glowIntensity ||
        oldDelegate.thumbShape != thumbShape ||
        oldDelegate.barWidth != barWidth ||
        oldDelegate.barSpacing != barSpacing ||
        oldDelegate.animationProgress != animationProgress;
  }
}
