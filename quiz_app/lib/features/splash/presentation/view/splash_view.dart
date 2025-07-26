import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/features/auth/providers/auth_provider.dart';
import 'package:quiz_app/features/splash/presentation/widgets/floating_quiz_icons.dart';
import 'package:quiz_app/features/splash/presentation/widgets/glow_effect.dart';
import 'package:quiz_app/features/splash/presentation/widgets/loading_section.dart';
import 'package:quiz_app/features/splash/presentation/widgets/logo_animation.dart';
import 'package:quiz_app/features/splash/presentation/widgets/particles_background.dart';
import 'package:quiz_app/features/splash/presentation/widgets/title_slide_animation.dart';
import 'package:quiz_app/features/splash/providers/splash_provider.dart';

class SplashView extends ConsumerStatefulWidget {
  const SplashView({super.key});

  @override
  ConsumerState<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView> 
    with SingleTickerProviderStateMixin {
  late AnimationController _loadingController;
  late Animation<double> _loadingAnimation;
  bool _shouldNavigate = false;
  bool _loadingComplete = false;

  @override
  void initState() {
    super.initState();
    
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    
    _loadingAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _loadingController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  void _handleNavigation(AuthState authState) {
    if (_loadingComplete && !_shouldNavigate) {
      _shouldNavigate = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        authState.whenOrNull(
          initial: () => context.go('/login-view'),
          loading: () => context.go('/login-view'),
          authenticated: (user) => context.go('/home-view'),
          unauthenticated: () => context.go('/login-view'),
          error: (message) => context.go('/login-view'),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final splashState = ref.watch(splashProvider);
    final authState = ref.watch(authProvider);

    // Check if loading is complete
    if (splashState.loadingTextIndex == 4) {
      _loadingComplete = true;
      _handleNavigation(authState);
    }

    // Listen to auth state changes
    ref.listen<AuthState>(authProvider, (_, state) {
      _handleNavigation(state);
    });

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
            ),
          ),
          const Center(child: GlowEffect()),
          const ParticlesBackground(),
          const FloatingQuizIcons(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const LogoAnimation(),
                const TitleSlideAnimation(),
                LoadingSection(
                  controller: _loadingController,
                  animation: _loadingAnimation,
                  loadingText: splashState.loadingTexts[splashState.loadingTextIndex],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}