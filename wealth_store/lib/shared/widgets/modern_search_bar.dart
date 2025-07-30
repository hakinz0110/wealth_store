import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/core/constants/app_text_styles.dart';
import 'package:wealth_app/core/constants/app_shadows.dart';

class ModernSearchBar extends StatefulWidget {
  final String? hintText;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final VoidCallback? onVoicePressed;
  final VoidCallback? onFilterPressed;
  final bool showVoiceButton;
  final bool showFilterButton;
  final bool autofocus;
  final List<String>? suggestions;
  final Function(String)? onSuggestionTap;
  final bool showSuggestions;

  const ModernSearchBar({
    super.key,
    this.hintText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onVoicePressed,
    this.onFilterPressed,
    this.showVoiceButton = true,
    this.showFilterButton = false,
    this.autofocus = false,
    this.suggestions,
    this.onSuggestionTap,
    this.showSuggestions = false,
  });

  @override
  State<ModernSearchBar> createState() => _ModernSearchBarState();
}

class _ModernSearchBarState extends State<ModernSearchBar>
    with TickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
      if (_isFocused) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });

    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  boxShadow: _isFocused ? AppShadows.inputFocused : AppShadows.input,
                  border: Border.all(
                    color: _isFocused 
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : AppColors.neutral300.withValues(alpha: 0.5),
                    width: _isFocused ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Search icon
                    Padding(
                      padding: EdgeInsets.only(left: AppSpacing.lg),
                      child: Icon(
                        Icons.search,
                        color: _isFocused ? AppColors.primary : AppColors.neutral500,
                        size: 24,
                      ),
                    ),
                    
                    // Text field
                    Expanded(
                      child: TextField(
                        controller: widget.controller,
                        focusNode: _focusNode,
                        onChanged: widget.onChanged,
                        onSubmitted: widget.onSubmitted,
                        style: AppTextStyles.bodyLarge,
                        decoration: InputDecoration(
                          hintText: widget.hintText ?? 'Search products...',
                          hintStyle: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.neutral500,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.lg,
                          ),
                        ),
                      ),
                    ),
                    
                    // Action buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.showVoiceButton)
                          _buildActionButton(
                            icon: Icons.mic_outlined,
                            onPressed: widget.onVoicePressed,
                            tooltip: 'Voice search',
                          ),
                        
                        if (widget.showFilterButton)
                          _buildActionButton(
                            icon: Icons.tune,
                            onPressed: widget.onFilterPressed,
                            tooltip: 'Filters',
                          ),
                        
                        SizedBox(width: AppSpacing.sm),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        
        // Suggestions dropdown
        if (widget.showSuggestions && widget.suggestions != null && widget.suggestions!.isNotEmpty)
          _buildSuggestions(),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    VoidCallback? onPressed,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed?.call();
        },
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            color: AppColors.neutral600,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    return Container(
      margin: EdgeInsets.only(top: AppSpacing.xs),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: AppShadows.elevation3,
        border: Border.all(
          color: AppColors.neutral200.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: widget.suggestions!.map((suggestion) {
          return InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onSuggestionTap?.call(suggestion);
            },
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    size: 16,
                    color: AppColors.neutral500,
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      suggestion,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                  Icon(
                    Icons.north_west,
                    size: 16,
                    color: AppColors.neutral400,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    )
        .animate()
        .fadeIn(duration: 200.ms)
        .slideY(begin: -0.1, end: 0, duration: 200.ms);
  }
}

// Voice search button with animation
class VoiceSearchButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isListening;

  const VoiceSearchButton({
    super.key,
    this.onPressed,
    this.isListening = false,
  });

  @override
  State<VoiceSearchButton> createState() => _VoiceSearchButtonState();
}

class _VoiceSearchButtonState extends State<VoiceSearchButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.isListening) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(VoiceSearchButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening != oldWidget.isListening) {
      if (widget.isListening) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isListening ? _pulseAnimation.value : 1.0,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: widget.isListening ? AppColors.error : AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (widget.isListening ? AppColors.error : AppColors.primary)
                      .withValues(alpha: 0.3),
                  blurRadius: widget.isListening ? 20 : 8,
                  spreadRadius: widget.isListening ? 5 : 0,
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                widget.onPressed?.call();
              },
              icon: Icon(
                widget.isListening ? Icons.mic : Icons.mic_none,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        );
      },
    );
  }
}

// Search suggestions with categories
class SearchSuggestionsList extends StatelessWidget {
  final List<SearchSuggestion> suggestions;
  final Function(SearchSuggestion) onSuggestionTap;
  final VoidCallback? onClearHistory;

  const SearchSuggestionsList({
    super.key,
    required this.suggestions,
    required this.onSuggestionTap,
    this.onClearHistory,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    // Group suggestions by type
    final recentSearches = suggestions.where((s) => s.type == SearchSuggestionType.recent).toList();
    final popularSearches = suggestions.where((s) => s.type == SearchSuggestionType.popular).toList();
    final categorySearches = suggestions.where((s) => s.type == SearchSuggestionType.category).toList();

    return Container(
      margin: EdgeInsets.only(top: AppSpacing.xs),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: AppShadows.elevation3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recentSearches.isNotEmpty) ...[
            _buildSectionHeader('Recent Searches', onClearHistory),
            ...recentSearches.map((suggestion) => _buildSuggestionItem(suggestion)),
          ],
          
          if (popularSearches.isNotEmpty) ...[
            if (recentSearches.isNotEmpty) const Divider(height: 1),
            _buildSectionHeader('Popular Searches'),
            ...popularSearches.map((suggestion) => _buildSuggestionItem(suggestion)),
          ],
          
          if (categorySearches.isNotEmpty) ...[
            if (recentSearches.isNotEmpty || popularSearches.isNotEmpty) const Divider(height: 1),
            _buildSectionHeader('Categories'),
            ...categorySearches.map((suggestion) => _buildSuggestionItem(suggestion)),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, [VoidCallback? onAction]) {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.neutral600,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (onAction != null)
            InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  'Clear',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(SearchSuggestion suggestion) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onSuggestionTap(suggestion);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(
              _getIconForType(suggestion.type),
              size: 18,
              color: AppColors.neutral500,
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                suggestion.text,
                style: AppTextStyles.bodyMedium,
              ),
            ),
            if (suggestion.type == SearchSuggestionType.recent)
              Icon(
                Icons.north_west,
                size: 16,
                color: AppColors.neutral400,
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(SearchSuggestionType type) {
    switch (type) {
      case SearchSuggestionType.recent:
        return Icons.history;
      case SearchSuggestionType.popular:
        return Icons.trending_up;
      case SearchSuggestionType.category:
        return Icons.category_outlined;
    }
  }
}

// Data models
class SearchSuggestion {
  final String text;
  final SearchSuggestionType type;
  final String? category;

  const SearchSuggestion({
    required this.text,
    required this.type,
    this.category,
  });
}

enum SearchSuggestionType {
  recent,
  popular,
  category,
}