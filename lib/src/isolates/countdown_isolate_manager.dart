import 'dart:async';
import 'dart:isolate';

import 'package:countdown_carousel_widget/src/models/countdown_config.dart';
import 'package:countdown_carousel_widget/src/isolates/countdown_manager_interface.dart';

/// Tipos de mensajes para la comunicación con el isolate
enum _IsolateMessageType {
  start,
  stop,
  updateTarget,
  timeUpdate,
  completed,
  error,
  pause,
  resume,
  reset,
  stateUpdate,
}

/// Envoltorio de mensajes para la comunicación con el isolate
class _IsolateMessage {
  final _IsolateMessageType type;
  final dynamic data;

  const _IsolateMessage(this.type, [this.data]);

  Map<String, dynamic> toMap() {
    return {'type': type.index, 'data': data};
  }

  factory _IsolateMessage.fromMap(Map<String, dynamic> map) {
    return _IsolateMessage(
      _IsolateMessageType.values[map['type'] as int],
      map['data'],
    );
  }
}

/// Datos de configuración pasados al isolate en su creación
class _IsolateSetupData {
  final SendPort sendPort;
  final int targetDateMs;
  final int updateIntervalMs;

  const _IsolateSetupData({
    required this.sendPort,
    required this.targetDateMs,
    required this.updateIntervalMs,
  });
}

/// Gestor de cuenta atrás basado en Isolate para plataformas nativas.
///
/// Esta implementación genera un Isolate separado para manejar los
/// cálculos de la cuenta atrás, manteniendo libre el hilo principal de la UI.
///
/// **Importante**: Esta clase SOLO debe usarse en plataformas nativas
/// (iOS, Android, macOS, Windows, Linux). NO funcionará en la web.
///
/// ## Características
/// - Iniciar/Detener la cuenta atrás en un isolate en segundo plano
/// - Pausar/Reanudar sin destruir el isolate
/// - Restablecer a una nueva fecha objetivo
/// - Operación independiente (cada instancia tiene su propio isolate)
///
/// Usa [CountdownManagerFactory.create()] para obtener automáticamente la
/// implementación correcta para la plataforma actual.
class CountdownIsolateManager implements CountdownManagerBase {
  Isolate? _isolate;
  ReceivePort? _receivePort;
  SendPort? _sendPort;
  StreamController<TimeRemaining>? _streamController;
  CountdownState _state = CountdownState.idle;
  Duration? _pausedRemainingDuration;
  int _updateIntervalMs = 1000;

  @override
  Stream<TimeRemaining>? get timeStream => _streamController?.stream;

  @override
  bool get isRunning => _state == CountdownState.running;

  @override
  bool get isPaused => _state == CountdownState.paused;

  @override
  CountdownState get state => _state;

  @override
  Duration? get remainingDuration => _pausedRemainingDuration;

  @override
  Future<Stream<TimeRemaining>> start(
    DateTime targetDate, {
    int updateIntervalMs = 1000,
  }) async {
    // Limpiar cualquier isolate existente
    await dispose();

    _updateIntervalMs = updateIntervalMs;
    _streamController = StreamController<TimeRemaining>.broadcast();
    _receivePort = ReceivePort();

    // Generar el isolate
    _isolate = await Isolate.spawn(
      _isolateEntryPoint,
      _IsolateSetupData(
        sendPort: _receivePort!.sendPort,
        targetDateMs: targetDate.millisecondsSinceEpoch,
        updateIntervalMs: updateIntervalMs,
      ),
    );

    _state = CountdownState.running;

    // Escuchar los mensajes del isolate
    _receivePort!.listen((message) {
      if (message is SendPort) {
        // Almacenar el send port para la comunicación bidireccional
        _sendPort = message;
      } else if (message is Map<String, dynamic>) {
        final isolateMessage = _IsolateMessage.fromMap(message);
        _handleIsolateMessage(isolateMessage);
      }
    });

    return _streamController!.stream;
  }

