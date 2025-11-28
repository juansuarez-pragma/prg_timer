import 'package:flutter/material.dart';

/// Una caja de unidad de tiempo individual que muestra un valor y una etiqueta (por ejemplo, "02" / "DÍAS")
class TimeBox extends StatelessWidget {
  /// El valor numérico a mostrar (se rellenará con ceros a la izquierda hasta 2 dígitos)
  final int value;

  /// El texto de la etiqueta (por ejemplo, "DÍAS", "HORAS", "MINS", "SECS")
  final String label;

  /// Color de fondo de la caja
  final Color boxColor;

  /// Color del texto del número
  final Color numberColor;

  /// Color del texto de la etiqueta
  final Color labelColor;

  /// Radio del borde de la caja
  final double borderRadius;

  /// Ancho de la caja (nulo para flexible)
  final double? width;

  /// Altura de la caja (nulo para flexible)
  final double? height;

  /// Tamaño de fuente para el número
  final double? numberFontSize;

  /// Tamaño de fuente para la etiqueta
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

/// Versión animada de TimeBox con animación de giro al cambiar el valor
class AnimatedTimeBox extends StatefulWidget {
  /// El valor numérico a mostrar
  final int value;

  /// El texto de la etiqueta
  final String label;

  /// Color de fondo de la caja
  final Color boxColor;

  /// Color del texto del número
  final Color numberColor;

  /// Color del texto de la etiqueta
  final Color labelColor;

  /// Radio del borde de la caja
  final double borderRadius;

  /// Ancho de la caja
  final double? width;

  /// Altura de la caja
  final double? height;

  /// Tamaño de fuente para el número
  final double? numberFontSize;

  /// Tamaño de fuente para la etiqueta
  final double? labelFontSize;

  /// Duración de la animación
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
        tween: Tween<double>(
          begin: 1.0,
          end: 1.1,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.1,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
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
