import 'dart:async';

import 'package:countdown_carousel_widget/src/models/countdown_config.dart';
import 'package:countdown_carousel_widget/src/isolates/countdown_manager_interface.dart';

/// Gestor de cuenta atrás basado en Timer.
///
/// Esta implementación utiliza un simple [Timer.periodic] para actualizar la cuenta atrás.
/// Funciona en TODAS las plataformas, incluida la web.
///
/// Se utiliza:
/// - En la plataforma web (donde los Isolates no son compatibles)
/// - Como alternativa cuando falla la creación de un Isolate
/// - Cuando el usuario establece explícitamente `useIsolate: false`
///
/// ## Características
/// - Iniciar/Detener la cuenta atrás
/// - Pausar/Reanudar sin perder el progreso
/// - Restablecer a una nueva fecha objetivo
/// - Operación independiente (cada instancia tiene su propio temporizador)
class CountdownTimerManager implements CountdownManagerBase {
  Timer? _timer;
  StreamController<TimeRemaining>? _streamController;
  DateTime _targetDate;
  int _updateIntervalMs;
  CountdownState _state = CountdownState.idle;

  /// Almacena la duración restante cuando está en pausa
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
    // Limpiar cualquier temporizador existente
    await dispose();

    _targetDate = targetDate;
    _updateIntervalMs = updateIntervalMs;
    _state = CountdownState.running;
    _pausedRemainingDuration = null;
    _streamController = StreamController<TimeRemaining>.broadcast();

    // Enviar el valor inicial inmediatamente
    _sendTimeUpdate();

    // Iniciar el temporizador periódico
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
      // Actualizar la duración restante en pausa
      _pausedRemainingDuration = newTargetDate.difference(DateTime.now());
      // Enviar actualización para mostrar el nuevo tiempo incluso mientras está en pausa
      if (_streamController != null && !_streamController!.isClosed) {
        _streamController!.add(
          TimeRemaining.fromDuration(_pausedRemainingDuration!),
        );
      }
    }
  }

  @override
  void pause() {
    if (_state != CountdownState.running) return;

    // Almacenar el tiempo restante
    _pausedRemainingDuration = _targetDate.difference(DateTime.now());

    // Cancelar el temporizador pero mantener el stream abierto
    _timer?.cancel();
    _timer = null;
    _state = CountdownState.paused;

    // Enviar el estado actual al stream
    if (_streamController != null && !_streamController!.isClosed) {
      _streamController!.add(
        TimeRemaining.fromDuration(_pausedRemainingDuration!),
      );
    }
  }

  @override
  void resume() {
    if (_state != CountdownState.paused) return;
    if (_pausedRemainingDuration == null) return;

    // Calcular la nueva fecha objetivo basada en la duración restante
    _targetDate = DateTime.now().add(_pausedRemainingDuration!);
    _pausedRemainingDuration = null;
    _state = CountdownState.running;

    // Enviar actualización inmediata
    _sendTimeUpdate();

    // Reiniciar el temporizador
    _startTimer();
  }

  @override
  void reset(DateTime newTargetDate) {
    final wasRunning = _state == CountdownState.running;
    final wasPaused = _state == CountdownState.paused;

    // Cancelar el temporizador existente
    _timer?.cancel();
    _timer = null;

    // Actualizar el objetivo
    _targetDate = newTargetDate;
    _pausedRemainingDuration = null;

    // Si estaba en ejecución o en pausa con un stream válido, actualizar el estado y reiniciar
    if (_streamController != null && !_streamController!.isClosed) {
      if (wasRunning) {
        _state = CountdownState.running;
        _sendTimeUpdate();
        _startTimer();
      } else if (wasPaused) {
        // Mantenerse en pausa pero con el nuevo objetivo
        _pausedRemainingDuration = newTargetDate.difference(DateTime.now());
        _state = CountdownState.paused;
        _streamController!.add(
          TimeRemaining.fromDuration(_pausedRemainingDuration!),
        );
      } else {
        // Estaba inactivo o completado, solo actualizar el objetivo
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
