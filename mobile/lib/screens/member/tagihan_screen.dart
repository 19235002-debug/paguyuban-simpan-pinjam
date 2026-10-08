import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/api_service.dart';
import '../../shared/widgets/app_badge.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_empty_state.dart';
import '../../shared/widgets/app_error_state.dart';
import '../../shared/widgets/app_skeleton.dart';
import '../../utils/formatters.dart';
import 'pay_installment_bottom_sheet.dart';
import '../profile_screen.dart';
import '../login_screen.dart';
import '../../services/storage_service.dart';

class MemberTagihanScreen extends StatefulWidget {
  final bool isActive;
  const MemberTagihanScreen({super.key, this.isActive = false});

  @override
  State<MemberTagihanScreen> createState() => _MemberTagihanScreenState();
}

class _MemberTagihanScreenState extends State<MemberTagihanScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _refreshTimer;

  // Metrics
  int _belumBayar = 0;
  int _pending = 0;
  int _totalTagihan = 0;
  int _persentaseLunas = 0;
  List<dynamic> _groupedPembayaran = [];

  @override
  void initState() {
    super.initState();
    _fetchTagihan();
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
        _fetchTagihan(quiet: true);
      }
    });
  }

  @override
  void didUpdateWidget(covariant MemberTagihanScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _fetchTagihan();
      _startTimer();
    } else if (!widget.isActive && oldWidget.isActive) {
      _refreshTimer?.cancel();
    }
  }

  Future<void> _fetchTagihan({bool quiet = false}) async {
    if (!quiet) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final response = await ApiService.get('/pembayaran');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _belumBayar = data['belumBayar'] ?? 0;
            _pending = data['pending'] ?? 0;
            _totalTagihan = data['totalTagihan'] ?? 0;
            _persentaseLunas = data['persentaseLunas'] ?? 0;
            _groupedPembayaran = data['groupedPembayaran'] ?? [];
            _isLoading = false;
          });
        }
      } else if (!quiet) {
        setState(() {
          _errorMessage = 'Gagal memuat data tagihan.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!quiet) {
        setState(() {
          _errorMessage = 'Gagal menghubungkan ke server.';
          _isLoading = false;
        });
      }
    }
  }

  void _payInstallment(dynamic item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PayInstallmentBottomSheet(item: item),
    ).then((success) {
      if (success == true && mounted) {
        _fetchTagihan();
      }
    });
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
          child: const Icon(Icons.person_rounded, size: 20, color: AppColors.primary),
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
          onRetry: _fetchTagihan,
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchTagihan,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tagihan & Angsuran',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Jadwal dan status pelunasan cicilan',
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

                // Hero Tagihan Summary Card
                AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Sisa Tagihan Belum Dibayar', style: TextStyle(fontSize: 12.5, color: AppColors.textMutedLight, fontWeight: FontWeight.w600)),
                          AppBadge(
                            text: 'Progress $_persentaseLunas%',
                            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                            textColor: AppColors.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          Formatters.formatCurrency(_totalTagihan),
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5, color: AppColors.error),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _persentaseLunas / 100.0,
                          minHeight: 8,
                          backgroundColor: isDark ? AppColors.surfaceSubtleDark : AppColors.surfaceSubtleLight,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Belum Dibayar: $_belumBayar', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.error)),
                          Text('Menunggu Verifikasi: $_pending', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.warning)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Grouped Installments List
                Text(
                  'Daftar Angsuran Aktif',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                ),
                const SizedBox(height: 12),

                if (_groupedPembayaran.isEmpty)
                  const AppEmptyState(
                    title: 'Tidak Ada Tagihan Aktif',
                    description: 'Semua kewajiban angsuran Anda telah lunas.',
                    icon: Icons.task_alt_rounded,
                  )
                else
                  ..._groupedPembayaran.map((group) => _buildGroupCard(group)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupCard(dynamic group) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String type = group['type'] ?? 'pinjaman';
    final dynamic parent = group['parent'];
    final List<dynamic> items = group['items'] ?? [];

    String title = type == 'pinjaman' ? 'Pinjaman Uang' : 'Kredit Barang';
    String detail = '';
    if (type == 'pinjaman') {
      final int nominal = parent['nominal'] is num ? (parent['nominal'] as num).toInt() : 0;
      detail = Formatters.formatCurrency(nominal);
    } else {
      final String nama = parent['nama_barang'] ?? 'Barang';
      final int harga = parent['harga_barang'] is num ? (parent['harga_barang'] as num).toInt() : 0;
      detail = '$nama (${Formatters.formatCurrency(harga)})';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (type == 'pinjaman' ? AppColors.secondary : AppColors.warning).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    type == 'pinjaman' ? Icons.monetization_on_rounded : Icons.shopping_bag_rounded,
                    color: type == 'pinjaman' ? AppColors.secondary : AppColors.warning,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                      const SizedBox(height: 2),
                      Text(detail, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            ...items.map((item) => _buildPaymentRow(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentRow(dynamic p) {
    final int ke = p['angsuran_ke'] ?? 1;
    final int nominalBayar = (p['nominal'] is int) ? p['nominal'] : (double.tryParse(p['nominal']?.toString() ?? '0') ?? 0).toInt();
    final String statusBayar = p['status'] ?? 'belum_bayar';
    String tgl = (statusBayar == 'approved' && p['tanggal_bayar'] != null) ? p['tanggal_bayar'].toString() : (p['jatuh_tempo'] ?? '-');
    if (tgl.contains('T')) tgl = tgl.split('T')[0];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text('Bulan ke-$ke ($tgl)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          Row(
            children: [
              Text(Formatters.formatCurrency(nominalBayar), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
              const SizedBox(width: 8),
              AppBadge.status(statusBayar, fontSize: 9.5),
              if (statusBayar == 'belum_bayar' || statusBayar == 'rejected') ...[
                const SizedBox(width: 6),
                AppButton(
                  text: 'Bayar',
                  height: 30,
                  isFullWidth: false,
                  onPressed: () => _payInstallment(p),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
