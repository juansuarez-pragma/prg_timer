// Copyright 2024 Juan Suarez - Pragma. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/// Demo de múltiples countdowns independientes.
///
/// Este demo muestra cómo ejecutar varios countdowns simultáneamente,
/// cada uno en su propio Isolate, con controles individuales y globales.
library;

import 'package:flutter/material.dart';
import 'package:countdown_carousel_widget/countdown_carousel_widget.dart';

import '../widgets/global_controls.dart';
import '../widgets/countdown_card.dart';

/// Página de demostración de múltiples countdowns independientes.
///
/// Características demostradas:
/// - **Isolates independientes**: Cada countdown se ejecuta en su propio Isolate
/// - **Controles individuales**: Pausar, reanudar, reiniciar cada countdown
/// - **Controles globales**: Operar todos los countdowns simultáneamente
/// - **[GlobalCountdownManager]**: Gestión centralizada de countdowns
/// - **Estados reactivos**: UI actualizada mediante streams
///
/// ## Arquitectura:
///
/// ```
/// ┌─────────────────────────────────────────────┐
/// │              GlobalCountdownManager          │
/// │                                              │
/// │  ┌────────────┐ ┌────────────┐ ┌──────────┐ │
/// │  │Controller 1│ │Controller 2│ │Controller│ │
/// │  └─────┬──────┘ └─────┬──────┘ └────┬─────┘ │
/// └────────┼──────────────┼─────────────┼───────┘
///          │              │             │
///          v              v             v
///    ┌──────────┐  ┌──────────┐  ┌──────────┐
///    │ Isolate 1│  │ Isolate 2│  │ Isolate N│
///    │ (Timer)  │  │ (Timer)  │  │ (Timer)  │
///    └──────────┘  └──────────┘  └──────────┘
/// ```
class MultiCountdownDemoPage extends StatefulWidget {
  const MultiCountdownDemoPage({super.key});

  @override
  State<MultiCountdownDemoPage> createState() => _MultiCountdownDemoPageState();
}

class _MultiCountdownDemoPageState extends State<MultiCountdownDemoPage> {
  /// Manager global para controlar todos los countdowns a la vez.
  ///
  /// Permite operaciones por lotes como:
  /// - `pauseAll()`: Pausa todos los countdowns
  /// - `resumeAll()`: Reanuda todos los countdowns
  /// - `resetAll()`: Reinicia todos los countdowns
  final GlobalCountdownManager _globalManager = GlobalCountdownManager();

  /// Controladores individuales de countdown.
  /// Cada uno puede ejecutarse en su propio Isolate.
  late List<ControllableCountdownController> _controllers;

  /// Configuración de cada countdown.
  /// Define id, título, duración y color para cada uno.
  final List<DemoCountdownConfig> _countdownConfigs = const [
    DemoCountdownConfig(
      id: 'evento_1',
      title: 'Lanzamiento de Evento',
      duration: Duration(hours: 2, minutes: 30),
      color: Color(0xFF1E3A5F),
    ),
    DemoCountdownConfig(
      id: 'evento_2',
      title: 'Venta Flash',
      duration: Duration(minutes: 45, seconds: 30),
      color: Color(0xFF4A148C),
    ),
    DemoCountdownConfig(
      id: 'evento_3',
      title: 'Inicio de Reunión',
      duration: Duration(minutes: 15),
      color: Color(0xFF006064),
    ),
    DemoCountdownConfig(
      id: 'evento_4',
      title: 'Timer Rápido',
      duration: Duration(seconds: 30),
      color: Color(0xFFBF360C),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  /// Inicializa todos los controladores de countdown.
  ///
  /// Cada controlador se configura con:
  /// - ID único para identificación
  /// - Fecha objetivo calculada desde la duración
  /// - useIsolate: true para ejecutar en Isolate separado
  ///
  /// Todos los controladores se registran en el [GlobalCountdownManager]
  /// para permitir operaciones por lotes.
  void _initializeControllers() {
    _controllers =
        _countdownConfigs.map((config) {
          final controller = ControllableCountdownController(
            id: config.id,
            targetDate: DateTime.now().add(config.duration),
            useIsolate: true, // ¡Cada countdown en su propio Isolate!
          );

          // Registrar en el manager global
          _globalManager.register(controller);

          return controller;
        }).toList();
  }

  @override
  void dispose() {
    // Liberar todos los recursos a través del manager global.
    // Esto limpia todos los Isolates y cancela las suscripciones.
    _globalManager.disposeAll();
    super.dispose();
  }

  /// Muestra un mensaje temporal al usuario.
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EEF2),
      appBar: AppBar(
        title: const Text('Demo Multi-Countdown'),
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Sección de controles globales
          GlobalControlsSection(
            globalManager: _globalManager,
            onPauseAll: () {
              _globalManager.pauseAll();
              _showMessage('Todos los countdowns pausados');
            },
            onResumeAll: () {
              _globalManager.resumeAll();
              _showMessage('Todos los countdowns reanudados');
            },
            onResetAll: () {
              // Reiniciar cada uno a su duración original
              for (int i = 0; i < _controllers.length; i++) {
                _controllers[i].resetTo(
                  DateTime.now().add(_countdownConfigs[i].duration),
                );
              }
              _showMessage('Todos los countdowns reiniciados');
            },
          ),

          // Banner informativo
          _buildInfoBanner(),

          const SizedBox(height: 16),

          // Lista de tarjetas de countdown
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _controllers.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: IndividualCountdownCard(
                    controller: _controllers[index],
                    config: _countdownConfigs[index],
                    onComplete: () {
                      _showMessage(
                        '¡${_countdownConfigs[index].title} completado!',
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Construye un banner informativo explicando la funcionalidad.
  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '¡Cada countdown se ejecuta en su propio Isolate! '
              'Contrólalos independientemente o todos a la vez.',
              style: TextStyle(color: Colors.blue.shade900, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
