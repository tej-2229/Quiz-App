import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class AuthGuard extends ConsumerWidget {
  final Widget child;
  
  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    return authState.when(
      initial: () => const Center(child: CircularProgressIndicator()),
      loading: () => const Center(child: CircularProgressIndicator()),
      authenticated: (user) => child,
      unauthenticated: () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/login');
        });
        return const Center(child: CircularProgressIndicator());
      },
      error: (message) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/login');
        });
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}