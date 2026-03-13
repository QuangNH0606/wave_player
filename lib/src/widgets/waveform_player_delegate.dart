/// Abstract interface for [WaveformPlayerController] to communicate with
/// [WaveformPlayer]'s internal state in a type-safe manner.
///
/// This replaces the previous `dynamic _state` pattern, ensuring compile-time
/// safety and proper API documentation.
mixin WaveformPlayerDelegate {
  /// Whether the underlying [State] object is still mounted in the widget tree.
  bool get mounted;

  /// Whether audio is currently playing.
  bool get isPlaying;

  /// Current playback position.
  Duration get position;

  /// Total audio duration.
  Duration get duration;

  /// Whether the player is currently loading.
  bool get isLoading;

  /// Whether an error has occurred.
  bool get hasError;

  /// Error message, if any.
  String? get errorMessage;

  /// Starts playback.
  Future<void> play();

  /// Pauses playback.
  Future<void> pause();

  /// Toggles between play and pause.
  Future<void> togglePlayPause();

  /// Seeks to the given [position].
  void seekTo(Duration position);
}
