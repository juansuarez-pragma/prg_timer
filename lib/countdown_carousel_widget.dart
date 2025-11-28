/// A customizable countdown timer widget with image carousel,
/// powered by Dart Isolates for optimal performance on native platforms.
///
/// ## Platform Support
///
/// This package automatically detects the platform and uses the appropriate
/// implementation:
///
/// - **Native platforms** (iOS, Android, macOS, Windows, Linux):
///   Uses Dart Isolates for background countdown calculations.
///
/// - **Web platform**:
///   Uses Timer.periodic since Isolates are NOT supported on web.
///
/// ## Main Components
///
/// - [CountdownCarouselWidget]: Main widget with countdown timer and image carousel
/// - [CountdownOnlyWidget]: Simpler widget with just the countdown timer
/// - [TimeRemaining]: Model for countdown time values
/// - [CarouselImageItem]: Model for carousel images
/// - [CountdownManagerFactory]: Factory for creating platform-appropriate managers
///
/// ## Example Usage
///
/// ```dart
/// import 'package:countdown_carousel_widget/countdown_carousel_widget.dart';
///
/// CountdownCarouselWidget(
///   targetDate: DateTime.now().add(Duration(days: 2, hours: 14)),
///   images: [
///     CarouselImageItem.fromProvider(NetworkImage('https://example.com/image.jpg')),
///   ],
///   onAddImage: () => print('Add image tapped'),
///   onCountdownComplete: () => print('Countdown complete!'),
/// )
/// ```
///
/// ## Checking Platform Support
///
/// ```dart
/// // Check if isolates are supported on the current platform
/// if (CountdownManagerFactory.isolatesSupported) {
///   print('Running on native platform with Isolate support');
/// } else {
///   print('Running on web platform with Timer fallback');
/// }
/// ```
library;

// Models
export 'src/models/countdown_config.dart'
    show TimeRemaining, CountdownConfig, CountdownTheme;

// Countdown managers (for advanced usage)
export 'src/isolates/countdown_manager_interface.dart'
    show CountdownManagerBase, CountdownState;
export 'src/isolates/countdown_manager_factory.dart' show CountdownManagerFactory;
export 'src/isolates/countdown_timer_manager.dart' show CountdownTimerManager;

// Controllers
export 'src/controllers/controllable_countdown_controller.dart'
    show ControllableCountdownController, GlobalCountdownManager;

// Widgets
export 'src/widgets/time_box.dart' show TimeBox, AnimatedTimeBox;
export 'src/widgets/countdown_display.dart'
    show CountdownDisplay, ResponsiveCountdownDisplay;
export 'src/widgets/image_carousel.dart' show ImageCarousel, CarouselImageItem;
export 'src/widgets/controllable_countdown_widget.dart'
    show ControllableCountdownWidget, ControllableCountdownCard;

// Main widgets
export 'src/countdown_carousel_widget.dart'
    show CountdownCarouselWidget, CountdownOnlyWidget;
