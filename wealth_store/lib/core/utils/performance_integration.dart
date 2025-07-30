import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/performance_service.dart';
import 'performance_optimizer.dart';
import 'component_lifecycle_optimizer.dart';

/// Integration class that combines our performance optimization tools
class PerformanceIntegration {
  static final PerformanceIntegration _instance = PerformanceIntegration._internal();
  factory PerformanceIntegration() => _instance;
  PerformanceIntegration._internal();
  
  late final PerformanceService _performanceService;
  late final PerformanceOptimizer _performanceOptimizer;
  late final ComponentLifecycleOptimizer _lifecycleOptimizer;
  
  /// Initialize all performance systems
  void initialize(WidgetRef ref) {
    _performanceService = ref.read(performanceServiceProvider);
    _performanceOptimizer = PerformanceOptimizer();
    _lifecycleOptimizer = ComponentLifecycleOptimizer();
    
    // Initialize the legacy performance optimizer
    _performanceOptimizer.initialize();
  }
  
  /// Monitor a network request with both systems
  void monitorNetworkRequest(String endpoint, Future<dynamic> request) {
    _performanceService.monitorNetworkRequest(endpoint, request);
  }
  
  /// Monitor widget build performance
  T monitorWidgetBuild<T>(String widgetName, T Function() buildFunction) {
    return _performanceService.monitorWidgetBuild(widgetName, buildFunction);
  }
  
  /// Monitor async operation performance
  Future<T> monitorAsyncOperation<T>(
    String operationName, 
    Future<T> Function() operation,
  ) async {
    return _performanceService.monitorAsyncOperation(operationName, operation);
  }
  
  /// Optimize widget for performance
  Widget optimizeWidget(Widget child, {
    bool enableRepaintBoundary = true,
    bool enableAutomaticKeepAlive = false,
    String? debugLabel,
  }) {
    return PerformanceOptimizer.optimizeWidget(
      child,
      enableRepaintBoundary: enableRepaintBoundary,
      enableAutomaticKeepAlive: enableAutomaticKeepAlive,
      debugLabel: debugLabel,
    );
  }
  
  /// Optimize list view performance
  Widget optimizeListView({
    required IndexedWidgetBuilder itemBuilder,
    required int itemCount,
    ScrollController? controller,
    Axis scrollDirection = Axis.vertical,
    bool shrinkWrap = false,
    EdgeInsets? padding,
  }) {
    return OptimizedListView(
      itemBuilder: itemBuilder,
      itemCount: itemCount,
      controller: controller,
      scrollDirection: scrollDirection,
      shrinkWrap: shrinkWrap,
      padding: padding,
    );
  }
  
  /// Optimize grid view performance
  Widget optimizeGridView({
    required IndexedWidgetBuilder itemBuilder,
    required int itemCount,
    required SliverGridDelegate gridDelegate,
    ScrollController? controller,
    bool shrinkWrap = false,
    EdgeInsets? padding,
  }) {
    return OptimizedGridView(
      itemBuilder: itemBuilder,
      itemCount: itemCount,
      gridDelegate: gridDelegate,
      controller: controller,
      shrinkWrap: shrinkWrap,
      padding: padding,
    );
  }
  
  /// Register a component for lifecycle management
  void registerComponent(String componentId, {
    VoidCallback? onDispose,
    Duration? disposeDelay,
  }) {
    _lifecycleOptimizer.registerComponent(
      componentId,
      onDispose: onDispose,
      disposeDelay: disposeDelay,
    );
  }
  
  /// Unregister a component
  void unregisterComponent(String componentId) {
    _lifecycleOptimizer.unregisterComponent(componentId);
  }
  
  /// Get combined performance statistics
  Map<String, dynamic> getPerformanceStatistics() {
    final perfMetrics = _performanceOptimizer.getPerformanceMetrics();
    final lifecycleStats = _lifecycleOptimizer.getStatistics();
    final serviceStats = _performanceService.getPerformanceSummary();
    
    return {
      'fps': perfMetrics.currentFps,
      'frameTime': perfMetrics.averageFrameTime.inMicroseconds,
      'activeAnimations': perfMetrics.activeAnimations,
      'cachedImages': perfMetrics.cachedImages,
      'components': {
        'total': lifecycleStats.totalComponents,
        'active': lifecycleStats.activeComponents,
        'inactive': lifecycleStats.inactiveComponents,
        'pendingDisposal': lifecycleStats.pendingDisposal,
      },
      'metrics': serviceStats,
    };
  }
  
  /// Log performance summary
  void logPerformanceSummary() {
    _performanceService.logPerformanceSummary();
  }
  
  /// Clear all metrics
  void clearMetrics() {
    _performanceService.clearMetrics();
  }
}

/// Performance monitoring mixin that combines both systems
mixin IntegratedPerformanceMonitorMixin<T extends StatefulWidget> on State<T> {
  String get performanceId => runtimeType.toString();
  
  @override
  void initState() {
    super.initState();
    PerformanceOptimizer().startAnimationTracking(performanceId);
    ComponentLifecycleOptimizer().registerComponent(
      performanceId,
      onDispose: onComponentDispose,
    );
  }
  
  @override
  void dispose() {
    PerformanceOptimizer().endAnimationTracking(performanceId);
    ComponentLifecycleOptimizer().unregisterComponent(performanceId);
    super.dispose();
  }
  
  /// Called when component is being disposed by the optimizer
  void onComponentDispose() {
    // Override in subclasses to handle cleanup
  }
  
  /// Monitor build method performance
  Widget monitorBuild(String widgetName, Widget Function() buildFunction) {
    return PerformanceIntegration().monitorWidgetBuild(widgetName, buildFunction);
  }
}