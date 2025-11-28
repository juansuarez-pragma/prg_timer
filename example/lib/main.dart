// Copyright 2024 Juan Suarez - Pragma. Todos los derechos reservados.
// El uso de este código fuente se rige por una licencia MIT que se puede
// encontrar en el archivo LICENSE.

/// Aplicación de ejemplo para el paquete countdown_carousel_widget.
///
/// Esta aplicación demuestra las funcionalidades principales del paquete:
///
/// - **Demo Básico**: Uso de [CountdownCarouselWidget] y [CountdownOnlyWidget]
///   con carrusel de imágenes y estilos personalizados.
///
/// - **Demo Multi-Countdown**: Múltiples countdowns independientes ejecutándose
///   en sus propios Isolates con [ControllableCountdownController] y
///   [GlobalCountdownManager].
///
/// ## Ejecutar el ejemplo:
///
/// ```bash
/// cd example
/// flutter run -d chrome  # Web (Timer)
/// flutter run -d macos   # macOS (Isolate)
/// flutter run -d android # Android (Isolate)
/// ```
///
/// ## Estructura del proyecto:
///
/// ```
/// lib/
/// ├── main.dart                     # Este archivo
/// ├── demos/
/// │   ├── basic_demo.dart           # Demo básico
/// │   └── multi_countdown_demo.dart # Demo multi-countdown
/// └── widgets/
///     ├── global_controls.dart      # Controles globales
///     └── countdown_card.dart       # Tarjeta de countdown
/// ```
library;

import 'package:flutter/material.dart';

import 'package:countdown_example/demos/basic_demo.dart';
import 'package:countdown_example/demos/multi_countdown_demo.dart';

/// Punto de entrada de la aplicación de ejemplo.
void main() {
  runApp(const CountdownExampleApp());
}

/// Aplicación de ejemplo para countdown_carousel_widget.
///
/// Configura el tema y la estructura de navegación para los diferentes demos.
class CountdownExampleApp extends StatelessWidget {
  const CountdownExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Countdown Carousel Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Usar el color principal del paquete como semilla del tema
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A5F)),
        useMaterial3: true,
      ),
      home: const MainNavigationPage(),
    );
  }
}

/// Página principal de navegación con pestañas para los diferentes demos.
///
/// Utiliza [NavigationBar] de Material 3 para una navegación intuitiva
/// entre los demos disponibles:
///
/// - **Demo Básico**: Funcionalidades fundamentales del widget
/// - **Multi Countdown**: Múltiples countdowns con Isolates independientes
class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  /// Índice de la página actualmente seleccionada.
  int _currentIndex = 0;

  /// Lista de páginas disponibles en la navegación.
  ///
  /// Cada página es un demo independiente que muestra diferentes
  /// aspectos del paquete.
  final List<Widget> _pages = const [BasicDemoPage(), MultiCountdownDemoPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.timer), label: 'Demo Básico'),
          NavigationDestination(
            icon: Icon(Icons.grid_view),
            label: 'Multi Countdown',
          ),
        ],
      ),
    );
  }
}
