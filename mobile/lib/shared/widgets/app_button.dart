import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum AppButtonVariant { primary, secondary, outline, text, danger }

class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double height;
  final double borderRadius;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = 52,
    this.borderRadius = 16,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.04,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDisabled = widget.onPressed == null || widget.isLoading;

    Color bg;
    Color textCol;
    BorderSide border = BorderSide.none;

    switch (widget.variant) {
      case AppButtonVariant.primary:
        bg = isDisabled ? AppColors.primary.withValues(alpha: 0.5) : AppColors.primary;
        textCol = Colors.white;
        break;
      case AppButtonVariant.secondary:
        bg = isDark
            ? (isDisabled ? AppColors.surfaceSubtleDark : AppColors.surfaceSubtleDark)
            : (isDisabled ? AppColors.surfaceSubtleLight : AppColors.surfaceSubtleLight);
        textCol = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
        break;
      case AppButtonVariant.outline:
        bg = Colors.transparent;
        textCol = isDark ? AppColors.primaryLight : AppColors.primary;
        border = BorderSide(
          color: isDark ? AppColors.primaryLight : AppColors.primary,
          width: 1.5,
        );
        break;
      case AppButtonVariant.text:
        bg = Colors.transparent;
        textCol = isDark ? AppColors.primaryLight : AppColors.primary;
        break;
      case AppButtonVariant.danger:
        bg = isDisabled ? AppColors.error.withValues(alpha: 0.5) : AppColors.error;
        textCol = Colors.white;
        break;
    }

    Widget content = Row(
      mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(textCol),
            ),
          ),
          const SizedBox(width: 10),
        ] else if (widget.icon != null) ...[
          Icon(widget.icon, size: 20, color: textCol),
          const SizedBox(width: 8),
        ],
        Text(
          widget.text,
          style: TextStyle(
            color: textCol,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );

    Widget buttonWidget = GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: border != BorderSide.none ? Border.fromBorderSide(border) : null,
            boxShadow: (widget.variant == AppButtonVariant.primary && !isDisabled)
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.28),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: content,
        ),
      ),
    );

    if (widget.isFullWidth) {
      return SizedBox(width: double.infinity, child: buttonWidget);
    }
    return buttonWidget;
  }
}
