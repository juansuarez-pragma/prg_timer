import 'dart:async';

import 'package:countdown_carousel_widget/src/isolates/countdown_manager_factory.dart';
import 'package:countdown_carousel_widget/src/isolates/countdown_manager_interface.dart';
import 'package:countdown_carousel_widget/src/models/countdown_config.dart';

/// Controlador para gestionar un único temporizador de cuenta atrás con control total.
///
/// Cada controlador crea su propia instancia de [CountdownManagerBase],
/// garantizando una independencia total de otras cuentas atrás.
///
/// ## Características
/// - Iniciar/Detener la cuenta atrás
/// - Pausar/Reanudar sin perder el progreso
/// - Restablecer a una fecha objetivo nueva o a la original
/// - Seguimiento del estado a través de streams
///
/// ## Garantía de Independencia
/// Cada instancia de [ControllableCountdownController]:
/// - Crea su propio Isolate (en nativo) o Timer (en web)
/// - Mantiene su propio estado de forma independiente
/// - Puede ser controlado sin afectar a otros controladores
///
/// ## Ejemplo
/// ```dart
/// final controller = ControllableCountdownController(
/// id: 'countdown_1',
/// targetDate: DateTime.now().add(Duration(hours: 2)),
/// );
///
/// await controller.start();
///
/// // Pausar solo esta cuenta atrás
/// controller.pause();
///
/// // Reanudar más tarde
/// controller.resume();
///
/// // Restablecer al objetivo original
/// controller.reset();
///
/// // Limpiar
/// await controller.dispose();
/// ```
class ControllableCountdownController {
  /// Identificador único para esta cuenta atrás
  final String id;

  /// La fecha objetivo original (usada para restablecer al original)
  final DateTime _originalTargetDate;

  /// Fecha objetivo actual (puede cambiar después de restablecer con una nueva fecha)
  DateTime _currentTargetDate;

  /// Intervalo de actualización en milisegundos
  final int updateIntervalMs;

  /// Si se debe usar Isolate (nulo = autodetección)
  final bool? useIsolate;

  /// El gestor de la cuenta atrás (basado en Isolate o Timer)
  CountdownManagerBase? _manager;

  /// Controlador de stream para las actualizaciones del tiempo restante
  StreamController<TimeRemaining>? _timeStreamController;

  /// Controlador de stream para las actualizaciones de estado
  final StreamController<CountdownState> _stateStreamController =
      StreamController<CountdownState>.broadcast();

  /// Suscripción al stream del gestor
  StreamSubscription<TimeRemaining>? _managerSubscription;

  /// Tiempo restante actual (cacheado para los getters)
  TimeRemaining _currentTimeRemaining = const TimeRemaining.zero();

  /// Si la cuenta atrás ha comenzado
  bool _isStarted = false;

  /// Crea un nuevo controlador de cuenta atrás controlable.
  ///
  /// [id] - Identificador único para esta cuenta atrás
  /// [targetDate] - La fecha/hora objetivo para la cuenta atrás
  /// [updateIntervalMs] - Con qué frecuencia actualizar (por defecto: 1000ms)
  /// [useIsolate] - Forzar isolate (true), forzar temporizador (false), o autodetección (nulo)
  ControllableCountdownController({
    required this.id,
    required DateTime targetDate,
    this.updateIntervalMs = 1000,
    this.useIsolate,
  }) : _originalTargetDate = targetDate,
       _currentTargetDate = targetDate;

  /// Stream de las actualizaciones del tiempo restante
  Stream<TimeRemaining> get timeStream {
    _timeStreamController ??= StreamController<TimeRemaining>.broadcast();
    return _timeStreamController!.stream;
  }

  /// Stream de los cambios de estado
  Stream<CountdownState> get stateStream => _stateStreamController.stream;

  /// Estado actual de la cuenta atrás
  CountdownState get state => _manager?.state ?? CountdownState.idle;

  /// Si la cuenta atrás está actualmente en ejecución
  bool get isRunning => _manager?.isRunning ?? false;

  /// Si la cuenta atrás está actualmente en pausa
  bool get isPaused => _manager?.isPaused ?? false;

  /// Si la cuenta atrás ha comenzado (puede estar en pausa/detenida)
  bool get isStarted => _isStarted;

  /// Si la cuenta atrás ha finalizado (llegado a cero)
  bool get isCompleted => state == CountdownState.completed;

  /// Tiempo restante actual
  TimeRemaining get currentTimeRemaining => _currentTimeRemaining;

  /// La fecha objetivo original
  DateTime get originalTargetDate => _originalTargetDate;

  /// La fecha objetivo actual
  DateTime get currentTargetDate => _currentTargetDate;

  /// Duración restante (para el estado de pausa)
  Duration? get remainingDuration => _manager?.remainingDuration;

