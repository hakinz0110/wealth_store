import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wealth_app/core/utils/performance_optimizer.dart';
import 'package:wealth_app/core/utils/component_lifecycle_optimizer.dart';

/// Performance monitoring widget for debugging and optimization
class PerformanceMonitor extends StatefulWidget {
  final Widget child;
  final bool showOverlay;
  final bool enableLogging;
  
  const PerformanceMonitor({
    super.key,
    required this.child,
    this.showOverlay = kDebugMode,
    this.enableLogging = kDebugMode,
  });
  
  @override
  State<PerformanceMonitor> createState() => _PerformanceMonitorState();
}

class _PerformanceMonitorState extends State<PerformanceMonitor> {
  Timer? _updateTimer;
  PerformanceMetrics? _currentMetrics;
  ImageCacheStatistics? _imageCacheStats;
  ComponentLifecycleStatistics? _lifecycleStats;
  bool _isExpanded = false;
  
  @override
  void initState() {
    super.initState();
    if (widget.showOverlay || widget.enableLogging) {
      _startMonitoring();
    }
  }
  
  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
  
  void _startMonitoring() {
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentMetrics = PerformanceOptimizer().getPerformanceMetrics();
          _imageCacheStats = OptimizedImageLoader.getCacheStatistics();
          _lifecycleStats = ComponentLifecycleOptimizer().getStatistics();
        });
        
        if (widget.enableLogging) {
          _logPerformanceMetrics();
        }
      }
    });
  }
  
  void _logPerformanceMetrics() {
    if (_currentMetrics != null) {
      final fps = _currentMetrics!.currentFps;
      if (fps < 55) {
        debugPrint('⚠️ Performance Warning: FPS dropped to ${fps.toStringAsFixed(1)}');
      }
      
      if (_imageCacheStats != null && _imageCacheStats!.memoryCacheUsagePercentage > 80) {
        debugPrint('⚠️ Memory Warning: Image cache at ${_imageCacheStats!.memoryCacheUsagePercentage.toStringAsFixed(1)}%');
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.showOverlay && _currentMetrics != null)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 10,
            child: _buildPerformanceOverlay(),
          ),
      ],
    );
  }
  
  Widget _buildPerformanceOverlay() {
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // FPS indicator
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.speed,
                  size: 16,
                  color: _getFpsColor(_currentMetrics!.currentFps),
                ),
                const SizedBox(width: 4),
                Text(
                  '${_currentMetrics!.currentFps.toStringAsFixed(1)} FPS',
                  style: TextStyle(
                    color: _getFpsColor(_currentMetrics!.currentFps),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            if (_isExpanded) ...[
              const SizedBox(height: 8),
              _buildDetailedMetrics(),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailedMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Frame time
        _buildMetricRow(
          'Frame Time',
          '${_currentMetrics!.averageFrameTime.inMicroseconds}μs',
          _getFrameTimeColor(_currentMetrics!.averageFrameTime),
        ),
        
        // Active animations
        _buildMetricRow(
          'Animations',
          '${_currentMetrics!.activeAnimations}',
          Colors.blue,
        ),
        
        // Image cache
        if (_imageCacheStats != null) ...[
          _buildMetricRow(
            'Image Cache',
            '${_imageCacheStats!.currentSize}/${_imageCacheStats!.maximumSize}',
            _getCacheColor(_imageCacheStats!.cacheUsagePercentage),
          ),
          _buildMetricRow(
            'Cache Memory',
            '${(_imageCacheStats!.currentSizeBytes / 1024 / 1024).toStringAsFixed(1)}MB',
            _getCacheColor(_imageCacheStats!.memoryCacheUsagePercentage),
          ),
        ],
        
        // Component lifecycle
        if (_lifecycleStats != null) ...[
          _buildMetricRow(
            'Components',
            '${_lifecycleStats!.activeComponents}/${_lifecycleStats!.totalComponents}',
            Colors.purple,
          ),
        ],
      ],
    );
  }
  
  Widget _buildMetricRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getFpsColor(double fps) {
    if (fps >= 58) return Colors.green;
    if (fps >= 45) return Colors.orange;
    return Colors.red;
  }
  
  Color _getFrameTimeColor(Duration frameTime) {
    final microseconds = frameTime.inMicroseconds;
    if (microseconds <= 16667) return Colors.green; // 60fps
    if (microseconds <= 22222) return Colors.orange; // 45fps
    return Colors.red;
  }
  
  Color _getCacheColor(double percentage) {
    if (percentage <= 60) return Colors.green;
    if (percentage <= 80) return Colors.orange;
    return Colors.red;
  }
}

