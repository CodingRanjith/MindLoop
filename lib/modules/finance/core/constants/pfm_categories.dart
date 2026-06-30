/// Personal Finance Management — income sources, expense buckets, and metadata.
library;

import 'package:mindloop/modules/finance/domain/entities/expense_category_entity.dart';

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

  /// Spec default expense categories (Food, Transport, Shopping, etc.).
  static const List<ExpenseCategoryEntity> defaultExpenseCategories = [
    ExpenseCategoryEntity(
      id: 'food',
      name: 'Food',
      icon: 'food',
      color: 0xFFEF4444,
      isDefault: true,
    ),
    ExpenseCategoryEntity(
      id: 'transport',
      name: 'Transport',
      icon: 'transport',
      color: 0xFF3B82F6,
      isDefault: true,
    ),
    ExpenseCategoryEntity(
      id: 'shopping',
      name: 'Shopping',
      icon: 'shopping_bag',
      color: 0xFF8B5CF6,
      isDefault: true,
    ),
    ExpenseCategoryEntity(
      id: 'bills',
      name: 'Bills',
      icon: 'bills',
      color: 0xFFF59E0B,
      isDefault: true,
    ),
    ExpenseCategoryEntity(
      id: 'entertainment',
      name: 'Entertainment',
      icon: 'entertainment',
      color: 0xFFEC4899,
      isDefault: true,
    ),
    ExpenseCategoryEntity(
      id: 'health',
      name: 'Health',
      icon: 'health',
      color: 0xFF10B981,
      isDefault: true,
    ),
    ExpenseCategoryEntity(
      id: 'education',
      name: 'Education',
      icon: 'school',
      color: 0xFF06B6D4,
      isDefault: true,
    ),
    ExpenseCategoryEntity(
      id: 'others',
      name: 'Others',
      icon: 'more',
      color: 0xFF6B7280,
      isDefault: true,
    ),
  ];

  static const Map<String, ExpenseBucket> expenseCategories = {
    'Food': ExpenseBucket.needs,
    'Transport': ExpenseBucket.needs,
    'Bills': ExpenseBucket.needs,
    'Health': ExpenseBucket.needs,
    'Education': ExpenseBucket.needs,
    'Others': ExpenseBucket.needs,
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

  static List<String> allExpenseCategoryNames(List<ExpenseCategoryEntity> custom) {
    final names = <String>{};
    for (final c in defaultExpenseCategories) {
      names.add(c.name);
    }
    for (final c in custom) {
      names.add(c.name);
    }
    for (final name in expenseCategories.keys) {
      names.add(name);
    }
    return names.toList()..sort();
  }

  static ExpenseCategoryEntity? categoryMeta(
    String name,
    List<ExpenseCategoryEntity> custom,
  ) {
    for (final c in defaultExpenseCategories) {
      if (c.name == name) return c;
    }
    for (final c in custom) {
      if (c.name == name) return c;
    }
    return null;
  }

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
