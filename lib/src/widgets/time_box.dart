import 'package:flutter/material.dart';

/// A single time unit box displaying a value and label (e.g., "02" / "DAYS")
class TimeBox extends StatelessWidget {
  /// The numeric value to display (will be zero-padded to 2 digits)
  final int value;

  /// The label text (e.g., "DAYS", "HOURS", "MINS", "SECS")
  final String label;

  /// Background color of the box
  final Color boxColor;

  /// Text color for the number
  final Color numberColor;

  /// Text color for the label
  final Color labelColor;

  /// Border radius of the box
  final double borderRadius;

  /// Width of the box (null for flexible)
  final double? width;

  /// Height of the box (null for flexible)
  final double? height;

  /// Font size for the number
  final double? numberFontSize;

  /// Font size for the label
  final double? labelFontSize;

  const TimeBox({
    super.key,
    required this.value,
    required this.label,
    this.boxColor = const Color(0xFF1E3A5F),
    this.numberColor = Colors.white,
    this.labelColor = Colors.white,
    this.borderRadius = 12.0,
    this.width,
    this.height,
    this.numberFontSize,
    this.labelFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Number display with zero-padding
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value.toString().padLeft(2, '0'),
              maxLines: 1,
              style: TextStyle(
                color: numberColor,
                fontSize: numberFontSize ?? 36,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Label
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: labelColor,
                fontSize: labelFontSize ?? 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated version of TimeBox with flip animation on value change
class AnimatedTimeBox extends StatefulWidget {
  /// The numeric value to display
  final int value;

  /// The label text
  final String label;

  /// Background color of the box
  final Color boxColor;

  /// Text color for the number
  final Color numberColor;

  /// Text color for the label
  final Color labelColor;

  /// Border radius of the box
  final double borderRadius;

  /// Width of the box
  final double? width;

  /// Height of the box
  final double? height;

  /// Font size for the number
  final double? numberFontSize;

  /// Font size for the label
  final double? labelFontSize;

  /// Animation duration
  final Duration animationDuration;

  const AnimatedTimeBox({
    super.key,
    required this.value,
    required this.label,
    this.boxColor = const Color(0xFF1E3A5F),
    this.numberColor = Colors.white,
    this.labelColor = Colors.white,
    this.borderRadius = 12.0,
    this.width,
    this.height,
    this.numberFontSize,
    this.labelFontSize,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<AnimatedTimeBox> createState() => _AnimatedTimeBoxState();
}

class _AnimatedTimeBoxState extends State<AnimatedTimeBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.1)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(AnimatedTimeBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: TimeBox(
            value: widget.value,
            label: widget.label,
            boxColor: widget.boxColor,
            numberColor: widget.numberColor,
            labelColor: widget.labelColor,
            borderRadius: widget.borderRadius,
            width: widget.width,
            height: widget.height,
            numberFontSize: widget.numberFontSize,
            labelFontSize: widget.labelFontSize,
          ),
        );
      },
    );
  }
}
