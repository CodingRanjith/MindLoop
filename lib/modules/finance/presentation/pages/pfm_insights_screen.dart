import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindloop/modules/finance/presentation/bloc/pfm_bloc.dart';
import 'package:mindloop/shared/theme/pfm_theme.dart';
import 'package:mindloop/modules/finance/presentation/widgets/pfm_empty_data.dart';
import 'package:mindloop/modules/finance/presentation/widgets/pfm_drawer.dart';
import 'package:mindloop/modules/finance/presentation/widgets/pfm_ui_kit.dart';

class PfmInsightsScreen extends StatelessWidget {
  const PfmInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final insights = context.watch<PfmBloc>().state.snapshot?.insights ?? [];

    return Scaffold(
      backgroundColor: PfmTheme.scaffold,
      drawer: const PfmDrawer(),
      appBar: PfmPageHeader(
        title: 'AI Insights',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: insights.isEmpty
          ? const Center(child: PfmNoDataBox(message: 'Insights appear when you have enough transaction data.'))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              itemCount: insights.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final icons = [
                  (Icons.shopping_bag_outlined, const Color(0xFFFCE7F3), PfmTheme.expense),
                  (Icons.savings_outlined, const Color(0xFFFEE2E2), PfmTheme.expense),
                  (Icons.bar_chart_rounded, const Color(0xFFE0E7FF), PfmTheme.primary),
                  (Icons.shield_outlined, const Color(0xFFD1FAE5), PfmTheme.income),
                ];
                final item = icons[i % icons.length];
                return PfmInsightTile(
                  icon: item.$1,
                  iconBg: item.$2,
                  iconColor: item.$3,
                  text: insights[i],
                );
              },
            ),
    );
  }
}
