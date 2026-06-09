import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mindloop/core/utils/currency_preferences.dart';
import 'package:mindloop/core/utils/pfm_display_helpers.dart';
import 'package:mindloop/presentation/blocs/auth/auth_bloc.dart';
import 'package:mindloop/presentation/blocs/pfm/pfm_bloc.dart';
import 'package:mindloop/widgets/pfm/pfm_drawer.dart';
import 'package:mindloop/presentation/screens/pfm/pfm_utils.dart';
import 'package:mindloop/themes/pfm_theme.dart';
import 'package:mindloop/widgets/pfm/pfm_charts.dart';
import 'package:mindloop/widgets/pfm/pfm_empty_data.dart';
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
        appBar: const PfmPageHeader(title: 'Dashboard', showDrawer: true),
        body: Center(child: Text(state.error ?? 'Unable to load finance data')),
      );
    }

    final growth = state.monthComparisons['savingsGrowth'] ?? 0;
    final showCategory = PfmDisplayHelpers.mapHasValues(s.categorySpending);
    final showTrend = PfmDisplayHelpers.seriesHasValues(s.monthlyIncomeTrend) ||
        PfmDisplayHelpers.seriesHasValues(s.monthlyExpenseTrend);
    final scoreLabel = healthLevelLabel(s.healthLevel);
    final scoreGood = s.financialHealthScore >= 75;

    return Scaffold(
      backgroundColor: PfmTheme.scaffold,
      drawer: const PfmDrawer(),
      appBar: PfmPageHeader(
        title: 'Dashboard',
        showDrawer: true,
        actions: [
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
            PfmHeroBalanceCard(
              label: 'Total Balance',
              amount: fmt.format(s.availableBalance),
              showGrowth: s.hasMonthlyActivity,
              monthGrowthPercent: growth,
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
            if (showCategory) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Expense Overview',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: PfmTheme.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: PfmTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: PfmTheme.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'This Month',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: PfmTheme.textSecondary,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: PfmTheme.textMuted),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              PfmSurfaceCard(child: PfmExpenseOverview(categorySpending: s.categorySpending)),
            ],
            if (showTrend) ...[
              const SizedBox(height: 20),
              const PfmSectionTitle('Monthly Trend'),
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
                _NavItemData('Goals', Icons.flag_outlined, '/finance/goals'),
                _NavItemData('Budget', Icons.pie_chart_outline, '/finance/budget'),
              ],
            ),
            if (s.insights.isNotEmpty) ...[
              const SizedBox(height: 8),
              PfmSectionTitle(
                'AI Insights',
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
            if (!s.hasMonthlyActivity &&
                state.transactions.isEmpty &&
                state.goals.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: PfmNoDataBox(
                  message: 'Tap + to add income or expenses and build your dashboard.',
                ),
              ),
          ],
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
              shadowColor: PfmTheme.primary.withValues(alpha: 0.08),
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
