import 'package:flutter/material.dart';

enum AlertType { success, error, warning, info }

class CustomAlert {
  /// Custom Toast Notifications
  static void showToastSuccess({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(milliseconds: 2500),
  }) {
    showToast(context: context, message: message, isSuccess: true, duration: duration);
  }

  static void showToastError({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(milliseconds: 2500),
  }) {
    showToast(context: context, message: message, isSuccess: false, duration: duration);
  }

  static void showToast({
    required BuildContext context,
    required String message,
    required bool isSuccess,
    Duration duration = const Duration(milliseconds: 2500),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        isSuccess: isSuccess,
        onDismiss: () => overlayEntry.remove(),
        duration: duration,
      ),
    );

    overlay.insert(overlayEntry);
  }

  /// SweetAlert v2 Confirmation / Validation Dialog
  static Future<bool> showConfirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Lanjutkan',
    String cancelText = 'Batal',
    AlertType type = AlertType.warning,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _SweetAlertWidget(
          title: title,
          message: message,
          confirmText: confirmText,
          cancelText: cancelText,
          type: type,
        );
      },
    );
    return result ?? false;
  }

  /// Modern modal dialogs
  static void showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onConfirm,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          elevation: 16,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFA7F3D0), width: 3),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle_outline_rounded,
                      color: Color(0xFF10B981),
                      size: 48,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    height: 1.6,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      if (onConfirm != null) onConfirm();
                    },
                    child: const Text(
                      'Selesai',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Poppins'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void showError({
    required BuildContext context,
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          elevation: 16,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFEE2E2), width: 3),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.error_outline_rounded,
                      color: Color(0xFFEF4444),
                      size: 48,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    height: 1.6,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Kembali',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Poppins'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final bool isSuccess;
  final VoidCallback onDismiss;
  final Duration duration;

  const _ToastWidget({
    required this.message,
    required this.isSuccess,
    required this.onDismiss,
    required this.duration,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    Future.delayed(widget.duration - const Duration(milliseconds: 350), () async {
      if (mounted) {
        await _controller.reverse();
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final bgColor = widget.isSuccess ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2);
    final borderColor = widget.isSuccess ? const Color(0xFFA7F3D0) : const Color(0xFFFEE2E2);

    return IgnorePointer(
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x0F000000),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.isSuccess ? Icons.check_circle_rounded : Icons.cancel_rounded,
                          color: themeColor,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            widget.message,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: widget.isSuccess ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SweetAlertWidget extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final AlertType type;

  const _SweetAlertWidget({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color themeColor;
    Color bgColor;
    Color borderColor;

    switch (type) {
      case AlertType.success:
        iconData = Icons.check_circle_outline_rounded;
        themeColor = const Color(0xFF10B981);
        bgColor = const Color(0xFFECFDF5);
        borderColor = const Color(0xFFA7F3D0);
        break;
      case AlertType.error:
        iconData = Icons.error_outline_rounded;
        themeColor = const Color(0xFFEF4444);
        bgColor = const Color(0xFFFEF2F2);
        borderColor = const Color(0xFFFEE2E2);
        break;
      case AlertType.warning:
        iconData = Icons.warning_amber_rounded;
        themeColor = const Color(0xFFF59E0B);
        bgColor = const Color(0xFFFFFBEB);
        borderColor = const Color(0xFFFEF3C7);
        break;
      case AlertType.info:
        iconData = Icons.info_outline_rounded;
        themeColor = const Color(0xFF3B82F6);
        bgColor = const Color(0xFFEFF6FF);
        borderColor = const Color(0xFFBFDBFE);
        break;
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 16,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 3),
              ),
              child: Center(
                child: Icon(
                  iconData,
                  color: themeColor,
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.6,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        foregroundColor: const Color(0xFF64748B),
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        cancelText,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, fontFamily: 'Poppins'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        confirmText,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, fontFamily: 'Poppins'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
