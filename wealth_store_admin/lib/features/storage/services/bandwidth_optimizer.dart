import 'dart:async';
import 'dart:math' as math;
import '../constants/storage_constants.dart';
import '../../../shared/utils/logger.dart';

/// Service for optimizing bandwidth usage during uploads and downloads
class BandwidthOptimizer {
  // Network monitoring
  final List<_NetworkSample> _networkSamples = [];
  final List<_TransferSample> _transferSamples = [];
  
  // Current settings
  int _currentChunkSize = StorageConstants.uploadChunkSize;
  int _currentConcurrentTransfers = StorageConstants.maxConcurrentUploads;
  Duration _currentRetryDelay = const Duration(seconds: 2);
  
  // Configuration
  static const int maxNetworkSamples = 50;
  static const int maxTransferSamples = 100;
  static const Duration samplingInterval = Duration(seconds: 1);
  static const Duration optimizationInterval = Duration(seconds: 10);
  
  // Bandwidth thresholds (bytes per second)
  static const int slowConnectionThreshold = 100 * 1024; // 100 KB/s
  static const int fastConnectionThreshold = 5 * 1024 * 1024; // 5 MB/s
  
  // Optimization parameters
  static const int minChunkSize = 64 * 1024; // 64 KB
  static const int maxChunkSize = 10 * 1024 * 1024; // 10 MB
  static const int minConcurrentTransfers = 1;
  static const int maxConcurrentTransfers = 8;
  
  Timer? _monitoringTimer;
  Timer? _optimizationTimer;
  bool _isOptimizing = false;

  /// Start bandwidth monitoring and optimization
  void startOptimization() {
    if (_monitoringTimer != null) return;
    
    _monitoringTimer = Timer.periodic(samplingInterval, (_) {
      _collectNetworkSample();
    });
    
    _optimizationTimer = Timer.periodic(optimizationInterval, (_) {
      _optimizeSettings();
    });
    
    Logger.info('Started bandwidth optimization');
  }

  /// Stop bandwidth monitoring and optimization
  void stopOptimization() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    
    _optimizationTimer?.cancel();
    _optimizationTimer = null;
    
