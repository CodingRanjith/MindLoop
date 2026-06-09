import 'package:intl/intl.dart';
import 'package:mindloop/domain/entities/budget_transaction_entity.dart';

class PfmDisplayHelpers {
  PfmDisplayHelpers._();

  static List<String> trendMonthLabels({int months = 6}) {
    final now = DateTime.now();
    return List.generate(months, (i) {
      final m = DateTime(now.year, now.month - (months - 1 - i));
      return DateFormat.MMM().format(m);
    });
  }

  static bool seriesHasValues(Iterable<double> values) =>
      values.any((v) => v > 0);

  static bool mapHasValues(Map<String, double> values) =>
      values.values.any((v) => v > 0);

  static List<double> monthlySavingsTrend({
    required List<double> incomeTrend,
    required List<double> expenseTrend,
  }) {
    final len = incomeTrend.length < expenseTrend.length
        ? incomeTrend.length
        : expenseTrend.length;
    return List.generate(len, (i) => incomeTrend[i] - expenseTrend[i]);
  }

  static String? transactionDateRangeLabel(List<BudgetTransactionEntity> transactions) {
    if (transactions.isEmpty) return null;
    final sorted = [...transactions]..sort((a, b) => a.date.compareTo(b.date));
    final first = sorted.first.date;
    final last = sorted.last.date;
    final fmt = DateFormat.MMMd();
    if (first.year == last.year && first.month == last.month && first.day == last.day) {
      return fmt.format(first);
    }
    return '${fmt.format(first)} – ${fmt.format(last)}';
  }
}
