import 'dart:async';

import 'package:countdown_carousel_widget/src/models/countdown_config.dart';
import 'package:countdown_carousel_widget/src/isolates/countdown_manager_interface.dart';

/// Timer-based countdown manager.
///
/// This implementation uses a simple [Timer.periodic] to update the countdown.
/// It works on ALL platforms including web.
///
/// This is used:
/// - On web platform (where Isolates are not supported)
/// - As a fallback when Isolate creation fails
/// - When the user explicitly sets `useIsolate: false`
///
/// ## Features
/// - Start/Stop countdown
/// - Pause/Resume without losing progress
/// - Reset to new target date
/// - Independent operation (each instance has its own timer)
class CountdownTimerManager implements CountdownManagerBase {
  Timer? _timer;
  StreamController<TimeRemaining>? _streamController;
  DateTime _targetDate;
  int _updateIntervalMs;
  CountdownState _state = CountdownState.idle;

  /// Stores the remaining duration when paused
  Duration? _pausedRemainingDuration;

  CountdownTimerManager()
      : _targetDate = DateTime.now(),
        _updateIntervalMs = 1000;

  @override
  Stream<TimeRemaining>? get timeStream => _streamController?.stream;

  @override
  bool get isRunning => _state == CountdownState.running;

  @override
  bool get isPaused => _state == CountdownState.paused;

  @override
  CountdownState get state => _state;

  @override
  Duration? get remainingDuration {
    if (_state == CountdownState.paused) {
      return _pausedRemainingDuration;
    }
    if (_state == CountdownState.running) {
      return _targetDate.difference(DateTime.now());
    }
    return null;
  }

  @override
  Future<Stream<TimeRemaining>> start(
    DateTime targetDate, {
    int updateIntervalMs = 1000,
  }) async {
    // Clean up any existing timer
    await dispose();

    _targetDate = targetDate;
    _updateIntervalMs = updateIntervalMs;
    _state = CountdownState.running;
    _pausedRemainingDuration = null;
    _streamController = StreamController<TimeRemaining>.broadcast();

    // Send initial value immediately
    _sendTimeUpdate();

    // Start periodic timer
    _startTimer();

    return _streamController!.stream;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      Duration(milliseconds: _updateIntervalMs),
      (_) => _sendTimeUpdate(),
    );
  }

  void _sendTimeUpdate() {
    if (_streamController == null || _streamController!.isClosed) return;
    if (_state != CountdownState.running) return;

    final timeRemaining = TimeRemaining.fromTargetDate(_targetDate);
    _streamController?.add(timeRemaining);

    if (timeRemaining.isCompleted) {
      _timer?.cancel();
      _timer = null;
      _state = CountdownState.completed;
    }
  }

  @override
  void updateTargetDate(DateTime newTargetDate) {
    _targetDate = newTargetDate;
    _pausedRemainingDuration = null;

    if (_state == CountdownState.running) {
      _sendTimeUpdate();
    } else if (_state == CountdownState.paused) {
      // Update the paused remaining duration
      _pausedRemainingDuration = newTargetDate.difference(DateTime.now());
      // Send update to show new time even while paused
      if (_streamController != null && !_streamController!.isClosed) {
        _streamController!.add(TimeRemaining.fromDuration(_pausedRemainingDuration!));
      }
    }
  }

  @override
  void pause() {
    if (_state != CountdownState.running) return;

    // Store the remaining time
    _pausedRemainingDuration = _targetDate.difference(DateTime.now());

    // Cancel the timer but keep the stream open
    _timer?.cancel();
    _timer = null;
    _state = CountdownState.paused;

    // Send current state to stream
    if (_streamController != null && !_streamController!.isClosed) {
      _streamController!.add(TimeRemaining.fromDuration(_pausedRemainingDuration!));
    }
  }

  @override
  void resume() {
    if (_state != CountdownState.paused) return;
    if (_pausedRemainingDuration == null) return;

    // Calculate new target date based on remaining duration
    _targetDate = DateTime.now().add(_pausedRemainingDuration!);
    _pausedRemainingDuration = null;
    _state = CountdownState.running;

    // Send immediate update
    _sendTimeUpdate();

    // Restart the timer
    _startTimer();
  }

  @override
  void reset(DateTime newTargetDate) {
    final wasRunning = _state == CountdownState.running;
    final wasPaused = _state == CountdownState.paused;

    // Cancel existing timer
    _timer?.cancel();
    _timer = null;

    // Update target
    _targetDate = newTargetDate;
    _pausedRemainingDuration = null;

    // If was running or paused with a valid stream, update state and restart
    if (_streamController != null && !_streamController!.isClosed) {
      if (wasRunning) {
        _state = CountdownState.running;
        _sendTimeUpdate();
        _startTimer();
      } else if (wasPaused) {
        // Stay paused but with new target
        _pausedRemainingDuration = newTargetDate.difference(DateTime.now());
        _state = CountdownState.paused;
        _streamController!.add(TimeRemaining.fromDuration(_pausedRemainingDuration!));
      } else {
        // Was idle or completed, just update target
        _state = CountdownState.idle;
      }
    }
  }

  @override
  void stop() {
    _timer?.cancel();
    _timer = null;
    _state = CountdownState.stopped;
    _pausedRemainingDuration = null;
  }

  @override
  Future<void> dispose() async {
    stop();
    await _streamController?.close();
    _streamController = null;
    _state = CountdownState.idle;
  }
}
