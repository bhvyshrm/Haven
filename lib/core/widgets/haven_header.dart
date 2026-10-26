import 'package:flutter/material.dart';
import '../theme/haven_colors.dart';
import '../theme/haven_typography.dart';

class HavenHeader extends StatelessWidget implements PreferredSizeWidget {
  final Widget? trailing;
  final bool showBottomDivider;
  final VoidCallback? onTitleTap;

  const HavenHeader({
    super.key,
    this.trailing,
    this.showBottomDivider = true,
    this.onTitleTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? HavenColors.darkTextPrimary : HavenColors.lightTextPrimary;
    final borderColor = isDark ? HavenColors.darkBorder : HavenColors.lightBorder;
    final canvasColor = isDark ? HavenColors.darkCanvas : HavenColors.lightCanvas;

    return Container(
      color: canvasColor,
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640.0),
            child: Container(
              height: 56.0,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              decoration: BoxDecoration(
                border: showBottomDivider
                    ? Border(
                        bottom: BorderSide(color: borderColor, width: 1.0),
                      )
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: onTitleTap,
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      'haven',
                      style: TextStyle(
                        fontFamily: HavenTypography.fontFamily,
                        fontSize: 26.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                        color: primaryTextColor,
                      ),
                    ),
                  ),
                  ?trailing,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
