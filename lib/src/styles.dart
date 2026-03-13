import 'package:flutter/material.dart';

/// Theme configuration for the Wave Player package.
///
/// Use [WavePlayerColors.setTheme] to customize colors globally:
/// ```dart
/// WavePlayerColors.setTheme(const WavePlayerTheme(
///   primaryColor: Colors.blue,
///   errorColor: Colors.red,
/// ));
/// ```
class WavePlayerTheme {
  /// Creates a [WavePlayerTheme] with optional color overrides.
  const WavePlayerTheme({
    this.primaryColor = const Color(0xFF007AFF),
    this.secondaryColor = const Color(0xFF5856D6),
    this.successColor = const Color(0xFF34C759),
    this.warningColor = const Color(0xFFFF9500),
    this.errorColor = const Color(0xFFFF3B30),
    this.backgroundColor = const Color(0xFFF5F5F7),
    this.surfaceColor = const Color(0xFFFFFFFF),
    this.textColor = const Color(0xFF1A1A1A),
    this.textSecondaryColor = const Color(0xFF5F6368),
    this.borderColor = const Color(0xFFE1E1E1),
  });

  /// Primary brand color used for active waveform, play button, etc.
  final Color primaryColor;

  /// Secondary accent color.
  final Color secondaryColor;

  /// Color indicating success state.
  final Color successColor;

  /// Color indicating warning state.
  final Color warningColor;

  /// Color indicating error state.
  final Color errorColor;

  /// Background color for the player container.
  final Color backgroundColor;

  /// Surface color for elevated elements.
  final Color surfaceColor;

  /// Primary text color.
  final Color textColor;

  /// Secondary text color for less prominent labels.
  final Color textSecondaryColor;

  /// Border color for outlined elements.
  final Color borderColor;

  /// A lighter shade of [primaryColor].
  Color get primaryLight =>
      Color.lerp(primaryColor, Colors.white, 0.3) ?? primaryColor;

  /// A darker shade of [primaryColor].
  Color get primaryDark =>
      Color.lerp(primaryColor, Colors.black, 0.2) ?? primaryColor;

  /// A blended surface/background color.
  Color get surfaceVariant =>
      Color.lerp(surfaceColor, backgroundColor, 0.5) ?? backgroundColor;

  /// Color for active (played) waveform bars.
  Color get waveformActive => primaryColor;

  /// Color for inactive (unplayed) waveform bars.
  Color get waveformInactive =>
      Color.lerp(primaryColor, Colors.white, 0.8) ?? const Color(0xFFD1D1D6);

  /// Color of the waveform slider thumb.
  Color get waveformThumb => primaryColor;

  /// Color of the play button background.
  Color get playButton => primaryColor;

  /// Color of the play button when pressed.
  Color get playButtonPressed => primaryDark;

  /// Returns a copy of this theme with the given fields replaced.
  WavePlayerTheme copyWith({
    /// Override the primary brand color.
    Color? primaryColor,

    /// Override the secondary accent color.
    Color? secondaryColor,

    /// Override the success color.
    Color? successColor,

    /// Override the warning color.
    Color? warningColor,

    /// Override the error color.
    Color? errorColor,

    /// Override the background color.
    Color? backgroundColor,

    /// Override the surface color.
    Color? surfaceColor,

    /// Override the primary text color.
    Color? textColor,

    /// Override the secondary text color.
    Color? textSecondaryColor,

    /// Override the border color.
    Color? borderColor,
  }) {
    return WavePlayerTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      errorColor: errorColor ?? this.errorColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      textColor: textColor ?? this.textColor,
      textSecondaryColor: textSecondaryColor ?? this.textSecondaryColor,
      borderColor: borderColor ?? this.borderColor,
    );
  }
}

/// Default theme instance used when no custom theme is set.
const WavePlayerTheme defaultTheme = WavePlayerTheme();

/// Convenience accessors for Wave Player colors.
///
/// Colors resolve from the current theme, which can be changed at runtime
/// via [setTheme].
class WavePlayerColors {
  static WavePlayerTheme _theme = defaultTheme;

  /// The current [WavePlayerTheme].
  static WavePlayerTheme get theme => _theme;

  /// Replaces the current theme with [theme].
  static void setTheme(WavePlayerTheme theme) => _theme = theme;

  // ---------------------------------------------------------------------------
  // Primary color palette
  // ---------------------------------------------------------------------------

  /// Primary brand color.
  static Color get primary => _theme.primaryColor;

  /// Light variant of the primary color.
  static Color get primaryLight => _theme.primaryLight;

  /// Dark variant of the primary color.
  static Color get primaryDark => _theme.primaryDark;

  /// Primary color at 70 % intensity (30 % white blend).
  static Color get primary70 =>
      Color.lerp(_theme.primaryColor, Colors.white, 0.3) ?? _theme.primaryColor;

