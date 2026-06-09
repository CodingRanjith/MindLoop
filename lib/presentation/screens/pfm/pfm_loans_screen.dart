import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mindloop/core/utils/currency_preferences.dart';
import 'package:mindloop/presentation/blocs/pfm/pfm_bloc.dart';
import 'package:mindloop/presentation/screens/pfm/pfm_add_sheets.dart';
import 'package:mindloop/themes/pfm_theme.dart';
import 'package:mindloop/widgets/pfm/pfm_empty_data.dart';
import 'package:mindloop/widgets/pfm/pfm_drawer.dart';
import 'package:mindloop/widgets/pfm/pfm_ui_kit.dart';

class PfmLoansScreen extends StatelessWidget {
  const PfmLoansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PfmBloc>().state;
    final snapshot = state.snapshot;
    final fmt = CurrencyPreferences.formatter(decimalDigits: 0);

    return Scaffold(
      backgroundColor: PfmTheme.scaffold,
      drawer: const PfmDrawer(),
      appBar: PfmPageHeader(
        title: 'Loans',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: PfmTheme.primary),
            onPressed: () => PfmAddSheets.showLoan(context),
          ),
        ],
      ),
      body: state.loans.isEmpty
          ? const Center(child: PfmNoDataBox(message: 'No loans saved yet.'))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              itemCount: state.loans.length,
              itemBuilder: (context, i) {
                final l = state.loans[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: PfmSurfaceCard(
                    onTap: () => PfmAddSheets.showLoan(context, existing: l),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: PfmTheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.two_wheeler, color: PfmTheme.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l.name,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                                  ),
                                  if (l.lender.isNotEmpty)
                                    Text(
                                      l.lender,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: PfmTheme.textSecondary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _LoanDetailRow('Total Loan', fmt.format(l.totalAmount)),
                        _LoanDetailRow('Paid', fmt.format(l.paidAmount)),
                        _LoanDetailRow('Pending', fmt.format(l.pendingAmount)),
                        _LoanDetailRow('EMI', fmt.format(l.emiAmount)),
                        _LoanDetailRow('Next EMI', DateFormat.MMMd().format(l.nextDueDate)),
                        _LoanDetailRow('Remaining', '${l.remainingEmiCount} months'),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${l.progressPercent.toStringAsFixed(0)}% paid',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: PfmTheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: l.progressPercent / 100,
                            minHeight: 8,
                            backgroundColor: PfmTheme.border,
                            color: PfmTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _LoanDetailRow extends StatelessWidget {
  const _LoanDetailRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: PfmTheme.textSecondary, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
