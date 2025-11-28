# Registro de Cambios

Todos los cambios notables de este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/),
y este proyecto adhiere a [Versionamiento Semántico](https://semver.org/lang/es/).

## [1.0.0] - 2024-11-28

### Agregado

- **CountdownCarouselWidget**: Widget principal con temporizador de cuenta regresiva y carrusel de imágenes
- **CountdownOnlyWidget**: Widget simplificado solo con el temporizador de cuenta regresiva
- **Soporte de Isolates**: Procesamiento en segundo plano en plataformas nativas (iOS, Android, macOS, Windows, Linux)
- **Soporte Web**: Fallback basado en Timer para plataforma web donde los Isolates no están soportados
- **Auto-Detección de Plataforma**: Selección automática de la implementación apropiada según la plataforma
- **ControllableCountdownController**: Controlador individual de countdown con pausar/reanudar/reiniciar
- **GlobalCountdownManager**: Administrar múltiples countdowns con operaciones por lotes
- **ControllableCountdownWidget**: Widget con capacidades de control externo
- **ControllableCountdownCard**: Widget de tarjeta con botones de control integrados
- **Múltiples Countdowns Independientes**: Cada countdown se ejecuta en su propio Isolate
- **Estilos Personalizables**: Colores, etiquetas y estilos pueden ser configurados
- **Cambios de Valor Animados**: Animaciones suaves de escala en cambios de valor
- **Diseño Responsivo**: Se adapta al ancho de pantalla disponible
- **Carrusel de Imágenes**: Carrusel de imágenes desplazable horizontalmente con paginación
- **Modelo TimeRemaining**: Modelo inmutable para valores de tiempo de cuenta regresiva
- **Enum CountdownState**: Gestión de estado para el ciclo de vida del countdown

### Características

- El countdown muestra días, horas, minutos y segundos
- Pausar, reanudar y reiniciar countdowns individuales
- Pausar/reanudar/reiniciar global para todos los countdowns
- Etiquetas de tiempo personalizables (soporte de localización)
- Agregar/eliminar imágenes en el carrusel
- Callbacks de tap y eliminación de imágenes
- Callback de finalización del countdown
- Opción para forzar modo timer para depuración

### Técnico

- Imports condicionales para compatibilidad web
- Comunicación bidireccional con Isolates
- Actualizaciones de tiempo basadas en Stream
- Más de 39 pruebas unitarias y de widgets
- Documentación completa de la API
