import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'storage_usage_overview.dart';
import 'detailed_statistics_panel.dart';
import 'statistics_refresh_controller.dart';
import '../providers/storage_providers.dart';
import '../../../shared/utils/logger.dart';

/// Main storage statistics dashboard that combines all statistics components
class StorageStatisticsDashboard extends ConsumerStatefulWidget {
  const StorageStatisticsDashboard({super.key});

  @override
  ConsumerState<StorageStatisticsDashboard> createState() => _StorageStatisticsDashboardState();
}

class _StorageStatisticsDashboardState extends ConsumerState<StorageStatisticsDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showAllBuckets = true;
  bool _enableAutoRefresh = true;
  Duration _autoRefreshInterval = const Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Logger.info('Storage statistics dashboard initialized');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedBucketId = ref.watch(selectedBucketProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage Statistics Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.dashboard),
              text: 'Overview',
            ),
            Tab(
              icon: Icon(Icons.analytics),
              text: 'Detailed Stats',
            ),
            Tab(
              icon: Icon(Icons.settings),
              text: 'Settings',
            ),
          ],
        ),
        actions: [
          // View mode toggle
          IconButton(
            icon: Icon(_showAllBuckets ? Icons.folder_open : Icons.folder),
            onPressed: () {
              setState(() {
                _showAllBuckets = !_showAllBuckets;
              });
            },
            tooltip: _showAllBuckets ? 'Show Selected Bucket' : 'Show All Buckets',
          ),
          
          // Auto-refresh toggle
          IconButton(
            icon: Icon(_enableAutoRefresh ? Icons.sync : Icons.sync_disabled),
            onPressed: () {
              setState(() {
                _enableAutoRefresh = !_enableAutoRefresh;
              });
            },
            tooltip: _enableAutoRefresh ? 'Disable Auto-Refresh' : 'Enable Auto-Refresh',
          ),
        ],
      ),
      body: StatisticsRefreshController(
        enableAutoRefresh: _enableAutoRefresh,
        autoRefreshInterval: _autoRefreshInterval,
        specificBuckets: _showAllBuckets ? null : (selectedBucketId != null ? [selectedBucketId] : null),
        child: TabBarView(
          controller: _tabController,
          children: [
            // Overview tab
            _buildOverviewTab(),
            
            // Detailed statistics tab
            _buildDetailedStatsTab(),
            
            // Settings tab
            _buildSettingsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page header
          _buildPageHeader('Storage Overview', 'Comprehensive view of storage usage and statistics'),
          
          const SizedBox(height: 16),
          
          // Storage usage overview
          const StorageUsageOverview(),
          
          const SizedBox(height: 16),
          
          // Quick stats cards
          _buildQuickStatsCards(),
        ],
      ),
    );
  }

  Widget _buildDetailedStatsTab() {
    final selectedBucketId = ref.watch(selectedBucketProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page header
          _buildPageHeader(
            'Detailed Statistics',
            _showAllBuckets 
                ? 'Comprehensive statistics for all storage buckets'
                : selectedBucketId != null 
                    ? 'Detailed statistics for bucket: $selectedBucketId'
                    : 'Select a bucket to view detailed statistics',
          ),
          
          const SizedBox(height: 16),
          
          // Detailed statistics panel
          DetailedStatisticsPanel(
            bucketId: _showAllBuckets ? null : selectedBucketId,
            showAllBuckets: _showAllBuckets,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page header
          _buildPageHeader('Statistics Settings', 'Configure refresh intervals, caching, and display options'),
          
          const SizedBox(height: 16),
          
          // Refresh settings
          _buildRefreshSettings(),
          
          const SizedBox(height: 16),
          
          // Display settings
          _buildDisplaySettings(),
          
          const SizedBox(height: 16),
          
          // Cache statistics
          const CacheStatisticsWidget(),
          
          const SizedBox(height: 16),
          
          // Export settings
          _buildExportSettings(),
        ],
      ),
    );
  }

  Widget _buildPageHeader(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.analytics,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsCards() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Statistics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            // Quick stats grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _buildQuickStatCard(
                  'Total Buckets',
                  'Loading...',
                  Icons.folder,
                  Colors.blue,
                ),
                _buildQuickStatCard(
                  'Total Files',
                  'Loading...',
                  Icons.description,
                  Colors.green,
                ),
                _buildQuickStatCard(
                  'Total Storage',
                  'Loading...',
                  Icons.storage,
                  Colors.orange,
                ),
                _buildQuickStatCard(
                  'Avg File Size',
                  'Loading...',
                  Icons.analytics,
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefreshSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Refresh Settings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            // Auto-refresh toggle
            SwitchListTile(
              title: const Text('Enable Auto-Refresh'),
              subtitle: const Text('Automatically refresh statistics at regular intervals'),
              value: _enableAutoRefresh,
              onChanged: (value) {
                setState(() {
                  _enableAutoRefresh = value;
                });
              },
            ),
            
            // Refresh interval selector
            if (_enableAutoRefresh) ...[
              const Divider(),
              ListTile(
                title: const Text('Refresh Interval'),
                subtitle: Text('Current: ${_formatDuration(_autoRefreshInterval)}'),
                trailing: DropdownButton<Duration>(
                  value: _autoRefreshInterval,
                  items: const [
                    DropdownMenuItem(
                      value: Duration(minutes: 1),
                      child: Text('1 minute'),
                    ),
                    DropdownMenuItem(
                      value: Duration(minutes: 5),
                      child: Text('5 minutes'),
                    ),
                    DropdownMenuItem(
                      value: Duration(minutes: 10),
                      child: Text('10 minutes'),
                    ),
                    DropdownMenuItem(
                      value: Duration(minutes: 30),
                      child: Text('30 minutes'),
                    ),
                    DropdownMenuItem(
                      value: Duration(hours: 1),
                      child: Text('1 hour'),
                    ),
                  ],
                  onChanged: (Duration? newInterval) {
                    if (newInterval != null) {
                      setState(() {
                        _autoRefreshInterval = newInterval;
                      });
                    }
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDisplaySettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Display Settings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            // Show all buckets toggle
            SwitchListTile(
              title: const Text('Show All Buckets'),
              subtitle: const Text('Display statistics for all buckets or selected bucket only'),
              value: _showAllBuckets,
              onChanged: (value) {
                setState(() {
                  _showAllBuckets = value;
                });
              },
            ),
            
            const Divider(),
            
            // Additional display options
            ListTile(
              title: const Text('Chart Type'),
              subtitle: const Text('Pie charts and bar charts'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // TODO: Implement chart type selection
              },
            ),
            
            ListTile(
              title: const Text('Number Format'),
              subtitle: const Text('Decimal places and units'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // TODO: Implement number format settings
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export & Reports',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text('Export CSV'),
                    onPressed: () => _exportStatistics('csv'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Export PDF'),
                    onPressed: () => _exportStatistics('pdf'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            OutlinedButton.icon(
              icon: const Icon(Icons.schedule),
              label: const Text('Schedule Reports'),
              onPressed: () => _scheduleReports(),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}';
    } else {
      return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
    }
  }

  void _exportStatistics(String format) {
    try {
      Logger.info('Exporting statistics in $format format');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exporting statistics as $format...'),
          duration: const Duration(seconds: 2),
        ),
      );
      
      // TODO: Implement actual export functionality
      
      Logger.info('Statistics export initiated');
    } catch (e) {
      Logger.error('Failed to export statistics', e);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export statistics: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _scheduleReports() {
    try {
      Logger.info('Opening report scheduling dialog');
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Schedule Reports'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Report scheduling will be available in a future update.'),
              SizedBox(height: 16),
              Text('Features will include:'),
              SizedBox(height: 8),
              Text('• Daily, weekly, monthly reports'),
              Text('• Email delivery'),
              Text('• Custom report templates'),
              Text('• Automated insights'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
      
      Logger.info('Report scheduling dialog opened');
    } catch (e) {
      Logger.error('Failed to open report scheduling dialog', e);
    }
  }
}