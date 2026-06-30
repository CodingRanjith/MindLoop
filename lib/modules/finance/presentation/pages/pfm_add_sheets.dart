import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindloop/modules/finance/core/constants/pfm_categories.dart';
import 'package:mindloop/modules/finance/domain/entities/budget_transaction_entity.dart';
import 'package:mindloop/modules/finance/domain/entities/financial_goal_entity.dart';
import 'package:mindloop/modules/finance/domain/entities/loan_entity.dart';
import 'package:mindloop/modules/finance/domain/entities/net_worth_item_entity.dart';
import 'package:mindloop/modules/finance/presentation/bloc/pfm_bloc.dart';
import 'package:mindloop/shared/theme/pfm_theme.dart';
import 'package:mindloop/modules/finance/presentation/widgets/pfm_form_fields.dart';
import 'package:mindloop/modules/finance/presentation/widgets/pfm_ui_kit.dart';

class PfmQuickAddFab extends StatelessWidget {
  const PfmQuickAddFab({super.key});

  @override
  Widget build(BuildContext context) {
    return PfmGradientFab(onPressed: () => _showQuickAddMenu(context));
  }

  void _showQuickAddMenu(BuildContext context) {
    PfmAddSheets.showQuickAddMenu(context);
  }
}

class PfmAddSheets {
  static void showQuickAddMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: PfmTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: PfmTheme.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Quick Add',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: PfmTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Log money in one tap',
                  style: TextStyle(fontSize: 13, color: PfmTheme.textSecondary),
                ),
                const SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.95,
                  children: [
                    PfmQuickAddTile(
                      icon: Icons.arrow_downward_rounded,
                      label: 'Income',
                      color: PfmTheme.income,
                      onTap: () {
                        Navigator.pop(ctx);
                        showTransaction(context, TransactionType.income);
                      },
                    ),
                    PfmQuickAddTile(
                      icon: Icons.arrow_upward_rounded,
                      label: 'Expense',
                      color: PfmTheme.expense,
                      onTap: () {
                        Navigator.pop(ctx);
                        showTransaction(context, TransactionType.expense);
                      },
                    ),
                    PfmQuickAddTile(
                      icon: Icons.flag_rounded,
                      label: 'Goal',
                      color: PfmTheme.primaryLight,
                      onTap: () {
                        Navigator.pop(ctx);
                        showGoal(context);
                      },
                    ),
                    PfmQuickAddTile(
                      icon: Icons.account_balance_rounded,
                      label: 'Loan',
                      color: PfmTheme.primary,
                      onTap: () {
                        Navigator.pop(ctx);
                        showLoan(context);
                      },
                    ),
                    PfmQuickAddTile(
                      icon: Icons.trending_up_rounded,
                      label: 'Invest',
                      color: PfmTheme.primaryDark,
                      onTap: () {
                        Navigator.pop(ctx);
                        showTransaction(
                          context,
                          TransactionType.expense,
                          defaultCategory: 'Stocks',
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _paymentLabel(PaymentMethod method) {
    final n = method.name;
    if (n.length <= 3) return n.toUpperCase();
    return '${n[0].toUpperCase()}${n.substring(1)}';
  }

  static void showTransaction(
    BuildContext context,
    TransactionType type, {
    String? defaultCategory,
    BudgetTransactionEntity? existing,
  }) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final amountCtrl = TextEditingController(
      text: existing != null ? existing.amount.toString() : '',
    );
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');
    var category = defaultCategory ??
        (type == TransactionType.income
            ? PfmCategories.incomeLabels[IncomeSource.salary]!
            : 'Food');
    var payment = existing?.paymentMethod ?? PaymentMethod.upi;
    var incomeSource = existing?.incomeSource ?? IncomeSource.salary;
    var txDate = existing?.date ?? DateTime.now();

    final pfmState = context.read<PfmBloc>().state;
    final categories = type == TransactionType.income
        ? PfmCategories.incomeCategoryList
        : PfmCategories.allExpenseCategoryNames(
            pfmState.expenseCategories.where((c) => !c.isDefault).toList(),
          );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          return PfmFormSheet(
            title: existing != null
                ? (type == TransactionType.income ? 'Edit Income' : 'Edit Expense')
                : (type == TransactionType.income ? 'Add Income' : 'Add Expense'),
            primaryLabel: 'Save',
            onPrimary: () {
              final amount = double.tryParse(amountCtrl.text) ?? 0;
              if (titleCtrl.text.trim().isEmpty || amount <= 0) return;
              context.read<PfmBloc>().add(
                    PfmTransactionSaveRequested(
                      BudgetTransactionEntity(
                        id: existing?.id ?? '',
                        title: titleCtrl.text.trim(),
                        amount: amount,
                        type: type,
                        date: txDate,
                        category: category,
                        notes: notesCtrl.text.trim(),
                        paymentMethod: payment,
                        incomeSource: type == TransactionType.income ? incomeSource : null,
                      ),
                    ),
                  );
              Navigator.pop(ctx);
            },
            secondaryLabel: existing != null ? 'Delete' : null,
            onSecondary: existing != null
                ? () async {
                    final ok = await showDialog<bool>(
                      context: ctx,
                      builder: (dCtx) => AlertDialog(
                        title: const Text('Delete transaction?'),
                        content: const Text('This cannot be undone.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dCtx, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(dCtx, true),
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: PfmTheme.expense),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (ok == true && ctx.mounted) {
                      context.read<PfmBloc>().add(PfmTransactionDeleteRequested(existing.id));
                      Navigator.pop(ctx);
                    }
                  }
                : null,
            children: [
              PfmFormTextField(
                label: 'Title',
                controller: titleCtrl,
                hint: type == TransactionType.income ? 'e.g. Monthly salary' : 'e.g. Groceries',
              ),
              PfmFormTextField(
                label: 'Amount',
                controller: amountCtrl,
                hint: '0.00',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              PfmFormDropdown<String>(
                label: 'Category',
                value: category,
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => category = v ?? category),
              ),
              if (type == TransactionType.income)
                PfmFormDropdown<IncomeSource>(
                  label: 'Income source',
                  value: incomeSource,
                  items: IncomeSource.values
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(PfmCategories.incomeLabels[s]!),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => incomeSource = v ?? incomeSource),
                ),
              PfmFormDropdown<PaymentMethod>(
                label: 'Payment method',
                value: payment,
                items: PaymentMethod.values
                    .map(
                      (p) => DropdownMenuItem(
                        value: p,
                        child: Text(_paymentLabel(p)),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => payment = v ?? payment),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: PfmFormFields.fieldGap),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date', style: PfmFormFields.labelStyle),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: txDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) setState(() => txDate = picked);
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: InputDecorator(
                        decoration: PfmFormFields.decoration(hint: 'Select date'),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${txDate.day}/${txDate.month}/${txDate.year}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: PfmTheme.textPrimary,
                                ),
                              ),
                            ),
                            const Icon(Icons.calendar_today_outlined, size: 20, color: PfmTheme.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              PfmFormTextField(
                label: 'Notes',
                controller: notesCtrl,
                hint: 'Optional details',
                maxLines: 3,
              ),
            ],
          );
        },
      ),
    );
  }

  static void showGoal(BuildContext context, {FinancialGoalEntity? existing}) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final targetCtrl = TextEditingController(
      text: existing?.targetAmount.toString() ?? '',
    );
    final currentCtrl = TextEditingController(
      text: existing?.currentAmount.toString() ?? '0',
    );
    var targetDate = existing?.targetDate ?? DateTime.now().add(const Duration(days: 365));

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          return PfmFormSheet(
            title: 'Savings Goal',
            primaryLabel: 'Save goal',
            onPrimary: () {
              final target = double.tryParse(targetCtrl.text) ?? 0;
              final current = double.tryParse(currentCtrl.text) ?? 0;
              if (nameCtrl.text.trim().isEmpty || target <= 0) return;
              context.read<PfmBloc>().add(
                    PfmGoalSaveRequested(
                      FinancialGoalEntity(
                        id: existing?.id ?? '',
                        name: nameCtrl.text.trim(),
                        targetAmount: target,
                        currentAmount: current,
                        targetDate: targetDate,
                      ),
                    ),
                  );
              Navigator.pop(ctx);
            },
            children: [
              PfmFormTextField(label: 'Goal name', controller: nameCtrl, hint: 'e.g. Emergency fund'),
              PfmFormTextField(
                label: 'Target amount',
                controller: targetCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              PfmFormTextField(
                label: 'Current saved',
                controller: currentCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: PfmFormFields.fieldGap),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Target date', style: PfmFormFields.labelStyle),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: targetDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 3650)),
                        );
                        if (picked != null) setState(() => targetDate = picked);
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: InputDecorator(
                        decoration: PfmFormFields.decoration(hint: 'Select date'),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${targetDate.day}/${targetDate.month}/${targetDate.year}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: PfmTheme.textPrimary,
                                ),
                              ),
                            ),
                            const Icon(Icons.calendar_today_outlined, size: 20, color: PfmTheme.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static void showLoan(BuildContext context, {LoanEntity? existing}) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final totalCtrl = TextEditingController(text: existing?.totalAmount.toString() ?? '');
    final paidCtrl = TextEditingController(text: existing?.paidAmount.toString() ?? '0');
    final emiCtrl = TextEditingController(text: existing?.emiAmount.toString() ?? '');
    final emiCountCtrl = TextEditingController(
      text: existing?.remainingEmiCount.toString() ?? '',
    );
    final rateCtrl = TextEditingController(text: existing?.interestRate.toString() ?? '');
    var nextDue = existing?.nextDueDate ?? DateTime.now().add(const Duration(days: 30));

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          return PfmFormSheet(
            title: 'Track Loan',
            primaryLabel: 'Save loan',
            onPrimary: () {
              if (nameCtrl.text.trim().isEmpty) return;
              context.read<PfmBloc>().add(
                    PfmLoanSaveRequested(
                      LoanEntity(
                        id: existing?.id ?? '',
                        name: nameCtrl.text.trim(),
                        totalAmount: double.tryParse(totalCtrl.text) ?? 0,
                        paidAmount: double.tryParse(paidCtrl.text) ?? 0,
                        emiAmount: double.tryParse(emiCtrl.text) ?? 0,
                        remainingEmiCount: int.tryParse(emiCountCtrl.text) ?? 0,
                        interestRate: double.tryParse(rateCtrl.text) ?? 0,
                        nextDueDate: nextDue,
                      ),
                    ),
                  );
              Navigator.pop(ctx);
            },
            children: [
              PfmFormTextField(label: 'Loan name', controller: nameCtrl, hint: 'e.g. Home loan'),
              PfmFormTextField(
                label: 'Total loan',
                controller: totalCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              PfmFormTextField(
                label: 'Paid amount',
                controller: paidCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              PfmFormTextField(
                label: 'EMI amount',
                controller: emiCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              PfmFormTextField(
                label: 'Remaining EMIs',
                controller: emiCountCtrl,
                keyboardType: TextInputType.number,
              ),
              PfmFormTextField(
                label: 'Interest rate %',
                controller: rateCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: PfmFormFields.fieldGap),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Next due date', style: PfmFormFields.labelStyle),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: nextDue,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 3650)),
                        );
                        if (picked != null) setState(() => nextDue = picked);
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: InputDecorator(
                        decoration: PfmFormFields.decoration(),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${nextDue.day}/${nextDue.month}/${nextDue.year}',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                              ),
                            ),
                            const Icon(Icons.calendar_today_outlined, size: 20, color: PfmTheme.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static void showNetWorthItem(BuildContext context, {NetWorthType type = NetWorthType.asset}) {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PfmFormSheet(
        title: type == NetWorthType.asset ? 'Add Asset' : 'Add Liability',
        onPrimary: () {
          if (nameCtrl.text.trim().isEmpty) return;
          context.read<PfmBloc>().add(
                PfmNetWorthSaveRequested(
                  NetWorthItemEntity(
                    id: '',
                    name: nameCtrl.text.trim(),
                    amount: double.tryParse(amountCtrl.text) ?? 0,
                    type: type,
                  ),
                ),
              );
          Navigator.pop(ctx);
        },
        children: [
          PfmFormTextField(label: 'Name', controller: nameCtrl, hint: 'e.g. Savings account'),
          PfmFormTextField(
            label: 'Amount',
            controller: amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
    );
  }
}
