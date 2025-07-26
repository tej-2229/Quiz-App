import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/features/auth/data/models/user_model.dart';
import 'package:quiz_app/features/auth/providers/auth_provider.dart';
import 'package:quiz_app/features/quiz/data/models/quiz_category_model.dart';
import 'package:quiz_app/features/quiz/presentation/view/quiz_view.dart';
import 'package:quiz_app/features/quiz/providers/quiz_providers.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  String _greeting = 'Good morning';

  @override
  void initState() {
    super.initState();
    _updateGreeting();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.4, end: 0.6).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateGreeting() {
    final hour = DateTime.now().hour;
    setState(() {
      if (hour < 12) {
        _greeting = 'Good morning';
      } else if (hour < 18) {
        _greeting = 'Good afternoon';
      } else {
        _greeting = 'Good evening';
      }
    });
  }

  Future<void> _startRandomQuiz() async {
    HapticFeedback.lightImpact();
    final categories = ref.read(categoriesProvider).value;
    if (categories == null || categories.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No categories available')));
      return;
    }

    final random = Random();
    final randomCategory = categories[random.nextInt(categories.length)];
    _navigateToQuiz(randomCategory.id, randomCategory.name);
  }

  void _navigateToQuiz(String categoryId, String categoryName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            QuizView(categoryId: categoryId, categoryName: categoryName),
      ),
    );
  }

  void _showFeatureMessage(String feature) {
    HapticFeedback.lightImpact();

    if (feature == 'Profile') {
      context.go('/profile-view');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$feature feature would be implemented here')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(authStateProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error loading categories: $error')),
        data: (categories) {
          final user = userAsync.value;
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(user),
                _buildWelcomeSection(),
                _buildQuizCategories(categories),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(AppUser? user) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
      child: Column(
        children: [
          _buildHeaderTop(user),
          const SizedBox(height: 20),
          _buildStatsRow(user),
        ],
      ),
    );
  }

  Widget _buildHeaderTop(AppUser? user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _greeting,
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            Text(
              user?.fullName.split(' ').first ?? 'Guest',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => _showFeatureMessage('Profile'),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    user?.fullName.isNotEmpty ?? false
                        ? user!.fullName[0].toUpperCase()
                        : 'G',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(AppUser? user) {
    final userData = user != null
        ? ref.watch(userDataProvider(user.uid))
        : null;

    return userData?.when(
          loading: () => const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatCard(number: '--', label: 'Quizzes'),
              _StatCard(number: '--%', label: 'Avg Score'),
              _StatCard(number: '--', label: 'Day Streak'),
            ],
          ),
          error: (error, stack) => const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatCard(number: '0', label: 'Quizzes'),
              _StatCard(number: '0%', label: 'Avg Score'),
              _StatCard(number: '0', label: 'Day Streak'),
            ],
          ),
          data: (appUser) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatCard(
                number: '${appUser?.quizzesCompleted ?? 0}',
                label: 'Quizzes',
              ),
              _StatCard(
                number: '${(appUser?.averageScore ?? 0).toStringAsFixed(0)}%',
                label: 'Avg Score',
              ),
              _StatCard(
                number: '${appUser?.dayStreak ?? 0}',
                label: 'Day Streak',
              ),
            ],
          ),
        ) ??
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _StatCard(number: '0', label: 'Quizzes'),
            _StatCard(number: '0%', label: 'Avg Score'),
            _StatCard(number: '0', label: 'Day Streak'),
          ],
        );
  }

  Widget _buildWelcomeSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            ).createShader(bounds),
            child: const Text(
              'Ready to Quiz?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Challenge yourself with our wide range of topics',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
          ElevatedButton(
            onPressed: _startRandomQuiz,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667EEA),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 8,
              shadowColor: const Color(0xFF667EEA).withOpacity(0.3),
            ),
            child: const Text(
              '🚀 Start Random Quiz',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCategories(List<QuizCategory> categories) {
    if (categories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Center(child: Text('No categories available')),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose Your Category',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              if (category.questionCount == 0) {
                return _buildEmptyCategoryCard(category);
              }
              return _CategoryCard(
                icon: category.icon,
                name: category.name,
                count: '${category.questionCount} Questions',
                onTap: () => _navigateToQuiz(category.id, category.name),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCategoryCard(QuizCategory category) {
    return Card(
      color: Colors.grey[200],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              category.icon,
              style: const TextStyle(fontSize: 36, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              '${category.name} (Coming Soon)',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String number;
  final String label;

  const _StatCard({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You\'ve completed $number $label!')),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Text(
                number,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String icon;
  final String name;
  final String count;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.icon,
    required this.name,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon, style: const TextStyle(fontSize: 36)),
              const SizedBox(height: 12),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                count,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String icon;
  final String text;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 8),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String icon;
  final String title;
  final String time;
  final String score;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.time,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(icon, style: const TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        Text(
          score,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF667EEA),
          ),
        ),
      ],
    );
  }
}
