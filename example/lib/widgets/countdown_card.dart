// Copyright 2024 Juan Suarez - Pragma. Todos los derechos reservados.
// El uso de este código fuente se rige por una licencia MIT que se puede
// encontrar en el archivo LICENSE.

/// Widget de tarjeta de countdown individual con controles.
///
/// Muestra un countdown con su propio estado y botones de control
/// para pausar, reanudar, reiniciar y agregar tiempo.
library;

import 'package:flutter/material.dart';
import 'package:countdown_carousel_widget/countdown_carousel_widget.dart';

/// Configuración inmutable para un countdown individual del demo.
///
/// Esta clase define los parámetros que identifican y estilizan
/// cada countdown de manera única en el ejemplo.
///
/// Nota: Se usa el nombre `DemoCountdownConfig` para evitar conflicto
/// con el `CountdownConfig` del paquete principal.
class DemoCountdownConfig {
  /// Identificador único del countdown.
  final String id;

  /// Título mostrado en el encabezado de la tarjeta.
  final String title;

  /// Duración inicial del countdown.
  final Duration duration;

  /// Color del tema para la tarjeta y las cajas de tiempo.
  final Color color;

  const DemoCountdownConfig({
    required this.id,
    required this.title,
    required this.duration,
    required this.color,
  });
}

/// Tarjeta de countdown individual con controles integrados.
///
/// Esta tarjeta muestra:
/// - Encabezado con título, ID y estado actual
/// - Countdown visual con [ControllableCountdownWidget]
/// - Botones de control (pausar/reanudar, reiniciar, +30 seg)
///
/// ## Ejemplo de uso:
///
/// ```dart
/// IndividualCountdownCard(
///   controller: myController,
///   config: DemoCountdownConfig(
///     id: 'event_1',
///     title: 'Lanzamiento',
///     duration: Duration(hours: 2),
///     color: Colors.blue,
///   ),
///   onComplete: () => print('¡Completado!'),
/// )
/// ```
class IndividualCountdownCard extends StatefulWidget {
  /// Controlador del countdown.
  /// Cada controlador puede ejecutarse en su propio Isolate.
  final ControllableCountdownController controller;

  /// Configuración del countdown (id, título, duración, color).
  final DemoCountdownConfig config;

  /// Callback ejecutado cuando el countdown llega a cero.
  final VoidCallback? onComplete;

  const IndividualCountdownCard({
    super.key,
    required this.controller,
    required this.config,
    this.onComplete,
  });

  @override
  State<IndividualCountdownCard> createState() =>
      _IndividualCountdownCardState();
}

class _IndividualCountdownCardState extends State<IndividualCountdownCard> {
  /// Estado actual del countdown.
  /// Se actualiza reactivamente mediante el stream del controlador.
  CountdownState _state = CountdownState.idle;

  @override
  void initState() {
    super.initState();
    _setupStateListener();
    _startCountdown();
  }

  /// Configura el listener para cambios de estado del countdown.
  ///
  /// Escucha el [stateStream] del controlador y actualiza la UI
  /// cada vez que el estado cambia.
  void _setupStateListener() {
    widget.controller.stateStream.listen((state) {
      if (mounted) {
        setState(() {
          _state = state;
        });
      }
    });
  }

  /// Inicia el countdown automáticamente al crear la tarjeta.
  Future<void> _startCountdown() async {
    await widget.controller.start();
    if (mounted) {
      setState(() {
        _state = widget.controller.state;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRunning = _state == CountdownState.running;
    final isPaused = _state == CountdownState.paused;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Encabezado con título y estado
          _buildHeader(),

          // Countdown visual
          Padding(
            padding: const EdgeInsets.all(16),
            child: ControllableCountdownWidget(
              controller: widget.controller,
              boxColor: widget.config.color,
              showStateIndicator: false, // Mostramos nuestro propio indicador
              onCountdownComplete: widget.onComplete,
            ),
          ),

          // Controles individuales
          _buildControls(isRunning: isRunning, isPaused: isPaused),
        ],
      ),
    );
  }

  /// Construye el encabezado de la tarjeta con título, ID y estado.
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: widget.config.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.config.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'ID: ${widget.config.id}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          _buildStateChip(),
        ],
      ),
    );
  }

  /// Construye los botones de control para este countdown específico.
  Widget _buildControls({required bool isRunning, required bool isPaused}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          // Botón Pausar/Reanudar
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                if (isRunning) {
                  widget.controller.pause();
                } else if (isPaused) {
                  widget.controller.resume();
                }
              },
              icon: Icon(isRunning ? Icons.pause : Icons.play_arrow, size: 18),
              label: Text(isRunning ? 'Pausar' : 'Reanudar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: isRunning ? Colors.orange : Colors.green,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Botón Reiniciar
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                widget.controller.resetTo(
                  DateTime.now().add(widget.config.duration),
                );
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reiniciar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: widget.config.color,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Botón +30 segundos
          IconButton(
            onPressed: () {
              // Agrega 30 segundos al objetivo actual
              final newTarget = widget.controller.currentTargetDate.add(
                const Duration(seconds: 30),
              );
              widget.controller.updateTargetDate(newTarget);
            },
            icon: const Icon(Icons.add),
            tooltip: '+30 seg',
            style: IconButton.styleFrom(backgroundColor: Colors.grey.shade200),
          ),
        ],
      ),
    );
  }

  /// Construye el chip indicador de estado.
  ///
  /// El color y el texto del chip varían según el [CountdownState]:
  /// - running: Verde
  /// - paused: Naranja
  /// - completed: Azul
  /// - stopped: Rojo
  /// - idle: Gris
  Widget _buildStateChip() {
    Color chipColor;
    String label;
    IconData icon;

    switch (_state) {
      case CountdownState.running:
        chipColor = Colors.green;
        label = 'ACTIVO';
        icon = Icons.play_arrow;
        break;
      case CountdownState.paused:
        chipColor = Colors.orange;
        label = 'PAUSADO';
        icon = Icons.pause;
        break;
      case CountdownState.completed:
        chipColor = Colors.blue;
        label = 'LISTO';
        icon = Icons.check;
        break;
      case CountdownState.stopped:
        chipColor = Colors.red;
        label = 'DETENIDO';
        icon = Icons.stop;
        break;
      case CountdownState.idle:
        chipColor = Colors.grey;
        label = 'INACTIVO';
        icon = Icons.hourglass_empty;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
