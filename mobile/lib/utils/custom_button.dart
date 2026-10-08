import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double borderRadius;
  final bool isFullWidth;
  final bool isOutlined;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.height = 48.0,
    this.borderRadius = 14.0,
    this.isFullWidth = true,
    this.isOutlined = false,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnimation = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.animateTo(0.95, curve: Curves.easeInOut);
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.animateTo(1.0, curve: Curves.easeInOut);
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.animateTo(1.0, curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.onPressed == null 
        ? const Color(0xFFCBD5E1) 
        : (widget.backgroundColor ?? const Color(0xFF0D9488));
        
    final textThemeColor = widget.onPressed == null
        ? const Color(0xFF94A3B8)
        : (widget.textColor ?? (widget.isOutlined ? themeColor : Colors.white));

    final shadowColor = widget.onPressed == null || widget.isOutlined
        ? Colors.transparent
        : themeColor.withAlpha(38);

    Widget buttonContent = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (widget.isLoading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.isOutlined ? themeColor : Colors.white,
              ),
            ),
          )
        else ...[
          if (widget.icon != null) ...[
            Icon(widget.icon, size: 18, color: textThemeColor),
            const SizedBox(width: 8),
          ],
          Text(
            widget.text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textThemeColor,
              fontFamily: 'Poppins',
            ),
          ),
        ]
      ],
    );

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: (widget.onPressed == null || widget.isLoading) ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.isFullWidth ? double.infinity : null,
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: widget.isOutlined ? Colors.transparent : themeColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: widget.isOutlined
                ? Border.all(color: themeColor, width: 2)
                : null,
            boxShadow: widget.onPressed == null || widget.isOutlined
                ? null
                : [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Center(child: buttonContent),
        ),
      ),
    );
  }
}
