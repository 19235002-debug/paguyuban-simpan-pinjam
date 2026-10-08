import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppBadge extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const AppBadge({
    super.key,
    required this.text,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  });

  factory AppBadge.status(String? status, {double fontSize = 11}) {
    final cleanStatus = (status ?? '').toLowerCase().trim();

    Color bg;
    Color text;
    Color border;
    IconData icon;

    if (cleanStatus.contains('setuju') ||
        cleanStatus.contains('disetujui') ||
        cleanStatus.contains('lunas') ||
        cleanStatus.contains('aktif') ||
        cleanStatus.contains('approved') ||
        cleanStatus.contains('selesai') ||
        cleanStatus.contains('diterima') ||
        cleanStatus.contains('berhasil')) {
      bg = AppColors.successBg;
      text = AppColors.success;
      border = AppColors.successBorder;
      icon = Icons.check_circle_rounded;
    } else if (cleanStatus.contains('tunggu') ||
        cleanStatus.contains('menunggu') ||
        cleanStatus.contains('pending') ||
        cleanStatus.contains('proses') ||
        cleanStatus.contains('diproses')) {
      bg = AppColors.warningBg;
      text = AppColors.warning;
      border = AppColors.warningBorder;
      icon = Icons.hourglass_top_rounded;
    } else if (cleanStatus.contains('tolak') ||
        cleanStatus.contains('ditolak') ||
        cleanStatus.contains('gagal') ||
        cleanStatus.contains('batal') ||
        cleanStatus.contains('dibatalkan') ||
        cleanStatus.contains('nonaktif') ||
        cleanStatus.contains('non-aktif') ||
        cleanStatus.contains('belum dibayar') ||
        cleanStatus.contains('menunggak')) {
      bg = AppColors.errorBg;
      text = AppColors.error;
      border = AppColors.errorBorder;
      icon = Icons.cancel_rounded;
    } else {
      bg = AppColors.infoBg;
      text = AppColors.info;
      border = AppColors.infoBorder;
      icon = Icons.info_rounded;
    }

    return AppBadge(
      text: status ?? 'N/A',
      icon: icon,
      backgroundColor: bg,
      textColor: text,
      borderColor: border,
      fontSize: fontSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.infoBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor ?? (textColor ?? AppColors.info).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: fontSize + 3,
              color: textColor ?? AppColors.info,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: textColor ?? AppColors.info,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
