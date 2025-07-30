import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/features/home/presentation/widgets/personalized_header.dart';
import 'package:wealth_app/features/home/presentation/widgets/prominent_search_bar.dart';
import 'package:wealth_app/features/home/presentation/widgets/popular_categories_section.dart';
import 'package:wealth_app/features/home/presentation/widgets/banner_carousel.dart';
import 'package:wealth_app/features/home/presentation/widgets/popular_products_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Personalized header with greeting and notifications
              const PersonalizedHeader(),
              
              const SizedBox(height: AppSpacing.md),
              
              // Prominent search bar
              const ProminentSearchBar(),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Popular categories section
              const PopularCategoriesSection(),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Banner carousel using Supabase data
              const BannerCarousel(),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Popular products section
              const PopularProductsSection(),
              
              // Bottom padding for better scrolling experience
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}