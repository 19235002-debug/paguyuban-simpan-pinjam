import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'app_badge.dart';

class AppTransactionTile extends StatelessWidget {
  final String title;
  final String date;
  final String amount;
  final bool isIncoming;
  final String? status;
  final IconData? icon;
  final VoidCallback? onTap;

  const AppTransactionTile({
    super.key,
    required this.title,
    required this.date,
    required this.amount,
    this.isIncoming = true,
    this.status,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultIcon = icon ?? (isIncoming ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded);
    final iconColor = isIncoming ? AppColors.success : AppColors.secondary;
    final iconBg = iconColor.withValues(alpha: 0.12);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                defaultIcon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncoming ? '+' : '-'} $amount',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isIncoming ? AppColors.success : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    fontFamily: 'Poppins',
                  ),
                ),
                if (status != null) ...[
                  const SizedBox(height: 4),
                  AppBadge.status(status, fontSize: 10),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
