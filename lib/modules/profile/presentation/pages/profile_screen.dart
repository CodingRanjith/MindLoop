import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mindloop/app/di/injection.dart';
import 'package:mindloop/modules/auth/presentation/bloc/auth_bloc.dart';
import 'package:mindloop/modules/profile/core/utils/user_profile_store.dart';
import 'package:mindloop/modules/profile/domain/entities/user_profile.dart';
import 'package:mindloop/modules/profile/presentation/widgets/profile_header_card.dart';
import 'package:mindloop/shared/theme/pfm_theme.dart';
import 'package:mindloop/modules/finance/presentation/widgets/pfm_ui_kit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserProfile _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    setState(() => _profile = UserProfileStore(sl()).load());
  }

  Future<void> _openPersonalInfo() async {
    final saved = await context.push<bool>('/profile/info');
    if (saved == true && mounted) _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
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
          ProfileHeaderCard(
            profile: _profile,
            subtitle: email.isNotEmpty ? email : null,
          ),
          const SizedBox(height: 20),
          _MenuCard(
            children: [
              PfmMenuRow(
                icon: Icons.person_outline,
                title: 'Personal Information',
                onTap: _openPersonalInfo,
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
