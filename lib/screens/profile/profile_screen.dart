import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/constants.dart';
import '../../core/routing/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../services/storage_service.dart';
import '../../widgets/common/app_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final storage = context.watch<StorageService>();
    final user = authProvider.user;
    final isPremium = storage.isPremium;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Text('Profile', style: AppTypography.headlineMedium),
      ),
      body: user == null
          ? const EmptyState(icon: Icons.person, title: 'Not logged in')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              child: Column(
                children: [
                  // Avatar
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius:
                                BorderRadius.circular(AppRadius.full),
                          ),
                          child: Center(
                            child: Text(
                              user.initials,
                              style: AppTypography.headlineLarge
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(user.fullName, style: AppTypography.headlineSmall),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          user.email,
                          style: AppTypography.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        GestureDetector(
                          onTap: () => context.push('/main/premium'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              gradient: isPremium
                                  ? const LinearGradient(
                                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                                    )
                                  : AppColors.primaryGradient,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.full),
                            ),
                            child: Text(
                              isPremium ? '✦ PRO MEMBER' : '✦ FREE PLAN (UPGRADE)',
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxxl),

                  // Settings tiles
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _ProfileTile(
                          icon: Icons.account_balance_wallet_rounded,
                          label: 'Connected Accounts',
                          onTap: () => context.push('/main/accounts'),
                        ),
                        const Divider(height: 0),
                        _ProfileTile(
                          icon: Icons.pie_chart_outline_rounded,
                          label: 'Budget Categories',
                          onTap: () => context.push('/main/budgets'),
                        ),
                        const Divider(height: 0),
                        _ProfileTile(
                          icon: Icons.security_rounded,
                          label: 'Security Centre',
                          onTap: () => context.push('/main/security'),
                        ),
                        const Divider(height: 0),
                        _ProfileTile(
                          icon: Icons.notifications_outlined,
                          label: 'Notifications',
                          onTap: () => context.push('/main/notifications'),
                        ),
                        const Divider(height: 0),
                        _ProfileTile(
                          icon: Icons.assignment_outlined,
                          label: 'Financial Statements',
                          onTap: () => context.push('/main/report'),
                        ),
                        const Divider(height: 0),
                        _ProfileTile(
                          icon: Icons.workspace_premium_rounded,
                          label: isPremium
                              ? 'Manage Subscription'
                              : 'Upgrade to Premium',
                          color: AppColors.warning,
                          onTap: () => context.push('/main/premium'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Logout
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: _ProfileTile(
                      icon: Icons.logout_rounded,
                      label: 'Logout',
                      color: AppColors.error,
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            backgroundColor: AppColors.surfaceDark,
                            title: const Text('Logout'),
                            content: const Text(
                                'Are you sure you want to sign out of FinTrack?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Logout',
                                  style: TextStyle(color: AppColors.error),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true && context.mounted) {
                          await context.read<AuthProvider>().logout();
                          if (context.mounted) context.go(AppRoutes.login);
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  Text(
                    '${AppConstants.appName} v${AppConstants.appVersion}',
                    style: AppTypography.labelSmall,
                  ),
                ],
              ),
            ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return ListTile(
      leading: Icon(icon, color: c, size: 22),
      title: Text(label, style: AppTypography.bodyLarge.copyWith(color: c)),
      trailing:
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
      onTap: onTap,
    );
  }
}
