import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mindloop/modules/finance/core/constants/pfm_categories.dart';
import 'package:mindloop/modules/finance/domain/entities/budget_transaction_entity.dart';
import 'package:mindloop/modules/finance/domain/entities/expense_budget_entity.dart';
import 'package:mindloop/modules/finance/services/expense_tracker_service.dart';
import 'package:mindloop/modules/finance/domain/entities/expense_category_entity.dart';
import 'package:mindloop/shared/theme/pfm_theme.dart';

class PfmPeriodExpenseRow extends StatelessWidget {
  const PfmPeriodExpenseRow({
    super.key,
    required this.totals,
    required this.formatAmount,
  });

  final ExpensePeriodTotals totals;
  final String Function(double) formatAmount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PeriodChip(
            label: 'Today',
            value: formatAmount(totals.today),
            accent: PfmTheme.expense,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _PeriodChip(
            label: 'This Week',
            value: formatAmount(totals.thisWeek),
            accent: PfmTheme.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _PeriodChip(
            label: 'This Month',
            value: formatAmount(totals.thisMonth),
            accent: PfmTheme.chartNeeds,
          ),
        ),
      ],
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: PfmTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PfmTheme.border),
        boxShadow: PfmTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 4,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: PfmTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: PfmTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class PfmBudgetProgressCard extends StatelessWidget {
  const PfmBudgetProgressCard({
    super.key,
    required this.status,
    required this.formatAmount,
    this.onTap,
  });

  final ExpenseBudgetStatus status;
  final String Function(double) formatAmount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final periodLabel =
        status.period == ExpenseBudgetPeriod.monthly ? 'Monthly Budget' : 'Weekly Budget';
    final progressColor = switch (status.alertLevel) {
      BudgetAlertLevel.exceeded => PfmTheme.expense,
      BudgetAlertLevel.warning => PfmTheme.warning,
      BudgetAlertLevel.none => PfmTheme.primary,
    };
    final usage = (status.usagePercent / 100).clamp(0.0, 1.0);

    return Material(
      color: PfmTheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: PfmTheme.cardDecoration(),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      periodLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    if (status.alertLevel != BudgetAlertLevel.none)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: progressColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status.alertLevel == BudgetAlertLevel.exceeded
                              ? 'Over budget'
                              : '80% reached',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: progressColor,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatAmount(status.spent),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: PfmTheme.textPrimary,
                      ),
                    ),
                    Text(
                      ' / ${formatAmount(status.budgetAmount)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: PfmTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${formatAmount(status.remaining.abs())} ${status.remaining >= 0 ? 'remaining' : 'over'}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: status.remaining >= 0 ? PfmTheme.income : PfmTheme.expense,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: usage,
                    minHeight: 10,
                    backgroundColor: PfmTheme.border,
                    color: progressColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${status.usagePercent.toStringAsFixed(0)}% used',
                  style: const TextStyle(fontSize: 11, color: PfmTheme.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PfmRecentExpensesList extends StatelessWidget {
  const PfmRecentExpensesList({
    super.key,
    required this.transactions,
    required this.categories,
    required this.formatAmount,
    this.title = 'Recent Transactions',
    this.onSeeAll,
    this.onTap,
  });

  final List<BudgetTransactionEntity> transactions;
  final List<ExpenseCategoryEntity> categories;
  final String Function(double) formatAmount;
  final String title;
  final VoidCallback? onSeeAll;
  final void Function(BudgetTransactionEntity)? onTap;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: PfmTheme.textPrimary,
                ),
              ),
            ),
            if (onSeeAll != null)
              TextButton(onPressed: onSeeAll, child: const Text('See all')),
          ],
        ),
        const SizedBox(height: 10),
        ...transactions.map((t) {
          final isIncome = t.type == TransactionType.income;
          final meta = PfmCategories.categoryMeta(t.category, categories);
          final color = isIncome
              ? PfmTheme.income
              : (meta?.colorValue ?? PfmTheme.primary);
          final icon = isIncome
              ? Icons.trending_up_rounded
              : (meta?.iconData ?? Icons.receipt_rounded);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: PfmTheme.surface,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: onTap != null ? () => onTap!(t) : null,
                borderRadius: BorderRadius.circular(14),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: PfmTheme.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: color.withValues(alpha: 0.15),
                          child: Icon(icon, color: color, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${t.category} · ${DateFormat('d MMM').format(t.date)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: PfmTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${isIncome ? '+' : '-'}${formatAmount(t.amount)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: isIncome ? PfmTheme.income : PfmTheme.expense,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class PfmBudgetAlertBanner extends StatelessWidget {
  const PfmBudgetAlertBanner({super.key, required this.message, required this.level});

  final String message;
  final BudgetAlertLevel level;

  @override
  Widget build(BuildContext context) {
    final color = level == BudgetAlertLevel.exceeded ? PfmTheme.expense : PfmTheme.warning;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(
            level == BudgetAlertLevel.exceeded
                ? Icons.warning_amber_rounded
                : Icons.info_outline_rounded,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: color,
              ),
            ),
          ),
          TextButton(
            onPressed: () => context.push('/finance/budget'),
            child: Text('Manage', style: TextStyle(color: color)),
          ),
        ],
      ),
    );
  }
}
