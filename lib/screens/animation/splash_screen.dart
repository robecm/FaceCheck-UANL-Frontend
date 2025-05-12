import 'package:flutter/material.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    // Move circle to center (first 35% of animation)
    _positionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOutCubic),
      ),
    );

    // Expand circle to fill screen (35% to 75% of animation)
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 20.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.75, curve: Curves.easeOutQuart),
      ),
    );

    // Fade out at the end (last 25% of animation)
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.75, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Transition background color
    _colorAnimation = ColorTween(
      begin: Colors.green,
      end: Colors.white,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pushReplacementNamed(context, '/login_selection');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double maxScale = size.height > size.width
        ? size.height / 50
        : size.width / 50;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Calculate circle opacity (clamped to valid range)
        final circleOpacity = _controller.value <= 0.75
            ? 1.0
            : math.max(0.0, math.min(1.0, _opacityAnimation.value));

        // Calculate title opacity (clamped to valid range)
        final titleOpacity = _controller.value <= 0.35
            ? math.max(0.0, math.min(1.0, _positionAnimation.value))
            : math.max(0.0, math.min(1.0, 1.0 - ((_controller.value - 0.35) / 0.4)));

        return Scaffold(
          backgroundColor: _colorAnimation.value,
          body: Stack(
            children: [
              // Animated circle
              Center(
                child: Opacity(
                  opacity: circleOpacity,
                  child: Transform.translate(
                    offset: Offset(0.0, 200 * (1 - _positionAnimation.value)),
                    child: Transform.scale(
                      scale: _controller.value <= 0.35 ? 1.0 :
                             1.0 + (_scaleAnimation.value - 1.0) * maxScale / 20,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.school,
                            color: Colors.green,
                            size: 50,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}