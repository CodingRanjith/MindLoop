import 'package:mindloop/modules/finance/domain/entities/budget_transaction_entity.dart';
import 'package:mindloop/modules/finance/domain/repositories/budget_repository.dart';
import 'package:mindloop/modules/finance/domain/repositories/pfm_repository.dart';

/// Legacy budget API — delegates to [PfmRepository].
class BudgetRepositoryImpl implements BudgetRepository {
  BudgetRepositoryImpl(this._pfm);

  final PfmRepository _pfm;

  @override
  Future<List<BudgetTransactionEntity>> getTransactions() => _pfm.getTransactions();

  @override
  Future<void> addTransaction(BudgetTransactionEntity transaction) =>
      _pfm.saveTransaction(transaction);

  @override
  Future<void> deleteTransaction(String id) => _pfm.deleteTransaction(id);
}
