import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/constants.dart';
import '../../services/storage_service.dart';
import '../../widgets/common/app_widgets.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  int _selectedTier = 1; // 0: Starter (₹99), 1: Pro AI (₹199), 2: Executive (₹299)

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final isPremium = storage.isPremium;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        title: Text(
          'FinTrack Premium',
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
            children: [
              // Gold gradient hero
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.workspace_premium_rounded,
                      size: 48, color: Colors.black),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    isPremium ? 'PREMIUM ACTIVATED' : 'UPGRADE TO PRO',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPremium
                        ? 'You have full access to all AI Insights & Reports'
                        : 'Unlock Advanced AI Insights & Unlimited Bank Sync',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Pricing Plans
            Row(
              children: [
                _pricingCard(0, 'Basic', '₹99', '/month'),
                const SizedBox(width: AppSpacing.sm),
                _pricingCard(1, 'Pro AI', '₹199', '/month', isPopular: true),
                const SizedBox(width: AppSpacing.sm),
                _pricingCard(2, 'Executive', '₹299', '/month'),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Feature List
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Included with Premium',
                      style: AppTypography.titleMedium
                          .copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.md),
                  _featureItem(Icons.auto_awesome_rounded,
                      'AI Predictive Spending & Anomaly Alerts'),
                  _featureItem(Icons.account_balance_rounded,
                      'Unlimited Bank Accounts & Credit Cards Aggregation'),
                  _featureItem(Icons.repeat_rounded,
                      'Advanced Recurring Subscriptions & Debit Tracker'),
                  _featureItem(Icons.picture_as_pdf_rounded,
                      'Monthly PDF & CSV Tax Statement Exports'),
                  _featureItem(Icons.speed_rounded,
                      'Custom Threshold Category Budgets'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            AppButton(
              label: isPremium ? 'Manage Membership' : 'Activate Pro Access',
              onPressed: () async {
                await storage.setPremium(!isPremium);
                setState(() {});
                if (context.mounted) {
                  AppSnackbar.showSuccess(
                    context,
                    !isPremium
                        ? 'FinTrack Pro successfully enabled!'
                        : 'Switched back to Free plan',
                  );
                }
              },
            ),
          ],
        ),
      ),
    ),
  );
  }

  Widget _pricingCard(int index, String name, String price, String period,
      {bool isPopular = false}) {
    final isSel = _selectedTier == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTier = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: isSel
                ? AppColors.primaryLight
                : AppColors.cardDark,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isSel ? AppColors.primary : AppColors.borderSubtle,
              width: isSel ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              if (isPopular)
                Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'BEST VALUE',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              Text(
                name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSel ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                period,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}
