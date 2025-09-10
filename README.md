# Wave Player

A Flutter package for audio waveform visualization and playback with customizable UI components.

<a href="https://pub.dev/packages/wave_player">
  <img src="https://img.shields.io/badge/dart%20sdk-%3E%3D3.6.0%20%3C4.0.0-blue"/>
</a>
<a href="https://pub.dev/packages/wave_player">
  <img src="https://img.shields.io/badge/pub-wave_player-red"/>
</a>
<a href="https://flutter.dev/">
  <img src="https://img.shields.io/badge/flutter-3.6+-blue"/>
</a>
<a href="https://opensource.org/licenses/MIT">
  <img src="https://img.shields.io/badge/License-MIT-yellow.svg"/>
</a>

Libraries help simplify working with audio waveforms and playback

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Widgets](#widgets)
- [Example](#example)
- [Dependencies](#dependencies)
- [License](#license)

## Features

- 🎵 **Waveform Player** - Complete audio player UI with waveform visualization
- 🎮 **Programmatic Control** - WaveformPlayerController for external control
- 📊 **Waveform Visualization** - Real-time audio waveform display with seek functionality
- 🎚️ **Audio Slider** - Customizable audio progress slider with multiple thumb shapes
- 🎨 **Customizable Styling** - Extensive theming and customization options
- 🔄 **Audio Management** - Singleton audio manager for coordinated playback

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  wave_player: ^0.0.4
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Waveform Player

```dart
import 'package:wave_player/wave_player.dart';

WaveformPlayer(
  audioUrl: 'https://raw.githubusercontent.com/QuangNH0606/wave_player/main/assets/mp3_url.mp3',
  waveformHeight: 24.0,
  thumbSize: 16.0,
  thumbShape: ThumbShape.verticalBar,
)
```

### Controller Usage

```dart
import 'package:wave_player/wave_player.dart';

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final WaveformPlayerController controller = WaveformPlayerController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        WaveformPlayer(
          audioUrl: 'https://raw.githubusercontent.com/QuangNH0606/wave_player/main/assets/mp3_url.mp3',
          controller: controller,
        ),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => controller.play(),
              child: Text('Play'),
            ),
            ElevatedButton(
              onPressed: () => controller.pause(),
              child: Text('Pause'),
            ),
            ElevatedButton(
              onPressed: () => controller.seekToPercentage(0.5),
              child: Text('50%'),
            ),
          ],
        ),
      ],
    );
  }
}
```



### Examples
|Screenshot|Recording 1|Recording 2|
|:---:|:---:|:---:|
|![](assets/screenshot.png)|![](assets/recording_1.gif)|![](assets/recording_2.gif)|

### Custom Theme

```dart
// Set global theme
WavePlayerColors.theme = const WavePlayerTheme(
  primaryColor: Color(0xFF2196F3),
  successColor: Color(0xFF4CAF50),
  backgroundColor: Color(0xFFE3F2FD),
  surfaceColor: Color(0xFFFFFFFF),
  textColor: Color(0xFF1565C0),
  textSecondaryColor: Color(0xFF424242),
);

// Or create a custom theme
final customTheme = WavePlayerTheme(
  primaryColor: Colors.purple,
  successColor: Colors.green,
  backgroundColor: Colors.grey[100]!,
  surfaceColor: Colors.white,
  textColor: Colors.black87,
  textSecondaryColor: Colors.grey[600]!,
);

// Apply custom theme
WavePlayerColors.theme = customTheme;
```


### Advanced Customization

```dart
WaveformPlayer(
  audioUrl: 'https://raw.githubusercontent.com/QuangNH0606/wave_player/main/assets/mp3_url.mp3',
  waveformHeight: 32.0,
  thumbSize: 20.0,
  thumbShape: ThumbShape.roundedBar,
  activeColor: Colors.blue,
  inactiveColor: Colors.grey[300]!,
  thumbColor: Colors.blue,
  backgroundColor: Colors.white,
  showPlayButton: true,
  showDuration: true,
  autoPlay: false,
  playButtonSize: 48.0,
  playButtonColor: Colors.blue,
  playButtonIconColor: Colors.white,
  barWidth: 3.0,
  barSpacing: 2.0,
  onPlayPause: (isPlaying) {
    print('Playing: $isPlaying');
  },
  onPositionChanged: (position) {
    print('Position: $position');
  },
  onCompleted: () {
    print('Playback completed');
  },
  onError: (error) {
    print('Error: $error');
  },
)
```

### Basic Audio Slider

```dart
BasicAudioSlider(
  value: currentPosition,
  max: totalDuration,
  onChanged: (value) {
    // Handle position change
  },
  onChangeStart: () {
    // Handle seek start
  },
  onChangeEnd: () {
    // Handle seek end
  },
  waveformData: waveformData,
  activeColor: WavePlayerColors.primary,
  inactiveColor: WavePlayerColors.neutral60,
  thumbColor: WavePlayerColors.primary,
  height: 30,
  thumbSize: 24,
  thumbShape: ThumbShape.verticalBar,
)
```



## Widgets

### WaveformPlayer

A complete waveform player widget with audio visualization, play/pause controls, and extensive customization options.

**Properties:**
- `audioUrl` - URL of the audio file
- `waveformHeight` - Height of the waveform display
- `thumbSize` - Size of the progress thumb
- `thumbShape` - Shape of the thumb (circle, verticalBar, roundedBar)
- `activeColor` - Color for played portion
- `inactiveColor` - Color for unplayed portion
- `thumbColor` - Color of the progress thumb
- `backgroundColor` - Background color
- `showPlayButton` - Whether to show play/pause button
- `showDuration` - Whether to show duration text
- `autoPlay` - Whether to auto-play on load
- `playButtonSize` - Size of the play/pause button
- `playButtonColor` - Color of the play/pause button background
- `playButtonIconColor` - Color of the play/pause button icon
- `durationTextStyle` - Text style for duration display
- `borderColor` - Color of the border
- `animationDuration` - Duration of animations
- `onPlayPause` - Callback when play/pause state changes
- `onPositionChanged` - Callback when position changes during playback
- `onCompleted` - Callback when playback completes
- `onError` - Callback when an error occurs
- `glowColor` - Color of the play/pause button glow
- `barWidth` - Width of waveform bars
- `barSpacing` - Spacing between waveform bars

### BasicAudioSlider

A customizable audio slider with waveform visualization and multiple thumb shapes.

**Properties:**
- `value` - Current position value
- `max` - Maximum value
- `onChanged` - Callback when value changes
- `onChangeStart` - Callback when seeking starts
- `onChangeEnd` - Callback when seeking ends
- `waveformData` - List of waveform bar heights
- `activeColor` - Color for played portion
- `inactiveColor` - Color for unplayed portion
- `thumbColor` - Color of the thumb
- `height` - Height of the slider
- `thumbSize` - Size of the thumb
- `thumbShape` - Shape of the thumb (circle, verticalBar, roundedBar)
- `barWidth` - Width of each waveform bar
- `barSpacing` - Spacing between waveform bars


## Services

### AudioManager

A singleton service for managing audio playback across the app.

```dart
// Set current player
await AudioManager().setCurrentPlayer(audioPlayer);

// Clear current player
AudioManager().clearCurrentPlayer(audioPlayer);

// Pause all audio
await AudioManager().pauseAll();

// Stop all audio
await AudioManager().stopAll();
```

### RealWaveformGenerator

Service for generating waveform data from audio files.

```dart
final waveformData = await RealWaveformGenerator.generateWaveformFromAudio(
  audioUrl,
  targetBars: 50,
  minHeight: 2.0,
  maxHeight: 25.0,
);
```

## Styling

The package includes a comprehensive set of colors and text styles:

### Colors

```dart
// Primary colors
WavePlayerColors.primary
WavePlayerColors.primaryLight
WavePlayerColors.primaryDark
WavePlayerColors.primary70
WavePlayerColors.primary50
WavePlayerColors.primary30
WavePlayerColors.primary10

// Secondary colors
WavePlayerColors.secondary

// Semantic colors
WavePlayerColors.success
WavePlayerColors.warning
WavePlayerColors.error
WavePlayerColors.info

// Background colors
WavePlayerColors.background
WavePlayerColors.surface
WavePlayerColors.surfaceVariant

// Text colors
WavePlayerColors.textPrimary
WavePlayerColors.textSecondary
WavePlayerColors.textOnPrimary

// Audio player specific
WavePlayerColors.waveformActive
WavePlayerColors.waveformInactive
WavePlayerColors.waveformThumb
WavePlayerColors.playButton

// Basic colors
WavePlayerColors.white
WavePlayerColors.black
WavePlayerColors.red
WavePlayerColors.green
WavePlayerColors.orange

// Neutral colors
WavePlayerColors.neutral10
WavePlayerColors.neutral50
WavePlayerColors.neutral60
WavePlayerColors.neutral70
WavePlayerColors.neutral80
```

### Text Styles

```dart
// Main text styles
WavePlayerTextStyles.small
WavePlayerTextStyles.body
WavePlayerTextStyles.bodyMedium
WavePlayerTextStyles.large

// Legacy compatibility (still available)
WavePlayerTextStyles.regularSmall
WavePlayerTextStyles.regularMedium
WavePlayerTextStyles.regularLarge
WavePlayerTextStyles.smallMedium
WavePlayerTextStyles.mediumMedium
WavePlayerTextStyles.mediumLarge
WavePlayerTextStyles.boldLarge
```


## Example

See the `example/` directory for a complete example app demonstrating all features.

```bash
cd example
flutter run
```

## Dependencies

- `just_audio` - Audio playback
- `path_provider` - File system access
- `http` - HTTP requests for audio files

## Requirements

- Flutter 3.6+
- Dart 3.6+
- iOS 11.0+ / Android API 21+

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Support

If you encounter any issues or have questions, please file an issue on the [GitHub repository](https://github.com/your-username/wave_player/issues).

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes and version history.
