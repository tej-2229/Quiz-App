import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/features/auth/presentation/auth_guard.dart';
import 'package:quiz_app/features/auth/presentation/view/login_view.dart';
import 'package:quiz_app/features/auth/presentation/view/signup_view.dart';
import 'package:quiz_app/features/home/presentation/view/home_view.dart';
import 'package:quiz_app/features/profile/presentation/view/profile_view.dart';
import 'package:quiz_app/features/splash/presentation/view/splash_view.dart';

final router = GoRouter(
  initialLocation: '/splash-view',
  routes: [
    GoRoute(
      path: '/splash-view',
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const SplashView()),
    ),
    GoRoute(
      path: '/login-view',
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const LoginView()),
    ),
    GoRoute(
      path: '/signup-view',
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const SignUpView()),
    ),
    GoRoute(
      path: '/home-view',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: AuthGuard(child: HomeView()),
      ),
    ),
    GoRoute(
      path: '/profile-view',
      pageBuilder: (context, state) {
        final userId = state.uri.queryParameters['userId'] ?? '';
        return MaterialPage(
          key: state.pageKey,
          child: ProfileView(userId: userId),
        );
      },
    ),
  ],
);
