/// Un widget de temporizador de cuenta atrás personalizable con carrusel de imágenes,
/// impulsado por Dart Isolates para un rendimiento óptimo en plataformas nativas.
///
/// ## Soporte de Plataforma
///
/// Este paquete detecta automáticamente la plataforma y utiliza la implementación
/// apropiada:
///
/// - **Plataformas nativas** (iOS, Android, macOS, Windows, Linux):
///   Utiliza Dart Isolates para cálculos de cuenta atrás en segundo plano.
///
/// - **Plataforma web**:
///   Utiliza Timer.periodic ya que los Isolates NO son compatibles con la web.
///
/// ## Componentes Principales
///
/// - [CountdownCarouselWidget]: Widget principal con temporizador de cuenta atrás y carrusel de imágenes
/// - [CountdownOnlyWidget]: Widget más simple solo con el temporizador de cuenta atrás
/// - [TimeRemaining]: Modelo para los valores de tiempo de cuenta atrás
/// - [CarouselImageItem]: Modelo para las imágenes del carrusel
/// - [CountdownManagerFactory]: Fábrica para crear gestores apropiados para la plataforma
///
/// ## Ejemplo de Uso
///
/// ```dart
/// import 'package:countdown_carousel_widget/countdown_carousel_widget.dart';
///
/// CountdownCarouselWidget(
///   targetDate: DateTime.now().add(Duration(days: 2, hours: 14)),
///   images: [
///     CarouselImageItem.fromProvider(NetworkImage('https://example.com/image.jpg')),
///   ],
///   onAddImage: () => print('Añadir imagen tocada'),
///   onCountdownComplete: () => print('¡Cuenta atrás completada!'),
/// )
/// ```
///
/// ## Comprobación del Soporte de Plataforma
///
/// ```dart
/// // Comprobar si los isolates son compatibles con la plataforma actual
/// if (CountdownManagerFactory.isolatesSupported) {
///   print('Ejecutando en plataforma nativa con soporte de Isolate');
/// } else {
///   print('Ejecutando en plataforma web con fallback de Timer');
/// }
/// ```
library;

// Models
export 'src/models/countdown_config.dart'
    show TimeRemaining, CountdownConfig, CountdownTheme;

// Countdown managers (for advanced usage)
export 'src/isolates/countdown_manager_interface.dart'
    show CountdownManagerBase, CountdownState;
export 'src/isolates/countdown_manager_factory.dart'
    show CountdownManagerFactory;
export 'src/isolates/countdown_timer_manager.dart' show CountdownTimerManager;

// Controllers
export 'src/controllers/controllable_countdown_controller.dart'
    show ControllableCountdownController, GlobalCountdownManager;

// Widgets
export 'src/widgets/time_box.dart' show TimeBox, AnimatedTimeBox;
export 'src/widgets/countdown_display.dart'
    show CountdownDisplay, ResponsiveCountdownDisplay;
export 'src/widgets/image_carousel.dart' show ImageCarousel, CarouselImageItem;
export 'src/widgets/controllable_countdown_widget.dart'
    show ControllableCountdownWidget, ControllableCountdownCard;

// Main widgets
export 'src/countdown_carousel_widget.dart'
    show CountdownCarouselWidget, CountdownOnlyWidget;
