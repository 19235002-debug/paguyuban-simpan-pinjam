import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../services/api_service.dart';
import '../../shared/widgets/app_button.dart';
import '../../utils/formatters.dart';

class PayInstallmentBottomSheet extends StatefulWidget {
  final dynamic item;
  const PayInstallmentBottomSheet({super.key, required this.item});

  @override
  State<PayInstallmentBottomSheet> createState() => _PayInstallmentBottomSheetState();
}

class _PayInstallmentBottomSheetState extends State<PayInstallmentBottomSheet> {
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
      final picked = await picker.pickImage(source: source, imageQuality: 80);
      if (picked != null) {
        setState(() {
          _image = File(picked.path);
          _error = null;
        });
      }
    } catch (e) {
      setState(() => _error = 'Gagal mengakses media.');
    }
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
              Text('Pilih Sumber Foto', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
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
      setState(() => _error = 'Harap tentukan tanggal bayar.');
      return;
    }
    if (_image == null) {
      setState(() => _error = 'Harap unggah bukti transfer.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final int paymentId = widget.item['id'];
      final fields = {'tanggal_bayar': _dateController.text};
      final files = {'bukti_transfer': _image!};

      final response = await ApiService.multipart('POST', '/pembayaran/$paymentId', fields, files);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        setState(() {
          _error = data['message'] ?? 'Gagal memproses pembayaran.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Terjadi kesalahan jaringan saat mengupload data.';
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
    final item = widget.item;
    final int nominal = (item['nominal'] is int)
        ? item['nominal']
        : (double.tryParse(item['nominal']?.toString() ?? '0') ?? 0).toInt();
    final int angsuranKe = item['angsuran_ke'] ?? 1;
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
              Text(
                'Pembayaran Angsuran ke-$angsuranKe',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Total Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Nominal Angsuran', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                Text(
                  Formatters.formatCurrency(nominal),
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Bank Info
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
            text: 'Kirim Pembayaran',
            isLoading: _isSubmitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
