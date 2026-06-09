import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindloop/core/utils/currency_preferences.dart';
import 'package:mindloop/domain/entities/net_worth_item_entity.dart';
import 'package:mindloop/presentation/blocs/pfm/pfm_bloc.dart';
import 'package:mindloop/presentation/screens/pfm/pfm_add_sheets.dart';
import 'package:mindloop/themes/pfm_theme.dart';
import 'package:mindloop/widgets/pfm/pfm_empty_data.dart';
import 'package:mindloop/widgets/pfm/pfm_drawer.dart';
import 'package:mindloop/widgets/pfm/pfm_ui_kit.dart';

class PfmNetWorthScreen extends StatelessWidget {
  const PfmNetWorthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PfmBloc>().state;
    final fmt = CurrencyPreferences.formatter(decimalDigits: 0);
    final assets = state.netWorthItems.where((i) => i.type == NetWorthType.asset).toList();
    final liabilities = state.netWorthItems.where((i) => i.type == NetWorthType.liability).toList();
    final totalAssets = assets.fold<double>(0, (s, i) => s + i.amount);
    final totalLiab = liabilities.fold<double>(0, (s, i) => s + i.amount);
    final net = totalAssets - totalLiab;
    final growth = state.monthComparisons['savingsGrowth'] ?? 0;

    return Scaffold(
      backgroundColor: PfmTheme.scaffold,
      drawer: const PfmDrawer(),
      appBar: PfmPageHeader(
        title: 'Net Worth',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.add, color: PfmTheme.primary),
            onSelected: (v) {
              if (v == 'asset') PfmAddSheets.showNetWorthItem(context, type: NetWorthType.asset);
              if (v == 'liability') {
                PfmAddSheets.showNetWorthItem(context, type: NetWorthType.liability);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'asset', child: Text('Add asset')),
              PopupMenuItem(value: 'liability', child: Text('Add liability')),
            ],
          ),
        ],
      ),
      body: state.netWorthItems.isEmpty
          ? const Center(child: PfmNoDataBox(message: 'Add assets and liabilities to calculate net worth.'))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              children: [
                PfmSurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Net Worth Overview', style: TextStyle(color: PfmTheme.textSecondary)),
                      const SizedBox(height: 8),
                      Text(
                        fmt.format(state.snapshot?.netWorth ?? net),
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'This Month ${growth >= 0 ? '↑' : '↓'} ${growth.abs().toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: growth >= 0 ? PfmTheme.income : PfmTheme.expense,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SectionHeader(title: 'Assets', total: fmt.format(totalAssets)),
                ...assets.map((i) => _LineItem(name: i.name, amount: fmt.format(i.amount))),
                const SizedBox(height: 12),
                _SectionHeader(title: 'Liabilities', total: fmt.format(totalLiab)),
                ...liabilities.map((i) => _LineItem(name: i.name, amount: fmt.format(i.amount))),
              ],
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.total});
  final String title;
  final String total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          Text(total, style: const TextStyle(fontWeight: FontWeight.w800, color: PfmTheme.primary)),
        ],
      ),
    );
  }
}

class _LineItem extends StatelessWidget {
  const _LineItem({required this.name, required this.amount});
  final String name;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: PfmSurfaceCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(amount, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
