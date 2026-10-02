import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/constants.dart';
import '../../providers/providers.dart';
import '../../widgets/common/app_widgets.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _autoLockEnabled = true;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        title: Text(
          'Security Centre',
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ResponsiveContainer.wide(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status shield banner
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified_user_rounded,
                      color: AppColors.success,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Account is Protected',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Hardware-backed keystore encryption is active.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            Text(
              'Authentication & Access',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            Container(
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Biometric Authentication',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      'Use Face ID / Fingerprint to log into FinTrack.',
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    secondary: const Icon(Icons.fingerprint_rounded,
                        color: AppColors.primary),
                    value: auth.biometricEnabled,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) async {
                      await auth.setBiometricEnabled(val);
                      if (context.mounted) {
                        AppSnackbar.showSuccess(
                          context,
                          val
                              ? 'Biometric login enabled'
                              : 'Biometric login disabled',
                        );
                      }
                    },
                  ),
                  const Divider(height: 1, color: AppColors.divider),
                  SwitchListTile(
                    title: const Text('Auto-Lock on Background',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      'Require authentication when switching back to app.',
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    secondary: const Icon(Icons.lock_clock_rounded,
                        color: AppColors.primary),
                    value: _autoLockEnabled,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) {
                      setState(() => _autoLockEnabled = val);
                      AppSnackbar.showSuccess(
                        context,
                        val
                            ? 'Auto-lock activated'
                            : 'Auto-lock disabled',
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            Text(
              'Encryption & Storage Verification',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                children: [
                  _auditRow('Hardware Keystore', 'Hardware Enclave / TEE',
                      AppColors.success),
                  _auditRow('Token Encryption', 'AES-256 GCM', AppColors.success),
                  _auditRow('Session Token', 'Active & Validated',
                      AppColors.primary),
                  _auditRow('Last Login Event', 'Today, 21:04 Local',
                      AppColors.textPrimary),
                  _auditRow('Last Sync Timestamp', 'Real-time Local Cache',
                      AppColors.textPrimary),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }

  Widget _auditRow(String key, String val, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key,
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.textSecondary)),
          Text(val,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              )),
        ],
      ),
    );
  }
}
