import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive_layout.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePin = true;
  bool _obscureConfirmPin = true;
  bool _agreeToTerms = false;

  String? _selectedCampus;
  final List<String> _campuses = [
    'Main Campus',
    'East Campus',
    'North Campus',
    'South Campus',
    'Accra City Campus',
  ];

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapper(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Create Account'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  const Text('Join VERIDIS', style: AppTextStyles.displayMedium),
                  const SizedBox(height: 6),
                  const Text(
                    'Create your account to start recycling and earning rewards',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Full Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'Enter your full name',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      if (value.length < 3) {
                        return 'Name must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

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
                      final digits = value.replaceAll(RegExp(r'\D'), '');
                      if (digits.length != 9) {
                        return 'Please enter a valid Ghanaian number (9 digits)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Student/Staff ID
                  TextFormField(
                    controller: _idController,
                    decoration: const InputDecoration(
                      labelText: 'Student/Staff ID',
                      hintText: 'e.g., ACU123456',
                      prefixIcon: Icon(Icons.badge),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your campus ID';
                      }
                      if (value.length < 6) {
                        return 'ID must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Campus Selection
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCampus,
                    decoration: const InputDecoration(
                      labelText: 'Select Campus',
                      prefixIcon: Icon(Icons.school),
                    ),
                    items: _campuses.map((String campus) {
                      return DropdownMenuItem<String>(
                        value: campus,
                        child: Text(campus),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() => _selectedCampus = newValue);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select your campus';
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
                      labelText: 'Create PIN (4-6 digits)',
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
                        return 'Please create a PIN';
                      }
                      if (value.length < 4 || value.length > 6) {
                        return 'PIN must be 4-6 digits';
                      }
                      if (!RegExp(r'^\d+$').hasMatch(value)) {
                        return 'PIN must contain only numbers';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Confirm PIN
                  TextFormField(
                    controller: _confirmPinController,
                    obscureText: _obscureConfirmPin,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Confirm PIN',
                      prefixIcon: const Icon(Icons.lock_reset),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPin
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textSubtle,
                        ),
                        onPressed: () => setState(
                            () => _obscureConfirmPin = !_obscureConfirmPin),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your PIN';
                      }
                      if (value != _pinController.text) {
                        return 'PINs do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Terms & Conditions
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        onChanged: (value) =>
                            setState(() => _agreeToTerms = value!),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            const Text(
                              'I agree to the Terms & Conditions',
                              style: AppTextStyles.bodyLarge,
                            ),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () {
                                // TODO: Show terms & conditions
                              },
                              child: const Text(
                                'Read Terms & Conditions',
                                style: TextStyle(
                                  color: AppColors.freshGreen,
                                  decoration: TextDecoration.underline,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Create Account button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleRegister,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : const Text('Create Account'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Already have account
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: AppTextStyles.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Campus info box
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: AppDecorations.infoBox,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.freshGreen,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Campus Verification',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.freshGreen,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Your student/staff ID will be verified with campus records. '
                                'Please ensure it matches your official university ID.',
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      _showError('Please agree to the Terms & Conditions');
      return;
    }

    setState(() => _isLoading = true);

    // TODO: Implement Firebase registration
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    if (!mounted) return;
    _showSuccess();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorRed,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account created successfully!'),
        duration: Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _idController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }
}
