import 'dart:async';
import 'package:just_audio/just_audio.dart';

/// A singleton service to manage audio playback across the app.
///
/// Ensures only one audio player can play at a time by pausing the previous
/// player when a new one starts.
///
/// Usage:
/// ```dart
/// await AudioManager().setCurrentPlayer(audioPlayer);
/// AudioManager().clearCurrentPlayer(audioPlayer);
/// await AudioManager().pauseAll();
/// ```
class AudioManager {
  static final AudioManager _instance = AudioManager._internal();

  /// Returns the singleton [AudioManager] instance.
  factory AudioManager() => _instance;
  AudioManager._internal();

  AudioPlayer? _currentPlayer;
  bool _isPlaying = false;
  final StreamController<void> _playerChangedController =
      StreamController<void>.broadcast();

  /// Get the current active player.
  AudioPlayer? get currentPlayer => _currentPlayer;

  /// Check if any audio is currently playing.
  bool get isPlaying => _isPlaying;

  /// Stream that emits when the current player changes.
  ///
  /// Listen to this stream and **cancel the subscription** when done
  /// to avoid memory leaks:
  /// ```dart
  /// final sub = AudioManager().onPlayerChanged.listen((_) { ... });
  /// // Later:
  /// sub.cancel();
  /// ```
  Stream<void> get onPlayerChanged => _playerChangedController.stream;

  /// Set a new current player and pause others.
  Future<void> setCurrentPlayer(AudioPlayer newPlayer) async {
    // Pause current player if different
    if (_currentPlayer != null && _currentPlayer != newPlayer) {
      try {
        await _currentPlayer!.pause();
      } catch (_) {
        // Player may already be disposed
      }
    }

    _currentPlayer = newPlayer;
    _isPlaying = true;
    _playerChangedController.add(null);
  }

  /// Clear the current player.
  void clearCurrentPlayer(AudioPlayer player) {
    if (_currentPlayer == player) {
      _currentPlayer = null;
      _isPlaying = false;
      _playerChangedController.add(null);
    }
  }

  /// Pause all audio.
  Future<void> pauseAll() async {
    if (_currentPlayer != null) {
      try {
        await _currentPlayer!.pause();
      } catch (_) {
        // Player may already be disposed
      }
      _isPlaying = false;
      _playerChangedController.add(null);
    }
  }

  /// Stop all audio and reset position.
  Future<void> stopAll() async {
    if (_currentPlayer != null) {
      try {
        await _currentPlayer!.stop();
      } catch (_) {
        // Player may already be disposed
      }
      _isPlaying = false;
      _playerChangedController.add(null);
    }
  }

  /// Dispose the audio manager.
  ///
  /// Note: Since this is a singleton, calling dispose will affect all
  /// consumers. Only call this when the app is shutting down.
  void dispose() {
    _playerChangedController.close();
  }
}
