import 'countdown_manager_interface.dart';
import 'countdown_isolate_manager.dart';

/// Crea un gestor de cuenta atrás para plataformas nativas (iOS, Android, macOS, Windows, Linux).
/// Usa Isolates para el procesamiento en segundo plano.
CountdownManagerBase createCountdownManager() {
  return CountdownIsolateManager();
}

/// Los Isolates son compatibles con las plataformas nativas
bool get isolatesSupported => true;
