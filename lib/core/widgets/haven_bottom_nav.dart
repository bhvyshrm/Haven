import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/haven_colors.dart';

class HavenBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;

  const HavenBottomNav({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Respect keyboard visibility: hide the floating navigation bar when typing
    // so it doesn't obstruct inputs, notes lists, or search results.
    final keyboardVisible =
        MediaQuery.viewInsetsOf(context).bottom > 0 ||
        View.of(context).viewInsets.bottom > 0;
    if (keyboardVisible) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark
        ? HavenColors.darkSurface.withValues(alpha: 0.94)
        : HavenColors.lightCanvas.withValues(alpha: 0.94);
    final borderColor = isDark
        ? HavenColors.darkBorder
        : HavenColors.lightBorder;
    final activeColor = isDark
        ? HavenColors.darkTextPrimary
        : HavenColors.lightTextPrimary;
    final inactiveColor = isDark
        ? HavenColors.darkTextSecondary
        : HavenColors.lightTextSecondary;

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9999.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 340.0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 6.0,
                ),
                decoration: BoxDecoration(
                  color: navBg,
                  borderRadius: BorderRadius.circular(9999.0),
                  border: Border.all(color: borderColor, width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.40 : 0.06,
                      ),
                      blurRadius: 16.0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: currentIndex == 0
                          ? Icons.home_rounded
                          : Icons.home_outlined,
                      label: 'Home',
                      isSelected: currentIndex == 0,
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                      onTap: () => onIndexChanged(0),
                    ),
                    _NavItem(
                      icon: currentIndex == 1
                          ? Icons.menu_book_rounded
                          : Icons.menu_book_outlined,
                      label: 'Journal',
                      isSelected: currentIndex == 1,
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                      onTap: () => onIndexChanged(1),
                    ),
                    _NavItem(
                      icon: currentIndex == 2
                          ? Icons.edit_note_rounded
                          : Icons.edit_note_outlined,
                      label: 'Notes',
                      isSelected: currentIndex == 2,
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                      onTap: () => onIndexChanged(2),
                    ),
                    _NavItem(
                      icon: currentIndex == 3
                          ? Icons.explore_rounded
                          : Icons.explore_outlined,
                      label: 'Discover',
                      isSelected: currentIndex == 3,
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                      onTap: () => onIndexChanged(3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? activeColor : inactiveColor;

    return Semantics(
      label: label,
      selected: isSelected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9999.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: Icon(
                  icon,
                  key: ValueKey<IconData>(icon),
                  size: 24.0,
                  color: color,
                ),
              ),
              const SizedBox(height: 3.0),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                width: isSelected ? 4.0 : 0.0,
                height: 4.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? activeColor : Colors.transparent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
