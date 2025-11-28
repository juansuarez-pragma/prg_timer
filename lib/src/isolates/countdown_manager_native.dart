import 'countdown_manager_interface.dart';
import 'countdown_isolate_manager.dart';

/// Creates a countdown manager for native platforms (iOS, Android, macOS, Windows, Linux).
/// Uses Isolates for background processing.
CountdownManagerBase createCountdownManager() {
  return CountdownIsolateManager();
}

/// Isolates are supported on native platforms
bool get isolatesSupported => true;
