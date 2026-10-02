import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/constants.dart';
import '../../core/routing/app_router.dart';
import '../../core/utils/utils.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_widgets.dart';

/// SignupScreen — full name + email + password + confirm password.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signup(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      context.go(AppRoutes.dashboard);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Signup failed.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Create Account', style: AppTypography.displayMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Join FinTrack and take control of your finances',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxxl),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AppTextField(
                          label: 'Full Name',
                          hint: 'Arjun Sharma',
                          controller: _nameController,
                          prefixIcon: Icons.person_outline_rounded,
                          validator: Validators.fullName,
                          textInputAction: TextInputAction.next,
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        AppTextField(
                          label: 'Email address',
                          hint: 'you@example.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: Validators.email,
                          textInputAction: TextInputAction.next,
                          onChanged: (_) => authProvider.clearError(),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        AppTextField(
                          label: 'Password',
                          controller: _passwordController,
                          isPassword: true,
                          prefixIcon: Icons.lock_outline_rounded,
                          validator: Validators.password,
                          textInputAction: TextInputAction.next,
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        AppTextField(
                          label: 'Confirm Password',
                          controller: _confirmController,
                          isPassword: true,
                          prefixIcon: Icons.lock_outline_rounded,
                          validator: (v) => Validators.confirmPassword(
                              v, _passwordController.text),
                          textInputAction: TextInputAction.done,
                        ),

                        const SizedBox(height: AppSpacing.sm),

                        // Password requirements hint
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            'Password must be at least 8 characters, include one uppercase letter and one number.',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xxl),

                        AppButton(
                          label: 'Create Account',
                          onPressed: _signup,
                          isLoading: authProvider.isLoading,
                        ),

                        const SizedBox(height: AppSpacing.xxl),

                        // Terms disclaimer
                        Text(
                          'By creating an account, you agree to our Terms of Service and Privacy Policy.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // Already have account
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.pop(),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                              ),
                              child: Text(
                                'Sign In',
                                style: AppTypography.labelLarge.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (authProvider.isLoading)
            const LoadingOverlay(message: 'Creating your account...'),
        ],
      ),
    );
  }
}
