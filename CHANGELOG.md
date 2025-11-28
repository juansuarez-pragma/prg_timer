# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-11-28

### Added

- **CountdownCarouselWidget**: Main widget with countdown timer and image carousel
- **CountdownOnlyWidget**: Simplified widget with just the countdown timer
- **Isolate Support**: Background processing on native platforms (iOS, Android, macOS, Windows, Linux)
- **Web Support**: Timer-based fallback for web platform where Isolates are not supported
- **Platform Auto-Detection**: Automatic selection of appropriate implementation based on platform
- **ControllableCountdownController**: Individual countdown controller with pause/resume/reset
- **GlobalCountdownManager**: Manage multiple countdowns with batch operations
- **ControllableCountdownWidget**: Widget with external control capabilities
- **ControllableCountdownCard**: Card widget with built-in control buttons
- **Multiple Independent Countdowns**: Each countdown runs in its own Isolate
- **Customizable Styling**: Colors, labels, and styles can be configured
- **Animated Value Changes**: Smooth scale animations on value changes
- **Responsive Design**: Adapts to available screen width
- **Image Carousel**: Horizontally scrollable image carousel with pagination
- **TimeRemaining Model**: Immutable model for countdown time values
- **CountdownState Enum**: State management for countdown lifecycle

### Features

- Countdown displays days, hours, minutes, and seconds
- Pause, resume, and reset individual countdowns
- Global pause/resume/reset for all countdowns
- Customizable time labels (localization support)
- Add/remove images in carousel
- Image tap and remove callbacks
- Countdown completion callback
- Force timer mode option for debugging

### Technical

- Conditional imports for web compatibility
- Bidirectional Isolate communication
- Stream-based time updates
- 39+ unit and widget tests
- Full API documentation
