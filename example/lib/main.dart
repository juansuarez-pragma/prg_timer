import 'package:flutter/material.dart';
import 'package:countdown_carousel_widget/countdown_carousel_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Countdown Carousel Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A5F)),
        useMaterial3: true,
      ),
      home: const MainNavigationPage(),
    );
  }
}

/// Main navigation page with tabs for different demos
class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    BasicDemoPage(),
    MultiCountdownDemoPage(),
  ];

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
          NavigationDestination(
            icon: Icon(Icons.timer),
            label: 'Basic Demo',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view),
            label: 'Multi Countdown',
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// BASIC DEMO PAGE (Original functionality)
// =============================================================================

class BasicDemoPage extends StatefulWidget {
  const BasicDemoPage({super.key});

  @override
  State<BasicDemoPage> createState() => _BasicDemoPageState();
}

class _BasicDemoPageState extends State<BasicDemoPage> {
  late DateTime _targetDate;
  final List<CarouselImageItem> _images = [];

  @override
  void initState() {
    super.initState();
    _targetDate = DateTime.now().add(
      const Duration(days: 2, hours: 14, minutes: 35, seconds: 20),
    );
  }

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
        content: Text('Image added! (Demo: using placeholder image)'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onImageTap(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tapped image at index $index'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _onImageRemove(int index) {
    setState(() {
      _images.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed image at index $index'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _onCountdownComplete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Countdown Complete!'),
        content: const Text('The countdown has reached zero.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _targetDate = DateTime.now().add(
                  const Duration(days: 2, hours: 14, minutes: 35, seconds: 20),
                );
              });
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _resetCountdown() {
    setState(() {
      _targetDate = DateTime.now().add(
        const Duration(days: 2, hours: 14, minutes: 35, seconds: 20),
      );
    });
  }

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
        title: const Text('Basic Demo'),
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Full Widget (with Isolate)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            CountdownCarouselWidget(
              targetDate: _targetDate,
              images: _images,
              onAddImage: _onAddImage,
              onImageTap: _onImageTap,
              onImageRemove: _onImageRemove,
              onCountdownComplete: _onCountdownComplete,
              maxImages: 9,
              useIsolate: true,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _resetCountdown,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
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
                    label: const Text('10 sec'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Countdown Only (without carousel)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            CountdownOnlyWidget(
              targetDate: _targetDate,
              onCountdownComplete: () {},
              useIsolate: true,
            ),
            const SizedBox(height: 32),
            const Text(
              'Custom Styled',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            CountdownCarouselWidget(
              targetDate: _targetDate,
              images: const [],
              onAddImage: _onAddImage,
              boxColor: const Color(0xFF4A148C),
              carouselBackgroundColor: const Color(0xFFCE93D8),
              timeLabels: const ['DIAS', 'HORAS', 'MINS', 'SEGS'],
              useIsolate: false,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// MULTI COUNTDOWN DEMO PAGE (Independent countdowns with Isolates)
// =============================================================================

/// Demo page showing multiple independent countdowns
/// Each countdown runs in its own Isolate and can be controlled independently
class MultiCountdownDemoPage extends StatefulWidget {
  const MultiCountdownDemoPage({super.key});

  @override
  State<MultiCountdownDemoPage> createState() => _MultiCountdownDemoPageState();
}

class _MultiCountdownDemoPageState extends State<MultiCountdownDemoPage> {
  /// Global manager for controlling all countdowns at once
  final GlobalCountdownManager _globalManager = GlobalCountdownManager();

  /// Individual countdown controllers - each with its own Isolate!
  late List<ControllableCountdownController> _controllers;

  /// Configuration for each countdown
  final List<_CountdownConfig> _countdownConfigs = [
    _CountdownConfig(
      id: 'event_1',
      title: 'Event Launch',
      duration: const Duration(hours: 2, minutes: 30),
      color: const Color(0xFF1E3A5F),
    ),
    _CountdownConfig(
      id: 'event_2',
      title: 'Flash Sale',
      duration: const Duration(minutes: 45, seconds: 30),
      color: const Color(0xFF4A148C),
    ),
    _CountdownConfig(
      id: 'event_3',
      title: 'Meeting Start',
      duration: const Duration(minutes: 15),
      color: const Color(0xFF006064),
    ),
    _CountdownConfig(
      id: 'event_4',
      title: 'Quick Timer',
      duration: const Duration(seconds: 30),
      color: const Color(0xFFBF360C),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _controllers = _countdownConfigs.map((config) {
      final controller = ControllableCountdownController(
        id: config.id,
        targetDate: DateTime.now().add(config.duration),
        useIsolate: true, // Each countdown runs in its own Isolate!
      );

      // Register with global manager for batch operations
      _globalManager.register(controller);

      return controller;
    }).toList();
  }

  @override
  void dispose() {
    // Dispose all controllers through the global manager
    _globalManager.disposeAll();
    super.dispose();
  }

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
        title: const Text('Multi Countdown Demo'),
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Global Controls Section
          _GlobalControlsSection(
            globalManager: _globalManager,
            onPauseAll: () {
              _globalManager.pauseAll();
              _showMessage('All countdowns paused');
            },
            onResumeAll: () {
              _globalManager.resumeAll();
              _showMessage('All countdowns resumed');
            },
            onResetAll: () {
              // Reset each to its original duration
              for (int i = 0; i < _controllers.length; i++) {
                _controllers[i].resetTo(
                  DateTime.now().add(_countdownConfigs[i].duration),
                );
              }
              _showMessage('All countdowns reset');
            },
          ),

          // Info Banner
          Container(
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
                    'Each countdown runs in its own Isolate! '
                    'Control them independently or all at once.',
                    style: TextStyle(
                      color: Colors.blue.shade900,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Individual Countdown Cards
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _controllers.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _IndividualCountdownCard(
                    controller: _controllers[index],
                    config: _countdownConfigs[index],
                    onComplete: () {
                      _showMessage('${_countdownConfigs[index].title} completed!');
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
}

/// Configuration for a countdown
class _CountdownConfig {
  final String id;
  final String title;
  final Duration duration;
  final Color color;

  const _CountdownConfig({
    required this.id,
    required this.title,
    required this.duration,
    required this.color,
  });
}

/// Global controls section for batch operations
class _GlobalControlsSection extends StatelessWidget {
  final GlobalCountdownManager globalManager;
  final VoidCallback onPauseAll;
  final VoidCallback onResumeAll;
  final VoidCallback onResetAll;

  const _GlobalControlsSection({
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
          const Text(
            'Global Controls',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Control all ${globalManager.count} countdowns at once',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          // Use Wrap for better responsiveness on small screens
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SizedBox(
                width: 110,
                child: ElevatedButton.icon(
                  onPressed: onPauseAll,
                  icon: const Icon(Icons.pause, size: 16),
                  label: const Text(
                    'Pause',
                    style: TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                ),
              ),
              SizedBox(
                width: 110,
                child: ElevatedButton.icon(
                  onPressed: onResumeAll,
                  icon: const Icon(Icons.play_arrow, size: 16),
                  label: const Text(
                    'Resume',
                    style: TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                ),
              ),
              SizedBox(
                width: 110,
                child: ElevatedButton.icon(
                  onPressed: onResetAll,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text(
                    'Reset',
                    style: TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A5F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Individual countdown card with its own controls
class _IndividualCountdownCard extends StatefulWidget {
  final ControllableCountdownController controller;
  final _CountdownConfig config;
  final VoidCallback? onComplete;

  const _IndividualCountdownCard({
    required this.controller,
    required this.config,
    this.onComplete,
  });

  @override
  State<_IndividualCountdownCard> createState() =>
      _IndividualCountdownCardState();
}

class _IndividualCountdownCardState extends State<_IndividualCountdownCard> {
  CountdownState _state = CountdownState.idle;

  @override
  void initState() {
    super.initState();
    _setupStateListener();
    _startCountdown();
  }

  void _setupStateListener() {
    widget.controller.stateStream.listen((state) {
      if (mounted) {
        setState(() {
          _state = state;
        });
      }
    });
  }

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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with title and state indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.config.color,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
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
          ),

          // Countdown display
          Padding(
            padding: const EdgeInsets.all(16),
            child: ControllableCountdownWidget(
              controller: widget.controller,
              boxColor: widget.config.color,
              showStateIndicator: false, // We show our own indicator
              onCountdownComplete: widget.onComplete,
            ),
          ),

          // Individual controls
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                // Pause/Resume button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      if (isRunning) {
                        widget.controller.pause();
                      } else if (isPaused) {
                        widget.controller.resume();
                      }
                    },
                    icon: Icon(
                      isRunning ? Icons.pause : Icons.play_arrow,
                      size: 18,
                    ),
                    label: Text(isRunning ? 'Pause' : 'Resume'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isRunning ? Colors.orange : Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Reset button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      widget.controller.resetTo(
                        DateTime.now().add(widget.config.duration),
                      );
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Reset'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: widget.config.color,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Quick add time button
                IconButton(
                  onPressed: () {
                    // Add 30 seconds to current target
                    final newTarget = widget.controller.currentTargetDate
                        .add(const Duration(seconds: 30));
                    widget.controller.updateTargetDate(newTarget);
                  },
                  icon: const Icon(Icons.add),
                  tooltip: '+30 sec',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateChip() {
    Color chipColor;
    String label;
    IconData icon;

    switch (_state) {
      case CountdownState.running:
        chipColor = Colors.green;
        label = 'RUNNING';
        icon = Icons.play_arrow;
        break;
      case CountdownState.paused:
        chipColor = Colors.orange;
        label = 'PAUSED';
        icon = Icons.pause;
        break;
      case CountdownState.completed:
        chipColor = Colors.blue;
        label = 'DONE';
        icon = Icons.check;
        break;
      case CountdownState.stopped:
        chipColor = Colors.red;
        label = 'STOPPED';
        icon = Icons.stop;
        break;
      case CountdownState.idle:
        chipColor = Colors.grey;
        label = 'IDLE';
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
