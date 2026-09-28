import 'dart:async';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../auth/screens/login_screen.dart';
import '../navigation/main_navigation_screen.dart';

import '../../core/services/guest_session_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  Timer? _navigationTimer;

  late final AnimationController _orbitController;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
      lowerBound: 0.96,
      upperBound: 1.04,
    )..repeat(reverse: true);

    _navigationTimer = Timer(
      const Duration(seconds: 4),
      _openNextScreen,
    );
  }

  Future<void> _openNextScreen() async {
    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;
    final isGuest = await GuestSessionService.isGuest();

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 750),
        pageBuilder: (_, animation, secondaryAnimation) {
          // Logged-in users OR guests can enter the app.
          if (user != null || isGuest) {
            return const MainNavigationScreen();
          }

          return const LoginScreen();
        },
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );

          return FadeTransition(
            opacity: curvedAnimation,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.98,
                end: 1,
              ).animate(curvedAnimation),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _orbitController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B1F),
      body: Stack(
        children: [
          const Positioned.fill(
            child: _AnimatedBackground(),
          ),

          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLogoSection(),

                    const SizedBox(height: 38),

                    const Text(
                      'Kiddo Learn',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                      ),
                    )
                        .animate()
                        .fadeIn(
                      delay: 600.ms,
                      duration: 700.ms,
                    )
                        .slideY(
                      begin: 0.30,
                      end: 0,
                      curve: Curves.easeOutBack,
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Learn  •  Play  •  Grow',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFB8D9FF),
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                      ),
                    )
                        .animate()
                        .fadeIn(
                      delay: 900.ms,
                      duration: 700.ms,
                    ),

                    const SizedBox(height: 48),

                    _buildLoadingSection(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return SizedBox(
      width: 290,
      height: 290,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _orbitController,
          _pulseController,
        ]),
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: _orbitController.value * 2 * math.pi,
                child: Container(
                  width: 270,
                  height: 270,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF2FA8FF)
                          .withValues(alpha: 0.35),
                      width: 2,
                    ),
                  ),
                  child: const Stack(
                    children: [
                      _OrbitItem(
                        alignment: Alignment.topCenter,
                        icon: Icons.abc_rounded,
                        color: Color(0xFFFFD83D),
                      ),
                      _OrbitItem(
                        alignment: Alignment.centerRight,
                        icon: Icons.palette_rounded,
                        color: Color(0xFFFF6B8A),
                      ),
                      _OrbitItem(
                        alignment: Alignment.bottomCenter,
                        icon: Icons.numbers_rounded,
                        color: Color(0xFF59E0A7),
                      ),
                      _OrbitItem(
                        alignment: Alignment.centerLeft,
                        icon: Icons.pets_rounded,
                        color: Color(0xFFB388FF),
                      ),
                    ],
                  ),
                ),
              ),

              Transform.rotate(
                angle: -_orbitController.value * 2 * math.pi,
                child: Container(
                  width: 230,
                  height: 230,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 1,
                    ),
                  ),
                ),
              ),

              ScaleTransition(
                scale: _pulseController,
                child: Container(
                  width: 190,
                  height: 190,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF0D4F95),
                        Color(0xFF052B5C),
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFF40B5FF),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2FA8FF)
                            .withValues(alpha: 0.45),
                        blurRadius: 35,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/panda_splash.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, error, stackTrace) {
                      return const Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 95,
                      );
                    },
                  ),
                )
                    .animate()
                    .fadeIn(
                  duration: 500.ms,
                )
                    .scale(
                  begin: const Offset(0.25, 0.25),
                  end: const Offset(1, 1),
                  duration: 1100.ms,
                  curve: Curves.elasticOut,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingSection() {
    return Column(
      children: [
        Container(
          width: 220,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20),
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: 0,
              end: 1,
            ),
            duration: const Duration(milliseconds: 3400),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: value,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF20A8FF),
                          Color(0xFF62E7FF),
                          Color(0xFFFFD83D),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF20A8FF)
                              .withValues(alpha: 0.55),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 18),

        const Text(
          'Preparing your learning adventure...',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        )
            .animate(
          onPlay: (controller) {
            controller.repeat(reverse: true);
          },
        )
            .fade(
          begin: 0.35,
          end: 1,
          duration: 850.ms,
        ),
      ],
    );
  }
}

class _OrbitItem extends StatelessWidget {
  final Alignment alignment;
  final IconData icon;
  final Color color;

  const _OrbitItem({
    required this.alignment,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF061B38),
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withValues(alpha: 0.85),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.40),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color,
          size: 27,
        ),
      ),
    );
  }
}

class _AnimatedBackground extends StatelessWidget {
  const _AnimatedBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.2,
              colors: [
                Color(0xFF0A3A72),
                Color(0xFF041C3E),
                Color(0xFF020B1F),
              ],
              stops: [0, 0.55, 1],
            ),
          ),
          child: SizedBox.expand(),
        ),

        const Positioned(
          top: 90,
          left: 30,
          child: _FloatingParticle(
            size: 8,
            color: Color(0xFFFFD83D),
          ),
        ),

        const Positioned(
          top: 170,
          right: 45,
          child: _FloatingParticle(
            size: 6,
            color: Color(0xFF2FA8FF),
          ),
        ),

        const Positioned(
          bottom: 180,
          left: 50,
          child: _FloatingParticle(
            size: 7,
            color: Color(0xFF59E0A7),
          ),
        ),

        const Positioned(
          bottom: 120,
          right: 30,
          child: _FloatingParticle(
            size: 9,
            color: Color(0xFFFF6B8A),
          ),
        ),
      ],
    );
  }
}

class _FloatingParticle extends StatelessWidget {
  final double size;
  final Color color;

  const _FloatingParticle({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.75),
            blurRadius: 12,
            spreadRadius: 3,
          ),
        ],
      ),
    )
        .animate(
      onPlay: (controller) {
        controller.repeat(reverse: true);
      },
    )
        .moveY(
      begin: -12,
      end: 12,
      duration: 1400.ms,
    )
        .fade(
      begin: 0.35,
      end: 1,
      duration: 1100.ms,
    );
  }
}