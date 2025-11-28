import 'dart:async';

import 'package:flutter/material.dart';

import 'isolates/countdown_manager_factory.dart';
import 'isolates/countdown_manager_interface.dart';
import 'models/countdown_config.dart';
import 'widgets/countdown_display.dart';
import 'widgets/image_carousel.dart';

/// Un widget de temporizador de cuenta atrás con un carrusel de imágenes.
///
/// Este widget muestra un temporizador de cuenta atrás que muestra días, horas, minutos y segundos
/// hasta una fecha objetivo, junto con un carrusel de imágenes desplazable en la parte inferior.
///
/// ## Comportamiento Específico de la Plataforma
///
/// Los cálculos de la cuenta atrás se manejan de manera diferente según la plataforma:
///
/// - **Plataformas nativas** (iOS, Android, macOS, Windows, Linux):
///   Utiliza Dart Isolates para el procesamiento en segundo plano, manteniendo el hilo de la UI libre.
///
/// - **Plataforma web**:
///   Utiliza Timer.periodic ya que los Isolates NO son compatibles con la web.
///   La cuenta atrás se ejecuta en el hilo principal pero es lo suficientemente ligera
///   como para no afectar el rendimiento de la UI.
///
/// Puedes anular este comportamiento usando el parámetro [useIsolate]:
/// - `useIsolate: true` - Forzar el uso de isolate (fallará en la web)
/// - `useIsolate: false` - Forzar el uso de temporizador en todas las plataformas
/// - `useIsolate: null` (por defecto) - Detección automática según la plataforma
///
/// Example usage:
/// ```dart
/// CountdownCarouselWidget(
///   targetDate: DateTime.now().add(Duration(days: 2, hours: 14)),
///   images: [
///     CarouselImageItem.fromProvider(NetworkImage('https://example.com/image.jpg')),
///   ],
///   onAddImage: () => print('Add image tapped'),
///   onCountdownComplete: () => print('Countdown complete!'),
/// )
/// ```
class CountdownCarouselWidget extends StatefulWidget {
  /// La fecha/hora objetivo para la cuenta atrás
  final DateTime targetDate;

  /// Callback cuando la cuenta atrás llega a cero
  final VoidCallback? onCountdownComplete;

  /// Lista de imágenes para mostrar en el carrusel
  final List<CarouselImageItem> images;

  /// Callback cuando se toca el botón "Añadir imagen"
  final VoidCallback? onAddImage;

  /// Callback cuando se toca una imagen
  final void Function(int index)? onImageTap;

  /// Callback cuando una imagen debe ser eliminada
  final void Function(int index)? onImageRemove;

  /// Número máximo de imágenes permitidas en el carrusel
  final int maxImages;

  /// Si se debe usar un isolate para los cálculos de la cuenta atrás.
  ///
  /// - `true`: Forzar el uso de isolate (fallará silenciosamente en la web, recurriendo a un temporizador)
  /// - `false`: Forzar el uso de temporizador en todas las plataformas
  /// - `null` (por defecto): Detección automática según la plataforma
  ///   - Plataformas nativas: Utiliza Isolate
  ///   - Plataforma web: Utiliza Timer
  final bool? useIsolate;

  /// Color de fondo de la sección de cuenta atrás
  final Color countdownBackgroundColor;

  /// Color de fondo de las cajas de tiempo
  final Color boxColor;

  /// Color del texto de los números de la cuenta atrás
  final Color numberColor;

  /// Color del texto de las etiquetas de la cuenta atrás
  final Color labelColor;

  /// Color de fondo de la sección del carrusel
  final Color carouselBackgroundColor;

  /// Radio del borde del contenedor principal
  final double borderRadius;

  /// Radio del borde de las cajas de tiempo individuales
  final double boxBorderRadius;

  /// Etiquetas personalizadas para las unidades de tiempo (por defecto ['DÍAS', 'HORAS', 'MINS', 'SECS'])
  final List<String>? timeLabels;

  /// Si se deben animar los cambios de valor de la cuenta atrás
  final bool animateChanges;

  /// Altura de la sección del carrusel
  final double carouselHeight;

  /// Texto del botón "Añadir imagen"
  final String addImageText;

  /// Si se deben mostrar los botones de eliminar imagen
  final bool showImageRemoveButtons;

