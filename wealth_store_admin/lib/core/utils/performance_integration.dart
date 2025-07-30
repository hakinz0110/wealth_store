import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../services/performance_service.dart';

/// Integration class for admin app performance optimization
class PerformanceIntegration {
  static final PerformanceIntegration _instance = PerformanceIntegration._internal();
  factory PerformanceIntegration() => _instance;
  PerformanceIntegration._internal();
  
  late final PerformanceService _performanceService;
  
  /// Initialize performance systems
  void initialize(WidgetRef ref) {
    _performanceService = ref.read(performanceServiceProvider);
  }
  
  /// Monitor CRUD operation performance
  void monitorCrudOperation(String entity, String operation, Future<dynamic> request) {
    _performanceService.monitorCrudOperation(entity, operation, request);
  }
  
  /// Monitor data table performance
  void monitorDataTableRender(String tableName, int rowCount) {
    _performanceService.monitorDataTableRender(tableName, rowCount);
  }
  
  /// Monitor file upload performance
  void monitorFileUpload(String fileName, int fileSize, Future<dynamic> upload) {
    _performanceService.monitorFileUpload(fileName, fileSize, upload);
  }
  
  /// Monitor search performance
  void monitorSearch(String searchType, String query, Future<dynamic> search) {
    _performanceService.monitorSearch(searchType, query, search);
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
    String? debugLabel,
  }) {
    if (enableRepaintBoundary) {
      return RepaintBoundary(child: child);
    }
    return child;
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
    return ListView.builder(
      controller: controller,
      scrollDirection: scrollDirection,
      shrinkWrap: shrinkWrap,
      padding: padding,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: itemBuilder(context, index),
        );
      },
      cacheExtent: 250.0,
      addRepaintBoundaries: true,
      addAutomaticKeepAlives: false,
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
      addAutomaticKeepAlives: false,
    );
  }
  
  /// Get performance statistics
  Map<String, dynamic> getPerformanceStatistics() {
    return _performanceService.getPerformanceSummary();
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

/// Performance monitoring mixin for admin widgets
mixin AdminPerformanceMonitorMixin<T extends StatefulWidget> on State<T> {
  String get performanceId => runtimeType.toString();
  
  /// Monitor CRUD operation
  void monitorCrud(String entity, String operation, Future<dynamic> request) {
    PerformanceIntegration().monitorCrudOperation(entity, operation, request);
  }
  
  /// Monitor data table render
  void monitorTable(String tableName, int rowCount) {
    PerformanceIntegration().monitorDataTableRender(tableName, rowCount);
  }
  
  /// Monitor file upload
  void monitorUpload(String fileName, int fileSize, Future<dynamic> upload) {
    PerformanceIntegration().monitorFileUpload(fileName, fileSize, upload);
  }
}