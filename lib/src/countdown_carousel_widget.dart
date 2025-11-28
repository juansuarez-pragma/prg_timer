import 'dart:async';

import 'package:flutter/material.dart';

import 'isolates/countdown_manager_factory.dart';
import 'isolates/countdown_manager_interface.dart';
import 'models/countdown_config.dart';
import 'widgets/countdown_display.dart';
import 'widgets/image_carousel.dart';

/// A countdown timer widget with an image carousel.
///
/// This widget displays a countdown timer showing days, hours, minutes, and seconds
/// until a target date, along with a scrollable image carousel at the bottom.
///
/// ## Platform-Specific Behavior
///
/// The countdown calculations are handled differently based on the platform:
///
/// - **Native platforms** (iOS, Android, macOS, Windows, Linux):
///   Uses Dart Isolates for background processing, keeping the UI thread free.
///
/// - **Web platform**:
///   Uses Timer.periodic since Isolates are NOT supported on web.
///   The countdown runs on the main thread but is lightweight enough
///   to not affect UI performance.
///
/// You can override this behavior using the [useIsolate] parameter:
/// - `useIsolate: true` - Force isolate usage (will fail on web)
/// - `useIsolate: false` - Force timer usage on all platforms
/// - `useIsolate: null` (default) - Auto-detect based on platform
///
/// Example usage:
/// ```dart
/// CountdownCarouselWidget(
///   targetDate: DateTime.now().add(Duration(days: 2, hours: 14)),
///   images: [
///     CarouselImageItem.fromProvider(NetworkImage('https://example.com/image.jpg')),
///   ],
///   onAddImage: () => print('Add image tapped'),
///   onCountdownComplete: () => print('Countdown complete!'),
/// )
/// ```
class CountdownCarouselWidget extends StatefulWidget {
  /// The target date/time for the countdown
  final DateTime targetDate;

  /// Callback when the countdown reaches zero
  final VoidCallback? onCountdownComplete;

  /// List of images to display in the carousel
  final List<CarouselImageItem> images;

  /// Callback when "Add Image" button is tapped
  final VoidCallback? onAddImage;

  /// Callback when an image is tapped
  final void Function(int index)? onImageTap;

  /// Callback when an image should be removed
  final void Function(int index)? onImageRemove;

  /// Maximum number of images allowed in the carousel
  final int maxImages;

  /// Whether to use an isolate for countdown calculations.
  ///
  /// - `true`: Force isolate usage (will fail silently on web, falling back to timer)
  /// - `false`: Force timer usage on all platforms
  /// - `null` (default): Auto-detect based on platform
  ///   - Native platforms: Uses Isolate
  ///   - Web platform: Uses Timer
  final bool? useIsolate;

  /// Background color of the countdown section
  final Color countdownBackgroundColor;

  /// Background color of the time boxes
  final Color boxColor;

  /// Text color for the countdown numbers
  final Color numberColor;

  /// Text color for the countdown labels
  final Color labelColor;

  /// Background color of the carousel section
  final Color carouselBackgroundColor;

  /// Border radius for the main container
  final double borderRadius;

  /// Border radius for individual time boxes
  final double boxBorderRadius;

  /// Custom labels for time units (defaults to ['DAYS', 'HOURS', 'MINS', 'SECS'])
  final List<String>? timeLabels;

  /// Whether to animate countdown value changes
  final bool animateChanges;

  /// Height of the carousel section
  final double carouselHeight;

  /// "Add Image" button text
  final String addImageText;

  /// Whether to show remove buttons on images
  final bool showImageRemoveButtons;

  const CountdownCarouselWidget({
    super.key,
    required this.targetDate,
    this.onCountdownComplete,
    this.images = const [],
    this.onAddImage,
    this.onImageTap,
    this.onImageRemove,
    this.maxImages = 10,
    this.useIsolate,
    this.countdownBackgroundColor = Colors.white,
    this.boxColor = const Color(0xFF1E3A5F),
    this.numberColor = Colors.white,
    this.labelColor = Colors.white,
    this.carouselBackgroundColor = const Color(0xFFB3D4E8),
    this.borderRadius = 16.0,
    this.boxBorderRadius = 12.0,
    this.timeLabels,
    this.animateChanges = true,
    this.carouselHeight = 120,
    this.addImageText = 'Add Image',
    this.showImageRemoveButtons = true,
  });

