import 'package:hive_flutter/hive_flutter.dart';
import 'package:mindloop/core/constants/app_constants.dart';
import 'package:mindloop/data/models/budget_transaction_model.dart';
import 'package:mindloop/domain/entities/budget_transaction_entity.dart';
import 'package:mindloop/domain/repositories/budget_repository.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  Box<Map>? _box;

  Future<Box<Map>> get box async {
    _box ??= await Hive.openBox<Map>(AppConstants.hiveBudgetBox);
    return _box!;
  }

  @override
  Future<List<BudgetTransactionEntity>> getTransactions() async {
    final b = await box;
    return b.values
        .map((e) =>
            BudgetTransactionModel.fromJson(Map<String, dynamic>.from(e)).toEntity())
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<void> addTransaction(BudgetTransactionEntity transaction) async {
    final b = await box;
    final model = BudgetTransactionModel.fromEntity(transaction);
    await b.put(transaction.id, model.toJson());
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final b = await box;
    await b.delete(id);
  }
}
