import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mindloop/core/utils/currency_preferences.dart';
import 'package:mindloop/core/utils/pfm_display_helpers.dart';
import 'package:mindloop/domain/entities/expense_budget_entity.dart';
import 'package:mindloop/presentation/blocs/auth/auth_bloc.dart';
import 'package:mindloop/presentation/blocs/pfm/pfm_bloc.dart';
import 'package:mindloop/domain/entities/budget_transaction_entity.dart';
import 'package:mindloop/presentation/screens/pfm/pfm_add_sheets.dart';
import 'package:mindloop/presentation/screens/pfm/pfm_utils.dart';
import 'package:mindloop/services/expense_tracker_service.dart';
import 'package:mindloop/themes/pfm_theme.dart';
import 'package:mindloop/widgets/pfm/pfm_drawer.dart';
import 'package:mindloop/widgets/pfm/pfm_empty_data.dart';
import 'package:mindloop/widgets/pfm/pfm_expense_dashboard_widgets.dart';
import 'package:mindloop/widgets/pfm/pfm_expense_overview.dart';
import 'package:mindloop/widgets/pfm/pfm_money_overview.dart';
import 'package:mindloop/widgets/pfm/pfm_ui_kit.dart';

class PfmDashboardScreen extends StatelessWidget {
  const PfmDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PfmBloc>().state;
    final auth = context.watch<AuthBloc>().state;
    final s = state.snapshot;
    final fmt = CurrencyPreferences.formatter(decimalDigits: 2);
    final name = auth.userName ?? 'User';
    final tracker = ExpenseTrackerService();
    final recent = tracker.recentTransactions(state.transactions);

    if (state.isLoading && s == null) {
      return const Scaffold(
        backgroundColor: PfmTheme.scaffold,
        body: Center(child: CircularProgressIndicator(color: PfmTheme.primary)),
      );
    }

    if (s == null) {
      return Scaffold(
        backgroundColor: PfmTheme.scaffold,
        drawer: const PfmDrawer(),
        appBar: const PfmPageHeader(title: 'Finance', showDrawer: true),
        body: Center(child: Text(state.error ?? 'Unable to load finance data')),
      );
    }

    final showCategory = PfmDisplayHelpers.mapHasValues(s.categorySpending);
    final monthlyStatus = state.monthlyBudgetStatus;
    final alertStatus = monthlyStatus?.alertLevel != BudgetAlertLevel.none
        ? monthlyStatus
        : state.weeklyBudgetStatus?.alertLevel != BudgetAlertLevel.none
            ? state.weeklyBudgetStatus
            : null;
    final monthSummary = tracker.moneySummary(state.transactions, FinancePeriod.month);

