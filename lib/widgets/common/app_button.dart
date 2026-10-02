import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';

enum ButtonVariant { primary, secondary, danger, outline }

/// Primary action button — used for the main CTA on each screen.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final ButtonVariant variant;
  final IconData? icon;
  final IconData? prefixIcon;
  final double? width;
  final Color? backgroundColor;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.prefixIcon,
    this.width,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIcon = icon ?? prefixIcon;

    Widget child = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (effectiveIcon != null) ...[
                Icon(effectiveIcon, size: 18),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          );

    if (isOutlined || variant == ButtonVariant.outline) {
      return SizedBox(
        width: width ?? double.infinity,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primary),
            foregroundColor: AppColors.primary,
          ),
          child: child,
        ),
      );
    }

    if (variant == ButtonVariant.secondary) {
      return SizedBox(
        width: width ?? double.infinity,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.bgSurface,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            side: const BorderSide(color: AppColors.borderSubtle),
          ),
          child: child,
        ),
      );
    }

    if (variant == ButtonVariant.danger) {
      return SizedBox(
        width: width ?? double.infinity,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error.withValues(alpha: 0.1),
            foregroundColor: AppColors.error,
            elevation: 0,
            side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: backgroundColor != null
            ? ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: AppColors.textInverse,
              )
            : ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textInverse,
                elevation: 0,
              ),
        child: child,
      ),
    );
  }
}
