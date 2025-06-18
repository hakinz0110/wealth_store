import 'package:flutter/material.dart';
import 'skeleton_loading.dart';

class SeasonalCollection extends StatelessWidget {
  final String title;
  final String description;
  final String imageAsset;
  final Color backgroundColor;
  final VoidCallback onTap;
  final bool isLoading;

  const SeasonalCollection({
    super.key,
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.backgroundColor,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: SkeletonLoading(height: 150, borderRadius: 16),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: Colors.white.withAlpha(26),
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [backgroundColor, backgroundColor.withAlpha(204)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                // Background pattern
                Positioned(
                  right: -20,
                  bottom: -20,
                  child: CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.white.withAlpha(26),
                  ),
                ),

                // Content
                Row(
                  children: [
                    // Text content
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              description,
                              style: TextStyle(
                                color: Colors.white.withAlpha(230),
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Shop Now',
                                style: TextStyle(
                                  color: backgroundColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Image
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withAlpha(26),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(
                          imageAsset,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to get the current season collection
  static SeasonalCollection getCurrentSeason({
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    final now = DateTime.now();
    final month = now.month;

    // Spring: March - May
    if (month >= 3 && month <= 5) {
      return SeasonalCollection(
        title: 'Spring Collection',
        description: 'Refresh your tech with our spring essentials',
        imageAsset: 'assets/images/products/cat1_1.png',
        backgroundColor: const Color(0xFF4CAF50), // Green
        onTap: onTap,
        isLoading: isLoading,
      );
    }
    // Summer: June - August
    else if (month >= 6 && month <= 8) {
      return SeasonalCollection(
        title: 'Summer Collection',
        description: 'Stay cool with our summer tech deals',
        imageAsset: 'assets/images/products/cat2_2.png',
        backgroundColor: const Color(0xFF2196F3), // Blue
        onTap: onTap,
        isLoading: isLoading,
      );
    }
    // Fall: September - November
    else if (month >= 9 && month <= 11) {
      return SeasonalCollection(
        title: 'Fall Collection',
        description: 'Upgrade your workspace this fall season',
        imageAsset: 'assets/images/products/cat3_3.png',
        backgroundColor: const Color(0xFFFF9800), // Orange
        onTap: onTap,
        isLoading: isLoading,
      );
    }
    // Winter: December - February
    else {
      return SeasonalCollection(
        title: 'Winter Collection',
        description: 'Cozy up with our winter tech essentials',
        imageAsset: 'assets/images/products/loptop2.png',
        backgroundColor: const Color(0xFF3F51B5), // Indigo
        onTap: onTap,
        isLoading: isLoading,
      );
    }
  }
}