  /// Primary color at 50 % intensity.
  static Color get primary50 =>
      Color.lerp(_theme.primaryColor, Colors.white, 0.5) ?? _theme.primaryColor;

  /// Primary color at 30 % intensity.
  static Color get primary30 =>
      Color.lerp(_theme.primaryColor, Colors.white, 0.7) ?? _theme.primaryColor;

  /// Primary color at 10 % intensity.
  static Color get primary10 =>
      Color.lerp(_theme.primaryColor, Colors.white, 0.9) ?? _theme.primaryColor;

  // ---------------------------------------------------------------------------
  // Secondary
  // ---------------------------------------------------------------------------

  /// Secondary accent color.
  static Color get secondary => _theme.secondaryColor;

  // ---------------------------------------------------------------------------
  // Semantic colors
  // ---------------------------------------------------------------------------

  /// Success / positive color.
  static Color get success => _theme.successColor;

  /// Warning color.
  static Color get warning => _theme.warningColor;

  /// Error / destructive color.
  static Color get error => _theme.errorColor;

  /// Informational color (resolves to primary).
  static Color get info => _theme.primaryColor;

  // ---------------------------------------------------------------------------
  // Background / surface
  // ---------------------------------------------------------------------------

  /// General background color.
  static Color get background => _theme.backgroundColor;

  /// Surface color for cards and elevated elements.
  static Color get surface => _theme.surfaceColor;

  /// Surface variant (softer contrast).
  static Color get surfaceVariant => _theme.surfaceVariant;

  // ---------------------------------------------------------------------------
  // Text
  // ---------------------------------------------------------------------------

  /// Primary text color.
  static Color get textPrimary => _theme.textColor;

  /// Secondary (muted) text color.
  static Color get textSecondary => _theme.textSecondaryColor;

  /// Text color rendered on top of primary backgrounds.
  static Color get textOnPrimary => Colors.white;

  // ---------------------------------------------------------------------------
  // Audio-player specific
  // ---------------------------------------------------------------------------

  /// Audio player background.
  static Color get audioBackground => _theme.backgroundColor;

  /// Audio player surface.
  static Color get audioSurface => _theme.surfaceColor;

  /// Audio player border.
  static Color get audioBorder => _theme.borderColor;

  /// Active waveform bar color.
  static Color get waveformActive => _theme.waveformActive;

  /// Inactive waveform bar color.
  static Color get waveformInactive => _theme.waveformInactive;

  /// Waveform slider thumb color.
  static Color get waveformThumb => _theme.waveformThumb;

  /// Play button background color.
  static Color get playButton => _theme.playButton;

  /// Play button pressed color.
  static Color get playButtonPressed => _theme.playButtonPressed;

  // ---------------------------------------------------------------------------
  // Basic colors
  // ---------------------------------------------------------------------------

  /// Pure white.
  static Color get white => Colors.white;

  /// Pure black.
  static Color get black => Colors.black;

  /// Alias for [error] — kept for convenience.
  static Color get red => _theme.errorColor;

  /// Alias for [success].
  static Color get green => _theme.successColor;

  /// Alias for [warning].
  static Color get orange => _theme.warningColor;

  // ---------------------------------------------------------------------------
  // Neutral palette
  // ---------------------------------------------------------------------------

  /// Neutral gray at 60 % brightness.
  static Color get neutral60 => const Color(0xFFAEAEB2);

  /// Neutral gray at 70 % brightness.
  static Color get neutral70 => const Color(0xFFC7C7CC);

  /// Neutral gray at 80 % brightness.
  static Color get neutral80 => const Color(0xFFD1D1D6);

  /// Neutral gray at 50 % brightness.
  static Color get neutral50 => const Color(0xFF8E8E93);

  /// Neutral gray at 10 % brightness (dark).
  static Color get neutral10 => const Color(0xFF2C2C2E);
}

/// Pre-defined text styles used across the Wave Player package.
class WavePlayerTextStyles {
  /// Small text (12 px, medium weight).
  static const TextStyle small = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.33,
    letterSpacing: 0.4,
  );

  /// Body text (14 px, regular weight).
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    letterSpacing: 0.25,
  );

  /// Body text with medium weight (14 px).
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43,
    letterSpacing: 0.25,
  );

  /// Large text (16 px, regular weight).
  static const TextStyle large = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.15,
  );

  // Legacy compatibility aliases

  /// Legacy alias for [small].
  static const TextStyle regularSmall = small;

  /// Legacy alias for [body].
  static const TextStyle regularMedium = body;

  /// Legacy alias for [large].
  static const TextStyle regularLarge = large;

  /// Legacy alias for [small].
  static const TextStyle smallMedium = small;

  /// Legacy alias for [bodyMedium].
  static const TextStyle mediumMedium = bodyMedium;

  /// Legacy alias for [large].
  static const TextStyle mediumLarge = large;

  /// Bold large text (16 px, bold weight).
  static const TextStyle boldLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.5,
    letterSpacing: 0.15,
  );
}
