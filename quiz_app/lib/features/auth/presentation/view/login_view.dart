import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/features/auth/providers/auth_provider.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _showSuccessMessage = false;
  late AnimationController _animationController;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animations = List.generate(4, (index) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(index * 0.15, 1, curve: Curves.easeOut),
        ),
      );
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  // Update the _submitForm method in LoginView
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref
          .read(authProvider.notifier)
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            rememberMe: _rememberMe,
          );

      // Show success message
      setState(() => _showSuccessMessage = true);

      // Clear form fields
      _emailController.clear();
      _passwordController.clear();

      // The auth state listener will handle the navigation
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _forgotPassword() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Password reset email sent')));
  }

  void _goToSignup() => context.go('/signup-view');

  OutlineInputBorder _outlinedBorder({Color color = Colors.black12}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    if (authState is Authenticated) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.go('/home-view'),
      );
    }

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

          Center(
            child: SingleChildScrollView(
              child: Container(
                width: size.width > 480 ? 400 : size.width * 0.9,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLogo(),
                      const SizedBox(height: 30),
                      if (_showSuccessMessage) _buildSuccessMessage(),
                      _buildEmailField(theme),
                      const SizedBox(height: 20),
                      _buildPasswordField(theme),
                      const SizedBox(height: 18),
                      _buildFormOptions(size),
                      const SizedBox(height: 18),
                      _buildLoginButton(authState is Loading),
                      const SizedBox(height: 18),
                      _buildSignupLink(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Center(
                child: Text(
                  '?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: OverflowBox(
                  maxWidth: double.infinity,
                  maxHeight: double.infinity,
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                          -200 + 400 * (_animationController.value * 2 % 1),
                          -200 + 400 * (_animationController.value * 2 % 1),
                        ),
                        child: Transform.rotate(
                          angle: 0.785,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withOpacity(0.3),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const Text(
          'QuizMaster',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Welcome Back!',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Ready for your next challenge?',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFD4EDDA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC3E6CB)),
      ),
      margin: const EdgeInsets.only(bottom: 20),
      child: const Text(
        'Welcome back! Login successful.',
        style: TextStyle(color: Color(0xFF155724), fontSize: 14),
      ),
    );
  }

  Widget _buildEmailField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email Address',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Enter your email',
            prefixIcon: const Icon(Icons.email_outlined, size: 20),
            border: _outlinedBorder(),
            enabledBorder: _outlinedBorder(),
            focusedBorder: _outlinedBorder(color: const Color(0xFF667EEA)),
            errorBorder: _outlinedBorder(color: Colors.red),
            focusedErrorBorder: _outlinedBorder(color: Colors.red),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: 'Enter your password',
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: const Color(0xFF667EEA),
              ),
              onPressed: _togglePasswordVisibility,
            ),
            border: _outlinedBorder(),
            enabledBorder: _outlinedBorder(),
            focusedBorder: _outlinedBorder(color: const Color(0xFF667EEA)),
            errorBorder: _outlinedBorder(color: Colors.red),
            focusedErrorBorder: _outlinedBorder(color: Colors.red),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a password';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildFormOptions(Size size) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 480) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_buildRememberMe(), _buildForgotPassword()],
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRememberMe(),
              const SizedBox(height: 10),
              _buildForgotPassword(),
            ],
          );
        }
      },
    );
  }

  Widget _buildRememberMe() {
    return Row(
      children: [
        Checkbox(
          value: _rememberMe,
          onChanged: (value) {
            setState(() {
              _rememberMe = value ?? false;
            });
          },
          activeColor: const Color(0xFF667EEA),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        const Text(
          'Remember me',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return GestureDetector(
      onTap: _forgotPassword,
      child: const Text(
        'Forgot Password?',
        style: TextStyle(
          color: Color(0xFF667EEA),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildLoginButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF667EEA),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          shadowColor: const Color(0xFF667EEA).withOpacity(0.3),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Sign In',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Widget _buildSignupLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Don\'t have an account? '),
        GestureDetector(
          onTap: _goToSignup,
          child: const Text(
            'Sign Up',
            style: TextStyle(
              color: Color(0xFF667EEA),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
