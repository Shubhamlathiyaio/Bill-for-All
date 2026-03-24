import 'package:flutter/material.dart';
import '../../utils/helpers/extensions.dart';

/// AppButton — gradient primary button.
/// Never use ElevatedButton directly in pages.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
  });

  final String title;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isActive = enabled && !isLoading;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: isActive ? colors.primaryGradient : null,
          color: isActive ? null : colors.bg1,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: colors.primary.changeOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: ElevatedButton(
          onPressed: isActive ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Text(
                  title,
                  style: context.styles.s16w600White.copyWith(
                    color: isActive
                        ? colors.white
                        : colors.white.changeOpacity(0.3),
                  ),
                ),
        ),
      ),
    );
  }
}
