import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindloop/core/constants/pfm_categories.dart';
import 'package:mindloop/core/utils/currency_preferences.dart';
import 'package:mindloop/domain/entities/expense_budget_entity.dart';
import 'package:mindloop/domain/entities/pfm_dashboard_snapshot.dart';
import 'package:mindloop/presentation/blocs/pfm/pfm_bloc.dart';
import 'package:mindloop/presentation/screens/pfm/pfm_utils.dart';
import 'package:mindloop/themes/pfm_theme.dart';
import 'package:mindloop/widgets/pfm/pfm_empty_data.dart';
import 'package:mindloop/widgets/pfm/pfm_drawer.dart';
import 'package:mindloop/widgets/pfm/pfm_expense_dashboard_widgets.dart';
import 'package:mindloop/widgets/pfm/pfm_ui_kit.dart';

class PfmBudgetScreen extends StatelessWidget {
  const PfmBudgetScreen({super.key});

  String _ruleLabel(BudgetRuleType rule) => switch (rule) {
        BudgetRuleType.rule503020 => 'Budget Rule 50/30/20',
        BudgetRuleType.rule602020 => 'Budget Rule 60/20/20',
        BudgetRuleType.custom => 'Custom Budget',
      };

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PfmBloc>().state;
    final snapshot = state.snapshot;
    final fmt = CurrencyPreferences.formatter(decimalDigits: 0);
    final hasExpenseData = snapshot != null && snapshot.hasMonthlyActivity && snapshot.totalExpenses > 0;
    final totalBudget = snapshot?.totalExpenses ?? 0;

    return Scaffold(
      backgroundColor: PfmTheme.scaffold,
      drawer: const PfmDrawer(),
      appBar: PfmPageHeader(
        title: 'Budget',
        showDrawer: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          const PfmSectionTitle('Spending Limits'),
          const SizedBox(height: 8),
          _BudgetLimitCard(
            label: 'Monthly Budget',
            amount: state.monthlyBudget,
            status: state.monthlyBudgetStatus,
            onEdit: () => _editBudget(context, ExpenseBudgetPeriod.monthly, state.monthlyBudget),
          ),
          const SizedBox(height: 10),
          _BudgetLimitCard(
            label: 'Weekly Budget',
            amount: state.weeklyBudget,
            status: state.weeklyBudgetStatus,
            onEdit: () => _editBudget(context, ExpenseBudgetPeriod.weekly, state.weeklyBudget),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: PfmTheme.heroGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _ruleLabel(state.budgetRule),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                TextButton(
                  onPressed: () => _pickRule(context, state.budgetRule),
                  child: const Text('Edit', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (!hasExpenseData)
            const PfmNoDataBox(message: 'Add expenses this month to track budget vs actual.')
          else if (snapshot != null) ...[
            const PfmSectionTitle('Budget Overview'),
            ...ExpenseBucket.values.map((bucket) {
              final targetPct = (snapshot.budgetTargets[bucket] ?? 0);
              final actualPct = (snapshot.budgetActuals[bucket] ?? 0);
              final spent = actualPct * totalBudget;
              final target = targetPct * totalBudget;
              final status = snapshot.budgetStatus[bucket] ?? BudgetStatus.underBudget;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PfmSurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${PfmCategories.bucketLabel(bucket)} (${(targetPct * 100).toStringAsFixed(0)}%)',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            budgetStatusLabel(status),
                            style: const TextStyle(fontSize: 11, color: PfmTheme.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${fmt.format(spent)} / ${fmt.format(target)}',
                        style: const TextStyle(color: PfmTheme.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: target > 0 ? (spent / target).clamp(0.0, 1.0) : 0,
                          minHeight: 8,
                          backgroundColor: PfmTheme.border,
                          color: PfmTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: PfmTheme.income.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: PfmTheme.income.withValues(alpha: 0.3)),
              ),
              child: Text(
                'Budget Status: ${budgetStatusLabel(snapshot.monthlyBudgetStatus)} 🎉',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: PfmTheme.income,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _pickRule(BuildContext context, BudgetRuleType current) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: BudgetRuleType.values.map((rule) {
            return RadioListTile<BudgetRuleType>(
              value: rule,
              groupValue: current,
              title: Text(_ruleLabel(rule)),
              onChanged: (v) {
                if (v != null) {
                  context.read<PfmBloc>().add(PfmBudgetRuleChanged(v));
                  Navigator.pop(ctx);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _editBudget(BuildContext context, ExpenseBudgetPeriod period, double current) {
    final ctrl = TextEditingController(
      text: current > 0 ? current.toStringAsFixed(0) : '',
    );
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(ctx).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              period == ExpenseBudgetPeriod.monthly ? 'Monthly Budget' : 'Weekly Budget',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Budget amount',
                prefixIcon: Icon(Icons.savings_outlined),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                final amount = double.tryParse(ctrl.text) ?? 0;
                context.read<PfmBloc>().add(
                      PfmExpenseBudgetSetRequested(period: period, amount: amount),
                    );
                Navigator.pop(ctx);
              },
              child: const Text('Save budget'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetLimitCard extends StatelessWidget {
  const _BudgetLimitCard({
    required this.label,
    required this.amount,
    required this.status,
    required this.onEdit,
  });

  final String label;
  final double amount;
  final ExpenseBudgetStatus? status;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final fmt = CurrencyPreferences.formatter(decimalDigits: 0);

    if (status != null && amount > 0) {
      return PfmBudgetProgressCard(
        status: status!,
        formatAmount: (v) => fmt.format(v),
        onTap: onEdit,
      );
    }

    return PfmSurfaceCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  amount > 0 ? fmt.format(amount) : 'Not set',
                  style: const TextStyle(color: PfmTheme.textSecondary),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onEdit, child: const Text('Set')),
        ],
      ),
    );
  }
}
