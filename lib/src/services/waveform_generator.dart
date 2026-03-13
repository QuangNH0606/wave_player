import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;

/// Service for generating waveform visualization data from audio sources.
///
/// Supports three strategies:
/// 1. **WAV files** — Parses raw PCM data to extract real amplitude information.
/// 2. **Duration-based** — Uses [AudioPlayer] to get duration, then generates
///    a visually realistic waveform seeded by the URL (deterministic).
/// 3. **Fallback** — Random but plausible waveform if all else fails.
///
/// Usage:
/// ```dart
/// final data = await RealWaveformGenerator.generateWaveformFromAudio(
///   'https://example.com/audio.mp3',
///   targetBars: 50,
///   minHeight: 2.0,
///   maxHeight: 25.0,
/// );
/// ```
class RealWaveformGenerator {
  /// Maximum number of entries to keep in the waveform cache.
  static const int _maxCacheEntries = 50;

  /// Cache of previously generated waveforms, keyed by `"$source_$barCount"`.
  static final Map<String, List<double>> _waveformCache = {};

  /// Clears the waveform cache to free memory.
  static void clearCache() {
    _waveformCache.clear();
  }

  /// Generates waveform data suitable for visualization.
  ///
  /// Returns a [List<double>] of bar heights between [minHeight] and [maxHeight].
  ///
  /// - [audioSource]: URL or asset path of the audio file.
  /// - [targetBars]: Number of bars in the waveform.
  /// - [minHeight]: Minimum bar height.
  /// - [maxHeight]: Maximum bar height.
  /// - [isAsset]: Whether [audioSource] is a Flutter asset path.
  static Future<List<double>> generateWaveformFromAudio(
    String audioSource, {
    int targetBars = 50,
    double minHeight = 2.0,
    double maxHeight = 30.0,
    bool isAsset = false,
  }) async {
    // Check cache first
    final cacheKey = '${audioSource}_$targetBars';
    if (_waveformCache.containsKey(cacheKey)) {
      return _waveformCache[cacheKey]!;
    }

    try {
      List<double> result;

      if (isAsset) {
        // Assets: generate a synthetic waveform since we can't easily
        // read raw bytes from packaged assets without an AudioPlayer
        result = _generateSyntheticWaveform(targetBars, minHeight, maxHeight);
      } else if (audioSource.toLowerCase().endsWith('.wav')) {
        // WAV URLs: download and parse raw PCM data
        final amplitudeData = await _extractWaveformFromWavUrl(
          audioSource,
          targetBars * 10,
        );
        if (amplitudeData.isNotEmpty) {
          result = _normalizeToBarHeights(
            amplitudeData,
            targetBars,
            minHeight: minHeight,
            maxHeight: maxHeight,
          );
        } else {
          result = await _generateFromAudioDuration(
            audioSource,
            targetBars,
            minHeight,
            maxHeight,
          );
        }
      } else {
        // MP3/other: use AudioPlayer to get duration, generate smart waveform
        result = await _generateFromAudioDuration(
          audioSource,
          targetBars,
          minHeight,
          maxHeight,
        );
      }

      // Cache result with eviction
      _cacheResult(cacheKey, result);
      return result;
    } catch (e) {
      debugPrint('Error generating waveform: $e');
      return _generateFallbackWaveform(targetBars, minHeight, maxHeight);
    }
  }

  /// Caches a result, evicting oldest entries if cache is full.
  static void _cacheResult(String key, List<double> data) {
    if (_waveformCache.length >= _maxCacheEntries) {
      // Remove the oldest entry (first inserted key)
      _waveformCache.remove(_waveformCache.keys.first);
    }
    _waveformCache[key] = data;
  }

  // ---------------------------------------------------------------------------
  // WAV Parsing
  // ---------------------------------------------------------------------------

