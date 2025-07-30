import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:wealth_app/core/config/app_config.dart';
import 'package:wealth_app/core/services/database/database_initializer.dart';
import 'package:wealth_app/core/theme/app_theme.dart' as app_theme;
import 'package:wealth_app/core/theme/app_theme_provider.dart';
import 'package:wealth_app/core/utils/performance_optimizer.dart';
import 'package:wealth_app/core/services/deep_link_service.dart';
import 'package:wealth_app/router/app_router.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase with better error handling
  try {
    debugPrint('Initializing Supabase with URL: ${AppConfig.supabaseUrl}');
    
    // Initialize Supabase
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
      debug: AppConfig.isDevelopment,
    );
    
    debugPrint('Supabase initialized successfully');
  } catch (e, stackTrace) {
    debugPrint('Error initializing Supabase: $e');
    debugPrint('Stack trace: $stackTrace');
    // Continue execution to show UI with error state
  }

  // Initialize performance optimization systems
  try {
    debugPrint('Initializing performance optimization systems');
    PerformanceOptimizer().initialize();
    debugPrint('Performance optimization systems initialized');
  } catch (e, stackTrace) {
    debugPrint('Error initializing performance systems: $e');
    debugPrint('Stack trace: $stackTrace');
  }

  // Initialize deep link service
  try {
    debugPrint('Initializing deep link service');
    await DeepLinkService().initialize(appRouter);
    debugPrint('Deep link service initialized');
  } catch (e, stackTrace) {
    debugPrint('Error initializing deep link service: $e');
    debugPrint('Stack trace: $stackTrace');
  }

  // Initialize database if needed - with more careful handling
  if (AppConfig.isDevelopment) {
    try {
      debugPrint('Initializing database');
      
      // First verify the Supabase instance is properly initialized
      final client = Supabase.instance.client;
      final databaseInitializer = DatabaseInitializer(client);
      
      // Wait a short delay to ensure auth is ready
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Initialize the database
      await databaseInitializer.ensureDatabaseInitialized();
      debugPrint('Database initialization complete');
    } catch (e, stackTrace) {
      debugPrint('Error initializing database: $e');
      debugPrint('Stack trace: $stackTrace');
      // Continue anyway, as the database might already be set up
    }
  }
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeProvider);
    
    return MaterialApp.router(
      title: 'Wealth App',
      theme: app_theme.AppTheme.lightTheme(),
      darkTheme: app_theme.AppTheme.darkTheme(),
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: [
          const Breakpoint(start: 0, end: 450, name: MOBILE),
          const Breakpoint(start: 451, end: 800, name: TABLET),
          const Breakpoint(start: 801, end: 1920, name: DESKTOP),
          const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
        ],
      ),
    );
  }
}
