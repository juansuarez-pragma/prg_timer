import 'countdown_manager_interface.dart';
import 'countdown_timer_manager.dart';

// Conditional imports: uses the correct implementation based on platform
import 'countdown_manager_stub.dart'
    if (dart.library.io) 'countdown_manager_native.dart'
    if (dart.library.html) 'countdown_manager_web.dart'
    as platform;

/// Clase factory para crear el gestor de cuenta atrás apropiado
/// basado en la plataforma actual.
///
/// En plataformas nativas (iOS, Android, macOS, Windows, Linux):
/// - Crea [CountdownIsolateManager] que usa Dart Isolates
///
/// En la plataforma web:
/// - Crea [CountdownTimerManager] que usa Timer.periodic
/// (ya que los Isolates NO son compatibles con la web)
///
/// Ejemplo:
/// ```dart
/// final manager = CountdownManagerFactory.create();
/// final stream = await manager.start(targetDate);
/// ```
class CountdownManagerFactory {
  CountdownManagerFactory._();

  /// Crea el gestor de cuenta atrás apropiado para la plataforma actual.
  ///
  /// Si [forceTimer] es verdadero, siempre devuelve un [CountdownTimerManager]
  /// independientemente de la plataforma. Esto es útil para:
  /// - Pruebas
  /// - Cuando se desea un comportamiento consistente en todas las plataformas
  /// - Cuando la sobrecarga del isolate no vale la pena para cuentas atrás simples
  static CountdownManagerBase create({bool forceTimer = false}) {
    if (forceTimer) {
      return CountdownTimerManager();
    }
    return platform.createCountdownManager();
  }

  /// Devuelve verdadero si la plataforma actual admite Isolates.
  ///
  /// - Devuelve `true` en plataformas nativas (iOS, Android, macOS, Windows, Linux)
  /// - Devuelve `false` en la plataforma web
  static bool get isolatesSupported => platform.isolatesSupported;

  /// Devuelve una descripción legible por humanos de la implementación de la cuenta atrás
  /// de la plataforma actual.
  static String get platformDescription {
    if (platform.isolatesSupported) {
      return 'Plataforma nativa: Usando el gestor de cuenta atrás basado en Isolate';
    } else {
      return 'Plataforma web: Usando el gestor de cuenta atrás basado en Timer (Isolates no soportados)';
    }
  }
}
