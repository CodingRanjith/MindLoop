import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mindloop/shared/theme/app_colors.dart';

class PfmLineTrendChart extends StatelessWidget {
  const PfmLineTrendChart({
    super.key,
    required this.incomeData,
    required this.expenseData,
    this.monthLabels = const [],
    this.height = 180,
  });

  final List<double> incomeData;
  final List<double> expenseData;
  final List<String> monthLabels;
  final double height;

  @override
  Widget build(BuildContext context) {
    final hasData = [...incomeData, ...expenseData].any((v) => v > 0);
    if (!hasData) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text(
            'No income or expense data for this period',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ),
      );
    }

    final maxY = [...incomeData, ...expenseData].fold<double>(0, (a, b) => a > b ? a : b);
    final cap = maxY <= 0 ? 1.0 : maxY * 1.2;

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: cap,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: AppColors.border, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: monthLabels.isNotEmpty,
                getTitlesWidget: (value, _) {
                  final i = value.toInt();
                  if (i < 0 || i >= monthLabels.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      monthLabels[i],
                      style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            _line(incomeData, AppColors.income),
            _line(expenseData, AppColors.expense),
          ],
        ),
      ),
    );
  }

  LineChartBarData _line(List<double> data, Color color) {
    return LineChartBarData(
      spots: List.generate(
        data.length,
        (i) => FlSpot(i.toDouble(), data[i]),
      ),
      isCurved: true,
      color: color,
      barWidth: 3,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: color.withValues(alpha: 0.12),
      ),
    );
  }
}

class PfmCategoryPieChart extends StatelessWidget {
  const PfmCategoryPieChart({
    super.key,
    required this.categorySpending,
    this.height = 200,
  });

  final Map<String, double> categorySpending;
  final double height;

  @override
  Widget build(BuildContext context) {
    final entries = categorySpending.entries.where((e) => e.value > 0).toList();
    if (entries.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text('No spending data yet', style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    final total = entries.fold<double>(0, (s, e) => s + e.value);
    return SizedBox(
      height: height,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 48,
          sections: List.generate(entries.length, (i) {
            final e = entries[i];
            return PieChartSectionData(
              value: e.value,
              color: AppColors.chartPalette[i % AppColors.chartPalette.length],
              title: '${(e.value / total * 100).toStringAsFixed(0)}%',
              radius: 42,
              titleStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textOnPrimary,
              ),
            );
          }),
        ),
      ),
    );
  }
}

class PfmBarComparisonChart extends StatelessWidget {
  const PfmBarComparisonChart({
    super.key,
    required this.labels,
    required this.values,
    this.color = AppColors.primary,
    this.height = 160,
  });

  final List<String> labels;
  final List<double> values;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (!values.any((v) => v != 0)) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text(
            'No data for this chart',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ),
      );
    }

    final max = values.fold<double>(0, (a, b) => a > b ? a : b);
    final cap = max <= 0 ? 1.0 : max * 1.15;
    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          maxY: cap,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final i = value.toInt();
                  if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      labels[i],
                      style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(values.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: values[i],
                  color: color,
                  width: 14,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
