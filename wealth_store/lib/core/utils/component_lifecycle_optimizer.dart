import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Component lifecycle optimizer for efficient widget management and memory usage
class ComponentLifecycleOptimizer {
  static final ComponentLifecycleOptimizer _instance = ComponentLifecycleOptimizer._internal();
  factory ComponentLifecycleOptimizer() => _instance;
  ComponentLifecycleOptimizer._internal();
  
  // Track active components
  final Map<String, ComponentLifecycleData> _activeComponents = {};
  final Map<String, Timer> _disposeTimers = {};
  
  // Configuration
  static const Duration _defaultDisposeDelay = Duration(seconds: 30);
  static const int _maxActiveComponents = 50;
  
  /// Register a component for lifecycle management
  void registerComponent(String componentId, {
    VoidCallback? onDispose,
    Duration? disposeDelay,
  }) {
    _activeComponents[componentId] = ComponentLifecycleData(
      id: componentId,
      createdAt: DateTime.now(),
      onDispose: onDispose,
      disposeDelay: disposeDelay ?? _defaultDisposeDelay,
    );
    
    _checkComponentLimit();
  }
  
  /// Unregister a component
  void unregisterComponent(String componentId) {
    final component = _activeComponents.remove(componentId);
    _disposeTimers[componentId]?.cancel();
    _disposeTimers.remove(componentId);
    
    component?.onDispose?.call();
  }
  
  /// Mark component as inactive (will be disposed after delay)
  void markComponentInactive(String componentId) {
    final component = _activeComponents[componentId];
    if (component != null && !component.isInactive) {
      component.isInactive = true;
      component.inactiveAt = DateTime.now();
      
      // Schedule disposal
      _disposeTimers[componentId] = Timer(component.disposeDelay, () {
        unregisterComponent(componentId);
      });
    }
  }
  
  /// Mark component as active (cancel disposal)
  void markComponentActive(String componentId) {
    final component = _activeComponents[componentId];
    if (component != null && component.isInactive) {
      component.isInactive = false;
      component.inactiveAt = null;
      
      // Cancel disposal timer
      _disposeTimers[componentId]?.cancel();
      _disposeTimers.remove(componentId);
    }
  }
  
  /// Check if we have too many active components
  void _checkComponentLimit() {
    if (_activeComponents.length > _maxActiveComponents) {
      // Remove oldest inactive components first
      final inactiveComponents = _activeComponents.values
          .where((c) => c.isInactive)
          .toList()
        ..sort((a, b) => a.inactiveAt!.compareTo(b.inactiveAt!));
      
      for (final component in inactiveComponents.take(10)) {
        unregisterComponent(component.id);
      }
      
      // If still too many, remove oldest active components
      if (_activeComponents.length > _maxActiveComponents) {
        final activeComponents = _activeComponents.values
            .where((c) => !c.isInactive)
            .toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
        
        for (final component in activeComponents.take(5)) {
          unregisterComponent(component.id);
        }
      }
    }
  }
  
  /// Get component statistics
  ComponentLifecycleStatistics getStatistics() {
    final activeCount = _activeComponents.values.where((c) => !c.isInactive).length;
    final inactiveCount = _activeComponents.values.where((c) => c.isInactive).length;
    
    return ComponentLifecycleStatistics(
      totalComponents: _activeComponents.length,
      activeComponents: activeCount,
      inactiveComponents: inactiveCount,
      pendingDisposal: _disposeTimers.length,
    );
  }
  
  /// Clean up all components
  void cleanup() {
    for (final componentId in _activeComponents.keys.toList()) {
      unregisterComponent(componentId);
    }
  }
}

/// Mixin for optimized component lifecycle management
mixin OptimizedLifecycleMixin<T extends StatefulWidget> on State<T> {
  String get componentId;
  Duration get disposeDelay => const Duration(seconds: 30);
  
  @override
  void initState() {
    super.initState();
    ComponentLifecycleOptimizer().registerComponent(
      componentId,
      onDispose: onComponentDispose,
      disposeDelay: disposeDelay,
    );
  }
  
  @override
  void dispose() {
    ComponentLifecycleOptimizer().unregisterComponent(componentId);
    super.dispose();
  }
  
  /// Called when component is being disposed by the optimizer
  void onComponentDispose() {
    // Override in subclasses to handle cleanup
  }
  
  /// Mark this component as inactive
  void markInactive() {
    ComponentLifecycleOptimizer().markComponentInactive(componentId);
  }
  
  /// Mark this component as active
  void markActive() {
    ComponentLifecycleOptimizer().markComponentActive(componentId);
  }
}

/// Optimized stateful widget with automatic lifecycle management
abstract class OptimizedStatefulWidget extends StatefulWidget {
  const OptimizedStatefulWidget({super.key});
  
  String get componentId;
  Duration get disposeDelay => const Duration(seconds: 30);
}

