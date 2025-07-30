import 'package:flutter/material.dart';
import '../../../models/banner_models.dart' as banner_models;

class BannerCard extends StatelessWidget {
  final banner_models.Banner banner;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;

  const BannerCard({
    super.key,
    required this.banner,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Image
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                image: DecorationImage(
                  image: NetworkImage(banner.imageUrl),
                  fit: BoxFit.cover,
                  onError: (error, stackTrace) {
                    // Handle image load error
                  },
                ),
              ),
              child: Stack(
                children: [
                  // Status badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: banner.isActive ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        banner.isActive ? 'Active' : 'Inactive',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  
                  // Sort order badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '#${banner.sortOrder}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Banner Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    banner.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Description
                  if (banner.description != null)
                    Text(
                      banner.description!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  
                  const Spacer(),
                  
                  // Actions
                  Row(
                    children: [
                      // Toggle status
                      IconButton(
                        onPressed: onToggleStatus,
                        icon: Icon(
                          banner.isActive ? Icons.visibility_off : Icons.visibility,
                          size: 18,
                        ),
                        tooltip: banner.isActive ? 'Deactivate' : 'Activate',
                        color: banner.isActive ? Colors.orange : Colors.green,
                      ),
                      
                      // Edit
                      IconButton(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit, size: 18),
                        tooltip: 'Edit',
                        color: Colors.blue,
                      ),
                      
                      // Delete
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete, size: 18),
                        tooltip: 'Delete',
                        color: Colors.red,
                      ),
                      
                      const Spacer(),
                      
                      // Link indicator
                      if (banner.linkUrl != null)
                        Icon(
                          Icons.link,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}