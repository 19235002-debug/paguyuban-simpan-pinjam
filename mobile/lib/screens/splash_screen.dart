import 'dart:async';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../widgets/liquid_aquarium_loader.dart';
import 'login_screen.dart';
import 'member_nav.dart';
import 'admin_nav.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  Widget? _nextScreen;

  @override
  void initState() {
    super.initState();
    
    // Set up the aquarium water fill animation (2.5 seconds)
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    
    _progressController.forward();

    // Start loading session data in parallel
    _loadSessionAndPrepare();
  }

  Future<void> _loadSessionAndPrepare() async {
    final startTime = DateTime.now();
    Widget destination = const LoginScreen();

    try {
      final token = await StorageService.getToken();
      final user = await StorageService.getUser();

      if (token != null && user != null) {
        final lastActive = await StorageService.getLastActive();
        final now = DateTime.now();
        const sessionTimeout = Duration(minutes: 5);

        if (lastActive != null && now.difference(lastActive) > sessionTimeout) {
          await StorageService.clear();
          destination = const LoginScreen();
        } else {
          await StorageService.saveLastActive(now);
          final role = user['role'];
          destination = role == 'pengurus'
              ? const AdminNavigationShell()
              : const MemberNavigationShell();
        }
      } else {
        destination = const LoginScreen();
      }
    } catch (_) {
      destination = const LoginScreen();
    }

    _nextScreen = destination;

    // Wait until the animation completes (at least 2.5s)
    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    final remaining = 2500 - elapsed;
    if (remaining > 0) {
      await Future.delayed(Duration(milliseconds: remaining));
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => _nextScreen!,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const tealColor = Color(0xFF0D9488);
    const mintColor = Color(0xFF2DD4BF);
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF082F49), Color(0xFF0F172A), Color(0xFF115E59)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Ambient glowing circles for modern mesh effect
              Positioned(
                top: -100,
                right: -50,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: mintColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: -150,
                left: -100,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    color: tealColor.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Premium Glassmorphic container for logo
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 32,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/logo.png',
                        width: 90,
                        height: 90,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'KOPERASI PAGUYUBAN',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'BRAVO BEKASI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 80),
                    
                    // Liquid Filling Aquarium with Premium Stats
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        final int percent = (_progressAnimation.value * 100).toInt();
                        return Column(
                          children: [
                            LiquidAquariumLoader(
                              progress: _progressAnimation.value,
                              size: 130,
                              color: mintColor,
                            ),
                            const SizedBox(height: 28),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(mintColor.withValues(alpha: 0.8)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Memuat Sistem... $percent%',
                                    style: const TextStyle(
                                      color: Color(0xE6FFFFFF),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
