/// Modelo que representa el tiempo restante para la cuenta atrás.
class TimeRemaining {
  /// Días restantes
  final int days;

  /// Horas restantes (0-23)
  final int hours;

  /// Minutos restantes (0-59)
  final int minutes;

  /// Segundos restantes (0-59)
  final int seconds;

  /// Si la cuenta atrás ha finalizado
  final bool isCompleted;

  const TimeRemaining({
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
    this.isCompleted = false,
  });

  /// Crea una instancia de TimeRemaining que representa tiempo cero (cuenta atrás completada)
  const TimeRemaining.zero()
    : days = 0,
      hours = 0,
      minutes = 0,
      seconds = 0,
      isCompleted = true;

  /// Crea un TimeRemaining a partir de una Duration
  factory TimeRemaining.fromDuration(Duration duration) {
    if (duration.isNegative || duration == Duration.zero) {
      return const TimeRemaining.zero();
    }

    final totalSeconds = duration.inSeconds;
    final days = totalSeconds ~/ 86400;
    final hours = (totalSeconds % 86400) ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    return TimeRemaining(
      days: days,
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      isCompleted: false,
    );
  }

  /// Calcula TimeRemaining a partir de una fecha y hora objetivo
  factory TimeRemaining.fromTargetDate(DateTime targetDate) {
    final now = DateTime.now();
    final difference = targetDate.difference(now);
    return TimeRemaining.fromDuration(difference);
  }

  /// Convierte a un mapa para la comunicación con el isolate
  Map<String, dynamic> toMap() {
    return {
      'days': days,
      'hours': hours,
      'minutes': minutes,
      'seconds': seconds,
      'isCompleted': isCompleted,
    };
  }

  /// Crea desde un mapa (para la comunicación con el isolate)
  factory TimeRemaining.fromMap(Map<String, dynamic> map) {
    return TimeRemaining(
      days: map['days'] as int,
      hours: map['hours'] as int,
      minutes: map['minutes'] as int,
      seconds: map['seconds'] as int,
      isCompleted: map['isCompleted'] as bool,
    );
  }

  @override
  String toString() {
    return 'TimeRemaining(days: $days, hours: $hours, minutes: $minutes, seconds: $seconds, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimeRemaining &&
        other.days == days &&
        other.hours == hours &&
        other.minutes == minutes &&
        other.seconds == seconds &&
        other.isCompleted == isCompleted;
  }

  @override
  int get hashCode {
    return Object.hash(days, hours, minutes, seconds, isCompleted);
  }
}

/// Configuración para el widget del temporizador de cuenta atrás
class CountdownConfig {
  /// La fecha/hora objetivo para la cuenta atrás
  final DateTime targetDate;

  /// Si se debe usar un isolate para los cálculos de tiempo
  final bool useIsolate;

  /// Intervalo de actualización en milisegundos (por defecto: 1000ms = 1 segundo)
  final int updateIntervalMs;

  const CountdownConfig({
    required this.targetDate,
    this.useIsolate = true,
    this.updateIntervalMs = 1000,
  });

  /// Convierte a un mapa para la comunicación con el isolate
  Map<String, dynamic> toMap() {
    return {
      'targetDateMs': targetDate.millisecondsSinceEpoch,
      'updateIntervalMs': updateIntervalMs,
    };
  }

  /// Crea desde un mapa (para la comunicación con el isolate)
  factory CountdownConfig.fromMap(Map<String, dynamic> map) {
    return CountdownConfig(
      targetDate: DateTime.fromMillisecondsSinceEpoch(
        map['targetDateMs'] as int,
      ),
      updateIntervalMs: map['updateIntervalMs'] as int,
    );
  }
}

/// Configuración del tema para la visualización de la cuenta atrás
class CountdownTheme {
  /// Color de fondo de las cajas de tiempo
  final int boxColorValue;

  /// Color del texto de los números
  final int numberColorValue;

  /// Color del texto de las etiquetas (DÍAS, HORAS, etc.)
  final int labelColorValue;

  /// Color de fondo de la sección del carrusel
  final int carouselBackgroundColorValue;

  /// Radio del borde del contenedor principal
  final double borderRadius;

  /// Radio del borde de las cajas de tiempo individuales
  final double boxBorderRadius;

  /// Espaciado entre las cajas de tiempo
  final double boxSpacing;

  const CountdownTheme({
    this.boxColorValue = 0xFF1E3A5F,
    this.numberColorValue = 0xFFFFFFFF,
    this.labelColorValue = 0xFFFFFFFF,
    this.carouselBackgroundColorValue = 0xFFB3D4E8,
    this.borderRadius = 16.0,
    this.boxBorderRadius = 12.0,
    this.boxSpacing = 8.0,
  });

  /// Tema por defecto que coincide con el diseño
  static const CountdownTheme defaultTheme = CountdownTheme();
}
