import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:mindloop/core/constants/app_constants.dart';
import 'package:mindloop/core/constants/pfm_categories.dart';
import 'package:mindloop/data/models/budget_transaction_model.dart';
import 'package:mindloop/domain/entities/budget_transaction_entity.dart';
import 'package:mindloop/domain/entities/financial_goal_entity.dart';
import 'package:mindloop/domain/entities/loan_entity.dart';
import 'package:mindloop/domain/entities/net_worth_item_entity.dart';
import 'package:mindloop/domain/entities/recurring_transaction_entity.dart';
import 'package:mindloop/domain/repositories/pfm_repository.dart';

class PfmRepositoryImpl implements PfmRepository {
  Box<Map>? _txBox;
  Box<Map>? _goalsBox;
  Box<Map>? _loansBox;
  Box<Map>? _netWorthBox;
  Box<Map>? _recurringBox;
  Box? _settingsBox;

  Future<Box<Map>> get _transactions async {
    _txBox ??= await Hive.openBox<Map>(AppConstants.hiveBudgetBox);
    return _txBox!;
  }

  Future<Box<Map>> get _goals async {
    _goalsBox ??= await Hive.openBox<Map>(AppConstants.hivePfmGoalsBox);
    return _goalsBox!;
  }

  Future<Box<Map>> get _loans async {
    _loansBox ??= await Hive.openBox<Map>(AppConstants.hivePfmLoansBox);
    return _loansBox!;
  }

  Future<Box<Map>> get _netWorth async {
    _netWorthBox ??= await Hive.openBox<Map>(AppConstants.hivePfmNetWorthBox);
    return _netWorthBox!;
  }

  Future<Box<Map>> get _recurring async {
    _recurringBox ??= await Hive.openBox<Map>(AppConstants.hivePfmRecurringBox);
    return _recurringBox!;
  }

  Future<Box> get _settings async {
    _settingsBox ??= await Hive.openBox(AppConstants.hivePfmSettingsBox);
    return _settingsBox!;
  }

