import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/core/utils/typography_utils.dart';
import 'package:wealth_app/core/utils/haptic_feedback_utils.dart';
import 'package:wealth_app/features/home/domain/featured_banner_model.dart';
import 'package:wealth_app/features/home/domain/featured_banner_service.dart';
import 'package:wealth_app/shared/widgets/shimmer_loading.dart';

class FeaturedBannerCarousel extends ConsumerStatefulWidget {
  const FeaturedBannerCarousel({super.key});

  @override
  ConsumerState<FeaturedBannerCarousel> createState() => _FeaturedBannerCarouselState();
}

class _FeaturedBannerCarouselState extends ConsumerState<FeaturedBannerCarousel> {
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
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        final bannersAsync = ref.read(featuredBannersProvider);
        bannersAsync.whenData((banners) {
          if (banners.isNotEmpty) {
            final nextPage = (_currentPage + 1) % banners.length;
            _pageController.animateToPage(
              nextPage,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bannersAsync = ref.watch(featuredBannersProvider);

    return bannersAsync.when(
      data: (banners) {
        if (banners.isEmpty) {
          return const SizedBox.shrink(); // Hide if no banners
        }
        return _buildBannerCarousel(context, banners);
      },
      loading: () => _buildLoadingState(context),
      error: (error, stack) => const SizedBox.shrink(), // Hide on error
    );
  }

  Widget _buildBannerCarousel(BuildContext context, List<FeaturedBanner> banners) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          // Banner carousel
          SizedBox(
            height: 200,
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
      child: ShimmerLoading(
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class BannerCard extends StatelessWidget {
  final FeaturedBanner banner;

  const BannerCard({
    super.key,
    required this.banner,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleTap(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: banner.backgroundColor,
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
              // Background content
              Positioned.fill(
                child: Row(
                  children: [
                    // Text content area (60% of width)
                    Expanded(
                      flex: 6,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Subtitle/Brand
                            Text(
                              banner.subtitle,
                              style: TypographyUtils.getLabelStyle(
                                context,
                                size: LabelSize.small,
                                isSecondary: true,
                              ).copyWith(color: banner.textColor.withOpacity(0.7)),
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Main title
                            Text(
                              banner.title,
                              style: TypographyUtils.getHeadingStyle(
                                context,
                                HeadingLevel.h3,
                                isEmphasis: true,
                              ).copyWith(color: banner.textColor),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Image area (40% of width)
                    Expanded(
                      flex: 4,
                      child: Container(
                        height: double.infinity,
                        alignment: Alignment.centerRight,
                        child: _buildBannerImage(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerImage() {
    return CachedNetworkImage(
      imageUrl: banner.imageUrl,
      fit: BoxFit.contain,
      placeholder: (context, url) => ShimmerLoading(
        child: Container(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey.withOpacity(0.2),
        child: const Icon(
          Icons.image_not_supported_outlined,
          size: 48,
          color: Colors.grey,
        ),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    HapticFeedbackUtils.lightImpact();
    context.push(banner.targetRoute);
  }
}