  const CountdownCarouselWidget({
    super.key,
    required this.targetDate,
    this.onCountdownComplete,
    this.images = const [],
    this.onAddImage,
    this.onImageTap,
    this.onImageRemove,
    this.maxImages = 10,
    this.useIsolate,
    this.countdownBackgroundColor = Colors.white,
    this.boxColor = const Color(0xFF1E3A5F),
    this.numberColor = Colors.white,
    this.labelColor = Colors.white,
    this.carouselBackgroundColor = const Color(0xFFB3D4E8),
    this.borderRadius = 16.0,
    this.boxBorderRadius = 12.0,
    this.timeLabels,
    this.animateChanges = true,
    this.carouselHeight = 120,
    this.addImageText = 'Add Image',
    this.showImageRemoveButtons = true,
  });

  @override
  State<CountdownCarouselWidget> createState() =>
      _CountdownCarouselWidgetState();
}

class _CountdownCarouselWidgetState extends State<CountdownCarouselWidget> {
  TimeRemaining _timeRemaining = const TimeRemaining(
    days: 0,
    hours: 0,
    minutes: 0,
    seconds: 0,
  );

  CountdownManagerBase? _manager;
  StreamSubscription<TimeRemaining>? _subscription;
  bool _countdownComplete = false;

  /// Determines whether to use isolate based on widget config and platform support
  bool get _shouldUseIsolate {
    // If explicitly set to false, never use isolate
    if (widget.useIsolate == false) return false;

    // If explicitly set to true, try to use isolate (may fail on web)
    if (widget.useIsolate == true)
      return CountdownManagerFactory.isolatesSupported;

    // Auto-detect: use isolate only if platform supports it
    return CountdownManagerFactory.isolatesSupported;
  }

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void didUpdateWidget(CountdownCarouselWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If target date changed, update the manager
    if (oldWidget.targetDate != widget.targetDate) {
      _manager?.updateTargetDate(widget.targetDate);
      _countdownComplete = false;
    }

    // If isolate preference changed, restart with new method
    if (oldWidget.useIsolate != widget.useIsolate) {
      _stopCountdown();
      _startCountdown();
    }
  }

  @override
  void dispose() {
    _stopCountdown();
    super.dispose();
  }

  Future<void> _startCountdown() async {
    _countdownComplete = false;

    // Create the appropriate manager based on platform/preference
    _manager = CountdownManagerFactory.create(forceTimer: !_shouldUseIsolate);

    try {
      final stream = await _manager!.start(widget.targetDate);
      _subscription = stream.listen(
        _onTimeUpdate,
        onError: (error) {
          debugPrint('Countdown error: $error');
        },
      );
    } catch (e) {
      debugPrint('Failed to start countdown: $e');
      // If isolate fails, fallback to timer
      if (_shouldUseIsolate) {
        _manager = CountdownManagerFactory.create(forceTimer: true);
        final stream = await _manager!.start(widget.targetDate);
        _subscription = stream.listen(_onTimeUpdate);
      }
    }
  }

  void _onTimeUpdate(TimeRemaining timeRemaining) {
    if (!mounted) return;

    setState(() {
      _timeRemaining = timeRemaining;
    });

    if (timeRemaining.isCompleted && !_countdownComplete) {
      _countdownComplete = true;
      widget.onCountdownComplete?.call();
    }
  }

  void _stopCountdown() {
    _subscription?.cancel();
    _subscription = null;
    _manager?.dispose();
    _manager = null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.countdownBackgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Countdown display
          ResponsiveCountdownDisplay(
            timeRemaining: _timeRemaining,
            boxColor: widget.boxColor,
            numberColor: widget.numberColor,
            labelColor: widget.labelColor,
            boxBorderRadius: widget.boxBorderRadius,
            animate: widget.animateChanges,
            labels: widget.timeLabels,
          ),
          // Image carousel
          ImageCarousel(
            images: widget.images,
            onAddImage: widget.onAddImage,
            onImageTap: widget.onImageTap,
            onImageRemove: widget.onImageRemove,
            backgroundColor: widget.carouselBackgroundColor,
            maxImages: widget.maxImages,
            height: widget.carouselHeight,
            addImageText: widget.addImageText,
            showRemoveButtons: widget.showImageRemoveButtons,
          ),
        ],
      ),
    );
  }
}

