import 'package:flutter/material.dart';


enum SocialProvider {
  google,
  facebook,
}

class SocialSignInButton extends StatelessWidget {
  final SocialProvider provider;
  final VoidCallback onPressed;
  final bool isLoading;
  
  const SocialSignInButton({
    super.key,
    required this.provider,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color buttonColor = provider == SocialProvider.google 
        ? Colors.white 
        : const Color(0xFF1877F2);
    
    final Color textColor = provider == SocialProvider.google 
        ? Colors.black87 
        : Colors.white;
    
    final String buttonText = provider == SocialProvider.google 
        ? 'Continue with Google' 
        : 'Continue with Facebook';

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: textColor,
          elevation: 1,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: provider == SocialProvider.google 
                ? const BorderSide(color: Colors.grey, width: 0.5) 
                : BorderSide.none,
          ),
        ),
        icon: isLoading 
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: textColor,
                ),
              )
            : SizedBox(
                width: 24,
                height: 24,
                child: provider == SocialProvider.google
                    ? Icon(Icons.g_mobiledata, size: 24, color: Colors.red)
                    : Icon(Icons.facebook, size: 24, color: Colors.white),
              ),
        label: Text(
          buttonText,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }
} 