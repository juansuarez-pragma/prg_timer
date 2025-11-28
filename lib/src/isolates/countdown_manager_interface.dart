import 'dart:async';

import 'package:countdown_carousel_widget/src/models/countdown_config.dart';

/// Estado de un gestor de cuenta atrás
enum CountdownState {
  /// Estado inicial, aún no ha comenzado
  idle,

  /// La cuenta atrás está activa
  running,

  /// La cuenta atrás está en pausa (se puede reanudar)
  paused,

  /// La cuenta atrás ha finalizado (llegado a cero)
  completed,

  /// La cuenta atrás se ha detenido (desechado)
  stopped,
}

/// Interfaz abstracta para los gestores de cuenta atrás.
///
/// Esto permite diferentes implementaciones para diferentes plataformas:
/// - [CountdownIsolateManager] para plataformas nativas (iOS, Android, macOS, Windows, Linux)
/// - [CountdownTimerManager] para la plataforma web (donde los Isolates no son compatibles)
///
/// ## Ciclo de vida
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
  /// Stream de las actualizaciones del tiempo restante
  Stream<TimeRemaining>? get timeStream;

  /// Si la cuenta atrás está actualmente en ejecución (no en pausa, no detenida)
  bool get isRunning;

  /// Si la cuenta atrás está actualmente en pausa
  bool get isPaused;

  /// Estado actual de la cuenta atrás
  CountdownState get state;

  /// El tiempo restante cuando está en pausa (usado para reanudar)
  Duration? get remainingDuration;

  /// Inicia la cuenta atrás hasta la fecha objetivo
  ///
  /// Devuelve un Stream que emite actualizaciones de [TimeRemaining]
  Future<Stream<TimeRemaining>> start(
    DateTime targetDate, {
    int updateIntervalMs = 1000,
  });

  /// Actualiza la fecha objetivo mientras la cuenta atrás está en ejecución
  void updateTargetDate(DateTime newTargetDate);

  /// Pausa la cuenta atrás sin liberar los recursos.
  /// La cuenta atrás se puede reanudar desde donde se dejó usando [resume].
  void pause();

  /// Reanuda una cuenta atrás pausada desde donde se dejó.
  /// No hace nada si la cuenta atrás no está en pausa.
  void resume();

  /// Restablece la cuenta atrás a una nueva fecha objetivo.
  /// Si está en ejecución, continuará ejecutándose con el nuevo objetivo.
  /// Si está en pausa, permanecerá en pausa pero actualizará el objetivo.
  void reset(DateTime newTargetDate);

  /// Detiene la cuenta atrás por completo.
  /// A diferencia de [pause], esto prepara la liberación de recursos.
  void stop();

  /// Libera los recursos
  Future<void> dispose();
}
