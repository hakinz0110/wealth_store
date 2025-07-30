import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/core/utils/typography_utils.dart';
import 'package:wealth_app/core/utils/haptic_feedback_utils.dart';
import 'package:wealth_app/features/home/providers/banner_providers.dart';
import 'package:wealth_app/features/home/utils/banner_navigation_helper.dart';
import 'package:wealth_app/shared/models/banner.dart' as app_banner;
import 'package:wealth_app/shared/widgets/shimmer_loading.dart';
import 'package:wealth_app/shared/widgets/error_widget.dart';

class BannerCarousel extends ConsumerStatefulWidget {
  const BannerCarousel({super.key});

  @override
  ConsumerState<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends ConsumerState<BannerCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        final bannersAsync = ref.read(activeBannersProvider);
        bannersAsync.whenData((banners) {
          if (banners.isNotEmpty) {
            final nextPage = (_currentPage + 1) % banners.length;
            _pageController.animateToPage(
              nextPage,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use the real-time stream for banners if available
    final bannersAsync = ref.watch(bannerStreamProvider);

    return bannersAsync.when(
      data: (banners) {
        if (banners.isEmpty) {
          return const SizedBox.shrink(); // Hide if no banners
        }
        return _buildBannerCarousel(context, banners);
      },
      loading: () => _buildLoadingState(context),
      error: (error, stack) => CustomErrorWidget(
        error: 'Failed to load banners',
        onRetry: () => ref.refresh(activeBannersProvider),
      ),
    );
  }

  Widget _buildBannerCarousel(BuildContext context, List<app_banner.Banner> banners) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              'Featured',
              style: TypographyUtils.getHeadingStyle(
                context,
                HeadingLevel.h4,
                isEmphasis: true,
              ),
            ),
          ),
          
          // Banner carousel
          SizedBox(
            height: 180,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: banners.length,
              itemBuilder: (context, index) {
                return BannerCard(banner: banners[index]);
              },
            ),
          ),
          
          // Page indicators (only show if more than 1 banner)
          if (banners.length > 1) ...[
            const SizedBox(height: 12),
            _buildPageIndicators(context, banners.length),
          ],
        ],
      ),
    );
  }

  Widget _buildPageIndicators(BuildContext context, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == _currentPage;
        return GestureDetector(
          onTap: () {
            HapticFeedbackUtils.lightImpact();
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 8 : 6,
            height: isActive ? 8 : 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shimmer for section title
          ShimmerLoading(
            child: Container(
              width: 100,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          
          const SizedBox(height: AppSpacing.sm),
          
          // Shimmer for banner
          ShimmerLoading(
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BannerCard extends StatelessWidget {
  final app_banner.Banner banner;

  const BannerCard({
    super.key,
    required this.banner,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleBannerTap(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Banner image as background
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: banner.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => ShimmerLoading(
                    child: Container(color: Colors.white),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              
              // Gradient overlay for better text visibility
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              
              // Banner content
              Positioned(
                left: 20,
                bottom: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Banner title
                    Text(
                      banner.title,
                      style: TypographyUtils.getHeadingStyle(
                        context,
                        HeadingLevel.h3,
                        isEmphasis: true,
                      ).copyWith(color: Colors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    if (banner.description != null && banner.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        banner.description!,
                        style: TypographyUtils.getBodyStyle(
                          context,
                        ).copyWith(color: Colors.white.withOpacity(0.9)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleBannerTap(BuildContext context) {
    HapticFeedbackUtils.lightImpact();
    
    // Use the navigation helper to handle banner clicks
    BannerNavigationHelper.navigateFromBanner(context, banner);
  }
}