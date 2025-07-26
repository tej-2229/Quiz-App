// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:go_router/go_router.dart';

// class ProfileView extends StatefulWidget {
//   const ProfileView({super.key});

//   @override
//   State<ProfileView> createState() => _ProfileViewState();
// }

// class _ProfileViewState extends State<ProfileView>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   final ScrollController _scrollController = ScrollController();
//   double _headerOffset = 0;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1000),
//     )..forward();

//     _scrollController.addListener(_handleScroll);
//   }

//   void _handleScroll() {
//     setState(() {
//       _headerOffset = _scrollController.offset * 0.5;
//     });
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isSmallScreen = screenWidth < 480;

//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: SystemUiOverlayStyle.light,
//       child: Scaffold(
//         body: Stack(
//           children: [
//             // Background
//             Container(
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
//                 ),
//               ),
//             ),

//             // Content
//             CustomScrollView(
//               controller: _scrollController,
//               slivers: [
//                 // Profile Section
//                 SliverToBoxAdapter(
//                   child: Column(
//                     children: [
//                       const SizedBox(height: 48),
//                       Row(
//                         children: [
//                           IconButton(
//                             icon: const Icon(
//                               Icons.arrow_back,
//                               color: Colors.white,
//                             ),
//                             onPressed: () => context.go('/home-view'),
//                           ),
//                           const SizedBox(width: 120),
//                           Text(
//                             'My Profile',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 20,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 48),
//                       _buildProfileSection(theme, isSmallScreen),
//                     ],
//                   ),
//                 ),

//                 // Stats Grid
//                 SliverPadding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   sliver: SliverGrid(
//                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: isSmallScreen ? 2 : 4,
//                       crossAxisSpacing: 15,
//                       mainAxisSpacing: 15,
//                       childAspectRatio: 1,
//                     ),
//                     delegate: SliverChildBuilderDelegate(
//                       (context, index) => _buildStatCard(index, theme),
//                       childCount: 4,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProfileSection(ThemeData theme, bool isSmallScreen) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       transform: Matrix4.translationValues(0, _headerOffset, 0),
//       margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
//       padding: const EdgeInsets.all(25),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(25),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // Avatar
//           Stack(
//             alignment: Alignment.center,
//             children: [
//               Container(
//                 width: isSmallScreen ? 80 : 100,
//                 height: isSmallScreen ? 80 : 100,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF667EEA),
//                   borderRadius: BorderRadius.circular(50),
//                   border: Border.all(color: const Color(0xFF667EEA), width: 4),
//                 ),
//                 child: const Center(
//                   child: Text(
//                     'A',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 36,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 bottom: 5,
//                 right: 5,
//                 child: Container(
//                   width: 28,
//                   height: 28,
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF4CAF50),
//                     borderRadius: BorderRadius.circular(14),
//                     border: Border.all(color: Colors.white, width: 3),
//                   ),
//                   child: const Center(
//                     child: Text(
//                       '✓',
//                       style: TextStyle(color: Colors.white, fontSize: 14),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),

//           // User Info
//           const Text(
//             'Alex Johnson',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF2C3E50),
//             ),
//           ),
//           const SizedBox(height: 5),
//           const Text(
//             'Level 12 • Quiz Master',
//             style: TextStyle(
//               fontSize: 14,
//               color: Color(0xFF667EEA),
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 20),