    Logger.info('Stopped bandwidth optimization');
  }

  /// Record a transfer sample for optimization
  void recordTransfer({
    required TransferType type,
    required int bytesTransferred,
    required Duration duration,
    required int chunkSize,
    required int concurrentTransfers,
    bool successful = true,
  }) {
    final sample = _TransferSample(
      timestamp: DateTime.now(),
      type: type,
      bytesTransferred: bytesTransferred,
      duration: duration,
      chunkSize: chunkSize,
      concurrentTransfers: concurrentTransfers,
      successful: successful,
    );
    
    _transferSamples.add(sample);
    
    // Keep only recent samples
    if (_transferSamples.length > maxTransferSamples) {
      _transferSamples.removeAt(0);
    }
    
    Logger.debug('Recorded transfer sample: ${sample.speed.toStringAsFixed(0)} B/s');
  }

  /// Get optimized chunk size for current network conditions
  int getOptimizedChunkSize() {
    return _currentChunkSize;
  }

  /// Get optimized number of concurrent transfers
  int getOptimizedConcurrentTransfers() {
    return _currentConcurrentTransfers;
  }

  /// Get optimized retry delay
  Duration getOptimizedRetryDelay() {
    return _currentRetryDelay;
  }

  /// Get current network quality assessment
  NetworkQuality getNetworkQuality() {
    if (_networkSamples.isEmpty) return NetworkQuality.unknown;
    
    final recentSamples = _networkSamples
        .where((sample) => DateTime.now().difference(sample.timestamp) < const Duration(minutes: 1))
        .toList();
    
    if (recentSamples.isEmpty) return NetworkQuality.unknown;
    
    final averageSpeed = recentSamples
        .map((sample) => sample.estimatedBandwidth)
        .reduce((a, b) => a + b) / recentSamples.length;
    
    final packetLoss = recentSamples
        .map((sample) => sample.packetLoss)
        .reduce((a, b) => a + b) / recentSamples.length;
    
    final latency = recentSamples
        .map((sample) => sample.latency.inMilliseconds)
        .reduce((a, b) => a + b) / recentSamples.length;
    
    // Determine quality based on metrics
    if (averageSpeed > fastConnectionThreshold && packetLoss < 0.01 && latency < 50) {
      return NetworkQuality.excellent;
    } else if (averageSpeed > fastConnectionThreshold / 2 && packetLoss < 0.05 && latency < 100) {
      return NetworkQuality.good;
    } else if (averageSpeed > slowConnectionThreshold && packetLoss < 0.1 && latency < 200) {
      return NetworkQuality.fair;
    } else {
      return NetworkQuality.poor;
    }
  }

  /// Get bandwidth optimization statistics
  BandwidthStats getStats() {
    final networkQuality = getNetworkQuality();
    final recentTransfers = _transferSamples
        .where((sample) => DateTime.now().difference(sample.timestamp) < const Duration(minutes: 5))
        .toList();
    
    final averageSpeed = recentTransfers.isNotEmpty
        ? recentTransfers.map((s) => s.speed).reduce((a, b) => a + b) / recentTransfers.length
        : 0.0;
    
    final successRate = recentTransfers.isNotEmpty
        ? recentTransfers.where((s) => s.successful).length / recentTransfers.length
        : 0.0;
    
    return BandwidthStats(
      networkQuality: networkQuality,
      averageSpeed: averageSpeed,
      successRate: successRate,
      currentChunkSize: _currentChunkSize,
      currentConcurrentTransfers: _currentConcurrentTransfers,
      totalSamples: _transferSamples.length,
    );
  }

  /// Collect network sample (simulated)
  void _collectNetworkSample() {
    // In a real implementation, this would measure actual network conditions
    // For now, we'll simulate network conditions
    
    final sample = _NetworkSample(
      timestamp: DateTime.now(),
      estimatedBandwidth: _simulateNetworkSpeed(),
      latency: Duration(milliseconds: _simulateLatency()),
      packetLoss: _simulatePacketLoss(),
    );
    
    _networkSamples.add(sample);
    
    // Keep only recent samples
    if (_networkSamples.length > maxNetworkSamples) {
      _networkSamples.removeAt(0);
    }
  }

  /// Optimize transfer settings based on collected data
  void _optimizeSettings() {
    if (_isOptimizing || _transferSamples.isEmpty) return;
    
    _isOptimizing = true;
    
    try {
      final networkQuality = getNetworkQuality();
      final recentTransfers = _transferSamples
          .where((sample) => DateTime.now().difference(sample.timestamp) < const Duration(minutes: 2))
          .toList();
      
      if (recentTransfers.isEmpty) return;
      
      // Optimize chunk size
      _optimizeChunkSize(networkQuality, recentTransfers);
      
      // Optimize concurrent transfers
      _optimizeConcurrentTransfers(networkQuality, recentTransfers);
      
      // Optimize retry delay
      _optimizeRetryDelay(networkQuality, recentTransfers);
      
      Logger.info('Optimized settings: chunk=${_currentChunkSize}, concurrent=${_currentConcurrentTransfers}, retry=${_currentRetryDelay.inSeconds}s');
      
    } finally {
      _isOptimizing = false;
    }
  }

  /// Optimize chunk size based on network conditions
  void _optimizeChunkSize(NetworkQuality quality, List<_TransferSample> samples) {
    switch (quality) {
      case NetworkQuality.excellent:
        // Use larger chunks for fast connections
        _currentChunkSize = math.min(maxChunkSize, _currentChunkSize * 2);
        break;
        
      case NetworkQuality.good:
        // Moderate chunk size
        _currentChunkSize = math.min(maxChunkSize, StorageConstants.uploadChunkSize * 2);
        break;
        
      case NetworkQuality.fair:
        // Standard chunk size
        _currentChunkSize = StorageConstants.uploadChunkSize;
        break;
        
      case NetworkQuality.poor:
        // Use smaller chunks for slow/unreliable connections
        _currentChunkSize = math.max(minChunkSize, _currentChunkSize ~/ 2);
        break;
        
      case NetworkQuality.unknown:
        // Keep current settings
        break;
    }
    
    // Analyze transfer success rates by chunk size
    final chunkSizeGroups = <int, List<_TransferSample>>{};
    for (final sample in samples) {
      chunkSizeGroups.putIfAbsent(sample.chunkSize, () => []).add(sample);
    }
    
    // Find the chunk size with the best success rate and speed
    double bestScore = 0.0;
    int bestChunkSize = _currentChunkSize;
    
    for (final entry in chunkSizeGroups.entries) {
      final chunkSize = entry.key;
      final chunkSamples = entry.value;
      
      if (chunkSamples.length < 3) continue; // Need enough samples
      
      final successRate = chunkSamples.where((s) => s.successful).length / chunkSamples.length;
      final averageSpeed = chunkSamples.map((s) => s.speed).reduce((a, b) => a + b) / chunkSamples.length;
      
      // Score combines success rate and speed
      final score = successRate * averageSpeed;
      
      if (score > bestScore) {
        bestScore = score;
        bestChunkSize = chunkSize;
      }
    }
    
    // Gradually adjust towards the best chunk size
    if (bestChunkSize != _currentChunkSize) {
      final adjustment = (bestChunkSize - _currentChunkSize) ~/ 4;
      _currentChunkSize = (_currentChunkSize + adjustment).clamp(minChunkSize, maxChunkSize);
    }
  }

  /// Optimize concurrent transfers based on network conditions
  void _optimizeConcurrentTransfers(NetworkQuality quality, List<_TransferSample> samples) {
    switch (quality) {
      case NetworkQuality.excellent:
        _currentConcurrentTransfers = math.min(maxConcurrentTransfers, _currentConcurrentTransfers + 1);
        break;
        
      case NetworkQuality.good:
        _currentConcurrentTransfers = StorageConstants.maxConcurrentUploads;
        break;
        
      case NetworkQuality.fair:
        _currentConcurrentTransfers = math.max(minConcurrentTransfers, StorageConstants.maxConcurrentUploads - 1);
        break;
        
      case NetworkQuality.poor:
        _currentConcurrentTransfers = minConcurrentTransfers;
        break;
        
      case NetworkQuality.unknown:
        // Keep current settings
        break;
    }
    
    // Analyze success rates by concurrent transfer count
    final concurrencyGroups = <int, List<_TransferSample>>{};
    for (final sample in samples) {
      concurrencyGroups.putIfAbsent(sample.concurrentTransfers, () => []).add(sample);
    }
    
    // Find the concurrency level with the best overall performance
    double bestScore = 0.0;
    int bestConcurrency = _currentConcurrentTransfers;
    
    for (final entry in concurrencyGroups.entries) {
      final concurrency = entry.key;
      final concurrencySamples = entry.value;
      
      if (concurrencySamples.length < 3) continue;
      
      final successRate = concurrencySamples.where((s) => s.successful).length / concurrencySamples.length;
      final averageSpeed = concurrencySamples.map((s) => s.speed).reduce((a, b) => a + b) / concurrencySamples.length;
      
      // Score considers both success rate and total throughput
      final score = successRate * averageSpeed * concurrency;
      
      if (score > bestScore) {
        bestScore = score;
        bestConcurrency = concurrency;
      }
    }
    
    // Gradually adjust towards the best concurrency level
    if (bestConcurrency != _currentConcurrentTransfers) {
      if (bestConcurrency > _currentConcurrentTransfers) {
        _currentConcurrentTransfers = math.min(_currentConcurrentTransfers + 1, maxConcurrentTransfers);
      } else {
        _currentConcurrentTransfers = math.max(_currentConcurrentTransfers - 1, minConcurrentTransfers);
      }
    }
  }

  /// Optimize retry delay based on network conditions
  void _optimizeRetryDelay(NetworkQuality quality, List<_TransferSample> samples) {
    switch (quality) {
      case NetworkQuality.excellent:
      case NetworkQuality.good:
        _currentRetryDelay = const Duration(seconds: 1);
        break;
        
      case NetworkQuality.fair:
        _currentRetryDelay = const Duration(seconds: 2);
        break;
        
      case NetworkQuality.poor:
        _currentRetryDelay = const Duration(seconds: 5);
        break;
        
      case NetworkQuality.unknown:
        _currentRetryDelay = const Duration(seconds: 2);
        break;
    }
  }

  /// Simulate network speed (replace with actual measurement)
  double _simulateNetworkSpeed() {
    // Simulate varying network conditions
    final random = math.Random();
    final baseSpeed = 2 * 1024 * 1024; // 2 MB/s base
    final variation = random.nextDouble() * 0.5 + 0.75; // 75% to 125% of base
    return baseSpeed * variation;
  }

  /// Simulate network latency (replace with actual measurement)
  int _simulateLatency() {
    final random = math.Random();
    return 20 + random.nextInt(80); // 20-100ms
  }

  /// Simulate packet loss (replace with actual measurement)
  double _simulatePacketLoss() {
    final random = math.Random();
    return random.nextDouble() * 0.02; // 0-2% packet loss
  }

  /// Dispose resources
  void dispose() {
    stopOptimization();
    _networkSamples.clear();
    _transferSamples.clear();
  }
}

