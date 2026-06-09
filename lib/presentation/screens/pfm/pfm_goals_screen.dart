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

class PfmGoalsScreen extends StatelessWidget {
  const PfmGoalsScreen({super.key});

  static IconData _iconFor(String name) {
    final n = name.toLowerCase();
    if (n.contains('gold')) return Icons.monetization_on_outlined;
    if (n.contains('bike')) return Icons.two_wheeler_outlined;
    if (n.contains('emergency')) return Icons.health_and_safety_outlined;
    if (n.contains('trip') || n.contains('vacation')) return Icons.flight_outlined;
    return Icons.flag_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PfmBloc>().state;
    final fmt = CurrencyPreferences.formatter(decimalDigits: 0);

    return Scaffold(
      backgroundColor: PfmTheme.scaffold,
      drawer: const PfmDrawer(),
      appBar: PfmPageHeader(
        title: 'Goals',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: PfmTheme.primary),
            onPressed: () => PfmAddSheets.showGoal(context),
          ),
        ],
      ),
      body: state.goals.isEmpty
          ? const Center(child: PfmNoDataBox(message: 'No goals saved yet.'))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              itemCount: state.goals.length,
              itemBuilder: (context, i) {
                final g = state.goals[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PfmSurfaceCard(
                    onTap: () => PfmAddSheets.showGoal(context, existing: g),
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
                              child: Icon(_iconFor(g.name), color: PfmTheme.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                g.name,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                              ),
                            ),
                            Text(
                              '${g.completionPercent.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: PfmTheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${fmt.format(g.currentAmount)} / ${fmt.format(g.targetAmount)}',
                          style: const TextStyle(color: PfmTheme.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: g.completionPercent / 100,
                            minHeight: 8,
                            backgroundColor: PfmTheme.border,
                            color: PfmTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Target: ${DateFormat.MMMd().format(g.targetDate)}',
                          style: const TextStyle(fontSize: 12, color: PfmTheme.textMuted),
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
