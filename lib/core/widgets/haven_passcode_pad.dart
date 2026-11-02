import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/haven_colors.dart';
import '../theme/haven_typography.dart';

class HavenPasscodePad extends StatefulWidget {
  final String title;
  final String? subtitle;
  final ValueChanged<String> onPasscodeComplete;
  final String? errorMessage;
  final bool showBiometrics;
  final VoidCallback? onBiometricsTap;
  final VoidCallback? onCancel;

  const HavenPasscodePad({
    super.key,
    required this.title,
    this.subtitle,
    required this.onPasscodeComplete,
    this.errorMessage,
    this.showBiometrics = false,
    this.onBiometricsTap,
    this.onCancel,
  });

  @override
  State<HavenPasscodePad> createState() => _HavenPasscodePadState();
}

class _HavenPasscodePadState extends State<HavenPasscodePad> {
  String _enteredCode = '';

  void _onDigitPress(String digit) {
    if (_enteredCode.length < 4) {
      HapticFeedback.lightImpact();
      setState(() {
        _enteredCode += digit;
      });
      if (_enteredCode.length == 4) {
        final code = _enteredCode;
        widget.onPasscodeComplete(code);
      }
    }
  }

  void _onDelete() {
    if (_enteredCode.isNotEmpty) {
      HapticFeedback.lightImpact();
      setState(() {
        _enteredCode = _enteredCode.substring(0, _enteredCode.length - 1);
      });
    }
  }

  void clear() {
    setState(() {
      _enteredCode = '';
    });
  }

  @override
  void didUpdateWidget(covariant HavenPasscodePad oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorMessage != null && oldWidget.errorMessage == null) {
      _enteredCode = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? HavenColors.darkTextPrimary
        : HavenColors.lightTextPrimary;
    final secondaryTextColor = isDark
        ? HavenColors.darkTextSecondary
        : HavenColors.lightTextSecondary;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: HavenTypography.headlineSm(primaryTextColor)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            if (widget.subtitle != null) ...[
              const SizedBox(height: 6.0),
              Text(
                widget.subtitle!,
                textAlign: TextAlign.center,
                style: HavenTypography.bodySm(secondaryTextColor),
              ),
            ],
            const SizedBox(height: 24.0),

            // 4 Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final isFilled = index < _enteredCode.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10.0),
                  width: 14.0,
                  height: 14.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFilled ? primaryTextColor : Colors.transparent,
                    border: Border.all(
                      color: isFilled ? primaryTextColor : secondaryTextColor,
                      width: 1.5,
                    ),
                  ),
                );
              }),
            ),

            // Error message
            SizedBox(
              height: 36.0,
              child: Center(
                child: widget.errorMessage != null
                    ? Text(
                        widget.errorMessage!,
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFFFF6B6B)
                              : const Color(0xFFD32F2F),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : null,
              ),
            ),

            // Keypad (3 rows of digits 1-9)
            ...[
              ['1', '2', '3'],
              ['4', '5', '6'],
              ['7', '8', '9'],
            ].map((row) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: row.map((d) => _buildKey(d)).toList(),
                ),
              );
            }),

            // Bottom Row (Biometrics / Empty, 0, Backspace / Cancel)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Left action: Biometrics or Cancel
                  if (widget.showBiometrics && widget.onBiometricsTap != null)
                    _buildActionButton(
                      icon: Icons.fingerprint_rounded,
                      onTap: widget.onBiometricsTap!,
                      tooltip: 'Biometrics',
                    )
                  else if (widget.onCancel != null)
                    _buildActionButton(
                      icon: Icons.close_rounded,
                      onTap: widget.onCancel!,
                      tooltip: 'Cancel',
                    )
                  else
                    const SizedBox(width: 68.0, height: 68.0),

                  // Digit 0
                  _buildKey('0'),

                  // Right action: Backspace
                  _buildActionButton(
                    icon: Icons.backspace_outlined,
                    onTap: _onDelete,
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKey(String digit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? HavenColors.darkTextPrimary
        : HavenColors.lightTextPrimary;
    final surfaceColor = isDark
        ? HavenColors.darkSurface
        : HavenColors.lightSurface;
    final borderColor = isDark
        ? HavenColors.darkBorder
        : HavenColors.lightBorder;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onDigitPress(digit),
        borderRadius: BorderRadius.circular(34.0),
        child: Container(
          width: 68.0,
          height: 68.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: surfaceColor,
            border: Border.all(color: borderColor, width: 1.0),
          ),
          alignment: Alignment.center,
          child: Text(
            digit,
            style: HavenTypography.headlineMd(primaryTextColor)
                .copyWith(fontWeight: FontWeight.w500, fontSize: 24.0),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? HavenColors.darkTextPrimary
        : HavenColors.lightTextPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(34.0),
        child: SizedBox(
          width: 68.0,
          height: 68.0,
          child: Icon(icon, color: primaryTextColor, size: 24.0),
        ),
      ),
    );
  }
}
