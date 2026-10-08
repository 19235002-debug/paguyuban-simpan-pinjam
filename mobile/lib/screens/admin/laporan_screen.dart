import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_error_state.dart';
import '../../shared/widgets/app_skeleton.dart';
import '../../utils/formatters.dart';
import 'laporan_detail_screen.dart';
import '../profile_screen.dart';
import '../login_screen.dart';

class AdminLaporanScreen extends StatefulWidget {
  final bool isActive;
  const AdminLaporanScreen({super.key, this.isActive = false});

  @override
  State<AdminLaporanScreen> createState() => _AdminLaporanScreenState();
}

class _AdminLaporanScreenState extends State<AdminLaporanScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _report;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchLaporan();
    _startTimer();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (widget.isActive && mounted && !_isLoading) {
        _fetchLaporan(quiet: true);
      }
    });
  }

  @override
  void didUpdateWidget(covariant AdminLaporanScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _fetchLaporan();
      _startTimer();
    } else if (!widget.isActive && oldWidget.isActive) {
      _refreshTimer?.cancel();
    }
  }

  Future<void> _fetchLaporan({bool quiet = false}) async {
    if (!quiet) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final response = await ApiService.get('/pengurus/laporan');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _report = decoded;
            _isLoading = false;
          });
        }
      } else if (!quiet) {
        setState(() {
          _errorMessage = 'Gagal memuat laporan keuangan.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!quiet) {
        setState(() {
          _errorMessage = 'Kesalahan jaringan.';
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildProfileButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.primaryGradient,
        ),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          child: const Icon(Icons.admin_panel_settings_rounded, size: 20, color: AppColors.primary),
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      offset: const Offset(0, 45),
      color: isDark ? AppColors.surfaceDark : Colors.white,
      elevation: 8,
      onSelected: (value) async {
        if (value == 'profile') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        } else if (value == 'logout') {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text('Konfirmasi Logout', style: TextStyle(fontWeight: FontWeight.bold)),
              content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Keluar', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
          if (confirm == true && mounted) {
            try {
              await ApiService.post('/logout', {});
            } catch (_) {}
            await StorageService.clear();
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }
          }
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'profile',
          child: Row(
            children: [
              const Icon(Icons.person_outline_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Text('Profil Saya', style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
              SizedBox(width: 12),
              Text('Logout', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.error)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: const [
                AppSkeleton(width: double.infinity, height: 120),
                SizedBox(height: 16),
                AppSkeleton(width: double.infinity, height: 200),
              ],
            ),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: AppErrorState(
          description: _errorMessage!,
          onRetry: _fetchLaporan,
        ),
      );
    }

    final int totalSimpanan = _report?['totalSimpanan'] ?? 0;
    final int totalPinjaman = _report?['totalPinjaman'] ?? 0;
    final int totalKredit = _report?['totalKredit'] ?? 0;
    final int totalPendapatanBunga = _report?['totalPendapatanBunga'] ?? 0;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchLaporan,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Laporan Keuangan',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Rekapitulasi keuangan dan performa koperasi',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildProfileButton(),
                  ],
                ),
                const SizedBox(height: 20),

                // Hero Card Pendapatan Bunga
                AppCard(
                  gradient: AppColors.heroGradient,
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ESTIMASI PENDAPATAN BUNGA (10%)',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        Formatters.formatCurrency(totalPendapatanBunga),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Report Cards
                _reportNavCard('Laporan Simpanan', Formatters.formatCurrency(totalSimpanan), Icons.account_balance_wallet_rounded, AppColors.primary, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminLaporanDetailScreen(type: 'simpanan')));
                }),
                const SizedBox(height: 12),

                _reportNavCard('Laporan Pinjaman Uang', Formatters.formatCurrency(totalPinjaman), Icons.monetization_on_rounded, AppColors.secondary, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminLaporanDetailScreen(type: 'pinjaman')));
                }),
                const SizedBox(height: 12),

                _reportNavCard('Laporan Kredit Barang', Formatters.formatCurrency(totalKredit), Icons.shopping_bag_rounded, AppColors.warning, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminLaporanDetailScreen(type: 'kredit')));
                }),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _reportNavCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMutedLight, size: 20),
        ],
      ),
    );
  }
}
