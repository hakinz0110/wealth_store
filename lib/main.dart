import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'dart:io' show Platform;
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';
import 'providers/order_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/user_activity_provider.dart';
import 'providers/deal_provider.dart';
import 'providers/category_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/auth_screen.dart';
import 'screens/onboarding_splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/community_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'services/firebase_options.dart';
import 'utils/icon_styles.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SplashLogoApp());
}

class SplashLogoApp extends StatelessWidget {
  const SplashLogoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashLogoScreen(),
    );
  }
}

class SplashLogoScreen extends StatefulWidget {
  const SplashLogoScreen({super.key});

  @override
  State<SplashLogoScreen> createState() => _SplashLogoScreenState();
}

class _SplashLogoScreenState extends State<SplashLogoScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // Initialize Firebase in the background
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      debugPrint('Error initializing Firebase: $e');
    }
    // Wait a short moment to show the logo (optional, for smoothness)
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const MyApp()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/images/wealth_logo.jpg',
          width: 160,
          height: 160,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => UserActivityProvider()),
        ChangeNotifierProvider(create: (_) => DealProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Wealth Store',
            theme: themeProvider.getTheme(),
            home: const AuthWrapper(),
            routes: {
              '/splash': (context) => const OnboardingSplashScreen(),
              '/main': (context) => const MainScreen(),
              '/favorites': (context) => const FavoritesScreen(),
              '/search': (context) => const SearchScreen(),
              '/community': (context) => const CommunityScreen(),
              '/edit_profile': (context) => const EditProfileScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/auth') {
                final bool isLogin = settings.arguments as bool? ?? true;
                return MaterialPageRoute(
                  builder: (context) => AuthScreen(isLogin: isLogin),
                );
              }
              return null;
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Show loading indicator while checking auth state
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading...'),
            ],
          ),
        ),
      );
    }

    // If user is not logged in, show onboarding splash
    if (!authProvider.isLoggedIn) {
      return const OnboardingSplashScreen();
    }

    // If user is logged in, show main app
    return const MainScreen();
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    SearchScreen(),
    CartScreen(),
    CommunityScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
        }
      },
      child: Scaffold(
        body: _screens[_selectedIndex],
        extendBody:
            true, // Important for the bottom navigation bar to be transparent
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            child: BottomNavigationBar(
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: _buildNavIcon(0, Icons.home_outlined, Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: _buildNavIcon(1, Icons.search_outlined, Icons.search),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: _buildNavIcon(
                    2,
                    Icons.shopping_bag_outlined,
                    Icons.shopping_bag,
                  ),
                  label: 'Cart',
                ),
                BottomNavigationBarItem(
                  icon: _buildNavIcon(
                    3,
                    Icons.chat_bubble_outline_rounded,
                    Icons.chat_bubble_rounded,
                  ),
                  label: 'Community',
                ),
                BottomNavigationBarItem(
                  icon: _buildNavIcon(4, Icons.person_outline, Icons.person),
                  label: 'Profile',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: primaryColor,
              unselectedItemColor: isDarkMode
                  ? Colors.grey.shade500
                  : Colors.grey.shade600,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              onTap: _onItemTapped,
              elevation: 0,
              backgroundColor: isDarkMode
                  ? Colors.black.withOpacity(0.9)
                  : Colors.white.withOpacity(0.9),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build navigation icons
  Widget _buildNavIcon(int index, IconData outlinedIcon, IconData filledIcon) {
    final isSelected = _selectedIndex == index;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    if (isSelected) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(filledIcon, color: primaryColor),
      );
    } else {
      return Icon(
        outlinedIcon,
        color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
      );
    }
  }
}
