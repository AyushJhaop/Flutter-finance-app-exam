import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/constants.dart';
import '../../core/routing/app_router.dart';
import '../../core/utils/utils.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_widgets.dart';

/// LoginScreen — email + password login with biometric option.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      context.go(AppRoutes.dashboard);
    } else {
      _showError(authProvider.errorMessage ?? 'Login failed.');
    }
  }

  Future<void> _biometricLogin() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.loginWithBiometric();
    if (!mounted) return;
    if (success) {
      context.go(AppRoutes.dashboard);
    } else {
      _showError(authProvider.errorMessage ?? 'Biometric authentication failed.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // Background decoration
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.06),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.xxxl),

                  // Logo + brand
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(AppConstants.appName, style: AppTypography.headlineMedium),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xxxl),

                  Text('Welcome back', style: AppTypography.displayMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Sign in to your financial command centre',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxxl),

                  // Demo hint card
                  AppCard(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Demo: demo@fintrack.in / Demo@1234',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _emailController.text = 'demo@fintrack.in';
                            _passwordController.text = 'Demo@1234';
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm),
                            minimumSize: Size.zero,
                          ),
                          child: Text(
                            'Fill',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AppTextField(
                          label: 'Email address',
                          hint: 'you@example.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: Validators.email,
                          focusNode: _emailFocus,
                          textInputAction: TextInputAction.next,
                          onChanged: (_) => authProvider.clearError(),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        AppTextField(
                          label: 'Password',
                          controller: _passwordController,
                          isPassword: true,
                          prefixIcon: Icons.lock_outline_rounded,
                          validator: (v) => v == null || v.isEmpty
                              ? 'Password is required'
                              : null,
                          focusNode: _passwordFocus,
                          textInputAction: TextInputAction.done,
                          onChanged: (_) => authProvider.clearError(),
                        ),

                        const SizedBox(height: AppSpacing.sm),

                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // Forgot password flow — Phase 4
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Password reset coming soon.'),
                                ),
                              );
                            },
                            child: Text(
                              'Forgot password?',
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // Login button
                        AppButton(
                          label: 'Sign In',
                          onPressed: _login,
                          isLoading: authProvider.isLoading,
                        ),

                        // Biometric button
                        if (authProvider.biometricAvailable &&
                            authProvider.biometricEnabled) ...[
                          const SizedBox(height: AppSpacing.md),
                          AppButton(
                            label: 'Sign in with Biometrics',
                            onPressed: _biometricLogin,
                            isOutlined: true,
                            icon: Icons.fingerprint_rounded,
                            isLoading: authProvider.isLoading,
                          ),
                        ],

                        const SizedBox(height: AppSpacing.xxxl),

                        // Sign up link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.go('/login/signup'),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                              ),
                              child: Text(
                                'Create Account',
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

          // Loading overlay
          if (authProvider.isLoading)
            const LoadingOverlay(message: 'Signing you in...'),
        ],
      ),
    );
  }
}
