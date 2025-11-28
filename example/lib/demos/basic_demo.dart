// Copyright 2024 Juan Suarez - Pragma. Todos los derechos reservados.
// El uso de este código fuente se rige por una licencia MIT que se puede
// encontrar en el archivo LICENSE.

/// Demo básico que muestra las funcionalidades principales del widget.
///
/// Este demo incluye:
/// - CountdownCarouselWidget con carrusel de imágenes
/// - CountdownOnlyWidget (solo countdown)
/// - Estilos personalizados
library;

import 'package:flutter/material.dart';
import 'package:countdown_carousel_widget/countdown_carousel_widget.dart';

/// Página de demostración básica que muestra el uso fundamental del widget.
///
/// Características demostradas:
/// - Uso del [CountdownCarouselWidget] completo con carrusel de imágenes
/// - Uso del [CountdownOnlyWidget] para mostrar solo el countdown
/// - Personalización de colores y etiquetas
/// - Manejo de callbacks (onAddImage, onImageTap, onImageRemove, onCountdownComplete)
class BasicDemoPage extends StatefulWidget {
  const BasicDemoPage({super.key});

  @override
  State<BasicDemoPage> createState() => _BasicDemoPageState();
}

class _BasicDemoPageState extends State<BasicDemoPage> {
  /// Fecha objetivo para el countdown.
  /// Se inicializa a 2 días, 14 horas, 35 minutos y 20 segundos desde ahora.
  late DateTime _targetDate;

  /// Lista de imágenes para el carrusel.
  /// Las imágenes se agregan dinámicamente mediante el botón "Agregar Imagen".
  final List<CarouselImageItem> _images = [];

  @override
  void initState() {
    super.initState();
    _targetDate = DateTime.now().add(
      const Duration(days: 2, hours: 14, minutes: 35, seconds: 20),
    );
  }

  /// Callback ejecutado cuando el usuario presiona "Agregar Imagen".
  ///
  /// En una aplicación real, aquí se abriría un selector de imágenes.
  /// Para este demo, agregamos una imagen placeholder de picsum.photos.
  void _onAddImage() {
    setState(() {
      _images.add(
        CarouselImageItem.fromProvider(
          NetworkImage(
            'https://picsum.photos/200/200?random=${_images.length + 1}',
          ),
          id: 'image_${_images.length}',
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Imagen agregada! (Demo: usando imagen placeholder)'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Callback ejecutado cuando el usuario toca una imagen del carrusel.
  void _onImageTap(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tocaste la imagen en índice $index'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// Callback ejecutado cuando el usuario elimina una imagen del carrusel.
  void _onImageRemove(int index) {
    setState(() {
      _images.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Imagen eliminada en índice $index'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// Callback ejecutado cuando el countdown llega a cero.
  ///
  /// Muestra un diálogo de alerta y ofrece la opción de reiniciar.
  void _onCountdownComplete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¡Cuenta Regresiva Completada!'),
        content: const Text('El countdown ha llegado a cero.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetCountdown();
            },
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );
  }

  /// Reinicia el countdown a su duración original.
  void _resetCountdown() {
    setState(() {
      _targetDate = DateTime.now().add(
        const Duration(days: 2, hours: 14, minutes: 35, seconds: 20),
      );
    });
  }

  /// Establece un countdown corto de 10 segundos para pruebas rápidas.
  void _setShortCountdown() {
    setState(() {
      _targetDate = DateTime.now().add(const Duration(seconds: 10));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EEF2),
      appBar: AppBar(
        title: const Text('Demo Básico'),
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // =========================================================
            // EJEMPLO 1: Widget completo con Isolate
            // =========================================================
            _buildSectionTitle('Widget Completo (con Isolate)'),
            const SizedBox(height: 8),

            // El CountdownCarouselWidget es el widget principal del paquete.
            // Incluye countdown y carrusel de imágenes.
            // useIsolate: true - ejecuta el timer en un Isolate separado
            // para mejor rendimiento en plataformas nativas.
            CountdownCarouselWidget(
              targetDate: _targetDate,
              images: _images,
              onAddImage: _onAddImage,
              onImageTap: _onImageTap,
              onImageRemove: _onImageRemove,
              onCountdownComplete: _onCountdownComplete,
              maxImages: 9,
              useIsolate: true, // Usa Isolate en plataformas nativas
            ),

            const SizedBox(height: 24),

            // Botones de control para el demo
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _resetCountdown,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reiniciar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A5F),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _setShortCountdown,
                    icon: const Icon(Icons.timer),
                    label: const Text('10 seg'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // =========================================================
            // EJEMPLO 2: Solo countdown (sin carrusel)
            // =========================================================
            _buildSectionTitle('Solo Countdown (sin carrusel)'),
            const SizedBox(height: 8),

            // CountdownOnlyWidget muestra solo el countdown sin el carrusel.
            // Útil cuando no necesitas la funcionalidad de imágenes.
            CountdownOnlyWidget(
              targetDate: _targetDate,
              onCountdownComplete: () {},
              useIsolate: true,
            ),

            const SizedBox(height: 32),

            // =========================================================
            // EJEMPLO 3: Estilos personalizados
            // =========================================================
            _buildSectionTitle('Estilos Personalizados'),
            const SizedBox(height: 8),

            // Ejemplo de personalización completa de colores y etiquetas.
            // Demuestra la flexibilidad del widget para adaptarse a
            // diferentes diseños y temas.
            CountdownCarouselWidget(
              targetDate: _targetDate,
              images: const [],
              onAddImage: _onAddImage,
              // Personalización de colores
              boxColor: const Color(0xFF4A148C), // Púrpura oscuro
              carouselBackgroundColor: const Color(0xFFCE93D8), // Púrpura claro
              // Etiquetas en español
              timeLabels: const ['DIAS', 'HORAS', 'MINS', 'SEGS'],
              // useIsolate: false - fuerza el uso de Timer incluso en nativas
              // Útil para debugging o cuando se prefiere evitar Isolates.
              useIsolate: false,
            ),
          ],
        ),
      ),
    );
  }

  /// Construye un título de sección con estilo consistente.
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}
