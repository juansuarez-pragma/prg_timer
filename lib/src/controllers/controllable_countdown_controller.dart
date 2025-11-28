import 'dart:async';

import 'package:countdown_carousel_widget/src/isolates/countdown_manager_factory.dart';
import 'package:countdown_carousel_widget/src/isolates/countdown_manager_interface.dart';
import 'package:countdown_carousel_widget/src/models/countdown_config.dart';

/// Controller for managing a single countdown timer with full control.
///
/// Each controller creates its own [CountdownManagerBase] instance,
/// ensuring complete independence from other countdowns.
///
/// ## Features
/// - Start/Stop countdown
/// - Pause/Resume without losing progress
/// - Reset to new or original target date
/// - State tracking via streams
///
/// ## Independence Guarantee
/// Each [ControllableCountdownController] instance:
/// - Creates its own Isolate (on native) or Timer (on web)
/// - Maintains its own state independently
/// - Can be controlled without affecting other controllers
///
/// ## Example
/// ```dart
/// final controller = ControllableCountdownController(
///   id: 'countdown_1',
///   targetDate: DateTime.now().add(Duration(hours: 2)),
/// );
///
/// await controller.start();
///
/// // Pause this countdown only
/// controller.pause();
///
/// // Resume later
/// controller.resume();
///
/// // Reset to original target
/// controller.reset();
///
/// // Clean up
/// await controller.dispose();
/// ```
class ControllableCountdownController {
  /// Unique identifier for this countdown
  final String id;

  /// The original target date (used for reset to original)
  final DateTime _originalTargetDate;

  /// Current target date (may change after reset with new date)
  DateTime _currentTargetDate;

  /// Update interval in milliseconds
  final int updateIntervalMs;

  /// Whether to use Isolate (null = auto-detect)
  final bool? useIsolate;

  /// The countdown manager (Isolate or Timer based)
  CountdownManagerBase? _manager;

  /// Stream controller for time remaining updates
  StreamController<TimeRemaining>? _timeStreamController;

  /// Stream controller for state updates
  final StreamController<CountdownState> _stateStreamController =
      StreamController<CountdownState>.broadcast();

  /// Subscription to the manager's stream
  StreamSubscription<TimeRemaining>? _managerSubscription;

  /// Current time remaining (cached for getters)
  TimeRemaining _currentTimeRemaining = const TimeRemaining.zero();

  /// Whether the countdown has been started
  bool _isStarted = false;

  /// Creates a new controllable countdown controller.
  ///
  /// [id] - Unique identifier for this countdown
  /// [targetDate] - The target date/time for the countdown
  /// [updateIntervalMs] - How often to update (default: 1000ms)
  /// [useIsolate] - Force isolate (true), force timer (false), or auto-detect (null)
  ControllableCountdownController({
    required this.id,
    required DateTime targetDate,
    this.updateIntervalMs = 1000,
    this.useIsolate,
  })  : _originalTargetDate = targetDate,
        _currentTargetDate = targetDate;

  /// Stream of time remaining updates
  Stream<TimeRemaining> get timeStream {
    _timeStreamController ??= StreamController<TimeRemaining>.broadcast();
    return _timeStreamController!.stream;
  }

  /// Stream of state changes
  Stream<CountdownState> get stateStream => _stateStreamController.stream;

  /// Current state of the countdown
  CountdownState get state => _manager?.state ?? CountdownState.idle;

  /// Whether the countdown is currently running
  bool get isRunning => _manager?.isRunning ?? false;

  /// Whether the countdown is currently paused
  bool get isPaused => _manager?.isPaused ?? false;

  /// Whether the countdown has been started (may be paused/stopped)
  bool get isStarted => _isStarted;

  /// Whether the countdown has completed (reached zero)
  bool get isCompleted => state == CountdownState.completed;

  /// Current time remaining
  TimeRemaining get currentTimeRemaining => _currentTimeRemaining;

  /// The original target date
  DateTime get originalTargetDate => _originalTargetDate;

  /// The current target date
  DateTime get currentTargetDate => _currentTargetDate;

  /// Remaining duration (for paused state)
  Duration? get remainingDuration => _manager?.remainingDuration;

  /// Starts the countdown timer.
  ///
  /// Creates the appropriate manager (Isolate or Timer) based on platform
  /// and useIsolate setting.
  Future<void> start() async {
    if (_isStarted && state == CountdownState.running) return;

    // Create manager if needed
    _manager ??= CountdownManagerFactory.create(
      forceTimer: useIsolate == false,
    );

    _timeStreamController ??= StreamController<TimeRemaining>.broadcast();

    // Start the manager
    final managerStream = await _manager!.start(
      _currentTargetDate,
      updateIntervalMs: updateIntervalMs,
    );

    // Listen to manager updates
    _managerSubscription?.cancel();
    _managerSubscription = managerStream.listen(
      (timeRemaining) {
        _currentTimeRemaining = timeRemaining;
        _timeStreamController?.add(timeRemaining);

        // Check for completion
        if (timeRemaining.isCompleted &&
            _manager?.state == CountdownState.completed) {
          _notifyStateChange(CountdownState.completed);
        }
      },
      onError: (error) {
        _timeStreamController?.addError(error);
      },
    );

    _isStarted = true;
    _notifyStateChange(CountdownState.running);
  }

