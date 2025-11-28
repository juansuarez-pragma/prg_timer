import 'countdown_manager_interface.dart';
import 'countdown_timer_manager.dart';

/// Crea un gestor de cuenta atrás para la plataforma web.
/// Usa Timer ya que los Isolates no son compatibles con la web.
CountdownManagerBase createCountdownManager() {
  return CountdownTimerManager();
}

/// Los Isolates NO son compatibles con la plataforma web
bool get isolatesSupported => false;
