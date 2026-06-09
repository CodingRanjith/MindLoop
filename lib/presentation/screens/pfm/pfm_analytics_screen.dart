import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindloop/core/utils/currency_preferences.dart';
import 'package:mindloop/core/utils/pfm_display_helpers.dart';
import 'package:mindloop/presentation/blocs/pfm/pfm_bloc.dart';
import 'package:mindloop/themes/pfm_theme.dart';
import 'package:mindloop/widgets/pfm/pfm_charts.dart';
import 'package:mindloop/widgets/pfm/pfm_empty_data.dart';
import 'package:mindloop/widgets/pfm/pfm_expense_overview.dart';
import 'package:mindloop/widgets/pfm/pfm_drawer.dart';
import 'package:mindloop/widgets/pfm/pfm_ui_kit.dart';

class PfmAnalyticsScreen extends StatefulWidget {
  const PfmAnalyticsScreen({super.key});

  @override
  State<PfmAnalyticsScreen> createState() => _PfmAnalyticsScreenState();
}

class _PfmAnalyticsScreenState extends State<PfmAnalyticsScreen> {
  int _periodIndex = 1;
  static const _periods = ['Weekly', 'Monthly', 'Yearly', 'Custom'];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PfmBloc>().state;
    final snapshot = state.snapshot;
    final fmt = CurrencyPreferences.formatter(decimalDigits: 0);
    final comp = state.monthComparisons;
    final expenseGrowth = comp['expenseGrowth'] ?? 0;

    if (state.transactions.isEmpty) {
      return Scaffold(
        backgroundColor: PfmTheme.scaffold,
        drawer: const PfmDrawer(),
        appBar: PfmPageHeader(
          title: 'Analytics',
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        body: const Center(child: PfmNoDataBox(message: 'Add transactions to see analytics.')),
      );
    }

    final totalExpense = snapshot?.totalExpenses ?? state.totalExpense;

    return Scaffold(
      backgroundColor: PfmTheme.scaffold,
      drawer: const PfmDrawer(),
      appBar: PfmPageHeader(
        title: 'Analytics',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          PfmFilterChipRow(
            labels: _periods,
            selectedIndex: _periodIndex,
            onSelected: (i) => setState(() => _periodIndex = i),
          ),
          const SizedBox(height: 16),
          PfmSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Expense Trend', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(
                  fmt.format(totalExpense),
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                ),
                Text(
                  '${expenseGrowth >= 0 ? '+' : ''}${expenseGrowth.toStringAsFixed(1)}% vs last month',
                  style: TextStyle(
                    color: expenseGrowth >= 0 ? PfmTheme.expense : PfmTheme.income,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                if (snapshot != null)
                  PfmLineTrendChart(
                    incomeData: snapshot.monthlyExpenseTrend,
                    expenseData: snapshot.monthlyExpenseTrend,
                    monthLabels: snapshot.trendMonthLabels,
                    height: 160,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (snapshot != null && PfmDisplayHelpers.mapHasValues(snapshot.categorySpending)) ...[
            const PfmSectionTitle('Category Wise Expense'),
            PfmSurfaceCard(
              child: PfmExpenseOverview(
                categorySpending: snapshot.categorySpending,
                height: 220,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _GrowthChip(
                label: 'Income',
                value: '${(comp['incomeGrowth'] ?? 0).toStringAsFixed(1)}%',
              ),
              _GrowthChip(
                label: 'Savings',
                value: '${(comp['savingsGrowth'] ?? 0).toStringAsFixed(1)}%',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GrowthChip extends StatelessWidget {
  const _GrowthChip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: PfmTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: PfmTheme.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        ],
      ),
    );
  }
}
