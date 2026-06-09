import 'package:mindloop/domain/entities/pfm_dashboard_snapshot.dart';

String healthLevelLabel(FinancialHealthLevel level) => switch (level) {
      FinancialHealthLevel.excellent => 'Excellent',
      FinancialHealthLevel.good => 'Good',
      FinancialHealthLevel.average => 'Average',
      FinancialHealthLevel.risk => 'At Risk',
    };

String budgetStatusLabel(BudgetStatus status) => switch (status) {
      BudgetStatus.underBudget => 'Under Budget',
      BudgetStatus.nearLimit => 'Near Limit',
      BudgetStatus.overBudget => 'Over Budget',
    };
