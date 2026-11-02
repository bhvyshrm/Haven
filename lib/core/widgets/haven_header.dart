import 'package:flutter/material.dart';

import '../theme/haven_colors.dart';
import '../theme/haven_typography.dart';

class HavenHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool isHome;
  final String? title;
  final Widget? leading;
  final Widget? trailing;
  final bool showBottomDivider;
  final VoidCallback? onTitleTap;
  final bool useSafeArea;

  const HavenHeader({
    super.key,
    this.isHome = true,
    this.title,
    this.leading,
    this.trailing,
    this.showBottomDivider = false,
    this.onTitleTap,
    this.useSafeArea = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? HavenColors.darkTextPrimary
        : HavenColors.lightTextPrimary;
    final borderColor = isDark
        ? HavenColors.darkBorder
        : HavenColors.lightBorder;
    final canvasColor = isDark
        ? HavenColors.darkCanvas
        : HavenColors.lightCanvas;

    final content = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640.0),
        child: Container(
          height: 56.0,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          decoration: BoxDecoration(
            border: (!isHome && showBottomDivider)
                ? Border(bottom: BorderSide(color: borderColor, width: 1.0))
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isHome)
                GestureDetector(
                  onTap: onTitleTap,
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    'haven',
                    style: TextStyle(
                      fontFamilyFallback: const [
                        'New York',
                        'Baskerville',
                        'Georgia',
                        'Didot',
                        'serif',
                      ],
                      fontSize: 28.0,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.2,
                      color: primaryTextColor,
                    ),
                  ),
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (leading != null) ...[
                      leading!,
                      const SizedBox(width: 8.0),
                    ],
                    if (title != null)
                      Text(
                        title!,
                        style: HavenTypography.headlineSm(primaryTextColor)
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
              if (trailing != null) trailing! else const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );

    return Container(
      color: canvasColor,
      child: useSafeArea ? SafeArea(bottom: false, child: content) : content,
    );
  }
}
