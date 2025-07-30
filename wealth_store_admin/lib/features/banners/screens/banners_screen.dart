import 'package:flutter/material.dart';
import '../../../shared/widgets/admin_layout.dart';
import '../../../models/banner_models.dart' as banner_models;
import '../../../services/banner_service.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../widgets/add_banner_dialog.dart';
import '../widgets/edit_banner_dialog.dart';
import '../widgets/banner_card.dart';

class BannersScreen extends StatefulWidget {
  const BannersScreen({super.key});

  @override
  State<BannersScreen> createState() => _BannersScreenState();
}

class _BannersScreenState extends State<BannersScreen> {
  final BannerService _bannerService = BannerService();
  List<banner_models.Banner> _banners = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBanners();
  }

  Future<void> _loadBanners() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final banners = await _bannerService.getBanners();
      setState(() {
        _banners = banners;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addBanner() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const AddBannerDialog(),
    );

    if (result == true) {
      await _loadBanners();
    }
  }

  Future<void> _editBanner(banner_models.Banner banner) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => EditBannerDialog(banner: banner),
    );

    if (result == true) {
      await _loadBanners();
    }
  }

  Future<void> _deleteBanner(banner_models.Banner banner) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Banner'),
        content: Text('Are you sure you want to delete "${banner.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _bannerService.deleteBanner(banner.id);
        await _loadBanners();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Banner deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting banner: $e')),
          );
        }
      }
    }
  }

  Future<void> _toggleBannerStatus(banner_models.Banner banner) async {
    try {
      await _bannerService.toggleBannerStatus(banner.id);
      await _loadBanners();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              banner.isActive 
                  ? 'Banner deactivated successfully' 
                  : 'Banner activated successfully'
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating banner: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Banners',
      currentRoute: '/banners',
      breadcrumbs: const ['Dashboard', 'Banners'],
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Manage Homepage Banners',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _addBanner,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Banner'),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Loading banners...');
    }

    if (_error != null) {
      return ErrorDisplayWidget(
        error: _error!,
        onRetry: _loadBanners,
      );
    }

    if (_banners.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No banners found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first banner to showcase on the homepage',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addBanner,
              icon: const Icon(Icons.add),
              label: const Text('Add Banner'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  '${_banners.length} total banners, ${_banners.where((b) => b.isActive).length} active',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Banners Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return BannerCard(
                banner: banner,
                onEdit: () => _editBanner(banner),
                onDelete: () => _deleteBanner(banner),
                onToggleStatus: () => _toggleBannerStatus(banner),
              );
            },
          ),
        ],
      ),
    );
  }
}