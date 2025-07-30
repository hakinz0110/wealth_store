import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'services/supabase_service.dart';
import 'services/deep_link_service.dart';
import 'shared/themes/app_theme.dart';
import 'shared/constants/app_constants.dart';
import 'shared/utils/logger.dart';
import 'shared/utils/error_handler.dart';
import 'shared/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Supabase with enhanced error handling
    await SupabaseService.initialize();
    Logger.info('Application initialized successfully');
    
    runApp(
      const ProviderScope(
        child: WealthStoreAdminApp(),
      ),
    );
  } catch (e, stackTrace) {
    ErrorHandler.handleError('Application initialization', e, stackTrace);
    
    // Show error app if initialization fails
    runApp(
      MaterialApp(
        title: 'Wealth Store Admin - Error',
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Failed to initialize application',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  ErrorHandler.getErrorMessage(e),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Restart the app
                    main();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WealthStoreAdminApp extends ConsumerStatefulWidget {
  const WealthStoreAdminApp({super.key});

  @override
  ConsumerState<WealthStoreAdminApp> createState() => _WealthStoreAdminAppState();
}

class _WealthStoreAdminAppState extends ConsumerState<WealthStoreAdminApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDeepLinks();
    });
  }

  Future<void> _initializeDeepLinks() async {
    try {
      final router = ref.read(appRouterProvider);
      await DeepLinkService().initialize(router);
    } catch (e) {
      Logger.error('Failed to initialize deep links', e);
    }
  }

  @override
  void dispose() {
    DeepLinkService().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    
    return ResponsiveBreakpoints.builder(
      child: MaterialApp.router(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
      breakpoints: [
        const Breakpoint(start: 0, end: 450, name: MOBILE),
        const Breakpoint(start: 451, end: 800, name: TABLET),
        const Breakpoint(start: 801, end: 1920, name: DESKTOP),
        const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
      ],
    );
  }
}

