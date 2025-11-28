// Copyright 2024 Juan Suarez - Pragma. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/// Widget de controles globales para gestionar múltiples countdowns.
///
/// Este widget proporciona botones para pausar, reanudar y reiniciar
/// todos los countdowns registrados en un [GlobalCountdownManager].
library;

import 'package:flutter/material.dart';
import 'package:countdown_carousel_widget/countdown_carousel_widget.dart';

/// Sección de controles globales para operaciones por lotes en countdowns.
///
/// Utiliza el [GlobalCountdownManager] para controlar múltiples
/// countdowns simultáneamente con un solo toque.
///
/// ## Ejemplo de uso:
///
/// ```dart
/// GlobalControlsSection(
///   globalManager: _globalManager,
///   onPauseAll: () => _globalManager.pauseAll(),
///   onResumeAll: () => _globalManager.resumeAll(),
///   onResetAll: () => _resetAllCountdowns(),
/// )
/// ```
class GlobalControlsSection extends StatelessWidget {
  /// El manager global que controla todos los countdowns registrados.
  final GlobalCountdownManager globalManager;

  /// Callback ejecutado cuando se presiona el botón "Pausar Todo".
  final VoidCallback onPauseAll;

  /// Callback ejecutado cuando se presiona el botón "Reanudar Todo".
  final VoidCallback onResumeAll;

  /// Callback ejecutado cuando se presiona el botón "Reiniciar Todo".
  final VoidCallback onResetAll;

  const GlobalControlsSection({
    super.key,
    required this.globalManager,
    required this.onPauseAll,
    required this.onResumeAll,
    required this.onResetAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de la sección
          const Text(
            'Controles Globales',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Subtítulo con contador de countdowns
          Text(
            'Controla los ${globalManager.count} countdowns a la vez',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 12),

          // Botones de control
          // Usamos Wrap para mejor responsividad en pantallas pequeñas
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildControlButton(
                onPressed: onPauseAll,
                icon: Icons.pause,
                label: 'Pausar',
                color: Colors.orange,
              ),
              _buildControlButton(
                onPressed: onResumeAll,
                icon: Icons.play_arrow,
                label: 'Reanudar',
                color: Colors.green,
              ),
              _buildControlButton(
                onPressed: onResetAll,
                icon: Icons.refresh,
                label: 'Reiniciar',
                color: const Color(0xFF1E3A5F),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construye un botón de control individual con estilo consistente.
  Widget _buildControlButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return SizedBox(
      width: 110,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(
          label,
          style: const TextStyle(fontSize: 12),
          overflow: TextOverflow.ellipsis,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
      ),
    );
  }
}
