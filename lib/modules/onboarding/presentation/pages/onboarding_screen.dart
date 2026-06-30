import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindloop/modules/auth/presentation/bloc/auth_bloc.dart';
import 'package:mindloop/shared/theme/app_colors.dart';
import 'package:mindloop/shared/widgets/dynamic_background.dart';
import 'package:mindloop/shared/widgets/glow_button.dart';
import 'package:mindloop/shared/widgets/mind_loop_logo.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _index = 0;

  final _pages = const [
    _OnboardPage(
      icon: Icons.notifications_active_rounded,
      title: 'Never Forget',
      subtitle: 'Smart reminders with emotional full-screen alerts.',
    ),
    _OnboardPage(
      icon: Icons.account_balance_wallet_rounded,
      title: 'Budget Control',
      subtitle: 'Track income, expenses, and savings in one place.',
    ),
    _OnboardPage(
      icon: Icons.auto_awesome_rounded,
      title: 'Futuristic Experience',
      subtitle: 'Premium UI, dynamic backgrounds, and cinematic motion.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DynamicBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              const MindLoopLogo(size: 56),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (_, i) => _pages[i],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _index == i ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: _index == i ? AppColors.primaryGradient : null,
                      color: _index == i
                          ? null
                          : AppColors.surfaceMuted,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: GlowButton(
                  label: _index == _pages.length - 1 ? 'Get Started' : 'Next',
                  onPressed: () {
                    if (_index < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                      );
                    } else {
                      context.read<AuthBloc>().add(AuthOnboardingCompleted());
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  const _OnboardPage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: AppColors.accent),
          const SizedBox(height: 32),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
