import 'package:flutter/material.dart';
import '../utils/asset_helper.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Single intro logo image
              Container(
                height: 300,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 24),
                child: AssetHelper.loadImage(
                  path: 'assets/images/intro_logo.png',
                  fit: BoxFit.contain,
                  fallbackColor: const Color(0xFF6518F4),
                  fallbackIcon: Icons.image,
                  fallbackIconSize: 80,
                ),
              ),

              // Welcome text
              const Text(
                'Welcome to Digital Store',
                style: TextStyle(
                  fontSize: 24,
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
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Get Started button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to the register page
                    Navigator.pushNamed(context, '/auth', arguments: false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF6518F4,
                    ), // Purple color as seen in image
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Let\'s Get Started',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Sign In link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to the login page
                      Navigator.pushNamed(context, '/auth', arguments: true);
                    },
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        color: Color(0xFF6518F4), // Same purple color
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
