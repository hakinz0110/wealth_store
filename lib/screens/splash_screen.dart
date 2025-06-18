import 'package:flutter/material.dart';
import '../utils/asset_helper.dart';

class SplashFinalPage extends StatelessWidget {
  const SplashFinalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(48),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 40.0,
              vertical: 48.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Add more vertical space above
                const SizedBox(height: 24),
                // Single intro logo image (or your custom header)
                Container(
                  height: 180,
                  width: 180,
                  margin: const EdgeInsets.only(bottom: 24),
                  child: AssetHelper.loadImage(
                    path: 'assets/images/intro_logo.png',
                    fit: BoxFit.contain,
                    fallbackColor: const Color(0xFF6518F4),
                    fallbackIcon: Icons.image,
                    fallbackIconSize: 80,
                  ),
                ),
                const SizedBox(height: 16),
                // Welcome text
                const Text(
                  'Welcome to Digital Store',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Subtitle text
                const Text(
                  'a Gateway to the Latest Tech',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Description text
                Text(
                  'Sign in to explore a wide range of cutting-edge digital products. Don\'t have an account yet? Register now and enjoy a seamless and secure shopping experience',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Get Started button
                SizedBox(
                  width: 400,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to the register page
                      Navigator.pushNamed(context, '/auth', arguments: false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6518F4),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: const Text(
                      'Let\'s Get Started',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Sign In link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 16,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigate to the login page
                        Navigator.pushNamed(context, '/auth', arguments: true);
                      },
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: Color(0xFF6518F4),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
