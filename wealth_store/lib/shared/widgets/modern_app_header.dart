import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_design_tokens.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/core/constants/app_text_styles.dart';

class ModernAppHeader extends ConsumerStatefulWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final ScrollController? scrollController;
  final bool showSearchBar;
  final bool showProfileAvatar;
  final bool showNotificationBadge;
  final int notificationCount;

  const ModernAppHeader({
    super.key,
    this.title = 'Wealth Store',
    this.actions,
    this.showBackButton = false,
    this.onBackPressed,
    this.scrollController,
    this.showSearchBar = true,
    this.showProfileAvatar = true,
    this.showNotificationBadge = true,
    this.notificationCount = 0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  ConsumerState<ModernAppHeader> createState() => _ModernAppHeaderState();
}

class _ModernAppHeaderState extends ConsumerState<ModernAppHeader>
    with TickerProviderStateMixin {
  late AnimationController _scrollAnimationController;
  late AnimationController _searchAnimationController;
  late AnimationController _voiceAnimationController;
  
  bool _isSearchExpanded = false;
  bool _isVoiceListening = false;
  bool _isScrolled = false;
  
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final SpeechToText _speechToText = SpeechToText();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeScrollListener();
    _initializeSpeechToText();
  }

  void _initializeControllers() {
    _scrollAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _voiceAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  void _initializeScrollListener() {
    widget.scrollController?.addListener(() {
      final isScrolled = (widget.scrollController?.offset ?? 0) > 50;
      if (isScrolled != _isScrolled) {
        setState(() {
          _isScrolled = isScrolled;
        });
        if (isScrolled) {
          _scrollAnimationController.forward();
        } else {
          _scrollAnimationController.reverse();
        }
      }
    });
  }

  void _initializeSpeechToText() async {
    await _speechToText.initialize();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
    });
    
    if (_isSearchExpanded) {
      _searchAnimationController.forward();
      _searchFocusNode.requestFocus();
    } else {
      _searchAnimationController.reverse();
      _searchFocusNode.unfocus();
      _searchController.clear();
    }
    
    HapticFeedback.lightImpact();
  }

  void _startVoiceSearch() async {
    if (!_speechToText.isAvailable) return;
    
    setState(() {
      _isVoiceListening = true;
    });
    
    _voiceAnimationController.repeat();
    HapticFeedback.mediumImpact();
    
    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _searchController.text = result.recognizedWords;
        });
      },
      listenFor: const Duration(seconds: 10),
    );
    
    // Stop listening after timeout or completion
    Future.delayed(const Duration(seconds: 10), () {
      _stopVoiceSearch();
    });
  }

  void _stopVoiceSearch() {
    if (_isVoiceListening) {
      _speechToText.stop();
      setState(() {
        _isVoiceListening = false;
      });
      _voiceAnimationController.stop();
      _voiceAnimationController.reset();
    }
  }

  @override
  void dispose() {
    _scrollAnimationController.dispose();
    _searchAnimationController.dispose();
    _voiceAnimationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _scrollAnimationController,
      builder: (context, child) {
        return Container(
          height: widget.preferredSize.height,
          decoration: BoxDecoration(
            color: isDark 
                ? AppColors.backgroundDark.withValues(alpha: 0.95)
                : AppColors.backgroundLight.withValues(alpha: 0.95),
            border: Border(
              bottom: BorderSide(
                color: _isScrolled
                    ? (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1))
                    : Colors.transparent,
                width: 0.5,
              ),
            ),
          ),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: _isScrolled ? 20 : 0,
                sigmaY: _isScrolled ? 20 : 0,
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Column(
                    children: [
                      // Top row with title and actions
                      Row(
                        children: [
                          if (widget.showBackButton) ...[
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new),
                              onPressed: widget.onBackPressed ?? () => context.pop(),
                            ),
                            const SizedBox(width: 8),
                          ],
                          
                          // Title with fade animation based on scroll
                          Expanded(
                            child: AnimatedOpacity(
                              opacity: _isSearchExpanded ? 0.0 : 1.0,
                              duration: const Duration(milliseconds: 300),
                              child: Text(
                                widget.title,
                                style: AppTextStyles.headlineSmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          
                          // Action buttons
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Search toggle button
                              if (widget.showSearchBar)
                                IconButton(
                                  icon: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: Icon(
                                      _isSearchExpanded ? Icons.close : Icons.search,
                                      key: ValueKey(_isSearchExpanded),
                                    ),
                                  ),
                                  onPressed: _toggleSearch,
                                ),
                              
                              // Notification button with badge
                              if (widget.showNotificationBadge)
                                _buildNotificationButton(isDark),
                              
                              // Profile avatar
                              if (widget.showProfileAvatar)
                                _buildProfileAvatar(isDark),
                              
                              // Custom actions
                              ...?widget.actions,
                            ],
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Expandable search bar
                      _buildExpandableSearchBar(isDark),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationButton(bool isDark) {
    return Stack(
      children: [
        Semantics(
          label: 'Notifications',
          hint: widget.notificationCount > 0 
              ? 'You have ${widget.notificationCount} unread notifications. Double tap to view.'
              : 'No new notifications. Double tap to view all notifications.',
          button: true,
          enabled: true,
          child: IconButton(
            icon: const Icon(Icons.notifications_none),
            constraints: const BoxConstraints(
              minWidth: 44.0,
              minHeight: 44.0,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              context.push('/notifications');
            },
          ),
        ),
        if (widget.notificationCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.error.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Text(
                widget.notificationCount > 99 ? '99+' : widget.notificationCount.toString(),
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            )
                .animate()
                .scale(
                  duration: 300.ms,
                  curve: Curves.elasticOut,
                )
                .then()
                .animate(onPlay: (controller) => controller.repeat())
                .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.1, 1.1),
                  duration: 1000.ms,
                )
                .then()
                .scale(
                  begin: const Offset(1.1, 1.1),
                  end: const Offset(1.0, 1.0),
                  duration: 1000.ms,
                ),
          ),
      ],
    );
  }

  Widget _buildProfileAvatar(bool isDark) {
    return Semantics(
      label: 'Profile',
      hint: 'Double tap to view your profile and account settings',
      button: true,
      enabled: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          context.push('/profile');
        },
        child: Container(
          margin: const EdgeInsets.only(left: 8),
          // Ensure minimum touch target size
          constraints: const BoxConstraints(
            minWidth: 44.0,
            minHeight: 44.0,
          ),
          child: Stack(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary,
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              // Online status indicator
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .scale(
          duration: 300.ms,
          curve: Curves.elasticOut,
        )
        .then(delay: 200.ms)
        .shimmer(
          duration: 1500.ms,
          color: AppColors.primary.withValues(alpha: 0.3),
        );
  }

  Widget _buildExpandableSearchBar(bool isDark) {
    return AnimatedBuilder(
      animation: _searchAnimationController,
      builder: (context, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          height: _isSearchExpanded ? 48 : 0,
          child: _isSearchExpanded
              ? Container(
                  decoration: BoxDecoration(
                    color: isDark 
                        ? AppColors.surfaceVariantDark.withValues(alpha: 0.3)
                        : AppColors.surfaceVariantLight.withValues(alpha: 0.3),
                    borderRadius: AppDesignTokens.radiusLg,
                    border: Border.all(
                      color: isDark 
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Icon(
                        Icons.search,
                        color: isDark ? Colors.white70 : AppColors.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Semantics(
                          label: 'Search field',
                          hint: 'Enter text to search for products. Submit to search.',
                          textField: true,
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            decoration: InputDecoration(
                              hintText: 'Search products...',
                              hintStyle: AppTextStyles.bodyMedium.copyWith(
                                color: isDark ? Colors.white54 : AppColors.textSecondary,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isDark ? Colors.white : AppColors.textPrimary,
                            ),
                            onSubmitted: (value) {
                              if (value.isNotEmpty) {
                                context.push('/search?q=${Uri.encodeComponent(value)}');
                                _toggleSearch();
                              }
                            },
                          ),
                        ),
                      ),
                      // Voice search button
                      Semantics(
                        label: 'Voice search',
                        hint: _isVoiceListening 
                            ? 'Voice search is active. Double tap to stop listening.'
                            : 'Double tap to start voice search.',
                        button: true,
                        enabled: true,
                        child: IconButton(
                          constraints: const BoxConstraints(
                            minWidth: 44.0,
                            minHeight: 44.0,
                          ),
                          icon: AnimatedBuilder(
                            animation: _voiceAnimationController,
                            builder: (context, child) {
                              return Icon(
                                _isVoiceListening ? Icons.mic : Icons.mic_none,
                                color: _isVoiceListening 
                                    ? AppColors.error
                                    : (isDark ? Colors.white70 : AppColors.textSecondary),
                                size: 20,
                              );
                            },
                          )
                            .animate(target: _isVoiceListening ? 1 : 0)
                            .scale(
                              begin: const Offset(1.0, 1.0),
                              end: const Offset(1.2, 1.2),
                              duration: 200.ms,
                            )
                            .then()
                            .animate(onPlay: (controller) => _isVoiceListening ? controller.repeat() : null)
                            .scale(
                              begin: const Offset(1.0, 1.0),
                              end: const Offset(1.1, 1.1),
                              duration: 400.ms,
                            )
                            .then()
                            .scale(
                              begin: const Offset(1.1, 1.1),
                              end: const Offset(1.0, 1.0),
                              duration: 400.ms,
                            ),
                          onPressed: _isVoiceListening ? _stopVoiceSearch : _startVoiceSearch,
                        ),
                      ),
                    ],
                  ),
                )
                  .animate()
                  .slideY(
                    begin: -0.5,
                    end: 0,
                    duration: 400.ms,
                    curve: Curves.easeOutCubic,
                  )
                  .fadeIn(
                    duration: 300.ms,
                  )
              : const SizedBox.shrink(),
        );
      },
    );
  }
}