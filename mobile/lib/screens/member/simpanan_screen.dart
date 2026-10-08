import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../services/api_service.dart';
import '../../shared/widgets/app_badge.dart';
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

class MemberSimpananScreen extends StatefulWidget {
  final bool isActive;
  const MemberSimpananScreen({super.key, this.isActive = false});

  @override
  State<MemberSimpananScreen> createState() => _MemberSimpananScreenState();
}

class _MemberSimpananScreenState extends State<MemberSimpananScreen> {
  final List<dynamic> _savingsList = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = false;
  bool _isFetchingMore = false;
  Timer? _refreshTimer;
  String _selectedYear = 'Semua';

  @override
  void initState() {
    super.initState();
    _fetchSavings();
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
        _fetchSavings(quiet: true);
      }
    });
  }

  @override
  void didUpdateWidget(covariant MemberSimpananScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _fetchSavings(refresh: true);
      _startTimer();
    } else if (!widget.isActive && oldWidget.isActive) {
      _refreshTimer?.cancel();
    }
  }

  Future<void> _fetchSavings({bool refresh = false, bool quiet = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _savingsList.clear();
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
      final response = await ApiService.get(
        '/simpanan?page=$pageToFetch&tahun=$_selectedYear',
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data['data'] as List;
        final lastPage = data['last_page'] ?? 1;

        if (mounted) {
          setState(() {
            if (quiet || pageToFetch == 1) {
              _savingsList.clear();
            }
            _savingsList.addAll(list);
            _hasMore = _currentPage < lastPage;
            _isLoading = false;
            _isFetchingMore = false;
          });
        }
      } else if (!quiet) {
        setState(() {
          _errorMessage = 'Gagal memuat riwayat simpanan.';
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

  void _loadMore() {
    if (_hasMore && !_isFetchingMore) {
      setState(() {
        _isFetchingMore = true;
        _currentPage++;
      });
      _fetchSavings();
    }
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddSavingsBottomSheet(),
    ).then((success) {
      if (success == true) {
        _fetchSavings(refresh: true);
      }
    });
  }

  void _viewReceipt(String? url) {
    if (url == null) return;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Bukti Transfer', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              child: Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Column(
                    children: [
                      Icon(Icons.broken_image, size: 48, color: AppColors.textMutedLight),
                      SizedBox(height: 8),
                      Text('Gagal memuat gambar', style: TextStyle(fontSize: 12, color: AppColors.textMutedLight)),
                    ],
                  ),
                ),
              ),
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
                          'Simpanan Wajib',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Kelola simpanan bulanan Anda',
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Semua', '2026', '2025', '2024', '2023'].map((year) {
                    final isSelected = _selectedYear == year;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(
                          year,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                        checkmarkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: isSelected ? Colors.transparent : (isDark ? AppColors.borderDark : AppColors.borderLight),
                          ),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedYear = year;
                            });
                            _fetchSavings(refresh: true);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _fetchSavings(refresh: true),
                color: AppColors.primary,
                child: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            AppSkeleton(width: double.infinity, height: 80),
                            SizedBox(height: 12),
                            AppSkeleton(width: double.infinity, height: 80),
                          ],
                        ),
                      )
                    : _errorMessage != null
                    ? AppErrorState(
                        description: _errorMessage!,
                        onRetry: () => _fetchSavings(refresh: true),
                      )
                    : _savingsList.isEmpty
                    ? AppEmptyState(
                        title: 'Belum ada riwayat simpanan',
                        description: 'Ajukan simpanan wajib pertama Anda bulan ini.',
                        icon: Icons.account_balance_wallet_rounded,
                        buttonText: 'Setor Sekarang',
                        onButtonPressed: _showAddDialog,
                      )
                    : NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification scrollInfo) {
                          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                            _loadMore();
                          }
                          return true;
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          itemCount: _savingsList.length + (_hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _savingsList.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                  ),
                                ),
                              );
                            }
                            final item = _savingsList[index];
                            return _savingsCard(item);
                          },
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _savingsList.isNotEmpty
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              onPressed: _showAddDialog,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text(
                'Setor Simpanan',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
            )
          : null,
    );
  }

  Widget _savingsCard(dynamic item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String status = item['status'] ?? 'pending';
    final int totalBayar = item['total_bayar'] is num
        ? (item['total_bayar'] as num).toInt()
        : (double.tryParse(item['total_bayar']?.toString() ?? '')?.toInt() ?? 110000);
    final int bulan = item['bulan'] ?? 1;
    final int tahun = item['tahun'] ?? 2026;
    final String? bukti = item['bukti_transfer'];

    final List<String> listBulan = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final String namaBulan = bulan >= 1 && bulan <= 12 ? listBulan[bulan] : '$bulan';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Simpanan Wajib $namaBulan $tahun',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Formatters.formatCurrency(totalBayar),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Bayar: ${Formatters.formatDate(item['tanggal_bayar'])}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppBadge.status(status, fontSize: 10.5),
                if (bukti != null) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => _viewReceipt(bukti),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(40, 20),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Lihat Bukti',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Setor Simpanan bottom sheet controller
class AddSavingsBottomSheet extends StatefulWidget {
  const AddSavingsBottomSheet({super.key});

  @override
  State<AddSavingsBottomSheet> createState() => _AddSavingsBottomSheetState();
}

class _AddSavingsBottomSheetState extends State<AddSavingsBottomSheet> {
  final _dateController = TextEditingController();
  File? _image;
  bool _isSubmitting = false;
  String? _error;

  void _showCopyToast(BuildContext context) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (ctx) => Positioned(
        top: MediaQuery.of(ctx).padding.top + 32,
        left: 24,
        right: 24,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.bgDark,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Nomor rekening berhasil disalin',
                    style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 1), () {
      entry.remove();
    });
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (_) {}
  }

  void _showImageSourceActionSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pilih Sumber Foto',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                title: const Text('Ambil Foto (Kamera)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
                title: const Text('Pilih dari Galeri', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text = picked.toIso8601String().split('T').first;
      });
    }
  }

  Future<void> _submit() async {
    if (_dateController.text.isEmpty) {
      setState(() => _error = 'Harap tentukan tanggal pembayaran.');
      return;
    }
    if (_image == null) {
      setState(() => _error = 'Harap unggah bukti transfer pembayaran.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final fields = {'tanggal_bayar': _dateController.text};
      final files = {'bukti_transfer': _image!};

      final response = await ApiService.multipart('POST', '/simpanan', fields, files);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (mounted) {
          Navigator.pop(context, true);
          CustomSweetAlert.showSuccess(
            context: context,
            message: 'Simpanan wajib berhasil diajukan.',
          );
        }
      } else {
        setState(() {
          _error = data['message'] ?? 'Gagal memproses simpanan.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Koneksi terputus saat mengupload data.';
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: 24 + bottomInset,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Setor Simpanan Wajib',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Total detail box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Nominal Simpanan', style: TextStyle(fontSize: 12.5, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                    Text('Rp 100.000', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Biaya Administrasi', style: TextStyle(fontSize: 12.5, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                    Text('Rp 10.000', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                  ],
                ),
                const Divider(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Bayar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    Text('Rp 110.000', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Info Rekening Transfer
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceSubtleDark : AppColors.surfaceSubtleLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('BANK BNI - 82216567', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text('a.n. Solehudin', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                AppButton(
                  text: 'Salin',
                  variant: AppButtonVariant.secondary,
                  icon: Icons.copy_rounded,
                  isFullWidth: false,
                  height: 38,
                  onPressed: () {
                    Clipboard.setData(const ClipboardData(text: '82216567'));
                    _showCopyToast(context);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (_error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.errorBg,
                border: Border.all(color: AppColors.errorBorder),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 12.5)),
            ),
            const SizedBox(height: 14),
          ],

          const Text('Tanggal Transfer', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          TextField(
            controller: _dateController,
            readOnly: true,
            onTap: _selectDate,
            style: const TextStyle(fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'Pilih Tanggal',
              prefixIcon: Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 20),
            ),
          ),
          const SizedBox(height: 14),

          const Text('Bukti Transfer (Gambar)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          if (_image != null)
            Stack(
              children: [
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                    image: DecorationImage(image: FileImage(_image!), fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.delete_rounded, color: Colors.white, size: 18),
                      onPressed: () => setState(() => _image = null),
                    ),
                  ),
                ),
              ],
            )
          else
            AppButton(
              text: 'Unggah Bukti Transfer',
              variant: AppButtonVariant.outline,
              icon: Icons.add_a_photo_rounded,
              onPressed: _showImageSourceActionSheet,
            ),
          const SizedBox(height: 24),

          AppButton(
            text: 'Unggah Bukti Setoran',
            isLoading: _isSubmitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