  @override
  State<CountdownCarouselWidget> createState() =>
      _CountdownCarouselWidgetState();
}

class _CountdownCarouselWidgetState extends State<CountdownCarouselWidget> {
  TimeRemaining _timeRemaining = const TimeRemaining(
    days: 0,
    hours: 0,
    minutes: 0,
    seconds: 0,
  );

  CountdownManagerBase? _manager;
  StreamSubscription<TimeRemaining>? _subscription;
  bool _countdownComplete = false;

  /// Determines whether to use isolate based on widget config and platform support
  bool get _shouldUseIsolate {
    // If explicitly set to false, never use isolate
    if (widget.useIsolate == false) return false;

    // If explicitly set to true, try to use isolate (may fail on web)
    if (widget.useIsolate == true) return CountdownManagerFactory.isolatesSupported;

    // Auto-detect: use isolate only if platform supports it
    return CountdownManagerFactory.isolatesSupported;
  }

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void didUpdateWidget(CountdownCarouselWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If target date changed, update the manager
    if (oldWidget.targetDate != widget.targetDate) {
      _manager?.updateTargetDate(widget.targetDate);
      _countdownComplete = false;
    }

    // If isolate preference changed, restart with new method
    if (oldWidget.useIsolate != widget.useIsolate) {
      _stopCountdown();
      _startCountdown();
    }
  }

  @override
  void dispose() {
    _stopCountdown();
    super.dispose();
  }

  Future<void> _startCountdown() async {
    _countdownComplete = false;

    // Create the appropriate manager based on platform/preference
    _manager = CountdownManagerFactory.create(forceTimer: !_shouldUseIsolate);

    try {
      final stream = await _manager!.start(widget.targetDate);
      _subscription = stream.listen(
        _onTimeUpdate,
        onError: (error) {
          debugPrint('Countdown error: $error');
        },
      );
    } catch (e) {
      debugPrint('Failed to start countdown: $e');
      // If isolate fails, fallback to timer
      if (_shouldUseIsolate) {
        _manager = CountdownManagerFactory.create(forceTimer: true);
        final stream = await _manager!.start(widget.targetDate);
        _subscription = stream.listen(_onTimeUpdate);
      }
    }
  }

  void _onTimeUpdate(TimeRemaining timeRemaining) {
    if (!mounted) return;

    setState(() {
      _timeRemaining = timeRemaining;
    });

    if (timeRemaining.isCompleted && !_countdownComplete) {
      _countdownComplete = true;
      widget.onCountdownComplete?.call();
    }
  }

  void _stopCountdown() {
    _subscription?.cancel();
    _subscription = null;
    _manager?.dispose();
    _manager = null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.countdownBackgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Countdown display
          ResponsiveCountdownDisplay(
            timeRemaining: _timeRemaining,
            boxColor: widget.boxColor,
            numberColor: widget.numberColor,
            labelColor: widget.labelColor,
            boxBorderRadius: widget.boxBorderRadius,
            animate: widget.animateChanges,
            labels: widget.timeLabels,
          ),
          // Image carousel
          ImageCarousel(
            images: widget.images,
            onAddImage: widget.onAddImage,
            onImageTap: widget.onImageTap,
            onImageRemove: widget.onImageRemove,
            backgroundColor: widget.carouselBackgroundColor,
            maxImages: widget.maxImages,
            height: widget.carouselHeight,
            addImageText: widget.addImageText,
            showRemoveButtons: widget.showImageRemoveButtons,
          ),
        ],
      ),
    );
  }
}

