import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mindloop/core/utils/currency_preferences.dart';
import 'package:mindloop/domain/entities/budget_transaction_entity.dart';
import 'package:mindloop/presentation/blocs/budget/budget_bloc.dart';
import 'package:mindloop/themes/app_colors.dart';
import 'package:mindloop/themes/app_decorations.dart';
import 'package:mindloop/widgets/glass_card.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BudgetBloc>().state;
    final fmt = CurrencyPreferences.formatter(decimalDigits: 0);
    final spentRatio = state.totalIncome > 0
        ? (state.totalExpense / state.totalIncome).clamp(0.0, 1.0)
        : 0.0;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: const Text('Expense Manager'),
            actions: [
              IconButton(
                icon: const Icon(Icons.bar_chart_rounded),
                onPressed: () => context.push('/analytics'),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                GlassCard(
                  variant: GlassCardVariant.primary,
                  animate: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total balance',
                        style: TextStyle(
                          color: AppColors.textOnPrimary.withValues(alpha: 0.75),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fmt.format(state.balance),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textOnPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _MiniStat(
                              label: 'Income',
                              value: fmt.format(state.totalIncome),
                              color: AppColors.chartMint,
                              onDark: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _MiniStat(
                              label: 'Expense',
                              value: fmt.format(state.totalExpense),
                              color: AppColors.chartCoral,
                              onDark: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: spentRatio,
                          minHeight: 8,
                          backgroundColor: AppColors.textOnPrimary.withValues(alpha: 0.2),
                          color: AppColors.accentSoft,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _showAddDialog(context, TransactionType.income),
                        icon: const Icon(Icons.add),
                        label: const Text('Income'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showAddDialog(context, TransactionType.expense),
                        icon: const Icon(Icons.remove),
                        label: const Text('Expense'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent transactions',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${(spentRatio * 100).toStringAsFixed(0)}% used',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (state.transactions.isEmpty)
                  GlassCard(
                    animate: false,
                    child: const Text(
                      'No transactions yet.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                else
                  ...state.transactions.take(20).map(
                        (t) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _TransactionTile(transaction: t, fmt: fmt),
                        ),
                      ),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, TransactionType type) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(type == TransactionType.income ? 'Add Income' : 'Add Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(amountCtrl.text) ?? 0;
              if (titleCtrl.text.isEmpty || amount <= 0) return;
              context.read<BudgetBloc>().add(
                    BudgetAddRequested(
                      BudgetTransactionEntity(
                        id: '',
                        title: titleCtrl.text,
                        amount: amount,
                        type: type,
                        date: DateTime.now(),
                      ),
                    ),
                  );
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction, required this.fmt});

  final BudgetTransactionEntity transaction;
  final NumberFormat fmt;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final accent = isIncome ? AppColors.income : AppColors.expense;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDecorations.radiusChip),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(AppDecorations.radiusChip),
        child: Ink(
          decoration: AppDecorations.card(radius: AppDecorations.radiusChip),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        transaction.category,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${isIncome ? '+' : '-'}${fmt.format(transaction.amount)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
    this.onDark = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: onDark
            ? AppColors.textOnPrimary.withValues(alpha: 0.12)
            : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: onDark
                  ? AppColors.textOnPrimary.withValues(alpha: 0.7)
                  : AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
