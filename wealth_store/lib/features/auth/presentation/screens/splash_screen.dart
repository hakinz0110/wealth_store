import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_design_tokens.dart';
import 'package:wealth_app/core/constants/app_text_styles.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/features/auth/domain/auth_notifier.dart';
import 'package:wealth_app/core/utils/secure_storage.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  bool _showGetStartedButton = false;
  
  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  void _initializeScreen() async {
    // Show the Get Started button after animations complete
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() {
        _showGetStartedButton = true;
      });
    }
  }

  Future<void> _navigateToNextScreen() async {
    try {
      // Remove the artificial delay
      // await Future.delayed(const Duration(seconds: 2));
      
      if (!mounted) return;
      
      // Check authentication state
      final authState = ref.read(authNotifierProvider);
      
      if (authState.isAuthenticated) {
        // User is already authenticated, navigate to home
        context.go('/home');
      } else {
        // Check if there's a stored token
        final token = await SecureStorage.getToken();
        final userId = await SecureStorage.getUserId();
        
        if (token != null && userId != null) {
          // We have stored credentials, but auth state doesn't reflect it
          // This could be due to app restart - try to go to home anyway
          context.go('/home');
        } else {
          // No stored credentials, go to onboarding
          final isFirstLaunch = await _isFirstLaunch();
          if (isFirstLaunch) {
            context.go('/onboarding');
          } else {
            context.go('/auth');
          }
        }
      }
    } catch (e) {
      debugPrint('Error during navigation: $e');
      // In production, default to auth screen
      if (mounted) {
        context.go('/auth');
      }
    }
  }
  
  Future<bool> _isFirstLaunch() async {
    // Simple check to determine if this is the first launch
    // In a real app, you might use shared preferences
    return true; // Always show onboarding for now
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background with particle effects
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.surfaceLight,
                  AppColors.primary.withValues(alpha: 0.08),
                  AppColors.secondary.withValues(alpha: 0.05),
                ],
              ),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(
                duration: 3000.ms,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
          
          // Floating particles for dynamic effect
          ...List.generate(
            8,
            (index) => Positioned(
              top: 50.0 + (index * 80),
              left: (index % 2 == 0) ? 30.0 + (index * 40) : null,
              right: (index % 2 != 0) ? 30.0 + (index * 35) : null,
              child: Container(
                width: 6 + (index % 4) * 3,
                height: 6 + (index % 4) * 3,
                decoration: BoxDecoration(
                  color: index % 3 == 0
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : index % 3 == 1
                          ? AppColors.secondary.withValues(alpha: 0.15)
                          : AppColors.tertiary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(3 + (index % 4) * 1.5),
                ),
              )
                  .animate(delay: (150 * index).ms)
                  .fadeIn(duration: 800.ms)
                  .then()
                  .animate(onPlay: (controller) => controller.repeat())
                  .moveY(
                    begin: 0,
                    end: 15 + (index % 4) * 5,
                    duration: (2000 + (index * 300)).ms,
                    curve: Curves.easeInOut,
                  )
                  .then()
                  .moveY(
                    begin: 15 + (index % 4) * 5,
                    end: 0,
                    duration: (2000 + (index * 300)).ms,
                    curve: Curves.easeInOut,
                  ),
            ),
          ),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Hero logo treatment with modern container
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: AppDesignTokens.radiusXl,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                blurRadius: 35,
                                offset: const Offset(0, 18),
                                spreadRadius: 0,
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.shopping_bag_rounded,
                            size: 70,
                            color: AppColors.primary,
                          ),
                        )
                            .animate()
                            .scale(
                              begin: const Offset(0.3, 0.3),
                              end: const Offset(1, 1),
                              duration: 400.ms,
                              curve: Curves.elasticOut,
                            )
                            .fadeIn(
                              duration: AppDesignTokens.animationMedium,
                              curve: AppDesignTokens.easeOut,
                            )
                            .then(delay: 300.ms)
                            .shimmer(
                              duration: 1500.ms,
                              color: AppColors.primary.withValues(alpha: 0.3),
                            ),
                        
                        const SizedBox(height: 32),
                        
                        // App name with modern typography
                        Text(
                          'Wealth Store',
                          style: AppTextStyles.displaySmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
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
                        
                        const SizedBox(height: 12),
                        
                        // Staggered tagline fade-in with 200ms delay
                        Text(
                          'Shop smart, live better',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.onSurfaceLight.withValues(alpha: 0.7),
                          ),
                        )
                            .animate(delay: 400.ms)
                            .fadeIn(
                              duration: AppDesignTokens.animationMedium,
                              curve: AppDesignTokens.easeOut,
                            ),
                      ],
                    ),
                  ),
                ),
                
                // Get Started button with modern styling and slide-up animation
                if (_showGetStartedButton)
                  Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _navigateToNextScreen,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 8,
                          shadowColor: AppColors.primary.withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppDesignTokens.radiusLg,
                          ),
                        ),
                        child: Text(
                          'Get Started',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .slideY(
                        begin: 0.5,
                        end: 0,
                        duration: 600.ms,
                        curve: Curves.easeOutBack,
                      )
                      .fadeIn(
                        duration: 400.ms,
                        curve: AppDesignTokens.easeOut,
                      ),
                
                // Loading indicator (shown when button is not visible)
                if (!_showGetStartedButton)
                  Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  )
                      .animate(delay: 600.ms)
                      .fadeIn(
                        duration: AppDesignTokens.animationFast,
                        curve: AppDesignTokens.easeOut,
                      )
                      .then()
                      .animate(onPlay: (controller) => controller.repeat())
                      .scale(
                        begin: const Offset(1.0, 1.0),
                        end: const Offset(1.1, 1.1),
                        duration: 800.ms,
                      )
                      .then()
                      .scale(
                        begin: const Offset(1.1, 1.1),
                        end: const Offset(1.0, 1.0),
                        duration: 800.ms,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 