/// Network sample data class
class _NetworkSample {
  final DateTime timestamp;
  final double estimatedBandwidth; // bytes per second
  final Duration latency;
  final double packetLoss; // 0.0 to 1.0

  _NetworkSample({
    required this.timestamp,
    required this.estimatedBandwidth,
    required this.latency,
    required this.packetLoss,
  });
}

/// Transfer sample data class
class _TransferSample {
  final DateTime timestamp;
  final TransferType type;
  final int bytesTransferred;
  final Duration duration;
  final int chunkSize;
  final int concurrentTransfers;
  final bool successful;

  _TransferSample({
    required this.timestamp,
    required this.type,
    required this.bytesTransferred,
    required this.duration,
    required this.chunkSize,
    required this.concurrentTransfers,
    required this.successful,
  });

  /// Get transfer speed in bytes per second
  double get speed {
    final seconds = duration.inMilliseconds / 1000.0;
    return seconds > 0 ? bytesTransferred / seconds : 0.0;
  }
}

/// Transfer type enumeration
enum TransferType {
  upload,
  download,
}

/// Network quality levels
enum NetworkQuality {
  unknown,
  poor,
  fair,
  good,
  excellent,
}

/// Bandwidth optimization statistics
class BandwidthStats {
  final NetworkQuality networkQuality;
  final double averageSpeed; // bytes per second
  final double successRate; // 0.0 to 1.0
  final int currentChunkSize;
  final int currentConcurrentTransfers;
  final int totalSamples;

  const BandwidthStats({
    required this.networkQuality,
    required this.averageSpeed,
    required this.successRate,
    required this.currentChunkSize,
    required this.currentConcurrentTransfers,
    required this.totalSamples,
  });

  /// Get formatted average speed
  String get formattedAverageSpeed {
    if (averageSpeed < 1024) {
      return '${averageSpeed.toStringAsFixed(0)} B/s';
    } else if (averageSpeed < 1024 * 1024) {
      return '${(averageSpeed / 1024).toStringAsFixed(1)} KB/s';
    } else {
      return '${(averageSpeed / (1024 * 1024)).toStringAsFixed(1)} MB/s';
    }
  }

  /// Get formatted success rate
  String get formattedSuccessRate {
    return '${(successRate * 100).toStringAsFixed(1)}%';
  }

  @override
  String toString() {
    return 'BandwidthStats(quality: $networkQuality, speed: $formattedAverageSpeed, '
           'success: $formattedSuccessRate, samples: $totalSamples)';
  }
}