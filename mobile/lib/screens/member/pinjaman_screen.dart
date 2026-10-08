import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
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
import '../../utils/custom_alert.dart';
import '../../utils/custom_sweet_alert.dart';
import 'pay_installment_bottom_sheet.dart';
import '../profile_screen.dart';
import '../login_screen.dart';
import '../../services/storage_service.dart';

class MemberPinjamanScreen extends StatefulWidget {
  final bool isActive;
  const MemberPinjamanScreen({super.key, this.isActive = false});

  @override
  State<MemberPinjamanScreen> createState() => _MemberPinjamanScreenState();
}

class _MemberPinjamanScreenState extends State<MemberPinjamanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _refreshTimer;

  // Status variables
  List<dynamic> _loansList = [];
  int _totalPinjamanAktif = 0;
  int _totalSisaPinjaman = 0;
  bool _bolehAjukan = false;
  String _selectedYear = 'Semua';

  // Form / Simulation variables
  final _nominalController = TextEditingController();
  int _selectedTenor = 1;
  bool _isSimulating = false;
  bool _isSubmitting = false;
  Map<String, dynamic>? _simulasiHasil;
  String? _formError;
  File? _ttdFile;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1 && !_bolehAjukan) {
        _tabController.index = 0;
        CustomAlert.showError(
          context: context,
          title: 'Tidak Bisa Mengajukan',
          message:
              'Anda masih memiliki pinjaman atau kredit barang aktif yang sedang berjalan. Harap selesaikan kewajiban Anda terlebih dahulu.',
        );
      }
    });
    _nominalController.addListener(() {
      if (_simulasiHasil != null) {
        setState(() => _simulasiHasil = null);
      }
    });
    _fetchLoans();
    _startTimer();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _tabController.dispose();
    _nominalController.dispose();
    super.dispose();
  }

  Future<void> _pickSignature(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
      if (pickedFile != null) {
        setState(() {
          _ttdFile = File(pickedFile.path);
        });
      }
    } catch (_) {}
  }

  void _showSignatureSourceSheet() {
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
                'Pilih Sumber Foto TTD',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
                title: const Text('Galeri Foto', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickSignature(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                title: const Text('Kamera', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickSignature(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (widget.isActive && mounted && !_isLoading && !_isSubmitting) {
        _fetchLoans(quiet: true);
      }
    });
  }

  @override
  void didUpdateWidget(covariant MemberPinjamanScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _fetchLoans();
      _startTimer();
    } else if (!widget.isActive && oldWidget.isActive) {
      _refreshTimer?.cancel();
    }
  }

  Future<void> _fetchLoans({bool quiet = false}) async {
    if (!quiet) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final response = await ApiService.get('/pinjaman?tahun=$_selectedYear');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _loansList = data['pinjaman']['data'] ?? [];
            _totalPinjamanAktif = data['totalPinjamanAktif'] ?? 0;
            _totalSisaPinjaman = data['totalSisaPinjaman'] ?? 0;
            _bolehAjukan = data['bolehAjukan'] ?? false;
            _isLoading = false;
          });
        }
      } else if (!quiet) {
        setState(() {
          _errorMessage = 'Gagal mengambil data pinjaman.';
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

  void _payInstallment(dynamic item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PayInstallmentBottomSheet(item: item),
    ).then((success) {
      if (success == true && mounted) {
        _fetchLoans();
        CustomSweetAlert.showSuccess(
          context: context,
          message: 'Pembayaran berhasil dikirim.',
        );
      }
    });
  }

  Future<void> _runSimulation() async {
    final amountText = _nominalController.text.replaceAll(RegExp(r'\D'), '');
    if (amountText.isEmpty) {
      setState(() => _formError = 'Harap isi nominal pinjaman.');
      return;
    }
    final int nominal = int.parse(amountText);
    if (nominal < 100000) {
      setState(() => _formError = 'Minimal pengajuan pinjaman adalah Rp 100.000.');
      return;
    }

    setState(() {
      _isSimulating = true;
      _formError = null;
      _simulasiHasil = null;
    });

    try {
      final response = await ApiService.post('/pinjaman/simulasi', {
        'nominal': nominal,
        'tenor_bulan': _selectedTenor,
      });

      if (response.statusCode == 200) {
        setState(() {
          _simulasiHasil = jsonDecode(response.body);
        });
      } else {
        setState(() => _formError = 'Gagal memproses simulasi.');
      }
    } catch (e) {
      setState(() => _formError = 'Terjadi kesalahan jaringan.');
    } finally {
      setState(() => _isSimulating = false);
    }
  }

  Future<void> _submitLoan() async {
    final amountText = _nominalController.text.replaceAll(RegExp(r'\D'), '');
    if (amountText.isEmpty) {
      setState(() => _formError = 'Harap isi nominal pinjaman.');
      return;
    }
    final int nominal = int.parse(amountText);
    if (nominal < 100000) {
      setState(() => _formError = 'Minimal pengajuan pinjaman adalah Rp 100.000.');
      return;
    }

    if (_ttdFile == null) {
      setState(() => _formError = 'Harap upload foto tanda tangan Anggota.');
      return;
    }

    final confirm = await CustomAlert.showConfirm(
      context: context,
      title: 'Ajukan Pinjaman?',
      message:
          'Apakah Anda yakin ingin mengajukan pinjaman sebesar Rp ${Formatters.formatCurrency(nominal).replaceAll('Rp ', '')} dengan tenor $_selectedTenor Bulan?',
      confirmText: 'Ya, Ajukan',
      cancelText: 'Batal',
      type: AlertType.warning,
    );

    if (!confirm) return;

    setState(() {
      _isSubmitting = true;
      _formError = null;
    });

    try {
      final response = await ApiService.multipart(
        'POST',
        '/pinjaman',
        {
          'nominal': nominal.toString(),
          'tenor_bulan': _selectedTenor.toString(),
        },
        {
          'ttd_anggota': _ttdFile!,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _nominalController.clear();
        setState(() {
          _simulasiHasil = null;
          _ttdFile = null;
        });
        _tabController.animateTo(0);
        _fetchLoans();
        if (mounted) {
          CustomSweetAlert.showSuccess(
            context: context,
            message: 'Pinjaman berhasil diajukan.',
          );
        }
      } else {
        setState(() => _formError = data['message'] ?? 'Gagal mengajukan pinjaman.');
      }
    } catch (e) {
      setState(() => _formError = 'Jaringan terputus.');
    } finally {
      setState(() => _isSubmitting = false);
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
          final navigator = Navigator.of(context);
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
          onRetry: _fetchLoans,
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
                          'Pinjaman Uang',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Ajukan pinjaman dana koperasi',
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
                labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, fontFamily: 'Poppins'),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, fontFamily: 'Poppins'),
                tabs: const [
                  Tab(text: 'Riwayat Pinjaman'),
                  Tab(text: 'Simulasi & Ajukan'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // TAB 1: RIWAYAT & SUMMARY
                  RefreshIndicator(
                    onRefresh: _fetchLoans,
                    color: AppColors.primary,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _debtSummaryCard(),
                          const SizedBox(height: 24),

                          Text(
                            'Daftar Pengajuan Pinjaman',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SingleChildScrollView(
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
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(color: isSelected ? Colors.transparent : (isDark ? AppColors.borderDark : AppColors.borderLight)),
                                    ),
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() {
                                          _selectedYear = year;
                                        });
                                        _fetchLoans();
                                      }
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 14),

                          if (_loansList.isEmpty)
                            const AppEmptyState(
                              title: 'Belum ada pinjaman',
                              description: 'Anda belum memiliki riwayat pengajuan pinjaman.',
                              icon: Icons.monetization_on_rounded,
                            )
                          else
                            ..._loansList.map((loan) => _loanHistoryCard(loan)),
                        ],
                      ),
                    ),
                  ),

                  // TAB 2: SIMULASI & FORM PENGAJUAN
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!_bolehAjukan)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.warningBg,
                              border: Border.all(color: AppColors.warningBorder),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 22),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Anda belum dapat mengajukan pinjaman baru karena telah memiliki 2 pinjaman/kredit aktif berjalan.',
                                    style: TextStyle(color: Color(0xFF92400E), fontSize: 12.5, height: 1.4, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else ...[
                          AppCard(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Simulasi Pinjaman Koperasi',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Bunga flat 10% untuk semua tenor pinjaman.',
                                  style: TextStyle(fontSize: 12, color: AppColors.textMutedLight, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 20),

                                if (_formError != null) ...[
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.errorBg,
                                      border: Border.all(color: AppColors.errorBorder),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Text(_formError!, style: const TextStyle(color: AppColors.error, fontSize: 12.5)),
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                const Text('Nominal Pinjaman (Rupiah)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: _nominalController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                  inputFormatters: [RupiahInputFormatter()],
                                  decoration: const InputDecoration(
                                    hintText: 'Minimal Rp 100.000',
                                    prefixText: 'Rp ',
                                  ),
                                ),
                                const SizedBox(height: 16),

                                const Text('Tenor Pinjaman (Bulan)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<int>(
                                  initialValue: _selectedTenor,
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight, fontFamily: 'Poppins'),
                                  decoration: const InputDecoration(),
                                  items: List.generate(12, (index) => index + 1)
                                      .map((t) => DropdownMenuItem(value: t, child: Text('$t Bulan')))
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _selectedTenor = val;
                                        _simulasiHasil = null;
                                      });
                                    }
                                  },
                                ),
                                const SizedBox(height: 24),

                                AppButton(
                                  text: 'Hitung Simulasi',
                                  variant: AppButtonVariant.outline,
                                  isLoading: _isSimulating,
                                  onPressed: _runSimulation,
                                ),

                                if (_simulasiHasil != null) ...[
                                  const SizedBox(height: 24),
                                  const Divider(height: 1),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Hasil Simulasi',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.surfaceSubtleDark : AppColors.surfaceSubtleLight,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      children: [
                                        _simulationRow('Bunga Pinjaman', '10% (Flat)'),
                                        const SizedBox(height: 6),
                                        _simulationRow('Nominal Bunga', Formatters.formatCurrency(_simulasiHasil!['nominal_bunga'] ?? 0)),
                                        const SizedBox(height: 6),
                                        _simulationRow('Total Pengembalian', Formatters.formatCurrency(_simulasiHasil!['total_pengembalian'] ?? 0)),
                                        const Divider(height: 16),
                                        _simulationRow('Angsuran Per Bulan', Formatters.formatCurrency(_simulasiHasil!['angsuran_per_bulan'] ?? 0), isTotal: true),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text('Upload Tanda Tangan Anggota', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: _showSignatureSourceSheet,
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      padding: const EdgeInsets.all(18),
                                      decoration: BoxDecoration(
                                        color: isDark ? AppColors.surfaceSubtleDark : AppColors.surfaceSubtleLight,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 1.5),
                                      ),
                                      child: _ttdFile == null
                                          ? const Column(
                                              children: [
                                                Icon(Icons.draw_rounded, size: 36, color: AppColors.primary),
                                                SizedBox(height: 6),
                                                Text('Pilih Foto TTD Anggota', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                                SizedBox(height: 2),
                                                Text('Klik untuk memilih gambar TTD', style: TextStyle(fontSize: 11, color: AppColors.textMutedLight)),
                                              ],
                                            )
                                          : Column(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(10),
                                                  child: Image.file(_ttdFile!, height: 100, fit: BoxFit.contain),
                                                ),
                                                const SizedBox(height: 8),
                                                const Text('Tanda Tangan Terpilih', style: TextStyle(fontSize: 11.5, color: AppColors.primary, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  AppButton(
                                    text: 'Kirim Pengajuan Pinjaman',
                                    isLoading: _isSubmitting,
                                    onPressed: _submitLoan,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _debtSummaryCard() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text('Informasi Pinjaman Aktif', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Pinjaman Cair', style: TextStyle(fontSize: 11.5, color: AppColors.textMutedLight, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text(Formatters.formatCurrency(_totalPinjamanAktif), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              Container(height: 28, width: 1, color: AppColors.borderLight, margin: const EdgeInsets.symmetric(horizontal: 12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sisa Tagihan Pinjaman', style: TextStyle(fontSize: 11.5, color: AppColors.textMutedLight, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text(Formatters.formatCurrency(_totalSisaPinjaman), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _loanHistoryCard(dynamic item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String status = item['status'] ?? 'pending';
    final int nominal = item['nominal'] is num
        ? (item['nominal'] as num).toInt()
        : (double.tryParse(item['nominal']?.toString() ?? '')?.toInt() ?? 0);
    final int tenor = item['tenor_bulan'] ?? 1;
    final int sisa = item['sisa_pinjaman'] is num
        ? (item['sisa_pinjaman'] as num).toInt()
        : (double.tryParse(item['sisa_pinjaman']?.toString() ?? '')?.toInt() ?? 0);

    final int sudahBayarCount = item['sudah_bayar_count'] ?? 0;
    final List<dynamic> pembayaran = item['pembayaran'] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: EdgeInsets.zero,
        child: ExpansionTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: const Icon(Icons.monetization_on_rounded, color: AppColors.secondary, size: 20),
          ),
          title: Text(
            'Pinjaman Uang Rp ${Formatters.formatCurrency(nominal).replaceAll('Rp ', '')}',
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
          ),
          subtitle: Text(
            'Tenor: $tenor Bulan • Sisa: ${Formatters.formatCurrency(sisa)}',
            style: TextStyle(fontSize: 11.5, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight, fontWeight: FontWeight.w500),
          ),
          trailing: AppBadge.status(status, fontSize: 10),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Angsuran Masuk:', style: TextStyle(fontSize: 12, color: AppColors.textMutedLight)),
                      Text('$sudahBayarCount dari $tenor Bulan', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('Riwayat Angsuran:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const Divider(height: 12),
                  if (pembayaran.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6.0),
                      child: Text('Tidak ada riwayat pembayaran.', style: TextStyle(fontSize: 11, color: AppColors.textMutedLight)),
                    )
                  else
                    ...pembayaran.map((p) {
                      final int ke = p['angsuran_ke'] ?? 1;
                      final int nominalBayar = (p['nominal'] is int)
                          ? p['nominal']
                          : (double.tryParse(p['nominal']?.toString() ?? '0') ?? 0).toInt();
                      final String statusBayar = p['status'] ?? 'belum_bayar';
                      String tgl = (statusBayar == 'approved' && p['tanggal_bayar'] != null)
                          ? p['tanggal_bayar'].toString()
                          : (p['jatuh_tempo'] ?? '-');
                      if (tgl.contains('T')) tgl = tgl.split('T')[0];
                      if (tgl.contains(' ')) tgl = tgl.split(' ')[0];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text('Bulan ke-$ke ($tgl)', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500)),
                            ),
                            Row(
                              children: [
                                Text('Rp ${Formatters.formatCurrency(nominalBayar).replaceAll('Rp ', '')}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                AppBadge.status(statusBayar, fontSize: 9),
                                if (statusBayar == 'belum_bayar' || statusBayar == 'rejected') ...[
                                  const SizedBox(width: 6),
                                  AppButton(
                                    text: 'Bayar',
                                    height: 28,
                                    isFullWidth: false,
                                    onPressed: () => _payInstallment(p),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  if (item['ttd_anggota'] != null || item['ttd_admin'] != null) ...[
                    const Divider(height: 16),
                    const Text('Tanda Tangan & Persetujuan:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (item['ttd_anggota'] != null)
                          Expanded(
                            child: Column(
                              children: [
                                Container(
                                  height: 70,
                                  decoration: BoxDecoration(border: Border.all(color: AppColors.borderLight), borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.all(4),
                                  child: Image.network(item['ttd_anggota'].toString(), fit: BoxFit.contain),
                                ),
                                const SizedBox(height: 4),
                                const Text('TTD Anggota', style: TextStyle(fontSize: 10, color: AppColors.textMutedLight)),
                              ],
                            ),
                          ),
                        if (item['ttd_admin'] != null) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              children: [
                                Container(
                                  height: 70,
                                  decoration: BoxDecoration(border: Border.all(color: AppColors.borderLight), borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.all(4),
                                  child: Image.network(item['ttd_admin'].toString(), fit: BoxFit.contain),
                                ),
                                const SizedBox(height: 4),
                                const Text('TTD Pengurus', style: TextStyle(fontSize: 10, color: AppColors.textMutedLight)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _simulationRow(String label, String value, {bool isTotal = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isTotal ? 13 : 12, fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
          Text(value, style: TextStyle(fontSize: isTotal ? 15 : 13, fontWeight: FontWeight.w900, color: isTotal ? AppColors.primary : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight))),
        ],
      ),
    );
  }
}
