import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/core/utils/typography_utils.dart';
import 'package:wealth_app/core/utils/haptic_feedback_utils.dart';

class ProminentSearchBar extends StatefulWidget {
  final String placeholder;
  final VoidCallback? onTap;
  final Function(String)? onSubmitted;
  final bool enabled;

  const ProminentSearchBar({
    super.key,
    this.placeholder = 'Search in Store',
    this.onTap,
    this.onSubmitted,
    this.enabled = true,
  });

  @override
  State<ProminentSearchBar> createState() => _ProminentSearchBarState();
}

class _ProminentSearchBarState extends State<ProminentSearchBar> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: MouseRegion(
        cursor: widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: widget.enabled ? (_) => setState(() => _isHovered = true) : null,
        onExit: widget.enabled ? (_) => setState(() => _isHovered = false) : null,
        child: GestureDetector(
          onTapDown: widget.enabled ? (_) => setState(() => _isPressed = true) : null,
          onTapUp: widget.enabled ? (_) => setState(() => _isPressed = false) : null,
          onTapCancel: widget.enabled ? () => setState(() => _isPressed = false) : null,
          onTap: widget.enabled ? () => _handleTap(context) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            height: 48,
            transform: Matrix4.identity()
              ..scale(_isPressed ? 0.98 : _isHovered ? 1.02 : 1.0),
            decoration: BoxDecoration(
              color: _isHovered 
                  ? (isDark 
                      ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.8)
                      : Theme.of(context).colorScheme.surface)
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _isHovered 
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.6)
                    : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                width: _isHovered ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered 
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                      : Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                  blurRadius: _isHovered ? 12 : 4,
                  offset: Offset(0, _isHovered ? 6 : 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Search icon with enhanced animation
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    transform: Matrix4.identity()
                      ..scale(_isHovered ? 1.1 : 1.0),
                    child: Icon(
                      Icons.search,
                      size: _isHovered ? 26 : 24,
                      color: _isHovered 
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
                
                // Placeholder text with enhanced contrast
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TypographyUtils.getBodyStyle(
                      context,
                      size: BodySize.medium,
                      isSecondary: !_isHovered,
                    ).copyWith(
                      color: _isHovered 
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: _isHovered ? FontWeight.w500 : FontWeight.normal,
                    ),
                    child: Text(widget.placeholder),
                  ),
                ),
                
                // Voice search icon with enhanced hover effect
                Padding(
                  padding: const EdgeInsets.only(right: 16, left: 8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    transform: Matrix4.identity()
                      ..scale(_isHovered ? 1.1 : 1.0),
                    child: Icon(
                      Icons.mic_outlined,
                      size: _isHovered ? 22 : 20,
                      color: _isHovered 
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.8)
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    HapticFeedbackUtils.lightImpact();
    
    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      // Default behavior: navigate to search screen
      context.push('/search');
    }
  }
}

/// Interactive search bar that can actually accept input
class InteractiveSearchBar extends StatefulWidget {
  final String placeholder;
  final Function(String)? onSubmitted;
  final Function(String)? onChanged;
  final bool autofocus;
  final TextEditingController? controller;

  const InteractiveSearchBar({
    super.key,
    this.placeholder = 'Search in Store',
    this.onSubmitted,
    this.onChanged,
    this.autofocus = false,
    this.controller,
  });

  @override
  State<InteractiveSearchBar> createState() => _InteractiveSearchBarState();
}

class _InteractiveSearchBarState extends State<InteractiveSearchBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();
    
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _focusNode.hasFocus 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: _focusNode.hasFocus ? 2 : 1,
          ),
          boxShadow: _focusNode.hasFocus 
              ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Search icon
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 12),
              child: Icon(
                Icons.search,
                size: 24,
                color: _focusNode.hasFocus
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            
            // Text input
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: TypographyUtils.getBodyStyle(
                  context,
                  size: BodySize.medium,
                ),
                decoration: InputDecoration(
                  hintText: widget.placeholder,
                  hintStyle: TypographyUtils.getBodyStyle(
                    context,
                    size: BodySize.medium,
                    isSecondary: true,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    widget.onSubmitted?.call(value.trim());
                  }
                },
                onChanged: widget.onChanged,
              ),
            ),
            
            // Clear button (when text is present)
            if (_controller.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _controller.clear();
                  widget.onChanged?.call('');
                  setState(() {});
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.clear,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            
            // Voice search icon
            GestureDetector(
              onTap: () {
                // TODO: Implement voice search
                HapticFeedbackUtils.lightImpact();
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 16, left: 8),
                child: Icon(
                  Icons.mic_outlined,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}