  /// Downloads a WAV file from [url] and extracts amplitude data.
  static Future<List<double>> _extractWaveformFromWavUrl(
    String url,
    int samplesCount,
  ) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        debugPrint('Failed to download WAV: HTTP ${response.statusCode}');
        return [];
      }

      final bytes = response.bodyBytes;
      if (bytes.length < 44) {
        debugPrint('File too short to be a valid WAV');
        return [];
      }

      // Validate RIFF header
      final header = String.fromCharCodes(bytes.sublist(0, 4));
      if (header != 'RIFF') {
        debugPrint('Not a WAV file: $header');
        return [];
      }

      // Skip the 44-byte WAV header (standard PCM)
      final data = bytes.sublist(44);
      final buffer = ByteData.sublistView(data);

      final totalSamples = buffer.lengthInBytes ~/ 2;
      if (totalSamples == 0) return [];

      final step = math.max(1, totalSamples ~/ samplesCount);
      final actualSamples = math.min(samplesCount, totalSamples ~/ step);

      final amplitudes = <double>[];

      for (int i = 0; i < actualSamples; i++) {
        final start = i * step * 2;
        final end = math.min(start + step * 2, data.length);

        double sumSquares = 0.0;
        int sampleCount = 0;

        for (int j = start; j < end - 1; j += 2) {
          final sample = buffer.getInt16(j, Endian.little);
          sumSquares += (sample * sample).toDouble();
          sampleCount++;
        }

        if (sampleCount > 0) {
          final rms = math.sqrt(sumSquares / sampleCount);
          final normalized = rms / 32768.0;
          // Convert to logarithmic scale for more natural visualization
          final db = 20 * math.log(normalized + 0.0001) / math.ln10;
          final logNormalized = (db + 60) / 60;
          amplitudes.add(logNormalized.clamp(0.0, 1.0));
        } else {
          amplitudes.add(0.0);
        }
      }

      return _smoothAmplitudes(amplitudes);
    } catch (e) {
      debugPrint('Error extracting waveform from WAV URL: $e');
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // Duration-based generation
  // ---------------------------------------------------------------------------

  /// Uses [AudioPlayer] to get the audio duration, then generates a
  /// deterministic waveform seeded by the URL hash.
  static Future<List<double>> _generateFromAudioDuration(
    String audioUrl,
    int targetBars,
    double minHeight,
    double maxHeight,
  ) async {
    try {
      final audioPlayer = AudioPlayer();
      try {
        await audioPlayer.setUrl(audioUrl);
        final duration = audioPlayer.duration;

        if (duration != null && duration.inSeconds > 0) {
          return _generateSmartWaveform(
            audioUrl,
            duration.inSeconds,
            targetBars,
            minHeight,
            maxHeight,
          );
        }
      } finally {
        await audioPlayer.dispose();
      }

      return _generateFallbackWaveform(targetBars, minHeight, maxHeight);
    } catch (e) {
      debugPrint('Error generating from audio duration: $e');
      return _generateFallbackWaveform(targetBars, minHeight, maxHeight);
    }
  }

  /// Generates a deterministic, natural-looking waveform based on
  /// the audio URL hash and duration.
  ///
  /// Uses layered sine waves to simulate music structure (verse/chorus),
  /// random peaks for transients, and an envelope for fade in/out.
  static List<double> _generateSmartWaveform(
    String audioUrl,
    int durationSeconds,
    int targetBars,
    double minHeight,
    double maxHeight,
  ) {
    final waveform = <double>[];
    final random = math.Random(audioUrl.hashCode);
    final range = maxHeight - minHeight;

    // Pre-generate "section" shapes using layered frequencies
    // seeded by the URL so the same URL always produces the same waveform.
    final seed2 = math.Random(audioUrl.hashCode ^ 0xCAFE);
    final phaseA = seed2.nextDouble() * math.pi * 2;
    final phaseB = seed2.nextDouble() * math.pi * 2;
    final phaseC = seed2.nextDouble() * math.pi * 2;

    for (int i = 0; i < targetBars; i++) {
      final t = targetBars > 1 ? i / (targetBars - 1) : 0.5;

      // --- Envelope: fade in first 8%, fade out last 8% ---
      double envelope;
      if (t < 0.08) {
        envelope = t / 0.08;
      } else if (t > 0.92) {
        envelope = (1.0 - t) / 0.08;
      } else {
        envelope = 1.0;
      }

      // --- Layered structure (simulates verse=quiet, chorus=loud) ---
      // Slow wave: overall energy contour (like song sections)
      final slow = 0.5 + 0.5 * math.sin(t * math.pi * 2.5 + phaseA);
      // Medium wave: musical phrases
      final mid = 0.5 + 0.5 * math.sin(t * math.pi * 7.0 + phaseB);
      // Fast wave: beat-level variation
      final fast = 0.5 + 0.5 * math.sin(t * math.pi * 19.0 + phaseC);

      // Weighted blend: slow dominates shape, fast adds texture
      final structure = slow * 0.45 + mid * 0.30 + fast * 0.25;

      // --- Random per-bar jitter (±20%) for natural feel ---
      final jitter = (random.nextDouble() - 0.5) * 0.4;

      // --- Occasional peaks (transient hits, ~12% chance) ---
      final spike =
          random.nextDouble() < 0.12 ? 0.2 + random.nextDouble() * 0.15 : 0.0;

      // Combine: base floor 15% + structure + jitter + spike
      final raw = 0.15 + structure * 0.7 + jitter + spike;
      final amplitude = (raw * envelope).clamp(0.08, 1.0);

      waveform.add(minHeight + amplitude * range);
    }

    return _smoothAmplitudes(waveform);
  }

  // ---------------------------------------------------------------------------
  // Synthetic & Fallback
  // ---------------------------------------------------------------------------

  /// Generates a synthetic waveform with multiple frequency components
  /// for a natural appearance. Used for assets.
  static List<double> _generateSyntheticWaveform(
    int targetBars,
    double minHeight,
    double maxHeight,
  ) {
    final random = math.Random(42); // Fixed seed for consistency
    final waveform = <double>[];
    final range = maxHeight - minHeight;

    for (int i = 0; i < targetBars; i++) {
      final progress = targetBars > 1 ? i / targetBars : 0.5;

      // Multiple frequency components for a realistic look
      final lowFreq = 0.2 + 0.3 * math.sin(progress * math.pi * 2);
      final midFreq = 0.1 + 0.2 * math.sin(progress * math.pi * 8);
      final highFreq = 0.05 + 0.15 * math.sin(progress * math.pi * 16);
      final variation = (random.nextDouble() - 0.5) * 0.3;

      // Smooth fade at edges instead of hard cut
      double edgeFade;
      if (progress < 0.1) {
        edgeFade = 0.3 + 0.7 * (progress / 0.1);
      } else if (progress > 0.9) {
        edgeFade = 0.3 + 0.7 * ((1.0 - progress) / 0.1);
      } else {
        edgeFade = 1.0;
      }

      final amplitude = ((lowFreq + midFreq + highFreq + variation) * edgeFade)
          .clamp(0.05, 1.0);

      waveform.add(minHeight + amplitude * range);
    }

    return _smoothAmplitudes(waveform);
  }

  /// Fallback waveform when all generation strategies fail.
  static List<double> _generateFallbackWaveform(
    int targetBars,
    double minHeight,
    double maxHeight,
  ) {
    final waveform = <double>[];
    final random = math.Random();

    for (int i = 0; i < targetBars; i++) {
      final progress = targetBars > 1 ? i / (targetBars - 1) : 0.5;
      double height;

      if (progress < 0.2 || progress > 0.8) {
        height = minHeight + random.nextDouble() * 2.0;
      } else {
        final baseHeight = minHeight + 4.0 + (progress - 0.2) * 16.0;
        final variation = (random.nextDouble() - 0.5) * 6.0;
        height = (baseHeight + variation).clamp(minHeight, maxHeight);
      }

      waveform.add(height);
    }

    return waveform;
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Normalizes raw amplitude data (0.0–1.0) to bar heights.
  static List<double> _normalizeToBarHeights(
    List<double> amplitudeData,
    int targetBars, {
    double minHeight = 2.0,
    double maxHeight = 30.0,
  }) {
    if (amplitudeData.isEmpty) {
      return _generateFallbackWaveform(targetBars, minHeight, maxHeight);
    }

    final waveform = <double>[];
    final samplesPerBar = (amplitudeData.length / targetBars).ceil();

    final maxAmplitude = amplitudeData.reduce(math.max);
    final minAmplitude = amplitudeData.reduce(math.min);
    final amplitudeRange = maxAmplitude - minAmplitude;

    for (int i = 0; i < targetBars; i++) {
      final startIndex = i * samplesPerBar;
      final endIndex =
          math.min(startIndex + samplesPerBar, amplitudeData.length);

      if (startIndex >= amplitudeData.length) break;

      // Use peak (max) amplitude per segment for more dynamic waveforms
      double peakAmplitude = 0.0;
      for (int j = startIndex; j < endIndex; j++) {
        if (amplitudeData[j] > peakAmplitude) {
          peakAmplitude = amplitudeData[j];
        }
      }

      double normalizedAmplitude;
      if (amplitudeRange > 0) {
        normalizedAmplitude = (peakAmplitude - minAmplitude) / amplitudeRange;
      } else {
        normalizedAmplitude = 0.0;
      }

      final height =
          minHeight + (normalizedAmplitude * (maxHeight - minHeight));
      waveform.add(height.clamp(minHeight, maxHeight));
    }

    return waveform;
  }

  /// Light smoothing that preserves peaks.
  ///
  /// Uses a weighted average (60% center, 20% neighbors) instead of
  /// equal-weight average which kills dynamic range.
  static List<double> _smoothAmplitudes(List<double> amplitudes) {
    if (amplitudes.length < 3) return amplitudes;

    final smoothed = List<double>.filled(amplitudes.length, 0.0);
    smoothed[0] = amplitudes[0];
    smoothed[amplitudes.length - 1] = amplitudes[amplitudes.length - 1];

    for (int i = 1; i < amplitudes.length - 1; i++) {
      smoothed[i] = amplitudes[i - 1] * 0.2 +
          amplitudes[i] * 0.6 +
          amplitudes[i + 1] * 0.2;
    }

    return smoothed;
  }
}
