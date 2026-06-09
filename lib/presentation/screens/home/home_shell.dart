import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mindloop/core/utils/app_responsive.dart';
import 'package:go_router/go_router.dart';
import 'package:mindloop/presentation/screens/pfm/pfm_add_sheets.dart';
import 'package:mindloop/themes/app_colors.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.child});

  final Widget child;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _getIndex(String location) {
    if (location.startsWith('/calendar')) return 1;
    if (location.startsWith('/finance') || location.startsWith('/budget')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  void _onTap(int index) {
    HapticFeedback.selectionClick();
    switch (index) {
      case 0:
        context.go('/home');
      case 1:
        context.go('/calendar');
      case 2:
        context.go('/finance/dashboard');
      case 3:
        context.go('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _getIndex(location);
    final onFinance = location.startsWith('/finance') || location.startsWith('/budget');

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final location = GoRouterState.of(context).uri.toString();
        if (location != '/home') {
          context.go('/home');
          return;
        }
        final shouldExit = await _showExitDialog(context);
        if (!context.mounted) return;
        if (shouldExit == true) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffold,
        extendBody: true,
        body: ResponsiveContent(child: widget.child),
        floatingActionButton: onFinance
            ? const PfmQuickAddFab()
            : FloatingActionButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  context.push('/reminder/create');
                },
                backgroundColor: AppColors.primary,
                elevation: 2,
                highlightElevation: 4,
                child: const Icon(Icons.add, size: 26),
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: BottomAppBar(
              color: Colors.transparent,
              elevation: 0,
              height: 60,
              notchMargin: 6,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              shape: const CircularNotchedRectangle(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                  selected: index == 0,
                  onTap: () => _onTap(0),
                ),
                _NavItem(
                  icon: Icons.calendar_month_outlined,
                  activeIcon: Icons.calendar_month_rounded,
                  label: 'Calendar',
                  selected: index == 1,
                  onTap: () => _onTap(1),
                ),
                const SizedBox(width: 56),
                _NavItem(
                  icon: Icons.pie_chart_outline_rounded,
                  activeIcon: Icons.pie_chart_rounded,
                  label: 'Finance',
                  selected: index == 2,
                  onTap: () => _onTap(2),
                ),
                _NavItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Profile',
                  selected: index == 3,
                  onTap: () => _onTap(3),
                ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Exit MindLoop?'),
          content: const Text('Are you sure you want to close the app?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textMuted;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? activeIcon : icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                height: 1,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
