import 'dart:async';

import 'package:flutter/material.dart';

import 'package:countdown_carousel_widget/src/controllers/controllable_countdown_controller.dart';
import 'package:countdown_carousel_widget/src/isolates/countdown_manager_interface.dart';
import 'package:countdown_carousel_widget/src/models/countdown_config.dart';
import 'package:countdown_carousel_widget/src/widgets/countdown_display.dart';

/// A countdown widget with external control capabilities.
///
/// Unlike [CountdownOnlyWidget], this widget takes a [ControllableCountdownController]
/// which allows external control of the countdown (pause, resume, reset).
///
/// ## Features
/// - Displays countdown timer (days, hours, minutes, seconds)
/// - Externally controllable via [ControllableCountdownController]
/// - Visual state indicators (paused, completed)
/// - Customizable colors and labels
///
/// ## Example
/// ```dart
/// final controller = ControllableCountdownController(
///   id: 'my_countdown',
///   targetDate: DateTime.now().add(Duration(hours: 5)),
/// );
///
/// // In your widget build:
/// ControllableCountdownWidget(
///   controller: controller,
///   onCountdownComplete: () => print('Done!'),
/// )
///
/// // Control from anywhere:
/// controller.pause();
/// controller.resume();
/// controller.reset();
/// ```
class ControllableCountdownWidget extends StatefulWidget {
  /// The controller that manages this countdown
  final ControllableCountdownController controller;

  /// Callback when countdown reaches zero
  final VoidCallback? onCountdownComplete;

  /// Callback when state changes
  final void Function(CountdownState state)? onStateChanged;

  /// Background color of the time boxes
  final Color boxColor;

  /// Color of the countdown numbers
  final Color numberColor;

  /// Color of the labels (DAYS, HOURS, etc.)
  final Color labelColor;

  /// Custom labels for the time units
  final List<String>? timeLabels;

  /// Whether to show state indicator overlay
  final bool showStateIndicator;

  /// Whether to animate value changes
  final bool animateChanges;

  /// Opacity when paused (to indicate paused state)
  final double pausedOpacity;

  const ControllableCountdownWidget({
    super.key,
    required this.controller,
    this.onCountdownComplete,
    this.onStateChanged,
    this.boxColor = const Color(0xFF1E3A5F),
    this.numberColor = Colors.white,
    this.labelColor = Colors.white,
    this.timeLabels,
    this.showStateIndicator = true,
    this.animateChanges = true,
    this.pausedOpacity = 0.6,
  });

  @override
  State<ControllableCountdownWidget> createState() =>
      _ControllableCountdownWidgetState();
}

