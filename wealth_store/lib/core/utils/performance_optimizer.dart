import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Performance optimizer for maintaining 60fps animations and efficient rendering
class PerformanceOptimizer {
  static final PerformanceOptimizer _instance = PerformanceOptimizer._internal();
  factory PerformanceOptimizer() => _instance;
  PerformanceOptimizer._internal();
  
  // Performance monitoring
  final List<Duration> _frameTimes = [];
  final int _maxFrameTimesSamples = 60; // Monitor last 60 frames
  Timer? _performanceTimer;
  
  // Animation performance tracking
  final Map<String, AnimationPerformanceData> _animationMetrics = {};
  
  // Memory optimization
  static const int _maxCachedImages = 100;
  static const Duration _cacheCleanupInterval = Duration(minutes: 5);
  Timer? _cacheCleanupTimer;
  
  /// Initialize performance monitoring
  void initialize() {
    if (kDebugMode) {
      _startPerformanceMonitoring();
      _startCacheCleanup();
    }
  }
  
  /// Dispose performance monitoring
  void dispose() {
    _performanceTimer?.cancel();
    _cacheCleanupTimer?.cancel();
  }
  
  /// Start monitoring frame performance
  void _startPerformanceMonitoring() {
    _performanceTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _analyzeFramePerformance();
    });
    
    // Monitor frame times
    SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);
  }
  
  /// Analyze frame performance and log issues
  void _analyzeFramePerformance() {
    if (_frameTimes.isEmpty) return;
    
    final totalMicroseconds = _frameTimes.fold<int>(0, (sum, duration) => sum + duration.inMicroseconds);
    final averageFrameTime = Duration(microseconds: totalMicroseconds ~/ _frameTimes.length);
    final targetFrameTime = const Duration(microseconds: 16667); // 60fps = 16.67ms
    
    if (averageFrameTime > targetFrameTime) {
      debugPrint('⚠️ Performance Warning: Average frame time ${averageFrameTime.inMicroseconds}μs exceeds 60fps target');
    }
    
    // Check for frame drops
    final droppedFrames = _frameTimes.where((time) => time > targetFrameTime * 2).length;
    if (droppedFrames > 0) {
      debugPrint('⚠️ Performance Warning: $droppedFrames dropped frames detected');
    }
    
    _frameTimes.clear();
  }
  
  /// Handle frame timing callbacks
  void _onFrameTimings(List<FrameTiming> timings) {
    for (final timing in timings) {
      final frameTime = timing.totalSpan;
      _frameTimes.add(frameTime);
      
      // Keep only recent samples
      if (_frameTimes.length > _maxFrameTimesSamples) {
        _frameTimes.removeAt(0);
      }
    }
  }
  
  /// Start animation performance tracking
  void startAnimationTracking(String animationId) {
    _animationMetrics[animationId] = AnimationPerformanceData(
      startTime: DateTime.now(),
      frameCount: 0,
    );
  }
  
  /// Update animation frame count
  void updateAnimationFrame(String animationId) {
    final data = _animationMetrics[animationId];
    if (data != null) {
      data.frameCount++;
    }
  }
  
  /// End animation performance tracking
  void endAnimationTracking(String animationId) {
    final data = _animationMetrics[animationId];
    if (data != null) {
      final duration = DateTime.now().difference(data.startTime);
      final fps = data.frameCount / (duration.inMilliseconds / 1000);
      
      if (kDebugMode && fps < 55) { // Allow 5fps tolerance
        debugPrint('⚠️ Animation Performance: $animationId achieved ${fps.toStringAsFixed(1)} fps');
      }
      
      _animationMetrics.remove(animationId);
    }
  }
  
  /// Start cache cleanup timer
  void _startCacheCleanup() {
    _cacheCleanupTimer = Timer.periodic(_cacheCleanupInterval, (timer) {
      _cleanupImageCache();
    });
  }
  
  /// Clean up image cache to prevent memory leaks
  void _cleanupImageCache() {
    final imageCache = PaintingBinding.instance.imageCache;
    
    if (imageCache.currentSize > _maxCachedImages) {
      imageCache.clear();
      if (kDebugMode) {
        debugPrint('🧹 Image cache cleared - was ${imageCache.currentSize} images');
      }
    }
  }
  
  /// Optimize widget for performance
  static Widget optimizeWidget(Widget child, {
    bool enableRepaintBoundary = true,
    bool enableAutomaticKeepAlive = false,
    String? debugLabel,
  }) {
    Widget optimizedChild = child;
    
    // Add repaint boundary to prevent unnecessary repaints
    if (enableRepaintBoundary) {
      optimizedChild = RepaintBoundary(child: optimizedChild);
    }
    
    // Add automatic keep alive for expensive widgets
    if (enableAutomaticKeepAlive) {
      optimizedChild = AutomaticKeepAlive(child: optimizedChild);
    }
    
    return optimizedChild;
  }
  
  /// Create performance-optimized animation controller
  static AnimationController createOptimizedController({
    required Duration duration,
    required TickerProvider vsync,
    String? debugLabel,
    double? value,
  }) {
    return AnimationController(
      duration: duration,
      vsync: vsync,
      debugLabel: debugLabel,
      value: value,
    );
  }
  
  /// Create battery-efficient animation
  static Animation<T> createBatteryEfficientAnimation<T>({
    required AnimationController controller,
    required Tween<T> tween,
    Curve curve = Curves.easeInOut,
  }) {
    // Use efficient curves that require fewer calculations
    final efficientCurve = _getEfficientCurve(curve);
    
    return tween.animate(CurvedAnimation(
      parent: controller,
      curve: efficientCurve,
    ));
  }
  
  /// Get battery-efficient curve alternatives
  static Curve _getEfficientCurve(Curve originalCurve) {
    // Map complex curves to simpler alternatives for better performance
    if (originalCurve == Curves.elasticOut || 
        originalCurve == Curves.bounceOut) {
      return Curves.easeOutCubic; // Simpler alternative
    }
    
    if (originalCurve == Curves.elasticIn || 
        originalCurve == Curves.bounceIn) {
      return Curves.easeInCubic; // Simpler alternative
    }
    
    return originalCurve;
  }
  
  /// Optimize list performance with viewport awareness
  static Widget optimizeListView({
    required IndexedWidgetBuilder itemBuilder,
    required int itemCount,
    ScrollController? controller,
    Axis scrollDirection = Axis.vertical,
    bool shrinkWrap = false,
    EdgeInsets? padding,
  }) {
    return ListView.builder(
      controller: controller,
      scrollDirection: scrollDirection,
      shrinkWrap: shrinkWrap,
      padding: padding,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // Wrap each item in a repaint boundary
        return RepaintBoundary(
          child: itemBuilder(context, index),
        );
      },
      // Optimize for performance
      cacheExtent: 250.0, // Cache 250 pixels beyond viewport
      addRepaintBoundaries: true,
      addAutomaticKeepAlives: true,
    );
  }
  
  /// Optimize grid performance
  static Widget optimizeGridView({
    required IndexedWidgetBuilder itemBuilder,
    required int itemCount,
    required SliverGridDelegate gridDelegate,
    ScrollController? controller,
    bool shrinkWrap = false,
    EdgeInsets? padding,
  }) {
    return GridView.builder(
      controller: controller,
      shrinkWrap: shrinkWrap,
      padding: padding,
      gridDelegate: gridDelegate,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: itemBuilder(context, index),
        );
      },
      cacheExtent: 250.0,
      addRepaintBoundaries: true,
      addAutomaticKeepAlives: true,
    );
  }
  
  /// Debounce function calls to prevent excessive operations
  static Timer? _debounceTimer;
  static void debounce(Duration delay, VoidCallback callback) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  }
  
  /// Throttle function calls to limit frequency
  static DateTime? _lastThrottleTime;
  static void throttle(Duration interval, VoidCallback callback) {
    final now = DateTime.now();
    if (_lastThrottleTime == null || 
        now.difference(_lastThrottleTime!) >= interval) {
      _lastThrottleTime = now;
      callback();
    }
  }
  
  /// Get current performance metrics
  PerformanceMetrics getPerformanceMetrics() {
    final averageFrameTime = _frameTimes.isNotEmpty
        ? Duration(microseconds: _frameTimes.fold<int>(0, (sum, duration) => sum + duration.inMicroseconds) ~/ _frameTimes.length)
        : Duration.zero;
    
    final currentFps = averageFrameTime.inMicroseconds > 0
        ? 1000000 / averageFrameTime.inMicroseconds
        : 60.0;
    
    return PerformanceMetrics(
      averageFrameTime: averageFrameTime,
      currentFps: currentFps,
      activeAnimations: _animationMetrics.length,
      cachedImages: PaintingBinding.instance.imageCache.currentSize,
    );
  }
}

