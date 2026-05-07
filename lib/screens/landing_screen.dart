import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'auth/login_screen.dart';
import 'auth/signup_screen.dart';
import 'main_layout.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _flipController;
  late AnimationController _bgController;

  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _slideAnim;
  late Animation<double> _flipAnim;
  late Animation<double> _elevationAnim;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _flipController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _bgController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _fadeAnim = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _slideAnim = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _elevationAnim = Tween<double>(begin: 0, end: 30).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _flipAnim = Tween<double>(
      begin: 0,
      end: math.pi * 2,
    ).animate(CurvedAnimation(parent: _flipController, curve: Curves.linear));

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _flipController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  Widget _buildMeshBackground(ColorScheme cs) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, _) {
        return Stack(
          children: [
            Positioned(
              top: -100 + (math.sin(_bgController.value * math.pi * 2) * 50),
              left: -100 + (math.cos(_bgController.value * math.pi * 2) * 50),
              child: _BlurredCircle(color: cs.primary.withOpacity(0.15), size: 400),
            ),
            Positioned(
              bottom: -50 + (math.cos(_bgController.value * math.pi * 2) * 80),
              right: -50 + (math.sin(_bgController.value * math.pi * 2) * 80),
              child: _BlurredCircle(color: cs.tertiary.withOpacity(0.1), size: 350),
            ),
            Positioned(
              top: 200 + (math.sin(_bgController.value * math.pi * 2 + 1) * 100),
              right: -100 + (math.cos(_bgController.value * math.pi * 2 + 1) * 100),
              child: _BlurredCircle(color: cs.secondary.withOpacity(0.1), size: 300),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFlippingLogo(ColorScheme cs) {
    return AnimatedBuilder(
      animation: Listenable.merge([_flipAnim, _bgController]),
      builder: (context, _) {
        final float = math.sin(_bgController.value * math.pi * 2) * 8;
        return Transform.translate(
          offset: Offset(0, float),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Glow effect
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withOpacity(0.2),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(_flipAnim.value),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.surface.withOpacity(0.8),
                    boxShadow: [
                      BoxShadow(
                        color: cs.primary.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(color: cs.primary.withOpacity(0.2), width: 1.5),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/App_log.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
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
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isLogged = Supabase.instance.client.auth.currentSession != null;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          // 1. Dynamic Mesh Background
          _buildMeshBackground(cs),

          // 2. Main Content
          AnimatedBuilder(
            animation: _entryController,
            builder: (context, _) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const Spacer(flex: 3),

                      // Logo Section
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: ScaleTransition(
                          scale: _scaleAnim,
                          child: _buildFlippingLogo(cs),
                        ),
                      ),

                      const Spacer(flex: 2),

                      // Title & Glass Card Section
                      Transform.translate(
                        offset: Offset(0, _slideAnim.value),
                        child: FadeTransition(
                          opacity: _fadeAnim,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: cs.surface.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(
                                color: cs.primary.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: [cs.primary, cs.secondary, cs.tertiary],
                                  ).createShader(bounds),
                                  child: Text(
                                    'VZHA',
                                    textAlign: TextAlign.center,
                                    style: tt.displaySmall?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -1,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'The definitive hub for modern developers. Connect, build, and grow together.',
                                  textAlign: TextAlign.center,
                                  style: tt.bodyLarge?.copyWith(
                                    color: cs.onSurfaceVariant,
                                    height: 1.5,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                
                                // Buttons
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    if (isLogged)
                                      _PrimaryButton(
                                        label: 'Go to dashboard',
                                        onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainLayout())),
                                      )
                                    else ...[
                                      _PrimaryButton(
                                        label: 'Sign in',
                                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                                      ),
                                      const SizedBox(height: 12),
                                      OutlinedButton(
                                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen())),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 18),
                                          side: BorderSide(color: cs.primary.withOpacity(0.3)),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                        ),
                                        child: Text(
                                          'Create account',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: cs.onSurface,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const Spacer(flex: 3),

                      // Footer
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: Text(
                          'Version 2.0 • Proudly Open Source',
                          textAlign: TextAlign.center,
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant.withOpacity(0.4),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BlurredCircle extends StatelessWidget {
  final Color color;
  final double size;

  const _BlurredCircle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    ).withBlur(100);
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PrimaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [cs.primary, cs.primary.withOpacity(0.8)],
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          backgroundColor: Colors.transparent,
          foregroundColor: cs.onPrimary,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

extension on Widget {
  Widget withBlur(double sigma) => ClipRect(
        child: ImageFiltered(
          imageFilter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: this,
        ),
      );
}