class _ControllableCountdownWidgetState
    extends State<ControllableCountdownWidget> {
  TimeRemaining _timeRemaining = const TimeRemaining.zero();
  CountdownState _state = CountdownState.idle;
  StreamSubscription<TimeRemaining>? _timeSubscription;
  StreamSubscription<CountdownState>? _stateSubscription;
  bool _completionNotified = false;

  @override
  void initState() {
    super.initState();
    _setupSubscriptions();
    _startIfNeeded();
  }

  @override
  void didUpdateWidget(ControllableCountdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _timeSubscription?.cancel();
      _stateSubscription?.cancel();
      _setupSubscriptions();
      _startIfNeeded();
    }
  }

  void _setupSubscriptions() {
    // Subscribe to time updates
    _timeSubscription = widget.controller.timeStream.listen((time) {
      if (mounted) {
        setState(() {
          _timeRemaining = time;
        });
      }
    });

    // Subscribe to state changes
    _stateSubscription = widget.controller.stateStream.listen((state) {
      if (mounted) {
        setState(() {
          _state = state;
        });

        widget.onStateChanged?.call(state);

        // Notify completion only once
        if (state == CountdownState.completed && !_completionNotified) {
          _completionNotified = true;
          widget.onCountdownComplete?.call();
        }

        // Reset completion flag when restarted
        if (state == CountdownState.running) {
          _completionNotified = false;
        }
      }
    });
  }

  Future<void> _startIfNeeded() async {
    if (!widget.controller.isStarted) {
      await widget.controller.start();
    }

    // Update initial state
    if (mounted) {
      setState(() {
        _state = widget.controller.state;
        _timeRemaining = widget.controller.currentTimeRemaining;
      });
    }
  }

  @override
  void dispose() {
    _timeSubscription?.cancel();
    _stateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPaused = _state == CountdownState.paused;
    final isCompleted = _state == CountdownState.completed;

    return AnimatedOpacity(
      opacity: isPaused ? widget.pausedOpacity : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Stack(
        children: [
          CountdownDisplay(
            timeRemaining: _timeRemaining,
            boxColor: widget.boxColor,
            numberColor: widget.numberColor,
            labelColor: widget.labelColor,
            labels: widget.timeLabels,
            animate: widget.animateChanges,
          ),
          if (widget.showStateIndicator && (isPaused || isCompleted))
            Positioned.fill(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isPaused
                        ? Colors.orange.withValues(alpha: 0.9)
                        : Colors.green.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isPaused ? 'PAUSED' : 'COMPLETED',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A card widget that displays a controllable countdown with built-in controls.
///
/// This is a convenience widget that combines [ControllableCountdownWidget]
/// with pause/resume and reset buttons.
///
/// ## Example
/// ```dart
/// ControllableCountdownCard(
///   controller: controller,
///   title: 'Event Countdown',
///   showControls: true,
/// )
/// ```
class ControllableCountdownCard extends StatefulWidget {
  /// The controller that manages this countdown
  final ControllableCountdownController controller;

  /// Title displayed above the countdown
  final String? title;

  /// Whether to show the control buttons
  final bool showControls;

  /// Callback when countdown reaches zero
  final VoidCallback? onCountdownComplete;

  /// Background color of the card
  final Color? cardColor;

  /// Background color of the time boxes
  final Color boxColor;

  /// Color of the countdown numbers
  final Color numberColor;

  /// Color of the labels
  final Color labelColor;

  /// Custom labels for time units
  final List<String>? timeLabels;

  /// Padding inside the card
  final EdgeInsets padding;

  /// Border radius of the card
  final double borderRadius;

  const ControllableCountdownCard({
    super.key,
    required this.controller,
    this.title,
    this.showControls = true,
    this.onCountdownComplete,
    this.cardColor,
    this.boxColor = const Color(0xFF1E3A5F),
    this.numberColor = Colors.white,
    this.labelColor = Colors.white,
    this.timeLabels,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16,
  });

  @override
  State<ControllableCountdownCard> createState() =>
      _ControllableCountdownCardState();
}

class _ControllableCountdownCardState extends State<ControllableCountdownCard> {
  CountdownState _state = CountdownState.idle;
  StreamSubscription<CountdownState>? _stateSubscription;

  @override
  void initState() {
    super.initState();
    _setupStateListener();
  }

  @override
  void didUpdateWidget(ControllableCountdownCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _stateSubscription?.cancel();
      _setupStateListener();
    }
  }

  void _setupStateListener() {
    _stateSubscription = widget.controller.stateStream.listen((state) {
      if (mounted) {
        setState(() {
          _state = state;
        });
      }
    });
    _state = widget.controller.state;
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRunning = _state == CountdownState.running;
    final isPaused = _state == CountdownState.paused;

    return Card(
      color: widget.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: Padding(
        padding: widget.padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.title != null) ...[
              Text(
                widget.title!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
            ],
            ControllableCountdownWidget(
              controller: widget.controller,
              boxColor: widget.boxColor,
              numberColor: widget.numberColor,
              labelColor: widget.labelColor,
              timeLabels: widget.timeLabels,
              onCountdownComplete: widget.onCountdownComplete,
              showStateIndicator: true,
            ),
            if (widget.showControls) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Pause/Resume button
                  IconButton.filled(
                    onPressed: () {
                      if (isRunning) {
                        widget.controller.pause();
                      } else if (isPaused) {
                        widget.controller.resume();
                      }
                    },
                    icon: Icon(
                      isRunning ? Icons.pause : Icons.play_arrow,
                    ),
                    tooltip: isRunning ? 'Pause' : 'Resume',
                  ),
                  const SizedBox(width: 8),
                  // Reset button
                  IconButton.filled(
                    onPressed: () {
                      widget.controller.reset();
                    },
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Reset',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
