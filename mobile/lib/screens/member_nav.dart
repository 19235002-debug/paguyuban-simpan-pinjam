import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'member/dashboard_screen.dart';
import 'member/simpanan_screen.dart';
import 'member/pinjaman_screen.dart';
import 'member/tagihan_screen.dart';
import 'member/kredit_barang_screen.dart';

class MemberNavigationShell extends StatefulWidget {
  const MemberNavigationShell({super.key});

  @override
  State<MemberNavigationShell> createState() => _MemberNavigationShellState();
}

class _MemberNavigationShellState extends State<MemberNavigationShell> {
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.1 : 1.0,
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
          MemberDashboardScreen(isActive: _currentIndex == 0),
          MemberSimpananScreen(isActive: _currentIndex == 1),
          MemberPinjamanScreen(isActive: _currentIndex == 2),
          MemberTagihanScreen(isActive: _currentIndex == 3),
          MemberKreditBarangScreen(isActive: _currentIndex == 4),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 12, right: 12, bottom: 12, top: 4),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
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
              _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, 'Home'),
              _buildNavItem(1, Icons.account_balance_wallet_outlined, Icons.account_balance_wallet_rounded, 'Simpanan'),
              _buildNavItem(2, Icons.monetization_on_outlined, Icons.monetization_on_rounded, 'Pinjaman'),
              _buildNavItem(3, Icons.credit_card_outlined, Icons.credit_card_rounded, 'Tagihan'),
              _buildNavItem(4, Icons.shopping_bag_outlined, Icons.shopping_bag_rounded, 'Kredit'),
            ],
          ),
        ),
      ),
    );
  }
}