/// Base state class for optimized widgets
abstract class OptimizedState<T extends OptimizedStatefulWidget> extends State<T>
    with OptimizedLifecycleMixin<T> {
  
  @override
  String get componentId => widget.componentId;
  
  @override
  Duration get disposeDelay => widget.disposeDelay;
}

/// Memory-efficient list view with automatic item disposal
class OptimizedListView extends StatefulWidget {
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final ScrollController? controller;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final Axis scrollDirection;
  
  const OptimizedListView({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.scrollDirection = Axis.vertical,
  });
  
  @override
  State<OptimizedListView> createState() => _OptimizedListViewState();
}

class _OptimizedListViewState extends State<OptimizedListView> {
  final Set<int> _visibleItems = {};
  final Map<int, Widget> _itemCache = {};
  static const int _maxCacheSize = 20;
  
  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: ListView.builder(
        controller: widget.controller,
        padding: widget.padding,
        shrinkWrap: widget.shrinkWrap,
        scrollDirection: widget.scrollDirection,
        itemCount: widget.itemCount,
        itemBuilder: _buildOptimizedItem,
        cacheExtent: 250.0,
        addRepaintBoundaries: true,
      ),
    );
  }
  
  Widget _buildOptimizedItem(BuildContext context, int index) {
    // Use cached widget if available
    if (_itemCache.containsKey(index)) {
      return _itemCache[index]!;
    }
    
    // Build new widget
    final item = RepaintBoundary(
      child: widget.itemBuilder(context, index),
    );
    
    // Cache the widget
    _itemCache[index] = item;
    
    // Limit cache size
    if (_itemCache.length > _maxCacheSize) {
      final oldestKey = _itemCache.keys.first;
      _itemCache.remove(oldestKey);
    }
    
    return item;
  }
  
  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      _updateVisibleItems();
    }
    return false;
  }
  
  void _updateVisibleItems() {
    // This is a simplified implementation
    // In a real app, you'd calculate which items are actually visible
    final controller = widget.controller;
    if (controller != null && controller.hasClients) {
      final scrollOffset = controller.offset;
      final viewportHeight = controller.position.viewportDimension;
      
      // Estimate visible items (simplified)
      final startIndex = (scrollOffset / 100).floor().clamp(0, widget.itemCount - 1);
      final endIndex = ((scrollOffset + viewportHeight) / 100).ceil().clamp(0, widget.itemCount - 1);
      
      _visibleItems.clear();
      for (int i = startIndex; i <= endIndex; i++) {
        _visibleItems.add(i);
      }
    }
  }
}

/// Optimized grid view with automatic item disposal
class OptimizedGridView extends StatefulWidget {
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final SliverGridDelegate gridDelegate;
  final ScrollController? controller;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  
  const OptimizedGridView({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
    required this.gridDelegate,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
  });
  
  @override
  State<OptimizedGridView> createState() => _OptimizedGridViewState();
}

class _OptimizedGridViewState extends State<OptimizedGridView> {
  final Map<int, Widget> _itemCache = {};
  static const int _maxCacheSize = 30;
  
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: widget.controller,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      gridDelegate: widget.gridDelegate,
      itemCount: widget.itemCount,
      itemBuilder: _buildOptimizedItem,
      cacheExtent: 250.0,
      addRepaintBoundaries: true,
    );
  }
  
  Widget _buildOptimizedItem(BuildContext context, int index) {
    if (_itemCache.containsKey(index)) {
      return _itemCache[index]!;
    }
    
    final item = RepaintBoundary(
      child: widget.itemBuilder(context, index),
    );
    
    _itemCache[index] = item;
    
    if (_itemCache.length > _maxCacheSize) {
      final oldestKey = _itemCache.keys.first;
      _itemCache.remove(oldestKey);
    }
    
    return item;
  }
}

/// Component lifecycle data
class ComponentLifecycleData {
  final String id;
  final DateTime createdAt;
  final VoidCallback? onDispose;
  final Duration disposeDelay;
  bool isInactive;
  DateTime? inactiveAt;
  
  ComponentLifecycleData({
    required this.id,
    required this.createdAt,
    this.onDispose,
    required this.disposeDelay,
    this.isInactive = false,
    this.inactiveAt,
  });
}

/// Component lifecycle statistics
class ComponentLifecycleStatistics {
  final int totalComponents;
  final int activeComponents;
  final int inactiveComponents;
  final int pendingDisposal;
  
  const ComponentLifecycleStatistics({
    required this.totalComponents,
    required this.activeComponents,
    required this.inactiveComponents,
    required this.pendingDisposal,
  });
  
  @override
  String toString() {
    return 'ComponentLifecycleStatistics('
           'total: $totalComponents, '
           'active: $activeComponents, '
           'inactive: $inactiveComponents, '
           'pending: $pendingDisposal)';
  }
}