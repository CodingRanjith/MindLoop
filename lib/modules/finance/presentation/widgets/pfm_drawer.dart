import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mindloop/modules/auth/presentation/bloc/auth_bloc.dart';
import 'package:mindloop/shared/theme/pfm_theme.dart';

/// Side navigation for Finance — replaces the old bottom-sheet menu.
class PfmDrawer extends StatelessWidget {
  const PfmDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final name = auth.userName?.trim();
    final displayName = (name != null && name.isNotEmpty) ? name : 'User';
    final initial = displayName[0].toUpperCase();
    final location = GoRouterState.of(context).uri.toString();

    return Drawer(
      backgroundColor: PfmTheme.surface,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
              decoration: const BoxDecoration(
                gradient: PfmTheme.brandGradient,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Finance Hub',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  _DrawerTile(
                    icon: Icons.dashboard_outlined,
                    title: 'Dashboard',
                    route: '/finance/dashboard',
                    current: location,
                  ),
                  _DrawerTile(
                    icon: Icons.receipt_long_outlined,
                    title: 'Transactions',
                    route: '/finance/transactions',
                    current: location,
                  ),
                  _DrawerTile(
                    icon: Icons.insights_outlined,
                    title: 'Analytics',
                    route: '/finance/analytics',
                    current: location,
                  ),
                  _DrawerTile(
                    icon: Icons.pie_chart_outline,
                    title: 'Budget',
                    route: '/finance/budget',
                    current: location,
                  ),
                  _DrawerTile(
                    icon: Icons.category_outlined,
                    title: 'Categories',
                    route: '/finance/categories',
                    current: location,
                  ),
                  _DrawerTile(
                    icon: Icons.flag_outlined,
                    title: 'Goals',
                    route: '/finance/goals',
                    current: location,
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Text(
                      'More',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: PfmTheme.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  _DrawerTile(
                    icon: Icons.account_balance_outlined,
                    title: 'Loans',
                    route: '/finance/loans',
                    current: location,
                  ),
                  _DrawerTile(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Net Worth',
                    route: '/finance/net-worth',
                    current: location,
                  ),
                  _DrawerTile(
                    icon: Icons.file_download_outlined,
                    title: 'Export Report',
                    route: '/finance/export',
                    current: location,
                  ),
                  _DrawerTile(
                    icon: Icons.auto_awesome_outlined,
                    title: 'AI Insights',
                    route: '/finance/insights',
                    current: location,
                  ),
                  _DrawerTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    route: '/finance/notifications',
                    current: location,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: PfmTheme.border),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: PfmTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.settings_outlined, color: PfmTheme.primary, size: 20),
              ),
              title: const Text(
                'Settings',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push('/settings');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.route,
    required this.current,
  });

  final IconData icon;
  final String title;
  final String route;
  final String current;

  @override
  Widget build(BuildContext context) {
    final selected = current.startsWith(route);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        tileColor: selected ? PfmTheme.primary.withValues(alpha: 0.08) : null,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: selected
                ? PfmTheme.brandGradient
                : LinearGradient(
                    colors: [
                      PfmTheme.primary.withValues(alpha: 0.12),
                      PfmTheme.chartNeeds.withValues(alpha: 0.08),
                    ],
                  ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: selected ? Colors.white : PfmTheme.primary,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            fontSize: 15,
            color: selected ? PfmTheme.primary : PfmTheme.textPrimary,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: selected ? PfmTheme.primary : PfmTheme.textMuted,
          size: 22,
        ),
        onTap: () {
          Navigator.pop(context);
          if (!current.startsWith(route)) {
            context.push(route);
          }
        },
      ),
    );
  }
}
