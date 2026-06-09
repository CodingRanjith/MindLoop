import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mindloop/presentation/blocs/auth/auth_bloc.dart';
import 'package:mindloop/themes/pfm_theme.dart';
import 'package:mindloop/widgets/pfm/pfm_ui_kit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final name = auth.userName ?? 'User';
    final email = auth.userEmail ?? '';

    return Scaffold(
      backgroundColor: PfmTheme.scaffold,
      appBar: PfmPageHeader(
        title: 'Profile',
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: PfmTheme.textPrimary),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          PfmProfileHeaderCard(name: name, email: email),
          const SizedBox(height: 20),
          _MenuCard(
            children: [
              PfmMenuRow(
                icon: Icons.person_outline,
                title: 'Personal Information',
                onTap: () => context.push('/settings'),
              ),
              const Divider(height: 1, indent: 70),
              PfmMenuRow(
                icon: Icons.account_balance_outlined,
                title: 'Bank Accounts',
                onTap: () => context.push('/finance/net-worth'),
              ),
              const Divider(height: 1, indent: 70),
              PfmMenuRow(
                icon: Icons.payment_outlined,
                title: 'Payment Methods',
                onTap: () => context.push('/finance/transactions'),
              ),
              const Divider(height: 1, indent: 70),
              PfmMenuRow(
                icon: Icons.category_outlined,
                title: 'Categories',
                onTap: () => context.push('/finance/budget'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _MenuCard(
            children: [
              PfmMenuRow(
                icon: Icons.cloud_upload_outlined,
                title: 'Backup & Restore',
                onTap: () => context.push('/settings'),
              ),
              const Divider(height: 1, indent: 70),
              PfmMenuRow(
                icon: Icons.file_download_outlined,
                title: 'Export Data',
                onTap: () => context.push('/finance/export'),
              ),
              const Divider(height: 1, indent: 70),
              PfmMenuRow(
                icon: Icons.notifications_active_outlined,
                title: 'Expense Reminders',
                onTap: () => context.push('/settings'),
              ),
              const Divider(height: 1, indent: 70),
              PfmMenuRow(
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () => context.push('/settings'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _MenuCard(
            children: [
              PfmMenuRow(
                icon: Icons.logout_rounded,
                title: 'Logout',
                iconColor: PfmTheme.expense,
                titleColor: PfmTheme.expense,
                showChevron: false,
                onTap: () => context.read<AuthBloc>().add(AuthLogoutRequested()),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'MindLoop v1.0.0',
              style: TextStyle(fontSize: 12, color: PfmTheme.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: PfmTheme.cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}
