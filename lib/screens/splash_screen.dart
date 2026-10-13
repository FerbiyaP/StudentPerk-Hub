import 'package:flutter/material.dart';
import 'auth/login_screen.dart';
import '../bottom_navigation/home_screen.dart';
import 'onboarding_screen.dart';
import 'package:stuentperk_hub/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();

    // Check auth status after splash animation
    Future.delayed(const Duration(seconds: 3), _routeNext);
  }

  Future<void> _routeNext() async {
    if (!mounted) return;

    final bool isLoggedIn = AuthService.instance.isLoggedIn;

    if (!isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
      return;
    }

    final bool emailVerified = AuthService.instance.emailVerified;

    if (!emailVerified) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B5FEF),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5B5FEF).withValues(alpha: 0.25),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    size: 65,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 30),

                // App name
                const Text(
                  'StudentPerk Hub',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172554),
                  ),
                ),

                const SizedBox(height: 10),

                // Tagline
                const Text(
                  'Your Student Life, Supercharged',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF64748B),
                  ),
                ),

                const SizedBox(height: 45),

                // Loading indicator
                const SizedBox(
                  width: 35,
                  height: 35,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF5B5FEF),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