    return Scaffold(
      backgroundColor: PfmTheme.scaffold,
      drawer: const PfmDrawer(),
      appBar: PfmPageHeader(
        title: 'Finance',
        showDrawer: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: PfmTheme.textPrimary),
            tooltip: 'Add transaction',
            onPressed: () => PfmAddSheets.showQuickAddMenu(context),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: PfmTheme.textPrimary),
            onPressed: () => context.push('/finance/notifications'),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: PfmTheme.primary,
        onRefresh: () async {
          context.read<PfmBloc>().add(const PfmLoadRequested());
          await Future<void>.delayed(const Duration(milliseconds: 400));
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            PfmGreetingHeader(
              name: name,
              subtitle: 'Your money at a glance',
              onAvatarTap: () => context.push('/profile'),
            ),
            const SizedBox(height: 20),
            if (alertStatus != null)
              PfmBudgetAlertBanner(
                level: alertStatus.alertLevel,
                message: alertStatus.alertLevel == BudgetAlertLevel.exceeded
                    ? 'You have exceeded your ${alertStatus.period == ExpenseBudgetPeriod.monthly ? 'monthly' : 'weekly'} budget.'
                    : 'You have used ${alertStatus.usagePercent.toStringAsFixed(0)}% of your budget.',
              ),
            PfmHeroBalanceCard(
              label: 'Available Balance',
              amount: fmt.format(s.availableBalance),
              showGrowth: s.hasMonthlyActivity,
              monthGrowthPercent: state.monthComparisons['savingsGrowth'] ?? 0,
            ),
            const SizedBox(height: 16),
            PfmMoneyOverviewCard(
              transactions: state.transactions,
              formatAmount: (v) => fmt.format(v),
            ),
            const SizedBox(height: 16),
            _MonthSnapshotRow(
              income: monthSummary.income,
              expense: monthSummary.expense,
              savings: s.totalSavings,
              healthScore: s.financialHealthScore,
              healthLabel: healthLevelLabel(s.healthLevel),
              formatAmount: (v) => fmt.format(v),
            ),
            if (monthlyStatus != null) ...[
              const SizedBox(height: 16),
              PfmBudgetProgressCard(
                status: monthlyStatus,
                formatAmount: (v) => fmt.format(v),
                onTap: () => context.push('/finance/budget'),
              ),
            ] else if (state.monthlyBudget <= 0) ...[
              const SizedBox(height: 12),
              _SetBudgetPrompt(onTap: () => context.push('/finance/budget')),
            ],
            if (recent.isNotEmpty) ...[
              const SizedBox(height: 20),
              PfmRecentExpensesList(
                transactions: recent,
                categories: state.expenseCategories,
                formatAmount: (v) => fmt.format(v),
                onSeeAll: () => context.push('/finance/transactions'),
                onTap: (t) => PfmAddSheets.showTransaction(
                  context,
                  t.type,
                  existing: t,
                ),
              ),
            ],
            if (showCategory) ...[
              const SizedBox(height: 20),
              const PfmSectionTitle('Spending by Category'),
              PfmSurfaceCard(child: PfmExpenseOverview(categorySpending: s.categorySpending)),
            ],
            const SizedBox(height: 16),
            _QuickActions(
              onAddExpense: () => PfmAddSheets.showTransaction(context, TransactionType.expense),
              onAddIncome: () => PfmAddSheets.showTransaction(context, TransactionType.income),
              onTransactions: () => context.push('/finance/transactions'),
              onAnalytics: () => context.push('/finance/analytics'),
            ),
            if (s.insights.isNotEmpty) ...[
              const SizedBox(height: 8),
              PfmSectionTitle(
                'Insight',
                trailing: TextButton(
                  onPressed: () => context.push('/finance/insights'),
                  child: const Text('More'),
                ),
              ),
              PfmInsightTile(
                icon: Icons.auto_awesome,
                text: s.insights.first,
                iconBg: PfmTheme.primary.withValues(alpha: 0.12),
                iconColor: PfmTheme.primary,
              ),
            ],
            if (!s.hasMonthlyActivity && state.transactions.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: PfmNoDataBox(
                  message: 'Tap + to log your first transaction and start tracking.',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MonthSnapshotRow extends StatelessWidget {
  const _MonthSnapshotRow({
    required this.income,
    required this.expense,
    required this.savings,
    required this.healthScore,
    required this.healthLabel,
    required this.formatAmount,
  });

  final double income;
  final double expense;
  final double savings;
  final int healthScore;
  final String healthLabel;
  final String Function(double) formatAmount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniStat(
            icon: Icons.savings_outlined,
            label: 'Saved',
            value: formatAmount(savings),
            color: PfmTheme.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStat(
            icon: Icons.favorite_outline_rounded,
            label: 'Health',
            value: '$healthScore',
            subtitle: healthLabel,
            color: healthScore >= 75 ? PfmTheme.income : PfmTheme.warning,
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: PfmTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: PfmTheme.textSecondary),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: PfmTheme.textPrimary,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
            ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onAddExpense,
    required this.onAddIncome,
    required this.onTransactions,
    required this.onAnalytics,
  });

  final VoidCallback onAddExpense;
  final VoidCallback onAddIncome;
  final VoidCallback onTransactions;
  final VoidCallback onAnalytics;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionChip(
            icon: Icons.remove_circle_outline,
            label: 'Expense',
            color: PfmTheme.expense,
            onTap: onAddExpense,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionChip(
            icon: Icons.add_circle_outline,
            label: 'Income',
            color: PfmTheme.income,
            onTap: onAddIncome,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionChip(
            icon: Icons.receipt_long_outlined,
            label: 'History',
            color: PfmTheme.primary,
            onTap: onTransactions,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionChip(
            icon: Icons.insights_outlined,
            label: 'Charts',
            color: PfmTheme.chartNeeds,
            onTap: onAnalytics,
          ),
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PfmTheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: PfmTheme.border),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: PfmTheme.textSecondary,
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

class _SetBudgetPrompt extends StatelessWidget {
  const _SetBudgetPrompt({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PfmTheme.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.savings_outlined, color: PfmTheme.primary),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Set a monthly budget to track spending limits',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: PfmTheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
