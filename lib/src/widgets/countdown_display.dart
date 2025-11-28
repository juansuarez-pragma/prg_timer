import 'package:flutter/material.dart';

import '../models/countdown_config.dart';
import 'time_box.dart';

/// Display widget showing the countdown timer with 4 time boxes
class CountdownDisplay extends StatelessWidget {
  /// The current time remaining
  final TimeRemaining timeRemaining;

  /// Background color of the time boxes
  final Color boxColor;

  /// Text color for the numbers
  final Color numberColor;

  /// Text color for the labels
  final Color labelColor;

  /// Border radius for the time boxes
  final double boxBorderRadius;

  /// Spacing between time boxes
  final double boxSpacing;

  /// Whether to animate value changes
  final bool animate;

  /// Custom labels for the time units (defaults to DAYS, HOURS, MINS, SECS)
  final List<String>? labels;

  /// Padding inside the display container
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

/// A responsive countdown display that adapts to available space
class ResponsiveCountdownDisplay extends StatelessWidget {
  /// The current time remaining
  final TimeRemaining timeRemaining;

  /// Background color of the time boxes
  final Color boxColor;

  /// Text color for the numbers
  final Color numberColor;

  /// Text color for the labels
  final Color labelColor;

  /// Border radius for the time boxes
  final double boxBorderRadius;

  /// Whether to animate value changes
  final bool animate;

  /// Custom labels for the time units
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
                  padding: EdgeInsets.symmetric(horizontal: index < 3 ? 4.0 : 0),
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
