import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mindloop/presentation/blocs/auth/auth_bloc.dart';
import 'package:mindloop/themes/app_colors.dart';
import 'package:mindloop/widgets/app_list_rows.dart';
import 'package:mindloop/widgets/glass_card.dart';
import 'package:mindloop/widgets/mind_loop_logo.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          const SliverAppBar(floating: true, title: Text('Profile')),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Center(
                  child: Column(
                    children: [
                      const MindLoopLogo(size: 88),
                      const SizedBox(height: 16),
                      Text(
                        auth.userName ?? 'User',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        auth.userEmail ?? '',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                GlassCard(
                  animate: false,
                  child: AppNavRow(
                    title: 'Settings',
                    icon: Icons.settings_rounded,
                    onTap: () => context.push('/settings'),
                  ),
                ),
                const SizedBox(height: 8),
                GlassCard(
                  animate: false,
                  child: AppNavRow(
                    title: 'Future Features',
                    icon: Icons.rocket_launch_rounded,
                    onTap: () => context.push('/future'),
                  ),
                ),
                const SizedBox(height: 8),
                GlassCard(
                  animate: false,
                  child: AppNavRow(
                    title: 'Preview Reminder Alert',
                    icon: Icons.notifications_active,
                    onTap: () => context.push('/alert'),
                  ),
                ),
                const SizedBox(height: 16),
                GlassCard(
                  animate: false,
                  child: AppNavRow(
                    title: 'Logout',
                    icon: Icons.logout,
                    trailing: const SizedBox.shrink(),
                    onTap: () {
                      context.read<AuthBloc>().add(AuthLogoutRequested());
                    },
                  ),
                ),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
