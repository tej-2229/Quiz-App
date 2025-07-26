import 'package:flutter_riverpod/flutter_riverpod.dart';

final splashProvider = StateNotifierProvider<SplashNotifier, SplashState>((ref) {
  return SplashNotifier();
});

class SplashNotifier extends StateNotifier<SplashState> {
  SplashNotifier() : super(SplashState.initial()) {
    _simulateLoading();
  }

  void _simulateLoading() {
    Future.delayed(const Duration(milliseconds: 500), () {
      state = state.copyWith(loadingTextIndex: 1);
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      state = state.copyWith(loadingTextIndex: 2);
    });
    Future.delayed(const Duration(milliseconds: 2500), () {
      state = state.copyWith(loadingTextIndex: 3);
    });
    Future.delayed(const Duration(milliseconds: 3500), () {
      state = state.copyWith(loadingTextIndex: 4);
    });
  }

  void reset() {
    state = SplashState.initial();
  }
}

class SplashState {
  final int loadingTextIndex;
  final List<String> loadingTexts;

  SplashState({
    required this.loadingTextIndex,
    required this.loadingTexts,
  });

  factory SplashState.initial() {
    return SplashState(
      loadingTextIndex: 0,
      loadingTexts: [
        'Initializing app...',
        'Checking authentication...',
        'Loading content...',
        'Finalizing setup...',
        'Ready to go! 🎉'
      ],
    );
  }

  SplashState copyWith({
    int? loadingTextIndex,
    List<String>? loadingTexts,
  }) {
    return SplashState(
      loadingTextIndex: loadingTextIndex ?? this.loadingTextIndex,
      loadingTexts: loadingTexts ?? this.loadingTexts,
    );
  }
}