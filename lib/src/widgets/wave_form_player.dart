import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../services/audio_manager.dart';
import '../services/waveform_generator.dart';
import '../styles.dart';
import 'button_glow.dart';
import 'basic_audio_slider.dart';
import 'waveform_player_controller.dart';

/// A customizable audio waveform player widget
/// A complete waveform player widget with audio visualization, play/pause controls,
/// and extensive customization options.
///
/// This widget provides a comprehensive audio player interface with:
/// - Real-time waveform visualization
/// - Customizable progress slider with multiple thumb shapes
/// - Play/pause controls with animated effects
/// - Duration display
/// - Extensive theming and styling options
///
/// Example:
/// ```dart
/// // Using URL
/// WaveformPlayer(
///   audioUrl: 'https://example.com/audio.mp3',
///   waveformHeight: 24.0,
///   thumbSize: 16.0,
///   thumbShape: ThumbShape.verticalBar,
///   activeColor: Colors.blue,
///   inactiveColor: Colors.grey,
///   playIconWidget: Icon(Icons.play_circle_filled),
///   pauseIconWidget: Icon(Icons.pause_circle_filled),
///   // Or use AnimatedIcons for morphing animation:
///   animatedIcon: AnimatedIcons.play_pause,
///   iconSize: 24.0, // Clamped between 12.0 and 40.0
/// )
///
/// // Using Asset
/// WaveformPlayer(
///   assetPath: 'assets/audio/sample.mp3',
///   waveformHeight: 24.0,
///   thumbSize: 16.0,
///   thumbShape: ThumbShape.verticalBar,
///   activeColor: Colors.blue,
///   inactiveColor: Colors.grey,
///   glowColor: Colors.blue,
///   glowDuration: Duration(milliseconds: 1500),
///   glowRadiusFactor: 0.3,
///   glowCount: 3,
///   showGlow: true,
/// )
///
/// // Using Controller
/// final controller = WaveformPlayerController();
/// WaveformPlayer(
///   audioUrl: 'https://example.com/audio.mp3',
///   controller: controller,
/// )
/// // Later: controller.play(), controller.pause(), etc.
/// ```
class WaveformPlayer extends StatefulWidget {
  const WaveformPlayer({
    super.key,
    this.audioUrl,
    this.assetPath,
    this.controller,
    this.waveformHeight = 24.0,
    this.thumbSize = 16.0,
    this.thumbShape = ThumbShape.verticalBar,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
    this.backgroundColor,
    this.showPlayButton = true,
    this.showDuration = true,
    this.autoPlay = false,
    this.playButtonSize = 40.0,
    this.playButtonColor,
    this.playButtonIconColor,
    this.playIconWidget,
    this.pauseIconWidget,
    this.animatedIcon,
    this.iconSize,
    this.durationTextStyle,
    this.borderColor,
    this.animationDuration = const Duration(milliseconds: 200),
    this.onPlayPause,
    this.onPositionChanged,
    this.onCompleted,
    this.onError,
    this.glowColor,
    this.glowDuration = const Duration(milliseconds: 1000),
    this.glowRadiusFactor = 0.25,
    this.glowCount = 2,
    this.showGlow = true,
    this.barWidth = 4.0,
    this.barSpacing = 1.0,
  }) : assert(
          (audioUrl != null) != (assetPath != null),
          'WaveformPlayer: You must provide either audioUrl OR assetPath, but not both. '
          'Use audioUrl for remote URLs or assetPath for local assets.',
        );

  /// URL of the audio file to play
  final String? audioUrl;

  /// Asset path of the audio file to play
  final String? assetPath;

  /// Controller for programmatic control
  final WaveformPlayerController? controller;

  /// Height of the waveform visualization
  final double waveformHeight;

  /// Size of the draggable thumb
  final double thumbSize;

  /// Shape of the thumb (circle, verticalBar, etc.)
  final ThumbShape thumbShape;

  /// Color for the active (played) portion of the waveform
  final Color? activeColor;

  /// Color for the inactive (unplayed) portion of the waveform
  final Color? inactiveColor;

  /// Color of the draggable thumb
  final Color? thumbColor;

  /// Background color of the player container
  final Color? backgroundColor;

  /// Whether to show the play/pause button
  final bool showPlayButton;

  /// Whether to show the duration text
  final bool showDuration;

  /// Whether to auto-play when loaded
  final bool autoPlay;

