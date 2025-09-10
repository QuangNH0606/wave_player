# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
## [0.0.4]
### 🎮 New Features
- **Added WaveformPlayerController** - Programmatic control for play/pause/seek operations
- **Enhanced WaveformPlayer** - Added public methods and getters for external access
- **Improved Example** - Compact single-screen layout with controller demo

### 🔧 Technical Improvements
- **Controller API** - `play()`, `pause()`, `togglePlayPause()`, `seekTo()`, `seekToPercentage()`
- **State Access** - `isPlaying`, `position`, `duration`, `isLoading`, `hasError` getters
- **Memory Safety** - Proper controller lifecycle management
- **Better UX** - Streamlined example with GitHub audio source

### 📚 Documentation
- **Updated examples** - Added controller usage documentation
- **GitHub integration** - Stable audio source using raw GitHub URLs

## [0.0.3] 
### 🚀 Bug Fixes
- **Fixed demo support** - Updated url

## [0.0.2] 

### 🚀 Bug Fixes & Improvements
- **Fixed platform support** - Updated to support only platforms compatible with `just_audio` (Android, iOS, Web, macOS)
- **Fixed Web compatibility** - Added proper handling for Web platform in waveform generation
- **Updated dependencies** - Upgraded all dependencies to latest versions for better compatibility
- **Fixed image display** - Improved README image formatting and sizing for better presentation
- **Enhanced documentation** - Updated all documentation to reflect current API

### 🔧 Technical Changes
- Updated `just_audio` from `^0.9.36` to `^0.10.5`
- Removed Windows and Linux platform support to match `just_audio` capabilities
- Added Web-specific handling in `RealWaveformGenerator`

### 📱 Platform Support
- ✅ Android
- ✅ iOS  
- ✅ Web
- ✅ macOS
- ❌ Windows (removed due to `just_audio` limitations)
- ❌ Linux (removed due to `just_audio` limitations)

## [0.0.1]

### 🎉 Initial Release

This is the first release of Wave Player, a comprehensive Flutter package for audio waveform visualization and playback.

### Added
- Initial release of Wave Player package
- `WaveformPlayer` widget with comprehensive audio visualization and playback controls
- `BasicAudioSlider` widget with customizable waveform display and multiple thumb shapes
- `AudioManager` singleton service for coordinated audio playback management
- `RealWaveformGenerator` service for generating waveform data from audio files
- Comprehensive theming system with `WavePlayerTheme` for easy customization
- Support for multiple thumb shapes: circle, verticalBar, roundedBar
- Extensive customization options for colors, text styles, and animations
- Cross-platform support for Android, iOS, Web, Windows, macOS, and Linux
- Professional documentation with examples and API reference
- Complete example application demonstrating all features

### Features
- Real-time waveform visualization with smooth animations
- Interactive play/pause controls with visual feedback
- Precise seek functionality with drag-and-drop support
- Highly customizable UI components with extensive theming
- Global theme management for consistent app-wide styling
- Coordinated audio playback to prevent multiple audio streams
- Comprehensive error handling with user-friendly callbacks
- Responsive design that adapts to different screen sizes
- Optimized performance for smooth audio playback

### Technical Details
- Built with Flutter 3.6+ and Dart 3.6+
- Uses `just_audio` for reliable audio playback
- Utilizes `http` for network audio file requests
- Follows Flutter best practices and Material Design guidelines

### Breaking Changes
- None (this is the initial release)

### Migration Guide
- This is the first release, so no migration is needed
- Future versions will maintain backward compatibility where possible

### Known Issues
- None at this time

### Future Plans
- Enhanced waveform visualization options
- Additional thumb shapes and customization
- Performance optimizations
- More comprehensive theming options