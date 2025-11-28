import 'countdown_manager_interface.dart';
import 'countdown_timer_manager.dart';

// Conditional imports: uses the correct implementation based on platform
import 'countdown_manager_stub.dart'
    if (dart.library.io) 'countdown_manager_native.dart'
    if (dart.library.html) 'countdown_manager_web.dart' as platform;

/// Factory class for creating the appropriate countdown manager
/// based on the current platform.
///
/// On native platforms (iOS, Android, macOS, Windows, Linux):
/// - Creates [CountdownIsolateManager] which uses Dart Isolates
///
/// On web platform:
/// - Creates [CountdownTimerManager] which uses Timer.periodic
///   (since Isolates are NOT supported on web)
///
/// Example:
/// ```dart
/// final manager = CountdownManagerFactory.create();
/// final stream = await manager.start(targetDate);
/// ```
class CountdownManagerFactory {
  CountdownManagerFactory._();

  /// Creates the appropriate countdown manager for the current platform.
  ///
  /// If [forceTimer] is true, always returns a [CountdownTimerManager]
  /// regardless of platform. This is useful for:
  /// - Testing
  /// - When you want consistent behavior across platforms
  /// - When isolate overhead is not worth it for simple countdowns
  static CountdownManagerBase create({bool forceTimer = false}) {
    if (forceTimer) {
      return CountdownTimerManager();
    }
    return platform.createCountdownManager();
  }

  /// Returns true if the current platform supports Isolates.
  ///
  /// - Returns `true` on native platforms (iOS, Android, macOS, Windows, Linux)
  /// - Returns `false` on web platform
  static bool get isolatesSupported => platform.isolatesSupported;

  /// Returns a human-readable description of the current platform's
  /// countdown implementation.
  static String get platformDescription {
    if (platform.isolatesSupported) {
      return 'Native platform: Using Isolate-based countdown manager';
    } else {
      return 'Web platform: Using Timer-based countdown manager (Isolates not supported)';
    }
  }
}