/// Animation performance tracking data
class AnimationPerformanceData {
  final DateTime startTime;
  int frameCount;
  
  AnimationPerformanceData({
    required this.startTime,
    required this.frameCount,
  });
}

/// Performance metrics data class
class PerformanceMetrics {
  final Duration averageFrameTime;
  final double currentFps;
  final int activeAnimations;
  final int cachedImages;
  
  const PerformanceMetrics({
    required this.averageFrameTime,
    required this.currentFps,
    required this.activeAnimations,
    required this.cachedImages,
  });
  
  @override
  String toString() {
    return 'PerformanceMetrics(fps: ${currentFps.toStringAsFixed(1)}, '
           'frameTime: ${averageFrameTime.inMicroseconds}μs, '
           'animations: $activeAnimations, '
           'cachedImages: $cachedImages)';
  }
}

/// Performance-optimized widget mixin
mixin PerformanceOptimizedWidget<T extends StatefulWidget> on State<T> {
  String? get performanceId => null;
  
  @override
  void initState() {
    super.initState();
    if (performanceId != null) {
      PerformanceOptimizer().startAnimationTracking(performanceId!);
    }
  }
  
  @override
  void dispose() {
    if (performanceId != null) {
      PerformanceOptimizer().endAnimationTracking(performanceId!);
    }
    super.dispose();
  }
  
  void updatePerformanceFrame() {
    if (performanceId != null) {
      PerformanceOptimizer().updateAnimationFrame(performanceId!);
    }
  }
}