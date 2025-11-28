import 'countdown_manager_interface.dart';
import 'countdown_timer_manager.dart';

/// Creates a countdown manager for web platform.
/// Uses Timer since Isolates are not supported on web.
CountdownManagerBase createCountdownManager() {
  return CountdownTimerManager();
}

/// Isolates are NOT supported on web platform
bool get isolatesSupported => false;
