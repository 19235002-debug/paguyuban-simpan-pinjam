import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'admin/dashboard_screen.dart';
import 'admin/anggota_screen.dart';
import 'admin/approvals_screen.dart';
import 'admin/laporan_screen.dart';
import 'admin/shu_screen.dart';

class AdminNavigationShell extends StatefulWidget {
  const AdminNavigationShell({super.key});

  @override
  State<AdminNavigationShell> createState() => _AdminNavigationShellState();
}

class _AdminNavigationShellState extends State<AdminNavigationShell> {
  int _currentIndex = 0;

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final activeColor = isDark ? AppColors.primaryLight : AppColors.primary;
    final inactiveColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.12 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? activeColor : inactiveColor,
                size: 20,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: activeColor,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Poppins',
                  letterSpacing: -0.2,
                ),
                child: Text(label),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          AdminDashboardScreen(isActive: _currentIndex == 0),
          AdminAnggotaScreen(isActive: _currentIndex == 1),
          AdminApprovalsScreen(isActive: _currentIndex == 2),
          AdminLaporanScreen(isActive: _currentIndex == 3),
          AdminShuScreen(isActive: _currentIndex == 4),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 12, right: 12, bottom: 16, top: 4),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.35)
                    : const Color(0xFF0F172A).withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.grid_view_outlined, Icons.grid_view_rounded, 'Dashboard'),
              _buildNavItem(1, Icons.people_outline_rounded, Icons.people_rounded, 'Anggota'),
              _buildNavItem(2, Icons.fact_check_outlined, Icons.fact_check_rounded, 'Approval'),
              _buildNavItem(3, Icons.analytics_outlined, Icons.analytics_rounded, 'Laporan'),
              _buildNavItem(4, Icons.percent_outlined, Icons.percent_rounded, 'SHU'),
            ],
          ),
        ),
      ),
    );
  }
}
