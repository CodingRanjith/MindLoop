import 'package:equatable/equatable.dart';
import 'package:mindloop/modules/finance/core/constants/pfm_categories.dart';

enum BudgetStatus { underBudget, nearLimit, overBudget }

enum FinancialHealthLevel { excellent, good, average, risk }

class PfmDashboardSnapshot extends Equatable {
  const PfmDashboardSnapshot({
    required this.totalIncome,
    required this.totalExpenses,
    required this.availableBalance,
    required this.totalSavings,
    required this.investments,
    required this.activeLoans,
    required this.upcomingEmi,
    required this.financialHealthScore,
    required this.healthLevel,
    required this.monthlyBudgetStatus,
    required this.netWorth,
    required this.budgetTargets,
    required this.budgetActuals,
    required this.budgetStatus,
    required this.insights,
    required this.monthlyIncomeTrend,
    required this.monthlyExpenseTrend,
    required this.categorySpending,
    required this.goalProgress,
    required this.loanBurdenPercent,
    required this.debtRatio,
    required this.trendMonthLabels,
    required this.hasMonthlyActivity,
  });

  final double totalIncome;
  final double totalExpenses;
  final double availableBalance;
  final double totalSavings;
  final double investments;
  final double activeLoans;
  final double upcomingEmi;
  final int financialHealthScore;
  final FinancialHealthLevel healthLevel;
  final BudgetStatus monthlyBudgetStatus;
  final double netWorth;
  final Map<ExpenseBucket, double> budgetTargets;
  final Map<ExpenseBucket, double> budgetActuals;
  final Map<ExpenseBucket, BudgetStatus> budgetStatus;
  final List<String> insights;
  final List<double> monthlyIncomeTrend;
  final List<double> monthlyExpenseTrend;
  final Map<String, double> categorySpending;
  final List<GoalProgressItem> goalProgress;
  final double loanBurdenPercent;
  final double debtRatio;
  final List<String> trendMonthLabels;
  final bool hasMonthlyActivity;

  @override
  List<Object?> get props => [
        totalIncome,
        totalExpenses,
        availableBalance,
        financialHealthScore,
        netWorth,
      ];
}

class GoalProgressItem extends Equatable {
  const GoalProgressItem({
    required this.name,
    required this.percent,
    required this.current,
    required this.target,
  });

  final String name;
  final double percent;
  final double current;
  final double target;

  @override
  List<Object?> get props => [name, percent, current, target];
}
