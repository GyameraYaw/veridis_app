import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _obscurePin = true;

  @override
  Widget build(BuildContext context) {
    final heroHeight = MediaQuery.of(context).size.height * 0.32;
    final clampedHeroHeight = heroHeight.clamp(200.0, 280.0);

    return ResponsiveWrapper(
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Column(
          children: [
            // ── Hero section ──────────────────────────────────────────────
            Container(
              height: clampedHeroHeight,
              width: double.infinity,
              decoration: AppDecorations.loginHero,
              child: SafeArea(
                bottom: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.recycling,
                      size: 64,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    const Text('VERIDIS', style: AppTextStyles.heroDisplayLarge),
                    const SizedBox(height: 6),
                    const Text(
                      'Smart Campus Recycling',
                      style: AppTextStyles.heroLabel,
                    ),
                  ],
                ),
              ),
            ),

            // ── Form section ──────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Welcome Back', style: AppTextStyles.headlineMedium),
                    const SizedBox(height: 6),
                    const Text(
                      'Sign in to continue recycling and earning rewards',
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Phone Number
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixText: '+233 ',
                        hintText: 'XX XXX XXXX',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (value.length != 9) {
                          return 'Please enter a valid Ghanaian number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // PIN
                    TextFormField(
                      controller: _pinController,
                      obscureText: _obscurePin,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'PIN',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePin
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.textSubtle,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePin = !_obscurePin),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your PIN';
                        }
                        if (value.length < 4) {
                          return 'PIN must be at least 4 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Remember me & Forgot PIN
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) =>
                                  setState(() => _rememberMe = value!),
                            ),
                            const Text(
                              'Remember me',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Forgot PIN?'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Sign In button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : const Text('Sign In'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Divider
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md),
                          child: Text('or', style: AppTextStyles.bodyMedium),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Sign Up
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: AppTextStyles.bodyMedium,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Campus info box
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: AppDecorations.infoBox,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.freshGreen,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'For Academic City University students and staff only. '
                              'Use your registered campus phone number.',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogin() async {
    if (_phoneController.text.isEmpty || _pinController.text.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    final phoneNumber = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (phoneNumber.length != 9) {
      _showError('Please enter a valid Ghanaian phone number (9 digits)');
      return;
    }

    if (_pinController.text.length < 4) {
      _showError('PIN must be at least 4 digits');
      return;
    }

    setState(() => _isLoading = true);

    // TODO: Implement Firebase Authentication
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Welcome back!')),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorRed,
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }
}
