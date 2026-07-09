import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/malihub_logo.dart';
import 'onboarding_screen.dart';

/// Brief branded launch screen. Shows the mark, then hands off to
/// onboarding (first launch) — a real app would check a "seen onboarding"
/// flag (e.g. shared_preferences) and skip straight to Login on repeat
/// opens; that's a TODO once local persistence is wired in.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn));
    _controller.forward();

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDeep,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const MalihubLogo(size: 88),
                const SizedBox(height: 20),
                const Text(
                  'Malihub',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your wealth, in one place',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
