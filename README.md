# Countdown Carousel Widget

[![pub package](https://img.shields.io/pub/v/countdown_carousel_widget.svg)](https://pub.dev/packages/countdown_carousel_widget)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev)

A highly customizable countdown timer widget with an image carousel, powered by Dart Isolates for optimal performance on native platforms.

## Features

- **Countdown Timer**: Displays days, hours, minutes, and seconds until a target date
- **Image Carousel**: Horizontally scrollable image carousel with pagination indicators
- **Cross-Platform**: Automatic platform detection with appropriate implementation
- **Isolate Support**: Background processing on native platforms (iOS, Android, macOS, Windows, Linux)
- **Web Support**: Timer-based fallback for web platform (Isolates not supported)
- **Multiple Independent Countdowns**: Run multiple countdowns simultaneously, each with its own Isolate
- **Pause/Resume/Reset**: Full control over countdown lifecycle
- **Global Controls**: Manage all countdowns at once
- **Fully Customizable**: Colors, labels, and styles can be configured
- **Animated**: Smooth scale animations on value changes
- **Responsive**: Adapts to available screen width

## Platform Support

| Platform | Implementation | Notes |
|----------|---------------|-------|
| iOS | Isolate | Background thread processing |
| Android | Isolate | Background thread processing |
| macOS | Isolate | Background thread processing |
| Windows | Isolate | Background thread processing |
| Linux | Isolate | Background thread processing |
| **Web** | **Timer** | Isolates NOT supported on web |

The widget automatically detects the platform and uses the appropriate implementation.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  countdown_carousel_widget: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Usage

```dart
import 'package:countdown_carousel_widget/countdown_carousel_widget.dart';

CountdownCarouselWidget(
  targetDate: DateTime.now().add(Duration(days: 2, hours: 14)),
  images: [
    CarouselImageItem.fromProvider(NetworkImage('https://example.com/image.jpg')),
  ],
  onAddImage: () => print('Add image tapped'),
  onCountdownComplete: () => print('Countdown complete!'),
)
```

### Countdown Only (without carousel)

```dart
CountdownOnlyWidget(
  targetDate: DateTime.now().add(Duration(hours: 5)),
  onCountdownComplete: () => print('Done!'),
)
```

### Custom Styling

```dart
CountdownCarouselWidget(
  targetDate: DateTime.now().add(Duration(days: 1)),
  boxColor: Color(0xFF4A148C),
  carouselBackgroundColor: Color(0xFFCE93D8),
  timeLabels: ['DIAS', 'HORAS', 'MINS', 'SEGS'],
)
```

### Multiple Independent Countdowns

Each countdown runs in its own Isolate and can be controlled independently:

```dart
// Create individual controllers
final controller1 = ControllableCountdownController(
  id: 'event_1',
  targetDate: DateTime.now().add(Duration(hours: 2)),
  useIsolate: true,
);

final controller2 = ControllableCountdownController(
  id: 'event_2',
  targetDate: DateTime.now().add(Duration(hours: 5)),
  useIsolate: true,
);

// Use in widgets
ControllableCountdownWidget(
  controller: controller1,
  onCountdownComplete: () => print('Event 1 complete!'),
)

// Control individually
controller1.pause();    // Only pauses controller1
controller2.resume();   // Only affects controller2
controller1.reset();    // Reset to original target
```

### Global Control for Multiple Countdowns

```dart
final globalManager = GlobalCountdownManager();

// Register controllers
globalManager.register(controller1);
globalManager.register(controller2);

// Control all at once
globalManager.pauseAll();
globalManager.resumeAll();
globalManager.resetAll();

// Clean up
await globalManager.disposeAll();
```

### Controllable Countdown Card (with built-in controls)

```dart
ControllableCountdownCard(
  controller: controller,
  title: 'Event Countdown',
  showControls: true,
  onCountdownComplete: () => print('Done!'),
)
```

### Checking Platform Support

```dart
// Check if isolates are supported on the current platform
if (CountdownManagerFactory.isolatesSupported) {
  print('Running on native platform with Isolate support');
} else {
  print('Running on web platform with Timer fallback');
}
```

### Force Timer Mode (all platforms)

```dart
CountdownCarouselWidget(
  targetDate: DateTime.now().add(Duration(days: 1)),
  useIsolate: false, // Forces Timer usage even on native platforms
)
```

## API Reference

### CountdownCarouselWidget

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `targetDate` | `DateTime` | **required** | The target date/time for the countdown |
| `images` | `List<CarouselImageItem>` | `[]` | List of images to display |
| `onAddImage` | `VoidCallback?` | `null` | Callback when "Add Image" is tapped |
| `onImageTap` | `Function(int)?` | `null` | Callback when an image is tapped |
| `onImageRemove` | `Function(int)?` | `null` | Callback when remove button is tapped |
| `onCountdownComplete` | `VoidCallback?` | `null` | Callback when countdown reaches zero |
| `maxImages` | `int` | `10` | Maximum number of images allowed |
| `useIsolate` | `bool?` | Auto-detect | `null`: auto-detect, `true`: force isolate, `false`: force timer |
| `boxColor` | `Color` | `Color(0xFF1E3A5F)` | Background color of time boxes |
| `numberColor` | `Color` | `Colors.white` | Color of countdown numbers |
| `labelColor` | `Color` | `Colors.white` | Color of labels (DAYS, HOURS, etc.) |
| `carouselBackgroundColor` | `Color` | `Color(0xFFB3D4E8)` | Background color of carousel |
| `timeLabels` | `List<String>?` | `['DAYS', 'HOURS', 'MINS', 'SECS']` | Custom labels |
| `animateChanges` | `bool` | `true` | Animate value changes |

### ControllableCountdownController

| Property/Method | Type | Description |
|-----------------|------|-------------|
| `id` | `String` | Unique identifier for the countdown |
| `state` | `CountdownState` | Current state (idle, running, paused, completed, stopped) |
| `isRunning` | `bool` | Whether countdown is actively running |
| `isPaused` | `bool` | Whether countdown is paused |
| `timeStream` | `Stream<TimeRemaining>` | Stream of time updates |
| `stateStream` | `Stream<CountdownState>` | Stream of state changes |
| `start()` | `Future<void>` | Start the countdown |
| `pause()` | `void` | Pause the countdown |
| `resume()` | `void` | Resume from paused state |
| `reset()` | `void` | Reset to original target |
| `resetTo(DateTime)` | `void` | Reset to new target |
| `dispose()` | `Future<void>` | Clean up resources |

### GlobalCountdownManager

| Method | Description |
|--------|-------------|
| `register(controller)` | Register a controller for global management |
| `unregister(id)` | Remove a controller from management |
| `pauseAll()` | Pause all registered countdowns |
| `resumeAll()` | Resume all registered countdowns |
| `resetAll()` | Reset all to original targets |
| `resetAllTo(DateTime)` | Reset all to new target |
| `disposeAll()` | Dispose all controllers |

### CarouselImageItem

```dart
// Create from an ImageProvider
CarouselImageItem.fromProvider(
  NetworkImage('https://example.com/image.jpg'),
  id: 'unique_id',
)

// Create an add button placeholder
CarouselImageItem.addButton()
```

## Architecture

### Native Platforms (Isolate)

```
Main Isolate (UI)              Worker Isolate
      |                              |
      |---- spawn() --------------->|
      |                              |
      |<---- TimeRemaining ---------|
      |      (every second)          |
      |                              |
      |---- pause() --------------->|
      |---- resume() -------------->|
      |---- reset() --------------->|
      |                              |
```

### Web Platform (Timer)

```
Main Thread
      |
      |-- Timer.periodic(1 second)
      |         |
      |         v
      |   Calculate TimeRemaining
      |         |
      |         v
      |   Update UI via Stream
      |
```

### Multiple Countdowns Architecture

```
┌─────────────────────────────────────────────────────┐
│                  Main Isolate (UI)                   │
│                                                      │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────┐ │
│  │ Controller 1 │  │ Controller 2 │  │Controller N│ │
│  └──────┬───────┘  └──────┬───────┘  └─────┬──────┘ │
└─────────┼─────────────────┼────────────────┼────────┘
          │                 │                │
          v                 v                v
   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
   │  Isolate 1   │  │  Isolate 2   │  │  Isolate N   │
   │  (Timer)     │  │  (Timer)     │  │  (Timer)     │
   └──────────────┘  └──────────────┘  └──────────────┘
```

## Why Isolates Don't Work on Web

Dart Isolates are **not supported** on web platforms. This is because:

1. **JavaScript is single-threaded**: The browser's JavaScript engine runs on a single thread
2. **Web Workers are different**: While Web Workers exist, they have a different API than Isolates
3. **No built-in support**: Flutter/Dart doesn't provide automatic translation of Isolates to Web Workers

This package handles this automatically by:
- Using **conditional imports** to avoid importing `dart:isolate` on web
- Providing a **Timer-based fallback** that works identically on web
- **Auto-detecting** the platform at runtime

## Example

See the [example](example/) directory for a complete demo application with:
- Basic countdown with carousel
- Multiple independent countdowns
- Global controls demo
- Custom styling examples

```bash
cd example
flutter run -d chrome  # Test web platform (Timer)
flutter run -d macos   # Test native platform (Isolate)
flutter run -d android # Test Android (Isolate)
```

## Testing

Run the test suite:

```bash
flutter test
```

The package includes 39+ tests covering:
- TimeRemaining model
- CountdownConfig model
- Widget rendering
- Timer manager functionality
- Multiple countdown independence
- Global manager operations
- Pause/Resume/Reset operations

## Contributing

Contributions are welcome! Please read our contributing guidelines and submit pull requests to our repository.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes.

## Support

If you find this package helpful, please give it a star on GitHub!

For bugs and feature requests, please [create an issue](https://github.com/juansuarez-pragma/prg_timer/issues).
