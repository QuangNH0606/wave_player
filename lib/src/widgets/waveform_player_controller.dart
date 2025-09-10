/// Controller for WaveformPlayer to programmatically control playback
class WaveformPlayerController {
  dynamic _state;

  /// Attaches this controller to a WaveformPlayer
  void attach(dynamic state) {
    _state = state;
  }

  /// Detaches this controller from the WaveformPlayer
  void detach() {
    _state = null;
  }

  /// Plays the audio
  Future<void> play() async {
    if (_state != null && _state!.mounted) {
      await _state!.play();
    }
  }

  /// Pauses the audio
  Future<void> pause() async {
    if (_state != null && _state!.mounted) {
      await _state!.pause();
    }
  }

  /// Toggles play/pause state
  Future<void> togglePlayPause() async {
    if (_state != null && _state!.mounted) {
      await _state!.togglePlayPause();
    }
  }

  /// Seeks to a specific position
  Future<void> seekTo(Duration position) async {
    if (_state != null && _state!.mounted) {
      _state!.seekTo(position);
    }
  }

  /// Seeks to a specific position as a percentage (0.0 to 1.0)
  Future<void> seekToPercentage(double percentage) async {
    if (_state != null && _state!.mounted) {
      final duration = _state!.duration;
      if (duration.inMilliseconds > 0) {
        final position = Duration(
          milliseconds:
              (duration.inMilliseconds * percentage.clamp(0.0, 1.0)).round(),
        );
        await seekTo(position);
      }
    }
  }

  /// Gets the current playing state
  bool get isPlaying => _state?.isPlaying ?? false;

  /// Gets the current position
  Duration get position => _state?.position ?? Duration.zero;

  /// Gets the total duration
  Duration get duration => _state?.duration ?? Duration.zero;

  /// Gets the current position as a percentage (0.0 to 1.0)
  double get positionPercentage {
    final dur = duration;
    if (dur.inMilliseconds <= 0) return 0.0;
    return (position.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0);
  }

  /// Gets whether the player is loading
  bool get isLoading => _state?.isLoading ?? false;

  /// Gets whether there's an error
  bool get hasError => _state?.hasError ?? false;

  /// Gets the error message if any
  String? get errorMessage => _state?.errorMessage;
}
