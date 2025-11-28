import 'package:flutter/material.dart';

import 'package:countdown_carousel_widget/src/models/countdown_config.dart';
import 'package:countdown_carousel_widget/src/widgets/time_box.dart';

/// Widget de visualización que muestra el temporizador de cuenta atrás con 4 cajas de tiempo
class CountdownDisplay extends StatelessWidget {
  /// El tiempo restante actual
  final TimeRemaining timeRemaining;

  /// Color de fondo de las cajas de tiempo
  final Color boxColor;

  /// Color del texto de los números
  final Color numberColor;

  /// Color del texto de las etiquetas
  final Color labelColor;

  /// Radio del borde de las cajas de tiempo
  final double boxBorderRadius;

  /// Espaciado entre las cajas de tiempo
  final double boxSpacing;

  /// Si se deben animar los cambios de valor
  final bool animate;

  /// Etiquetas personalizadas para las unidades de tiempo (por defecto DÍAS, HORAS, MINS, SECS)
  final List<String>? labels;

  /// Relleno dentro del contenedor de visualización
  final EdgeInsetsGeometry padding;

  const CountdownDisplay({
    super.key,
    required this.timeRemaining,
    this.boxColor = const Color(0xFF1E3A5F),
    this.numberColor = Colors.white,
    this.labelColor = Colors.white,
    this.boxBorderRadius = 12.0,
    this.boxSpacing = 8.0,
    this.animate = true,
    this.labels,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    final displayLabels = labels ?? ['DAYS', 'HOURS', 'MINS', 'SECS'];

    final timeValues = [
      timeRemaining.days,
      timeRemaining.hours,
      timeRemaining.minutes,
      timeRemaining.seconds,
    ];

    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(4, (index) {
          final timeBox = animate
              ? AnimatedTimeBox(
                  value: timeValues[index],
                  label: displayLabels[index],
                  boxColor: boxColor,
                  numberColor: numberColor,
                  labelColor: labelColor,
                  borderRadius: boxBorderRadius,
                )
              : TimeBox(
                  value: timeValues[index],
                  label: displayLabels[index],
                  boxColor: boxColor,
                  numberColor: numberColor,
                  labelColor: labelColor,
                  borderRadius: boxBorderRadius,
                );

          // All boxes have same spacing for consistency
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index < 3 ? boxSpacing : 0),
              child: timeBox,
            ),
          );
        }),
      ),
    );
  }
}

/// Una visualización de cuenta atrás responsiva que se adapta al espacio disponible
class ResponsiveCountdownDisplay extends StatelessWidget {
  /// El tiempo restante actual
  final TimeRemaining timeRemaining;

  /// Color de fondo de las cajas de tiempo
  final Color boxColor;

  /// Color del texto de los números
  final Color numberColor;

  /// Color del texto de las etiquetas
  final Color labelColor;

  /// Radio del borde de las cajas de tiempo
  final double boxBorderRadius;

  /// Si se deben animar los cambios de valor
  final bool animate;

  /// Etiquetas personalizadas para las unidades de tiempo
  final List<String>? labels;

  const ResponsiveCountdownDisplay({
    super.key,
    required this.timeRemaining,
    this.boxColor = const Color(0xFF1E3A5F),
    this.numberColor = Colors.white,
    this.labelColor = Colors.white,
    this.boxBorderRadius = 12.0,
    this.animate = true,
    this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive sizes based on available width
        final availableWidth = constraints.maxWidth;
        final boxWidth = (availableWidth - 48) / 4; // 48 = padding + spacing
        final fontSize = boxWidth * 0.45;
        final labelFontSize = boxWidth * 0.15;

        final displayLabels = labels ?? ['DAYS', 'HOURS', 'MINS', 'SECS'];

        final timeValues = [
          timeRemaining.days,
          timeRemaining.hours,
          timeRemaining.minutes,
          timeRemaining.seconds,
        ];

        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (index) {
              Widget timeBox;

              if (animate) {
                timeBox = AnimatedTimeBox(
                  value: timeValues[index],
                  label: displayLabels[index],
                  boxColor: boxColor,
                  numberColor: numberColor,
                  labelColor: labelColor,
                  borderRadius: boxBorderRadius,
                  numberFontSize: fontSize.clamp(20.0, 48.0),
                  labelFontSize: labelFontSize.clamp(8.0, 14.0),
                );
              } else {
                timeBox = TimeBox(
                  value: timeValues[index],
                  label: displayLabels[index],
                  boxColor: boxColor,
                  numberColor: numberColor,
                  labelColor: labelColor,
                  borderRadius: boxBorderRadius,
                  numberFontSize: fontSize.clamp(20.0, 48.0),
                  labelFontSize: labelFontSize.clamp(8.0, 14.0),
                );
              }

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: index < 3 ? 4.0 : 0,
                  ),
                  child: timeBox,
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
