# Countdown Carousel Widget

[![pub package](https://img.shields.io/pub/v/countdown_carousel_widget.svg)](https://pub.dev/packages/countdown_carousel_widget)
[![Licencia: MIT](https://img.shields.io/badge/Licencia-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev)

Un widget de temporizador de cuenta regresiva altamente personalizable con carrusel de imágenes, potenciado por Dart Isolates para un rendimiento óptimo en plataformas nativas.

## Características

- **Temporizador de Cuenta Regresiva**: Muestra días, horas, minutos y segundos hasta una fecha objetivo
- **Carrusel de Imágenes**: Carrusel de imágenes desplazable horizontalmente con indicadores de paginación
- **Multiplataforma**: Detección automática de plataforma con implementación apropiada
- **Soporte de Isolates**: Procesamiento en segundo plano en plataformas nativas (iOS, Android, macOS, Windows, Linux)
- **Soporte Web**: Fallback basado en Timer para plataforma web (Isolates no soportados)
- **Múltiples Countdowns Independientes**: Ejecuta múltiples cuenta regresivas simultáneamente, cada una con su propio Isolate
- **Pausar/Reanudar/Reiniciar**: Control total sobre el ciclo de vida del countdown
- **Controles Globales**: Administra todos los countdowns a la vez
- **Totalmente Personalizable**: Colores, etiquetas y estilos configurables
- **Animado**: Animaciones suaves de escala en cambios de valor
- **Responsivo**: Se adapta al ancho de pantalla disponible

## Soporte de Plataformas

| Plataforma | Implementación | Notas |
|------------|----------------|-------|
| iOS | Isolate | Procesamiento en hilo de fondo |
| Android | Isolate | Procesamiento en hilo de fondo |
| macOS | Isolate | Procesamiento en hilo de fondo |
| Windows | Isolate | Procesamiento en hilo de fondo |
| Linux | Isolate | Procesamiento en hilo de fondo |
| **Web** | **Timer** | Isolates NO soportados en web |

El widget detecta automáticamente la plataforma y usa la implementación apropiada.

## Instalación

Agrega esto al archivo `pubspec.yaml` de tu paquete:

```yaml
dependencies:
  countdown_carousel_widget: ^1.0.0
```

Luego ejecuta:

```bash
flutter pub get
```

## Uso

### Uso Básico

```dart
import 'package:countdown_carousel_widget/countdown_carousel_widget.dart';

CountdownCarouselWidget(
  targetDate: DateTime.now().add(Duration(days: 2, hours: 14)),
  images: [
    CarouselImageItem.fromProvider(NetworkImage('https://ejemplo.com/imagen.jpg')),
  ],
  onAddImage: () => print('Agregar imagen presionado'),
  onCountdownComplete: () => print('¡Cuenta regresiva completada!'),
)
```

### Solo Countdown (sin carrusel)

```dart
CountdownOnlyWidget(
  targetDate: DateTime.now().add(Duration(hours: 5)),
  onCountdownComplete: () => print('¡Listo!'),
)
```

### Estilos Personalizados

```dart
CountdownCarouselWidget(
  targetDate: DateTime.now().add(Duration(days: 1)),
  boxColor: Color(0xFF4A148C),
  carouselBackgroundColor: Color(0xFFCE93D8),
  timeLabels: ['DIAS', 'HORAS', 'MINS', 'SEGS'],
)
```

### Múltiples Countdowns Independientes

Cada countdown se ejecuta en su propio Isolate y puede ser controlado independientemente:

```dart
// Crear controladores individuales
final controller1 = ControllableCountdownController(
  id: 'evento_1',
  targetDate: DateTime.now().add(Duration(hours: 2)),
  useIsolate: true,
);

final controller2 = ControllableCountdownController(
  id: 'evento_2',
  targetDate: DateTime.now().add(Duration(hours: 5)),
  useIsolate: true,
);

// Usar en widgets
ControllableCountdownWidget(
  controller: controller1,
  onCountdownComplete: () => print('¡Evento 1 completado!'),
)

// Controlar individualmente
controller1.pause();    // Solo pausa controller1
controller2.resume();   // Solo afecta a controller2
controller1.reset();    // Reinicia al objetivo original
```

### Control Global para Múltiples Countdowns

```dart
final globalManager = GlobalCountdownManager();

// Registrar controladores
globalManager.register(controller1);
globalManager.register(controller2);

// Controlar todos a la vez
globalManager.pauseAll();
globalManager.resumeAll();
globalManager.resetAll();

// Limpiar recursos
await globalManager.disposeAll();
```

### Countdown Card Controlable (con controles integrados)

```dart
ControllableCountdownCard(
  controller: controller,
  title: 'Cuenta Regresiva del Evento',
  showControls: true,
  onCountdownComplete: () => print('¡Listo!'),
)
```

### Verificar Soporte de Plataforma

```dart
// Verificar si los isolates están soportados en la plataforma actual
if (CountdownManagerFactory.isolatesSupported) {
  print('Ejecutando en plataforma nativa con soporte de Isolate');
} else {
  print('Ejecutando en plataforma web con fallback de Timer');
}
```

### Forzar Modo Timer (todas las plataformas)

```dart
CountdownCarouselWidget(
  targetDate: DateTime.now().add(Duration(days: 1)),
  useIsolate: false, // Fuerza uso de Timer incluso en plataformas nativas
)
```

## Referencia de API

### CountdownCarouselWidget

| Propiedad | Tipo | Defecto | Descripción |
|-----------|------|---------|-------------|
| `targetDate` | `DateTime` | **requerido** | La fecha/hora objetivo para la cuenta regresiva |
| `images` | `List<CarouselImageItem>` | `[]` | Lista de imágenes a mostrar |
| `onAddImage` | `VoidCallback?` | `null` | Callback cuando se presiona "Agregar Imagen" |
| `onImageTap` | `Function(int)?` | `null` | Callback cuando se presiona una imagen |
| `onImageRemove` | `Function(int)?` | `null` | Callback cuando se presiona el botón de eliminar |
| `onCountdownComplete` | `VoidCallback?` | `null` | Callback cuando la cuenta regresiva llega a cero |
| `maxImages` | `int` | `10` | Número máximo de imágenes permitidas |
| `useIsolate` | `bool?` | Auto-detectar | `null`: auto-detectar, `true`: forzar isolate, `false`: forzar timer |
| `boxColor` | `Color` | `Color(0xFF1E3A5F)` | Color de fondo de las cajas de tiempo |
| `numberColor` | `Color` | `Colors.white` | Color de los números de la cuenta regresiva |
| `labelColor` | `Color` | `Colors.white` | Color de las etiquetas (DIAS, HORAS, etc.) |
| `carouselBackgroundColor` | `Color` | `Color(0xFFB3D4E8)` | Color de fondo del carrusel |
| `timeLabels` | `List<String>?` | `['DAYS', 'HOURS', 'MINS', 'SECS']` | Etiquetas personalizadas |
| `animateChanges` | `bool` | `true` | Animar cambios de valor |

### ControllableCountdownController

| Propiedad/Método | Tipo | Descripción |
|------------------|------|-------------|
| `id` | `String` | Identificador único para el countdown |
| `state` | `CountdownState` | Estado actual (idle, running, paused, completed, stopped) |
| `isRunning` | `bool` | Si el countdown está activamente ejecutándose |
| `isPaused` | `bool` | Si el countdown está pausado |
| `timeStream` | `Stream<TimeRemaining>` | Stream de actualizaciones de tiempo |
| `stateStream` | `Stream<CountdownState>` | Stream de cambios de estado |
| `start()` | `Future<void>` | Iniciar el countdown |
| `pause()` | `void` | Pausar el countdown |
| `resume()` | `void` | Reanudar desde estado pausado |
| `reset()` | `void` | Reiniciar al objetivo original |
| `resetTo(DateTime)` | `void` | Reiniciar a nuevo objetivo |
| `dispose()` | `Future<void>` | Limpiar recursos |

### GlobalCountdownManager

| Método | Descripción |
|--------|-------------|
| `register(controller)` | Registrar un controlador para gestión global |
| `unregister(id)` | Remover un controlador de la gestión |
| `pauseAll()` | Pausar todos los countdowns registrados |
| `resumeAll()` | Reanudar todos los countdowns registrados |
| `resetAll()` | Reiniciar todos a sus objetivos originales |
| `resetAllTo(DateTime)` | Reiniciar todos a nuevo objetivo |
| `disposeAll()` | Liberar todos los controladores |

### CarouselImageItem

```dart
// Crear desde un ImageProvider
CarouselImageItem.fromProvider(
  NetworkImage('https://ejemplo.com/imagen.jpg'),
  id: 'id_unico',
)

// Crear un placeholder de botón agregar
CarouselImageItem.addButton()
```

## Arquitectura

### Plataformas Nativas (Isolate)

```
Isolate Principal (UI)         Isolate Worker
      |                              |
      |---- spawn() --------------->|
      |                              |
      |<---- TimeRemaining ---------|
      |      (cada segundo)          |
      |                              |
      |---- pause() --------------->|
      |---- resume() -------------->|
      |---- reset() --------------->|
      |                              |
```

### Plataforma Web (Timer)

```
Hilo Principal
      |
      |-- Timer.periodic(1 segundo)
      |         |
      |         v
      |   Calcular TimeRemaining
      |         |
      |         v
      |   Actualizar UI via Stream
      |
```

### Arquitectura de Múltiples Countdowns

```
┌─────────────────────────────────────────────────────┐
│                Isolate Principal (UI)                │
│                                                      │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────┐ │
│  │ Controlador 1│  │ Controlador 2│  │Controlador N│ │
│  └──────┬───────┘  └──────┬───────┘  └─────┬──────┘ │
└─────────┼─────────────────┼────────────────┼────────┘
          │                 │                │
          v                 v                v
   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
   │  Isolate 1   │  │  Isolate 2   │  │  Isolate N   │
   │  (Timer)     │  │  (Timer)     │  │  (Timer)     │
   └──────────────┘  └──────────────┘  └──────────────┘
```

## Por qué los Isolates No Funcionan en Web

Los Dart Isolates **no están soportados** en plataformas web. Esto se debe a:

1. **JavaScript es single-threaded**: El motor JavaScript del navegador se ejecuta en un solo hilo
2. **Web Workers son diferentes**: Aunque existen Web Workers, tienen una API diferente a los Isolates
3. **Sin soporte nativo**: Flutter/Dart no proporciona traducción automática de Isolates a Web Workers

Este paquete maneja esto automáticamente mediante:
- Uso de **imports condicionales** para evitar importar `dart:isolate` en web
- Proporcionar un **fallback basado en Timer** que funciona idénticamente en web
- **Auto-detección** de la plataforma en tiempo de ejecución

## Ejemplo

Consulta el directorio [example](example/) para una aplicación de demostración completa con:
- Countdown básico con carrusel
- Múltiples countdowns independientes
- Demo de controles globales
- Ejemplos de estilos personalizados

```bash
cd example
flutter run -d chrome  # Probar plataforma web (Timer)
flutter run -d macos   # Probar plataforma nativa (Isolate)
flutter run -d android # Probar Android (Isolate)
```

## Testing

Ejecutar el conjunto de pruebas:

```bash
flutter test
```

El paquete incluye más de 39 pruebas cubriendo:
- Modelo TimeRemaining
- Modelo CountdownConfig
- Renderizado de widgets
- Funcionalidad del timer manager
- Independencia de múltiples countdowns
- Operaciones del global manager
- Operaciones de Pausar/Reanudar/Reiniciar

## Contribuir

¡Las contribuciones son bienvenidas! Por favor lee nuestras guías de contribución y envía pull requests a nuestro repositorio.

1. Fork del repositorio
2. Crea tu rama de feature (`git checkout -b feature/feature-increible`)
3. Commit de tus cambios (`git commit -m 'Agregar feature increíble'`)
4. Push a la rama (`git push origin feature/feature-increible`)
5. Abre un Pull Request

## Licencia

Este proyecto está licenciado bajo la Licencia MIT - consulta el archivo [LICENSE](LICENSE) para más detalles.

## Changelog

Consulta [CHANGELOG.md](CHANGELOG.md) para una lista de cambios.

## Soporte

¡Si encuentras útil este paquete, por favor dale una estrella en GitHub!

Para bugs y solicitudes de funcionalidades, por favor [crea un issue](https://github.com/juansuarez-pragma/prg_timer/issues).
