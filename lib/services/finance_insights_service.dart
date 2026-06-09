import 'package:mindloop/core/utils/currency_preferences.dart';
import 'package:mindloop/domain/entities/budget_transaction_entity.dart';
import 'package:mindloop/domain/entities/financial_goal_entity.dart';
import 'package:mindloop/domain/entities/loan_entity.dart';

class FinanceInsightsService {
  List<String> generate({
    required List<BudgetTransactionEntity> transactions,
    required List<FinancialGoalEntity> goals,
    required List<LoanEntity> loans,
    required double totalIncome,
    required double totalExpenses,
  }) {
    final insights = <String>[];
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month);
    final prevStart = DateTime(now.year, now.month - 1);

    final curByCat = <String, double>{};
    final prevByCat = <String, double>{};

    for (final t in transactions.where((t) => t.type == TransactionType.expense)) {
      if (!t.date.isBefore(monthStart)) {
        curByCat[t.category] = (curByCat[t.category] ?? 0) + t.amount;
      } else if (!t.date.isBefore(prevStart) && t.date.isBefore(monthStart)) {
        prevByCat[t.category] = (prevByCat[t.category] ?? 0) + t.amount;
      }
    }

    String? topIncrease;
    double topPct = 0;
    for (final entry in curByCat.entries) {
      final prev = prevByCat[entry.key] ?? 0;
      if (prev <= 0) continue;
      final pct = ((entry.value - prev) / prev) * 100;
      if (pct > topPct && pct >= 15) {
        topPct = pct;
        topIncrease = entry.key;
      }
    }
    if (topIncrease != null) {
      insights.add(
        '$topIncrease expenses increased by ${topPct.toStringAsFixed(0)}%.',
      );
    }

    final entertainment = curByCat['Entertainment'] ?? curByCat['Movies'] ?? 0;
    if (entertainment > 0 && totalIncome > 0) {
      final save = entertainment * 0.25;
      if (save >= 1) {
        final fmt = CurrencyPreferences.formatter(decimalDigits: 0);
        insights.add(
          'You can save ${fmt.format(save)} next month by reducing entertainment expenses.',
        );
      }
    }

    final emiTotal = loans.fold<double>(0, (s, l) => s + l.emiAmount);
    if (totalIncome > 0 && emiTotal / totalIncome > 0.4) {
      insights.add('Your EMI burden is reaching a risk zone.');
    }

    for (final goal in goals) {
      if (goal.remaining <= 0) continue;
      final monthly = totalIncome > 0 ? (totalIncome - totalExpenses).clamp(0, double.infinity) : 0;
      if (monthly > 0) {
        final months = (goal.remaining / monthly).ceil();
        if (months <= 12) {
          insights.add(
            '${goal.name} target can be completed in $months months.',
          );
          break;
        }
      }
    }

    if (totalExpenses > totalIncome * 0.9 && totalIncome > 0) {
      insights.add('Your spending pattern indicates possible budget overflow.');
    }

    return insights.take(5).toList();
  }
}
