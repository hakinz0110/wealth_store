import 'package:flutter/material.dart';

class VoiceSearchButton extends StatefulWidget {
  final Function(String) onSearchResult;
  final double size;
  final Color? color;
  final Color? backgroundColor;

  const VoiceSearchButton({
    super.key,
    required this.onSearchResult,
    this.size = 50,
    this.color,
    this.backgroundColor,
  });

  @override
  State<VoiceSearchButton> createState() => _VoiceSearchButtonState();
}

class _VoiceSearchButtonState extends State<VoiceSearchButton>
    with SingleTickerProviderStateMixin {
  bool _isListening = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startListening() {
    setState(() {
      _isListening = true;
    });

    // In a real app, you would use a speech recognition package
    // For now, we'll simulate voice recognition with a delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isListening = false;
        });

        // Simulate a search result
        widget.onSearchResult('voice search result');
      }
    });
  }

  void _stopListening() {
    if (_isListening) {
      setState(() {
        _isListening = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final color = widget.color ?? (isDarkMode ? Colors.white : Colors.black);
    final backgroundColor =
        widget.backgroundColor ??
        (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200);

    return GestureDetector(
      onTap: _isListening ? _stopListening : _startListening,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isListening
              ? Theme.of(context).primaryColor
              : backgroundColor,
        ),
        child: _isListening
            ? AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.scale(scale: _animation.value, child: child);
                },
                child: Icon(
                  Icons.mic,
                  color: Colors.white,
                  size: widget.size * 0.5,
                ),
              )
            : Icon(Icons.mic_none, color: color, size: widget.size * 0.5),
      ),
    );
  }
}

// Example usage:
// VoiceSearchButton(
//   onSearchResult: (result) {
//     print('Voice search result: $result');
//     // Handle the search result
//   },
// )
