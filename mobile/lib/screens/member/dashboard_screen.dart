import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../shared/widgets/app_badge.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_error_state.dart';
import '../../shared/widgets/app_skeleton.dart';
import '../../utils/formatters.dart';
import '../profile_screen.dart';
import '../login_screen.dart';

class MemberDashboardScreen extends StatefulWidget {
  final bool isActive;
  const MemberDashboardScreen({super.key, this.isActive = false});

  @override
  State<MemberDashboardScreen> createState() => _MemberDashboardScreenState();
}

class _MemberDashboardScreenState extends State<MemberDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _data;
  String? _errorMessage;
  Timer? _refreshTimer;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
    _fetchDashboardData();
    _startTimer();
  }

  Future<void> _loadUser() async {
    final user = await StorageService.getUser();
    if (user != null && mounted) {
      setState(() {
        _userName = user['name'] ?? '';
      });
    }
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
        _fetchDashboardData(quiet: true);
      }
    });
  }

  @override
  void didUpdateWidget(covariant MemberDashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _fetchDashboardData();
      _startTimer();
    } else if (!widget.isActive && oldWidget.isActive) {
      _refreshTimer?.cancel();
    }
  }

  Future<void> _fetchDashboardData({bool quiet = false}) async {
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
          _errorMessage = 'Gagal memuat data dari server.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!quiet) {
        setState(() {
          _errorMessage = 'Koneksi terputus. Pastikan internet Anda aktif.';
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
          child: const Icon(Icons.person_rounded, size: 22, color: AppColors.primary),
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
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text('Konfirmasi Logout', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
              content: const Text('Apakah Anda yakin ingin keluar dari akun ini?', style: TextStyle(fontSize: 13)),
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
                SizedBox(height: 24),
                AppSkeleton(width: double.infinity, height: 90, borderRadius: 24),
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
          onRetry: _fetchDashboardData,
        ),
      );
    }

    final int saldoSimpanan = _data?['saldoSimpanan'] ?? 0;
    final int pinjamanAktif = _data?['pinjamanAktif'] ?? 0;
    final int kreditAktif = _data?['kreditAktif'] ?? 0;
    final int tagihanBulanIni = _data?['tagihanBulanIni'] ?? 0;
    final Map<String, dynamic>? pinjamanTerakhir = _data?['pinjamanTerakhir'];
    final Map<String, dynamic>? kreditTerakhir = _data?['kreditTerakhir'];

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchDashboardData,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header (Matching Website dashboard.blade.php)
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
                              'SELAMAT DATANG',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _userName.isNotEmpty ? _userName : 'Anggota',
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

                // COMPACT HERO CARD (Matching Website dashboard.blade.php)
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
                      Positioned(
                        left: -20,
                        bottom: -20,
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
                              'TOTAL SIMPANAN SAYA',
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
                                      _showGuideBottomSheet(
                                        context,
                                        'Panduan Setor Simpanan',
                                        [
                                          'Buka menu "Simpanan" di tombol bawah aplikasi.',
                                          'Tekan tombol bertuliskan "Setor Simpanan" di bagian bawah.',
                                          'Lakukan transfer uang sebesar nominal simpanan ke rekening Koperasi.',
                                          'Pilih "Tanggal Transfer" dan masukkan foto struk bukti transfer Anda.',
                                          'Tekan tombol "Unggah Bukti Setoran" dan tunggu persetujuan pengurus.',
                                        ],
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF1E293B),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                    child: const Text('Bayar Simpanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      _showGuideBottomSheet(
                                        context,
                                        'Riwayat Simpanan',
                                        [
                                          'Buka menu "Simpanan" di navigasi bawah.',
                                          'Lihat daftar transaksi simpanan Anda.',
                                        ],
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                                      foregroundColor: Colors.white,
                                      side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                    child: const Text('Riwayat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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

                // BANKING STYLE QUICK ACTIONS MENU (Matching Website)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'LAYANAN CEPAT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFF1F5F9)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _quickActionTile(
                            'Pinjaman',
                            Icons.payments_rounded,
                            AppColors.cyanBg,
                            AppColors.cyanText,
                            () => _showGuideBottomSheet(context, 'Panduan Pinjaman', ['Buka menu "Pinjaman" di navigasi bawah.', 'Masukkan nominal & tenor.', 'Kirim pengajuan.']),
                          ),
                          _quickActionTile(
                            'Kredit',
                            Icons.shopping_cart_rounded,
                            AppColors.violetBg,
                            AppColors.violetText,
                            () => _showGuideBottomSheet(context, 'Panduan Kredit Barang', ['Buka menu "Kredit" di navigasi bawah.', 'Pilih barang & cicilan.', 'Ajukan kredit barang.']),
                          ),
                          _quickActionTile(
                            'Tagihan',
                            Icons.credit_card_rounded,
                            AppColors.emeraldBg,
                            AppColors.emeraldText,
                            () => _showGuideBottomSheet(context, 'Panduan Tagihan', ['Buka menu "Tagihan" di navigasi bawah.', 'Pilih tagihan & transfer.', 'Upload bukti bayar.']),
                          ),
                          _quickActionTile(
                            'Simpanan',
                            Icons.account_balance_wallet_rounded,
                            AppColors.orangeBg,
                            AppColors.orangeText,
                            () => _showGuideBottomSheet(context, 'Panduan Simpanan', ['Buka menu "Simpanan" di navigasi bawah.', 'Tekan Setor Simpanan.', 'Upload bukti transfer.']),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // STATUS KEUANGAN (Matching Website dashboard.blade.php)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'STATUS KEUANGAN',
                        style: TextStyle(
                          fontSize: 11,
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
                      childAspectRatio: 2.1,
                      children: [
                        _webStatTile('Tagihan Bulan Ini', Formatters.formatCurrency(tagihanBulanIni), Icons.calendar_month_rounded, AppColors.amberBg, AppColors.amberText),
                        _webStatTile('Saldo Simpanan', Formatters.formatCurrency(saldoSimpanan), Icons.account_balance_wallet_rounded, AppColors.emeraldBg, AppColors.emeraldText),
                        _webStatTile('Pinjaman Aktif', '$pinjamanAktif Kontrak', Icons.payments_rounded, AppColors.cyanBg, AppColors.cyanText),
                        _webStatTile('Kredit Barang', '$kreditAktif Kontrak', Icons.shopping_bag_rounded, AppColors.violetBg, AppColors.violetText),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Recent Activity
                Text(
                  'Aktivitas Terakhir',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),

                if (pinjamanTerakhir == null && kreditTerakhir == null)
                  const AppCard(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'Belum ada aktivitas pinjaman atau kredit.',
                        style: TextStyle(fontSize: 12.5, color: AppColors.textMutedLight, fontWeight: FontWeight.w500),
                      ),
                    ),
                  )
                else ...[
                  if (pinjamanTerakhir != null) ...[
                    _recentActivityCard(
                      'Pinjaman Uang',
                      Formatters.formatCurrency(pinjamanTerakhir['nominal'] ?? 0),
                      Formatters.formatDate(pinjamanTerakhir['created_at']),
                      pinjamanTerakhir['status'] ?? 'pending',
                      Icons.monetization_on_rounded,
                      AppColors.secondary,
                    ),
                  ],
                  if (kreditTerakhir != null) ...[
                    _recentActivityCard(
                      'Kredit Barang: ${kreditTerakhir['nama_barang']}',
                      Formatters.formatCurrency(kreditTerakhir['harga_barang'] ?? 0),
                      Formatters.formatDate(kreditTerakhir['created_at']),
                      kreditTerakhir['status'] ?? 'pending',
                      Icons.shopping_bag_rounded,
                      AppColors.warning,
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }



  void _showGuideBottomSheet(BuildContext context, String title, List<String> steps) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => Container(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...steps.asMap().entries.map((entry) {
              int idx = entry.key + 1;
              String step = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 14.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                      child: Text(
                        '$idx',
                        style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        step,
                        style: const TextStyle(fontSize: 13, height: 1.4, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Saya Mengerti'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recentActivityCard(
    String title,
    String subtitle,
    String dateStr,
    String status,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateStr,
                    style: const TextStyle(fontSize: 11, color: AppColors.textMutedLight, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            AppBadge.status(status, fontSize: 10.5),
          ],
        ),
      ),
    );
  }

  Widget _quickActionTile(
    String label,
    IconData icon,
    Color bgColor,
    Color textColor,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? textColor.withValues(alpha: 0.15) : bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: textColor, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _webStatTile(
    String label,
    String value,
    IconData icon,
    Color bgColor,
    Color textColor,
  ) {
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
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark ? textColor.withValues(alpha: 0.15) : bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: textColor, size: 18),
          ),
          const SizedBox(width: 10),
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
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
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
