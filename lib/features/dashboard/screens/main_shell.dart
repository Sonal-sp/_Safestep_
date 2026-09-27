import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/shell_provider.dart';
import '../../medicines/screens/medicines_screen.dart';
import '../../sos/screens/sos_screen.dart';
import '../../history/screens/history_screen.dart';
import '../../profile/screens/profile_screen.dart';
import 'dashboard_screen.dart';
import 'package:safestep/core/l10n/app_localizations.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selectedIndex = ref.watch(selectedTabIndexProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: selectedIndex,
        children: const [
          DashboardScreen(),
          MedicinesScreen(),
          SosScreen(),
          HistoryScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkCard.withAlpha(240)
              : Colors.white.withAlpha(240),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withAlpha(isDark ? 80 : 20),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: cs.outlineVariant.withAlpha(60),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              index: 0,
              selectedIndex: selectedIndex,
              icon: Icons.home_outlined,
              selectedIcon: Icons.home_rounded,
              label: l10n.home,
              onTap: () => ref.read(selectedTabIndexProvider.notifier).state = 0,
            ),
            _NavItem(
              index: 1,
              selectedIndex: selectedIndex,
              icon: Icons.medication_outlined,
              selectedIcon: Icons.medication_rounded,
              label: l10n.medicines,
              onTap: () => ref.read(selectedTabIndexProvider.notifier).state = 1,
            ),
            _SosNavItem(
              isSelected: selectedIndex == 2,
              onTap: () => ref.read(selectedTabIndexProvider.notifier).state = 2,
            ),
            _NavItem(
              index: 3,
              selectedIndex: selectedIndex,
              icon: Icons.history_rounded,
              selectedIcon: Icons.history_edu_rounded,
              label: l10n.history,
              onTap: () => ref.read(selectedTabIndexProvider.notifier).state = 3,
            ),
            _NavItem(
              index: 4,
              selectedIndex: selectedIndex,
              icon: Icons.person_outline_rounded,
              selectedIcon: Icons.person_rounded,
              label: l10n.profile,
              onTap: () => ref.read(selectedTabIndexProvider.notifier).state = 4,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.index,
    required this.selectedIndex,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.onTap,
  });

  final int index;
  final int selectedIndex;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selectedIndex;
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? selectedIcon : icon,
                key: ValueKey(isSelected),
                color: isSelected ? cs.primary : cs.onSurfaceVariant,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? cs.primary : cs.onSurfaceVariant,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SosNavItem extends StatelessWidget {
  const _SosNavItem({required this.onTap, required this.isSelected});
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Transform.translate(
        offset: const Offset(0, -14),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.error,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.error.withAlpha(80),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: const Center(
            child: Icon(Icons.emergency_rounded, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}
