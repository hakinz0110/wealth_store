import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_design_tokens.dart';
import 'package:wealth_app/core/constants/app_text_styles.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToSplash();
  }

  Future<void> _navigateToSplash() async {
    // Wait for logo animation to complete, then transition to splash
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) {
      context.go('/splash');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo with fade-in animation
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppDesignTokens.radiusXl,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shopping_bag_rounded,
                  size: 60,
                  color: AppColors.primary,
                ),
              )
                  .animate()
                  .fadeIn(
                    duration: AppDesignTokens.animationMedium,
                    curve: AppDesignTokens.easeOut,
                  )
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                    duration: AppDesignTokens.animationMedium,
                    curve: AppDesignTokens.easeOut,
                  ),

              const SizedBox(height: 40),

              // App Name
              Text(
                'Wealth Store',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )
                  .animate(delay: 200.ms)
                  .fadeIn(
                    duration: AppDesignTokens.animationMedium,
                    curve: AppDesignTokens.easeOut,
                  )
                  .slideY(
                    begin: 0.3,
                    end: 0,
                    duration: AppDesignTokens.animationMedium,
                    curve: AppDesignTokens.easeOut,
                  ),

              const SizedBox(height: 60),

              // Loading indicator
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              )
                  .animate(delay: 500.ms)
                  .fadeIn(
                    duration: AppDesignTokens.animationFast,
                    curve: AppDesignTokens.easeOut,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}