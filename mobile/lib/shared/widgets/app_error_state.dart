import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'app_button.dart';

class AppErrorState extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onRetry;

  const AppErrorState({
    super.key,
    this.title = 'Data Belum Dapat Dimuat',
    this.description = 'Terjadi kendala saat menghubungkan ke server. Silakan periksa koneksi internet Anda.',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.errorBg,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.errorBorder, width: 2),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                height: 1.5,
                fontFamily: 'Poppins',
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              AppButton(
                text: 'Coba Lagi',
                icon: Icons.refresh_rounded,
                onPressed: onRetry,
                isFullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
