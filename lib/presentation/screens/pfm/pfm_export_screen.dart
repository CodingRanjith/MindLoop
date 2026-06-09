import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindloop/presentation/blocs/pfm/pfm_bloc.dart';
import 'package:mindloop/services/finance_export_service.dart';
import 'package:mindloop/themes/pfm_theme.dart';
import 'package:mindloop/widgets/pfm/pfm_empty_data.dart';
import 'package:mindloop/widgets/pfm/pfm_form_fields.dart';
import 'package:mindloop/widgets/pfm/pfm_drawer.dart';
import 'package:mindloop/widgets/pfm/pfm_ui_kit.dart';

class PfmExportScreen extends StatefulWidget {
  const PfmExportScreen({super.key});

  @override
  State<PfmExportScreen> createState() => _PfmExportScreenState();
}

class _PfmExportScreenState extends State<PfmExportScreen> {
  int _reportIndex = 0;
  int _formatIndex = 0;

  static const _reports = [
    'Monthly Report',
    'Yearly Report',
    'Custom Report',
    'Category Report',
    'Loan Report',
    'Goal Report',
    'Complete Report',
  ];

  static const _formats = ['Excel (.xlsx)', 'PDF', 'CSV'];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PfmBloc, PfmState>(
      builder: (context, state) {
        final hasData = state.transactions.isNotEmpty ||
            state.goals.isNotEmpty ||
            state.loans.isNotEmpty;

        return Scaffold(
          backgroundColor: PfmTheme.scaffold,
          drawer: const PfmDrawer(),
          appBar: PfmPageHeader(
            title: 'Export Report',
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          body: !hasData
              ? const Center(child: PfmNoDataBox(message: 'Nothing to export yet.'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          PfmSurfaceCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Report Type',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                ...List.generate(_reports.length, (i) {
                                  return RadioListTile<int>(
                                    value: i,
                                    groupValue: _reportIndex,
                                    activeColor: PfmTheme.primary,
                                    title: Text(_reports[i], style: const TextStyle(fontSize: 14)),
                                    onChanged: (v) => setState(() => _reportIndex = v!),
                                    contentPadding: EdgeInsets.zero,
                                  );
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          PfmSurfaceCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                PfmFormDropdown<int>(
                                  label: 'Export format',
                                  value: _formatIndex,
                                  items: List.generate(
                                    _formats.length,
                                    (i) => DropdownMenuItem(value: i, child: Text(_formats[i])),
                                  ),
                                  onChanged: (v) => setState(() => _formatIndex = v ?? 0),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      child: PfmPrimaryButton(
                        label: 'Export',
                        onPressed: () => _export(context, state),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Future<void> _export(BuildContext context, PfmState state) async {
    final snapshot = state.snapshot;
    if (snapshot == null) return;

    final service = FinanceExportService();
    final type = switch (_formatIndex) {
      0 => 'excel',
      1 => 'pdf',
      _ => 'csv',
    };

    try {
      late final String path;
      switch (type) {
        case 'excel':
          path = (await service.exportExcel(
            snapshot: snapshot,
            transactions: state.transactions,
            goals: state.goals,
            loans: state.loans,
            insights: snapshot.insights,
          )).path;
        case 'pdf':
          path = (await service.exportPdf(
            snapshot: snapshot,
            insights: snapshot.insights,
          )).path;
        case 'csv':
          path = (await service.exportCsv(state.transactions)).path;
        default:
          return;
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exported to $path')));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }
}