//           // Progress Bar
//           Container(
//             height: 8,
//             decoration: BoxDecoration(
//               color: Colors.grey[200],
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Stack(
//               children: [
//                 LayoutBuilder(
//                   builder: (context, constraints) {
//                     return AnimatedContainer(
//                       duration: const Duration(milliseconds: 1500),
//                       width: constraints.maxWidth * 0.65,
//                       decoration: BoxDecoration(
//                         gradient: const LinearGradient(
//                           colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
//                         ),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 10),
//           const Text(
//             '2,450 / 3,000 XP to Level 13',
//             style: TextStyle(fontSize: 12, color: Colors.grey),
//             textAlign: TextAlign.right,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatCard(int index, ThemeData theme) {
//     final stats = [
//       {
//         'icon': '🏆',
//         'value': '127',
//         'label': 'Quizzes Won',
//         'color': Color(0xFF4CAF50),
//       },
//       {
//         'icon': '🎯',
//         'value': '89%',
//         'label': 'Accuracy',
//         'color': Color(0xFF2196F3),
//       },
//       {
//         'icon': '⚡',
//         'value': '15',
//         'label': 'Win Streak',
//         'color': Color(0xFFFF9800),
//       },
//       {
//         'icon': '⏱️',
//         'value': '2:14',
//         'label': 'Avg Time',
//         'color': Color(0xFF9C27B0),
//       },
//     ];

//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeOut,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 8,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(20),
//         onTap: () {},
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 stats[index]['icon'] as String,
//                 style: const TextStyle(fontSize: 24),
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 stats[index]['value'] as String,
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: const Color(0xFF2C3E50),
//                 ),
//               ),
//               const SizedBox(height: 5),
//               Text(
//                 stats[index]['label'] as String,
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey,
//                   fontWeight: FontWeight.w600,
//                   letterSpacing: 1,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:quiz_app/features/auth/data/models/user_model.dart';
import 'package:quiz_app/features/auth/providers/auth_provider.dart';

class ProfileView extends ConsumerStatefulWidget {
  final String userId;
  
  const ProfileView({super.key, required this.userId});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  double _headerOffset = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    setState(() {
      _headerOffset = _scrollController.offset * 0.5;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userDataProvider(widget.userId));
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 480;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Stack(
          children: [
            // Background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
              ),
            ),

            // Content
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Profile Section
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 48),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () => context.go('/home-view'),
                          ),
                          const SizedBox(width: 120),
                          Text(
                            'My Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                      userAsync.when(
                        loading: () => _buildLoadingProfileSection(theme, isSmallScreen),
                        error: (error, stack) => _buildErrorProfileSection(theme, isSmallScreen, error.toString()),
                        data: (user) => _buildProfileSection(theme, isSmallScreen, user!),
                      ),
                    ],
                  ),
                ),

                // Stats Grid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isSmallScreen ? 2 : 4,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 1,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => userAsync.when(
                        loading: () => _buildLoadingStatCard(index, theme),
                        error: (error, stack) => _buildErrorStatCard(index, theme),
                        data: (user) => _buildStatCard(index, theme, user!),
                      ),
                      childCount: 4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingProfileSection(ThemeData theme, bool isSmallScreen) {
    return _buildProfileSection(
      theme, 
      isSmallScreen, 
      AppUser(
        uid: '',
        fullName: 'Loading...',
        email: '',
        quizzesCompleted: 0,
        averageScore: 0,
        dayStreak: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  Widget _buildErrorProfileSection(ThemeData theme, bool isSmallScreen, String error) {
    return _buildProfileSection(
      theme, 
      isSmallScreen, 
      AppUser(
        uid: '',
        fullName: 'Error loading data',
        email: error,
        quizzesCompleted: 0,
        averageScore: 0,
        dayStreak: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  Widget _buildProfileSection(ThemeData theme, bool isSmallScreen, AppUser user) {
    // Format the initials for the avatar
    final initials = user.fullName.isNotEmpty 
        ? user.fullName.split(' ').map((n) => n[0]).take(2).join()
        : '?';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      transform: Matrix4.translationValues(0, _headerOffset, 0),
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: isSmallScreen ? 80 : 100,
                height: isSmallScreen ? 80 : 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF667EEA),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: const Color(0xFF667EEA), width: 4),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 5,
                right: 5,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Center(
                    child: Text(
                      '✓',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // User Info
          Text(
            user.fullName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Member since ${DateFormat('MMM yyyy').format(user.createdAt)}',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF667EEA),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),

          // Progress Bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final progress = user.dayStreak / 30; // Assuming 30 days for next level
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 1500),
                      width: constraints.maxWidth * progress.clamp(0.0, 1.0),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${user.dayStreak} / 30 days to next level',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingStatCard(int index, ThemeData theme) {
    return _buildStatCard(
      index, 
      theme, 
      AppUser(
        uid: '',
        fullName: '',
        email: '',
        quizzesCompleted: 0,
        averageScore: 0,
        dayStreak: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  Widget _buildErrorStatCard(int index, ThemeData theme) {
    return _buildStatCard(
      index, 
      theme, 
      AppUser(
        uid: '',
        fullName: '',
        email: 'Error',
        quizzesCompleted: 0,
        averageScore: 0,
        dayStreak: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  Widget _buildStatCard(int index, ThemeData theme, AppUser user) {
    final stats = [
      {
        'icon': '🏆',
        'value': '${user.quizzesCompleted}',
        'label': 'Quizzes Completed',
        'color': const Color(0xFF4CAF50),
      },
      {
        'icon': '🎯',
        'value': '${user.averageScore.toStringAsFixed(1)}%',
        'label': 'Avg Score',
        'color': const Color(0xFF2196F3),
      },
      {
        'icon': '⚡',
        'value': '${user.dayStreak}',
        'label': 'Day Streak',
        'color': const Color(0xFFFF9800),
      },
      {
        'icon': '⏱️',
        'value': DateFormat('MMM yyyy').format(user.updatedAt),
        'label': 'Last Active',
        'color': const Color(0xFF9C27B0),
      },
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                stats[index]['icon'] as String,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 10),
              Text(
                stats[index]['value'] as String,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                stats[index]['label'] as String,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}