  /// Size of the play/pause button
  final double playButtonSize;

  /// Color of the play/pause button background
  final Color? playButtonColor;

  /// Color of the play/pause button icon
  final Color? playButtonIconColor;

  /// Custom widget for play icon
  final Widget? playIconWidget;

  /// Custom widget for pause icon
  final Widget? pauseIconWidget;

  /// Custom AnimatedIcons for play/pause animation
  final AnimatedIconData? animatedIcon;

  /// Size of the play/pause icon (clamped between 12.0 and 40.0)
  final double? iconSize;

  /// Text style for duration display
  final TextStyle? durationTextStyle;

  /// Color of the border
  final Color? borderColor;

  /// Duration of animations (play button, etc.)
  final Duration animationDuration;

  /// Callback when play/pause state changes
  final ValueChanged<bool>? onPlayPause;

  /// Callback when position changes during playback
  final ValueChanged<Duration>? onPositionChanged;

  /// Callback when playback completes
  final VoidCallback? onCompleted;

  /// Callback when an error occurs
  final ValueChanged<String>? onError;

  /// Color of the play/pause button glow
  final Color? glowColor;

  /// Duration of the glow animation
  final Duration glowDuration;

  /// Radius factor of the glow effect (0.0 to 1.0)
  final double glowRadiusFactor;

  /// Number of glow rings
  final int glowCount;

  /// Whether to show glow effect
  final bool showGlow;

  /// Width of each waveform bar
  final double barWidth;

  /// Spacing between waveform bars
  final double barSpacing;

  @override
  State<WaveformPlayer> createState() => _WaveformPlayerState();
}

