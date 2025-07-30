import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/core/utils/typography_utils.dart';
import 'package:wealth_app/core/utils/haptic_feedback_utils.dart';
import 'package:wealth_app/features/home/domain/home_category_model.dart';
import 'package:wealth_app/features/home/domain/home_category_service.dart';
import 'package:wealth_app/shared/widgets/shimmer_loading.dart';

class PopularCategoriesSection extends ConsumerWidget {
  const PopularCategoriesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(popularCategoriesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'Popular Categories',
            style: TypographyUtils.getHeadingStyle(
              context,
              HeadingLevel.h4,
              isEmphasis: true,
            ),
          ),
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        // Categories horizontal list
        SizedBox(
          height: 100, // Height for icon + label
          child: categoriesAsync.when(
            data: (categories) => _buildCategoriesList(context, categories),
            loading: () => _buildLoadingState(context),
            error: (error, stack) => _buildErrorState(context, ref),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesList(BuildContext context, List<HomeCategory> categories) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Padding(
          padding: EdgeInsets.only(
            right: index < categories.length - 1 ? AppSpacing.md : 0,
          ),
          child: CategoryItem(category: category),
        );
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(
            right: index < 5 ? AppSpacing.md : 0,
          ),
          child: const CategoryItemSkeleton(),
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 32,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 8),
          Text(
            'Failed to load categories',
            style: TypographyUtils.getBodyStyle(
              context,
              size: BodySize.small,
              isSecondary: true,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              HapticFeedbackUtils.lightImpact();
              ref.invalidate(popularCategoriesProvider);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final HomeCategory category;

  const CategoryItem({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleTap(context),
      child: SizedBox(
        width: 80, // Fixed width for consistent layout
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Category icon container
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Icon(
                category.icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Category name
            Text(
              category.name,
              style: TypographyUtils.getLabelStyle(
                context,
                size: LabelSize.small,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    HapticFeedbackUtils.lightImpact();
    context.push(category.route);
  }
}

class CategoryItemSkeleton extends StatelessWidget {
  const CategoryItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Skeleton for icon container
          ShimmerLoading(
            child: Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Skeleton for category name
          ShimmerLoading(
            child: Container(
              width: 60,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}