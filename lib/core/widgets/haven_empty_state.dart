import 'package:flutter/material.dart';
import '../theme/haven_colors.dart';
import '../theme/haven_typography.dart';

class HavenEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  const HavenEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? HavenColors.darkTextPrimary : HavenColors.lightTextPrimary;
    final secondaryTextColor = isDark ? HavenColors.darkTextSecondary : HavenColors.lightTextSecondary;
    final surfaceColor = isDark ? HavenColors.darkSurface : HavenColors.lightSurface;
    final borderColor = isDark ? HavenColors.darkBorder : HavenColors.lightBorder;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56.0,
              height: 56.0,
              decoration: BoxDecoration(
                color: surfaceColor,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 1.0),
              ),
              child: Icon(
                icon,
                size: 26.0,
                color: secondaryTextColor,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              title,
              textAlign: TextAlign.center,
              style: HavenTypography.headlineSm(primaryTextColor).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              description,
              textAlign: TextAlign.center,
              style: HavenTypography.bodySm(secondaryTextColor).copyWith(
                height: 1.45,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryTextColor,
                  foregroundColor: isDark ? HavenColors.darkCanvas : HavenColors.lightCanvas,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: HavenTypography.labelMd(
                    isDark ? HavenColors.darkCanvas : HavenColors.lightCanvas,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
