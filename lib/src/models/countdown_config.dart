/// Model representing the remaining time for the countdown.
class TimeRemaining {
  /// Days remaining
  final int days;

  /// Hours remaining (0-23)
  final int hours;

  /// Minutes remaining (0-59)
  final int minutes;

  /// Seconds remaining (0-59)
  final int seconds;

  /// Whether the countdown has completed
  final bool isCompleted;

  const TimeRemaining({
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
    this.isCompleted = false,
  });

  /// Creates a TimeRemaining instance representing zero time (countdown complete)
  const TimeRemaining.zero()
      : days = 0,
        hours = 0,
        minutes = 0,
        seconds = 0,
        isCompleted = true;

  /// Creates a TimeRemaining from a Duration
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

  /// Calculates TimeRemaining from a target DateTime
  factory TimeRemaining.fromTargetDate(DateTime targetDate) {
    final now = DateTime.now();
    final difference = targetDate.difference(now);
    return TimeRemaining.fromDuration(difference);
  }

  /// Converts to a Map for isolate communication
  Map<String, dynamic> toMap() {
    return {
      'days': days,
      'hours': hours,
      'minutes': minutes,
      'seconds': seconds,
      'isCompleted': isCompleted,
    };
  }

  /// Creates from a Map (for isolate communication)
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

/// Configuration for the countdown timer widget
class CountdownConfig {
  /// The target date/time for the countdown
  final DateTime targetDate;

  /// Whether to use an isolate for time calculations
  final bool useIsolate;

  /// Update interval in milliseconds (default: 1000ms = 1 second)
  final int updateIntervalMs;

  const CountdownConfig({
    required this.targetDate,
    this.useIsolate = true,
    this.updateIntervalMs = 1000,
  });

  /// Converts to a Map for isolate communication
  Map<String, dynamic> toMap() {
    return {
      'targetDateMs': targetDate.millisecondsSinceEpoch,
      'updateIntervalMs': updateIntervalMs,
    };
  }

  /// Creates from a Map (for isolate communication)
  factory CountdownConfig.fromMap(Map<String, dynamic> map) {
    return CountdownConfig(
      targetDate: DateTime.fromMillisecondsSinceEpoch(map['targetDateMs'] as int),
      updateIntervalMs: map['updateIntervalMs'] as int,
    );
  }
}

/// Theme configuration for the countdown display
class CountdownTheme {
  /// Background color of the time boxes
  final int boxColorValue;

  /// Text color for the numbers
  final int numberColorValue;

  /// Text color for the labels (DAYS, HOURS, etc.)
  final int labelColorValue;

  /// Background color of the carousel section
  final int carouselBackgroundColorValue;

  /// Border radius for the main container
  final double borderRadius;

  /// Border radius for individual time boxes
  final double boxBorderRadius;

  /// Spacing between time boxes
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

  /// Default theme matching the design
  static const CountdownTheme defaultTheme = CountdownTheme();
}
