import 'waveform_player_delegate.dart';

/// Controller for [WaveformPlayer] to programmatically control playback.
///
/// Create a controller and pass it to [WaveformPlayer.controller]:
/// ```dart
/// final controller = WaveformPlayerController();
///
/// WaveformPlayer(
///   audioUrl: 'https://example.com/audio.mp3',
///   controller: controller,
/// )
///
/// // Later:
/// await controller.play();
/// await controller.pause();
/// controller.seekToPercentage(0.5);
/// ```
class WaveformPlayerController {
  WaveformPlayerDelegate? _delegate;

  /// Attaches this controller to a [WaveformPlayer]'s state.
  ///
  /// Called internally by [WaveformPlayer]. Do not call directly.
  void attach(WaveformPlayerDelegate delegate) {
    _delegate = delegate;
  }

  /// Detaches this controller from the [WaveformPlayer].
  ///
  /// Called internally by [WaveformPlayer]. Do not call directly.
  void detach() {
    _delegate = null;
  }

  /// Whether a [WaveformPlayer] is currently attached.
  bool get isAttached => _delegate != null;

  /// Plays the audio.
  Future<void> play() async {
    final delegate = _delegate;
    if (delegate != null && delegate.mounted) {
      await delegate.play();
    }
  }

  /// Pauses the audio.
  Future<void> pause() async {
    final delegate = _delegate;
    if (delegate != null && delegate.mounted) {
      await delegate.pause();
    }
  }

  /// Toggles play/pause state.
  Future<void> togglePlayPause() async {
    final delegate = _delegate;
    if (delegate != null && delegate.mounted) {
      await delegate.togglePlayPause();
    }
  }

  /// Seeks to a specific position.
  Future<void> seekTo(Duration position) async {
    final delegate = _delegate;
    if (delegate != null && delegate.mounted) {
      delegate.seekTo(position);
    }
  }

  /// Seeks to a specific position as a percentage (0.0 to 1.0).
  Future<void> seekToPercentage(double percentage) async {
    final delegate = _delegate;
    if (delegate != null && delegate.mounted) {
      final dur = delegate.duration;
      if (dur.inMilliseconds > 0) {
        final position = Duration(
          milliseconds:
              (dur.inMilliseconds * percentage.clamp(0.0, 1.0)).round(),
        );
        await seekTo(position);
      }
    }
  }

  /// Gets the current playing state.
  bool get isPlaying => _delegate?.isPlaying ?? false;

  /// Gets the current position.
  Duration get position => _delegate?.position ?? Duration.zero;

  /// Gets the total duration.
  Duration get duration => _delegate?.duration ?? Duration.zero;

  /// Gets the current position as a percentage (0.0 to 1.0).
  double get positionPercentage {
    final dur = duration;
    if (dur.inMilliseconds <= 0) return 0.0;
    return (position.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0);
  }

  /// Gets whether the player is loading.
  bool get isLoading => _delegate?.isLoading ?? false;

  /// Gets whether there's an error.
  bool get hasError => _delegate?.hasError ?? false;

  /// Gets the error message if any.
  String? get errorMessage => _delegate?.errorMessage;
}