  @override
  Future<List<BudgetTransactionEntity>> getTransactions() async {
    final b = await _transactions;
    return b.values
        .map((e) =>
            BudgetTransactionModel.fromJson(Map<String, dynamic>.from(e)).toEntity())
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<void> saveTransaction(BudgetTransactionEntity transaction) async {
    final b = await _transactions;
    final model = BudgetTransactionModel.fromEntity(transaction);
    await b.put(transaction.id, model.toJson());
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final b = await _transactions;
    await b.delete(id);
  }

  @override
  Future<void> deleteTransactions(Iterable<String> ids) async {
    final b = await _transactions;
    for (final id in ids) {
      await b.delete(id);
    }
  }

  @override
  Future<List<FinancialGoalEntity>> getGoals() async {
    final b = await _goals;
    return b.values
        .map((e) => _goalFromJson(Map<String, dynamic>.from(e)))
        .toList()
      ..sort((a, b) => a.targetDate.compareTo(b.targetDate));
  }

  @override
  Future<void> saveGoal(FinancialGoalEntity goal) async {
    final b = await _goals;
    await b.put(goal.id, _goalToJson(goal));
  }

  @override
  Future<void> deleteGoal(String id) async {
    final b = await _goals;
    await b.delete(id);
  }

  @override
  Future<List<LoanEntity>> getLoans() async {
    final b = await _loans;
    return b.values
        .map((e) => _loanFromJson(Map<String, dynamic>.from(e)))
        .toList()
      ..sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
  }

  @override
  Future<void> saveLoan(LoanEntity loan) async {
    final b = await _loans;
    await b.put(loan.id, _loanToJson(loan));
  }

  @override
  Future<void> deleteLoan(String id) async {
    final b = await _loans;
    await b.delete(id);
  }

  @override
  Future<List<NetWorthItemEntity>> getNetWorthItems() async {
    final b = await _netWorth;
    return b.values.map((e) => _netWorthFromJson(Map<String, dynamic>.from(e))).toList();
  }

  @override
  Future<void> saveNetWorthItem(NetWorthItemEntity item) async {
    final b = await _netWorth;
    await b.put(item.id, _netWorthToJson(item));
  }

  @override
  Future<void> deleteNetWorthItem(String id) async {
    final b = await _netWorth;
    await b.delete(id);
  }

  @override
  Future<List<RecurringTransactionEntity>> getRecurring() async {
    final b = await _recurring;
    return b.values.map((e) => _recurringFromJson(Map<String, dynamic>.from(e))).toList();
  }

  @override
  Future<void> saveRecurring(RecurringTransactionEntity recurring) async {
    final b = await _recurring;
    await b.put(recurring.id, _recurringToJson(recurring));
  }

  @override
  Future<void> deleteRecurring(String id) async {
    final b = await _recurring;
    await b.delete(id);
  }

  @override
  Future<BudgetRuleType> getBudgetRule() async {
    final b = await _settings;
    final name = b.get('budgetRule') as String?;
    if (name == null) return BudgetRuleType.custom;
    return BudgetRuleType.values.firstWhere(
      (e) => e.name == name,
      orElse: () => BudgetRuleType.custom,
    );
  }

  @override
  Future<void> setBudgetRule(BudgetRuleType rule) async {
    final b = await _settings;
    await b.put('budgetRule', rule.name);
  }

  @override
  Future<String?> exportBackupJson() async {
    final data = {
      'transactions': (await getTransactions())
          .map((t) => BudgetTransactionModel.fromEntity(t).toJson())
          .toList(),
      'goals': (await getGoals()).map(_goalToJson).toList(),
      'loans': (await getLoans()).map(_loanToJson).toList(),
      'netWorth': (await getNetWorthItems()).map(_netWorthToJson).toList(),
      'recurring': (await getRecurring()).map(_recurringToJson).toList(),
      'budgetRule': (await getBudgetRule()).name,
    };
    return jsonEncode(data);
  }

  @override
  Future<void> restoreBackupJson(String json) async {
    final data = jsonDecode(json) as Map<String, dynamic>;
    final txBox = await _transactions;
    await txBox.clear();
    for (final item in data['transactions'] as List<dynamic>? ?? []) {
      final model = BudgetTransactionModel.fromJson(Map<String, dynamic>.from(item as Map));
      await txBox.put(model.id, model.toJson());
    }
    final goalsBox = await _goals;
    await goalsBox.clear();
    for (final item in data['goals'] as List<dynamic>? ?? []) {
      final goal = _goalFromJson(Map<String, dynamic>.from(item as Map));
      await goalsBox.put(goal.id, _goalToJson(goal));
    }
    final loansBox = await _loans;
    await loansBox.clear();
    for (final item in data['loans'] as List<dynamic>? ?? []) {
      final loan = _loanFromJson(Map<String, dynamic>.from(item as Map));
      await loansBox.put(loan.id, _loanToJson(loan));
    }
    final nwBox = await _netWorth;
    await nwBox.clear();
    for (final item in data['netWorth'] as List<dynamic>? ?? []) {
      final nw = _netWorthFromJson(Map<String, dynamic>.from(item as Map));
      await nwBox.put(nw.id, _netWorthToJson(nw));
    }
    final recBox = await _recurring;
    await recBox.clear();
    for (final item in data['recurring'] as List<dynamic>? ?? []) {
      final r = _recurringFromJson(Map<String, dynamic>.from(item as Map));
      await recBox.put(r.id, _recurringToJson(r));
    }
    final ruleName = data['budgetRule'] as String?;
    if (ruleName != null) {
      final rule = BudgetRuleType.values.firstWhere(
        (e) => e.name == ruleName,
        orElse: () => BudgetRuleType.custom,
      );
      await setBudgetRule(rule);
    }
  }

  static Map<String, dynamic> _goalToJson(FinancialGoalEntity g) => {
        'id': g.id,
        'name': g.name,
        'targetAmount': g.targetAmount,
        'currentAmount': g.currentAmount,
        'targetDate': g.targetDate.toIso8601String(),
        'icon': g.icon,
      };

  static FinancialGoalEntity _goalFromJson(Map<String, dynamic> json) =>
      FinancialGoalEntity(
        id: json['id'] as String,
        name: json['name'] as String,
        targetAmount: (json['targetAmount'] as num).toDouble(),
        currentAmount: (json['currentAmount'] as num).toDouble(),
        targetDate: DateTime.parse(json['targetDate'] as String),
        icon: json['icon'] as String? ?? 'flag',
      );

  static Map<String, dynamic> _loanToJson(LoanEntity l) => {
        'id': l.id,
        'name': l.name,
        'totalAmount': l.totalAmount,
        'paidAmount': l.paidAmount,
        'emiAmount': l.emiAmount,
        'remainingEmiCount': l.remainingEmiCount,
        'interestRate': l.interestRate,
        'nextDueDate': l.nextDueDate.toIso8601String(),
        'lender': l.lender,
      };

  static LoanEntity _loanFromJson(Map<String, dynamic> json) => LoanEntity(
        id: json['id'] as String,
        name: json['name'] as String,
        totalAmount: (json['totalAmount'] as num).toDouble(),
        paidAmount: (json['paidAmount'] as num).toDouble(),
        emiAmount: (json['emiAmount'] as num).toDouble(),
        remainingEmiCount: json['remainingEmiCount'] as int,
        interestRate: (json['interestRate'] as num).toDouble(),
        nextDueDate: DateTime.parse(json['nextDueDate'] as String),
        lender: json['lender'] as String? ?? '',
      );

  static Map<String, dynamic> _netWorthToJson(NetWorthItemEntity i) => {
        'id': i.id,
        'name': i.name,
        'amount': i.amount,
        'type': i.type.name,
        'category': i.category,
      };

  static NetWorthItemEntity _netWorthFromJson(Map<String, dynamic> json) =>
      NetWorthItemEntity(
        id: json['id'] as String,
        name: json['name'] as String,
        amount: (json['amount'] as num).toDouble(),
        type: json['type'] == 'liability' ? NetWorthType.liability : NetWorthType.asset,
        category: json['category'] as String? ?? 'Other',
      );

  static Map<String, dynamic> _recurringToJson(RecurringTransactionEntity r) => {
        'id': r.id,
        'title': r.title,
        'amount': r.amount,
        'type': r.type.name,
        'category': r.category,
        'frequency': r.frequency.name,
        'nextRun': r.nextRun.toIso8601String(),
        'paymentMethod': r.paymentMethod.name,
        'active': r.active,
      };

  static RecurringTransactionEntity _recurringFromJson(Map<String, dynamic> json) =>
      RecurringTransactionEntity(
        id: json['id'] as String,
        title: json['title'] as String,
        amount: (json['amount'] as num).toDouble(),
        type: json['type'] == 'income' ? TransactionType.income : TransactionType.expense,
        category: json['category'] as String,
        frequency: RecurrenceFrequency.values.firstWhere(
          (e) => e.name == json['frequency'],
          orElse: () => RecurrenceFrequency.monthly,
        ),
        nextRun: DateTime.parse(json['nextRun'] as String),
        paymentMethod: PaymentMethod.values.firstWhere(
          (e) => e.name == json['paymentMethod'],
          orElse: () => PaymentMethod.upi,
        ),
        active: json['active'] as bool? ?? true,
      );
}
