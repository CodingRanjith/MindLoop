import 'package:mindloop/modules/finance/core/constants/pfm_categories.dart';
import 'package:mindloop/modules/finance/core/utils/pfm_display_helpers.dart';
import 'package:mindloop/modules/finance/domain/entities/budget_transaction_entity.dart';
import 'package:mindloop/modules/finance/domain/entities/financial_goal_entity.dart';
import 'package:mindloop/modules/finance/domain/entities/loan_entity.dart';
import 'package:mindloop/modules/finance/domain/entities/net_worth_item_entity.dart';
import 'package:mindloop/modules/finance/domain/entities/pfm_dashboard_snapshot.dart';

class FinanceAnalyticsService {
  PfmDashboardSnapshot buildSnapshot({
    required List<BudgetTransactionEntity> transactions,
    required List<FinancialGoalEntity> goals,
    required List<LoanEntity> loans,
    required List<NetWorthItemEntity> netWorthItems,
    required BudgetRuleType budgetRule,
    required List<String> insights,
  }) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month);
    final monthTx = transactions.where((t) => !t.date.isBefore(monthStart)).toList();

    double totalIncome = 0;
    double totalExpenses = 0;
    double savings = 0;
    double investments = 0;

    final categorySpending = <String, double>{};
    final bucketTotals = {
      ExpenseBucket.needs: 0.0,
      ExpenseBucket.wants: 0.0,
      ExpenseBucket.savings: 0.0,
      ExpenseBucket.investment: 0.0,
    };

    for (final t in monthTx) {
      if (t.type == TransactionType.income) {
        totalIncome += t.amount;
      } else {
        totalExpenses += t.amount;
        categorySpending[t.category] = (categorySpending[t.category] ?? 0) + t.amount;
        final bucket = PfmCategories.bucketFor(t.category);
        bucketTotals[bucket] = bucketTotals[bucket]! + t.amount;
      }
    }

    for (final t in transactions) {
      if (t.type != TransactionType.expense) continue;
      final bucket = PfmCategories.bucketFor(t.category);
      if (bucket == ExpenseBucket.savings) savings += t.amount;
      if (bucket == ExpenseBucket.investment) investments += t.amount;
    }

    final targets = PfmCategories.budgetTargets[budgetRule]!;
    final expenseBase = totalExpenses > 0 ? totalExpenses : 1.0;
    final actuals = {
      for (final e in ExpenseBucket.values)
        e: (bucketTotals[e]! / expenseBase).clamp(0.0, 1.0),
    };

    final statusMap = <ExpenseBucket, BudgetStatus>{};
    for (final bucket in ExpenseBucket.values) {
      final target = targets[bucket] ?? 0;
      final actual = actuals[bucket] ?? 0;
      if (actual <= target * 0.95) {
        statusMap[bucket] = BudgetStatus.underBudget;
      } else if (actual <= target * 1.05) {
        statusMap[bucket] = BudgetStatus.nearLimit;
      } else {
        statusMap[bucket] = BudgetStatus.overBudget;
      }
    }

    final overallBudget = statusMap.values.contains(BudgetStatus.overBudget)
        ? BudgetStatus.overBudget
        : statusMap.values.contains(BudgetStatus.nearLimit)
            ? BudgetStatus.nearLimit
            : BudgetStatus.underBudget;

    final activeLoans = loans.fold<double>(0, (s, l) => s + l.pendingAmount);
    final upcomingEmi = loans.fold<double>(0, (s, l) => s + l.emiAmount);

    double assets = 0;
    double liabilities = activeLoans;
    for (final item in netWorthItems) {
      if (item.type == NetWorthType.asset) {
        assets += item.amount;
      } else {
        liabilities += item.amount;
      }
    }
    final netWorth = assets - liabilities + (totalIncome - totalExpenses);

    final savingsRate = totalIncome > 0 ? savings / totalIncome : 0;
    final debtRatio = totalIncome > 0 ? activeLoans / totalIncome : 0;
    final budgetDiscipline = 1 - (actuals[ExpenseBucket.wants] ?? 0);
    final hasMonthlyActivity = monthTx.isNotEmpty;
    final expenseControl = totalIncome > 0
        ? (1 - (totalExpenses / totalIncome)).clamp(0.0, 1.0)
        : 0.0;
    final goalAchievement = goals.isEmpty
        ? 0.0
        : goals.map((g) => g.completionPercent / 100).reduce((a, b) => a + b) /
            goals.length;

    final score = hasMonthlyActivity
        ? ((savingsRate * 25) +
                ((1 - debtRatio.clamp(0, 1)) * 25) +
                (budgetDiscipline.clamp(0, 1) * 20) +
                (expenseControl * 15) +
                (goalAchievement * 15))
            .round()
            .clamp(0, 100)
        : 0;

    final healthLevel = !hasMonthlyActivity
        ? FinancialHealthLevel.risk
        : switch (score) {
            >= 90 => FinancialHealthLevel.excellent,
            >= 75 => FinancialHealthLevel.good,
            >= 50 => FinancialHealthLevel.average,
            _ => FinancialHealthLevel.risk,
          };

    final incomeTrend = _monthlyTrend(transactions, TransactionType.income, 6);
    final expenseTrend = _monthlyTrend(transactions, TransactionType.expense, 6);
    final trendLabels = PfmDisplayHelpers.trendMonthLabels(months: incomeTrend.length);

    final loanBurden = totalIncome > 0 ? (upcomingEmi / totalIncome) * 100 : 0.0;

    return PfmDashboardSnapshot(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      availableBalance: totalIncome - totalExpenses,
      totalSavings: savings,
      investments: investments,
      activeLoans: activeLoans,
      upcomingEmi: upcomingEmi,
      financialHealthScore: score,
      healthLevel: healthLevel,
      monthlyBudgetStatus: overallBudget,
      netWorth: netWorth,
      budgetTargets: targets,
      budgetActuals: actuals,
      budgetStatus: statusMap,
      insights: insights,
      monthlyIncomeTrend: incomeTrend,
      monthlyExpenseTrend: expenseTrend,
      categorySpending: categorySpending,
      goalProgress: goals
          .map(
            (g) => GoalProgressItem(
              name: g.name,
              percent: g.completionPercent.toDouble(),
              current: g.currentAmount,
              target: g.targetAmount,
            ),
          )
          .toList(),
      loanBurdenPercent: loanBurden,
      debtRatio: debtRatio * 100,
      trendMonthLabels: trendLabels,
      hasMonthlyActivity: hasMonthlyActivity,
    );
  }

  List<double> _monthlyTrend(
    List<BudgetTransactionEntity> transactions,
    TransactionType type,
    int months,
  ) {
    final now = DateTime.now();
    return List.generate(months, (i) {
      final m = DateTime(now.year, now.month - (months - 1 - i));
      final start = DateTime(m.year, m.month);
      final end = DateTime(m.year, m.month + 1);
      return transactions
          .where((t) => t.type == type && !t.date.isBefore(start) && t.date.isBefore(end))
          .fold<double>(0, (s, t) => s + t.amount);
    });
  }

  Map<String, double> compareMonths(
    List<BudgetTransactionEntity> transactions,
  ) {
    final now = DateTime.now();
    final curStart = DateTime(now.year, now.month);
    final prevStart = DateTime(now.year, now.month - 1);
    final prevEnd = curStart;

    double curIncome = 0, curExpense = 0, prevIncome = 0, prevExpense = 0;
    for (final t in transactions) {
      if (!t.date.isBefore(curStart)) {
        if (t.type == TransactionType.income) {
          curIncome += t.amount;
        } else {
          curExpense += t.amount;
        }
      } else if (!t.date.isBefore(prevStart) && t.date.isBefore(prevEnd)) {
        if (t.type == TransactionType.income) {
          prevIncome += t.amount;
        } else {
          prevExpense += t.amount;
        }
      }
    }

    double growth(double cur, double prev) =>
        prev > 0 ? ((cur - prev) / prev) * 100 : (cur > 0 ? 100 : 0);

    return {
      'incomeGrowth': growth(curIncome, prevIncome),
      'expenseGrowth': growth(curExpense, prevExpense),
      'savingsGrowth': growth(curIncome - curExpense, prevIncome - prevExpense),
    };
  }
}
