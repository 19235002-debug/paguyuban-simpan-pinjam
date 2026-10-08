import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/api_service.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_empty_state.dart';
import '../../shared/widgets/app_error_state.dart';
import '../../shared/widgets/app_skeleton.dart';
import '../../utils/formatters.dart';
import '../../utils/custom_sweet_alert.dart';
import '../profile_screen.dart';
import '../login_screen.dart';
import '../../services/storage_service.dart';

class AdminShuScreen extends StatefulWidget {
  final bool isActive;
  const AdminShuScreen({super.key, this.isActive = false});

  @override
  State<AdminShuScreen> createState() => _AdminShuScreenState();
}

class _AdminShuScreenState extends State<AdminShuScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  int _saldoKas = 0;
  final List<dynamic> _shuList = [];
  int _currentPage = 1;
  bool _isFetchingMore = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchShu();
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
      if (widget.isActive && mounted && !_isLoading && !_isFetchingMore) {
        _fetchShu(quiet: true);
      }
    });
  }

  @override
  void didUpdateWidget(covariant AdminShuScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _fetchShu(refresh: true);
      _startTimer();
    } else if (!widget.isActive && oldWidget.isActive) {
      _refreshTimer?.cancel();
    }
  }

  Future<void> _fetchShu({bool refresh = false, bool quiet = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _shuList.clear();
        _isLoading = true;
        _errorMessage = null;
      });
    } else if (!quiet && _isLoading) {
      setState(() {
        _errorMessage = null;
      });
    }

    try {
      final pageToFetch = quiet ? 1 : _currentPage;
      final response = await ApiService.get('/pengurus/shu?page=$pageToFetch');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data['shus']['data'] as List;

        if (mounted) {
          setState(() {
            if (quiet || pageToFetch == 1) {
              _shuList.clear();
            }
            _saldoKas = data['saldoKas'] ?? 0;
            _shuList.addAll(list);
            _isLoading = false;
            _isFetchingMore = false;
          });
        }
      } else if (!quiet) {
        setState(() {
          _errorMessage = 'Gagal memuat kelola SHU.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!quiet) {
        setState(() {
          _errorMessage = 'Gagal terhubung ke server.';
          _isLoading = false;
        });
      }
    }
  }

  void _showDistributeShuDialog() {
    final yearController = TextEditingController(text: DateTime.now().year.toString());
    final amountController = TextEditingController();
    bool isProcessing = false;
    String? dialogError;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Bagikan SHU Anggota', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Alokasikan Sisa Hasil Usaha (SHU) secara proporsional kepada seluruh anggota aktif:',
                style: TextStyle(fontSize: 12.5, color: AppColors.textSecondaryLight),
              ),
              const SizedBox(height: 14),
              if (dialogError != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(color: AppColors.errorBg, borderRadius: BorderRadius.circular(12)),
                  child: Text(dialogError!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
                ),
              ],
              TextField(
                controller: yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Tahun Pembagian'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [RupiahInputFormatter()],
                decoration: const InputDecoration(labelText: 'Total Dana SHU', prefixText: 'Rp '),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: isProcessing
                  ? null
                  : () async {
                      final tahunText = yearController.text.trim();
                      final amountText = amountController.text.replaceAll(RegExp(r'\D'), '');

                      if (tahunText.isEmpty || amountText.isEmpty) {
                        setDialogState(() => dialogError = 'Semua field wajib diisi.');
                        return;
                      }

                      final int totalShu = int.parse(amountText);
                      if (totalShu <= 0) {
                        setDialogState(() => dialogError = 'Total SHU harus lebih dari Rp 0.');
                        return;
                      }

                      setDialogState(() {
                        isProcessing = true;
                        dialogError = null;
                      });

                      try {
                        final response = await ApiService.post('/pengurus/shu/distribusi', {
                          'tahun': int.parse(tahunText),
                          'total_shu': totalShu,
                        });

                        final data = jsonDecode(response.body);

                        if (response.statusCode == 200) {
                          if (context.mounted) {
                            Navigator.pop(ctx);
                            _fetchShu(refresh: true);
                            CustomSweetAlert.showSuccess(
                              context: context,
                              message: 'SHU berhasil dibagikan.',
                            );
                          }
                        } else {
                          setDialogState(() {
                            dialogError = data['message'] ?? 'Gagal membagikan SHU.';
                            isProcessing = false;
                          });
                        }
                      } catch (e) {
                        setDialogState(() {
                          dialogError = 'Kesalahan jaringan.';
                          isProcessing = false;
                        });
                      }
                    },
              child: isProcessing
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                  : const Text('Bagikan SHU'),
            ),
          ],
        ),
      ),
    );
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
          onRetry: () => _fetchShu(refresh: true),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _fetchShu(refresh: true),
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
                            'Sisa Hasil Usaha (SHU)',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Manajemen alokasi SHU anggota',
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

                // Hero Saldo Kas Card
                AppCard(
                  gradient: AppColors.heroGradient,
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ESTIMASI SALDO KAS KOPERASI',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        Formatters.formatCurrency(_saldoKas),
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
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Riwayat Pembagian SHU',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    ),
                    AppButton(
                      text: 'Bagikan SHU',
                      icon: Icons.percent_rounded,
                      isFullWidth: false,
                      height: 38,
                      onPressed: _showDistributeShuDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (_shuList.isEmpty)
                  const AppEmptyState(
                    title: 'Belum Ada Pembagian SHU',
                    description: 'Tekan tombol Bagikan SHU di atas untuk mengalokasikan SHU tahunan.',
                    icon: Icons.percent_rounded,
                  )
                else
                  ..._shuList.map((shu) => _shuCard(shu)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _shuCard(dynamic shu) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final int tahun = shu['tahun'] ?? 2026;
    final int nominal = (shu['nominal'] is num) ? (shu['nominal'] as num).toInt() : 0;
    final dynamic user = shu['user'];
    final String name = user != null ? (user['name'] ?? 'Anggota') : 'Anggota';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: const Icon(Icons.percent_rounded, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                  const SizedBox(height: 2),
                  Text('SHU Tahun $tahun', style: TextStyle(fontSize: 11.5, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Text(Formatters.formatCurrency(nominal), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}
