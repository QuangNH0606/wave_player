import 'package:flutter/material.dart';
import '../styles.dart';

/// A stateful play/pause button that animates between states.
///
/// Supports three modes:
/// 1. **Custom widgets** — Provide [playIconWidget] and/or [pauseIconWidget]
///    for complete control. Uses [AnimatedSwitcher] with fade+scale transition.
/// 2. **AnimatedIcon** — Provide [animatedIcon] (e.g., `AnimatedIcons.play_pause`)
///    for a morphing animation between states.
/// 3. **Default** — Falls back to `AnimatedIcons.play_pause`.
class PlayPauseButton extends StatefulWidget {
  /// Creates a [PlayPauseButton].
  const PlayPauseButton({
    super.key,
    required this.isPlaying,
    this.playIconWidget,
    this.pauseIconWidget,
    this.iconColor,
    this.animatedIcon,
    this.iconSize = 22.0,
  });

  /// Whether the button should show the "playing" state.
  final bool isPlaying;

  /// Custom widget to show when paused (play icon).
  final Widget? playIconWidget;

  /// Custom widget to show when playing (pause icon).
  final Widget? pauseIconWidget;

  /// Color for the default animated icon.
  final Color? iconColor;

  /// Custom [AnimatedIconData] for the morphing animation.
  final AnimatedIconData? animatedIcon;

  /// Size of the icon. Defaults to 22.0.
  final double iconSize;

  @override
  State<PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<PlayPauseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    if (widget.isPlaying) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant PlayPauseButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.forward();
      } else {
        _controller.reverse();
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
    // If custom widgets are provided, use AnimatedSwitcher
    if (widget.playIconWidget != null || widget.pauseIconWidget != null) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.9,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: child,
            ),
          );
        },
        child: widget.isPlaying
            ? KeyedSubtree(
                key: const ValueKey('custom_pause'),
                child: widget.pauseIconWidget!,
              )
            : KeyedSubtree(
                key: const ValueKey('custom_play'),
                child: widget.playIconWidget!,
              ),
      );
    }

    // Fallback to default animated icon
    return AnimatedIcon(
      icon: widget.animatedIcon ?? AnimatedIcons.play_pause,
      progress: _controller,
      color: widget.iconColor ?? WavePlayerColors.white,
      size: widget.iconSize,
    );
  }
}