  void _handleIsolateMessage(_IsolateMessage message) {
    if (_streamController == null || _streamController!.isClosed) return;

    switch (message.type) {
      case _IsolateMessageType.timeUpdate:
        final timeRemaining = TimeRemaining.fromMap(
          message.data as Map<String, dynamic>,
        );
        _streamController?.add(timeRemaining);
        break;
      case _IsolateMessageType.completed:
        _streamController?.add(const TimeRemaining.zero());
        _state = CountdownState.completed;
        break;
      case _IsolateMessageType.stateUpdate:
        final data = message.data as Map<String, dynamic>;
        final stateIndex = data['state'] as int;
        _state = CountdownState.values[stateIndex];
        if (data['remainingMs'] != null) {
          _pausedRemainingDuration = Duration(
            milliseconds: data['remainingMs'] as int,
          );
        }
        break;
      case _IsolateMessageType.error:
        _streamController?.addError(message.data ?? 'Unknown error in isolate');
        break;
      default:
        break;
    }
  }

  @override
  void updateTargetDate(DateTime newTargetDate) {
    if (_sendPort != null) {
      _sendPort!.send(
        _IsolateMessage(
          _IsolateMessageType.updateTarget,
          newTargetDate.millisecondsSinceEpoch,
        ).toMap(),
      );
    }
  }

  @override
  void pause() {
    if (_state != CountdownState.running) return;
    if (_sendPort != null) {
      _sendPort!.send(_IsolateMessage(_IsolateMessageType.pause).toMap());
      _state = CountdownState.paused;
    }
  }

  @override
  void resume() {
    if (_state != CountdownState.paused) return;
    if (_sendPort != null) {
      _sendPort!.send(_IsolateMessage(_IsolateMessageType.resume).toMap());
      _state = CountdownState.running;
    }
  }

  @override
  void reset(DateTime newTargetDate) {
    if (_sendPort != null) {
      _sendPort!.send(
        _IsolateMessage(
          _IsolateMessageType.reset,
          newTargetDate.millisecondsSinceEpoch,
        ).toMap(),
      );
      // If was paused, stay paused; if was running, stay running
      if (_state == CountdownState.completed ||
          _state == CountdownState.stopped) {
        _state = CountdownState.running;
      }
    }
  }

  @override
  void stop() {
    if (_sendPort != null) {
      _sendPort!.send(_IsolateMessage(_IsolateMessageType.stop).toMap());
    }
    _state = CountdownState.stopped;
  }

  @override
  Future<void> dispose() async {
    stop();
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _receivePort?.close();
    _receivePort = null;
    _sendPort = null;
    await _streamController?.close();
    _streamController = null;
    _state = CountdownState.idle;
    _pausedRemainingDuration = null;
  }
}

