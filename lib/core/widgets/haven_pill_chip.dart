import 'package:flutter/material.dart';
import '../theme/haven_colors.dart';
import '../theme/haven_typography.dart';

class HavenPillChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const HavenPillChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? HavenColors.darkTextPrimary : HavenColors.lightTextPrimary;
    final secondaryTextColor = isDark ? HavenColors.darkTextSecondary : HavenColors.lightTextSecondary;
    final borderColor = isDark ? HavenColors.darkBorder : HavenColors.lightBorder;
    final canvasColor = isDark ? HavenColors.darkCanvas : HavenColors.lightCanvas;

    final bgColor = isSelected ? primaryTextColor : Colors.transparent;
    final textColor = isSelected ? canvasColor : secondaryTextColor;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9999.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 7.0),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(9999.0),
              border: Border.all(
                color: isSelected ? primaryTextColor : borderColor,
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 14.0,
                    color: textColor,
                  ),
                  const SizedBox(width: 6.0),
                ],
                Text(
                  label,
                  style: HavenTypography.labelSm(textColor).copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
