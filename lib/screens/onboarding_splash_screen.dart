import 'package:flutter/material.dart';
import 'splash_screen.dart';

class OnboardingSplashScreen extends StatefulWidget {
  const OnboardingSplashScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingSplashScreen> createState() => _OnboardingSplashScreenState();
}

class _OnboardingSplashScreenState extends State<OnboardingSplashScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late List<Widget> _pageWidgets;
  bool _autoAdvance = true;

  @override
  void initState() {
    super.initState();
    _pageWidgets = [
      const _OnboardingPage(
        image: 'assets/images/sp1.png',
        title: 'Choose Your Product',
        subtitle:
            'Welcome to a World of Limitless Choices - Your Perfect Product Awaits!',
      ),
      const _OnboardingPage(
        image: 'assets/images/sp2.png',
        title: 'Select Payment Method',
        subtitle:
            'For Seamless Transactions, Choose Your Payment Path - Your Convenience, Our Priority!',
      ),
      const _OnboardingPage(
        image: 'assets/images/sp3.png',
        title: 'Deliver At Your Door Step',
        subtitle:
            'From Our Doorstep to Yours - Swift, Secure, and Contactless Delivery!',
      ),
      const SplashFinalPage(),
    ];
    _startAutoAdvance();
  }

  void _startAutoAdvance() async {
    while (_autoAdvance && mounted && _currentPage < _pageWidgets.length - 1) {
      await Future.delayed(const Duration(seconds: 3));
      if (!_autoAdvance || !mounted) break;
      if (_currentPage < _pageWidgets.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
      _autoAdvance = true;
    });
    if (index < _pageWidgets.length - 1) {
      _startAutoAdvance();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _pageWidgets.length,
              onPageChanged: _onPageChanged,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) => _pageWidgets[index],
            ),
            // Skip button
            if (_currentPage < _pageWidgets.length - 1)
              Positioned(
                top: 24,
                right: 24,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _autoAdvance = false;
                    });
                    _pageController.animateToPage(
                      _pageWidgets.length - 1,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            // Forward button
            if (_currentPage < _pageWidgets.length - 1)
              Positioned(
                bottom: 40,
                right: 24,
                child: FloatingActionButton(
                  backgroundColor: Colors.black,
                  onPressed: () {
                    setState(() {
                      _autoAdvance = false;
                    });
                    if (_currentPage < _pageWidgets.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                  ),
                ),
              ),
            // Indicator dots
            if (_currentPage < _pageWidgets.length)
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pageWidgets.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Colors.black
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
            // Back button - only show when not on first page
            if (_currentPage > 0)
              Positioned(
                bottom: 40,
                left: 24,
                child: FloatingActionButton(
                  backgroundColor: Colors.black,
                  onPressed: () {
                    setState(() {
                      _autoAdvance = false;
                    });
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Icon(Icons.arrow_back_ios, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  const _OnboardingPage({
    required this.image,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 300,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 24),
            child: Image.asset(image, fit: BoxFit.contain),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