/// Punto de entrada para el isolate de la cuenta atrás (se ejecuta en un isolate separado)
void _isolateEntryPoint(_IsolateSetupData setupData) {
  final receivePort = ReceivePort();

  // Enviar nuestro receive port de vuelta al isolate principal para la comunicación bidireccional
  setupData.sendPort.send(receivePort.sendPort);

  int targetDateMs = setupData.targetDateMs;
  final int updateIntervalMs = setupData.updateIntervalMs;
  Timer? timer;
  bool isRunning = true;
  bool isPaused = false;
  int? pausedRemainingMs;

  // Función para calcular y enviar el tiempo restante
  void sendTimeUpdate() {
    if (!isRunning || isPaused) return;

    final now = DateTime.now();
    final targetDate = DateTime.fromMillisecondsSinceEpoch(targetDateMs);
    final difference = targetDate.difference(now);

    if (difference.isNegative || difference == Duration.zero) {
      // Cuenta atrás finalizada
      setupData.sendPort.send(
        _IsolateMessage(_IsolateMessageType.completed).toMap(),
      );
      timer?.cancel();
      isRunning = false;
      return;
    }

    final timeRemaining = TimeRemaining.fromDuration(difference);
    setupData.sendPort.send(
      _IsolateMessage(
        _IsolateMessageType.timeUpdate,
        timeRemaining.toMap(),
      ).toMap(),
    );
  }

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(
      Duration(milliseconds: updateIntervalMs),
      (_) => sendTimeUpdate(),
    );
  }

  void sendStateUpdate(int stateIndex, {int? remainingMs}) {
    setupData.sendPort.send(
      _IsolateMessage(_IsolateMessageType.stateUpdate, {
        'state': stateIndex,
        'remainingMs': remainingMs,
      }).toMap(),
    );
  }

  // Enviar la actualización de tiempo inicial
  sendTimeUpdate();

  // Iniciar las actualizaciones periódicas
  startTimer();

  // Escuchar los mensajes del isolate principal
  receivePort.listen((message) {
    if (message is Map<String, dynamic>) {
      final isolateMessage = _IsolateMessage.fromMap(message);

      switch (isolateMessage.type) {
        case _IsolateMessageType.stop:
          timer?.cancel();
          isRunning = false;
          isPaused = false;
          receivePort.close();
          break;

        case _IsolateMessageType.updateTarget:
          targetDateMs = isolateMessage.data as int;
          pausedRemainingMs = null;
          if (!isPaused) {
            sendTimeUpdate();
          } else {
            // Actualizar el tiempo restante en pausa
            final now = DateTime.now();
            final targetDate = DateTime.fromMillisecondsSinceEpoch(
              targetDateMs,
            );
            pausedRemainingMs = targetDate.difference(now).inMilliseconds;
            final timeRemaining = TimeRemaining.fromDuration(
              Duration(milliseconds: pausedRemainingMs!),
            );
            setupData.sendPort.send(
              _IsolateMessage(
                _IsolateMessageType.timeUpdate,
                timeRemaining.toMap(),
              ).toMap(),
            );
          }
          break;

        case _IsolateMessageType.pause:
          if (isRunning && !isPaused) {
            // Almacenar el tiempo restante
            final now = DateTime.now();
            final targetDate = DateTime.fromMillisecondsSinceEpoch(
              targetDateMs,
            );
            pausedRemainingMs = targetDate.difference(now).inMilliseconds;

            // Cancelar el temporizador pero mantener vivo el isolate
            timer?.cancel();
            timer = null;
            isPaused = true;

            // Enviar la hora actual una vez más
            final timeRemaining = TimeRemaining.fromDuration(
              Duration(milliseconds: pausedRemainingMs!),
            );
            setupData.sendPort.send(
              _IsolateMessage(
                _IsolateMessageType.timeUpdate,
                timeRemaining.toMap(),
              ).toMap(),
            );

            // Notificar el cambio de estado
            sendStateUpdate(
              CountdownState.paused.index,
              remainingMs: pausedRemainingMs,
            );
          }
          break;

        case _IsolateMessageType.resume:
          if (isPaused && pausedRemainingMs != null) {
            // Calcular el nuevo objetivo basado en el tiempo restante
            targetDateMs = DateTime.now()
                .add(Duration(milliseconds: pausedRemainingMs!))
                .millisecondsSinceEpoch;
            pausedRemainingMs = null;
            isPaused = false;

            // Enviar actualización inmediata y reiniciar el temporizador
            sendTimeUpdate();
            startTimer();

            // Notificar el cambio de estado
            sendStateUpdate(CountdownState.running.index);
          }
          break;

        case _IsolateMessageType.reset:
          targetDateMs = isolateMessage.data as int;
          pausedRemainingMs = null;

          if (isPaused) {
            // Mantenerse en pausa pero actualizar el tiempo restante
            final now = DateTime.now();
            final targetDate = DateTime.fromMillisecondsSinceEpoch(
              targetDateMs,
            );
            pausedRemainingMs = targetDate.difference(now).inMilliseconds;

            final timeRemaining = TimeRemaining.fromDuration(
              Duration(milliseconds: pausedRemainingMs!),
            );
            setupData.sendPort.send(
              _IsolateMessage(
                _IsolateMessageType.timeUpdate,
                timeRemaining.toMap(),
              ).toMap(),
            );
          } else {
            // Si se completó o se detuvo, reiniciar
            isRunning = true;
            sendTimeUpdate();
            startTimer();
          }
          break;

        default:
          break;
      }
    }
  });
}
