# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.5] - 2025-03-13

### Added
- `PlayPauseButton` — extracted reusable play/pause widget with glow effect
- `WaveformPlayerDelegate` — delegate pattern for controller ↔ widget communication
- `assetPath` support — play audio from local assets
- Custom icon support: `playIconWidget`, `pauseIconWidget`, `animatedIcon`
- Glow customization: `glowColor`, `glowCount`, `glowRadiusFactor`, `glowDuration`, `showGlow`
- CI/CD with GitHub Actions (format, analyze, test)
- PR template, issue template, CONTRIBUTING.md

### Changed
- Refactored `WaveformPlayer` architecture — separated play button, delegate, controller
- Improved `BasicAudioSlider` — gesture handling split (tap vs drag)
- Seek behavior: audio keeps playing during drag, only seeks on release
- `onPlayPause` fires consistently from both UI and controller
- `onPositionChanged` fires during seek drag
- Rewrote `RealWaveformGenerator` with better normalization and web compatibility
- Stricter `analysis_options.yaml` lint rules
- README rewritten — concise, focused on usage

### Fixed
- Audio stutter and position jump when starting to drag slider
- Memory leaks in audio subscriptions
- Type safety improvements across all widgets

## [0.0.4]

### Added
- `WaveformPlayerController` — programmatic play/pause/seek
- Controller API: `play()`, `pause()`, `togglePlayPause()`, `seekTo()`, `seekToPercentage()`
- State getters: `isPlaying`, `position`, `duration`, `isLoading`, `hasError`

### Changed
- Streamlined example app with controller demo

## [0.0.3]

### Fixed
- Demo audio URL

## [0.0.2]

### Fixed
- Platform support — only platforms compatible with `just_audio` (Android, iOS, Web, macOS)
- Web compatibility in waveform generation

### Changed
- Updated `just_audio` to `^0.10.5`
- Updated `path_provider` to `^2.1.5`
- Removed Windows and Linux platform support

## [0.0.1]

### Added
- Initial release
- `WaveformPlayer` widget with audio visualization and playback
- `BasicAudioSlider` with customizable waveform and thumb shapes
- `AudioManager` singleton for coordinated playback
- `RealWaveformGenerator` for audio waveform data
- `WavePlayerTheme` for global theming
- Cross-platform support (Android, iOS, Web, macOS)