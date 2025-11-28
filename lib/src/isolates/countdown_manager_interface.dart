import 'dart:async';

import '../models/countdown_config.dart';

/// State of a countdown manager
enum CountdownState {
  /// Initial state, not started yet
  idle,

  /// Countdown is actively running
  running,

  /// Countdown is paused (can be resumed)
  paused,

  /// Countdown has completed (reached zero)
  completed,

  /// Countdown was stopped (disposed)
  stopped,
}

/// Abstract interface for countdown managers.
///
/// This allows different implementations for different platforms:
/// - [CountdownIsolateManager] for native platforms (iOS, Android, macOS, Windows, Linux)
/// - [CountdownTimerManager] for web platform (where Isolates are not supported)
///
/// ## Lifecycle
///
/// ```
/// idle -> start() -> running -> pause() -> paused -> resume() -> running
///                       |                     |
///                       v                     v
///                  completed              completed
///                       |                     |
///                       +------> stop() <-----+
///                                   |
///                                   v
///                               stopped
/// ```
abstract class CountdownManagerBase {
  /// Stream of time remaining updates
  Stream<TimeRemaining>? get timeStream;

  /// Whether the countdown is currently running (not paused, not stopped)
  bool get isRunning;

  /// Whether the countdown is currently paused
  bool get isPaused;

  /// Current state of the countdown
  CountdownState get state;

  /// The remaining time when paused (used for resume)
  Duration? get remainingDuration;

  /// Starts the countdown to the target date
  ///
  /// Returns a Stream that emits [TimeRemaining] updates
  Future<Stream<TimeRemaining>> start(
    DateTime targetDate, {
    int updateIntervalMs = 1000,
  });

  /// Updates the target date while the countdown is running
  void updateTargetDate(DateTime newTargetDate);

  /// Pauses the countdown without disposing resources.
  /// The countdown can be resumed from where it left off using [resume].
  void pause();

  /// Resumes a paused countdown from where it left off.
  /// Does nothing if the countdown is not paused.
  void resume();

  /// Resets the countdown to a new target date.
  /// If running, it will continue running with the new target.
  /// If paused, it will remain paused but update the target.
  void reset(DateTime newTargetDate);

  /// Stops the countdown completely.
  /// Unlike [pause], this prepares for disposal.
  void stop();

  /// Disposes of resources
  Future<void> dispose();
}