class _WaveformPlayerState extends State<WaveformPlayer>
    with TickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isLoading = true;
  List<double> _waveformData = [];
  bool _isSeeking = false;
  Timer? _debounceTimer;
  double? _lastGeneratedWidth;
  bool _audioInitialized = false;
  bool _hasAnimatedWaveform = false;
  bool _isWaveformAnimating = false;
  bool _hasError = false;
  String? _errorMessage;
  double? _cachedWaveformWidth;
  static final Map<String, List<double>> _waveformCache = {};

  // Animation
  late AnimationController _animationController;
  late AnimationController _waveformAnimationController;

  @override
  void initState() {
    super.initState();
    widget.controller?.attach(this);
    _initAnimation();
    _initAudio();
    _setupAudioManagerListener();
  }

  void _setupAudioManagerListener() {
    AudioManager().setOnCurrentPlayerChanged(() {
      if (mounted) {
        setState(() {
          _isPlaying = AudioManager().currentPlayer == _audioPlayer &&
              AudioManager().isPlaying;
        });
      }
    });
  }

  /// Gets the audio source (URL or asset path)
  String get _audioSource {
    return widget.audioUrl ?? widget.assetPath!;
  }

  /// Checks if the audio source is an asset
  bool get _isAssetSource {
    return widget.assetPath != null;
  }

  void _initAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 16), // 60fps for play button
      vsync: this,
    );
    _waveformAnimationController = AnimationController(
      duration: const Duration(
          milliseconds: 350), // 0.4 seconds for smooth waveform drawing
      vsync: this,
    );
  }

  void _updatePositionWithAnimation(Duration position) {
    _updateDurationIfNeeded();

    if (_shouldAutoStop(position)) {
      _handleAutoStop();
      return;
    }

    if (_isPlaying && position != _position) {
      _updatePosition(position);
      // Only animate play button, not waveform
      if (!_isWaveformAnimating) {
        _animationController.forward(from: 0.0);
      }
    }
  }

  void _updateDurationIfNeeded() {
    final currentDuration = _audioPlayer.duration;
    if (currentDuration != null && currentDuration != _duration) {
      _duration = currentDuration;
    }
  }

  bool _shouldAutoStop(Duration position) {
    final currentDuration = _audioPlayer.duration;
    return currentDuration != null &&
        position.inMilliseconds >= currentDuration.inMilliseconds - 100 &&
        _isPlaying;
  }

  void _handleAutoStop() {
    setState(() {
      _isPlaying = false;
      _position = Duration.zero;
      _isLoading = false;
      _isSeeking = false;
    });
    _audioPlayer.seek(Duration.zero);
    _audioPlayer.pause();
  }

  void _updatePosition(Duration position) {
    if (mounted) {
      setState(() {
        _position = position;
      });

      // Callback for position changes
      widget.onPositionChanged?.call(position);
    }
  }

  @override
  void dispose() {
    widget.controller?.detach();
    AudioManager().clearCurrentPlayer(_audioPlayer);
    _audioPlayer.dispose();
    _debounceTimer?.cancel();
    _animationController.dispose();
    _waveformAnimationController.dispose();
    _audioInitialized = false;
    super.dispose();
  }

  Future<void> _initAudio() async {
    if (_audioInitialized) return;

    _audioPlayer = AudioPlayer();
    _audioInitialized = true;

    try {
      await _setupAudioPlayer();
      _setupAudioListeners();
    } catch (e) {
      _handleAudioError(e);
    }
  }

  Future<void> _setupAudioPlayer() async {
    if (_isAssetSource) {
      await _audioPlayer.setAsset(widget.assetPath!);
    } else {
      await _audioPlayer.setUrl(widget.audioUrl!);
    }
    _duration = _audioPlayer.duration ?? Duration.zero;
    setState(() {
      _isLoading = false;
    });
  }

  void _setupAudioListeners() {
    _audioPlayer.positionStream.listen(_onPositionChanged);
    _audioPlayer.playerStateStream.listen(_onPlayerStateChanged);
  }

  void _onPositionChanged(Duration position) {
    if (!_isSeeking && _isPlaying && mounted) {
      _updatePositionWithAnimation(position);
    }
  }

  void _onPlayerStateChanged(PlayerState state) {
    if (mounted) {
      setState(() {
        _isPlaying = state.playing;
      });
    }

    _updateLoadingState(state);

    if (state.processingState == ProcessingState.completed) {
      _handlePlaybackCompleted();
    }
  }

  void _updateLoadingState(PlayerState state) {
    if (state.processingState == ProcessingState.ready) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handlePlaybackCompleted() {
    setState(() {
      _isPlaying = false;
      _position = Duration.zero;
      _isLoading = false;
      _isSeeking = false;
    });
    _audioPlayer.seek(Duration.zero);
    _audioPlayer.pause();

    // Callback for playback completed
    widget.onCompleted?.call();
  }

  void _handleAudioError(dynamic error) {
    setState(() {
      _isLoading = false;
      _hasError = true;
      _errorMessage = error.toString();
    });

    // Callback for error
    widget.onError?.call(error.toString());
  }

  Future<void> _generateWaveformDataForWidth(double width) async {
    if (_hasError) return;

    const barWidth = 4.0;
    const barSpacing = 1.0;
    final barCount = ((width + barSpacing) / (barWidth + barSpacing)).floor();

    final cacheKey = '${_audioSource}_$barCount';

    if (_waveformCache.containsKey(cacheKey)) {
      _waveformData = _waveformCache[cacheKey]!;
      return;
    }

    try {
      _waveformData = await RealWaveformGenerator.generateWaveformFromAudio(
        _audioSource,
        targetBars: barCount,
        minHeight: 2.0,
        maxHeight: 25.0,
        isAsset: _isAssetSource,
      );

      _waveformCache[cacheKey] = _waveformData;
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _togglePlayPause() async {
    if (_isLoading) return;

    if (_isPlaying) {
      await _handlePause();
    } else {
      await _handlePlay();
    }

    // Callback for play/pause state change
    widget.onPlayPause?.call(_isPlaying);
  }

  Future<void> _handlePause() async {
    setState(() {
      _isPlaying = false;
    });

    await _audioPlayer.pause();
    AudioManager().clearCurrentPlayer(_audioPlayer);
  }

  Future<void> _handlePlay() async {
    if (_isLoading) return;

    await AudioManager().setCurrentPlayer(_audioPlayer);
    _resetPlaybackState();

    setState(() {
      _isPlaying = true;
    });

    if (_duration.inMilliseconds > 0 &&
        _position.inMilliseconds >= _duration.inMilliseconds) {
      setState(() {
        _position = Duration.zero;
      });
      await _audioPlayer.seek(Duration.zero);
    }

    await _audioPlayer.play();
  }

  void _resetPlaybackState() {
    setState(() {
      _isSeeking = false;
    });
  }

  void _handleSeekStart() {
    setState(() {
      _isSeeking = true;
    });
    if (_isPlaying) {
      _audioPlayer.pause();
    }
  }

  void _handleSeekEnd() {
    setState(() {
      _isSeeking = false;
    });
    if (_duration.inMilliseconds > 0) {
      _audioPlayer.seek(_position);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        if (widget.showPlayButton) ...[
          _buildPlayButton(),
          const SizedBox(width: 7),
        ],
        Expanded(child: _buildWaveform()),
        if (widget.showDuration) ...[
          const SizedBox(width: 7),
          _buildDurationDisplay(),
        ],
      ],
    );
  }

  Widget _buildPlayButton() {
    return GestureDetector(
      onTap: _hasError ? null : _togglePlayPause,
      child: Container(
        width: widget.playButtonSize,
        height: widget.playButtonSize,
        decoration: _buildPlayButtonDecoration(),
        child: _buildPlayButtonContent(),
      ),
    );
  }

  BoxDecoration _buildPlayButtonDecoration() {
    return BoxDecoration(
      color: _hasError
          ? WavePlayerColors.neutral60
          : (widget.playButtonColor ?? WavePlayerColors.playButton),
      shape: BoxShape.circle,
    );
  }

  Widget _buildPlayButtonContent() {
    // Simple fade transition for smooth loading to ready
    return AnimatedOpacity(
      opacity: _isLoading ? 0.7 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: _getPlayButtonState(),
    );
  }

  Widget _getPlayButtonState() {
    if (_isLoading) {
      return _buildLoadingIndicator();
    }

    if (_hasError) {
      return _buildErrorIcon();
    }

    return _buildAnimatedPlayButton();
  }

  Widget _buildLoadingIndicator() {
    return const SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  Widget _buildErrorIcon() {
    return const Icon(
      Icons.error_outline,
      color: Colors.white,
      size: 20,
    );
  }

  Widget _buildAnimatedPlayButton() {
    final buttonContent = InkWell(
      onTap: _togglePlayPause,
      borderRadius: BorderRadius.circular(100),
      child: Center(
        child: PlayPauseButton(
          isPlaying: _isPlaying,
          playIconWidget: widget.playIconWidget,
          pauseIconWidget: widget.pauseIconWidget,
          iconColor: widget.playButtonIconColor,
          animatedIcon: widget.animatedIcon,
          iconSize: _getClampedIconSize(),
        ),
      ),
    );

    if (!widget.showGlow) {
      return buttonContent;
    }

    return ButtonGlow(
      animate: _isPlaying,
      glowColor: widget.glowColor ?? WavePlayerColors.primary,
      duration: widget.glowDuration,
      glowRadiusFactor: widget.glowRadiusFactor,
      glowCount: widget.glowCount,
      child: buttonContent,
    );
  }

  double _getClampedIconSize() {
    final requestedSize = widget.iconSize ?? 22.0;
    // Clamp between 12.0 and 40.0 to ensure proper display
    return requestedSize.clamp(12.0, 40.0);
  }

  Widget _buildDurationDisplay() {
    // Show total duration when loading or when position is at start
    final shouldShowTotalDuration = _isLoading ||
        (_position.inMilliseconds == 0 && _duration.inMilliseconds > 0);

    return SizedBox(
      width: 45,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerRight,
        child: Text(
          _formatDuration(shouldShowTotalDuration ? _duration : _position),
          style: (widget.durationTextStyle ??
                  WavePlayerTextStyles.smallMedium.copyWith(
                    color: WavePlayerColors.textSecondary,
                  ))
              .copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }

  Widget _buildWaveform() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final waveformWidth = _calculateWaveformWidth(constraints.maxWidth);

        return AnimatedOpacity(
          opacity: _waveformData.isEmpty ? 0.6 : 1.0,
          duration: const Duration(milliseconds: 400),
          child: _getWaveformState(waveformWidth, constraints.maxWidth),
        );
      },
    );
  }

  Widget _getWaveformState(double waveformWidth, double availableWidth) {
    if (_hasError) {
      return _buildWaveformError(waveformWidth);
    }

    _generateWaveformIfNeeded(availableWidth);

    if (_waveformData.isEmpty) {
      return _buildWaveformLoading(waveformWidth);
    }

    return _buildWaveformSlider(waveformWidth, availableWidth);
  }

  double _calculateWaveformWidth(double availableWidth) {
    final waveformWidth =
        _cachedWaveformWidth ?? (availableWidth * 0.8).clamp(120.0, 200.0);
    _cachedWaveformWidth ??= waveformWidth;
    return waveformWidth;
  }

  Widget _buildWaveformError(double width) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 5,
      children: [
        const Icon(Icons.error_outline, size: 16, color: Color(0xFFFF3B30)),
        Flexible(
          child: Text(
            _errorMessage ?? 'Error',
            style: WavePlayerTextStyles.smallMedium.copyWith(
              color: WavePlayerColors.error,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildWaveformLoading(double width) {
    return Container(
      height: 24,
      width: width,
      decoration: BoxDecoration(
        color: WavePlayerColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007AFF)),
          ),
        ),
      ),
    );
  }

  void _generateWaveformIfNeeded(double availableWidth) {
    if (_lastGeneratedWidth != availableWidth) {
      _generateWaveformDataForWidth(availableWidth).then((_) {
        if (mounted) {
          setState(() {
            _lastGeneratedWidth = availableWidth;
            // Start waveform drawing animation only once
            if (!_hasAnimatedWaveform && _waveformData.isNotEmpty) {
              _hasAnimatedWaveform = true;
              _isWaveformAnimating = true;
              // Start animation immediately
              _waveformAnimationController.reset();
              _waveformAnimationController.forward().then((_) {
                if (mounted) {
                  setState(() {
                    _isWaveformAnimating = false;
                  });
                }
              });
            }
          });
        }
      });
    }
  }

  Widget _buildWaveformSlider(double width, double availableWidth) {
    final displayData = _prepareWaveformData(availableWidth);
    final currentDuration = _getCurrentDuration();

    return Container(
      height: 24,
      width: width,
      decoration: BoxDecoration(
        color: WavePlayerColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: CurvedAnimation(
            parent: _waveformAnimationController,
            curve: Curves.easeInOut,
          ),
          builder: (context, child) {
            return BasicAudioSlider(
              value: _position.inMilliseconds.toDouble(),
              max: currentDuration.inMilliseconds.toDouble(),
              onChanged: _onWaveformChanged,
              onChangeStart: _handleSeekStart,
              onChangeEnd: _handleSeekEnd,
              waveformData: displayData,
              activeColor: widget.activeColor,
              inactiveColor: widget.inactiveColor,
              thumbColor: widget.thumbColor,
              height: widget.waveformHeight,
              thumbSize: widget.thumbSize,
              thumbShape: widget.thumbShape,
              barWidth: widget.barWidth,
              barSpacing: widget.barSpacing,
              animationProgress: _waveformData.isEmpty
                  ? 0.0
                  : (_isWaveformAnimating
                      ? _waveformAnimationController.value.clamp(0.0, 1.0)
                      : 1.0),
            );
          },
        ),
      ),
    );
  }

  List<double> _prepareWaveformData(double availableWidth) {
    const barWidth = 4.0;
    const barSpacing = 1.0;
    final maxBars =
        ((availableWidth + barSpacing) / (barWidth + barSpacing)).floor();
    final actualBarCount = math.min(_waveformData.length, maxBars);
    return _waveformData.take(actualBarCount).toList();
  }

  Duration _getCurrentDuration() {
    return _duration.inMilliseconds > 0
        ? _duration
        : (_audioPlayer.duration ?? Duration.zero);
  }

  void _onWaveformChanged(double value) {
    setState(() {
      _position = Duration(milliseconds: value.round());
    });
  }

  void _seekTo(Duration position) {
    if (mounted) {
      setState(() {
        _position = position;
      });
      _audioPlayer.seek(position);
    }
  }

  // Public getters for controller access
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;

  // Public methods for controller access
  Future<void> play() async => await _handlePlay();
  Future<void> pause() async => await _handlePause();
  Future<void> togglePlayPause() async => await _togglePlayPause();
  void seekTo(Duration position) => _seekTo(position);
}

class PlayPauseButton extends StatefulWidget {
  final bool isPlaying;
  final Widget? playIconWidget;
  final Widget? pauseIconWidget;
  final Color? iconColor;
  final AnimatedIconData? animatedIcon;
  final double iconSize;

  const PlayPauseButton({
    super.key,
    required this.isPlaying,
    this.playIconWidget,
    this.pauseIconWidget,
    this.iconColor,
    this.animatedIcon,
    this.iconSize = 22.0,
  });

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
    if (widget.isPlaying) {
      _controller.forward();
    } else {
      _controller.reverse();
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
                ));
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
