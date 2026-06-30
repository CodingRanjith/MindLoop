import 'package:mindloop/modules/finance/domain/entities/budget_transaction_entity.dart';
import 'package:mindloop/modules/finance/domain/entities/expense_budget_entity.dart';

enum ExpenseSortOption { latest, oldest, highestAmount, lowestAmount }

class ExpenseFilter {
  const ExpenseFilter({
    this.query = '',
    this.category,
    this.startDate,
    this.endDate,
    this.minAmount,
    this.maxAmount,
    this.sort = ExpenseSortOption.latest,
    this.expensesOnly = true,
  });

  final String query;
  final String? category;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minAmount;
  final double? maxAmount;
  final ExpenseSortOption sort;
  final bool expensesOnly;
}

class ExpensePeriodTotals {
  const ExpensePeriodTotals({
    required this.today,
    required this.thisWeek,
    required this.thisMonth,
  });

  final double today;
  final double thisWeek;
  final double thisMonth;
}

/// Income and expense totals for a selected time window.
class PeriodMoneySummary {
  const PeriodMoneySummary({
    required this.income,
    required this.expense,
  });

  final double income;
  final double expense;

  double get net => income - expense;
  double get savingsRate => income > 0 ? ((income - expense) / income).clamp(0.0, 1.0) : 0;
}

enum FinancePeriod { today, week, month }

class ExpenseTrackerService {
  DateTime startOfDay(DateTime date) => DateTime(date.year, date.month, date.day);

  DateTime startOfWeek(DateTime date) {
    final day = startOfDay(date);
    final weekday = day.weekday;
    return day.subtract(Duration(days: weekday - 1));
  }

  DateTime startOfMonth(DateTime date) => DateTime(date.year, date.month);

  DateTime endOfMonth(DateTime date) => DateTime(date.year, date.month + 1, 0, 23, 59, 59);

  double sumExpenses(
    List<BudgetTransactionEntity> transactions, {
    required DateTime start,
    required DateTime end,
  }) {
    return transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            !t.date.isBefore(start) &&
            !t.date.isAfter(end))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double sumIncome(
    List<BudgetTransactionEntity> transactions, {
    required DateTime start,
    required DateTime end,
  }) {
    return transactions
        .where((t) =>
            t.type == TransactionType.income &&
            !t.date.isBefore(start) &&
            !t.date.isAfter(end))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  PeriodMoneySummary moneySummary(
    List<BudgetTransactionEntity> transactions,
    FinancePeriod period,
  ) {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final start = switch (period) {
      FinancePeriod.today => startOfDay(now),
      FinancePeriod.week => startOfWeek(now),
      FinancePeriod.month => startOfMonth(now),
    };
    return PeriodMoneySummary(
      income: sumIncome(transactions, start: start, end: end),
      expense: sumExpenses(transactions, start: start, end: end),
    );
  }

  ExpensePeriodTotals periodTotals(List<BudgetTransactionEntity> transactions) {
    final now = DateTime.now();
    final todayStart = startOfDay(now);
    final weekStart = startOfWeek(now);
    final monthStart = startOfMonth(now);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return ExpensePeriodTotals(
      today: sumExpenses(transactions, start: todayStart, end: end),
      thisWeek: sumExpenses(transactions, start: weekStart, end: end),
      thisMonth: sumExpenses(transactions, start: monthStart, end: end),
    );
  }

  ExpenseBudgetStatus? budgetStatus({
    required ExpenseBudgetPeriod period,
    required double budgetAmount,
    required List<BudgetTransactionEntity> transactions,
  }) {
    if (budgetAmount <= 0) return null;

    final now = DateTime.now();
    final start = period == ExpenseBudgetPeriod.weekly
        ? startOfWeek(now)
        : startOfMonth(now);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final spent = sumExpenses(transactions, start: start, end: end);
    final remaining = budgetAmount - spent;
    final usage = budgetAmount > 0 ? (spent / budgetAmount) * 100 : 0;

    final alert = usage >= 100
        ? BudgetAlertLevel.exceeded
        : usage >= 80
            ? BudgetAlertLevel.warning
            : BudgetAlertLevel.none;

    return ExpenseBudgetStatus(
      period: period,
      budgetAmount: budgetAmount,
      spent: spent,
      remaining: remaining,
      usagePercent: usage.toDouble(),
      alertLevel: alert,
    );
  }

  List<BudgetTransactionEntity> filterTransactions(
    List<BudgetTransactionEntity> transactions,
    ExpenseFilter filter,
  ) {
    var list = transactions.where((t) {
      if (filter.expensesOnly && t.type != TransactionType.expense) return false;
      if (filter.query.isNotEmpty) {
        final q = filter.query.toLowerCase();
        if (!t.title.toLowerCase().contains(q) &&
            !t.category.toLowerCase().contains(q) &&
            !t.notes.toLowerCase().contains(q)) {
          return false;
        }
      }
      if (filter.category != null && t.category != filter.category) return false;
      if (filter.startDate != null && t.date.isBefore(filter.startDate!)) return false;
      if (filter.endDate != null && t.date.isAfter(filter.endDate!)) return false;
      if (filter.minAmount != null && t.amount < filter.minAmount!) return false;
      if (filter.maxAmount != null && t.amount > filter.maxAmount!) return false;
      return true;
    }).toList();

    switch (filter.sort) {
      case ExpenseSortOption.latest:
        list.sort((a, b) => b.date.compareTo(a.date));
      case ExpenseSortOption.oldest:
        list.sort((a, b) => a.date.compareTo(b.date));
      case ExpenseSortOption.highestAmount:
        list.sort((a, b) => b.amount.compareTo(a.amount));
      case ExpenseSortOption.lowestAmount:
        list.sort((a, b) => a.amount.compareTo(b.amount));
    }
    return list;
  }

  List<BudgetTransactionEntity> recentExpenses(
    List<BudgetTransactionEntity> transactions, {
    int limit = 5,
  }) {
    return filterTransactions(
      transactions,
      const ExpenseFilter(sort: ExpenseSortOption.latest),
    ).take(limit).toList();
  }

  List<BudgetTransactionEntity> recentTransactions(
    List<BudgetTransactionEntity> transactions, {
    int limit = 5,
  }) {
    final list = [...transactions]
      ..sort((a, b) => b.date.compareTo(a.date));
    return list.take(limit).toList();
  }
}
