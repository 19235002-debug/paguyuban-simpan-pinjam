import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_error_state.dart';
import '../../shared/widgets/app_skeleton.dart';
import '../../utils/formatters.dart';
import 'approvals_screen.dart';
import '../profile_screen.dart';
import '../login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final bool isActive;
  const AdminDashboardScreen({super.key, this.isActive = false});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _data;
  String? _errorMessage;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchAdminDashboard();
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
        _fetchAdminDashboard(quiet: true);
      }
    });
  }

  @override
  void didUpdateWidget(covariant AdminDashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _fetchAdminDashboard();
      _startTimer();
    } else if (!widget.isActive && oldWidget.isActive) {
      _refreshTimer?.cancel();
    }
  }

  Future<void> _fetchAdminDashboard({bool quiet = false}) async {
    if (!quiet) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final response = await ApiService.get('/dashboard');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _data = decoded;
            _isLoading = false;
          });
        }
      } else if (!quiet) {
        setState(() {
          _errorMessage = 'Gagal memuat dashboard pengurus.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!quiet) {
        setState(() {
          _errorMessage = 'Koneksi gagal. Periksa jaringan Anda.';
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
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 19,
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          child: const Icon(Icons.admin_panel_settings_rounded, size: 22, color: AppColors.primary),
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      offset: const Offset(0, 50),
      color: isDark ? AppColors.surfaceDark : Colors.white,
      elevation: 12,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      onSelected: (value) async {
        if (value == 'profile') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        } else if (value == 'logout') {
          final navigator = Navigator.of(context);
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text('Konfirmasi Logout', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
              content: const Text('Apakah Anda yakin ingin keluar dari akun pengurus ini?', style: TextStyle(fontSize: 13)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
          if (confirm == true && mounted) {
            try {
              await ApiService.post('/logout', {});
            } catch (_) {}
            await StorageService.clear();
            navigator.pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
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
              Text('Profil Saya', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
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
              Text('Logout', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.error)),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                AppSkeleton(width: 180, height: 24),
                SizedBox(height: 8),
                AppSkeleton(width: 140, height: 16),
                SizedBox(height: 24),
                AppSkeleton(width: double.infinity, height: 180, borderRadius: 28),
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
          onRetry: _fetchAdminDashboard,
        ),
      );
    }

    final int saldoSimpanan = _data?['saldoSimpanan'] ?? 0;
    final int pinjamanAktif = _data?['pinjamanAktif'] ?? 0;
    final int kreditAktif = _data?['kreditAktif'] ?? 0;
    final int totalTagihanBelumBayar = _data?['totalTagihanBelumBayar'] ?? 0;
    final int totalPending = _data?['totalPending'] ?? 0;
    final int totalSisaPinjaman = _data?['totalSisaPinjaman'] ?? 0;
    final int totalSisaKredit = _data?['totalSisaKredit'] ?? 0;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchAdminDashboard,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header (Matching Website)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/logo.png',
                          width: 38,
                          height: 38,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PANEL PENGURUS',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Bravo Bekasi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    _buildProfileButton(),
                  ],
                ),
                const SizedBox(height: 20),

                // Hero Kas Koperasi Card (Matching Website dashboard.blade.php for Pengurus)
                Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.heroGradient,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20,
                        top: -20,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOTAL KAS SIMPANAN KOPERASI',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              Formatters.formatCurrency(saldoSimpanan),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const AdminApprovalsScreen()),
                                      ).then((_) => _fetchAdminDashboard());
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF1E293B),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                    child: const Text('Kelola Simpanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      // Action
                                    },
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                                      foregroundColor: Colors.white,
                                      side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                    child: const Text('Data Anggota', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Pending Banner Card
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: totalPending > 0
                        ? const LinearGradient(
                            colors: [Color(0xFFEA580C), Color(0xFFC2410C), Color(0xFF9A3412)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : const LinearGradient(
                            colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: (totalPending > 0 ? const Color(0xFFEA580C) : AppColors.primary).withValues(alpha: 0.25),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              totalPending > 0 ? Icons.notifications_active_rounded : Icons.task_alt_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'TUGAS PERSETUJUAN PENDING',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '$totalPending Pengajuan',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (totalPending > 0)
                        AppButton(
                          text: 'Proses Persetujuan Sekarang',
                          variant: AppButtonVariant.secondary,
                          icon: Icons.arrow_forward_rounded,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AdminApprovalsScreen()),
                            ).then((_) => _fetchAdminDashboard());
                          },
                          height: 48,
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: AppColors.primaryLight, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Semua tugas approval telah selesai',
                                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Operational Statistics Section
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 10),
                  child: Text(
                    'STATISTIK OPERASIONAL',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.85,
                  children: [
                    _adminMetricCard('Total Simpanan', Formatters.formatCurrency(saldoSimpanan), Icons.account_balance_wallet_rounded, AppColors.emeraldBg, AppColors.emeraldText),
                    _adminMetricCard('Piutang Tagihan', Formatters.formatCurrency(totalTagihanBelumBayar), Icons.receipt_long_rounded, AppColors.amberBg, AppColors.amberText),
                    _adminMetricCard('Pinjaman Aktif', '${Formatters.formatCurrency(totalSisaPinjaman)} ($pinjamanAktif)', Icons.monetization_on_rounded, AppColors.cyanBg, AppColors.cyanText),
                    _adminMetricCard('Kredit Aktif', '${Formatters.formatCurrency(totalSisaKredit)} ($kreditAktif)', Icons.shopping_bag_rounded, AppColors.violetBg, AppColors.violetText),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _adminMetricCard(String label, String value, IconData icon, Color bgColor, Color textColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isDark ? textColor.withValues(alpha: 0.15) : bgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: textColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
