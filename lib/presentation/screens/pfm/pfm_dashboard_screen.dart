import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mindloop/core/utils/currency_preferences.dart';
import 'package:mindloop/core/utils/pfm_display_helpers.dart';
import 'package:mindloop/domain/entities/expense_budget_entity.dart';
import 'package:mindloop/presentation/blocs/auth/auth_bloc.dart';
import 'package:mindloop/presentation/blocs/pfm/pfm_bloc.dart';
import 'package:mindloop/presentation/screens/pfm/pfm_add_sheets.dart';
import 'package:mindloop/presentation/screens/pfm/pfm_utils.dart';
import 'package:mindloop/services/expense_tracker_service.dart';
import 'package:mindloop/themes/pfm_theme.dart';
import 'package:mindloop/widgets/pfm/pfm_charts.dart';
import 'package:mindloop/widgets/pfm/pfm_drawer.dart';
import 'package:mindloop/widgets/pfm/pfm_empty_data.dart';
import 'package:mindloop/widgets/pfm/pfm_expense_dashboard_widgets.dart';
import 'package:mindloop/widgets/pfm/pfm_expense_overview.dart';
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
    final recent = tracker.recentExpenses(state.transactions);

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
        appBar: const PfmPageHeader(title: 'Expense Tracker', showDrawer: true),
        body: Center(child: Text(state.error ?? 'Unable to load finance data')),
      );
    }

    final showCategory = PfmDisplayHelpers.mapHasValues(s.categorySpending);
    final showTrend = PfmDisplayHelpers.seriesHasValues(s.monthlyIncomeTrend) ||
        PfmDisplayHelpers.seriesHasValues(s.monthlyExpenseTrend);
    final scoreLabel = healthLevelLabel(s.healthLevel);
    final scoreGood = s.financialHealthScore >= 75;

    final monthlyStatus = state.monthlyBudgetStatus;
    final weeklyStatus = state.weeklyBudgetStatus;
    final alertStatus = monthlyStatus?.alertLevel != BudgetAlertLevel.none
        ? monthlyStatus
        : weeklyStatus?.alertLevel != BudgetAlertLevel.none
            ? weeklyStatus
            : null;

    return Scaffold(
      backgroundColor: PfmTheme.scaffold,
      drawer: const PfmDrawer(),
      appBar: PfmPageHeader(
        title: 'Expense Tracker',
        showDrawer: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.category_outlined, color: PfmTheme.textPrimary),
            onPressed: () => context.push('/finance/categories'),
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
            PfmPeriodExpenseRow(
              totals: state.periodTotals,
              formatAmount: (v) => fmt.format(v),
            ),
            const SizedBox(height: 16),
            if (monthlyStatus != null) ...[
              PfmBudgetProgressCard(
                status: monthlyStatus,
                formatAmount: (v) => fmt.format(v),
                onTap: () => context.push('/finance/budget'),
              ),
              const SizedBox(height: 12),
            ] else if (state.monthlyBudget <= 0)
              _SetBudgetPrompt(onTap: () => context.push('/finance/budget')),
            if (weeklyStatus != null && state.weeklyBudget > 0) ...[
              const SizedBox(height: 12),
              PfmBudgetProgressCard(
                status: weeklyStatus,
                formatAmount: (v) => fmt.format(v),
                onTap: () => context.push('/finance/budget'),
              ),
            ],
            const SizedBox(height: 20),
            PfmHeroBalanceCard(
              label: 'Available Balance',
              amount: fmt.format(s.availableBalance),
              showGrowth: s.hasMonthlyActivity,
              monthGrowthPercent: state.monthComparisons['savingsGrowth'] ?? 0,
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.22,
              children: [
                PfmStatCard(
                  label: 'Income',
                  value: fmt.format(s.totalIncome),
                  trendUp: s.totalIncome > 0 ? true : null,
                ),
                PfmStatCard(
                  label: 'Expenses',
                  value: fmt.format(s.totalExpenses),
                  trendUp: s.totalExpenses > 0 ? false : null,
                ),
                PfmStatCard(
                  label: 'Savings',
                  value: fmt.format(s.totalSavings),
                  trendUp: s.totalSavings > 0 ? true : null,
                ),
                PfmStatCard(
                  label: 'Financial Score',
                  value: '${s.financialHealthScore} / 100',
                  footerLabel: scoreLabel,
                  trendUp: scoreGood,
                ),
              ],
            ),
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
              const Row(
                children: [
                  Expanded(
                    child: Text(
                      'Spending by Category',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: PfmTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              PfmSurfaceCard(child: PfmExpenseOverview(categorySpending: s.categorySpending)),
            ],
            if (showTrend) ...[
              const SizedBox(height: 20),
              const PfmSectionTitle('Expense Trend'),
              PfmSurfaceCard(
                child: PfmLineTrendChart(
                  incomeData: s.monthlyIncomeTrend,
                  expenseData: s.monthlyExpenseTrend,
                  monthLabels: s.trendMonthLabels,
                ),
              ),
            ],
            const SizedBox(height: 16),
            _QuickNavRow(
              items: [
                _NavItemData('Transactions', Icons.receipt_long_outlined, '/finance/transactions'),
                _NavItemData('Analytics', Icons.insights_outlined, '/finance/analytics'),
                _NavItemData('Categories', Icons.category_outlined, '/finance/categories'),
                _NavItemData('Budget', Icons.pie_chart_outline, '/finance/budget'),
              ],
            ),
            if (s.insights.isNotEmpty) ...[
              const SizedBox(height: 8),
              PfmSectionTitle(
                'Insights',
                trailing: TextButton(
                  onPressed: () => context.push('/finance/insights'),
                  child: const Text('See all'),
                ),
              ),
              ...s.insights.take(2).map(
                    (t) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: PfmInsightTile(
                        icon: Icons.auto_awesome,
                        text: t,
                        iconBg: PfmTheme.primary.withValues(alpha: 0.12),
                        iconColor: PfmTheme.primary,
                      ),
                    ),
                  ),
            ],
            if (!s.hasMonthlyActivity && state.transactions.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: PfmNoDataBox(
                  message: 'Tap + to log your first expense and start tracking.',
                ),
              ),
          ],
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

class _NavItemData {
  const _NavItemData(this.label, this.icon, this.route);
  final String label;
  final IconData icon;
  final String route;
}

class _QuickNavRow extends StatelessWidget {
  const _QuickNavRow({required this.items});
  final List<_NavItemData> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: items.map((item) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Material(
              color: PfmTheme.surface,
              borderRadius: BorderRadius.circular(16),
              elevation: 0,
              child: InkWell(
                onTap: () => context.push(item.route),
                borderRadius: BorderRadius.circular(16),
                child: Ink(
                  decoration: PfmTheme.cardDecoration(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                PfmTheme.primary.withValues(alpha: 0.15),
                                PfmTheme.chartNeeds.withValues(alpha: 0.12),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(item.icon, size: 20, color: PfmTheme.primary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.label,
                          textAlign: TextAlign.center,
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
            ),
          ),
        );
      }).toList(),
    );
  }
}