  /// Pauses the countdown.
  ///
  /// The countdown can be resumed from where it left off using [resume].
  /// Does nothing if not running.
  void pause() {
    if (_manager == null || !isRunning) return;

    _manager!.pause();
    _notifyStateChange(CountdownState.paused);
  }

  /// Resumes a paused countdown.
  ///
  /// The countdown continues from where it was paused.
  /// Does nothing if not paused.
  void resume() {
    if (_manager == null || !isPaused) return;

    _manager!.resume();
    _notifyStateChange(CountdownState.running);
  }

  /// Toggles between paused and running states.
  ///
  /// If running, pauses. If paused, resumes.
  void togglePause() {
    if (isRunning) {
      pause();
    } else if (isPaused) {
      resume();
    }
  }

  /// Resets the countdown to the original target date.
  ///
  /// If the countdown is running, it continues running with the new target.
  /// If paused, it remains paused but updates the remaining time.
  void reset() {
    resetTo(_originalTargetDate);
  }

  /// Resets the countdown to a new target date.
  ///
  /// [newTargetDate] - The new target date/time
  void resetTo(DateTime newTargetDate) {
    _currentTargetDate = newTargetDate;

    if (_manager != null) {
      _manager!.reset(newTargetDate);
    }
  }

  /// Stops the countdown completely.
  ///
  /// Unlike [pause], this indicates the countdown is done.
  /// Call [start] to begin again.
  void stop() {
    _manager?.stop();
    _notifyStateChange(CountdownState.stopped);
  }

  /// Updates the target date while the countdown is running.
  ///
  /// This is different from [resetTo] as it doesn't affect the running state.
  void updateTargetDate(DateTime newTargetDate) {
    _currentTargetDate = newTargetDate;
    _manager?.updateTargetDate(newTargetDate);
  }

  /// Notifies listeners of a state change
  void _notifyStateChange(CountdownState newState) {
    if (!_stateStreamController.isClosed) {
      _stateStreamController.add(newState);
    }
  }

  /// Disposes of all resources.
  ///
  /// Call this when the controller is no longer needed.
  Future<void> dispose() async {
    _managerSubscription?.cancel();
    _managerSubscription = null;

    await _manager?.dispose();
    _manager = null;

    await _timeStreamController?.close();
    _timeStreamController = null;

    await _stateStreamController.close();

    _isStarted = false;
  }
}

/// Manager for controlling multiple countdown controllers globally.
///
/// Use this to pause, resume, or reset all countdowns at once.
///
/// ## Example
/// ```dart
/// final globalManager = GlobalCountdownManager();
///
/// // Register controllers
/// globalManager.register(controller1);
/// globalManager.register(controller2);
///
/// // Pause all
/// globalManager.pauseAll();
///
/// // Resume all
/// globalManager.resumeAll();
///
/// // Reset all to their original targets
/// globalManager.resetAll();
///
/// // Clean up
/// await globalManager.disposeAll();
/// ```
class GlobalCountdownManager {
  final Map<String, ControllableCountdownController> _controllers = {};

  /// All registered controller IDs
  Iterable<String> get controllerIds => _controllers.keys;

  /// Number of registered controllers
  int get count => _controllers.length;

  /// Whether there are any registered controllers
  bool get isEmpty => _controllers.isEmpty;

  /// Whether there are registered controllers
  bool get isNotEmpty => _controllers.isNotEmpty;

  /// Registers a controller with the global manager.
  ///
  /// The controller's [id] is used as the key.
  void register(ControllableCountdownController controller) {
    _controllers[controller.id] = controller;
  }

  /// Unregisters a controller from the global manager.
  ///
  /// Does not dispose the controller.
  void unregister(String id) {
    _controllers.remove(id);
  }

  /// Gets a controller by ID.
  ControllableCountdownController? getController(String id) {
    return _controllers[id];
  }

  /// Starts all registered countdowns.
  Future<void> startAll() async {
    for (final controller in _controllers.values) {
      await controller.start();
    }
  }

  /// Pauses all registered countdowns.
  void pauseAll() {
    for (final controller in _controllers.values) {
      controller.pause();
    }
  }

  /// Resumes all registered countdowns.
  void resumeAll() {
    for (final controller in _controllers.values) {
      controller.resume();
    }
  }

  /// Resets all registered countdowns to their original target dates.
  void resetAll() {
    for (final controller in _controllers.values) {
      controller.reset();
    }
  }

  /// Resets all registered countdowns to a new target date.
  void resetAllTo(DateTime newTargetDate) {
    for (final controller in _controllers.values) {
      controller.resetTo(newTargetDate);
    }
  }

  /// Stops all registered countdowns.
  void stopAll() {
    for (final controller in _controllers.values) {
      controller.stop();
    }
  }

  /// Disposes all registered controllers and clears the registry.
  Future<void> disposeAll() async {
    for (final controller in _controllers.values) {
      await controller.dispose();
    }
    _controllers.clear();
  }
}
