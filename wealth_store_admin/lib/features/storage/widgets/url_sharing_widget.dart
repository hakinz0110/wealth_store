import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/storage_models.dart';
import '../services/url_manager.dart';
import '../constants/storage_constants.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/utils/logger.dart';

/// Widget for sharing file URLs with various options
class UrlSharingWidget extends HookConsumerWidget {
  final StorageFile file;
  final VoidCallback? onClose;

  const UrlSharingWidget({
    super.key,
    required this.file,
    this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = useState(0);
    final isGenerating = useState(false);
    final generatedUrl = useState<String?>(null);
    final shareData = useState<Map<String, dynamic>?>(null);
    final copySuccessMessage = useState<String?>(null);
    
    // Form states for secure sharing
    final expirationDuration = useState<Duration?>(null);
    final requireAuth = useState(false);
    final maxDownloads = useState<int?>(null);
    final allowedDomains = useState<List<String>>([]);
    final includeMetadata = useState(true);
    
    // Auto-hide success message after 3 seconds
    useEffect(() {
      if (copySuccessMessage.value != null) {
        final timer = Future.delayed(const Duration(seconds: 3), () {
          copySuccessMessage.value = null;
        });
        return () => timer.ignore();
      }
      return null;
    }, [copySuccessMessage.value]);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600,
        constraints: const BoxConstraints(
          maxWidth: 600,
          maxHeight: 700,
        ),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            
            // Tab bar
            _buildTabBar(selectedTab.value, (index) => selectedTab.value = index),
            
            // Content
            Expanded(
              child: _buildTabContent(
                context,
                selectedTab.value,
                isGenerating.value,
                generatedUrl.value,
                shareData.value,
                copySuccessMessage.value,
                expirationDuration.value,
                requireAuth.value,
                maxDownloads.value,
                allowedDomains.value,
                includeMetadata.value,
                (generating) => isGenerating.value = generating,
                (url) => generatedUrl.value = url,
                (data) => shareData.value = data,
                (message) => copySuccessMessage.value = message,
                (duration) => expirationDuration.value = duration,
                (auth) => requireAuth.value = auth,
                (downloads) => maxDownloads.value = downloads,
                (domains) => allowedDomains.value = domains,
                (metadata) => includeMetadata.value = metadata,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.share,
            size: 24,
            color: AppColors.primaryBlue,
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Share File',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  file.name,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close),
            color: AppColors.textSecondary,
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(int selectedTab, Function(int) onTabChanged) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildTab('Public URL', 0, selectedTab, onTabChanged),
          _buildTab('Secure Share', 1, selectedTab, onTabChanged),
          _buildTab('Download Link', 2, selectedTab, onTabChanged),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index, int selectedTab, Function(int) onTabChanged) {
    final isSelected = selectedTab == index;
    
    return Expanded(
      child: InkWell(
        onTap: () => onTabChanged(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(
    BuildContext context,
    int selectedTab,
    bool isGenerating,
    String? generatedUrl,
    Map<String, dynamic>? shareData,
    String? copySuccessMessage,
    Duration? expirationDuration,
    bool requireAuth,
    int? maxDownloads,
    List<String> allowedDomains,
    bool includeMetadata,
    Function(bool) setGenerating,
    Function(String?) setGeneratedUrl,
    Function(Map<String, dynamic>?) setShareData,
    Function(String?) setCopySuccessMessage,
    Function(Duration?) setExpirationDuration,
    Function(bool) setRequireAuth,
    Function(int?) setMaxDownloads,
    Function(List<String>) setAllowedDomains,
    Function(bool) setIncludeMetadata,
  ) {
    switch (selectedTab) {
      case 0:
        return _buildPublicUrlTab(
          context,
          copySuccessMessage,
          setCopySuccessMessage,
        );
      case 1:
        return _buildSecureShareTab(
          context,
          isGenerating,
          shareData,
          copySuccessMessage,
          expirationDuration,
          requireAuth,
          maxDownloads,
          allowedDomains,
          includeMetadata,
          setGenerating,
          setShareData,
          setCopySuccessMessage,
          setExpirationDuration,
          setRequireAuth,
          setMaxDownloads,
          setAllowedDomains,
          setIncludeMetadata,
        );
      case 2:
        return _buildDownloadLinkTab(
          context,
          generatedUrl,
          copySuccessMessage,
          setGeneratedUrl,
          setCopySuccessMessage,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPublicUrlTab(
    BuildContext context,
    String? copySuccessMessage,
    Function(String?) setCopySuccessMessage,
  ) {
    final publicUrl = file.publicUrl;
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Public URL',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 8),
          
          const Text(
            'This URL provides direct access to the file and never expires.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: 20),
          
          if (publicUrl != null && publicUrl.isNotEmpty) ...[
            // URL display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.borderLight,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'URL:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    publicUrl,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Copy button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _copyUrlToClipboard(
                  publicUrl,
                  setCopySuccessMessage,
                ),
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Copy Public URL'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.warning.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber,
                    color: AppColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'No public URL available for this file.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Success message
          if (copySuccessMessage != null) ...[
            const SizedBox(height: 16),
            _buildSuccessMessage(copySuccessMessage),
          ],
        ],
      ),
    );
  }

  Widget _buildSecureShareTab(
    BuildContext context,
    bool isGenerating,
    Map<String, dynamic>? shareData,
    String? copySuccessMessage,
    Duration? expirationDuration,
    bool requireAuth,
    int? maxDownloads,
    List<String> allowedDomains,
    bool includeMetadata,
    Function(bool) setGenerating,
    Function(Map<String, dynamic>?) setShareData,
    Function(String?) setCopySuccessMessage,
    Function(Duration?) setExpirationDuration,
    Function(bool) setRequireAuth,
    Function(int?) setMaxDownloads,
    Function(List<String>) setAllowedDomains,
    Function(bool) setIncludeMetadata,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Secure Share',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 8),
          
          const Text(
            'Generate a secure URL with expiration and access controls.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: 20),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Expiration settings
                  _buildExpirationSettings(expirationDuration, setExpirationDuration),
                  
                  const SizedBox(height: 20),
                  
                  // Authentication requirement
                  _buildAuthSettings(requireAuth, setRequireAuth),
                  
                  const SizedBox(height: 20),
                  
                  // Download limits
                  _buildDownloadLimitSettings(maxDownloads, setMaxDownloads),
                  
                  const SizedBox(height: 20),
                  
                  // Domain restrictions
                  _buildDomainSettings(allowedDomains, setAllowedDomains),
                  
                  const SizedBox(height: 20),
                  
                  // Metadata inclusion
                  _buildMetadataSettings(includeMetadata, setIncludeMetadata),
                  
                  const SizedBox(height: 24),
                  
                  // Generate button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isGenerating ? null : () => _generateSecureUrl(
                        expirationDuration,
                        requireAuth,
                        maxDownloads,
                        allowedDomains,
                        includeMetadata,
                        setGenerating,
                        setShareData,
                      ),
                      icon: isGenerating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.security, size: 18),
                      label: Text(isGenerating ? 'Generating...' : 'Generate Secure URL'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  
                  // Generated URL display
                  if (shareData != null) ...[
                    const SizedBox(height: 20),
                    _buildGeneratedUrlDisplay(shareData, setCopySuccessMessage),
                  ],
                  
                  // Success message
                  if (copySuccessMessage != null) ...[
                    const SizedBox(height: 16),
                    _buildSuccessMessage(copySuccessMessage),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadLinkTab(
    BuildContext context,
    String? generatedUrl,
    String? copySuccessMessage,
    Function(String?) setGeneratedUrl,
    Function(String?) setCopySuccessMessage,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Download Link',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 8),
          
          const Text(
            'Generate a direct download link that forces file download.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Generate download link button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _generateDownloadLink(setGeneratedUrl),
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Generate Download Link'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.info,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          
          // Generated download link display
          if (generatedUrl != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.borderLight,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Download URL:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    generatedUrl,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Copy download link button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _copyUrlToClipboard(
                  generatedUrl,
                  setCopySuccessMessage,
                ),
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Copy Download Link'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
          
          // Success message
          if (copySuccessMessage != null) ...[
            const SizedBox(height: 16),
            _buildSuccessMessage(copySuccessMessage),
          ],
        ],
      ),
    );
  }

  Widget _buildExpirationSettings(
    Duration? expirationDuration,
    Function(Duration?) setExpirationDuration,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Expiration',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildExpirationChip('1 Hour', const Duration(hours: 1), expirationDuration, setExpirationDuration),
            _buildExpirationChip('24 Hours', const Duration(hours: 24), expirationDuration, setExpirationDuration),
            _buildExpirationChip('7 Days', const Duration(days: 7), expirationDuration, setExpirationDuration),
            _buildExpirationChip('30 Days', const Duration(days: 30), expirationDuration, setExpirationDuration),
            _buildExpirationChip('Never', null, expirationDuration, setExpirationDuration),
          ],
        ),
      ],
    );
  }

  Widget _buildExpirationChip(
    String label,
    Duration? duration,
    Duration? selectedDuration,
    Function(Duration?) setExpirationDuration,
  ) {
    final isSelected = selectedDuration == duration;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => setExpirationDuration(selected ? duration : null),
      selectedColor: AppColors.primaryBlue.withOpacity(0.2),
      checkmarkColor: AppColors.primaryBlue,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
        fontSize: 12,
      ),
    );
  }

  Widget _buildAuthSettings(bool requireAuth, Function(bool) setRequireAuth) {
    return Row(
      children: [
        Checkbox(
          value: requireAuth,
          onChanged: (value) => setRequireAuth(value ?? false),
          activeColor: AppColors.primaryBlue,
        ),
        const Expanded(
          child: Text(
            'Require authentication to access',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadLimitSettings(int? maxDownloads, Function(int?) setMaxDownloads) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Download Limit',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Checkbox(
              value: maxDownloads != null,
              onChanged: (value) => setMaxDownloads(value == true ? 1 : null),
              activeColor: AppColors.primaryBlue,
            ),
            const Text(
              'Limit downloads to:',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            if (maxDownloads != null)
              SizedBox(
                width: 80,
                child: TextFormField(
                  initialValue: maxDownloads.toString(),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final downloads = int.tryParse(value);
                    if (downloads != null && downloads > 0) {
                      setMaxDownloads(downloads);
                    }
                  },
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildDomainSettings(List<String> allowedDomains, Function(List<String>) setAllowedDomains) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Domain Restrictions',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Restrict access to specific domains (optional)',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: const InputDecoration(
            hintText: 'example.com, another-domain.com',
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(),
          ),
          style: const TextStyle(fontSize: 14),
          onChanged: (value) {
            final domains = value
                .split(',')
                .map((d) => d.trim())
                .where((d) => d.isNotEmpty)
                .toList();
            setAllowedDomains(domains);
          },
        ),
      ],
    );
  }

  Widget _buildMetadataSettings(bool includeMetadata, Function(bool) setIncludeMetadata) {
    return Row(
      children: [
        Checkbox(
          value: includeMetadata,
          onChanged: (value) => setIncludeMetadata(value ?? true),
          activeColor: AppColors.primaryBlue,
        ),
        const Expanded(
          child: Text(
            'Include file metadata in share data',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGeneratedUrlDisplay(
    Map<String, dynamic> shareData,
    Function(String?) setCopySuccessMessage,
  ) {
    final url = shareData['url'] as String?;
    final isSecure = shareData['isSecure'] as bool? ?? false;
    final expiresAt = shareData['expiresAt'] as String?;
    final maxDownloads = shareData['maxDownloads'] as int?;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isSecure ? Icons.security : Icons.link,
                size: 16,
                color: isSecure ? AppColors.success : AppColors.info,
              ),
              const SizedBox(width: 8),
              Text(
                isSecure ? 'Secure Share URL' : 'Share URL',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSecure ? AppColors.success : AppColors.info,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          if (url != null) ...[
            SelectableText(
              url,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textPrimary,
                fontFamily: 'monospace',
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Share details
            if (expiresAt != null || maxDownloads != null) ...[
              const Divider(height: 1),
              const SizedBox(height: 12),
              
              if (expiresAt != null)
                _buildShareDetail('Expires', _formatExpirationDate(expiresAt)),
              
              if (maxDownloads != null)
                _buildShareDetail('Max Downloads', maxDownloads.toString()),
            ],
            
            const SizedBox(height: 12),
            
            // Copy button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _copyUrlToClipboard(url, setCopySuccessMessage),
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copy Secure URL'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShareDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: AppColors.success.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: AppColors.success,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.success,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copyUrlToClipboard(
    String url,
    Function(String?) setCopySuccessMessage,
  ) async {
    try {
      final success = await StorageUrlManager.copyUrlToClipboard(url);
      
      if (success) {
        setCopySuccessMessage('URL copied to clipboard successfully!');
        Logger.info('URL copied to clipboard successfully');
      } else {
        setCopySuccessMessage('Failed to copy URL to clipboard');
        Logger.error('Failed to copy URL to clipboard');
      }
    } catch (e) {
      setCopySuccessMessage('Failed to copy URL to clipboard');
      Logger.error('Error copying URL to clipboard', e);
    }
  }

  Future<void> _generateSecureUrl(
    Duration? expirationDuration,
    bool requireAuth,
    int? maxDownloads,
    List<String> allowedDomains,
    bool includeMetadata,
    Function(bool) setGenerating,
    Function(Map<String, dynamic>?) setShareData,
  ) async {
    setGenerating(true);
    
    try {
      final shareData = await StorageUrlManager.generateSecureShareableUrl(
        file,
        expiration: expirationDuration,
        includeMetadata: includeMetadata,
        requireAuthentication: requireAuth,
        allowedDomains: allowedDomains.isNotEmpty ? allowedDomains : null,
        maxDownloads: maxDownloads,
      );
      
      setShareData(shareData);
      Logger.info('Generated secure shareable URL for ${file.name}');
    } catch (e) {
      Logger.error('Failed to generate secure URL', e);
      setShareData({
        'error': 'Failed to generate secure URL',
        'fileName': file.name,
      });
    } finally {
      setGenerating(false);
    }
  }

  void _generateDownloadLink(Function(String?) setGeneratedUrl) {
    try {
      final publicUrl = file.publicUrl;
      if (publicUrl != null && publicUrl.isNotEmpty) {
        final downloadUrl = StorageUrlManager.generateDownloadUrl(
          publicUrl,
          file.name,
          forceDownload: true,
        );
        setGeneratedUrl(downloadUrl);
        Logger.info('Generated download link for ${file.name}');
      } else {
        Logger.error('No public URL available for download link generation');
      }
    } catch (e) {
      Logger.error('Failed to generate download link', e);
    }
  }

  String _formatExpirationDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final now = DateTime.now();
      final difference = date.difference(now);
      
      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'}';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'}';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'}';
      } else {
        return 'Expired';
      }
    } catch (e) {
      Logger.error('Failed to format expiration date', e);
      return 'Unknown';
    }
  }
}