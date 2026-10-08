import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'services/storage_service.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize local Indonesian date formatting data
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  static const Duration _sessionTimeout = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      StorageService.saveLastActive(DateTime.now());
    } else if (state == AppLifecycleState.resumed) {
      _checkSessionTimeout();
    }
  }

  Future<void> _checkSessionTimeout() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return;

      final lastActive = await StorageService.getLastActive();
      final now = DateTime.now();

      if (lastActive != null && now.difference(lastActive) > _sessionTimeout) {
        // Session expired
        await StorageService.clear();
        
        // Force redirect to login screen
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } else {
        // Session still valid, update last active time
        await StorageService.saveLastActive(now);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Paguyuban Bravo Bekasi',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const NoOverscrollBehavior(),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Default light theme with full darkTheme capability
      home: const SplashScreen(),
    );
  }
}

class NoOverscrollBehavior extends MaterialScrollBehavior {
  const NoOverscrollBehavior();

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }
}