/// Performance-optimized animation controller
class OptimizedAnimationController extends AnimationController {
  final String? performanceId;
  
  OptimizedAnimationController({
    required Duration duration,
    required TickerProvider vsync,
    this.performanceId,
    String? debugLabel,
    double? value,
  }) : super(
          duration: duration,
          vsync: vsync,
          debugLabel: debugLabel ?? performanceId,
          value: value,
        );
  
  @override
  void addListener(VoidCallback listener) {
    super.addListener(() {
      if (performanceId != null) {
        PerformanceOptimizer().updateAnimationFrame(performanceId!);
      }
      listener();
    });
  }
  
  @override
  TickerFuture forward({double? from}) {
    if (performanceId != null) {
      PerformanceOptimizer().startAnimationTracking(performanceId!);
    }
    return super.forward(from: from);
  }
  
  @override
  void stop({bool canceled = true}) {
    if (performanceId != null) {
      PerformanceOptimizer().endAnimationTracking(performanceId!);
    }
    super.stop(canceled: canceled);
  }
  
  @override
  void dispose() {
    if (performanceId != null) {
      PerformanceOptimizer().endAnimationTracking(performanceId!);
    }
    super.dispose();
  }
}

/// Performance-optimized widget builder
class OptimizedBuilder extends StatelessWidget {
  final WidgetBuilder builder;
  final String? debugLabel;
  final bool enableRepaintBoundary;
  
  const OptimizedBuilder({
    super.key,
    required this.builder,
    this.debugLabel,
    this.enableRepaintBoundary = true,
  });
  
  @override
  Widget build(BuildContext context) {
    Widget child = builder(context);
    
    if (enableRepaintBoundary) {
      child = RepaintBoundary(child: child);
    }
    
    return child;
  }
}

/// Performance statistics widget for debugging
class PerformanceStatistics extends StatefulWidget {
  const PerformanceStatistics({super.key});
  
  @override
  State<PerformanceStatistics> createState() => _PerformanceStatisticsState();
}

class _PerformanceStatisticsState extends State<PerformanceStatistics> {
  Timer? _updateTimer;
  PerformanceMetrics? _metrics;
  ImageCacheStatistics? _imageStats;
  ComponentLifecycleStatistics? _lifecycleStats;
  
  @override
  void initState() {
    super.initState();
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _metrics = PerformanceOptimizer().getPerformanceMetrics();
          _imageStats = OptimizedImageLoader.getCacheStatistics();
          _lifecycleStats = ComponentLifecycleOptimizer().getStatistics();
        });
      }
    });
  }
  
  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Statistics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Animation Performance', [
              if (_metrics != null) ...[
                _buildStatRow('Current FPS', '${_metrics!.currentFps.toStringAsFixed(1)}'),
                _buildStatRow('Frame Time', '${_metrics!.averageFrameTime.inMicroseconds}μs'),
                _buildStatRow('Active Animations', '${_metrics!.activeAnimations}'),
              ],
            ]),
            
            const SizedBox(height: 24),
            
            _buildSection('Image Cache', [
              if (_imageStats != null) ...[
                _buildStatRow('Cached Images', '${_imageStats!.currentSize}/${_imageStats!.maximumSize}'),
                _buildStatRow('Cache Usage', '${_imageStats!.cacheUsagePercentage.toStringAsFixed(1)}%'),
                _buildStatRow('Memory Usage', '${(_imageStats!.currentSizeBytes / 1024 / 1024).toStringAsFixed(1)}MB'),
                _buildStatRow('Live Images', '${_imageStats!.liveImageCount}'),
                _buildStatRow('Pending Images', '${_imageStats!.pendingImageCount}'),
              ],
            ]),
            
            const SizedBox(height: 24),
            
            _buildSection('Component Lifecycle', [
              if (_lifecycleStats != null) ...[
                _buildStatRow('Total Components', '${_lifecycleStats!.totalComponents}'),
                _buildStatRow('Active Components', '${_lifecycleStats!.activeComponents}'),
                _buildStatRow('Inactive Components', '${_lifecycleStats!.inactiveComponents}'),
                _buildStatRow('Pending Disposal', '${_lifecycleStats!.pendingDisposal}'),
              ],
            ]),
            
            const SizedBox(height: 24),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      OptimizedImageLoader.clearImageCache();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Image cache cleared')),
                      );
                    },
                    child: const Text('Clear Image Cache'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ComponentLifecycleOptimizer().cleanup();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Components cleaned up')),
                      );
                    },
                    child: const Text('Cleanup Components'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}