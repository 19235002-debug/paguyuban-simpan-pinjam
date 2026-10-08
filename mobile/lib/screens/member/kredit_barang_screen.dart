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

class MemberKreditBarangScreen extends StatefulWidget {
  final bool isActive;
  const MemberKreditBarangScreen({super.key, this.isActive = false});

  @override
  State<MemberKreditBarangScreen> createState() => _MemberKreditBarangScreenState();
}

class _MemberKreditBarangScreenState extends State<MemberKreditBarangScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _refreshTimer;

  List<dynamic> _kreditList = [];
  bool _bolehAjukan = false;

  // Form states
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _selectedTenor = 1;
  File? _itemImage;
  File? _ttdFile;
  bool _isSubmitting = false;
  String? _formError;
  bool _isSimulating = false;
  Map<String, dynamic>? _simulasiHasil;

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
          message: 'Anda masih memiliki pinjaman atau kredit barang aktif yang sedang berjalan. Harap selesaikan kewajiban Anda terlebih dahulu.',
        );
      }
    });
    _priceController.addListener(() {
      if (_simulasiHasil != null) {
        setState(() => _simulasiHasil = null);
      }
    });
    _fetchKredit();
    _startTimer();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _tabController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
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
              Text('Pilih Sumber Foto TTD', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
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

  Future<void> _pickItemImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
      if (pickedFile != null) {
        setState(() {
          _itemImage = File(pickedFile.path);
        });
      }
    } catch (_) {}
  }

  void _showItemImageSourceSheet() {
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
              Text('Pilih Foto Barang', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
                title: const Text('Galeri Foto', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickItemImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                title: const Text('Kamera', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickItemImage(ImageSource.camera);
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
        _fetchKredit(quiet: true);
      }
    });
  }

  @override
  void didUpdateWidget(covariant MemberKreditBarangScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _fetchKredit();
      _startTimer();
    } else if (!widget.isActive && oldWidget.isActive) {
      _refreshTimer?.cancel();
    }
  }

  Future<void> _fetchKredit({bool quiet = false}) async {
    if (!quiet) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final response = await ApiService.get('/kredit-barang');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _kreditList = data['kredit_barang']['data'] ?? [];
            _bolehAjukan = data['bolehAjukan'] ?? false;
            _isLoading = false;
          });
        }
      } else if (!quiet) {
        setState(() {
          _errorMessage = 'Gagal memuat daftar kredit barang.';
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
        _fetchKredit();
        CustomSweetAlert.showSuccess(
          context: context,
          message: 'Pembayaran berhasil dikirim.',
        );
      }
    });
  }

  Future<void> _runSimulation() async {
    final priceText = _priceController.text.replaceAll(RegExp(r'\D'), '');
    if (priceText.isEmpty) {
      setState(() => _formError = 'Harap isi harga barang.');
      return;
    }
    final int harga = int.parse(priceText);
    if (harga < 1000) {
      setState(() => _formError = 'Harga barang harus lebih dari Rp 1.000.');
      return;
    }

    setState(() {
      _isSimulating = true;
      _formError = null;
      _simulasiHasil = null;
    });

    try {
      final response = await ApiService.post('/kredit-barang/simulasi', {
        'harga_barang': harga,
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

  Future<void> _submitKredit() async {
    final name = _nameController.text.trim();
    final priceText = _priceController.text.replaceAll(RegExp(r'\D'), '');

    if (name.isEmpty) {
      setState(() => _formError = 'Harap isi nama barang.');
      return;
    }
    if (priceText.isEmpty) {
      setState(() => _formError = 'Harap isi harga barang.');
      return;
    }

    final int harga = int.parse(priceText);
    if (harga < 1000) {
      setState(() => _formError = 'Harga barang harus lebih dari Rp 1.000.');
      return;
    }

    if (_ttdFile == null) {
      setState(() => _formError = 'Harap upload foto tanda tangan Anggota.');
      return;
    }

    final confirm = await CustomAlert.showConfirm(
      context: context,
      title: 'Ajukan Kredit?',
      message: 'Apakah Anda yakin ingin mengajukan kredit barang "$name" seharga Rp ${Formatters.formatCurrency(harga).replaceAll('Rp ', '')} dengan tenor $_selectedTenor Bulan?',
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
      final fields = {
        'nama_barang': name,
        'harga_barang': harga.toString(),
        'tenor_bulan': _selectedTenor.toString(),
        'keterangan': _descriptionController.text.trim(),
      };
      
      final Map<String, File> files = {};
      if (_itemImage != null) {
        files['foto_barang'] = _itemImage!;
      }
      files['ttd_anggota'] = _ttdFile!;

      final response = await ApiService.multipart('POST', '/kredit-barang', fields, files);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _nameController.clear();
        _priceController.clear();
        _descriptionController.clear();
        setState(() {
          _itemImage = null;
          _ttdFile = null;
        });
        
        _tabController.animateTo(0);
        _fetchKredit();
        if (mounted) {
          CustomSweetAlert.showSuccess(
            context: context,
            message: 'Kredit barang berhasil diajukan.',
          );
        }
      } else {
        setState(() => _formError = data['message'] ?? 'Gagal mengajukan kredit.');
      }
    } catch (e) {
      setState(() => _formError = 'Terjadi kesalahan jaringan.');
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
          onRetry: _fetchKredit,
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
                          'Kredit Barang',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Pembiayaan barang pilihan Anda',
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
                  Tab(text: 'Daftar Kredit'),
                  Tab(text: 'Ajukan Baru'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // TAB 1: LIST
                  RefreshIndicator(
                    onRefresh: _fetchKredit,
                    color: AppColors.primary,
                    child: _kreditList.isEmpty
                        ? AppEmptyState(
                            title: 'Belum ada kredit barang',
                            description: 'Anda belum memiliki pengajuan kredit barang.',
                            icon: Icons.shopping_bag_rounded,
                            buttonText: _bolehAjukan ? 'Ajukan Sekarang' : null,
                            onButtonPressed: _bolehAjukan ? () => _tabController.animateTo(1) : null,
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: _kreditList.length,
                            itemBuilder: (context, index) {
                              final item = _kreditList[index];
                              return _kreditCard(item);
                            },
                          ),
                  ),

                  // TAB 2: AJUKAN FORM
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
                                    'Anda belum dapat mengajukan kredit barang baru karena telah memiliki 2 pinjaman/kredit aktif berjalan.',
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
                                  'Form Pengajuan Kredit Barang',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Bunga flat 10% untuk semua tenor kredit.',
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

                                const Text('Nama Barang / Produk', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: _nameController,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                  decoration: const InputDecoration(
                                    hintText: 'Contoh: Laptop Asus / HP Samsung A54',
                                    prefixIcon: Icon(Icons.shopping_bag_outlined, color: AppColors.primary, size: 20),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                const Text('Harga Barang (Rupiah)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: _priceController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                  inputFormatters: [RupiahInputFormatter()],
                                  decoration: const InputDecoration(
                                    hintText: 'Contoh: 5.000.000',
                                    prefixText: 'Rp ',
                                  ),
                                ),
                                const SizedBox(height: 16),

                                const Text('Tenor Cicilan (Bulan)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
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
                                const SizedBox(height: 16),

                                const Text('Catatan / Keterangan Tambahan (Opsional)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: _descriptionController,
                                  maxLines: 2,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                  decoration: const InputDecoration(
                                    hintText: 'Spesifikasi atau informasi toko penjual...',
                                  ),
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
                                    'Hasil Simulasi Kredit',
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
                                        _simulationRow('Bunga Kredit', '10% (Flat)'),
                                        const SizedBox(height: 6),
                                        _simulationRow('Nominal Bunga', Formatters.formatCurrency(_simulasiHasil!['nominal_bunga'] ?? 0)),
                                        const SizedBox(height: 6),
                                        _simulationRow('Total Harga + Bunga', Formatters.formatCurrency(_simulasiHasil!['total_pengembalian'] ?? 0)),
                                        const Divider(height: 16),
                                        _simulationRow('Angsuran Per Bulan', Formatters.formatCurrency(_simulasiHasil!['angsuran_per_bulan'] ?? 0), isTotal: true),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text('Upload Foto Barang (Opsional)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 8),
                                  if (_itemImage != null)
                                    Stack(
                                      children: [
                                        Container(
                                          height: 120,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                                            image: DecorationImage(image: FileImage(_itemImage!), fit: BoxFit.cover),
                                          ),
                                        ),
                                        Positioned(
                                          top: 6,
                                          right: 6,
                                          child: CircleAvatar(
                                            radius: 16,
                                            backgroundColor: Colors.black54,
                                            child: IconButton(
                                              padding: EdgeInsets.zero,
                                              icon: const Icon(Icons.delete_rounded, color: Colors.white, size: 16),
                                              onPressed: () => setState(() => _itemImage = null),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    AppButton(
                                      text: 'Unggah Foto Barang',
                                      variant: AppButtonVariant.outline,
                                      icon: Icons.add_a_photo_rounded,
                                      onPressed: _showItemImageSourceSheet,
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
                                    text: 'Kirim Pengajuan Kredit',
                                    isLoading: _isSubmitting,
                                    onPressed: _submitKredit,
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

  Widget _kreditCard(dynamic item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String status = item['status'] ?? 'pending';
    final String namaBarang = item['nama_barang'] ?? 'Barang';
    final int hargaBarang = item['harga_barang'] is num
        ? (item['harga_barang'] as num).toInt()
        : (double.tryParse(item['harga_barang']?.toString() ?? '')?.toInt() ?? 0);
    final int tenor = item['tenor_bulan'] ?? 1;
    final int sisa = item['sisa_kredit'] is num
        ? (item['sisa_kredit'] as num).toInt()
        : (double.tryParse(item['sisa_kredit']?.toString() ?? '')?.toInt() ?? 0);

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
            decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: const Icon(Icons.shopping_bag_rounded, color: AppColors.warning, size: 20),
          ),
          title: Text(
            namaBarang,
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
          ),
          subtitle: Text(
            'Harga: ${Formatters.formatCurrency(hargaBarang)} • Sisa: ${Formatters.formatCurrency(sisa)}',
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
