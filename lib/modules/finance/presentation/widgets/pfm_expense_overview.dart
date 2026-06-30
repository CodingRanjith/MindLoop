import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mindloop/modules/finance/core/constants/pfm_categories.dart';
import 'package:mindloop/modules/finance/core/utils/currency_preferences.dart';
import 'package:mindloop/shared/theme/pfm_theme.dart';

class PfmExpenseOverview extends StatelessWidget {
  const PfmExpenseOverview({
    super.key,
    required this.categorySpending,
    this.height = 200,
  });

  final Map<String, double> categorySpending;
  final double height;

  @override
  Widget build(BuildContext context) {
    final bucketTotals = <ExpenseBucket, double>{
      for (final b in ExpenseBucket.values) b: 0,
    };
    for (final e in categorySpending.entries) {
      final bucket = PfmCategories.bucketFor(e.key);
      bucketTotals[bucket] = bucketTotals[bucket]! + e.value;
    }
    final total = bucketTotals.values.fold<double>(0, (a, b) => a + b);
    if (total <= 0) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: Text('No expenses this month', style: TextStyle(color: PfmTheme.textSecondary)),
        ),
      );
    }

    final fmt = CurrencyPreferences.formatter(decimalDigits: 0);
    final segments = [
      _Segment(ExpenseBucket.needs, PfmTheme.chartNeeds, 'Needs'),
      _Segment(ExpenseBucket.wants, PfmTheme.chartWants, 'Wants'),
      _Segment(ExpenseBucket.savings, PfmTheme.chartSavings, 'Savings'),
      _Segment(ExpenseBucket.investment, PfmTheme.chartOther, 'Others'),
    ];

    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 52,
                sections: segments.map((s) {
                  final value = bucketTotals[s.bucket]!;
                  if (value <= 0) return null;
                  return PieChartSectionData(
                    value: value,
                    color: s.color,
                    radius: 40,
                    title: '',
                  );
                }).whereType<PieChartSectionData>().toList(),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fmt.format(total),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const Text('Total', style: TextStyle(fontSize: 11, color: PfmTheme.textSecondary)),
                const SizedBox(height: 12),
                ...segments.map((s) {
                  final value = bucketTotals[s.bucket]!;
                  final pct = total > 0 ? (value / total * 100) : 0.0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: s.color, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${s.label} ${pct.toStringAsFixed(0)}%',
                            style: const TextStyle(fontSize: 11, color: PfmTheme.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Segment {
  const _Segment(this.bucket, this.color, this.label);
  final ExpenseBucket bucket;
  final Color color;
  final String label;
}