/// Un widget de cuenta atrás más simple sin el carrusel de imágenes.
///
/// Este widget muestra solo el temporizador de cuenta atrás (días, horas, minutos, segundos).
/// Úsalo cuando no necesites la funcionalidad del carrusel de imágenes.
///
/// Consulta [CountdownCarouselWidget] para obtener documentación sobre el comportamiento específico de la plataforma.
class CountdownOnlyWidget extends StatefulWidget {
  /// La fecha/hora objetivo para la cuenta atrás
  final DateTime targetDate;

  /// Callback cuando la cuenta atrás llega a cero
  final VoidCallback? onCountdownComplete;

  /// Si se debe usar un isolate para los cálculos de la cuenta atrás.
  /// Consulta [CountdownCarouselWidget.useIsolate] para más detalles.
  final bool? useIsolate;

  /// Color de fondo de la sección de cuenta atrás
  final Color backgroundColor;

  /// Color de fondo de las cajas de tiempo
  final Color boxColor;

  /// Color del texto de los números de la cuenta atrás
  final Color numberColor;

  /// Color del texto de las etiquetas de la cuenta atrás
  final Color labelColor;

  /// Radio del borde del contenedor principal
  final double borderRadius;

  /// Radio del borde de las cajas de tiempo individuales
  final double boxBorderRadius;

  /// Etiquetas personalizadas para las unidades de tiempo
  final List<String>? timeLabels;

  /// Si se deben animar los cambios de valor de la cuenta atrás
  final bool animateChanges;

  const CountdownOnlyWidget({
    super.key,
    required this.targetDate,
    this.onCountdownComplete,
    this.useIsolate,
    this.backgroundColor = Colors.white,
    this.boxColor = const Color(0xFF1E3A5F),
    this.numberColor = Colors.white,
    this.labelColor = Colors.white,
    this.borderRadius = 16.0,
    this.boxBorderRadius = 12.0,
    this.timeLabels,
    this.animateChanges = true,
  });

  @override
  State<CountdownOnlyWidget> createState() => _CountdownOnlyWidgetState();
}

class _CountdownOnlyWidgetState extends State<CountdownOnlyWidget> {
  TimeRemaining _timeRemaining = const TimeRemaining(
    days: 0,
    hours: 0,
    minutes: 0,
    seconds: 0,
  );

  CountdownManagerBase? _manager;
  StreamSubscription<TimeRemaining>? _subscription;
  bool _countdownComplete = false;

  bool get _shouldUseIsolate {
    if (widget.useIsolate == false) return false;
    if (widget.useIsolate == true)
      return CountdownManagerFactory.isolatesSupported;
    return CountdownManagerFactory.isolatesSupported;
  }

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void didUpdateWidget(CountdownOnlyWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.targetDate != widget.targetDate) {
      _manager?.updateTargetDate(widget.targetDate);
      _countdownComplete = false;
    }

    if (oldWidget.useIsolate != widget.useIsolate) {
      _stopCountdown();
      _startCountdown();
    }
  }

  @override
  void dispose() {
    _stopCountdown();
    super.dispose();
  }

  Future<void> _startCountdown() async {
    _countdownComplete = false;

    _manager = CountdownManagerFactory.create(forceTimer: !_shouldUseIsolate);

    try {
      final stream = await _manager!.start(widget.targetDate);
      _subscription = stream.listen(
        _onTimeUpdate,
        onError: (error) {
          debugPrint('Countdown error: $error');
        },
      );
    } catch (e) {
      debugPrint('Failed to start countdown: $e');
      if (_shouldUseIsolate) {
        _manager = CountdownManagerFactory.create(forceTimer: true);
        final stream = await _manager!.start(widget.targetDate);
        _subscription = stream.listen(_onTimeUpdate);
      }
    }
  }

  void _onTimeUpdate(TimeRemaining timeRemaining) {
    if (!mounted) return;

    setState(() {
      _timeRemaining = timeRemaining;
    });

    if (timeRemaining.isCompleted && !_countdownComplete) {
      _countdownComplete = true;
      widget.onCountdownComplete?.call();
    }
  }

  void _stopCountdown() {
    _subscription?.cancel();
    _subscription = null;
    _manager?.dispose();
    _manager = null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ResponsiveCountdownDisplay(
        timeRemaining: _timeRemaining,
        boxColor: widget.boxColor,
        numberColor: widget.numberColor,
        labelColor: widget.labelColor,
        boxBorderRadius: widget.boxBorderRadius,
        animate: widget.animateChanges,
        labels: widget.timeLabels,
      ),
    );
  }
}
