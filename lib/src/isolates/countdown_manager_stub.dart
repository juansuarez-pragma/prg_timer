import 'countdown_manager_interface.dart';

/// Stub implementation - this file should never be imported directly.
/// Use conditional imports in countdown_manager_factory.dart instead.
CountdownManagerBase createCountdownManager() {
  throw UnsupportedError(
    'Cannot create CountdownManager without dart:isolate or dart:html',
  );
}

/// Stub for checking if isolates are supported
bool get isolatesSupported => false;