  /// Inicia el temporizador de la cuenta atrás.
  ///
  /// Crea el gestor apropiado (Isolate o Timer) basado en la plataforma
  /// y la configuración de useIsolate.
  Future<void> start() async {
    if (_isStarted && state == CountdownState.running) return;

    // Crear el gestor si es necesario
    _manager ??= CountdownManagerFactory.create(
      forceTimer: useIsolate == false,
    );

    _timeStreamController ??= StreamController<TimeRemaining>.broadcast();

    // Iniciar el gestor
    final managerStream = await _manager!.start(
      _currentTargetDate,
      updateIntervalMs: updateIntervalMs,
    );

    // Escuchar las actualizaciones del gestor
    _managerSubscription?.cancel();
    _managerSubscription = managerStream.listen(
      (timeRemaining) {
        _currentTimeRemaining = timeRemaining;
        _timeStreamController?.add(timeRemaining);

        // Comprobar si ha finalizado
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

  /// Pausa la cuenta atrás.
  ///
  /// La cuenta atrás se puede reanudar desde donde se dejó usando [resume].
  /// No hace nada si no está en ejecución.
  void pause() {
    if (_manager == null || !isRunning) return;

    _manager!.pause();
    _notifyStateChange(CountdownState.paused);
  }

  /// Reanuda una cuenta atrás pausada.
  ///
  /// La cuenta atrás continúa desde donde se pausó.
  /// No hace nada si no está en pausa.
  void resume() {
    if (_manager == null || !isPaused) return;

    _manager!.resume();
    _notifyStateChange(CountdownState.running);
  }

  /// Alterna entre los estados de pausa y ejecución.
  ///
  /// Si está en ejecución, pausa. Si está en pausa, reanuda.
  void togglePause() {
    if (isRunning) {
      pause();
    } else if (isPaused) {
      resume();
    }
  }

  /// Restablece la cuenta atrás a la fecha objetivo original.
  ///
  /// Si la cuenta atrás está en ejecución, continúa ejecutándose con el nuevo objetivo.
  /// Si está en pausa, permanece en pausa pero actualiza el tiempo restante.
  void reset() {
    resetTo(_originalTargetDate);
  }

  /// Restablece la cuenta atrás a una nueva fecha objetivo.
  ///
  /// [newTargetDate] - La nueva fecha/hora objetivo
  void resetTo(DateTime newTargetDate) {
    _currentTargetDate = newTargetDate;

    if (_manager != null) {
      _manager!.reset(newTargetDate);
    }
  }

  /// Detiene la cuenta atrás por completo.
  ///
  /// A diferencia de [pause], esto indica que la cuenta atrás ha terminado.
  /// Llama a [start] para comenzar de nuevo.
  void stop() {
    _manager?.stop();
    _notifyStateChange(CountdownState.stopped);
  }

  /// Actualiza la fecha objetivo mientras la cuenta atrás está en ejecución.
  ///
  /// Esto es diferente de [resetTo] ya que no afecta el estado de ejecución.
  void updateTargetDate(DateTime newTargetDate) {
    _currentTargetDate = newTargetDate;
    _manager?.updateTargetDate(newTargetDate);
  }

  /// Notifica a los oyentes de un cambio de estado
  void _notifyStateChange(CountdownState newState) {
    if (!_stateStreamController.isClosed) {
      _stateStreamController.add(newState);
    }
  }

  /// Libera todos los recursos.
  ///
  /// Llama a esto cuando el controlador ya no sea necesario.
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

/// Gestor para controlar múltiples controladores de cuenta atrás de forma global.
///
/// Úsalo para pausar, reanudar o restablecer todas las cuentas atrás a la vez.
///
/// ## Ejemplo
/// ```dart
/// final globalManager = GlobalCountdownManager();
///
/// // Registrar controladores
/// globalManager.register(controller1);
/// globalManager.register(controller2);
///
/// // Pausar todos
/// globalManager.pauseAll();
///
/// // Reanudar todos
/// globalManager.resumeAll();
///
/// // Restablecer todos a sus objetivos originales
/// globalManager.resetAll();
///
/// // Limpiar
/// await globalManager.disposeAll();
/// ```
class GlobalCountdownManager {
  final Map<String, ControllableCountdownController> _controllers = {};

  /// Todos los IDs de los controladores registrados
  Iterable<String> get controllerIds => _controllers.keys;

  /// Número de controladores registrados
  int get count => _controllers.length;

  /// Si hay algún controlador registrado
  bool get isEmpty => _controllers.isEmpty;

  /// Si hay controladores registrados
  bool get isNotEmpty => _controllers.isNotEmpty;

  /// Registra un controlador en el gestor global.
  ///
  /// El [id] del controlador se usa como clave.
  void register(ControllableCountdownController controller) {
    _controllers[controller.id] = controller;
  }

  /// Cancela el registro de un controlador en el gestor global.
  ///
  /// No libera el controlador.
  void unregister(String id) {
    _controllers.remove(id);
  }

  /// Obtiene un controlador por ID.
  ControllableCountdownController? getController(String id) {
    return _controllers[id];
  }

  /// Inicia todas las cuentas atrás registradas.
  Future<void> startAll() async {
    for (final controller in _controllers.values) {
      await controller.start();
    }
  }

  /// Pausa todas las cuentas atrás registradas.
  void pauseAll() {
    for (final controller in _controllers.values) {
      controller.pause();
    }
  }

  /// Reanuda todas las cuentas atrás registradas.
  void resumeAll() {
    for (final controller in _controllers.values) {
      controller.resume();
    }
  }

  /// Restablece todas las cuentas atrás a sus fechas objetivo originales.
  void resetAll() {
    for (final controller in _controllers.values) {
      controller.reset();
    }
  }

  /// Restablece todas las cuentas atrás a una nueva fecha objetivo.
  void resetAllTo(DateTime newTargetDate) {
    for (final controller in _controllers.values) {
      controller.resetTo(newTargetDate);
    }
  }

  /// Detiene todas las cuentas atrás registradas.
  void stopAll() {
    for (final controller in _controllers.values) {
      controller.stop();
    }
  }

  /// Libera todos los controladores registrados y borra el registro.
  Future<void> disposeAll() async {
    for (final controller in _controllers.values) {
      await controller.dispose();
    }
    _controllers.clear();
  }
}
