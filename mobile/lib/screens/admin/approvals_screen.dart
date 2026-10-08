import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

class AdminApprovalsScreen extends StatefulWidget {
  final bool isActive;
  const AdminApprovalsScreen({super.key, this.isActive = false});

  @override
  State<AdminApprovalsScreen> createState() => _AdminApprovalsScreenState();
}

class _AdminApprovalsScreenState extends State<AdminApprovalsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _refreshTimer;

  List<dynamic> _simpananList = [];
  List<dynamic> _pinjamanList = [];
  List<dynamic> _kreditList = [];
  List<dynamic> _pembayaranList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchApprovals();
    _startTimer();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (widget.isActive && mounted && !_isLoading) {
        _fetchApprovals(quiet: true);
      }
    });
  }

  @override
  void didUpdateWidget(covariant AdminApprovalsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _fetchApprovals();
      _startTimer();
    } else if (!widget.isActive && oldWidget.isActive) {
      _refreshTimer?.cancel();
    }
  }

  Future<void> _fetchApprovals({bool quiet = false}) async {
    if (!quiet) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final response = await ApiService.get('/pengurus/approvals');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _simpananList = data['simpanan'] ?? [];
            _pinjamanList = data['pinjaman'] ?? [];
            _kreditList = data['kreditBarang'] ?? [];
            _pembayaranList = data['pembayaran'] ?? [];
            _isLoading = false;
          });
        }
      } else if (!quiet) {
        setState(() {
          _errorMessage = 'Gagal memuat persetujuan.';
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

  Future<File?> _pickTtdAdmin() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Pilih Sumber TTD Pengurus', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
                title: const Text('Galeri Foto', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                title: const Text('Kamera', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return null;

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 80);
      if (picked != null) return File(picked.path);
    } catch (_) {}
    return null;
  }

  Future<void> _processAction(String endpoint, String status, {bool requiresTtd = false}) async {
    File? ttdAdmin;
    if (status == 'approved' && requiresTtd) {
      ttdAdmin = await _pickTtdAdmin();
      if (ttdAdmin == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Persetujuan memerlukan foto TTD Pengurus.')),
          );
        }
        return;
      }
    }

    try {
      dynamic response;
      if (ttdAdmin != null) {
        response = await ApiService.multipart('POST', endpoint, {'status': status}, {'ttd_admin': ttdAdmin});
      } else {
        response = await ApiService.post(endpoint, {'status': status});
      }

      if (response.statusCode == 200) {
        _fetchApprovals();
        if (mounted) {
          CustomSweetAlert.showSuccess(
            context: context,
            message: status == 'approved' ? 'Pengajuan berhasil disetujui.' : 'Pengajuan telah ditolak.',
          );
        }
      } else {
        if (mounted) {
          final data = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Gagal memproses persetujuan.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terjadi kesalahan koneksi.')),
        );
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
                AppSkeleton(width: double.infinity, height: 100),
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
          onRetry: _fetchApprovals,
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Persetujuan Pengurus',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Verifikasi pengajuan simpanan, pinjaman, & cicilan',
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
            ),
            Container(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelColor: AppColors.primary,
                unselectedLabelColor: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                isScrollable: true,
                labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, fontFamily: 'Poppins'),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, fontFamily: 'Poppins'),
                tabs: [
                  Tab(text: 'Simpanan (${_simpananList.length})'),
                  Tab(text: 'Pinjaman (${_pinjamanList.length})'),
                  Tab(text: 'Kredit (${_kreditList.length})'),
                  Tab(text: 'Angsuran (${_pembayaranList.length})'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildListSection(_simpananList, 'simpanan', false),
                  _buildListSection(_pinjamanList, 'pinjaman', true),
                  _buildListSection(_kreditList, 'kredit', true),
                  _buildListSection(_pembayaranList, 'pembayaran', false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListSection(List<dynamic> list, String category, bool requiresTtd) {
    if (list.isEmpty) {
      return const AppEmptyState(
        title: 'Tidak ada pengajuan pending',
        description: 'Semua pengajuan pada kategori ini telah diproses.',
        icon: Icons.task_alt_rounded,
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchApprovals,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final item = list[index];
          return _approvalItemCard(item, category, requiresTtd);
        },
      ),
    );
  }

  Widget _approvalItemCard(dynamic item, String category, bool requiresTtd) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final int id = item['id'];
    final dynamic user = item['user'];
    final String userName = user != null ? (user['name'] ?? 'Anggota') : 'Anggota';

    String title = '';
    String detail = '';

    if (category == 'simpanan') {
      title = 'Setoran Simpanan Wajib';
      detail = Formatters.formatCurrency(item['total_bayar']);
    } else if (category == 'pinjaman') {
      title = 'Pengajuan Pinjaman Uang';
      detail = '${Formatters.formatCurrency(item['nominal'])} (${item['tenor_bulan']} Bulan)';
    } else if (category == 'kredit') {
      title = 'Kredit Barang: ${item['nama_barang']}';
      detail = '${Formatters.formatCurrency(item['harga_barang'])} (${item['tenor_bulan']} Bulan)';
    } else if (category == 'pembayaran') {
      title = 'Pembayaran Angsuran ke-${item['angsuran_ke']}';
      detail = Formatters.formatCurrency(item['nominal']);
    }

    String endpoint = '';
    if (category == 'simpanan') endpoint = '/pengurus/simpanan/$id/approval';
    if (category == 'pinjaman') endpoint = '/pengurus/pinjaman/$id/approval';
    if (category == 'kredit') endpoint = '/pengurus/kredit-barang/$id/approval';
    if (category == 'pembayaran') endpoint = '/pengurus/pembayaran/$id/approval';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: AppCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                      const SizedBox(height: 2),
                      Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.primary)),
                    ],
                  ),
                ),
                Text(detail, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Tolak',
                    variant: AppButtonVariant.danger,
                    height: 40,
                    onPressed: () => _processAction(endpoint, 'rejected', requiresTtd: false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    text: 'Setujui',
                    variant: AppButtonVariant.primary,
                    height: 40,
                    onPressed: () => _processAction(endpoint, 'approved', requiresTtd: requiresTtd),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
