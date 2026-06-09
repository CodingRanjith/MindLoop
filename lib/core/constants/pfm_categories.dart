/// Personal Finance Management — income sources, expense buckets, and metadata.
library;

enum ExpenseBucket { needs, wants, savings, investment }

enum IncomeSource {
  salary,
  freelance,
  business,
  interest,
  refund,
  bonus,
  giftReceived,
  rentalIncome,
  other,
}

enum PaymentMethod {
  cash,
  upi,
  card,
  netBanking,
  wallet,
  other,
}

enum BudgetRuleType {
  rule503020,
  rule602020,
  custom,
}

enum RecurrenceFrequency { daily, weekly, monthly, yearly }

class PfmCategories {
  PfmCategories._();

  static const Map<IncomeSource, String> incomeLabels = {
    IncomeSource.salary: 'Salary',
    IncomeSource.freelance: 'Freelance',
    IncomeSource.business: 'Business',
    IncomeSource.interest: 'Interest',
    IncomeSource.refund: 'Refund',
    IncomeSource.bonus: 'Bonus',
    IncomeSource.giftReceived: 'Gift Received',
    IncomeSource.rentalIncome: 'Rental Income',
    IncomeSource.other: 'Other Income',
  };

  static const Map<String, ExpenseBucket> expenseCategories = {
    'Rent': ExpenseBucket.needs,
    'EMI': ExpenseBucket.needs,
    'Electricity': ExpenseBucket.needs,
    'Internet': ExpenseBucket.needs,
    'Fuel': ExpenseBucket.needs,
    'Grocery': ExpenseBucket.needs,
    'Medical': ExpenseBucket.needs,
    'Insurance': ExpenseBucket.needs,
    'Shopping': ExpenseBucket.wants,
    'Movies': ExpenseBucket.wants,
    'Travel': ExpenseBucket.wants,
    'Dining': ExpenseBucket.wants,
    'Entertainment': ExpenseBucket.wants,
    'Gadgets': ExpenseBucket.wants,
    'Emergency Fund': ExpenseBucket.savings,
    'Gold Savings': ExpenseBucket.savings,
    'FD': ExpenseBucket.savings,
    'Mutual Fund': ExpenseBucket.savings,
    'SIP': ExpenseBucket.savings,
    'Personal Savings': ExpenseBucket.savings,
    'Stocks': ExpenseBucket.investment,
    'Mutual Funds': ExpenseBucket.investment,
    'Gold': ExpenseBucket.investment,
    'Real Estate': ExpenseBucket.investment,
    'Crypto': ExpenseBucket.investment,
    'General': ExpenseBucket.needs,
  };

  static List<String> get incomeCategoryList => incomeLabels.values.toList();

  static List<String> get expenseCategoryList => expenseCategories.keys.toList();

  static ExpenseBucket bucketFor(String category) =>
      expenseCategories[category] ?? ExpenseBucket.needs;

  static String bucketLabel(ExpenseBucket bucket) => switch (bucket) {
        ExpenseBucket.needs => 'Needs',
        ExpenseBucket.wants => 'Wants',
        ExpenseBucket.savings => 'Savings',
        ExpenseBucket.investment => 'Investment',
      };

  static const Map<BudgetRuleType, Map<ExpenseBucket, double>> budgetTargets = {
    BudgetRuleType.rule503020: {
      ExpenseBucket.needs: 0.50,
      ExpenseBucket.wants: 0.30,
      ExpenseBucket.savings: 0.20,
    },
    BudgetRuleType.rule602020: {
      ExpenseBucket.needs: 0.60,
      ExpenseBucket.wants: 0.20,
      ExpenseBucket.savings: 0.20,
    },
    BudgetRuleType.custom: {
      ExpenseBucket.needs: 0.30,
      ExpenseBucket.wants: 0.20,
      ExpenseBucket.savings: 0.50,
    },
  };
}