/// A simpler countdown widget without the image carousel.
///
/// This widget displays only the countdown timer (days, hours, minutes, seconds).
/// Use this when you don't need the image carousel functionality.
///
/// See [CountdownCarouselWidget] for documentation on platform-specific behavior.
class CountdownOnlyWidget extends StatefulWidget {
  /// The target date/time for the countdown
  final DateTime targetDate;

  /// Callback when the countdown reaches zero
  final VoidCallback? onCountdownComplete;

  /// Whether to use an isolate for countdown calculations.
  /// See [CountdownCarouselWidget.useIsolate] for details.
  final bool? useIsolate;

  /// Background color of the countdown section
  final Color backgroundColor;

  /// Background color of the time boxes
  final Color boxColor;

  /// Text color for the countdown numbers
  final Color numberColor;

  /// Text color for the countdown labels
  final Color labelColor;

  /// Border radius for the main container
  final double borderRadius;

  /// Border radius for individual time boxes
  final double boxBorderRadius;

  /// Custom labels for time units
  final List<String>? timeLabels;

  /// Whether to animate countdown value changes
  final bool animateChanges;

  const CountdownOnlyWidget({
    super.key,
    required this.targetDate,
    this.onCountdownComplete,
    this.useIsolate,
    this.backgroundColor = Colors.white,
    this.boxColor = const Color(0xFF1E3A5F),
    this.numberColor = Colors.white,
    this.labelColor = Colors.white,
    this.borderRadius = 16.0,
    this.boxBorderRadius = 12.0,
    this.timeLabels,
    this.animateChanges = true,
  });

  @override
  State<CountdownOnlyWidget> createState() => _CountdownOnlyWidgetState();
}

class _CountdownOnlyWidgetState extends State<CountdownOnlyWidget> {
  TimeRemaining _timeRemaining = const TimeRemaining(
    days: 0,
    hours: 0,
    minutes: 0,
    seconds: 0,
  );

  CountdownManagerBase? _manager;
  StreamSubscription<TimeRemaining>? _subscription;
  bool _countdownComplete = false;

  bool get _shouldUseIsolate {
    if (widget.useIsolate == false) return false;
    if (widget.useIsolate == true) return CountdownManagerFactory.isolatesSupported;
    return CountdownManagerFactory.isolatesSupported;
  }

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void didUpdateWidget(CountdownOnlyWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.targetDate != widget.targetDate) {
      _manager?.updateTargetDate(widget.targetDate);
      _countdownComplete = false;
    }

    if (oldWidget.useIsolate != widget.useIsolate) {
      _stopCountdown();
      _startCountdown();
    }
  }

  @override
  void dispose() {
    _stopCountdown();
    super.dispose();
  }

  Future<void> _startCountdown() async {
    _countdownComplete = false;

    _manager = CountdownManagerFactory.create(forceTimer: !_shouldUseIsolate);

    try {
      final stream = await _manager!.start(widget.targetDate);
      _subscription = stream.listen(
        _onTimeUpdate,
        onError: (error) {
          debugPrint('Countdown error: $error');
        },
      );
    } catch (e) {
      debugPrint('Failed to start countdown: $e');
      if (_shouldUseIsolate) {
        _manager = CountdownManagerFactory.create(forceTimer: true);
        final stream = await _manager!.start(widget.targetDate);
        _subscription = stream.listen(_onTimeUpdate);
      }
    }
  }

  void _onTimeUpdate(TimeRemaining timeRemaining) {
    if (!mounted) return;

    setState(() {
      _timeRemaining = timeRemaining;
    });

    if (timeRemaining.isCompleted && !_countdownComplete) {
      _countdownComplete = true;
      widget.onCountdownComplete?.call();
    }
  }

  void _stopCountdown() {
    _subscription?.cancel();
    _subscription = null;
    _manager?.dispose();
    _manager = null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ResponsiveCountdownDisplay(
        timeRemaining: _timeRemaining,
        boxColor: widget.boxColor,
        numberColor: widget.numberColor,
        labelColor: widget.labelColor,
        boxBorderRadius: widget.boxBorderRadius,
        animate: widget.animateChanges,
        labels: widget.timeLabels,
      ),
    );
  }
}
