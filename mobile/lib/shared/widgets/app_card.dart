import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final BorderSide? border;
  final double borderRadius;
  final VoidCallback? onTap;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.border,
    this.borderRadius = 20,
    this.onTap,
    this.boxShadow,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final defaultBorder = isDark ? AppColors.borderDark : AppColors.borderLight;

    final cardContent = Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? defaultBg) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border != null
            ? Border.fromBorderSide(border!)
            : Border.all(color: defaultBorder, width: 1),
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.25)
                    : const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
