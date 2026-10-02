import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/common/app_widgets.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final filtered = finance.filteredTransactions;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        title: Text(
          'Transactions',
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Clear filters',
            icon: const Icon(Icons.filter_alt_off_rounded),
            onPressed: () {
              _searchController.clear();
              finance.clearFilters();
            },
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Add',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        onPressed: () => _showAddTransaction(context),
      ),
      body: Column(
        children: [
          // ─── Search Bar ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => finance.setSearchQuery(val),
              style: AppTypography.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Search by merchant, category, or note...',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear_rounded,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          finance.setSearchQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.cardDark,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: AppColors.borderSubtle),
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: AppColors.borderSubtle),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // ─── Type Filter Tabs (All / Expense / Income) ───────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                _TypeTab(
                  label: 'All',
                  isSelected: finance.selectedType == null,
                  onTap: () => finance.setTypeFilter(null),
                ),
                const SizedBox(width: AppSpacing.sm),
                _TypeTab(
                  label: 'Expenses',
                  isSelected: finance.selectedType == TransactionType.expense,
                  onTap: () => finance.setTypeFilter(TransactionType.expense),
                  color: AppColors.error,
                ),
                const SizedBox(width: AppSpacing.sm),
                _TypeTab(
                  label: 'Income',
                  isSelected: finance.selectedType == TransactionType.income,
                  onTap: () => finance.setTypeFilter(TransactionType.income),
                  color: AppColors.success,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // ─── Category Filter Chips ───────────────────────────────────────
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              children: [
                _CategoryChip(
                  label: 'All Categories',
                  isSelected: finance.selectedCategory == null,
                  onTap: () => finance.setCategoryFilter(null),
                ),
                ...TransactionCategory.values.map((cat) {
                  return _CategoryChip(
                    label: cat.displayName,
                    icon: cat.icon,
                    color: cat.color,
                    isSelected: finance.selectedCategory == cat,
                    onTap: () => finance.setCategoryFilter(cat),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // ─── Transaction List or Empty State ─────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? const EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No Transactions Found',
                    subtitle:
                        'Try adjusting your search keywords or filter options.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.xs,
                      AppSpacing.lg,
                      80,
                    ),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final tx = filtered[index];
                      return _TransactionItem(
                        transaction: tx,
                        onTap: () => _showDetail(context, tx),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddTransaction(BuildContext context) {
    // Re-use bottom sheet from dashboard or open dialog
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _AddTransactionDialog(),
    );
  }

  void _showDetail(BuildContext context, TransactionModel tx) {
    final finance = context.read<FinanceProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: const BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: tx.category.color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    tx.category.icon,
                    size: 24,
                    color: tx.category.color,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.merchant,
                        style: AppTypography.headlineSmall.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        tx.category.displayName,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${tx.type == TransactionType.income ? '+' : '-'}${CurrencyFormatter.formatINR(tx.amount)}',
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: tx.type == TransactionType.income
                        ? AppColors.success
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const Divider(height: 32, color: AppColors.divider),
            _infoRow('Status', tx.status.name.toUpperCase()),
            _infoRow('Account', tx.accountName ?? 'Default Account'),
            _infoRow('Date & Time', DateFormatter.formatFullDate(tx.date)),
            _infoRow('Transaction ID', tx.id),
            if (tx.notes != null) _infoRow('Notes', tx.notes!),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Delete',
                    variant: ButtonVariant.danger,
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await finance.deleteTransaction(tx.id);
                      if (context.mounted) {
                        AppSnackbar.showSuccess(context, 'Transaction removed');
                      }
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton(
                    label: 'Done',
                    variant: ButtonVariant.secondary,
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            val,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Filter Subwidgets ───────────────────────────────────────────────────────

class _TypeTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _TypeTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.primary;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: 0.15)
                : AppColors.cardDark,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isSelected
                  ? activeColor
                  : AppColors.borderSubtle,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? activeColor : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    this.icon,
    this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.2)
              : AppColors.cardDark,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected
                ? activeColor
                : AppColors.bgSurface,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: isSelected ? activeColor : AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? activeColor : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onTap;

  const _TransactionItem({
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.bgSurface,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        dense: true,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: transaction.category.color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            transaction.category.icon,
            size: 18,
            color: transaction.category.color,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                transaction.merchant,
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (transaction.isRecurring)
              Container(
                margin: const EdgeInsets.only(left: 4),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Auto',
                  style: TextStyle(
                    fontSize: 9,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          '${transaction.category.displayName} • ${transaction.accountName ?? 'Account'} • ${DateFormatter.formatDate(transaction.date)}',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
        trailing: Text(
          '${isIncome ? '+' : '-'}${CurrencyFormatter.formatINR(transaction.amount)}',
          style: AppTypography.titleSmall.copyWith(
            color: isIncome ? AppColors.success : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _AddTransactionDialog extends StatefulWidget {
  const _AddTransactionDialog();

  @override
  State<_AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<_AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _merchantController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  TransactionCategory _category = TransactionCategory.food;
  String? _accountId;

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.read<FinanceProvider>();
    final accounts = finance.accounts;
    _accountId ??= accounts.isNotEmpty ? accounts.first.id : null;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Record Transaction',
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () =>
                          setState(() => _type = TransactionType.expense),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _type == TransactionType.expense
                              ? AppColors.error.withValues(alpha: 0.2)
                              : AppColors.bgSurface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _type == TransactionType.expense
                                ? AppColors.error
                                : Colors.transparent,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Expense (-)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: InkWell(
                      onTap: () =>
                          setState(() => _type = TransactionType.income),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _type == TransactionType.income
                              ? AppColors.success.withValues(alpha: 0.2)
                              : AppColors.bgSurface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _type == TransactionType.income
                                ? AppColors.success
                                : Colors.transparent,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Income (+)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _merchantController,
                label: 'Merchant / Recipient',
                hint: 'e.g. Swiggy, Uber, Employer',
                prefixIcon: Icons.store_rounded,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _amountController,
                label: 'Amount (₹)',
                hint: '0.00',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.currency_rupee_rounded,
                validator: (v) {
                  final parsed = double.tryParse(v ?? '');
                  if (parsed == null || parsed <= 0) return 'Invalid amount';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              // Category selector
              Text(
                'Category',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<TransactionCategory>(
                initialValue: _category,
                dropdownColor: AppColors.cardDark,
                style: AppTypography.bodyMedium,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.cardDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide(
                      color: AppColors.borderSubtle,
                    ),
                  ),
                ),
                items: TransactionCategory.values.map((cat) {
                  return DropdownMenuItem<TransactionCategory>(
                    value: cat,
                    child: Text(cat.displayName),
                  );
                }).toList(),
                onChanged: (cat) {
                  if (cat != null) setState(() => _category = cat);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'Save Transaction',
                onPressed: () async {
                  if (!_formKey.currentState!.validate() || _accountId == null) {
                    return;
                  }
                  final amount = double.parse(_amountController.text.trim());
                  await finance.addTransaction(
                    merchant: _merchantController.text.trim(),
                    amount: amount,
                    category: _category,
                    accountId: _accountId!,
                    type: _type,
                    notes: _notesController.text.trim().isNotEmpty
                        ? _notesController.text.trim()
                        : null,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    AppSnackbar.showSuccess(
                        context, 'Transaction saved successfully');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
