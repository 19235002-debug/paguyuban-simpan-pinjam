import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../shared/widgets/app_badge.dart';
import '../shared/widgets/app_button.dart';
import '../shared/widgets/app_card.dart';
import '../shared/widgets/app_skeleton.dart';
import '../utils/formatters.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  Map<String, dynamic>? _user;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final cachedUser = await StorageService.getUser();
      if (cachedUser != null) {
        setState(() {
          _user = cachedUser;
          _nameController.text = cachedUser['name'] ?? '';
          _emailController.text = cachedUser['email'] ?? '';
          _phoneController.text = cachedUser['no_hp'] ?? '';
          _addressController.text = cachedUser['alamat'] ?? '';
          _isLoading = false;
        });
      }

      final response = await ApiService.get('/profile');
      if (response.statusCode == 200) {
        final freshUser = jsonDecode(response.body);
        await StorageService.saveUser(freshUser);
        if (mounted) {
          setState(() {
            _user = freshUser;
            _nameController.text = freshUser['name'] ?? '';
            _emailController.text = freshUser['email'] ?? '';
            _phoneController.text = freshUser['no_hp'] ?? '';
            _addressController.text = freshUser['alamat'] ?? '';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.put('/profile', {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'no_hp': _phoneController.text.trim(),
        'alamat': _addressController.text.trim(),
      });

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final updatedUser = data['user'];
        await StorageService.saveUser(updatedUser);
        setState(() {
          _user = updatedUser;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil berhasil diperbarui.'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = data['message'] ?? 'Gagal memperbarui profil.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal menyimpan data ke server.';
      });
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Keluar Aplikasi', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        content: const Text('Apakah Anda yakin ingin keluar dari akun Anda?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.post('/logout', {});
      } catch (_) {}
      await StorageService.clear();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil Saya')),
        body: const Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              AppSkeleton(width: 100, height: 100, borderRadius: 50),
              SizedBox(height: 16),
              AppSkeleton(width: 160, height: 20),
              SizedBox(height: 24),
              AppSkeleton(width: double.infinity, height: 240),
            ],
          ),
        ),
      );
    }

    final String initial = _user != null && _user!['name'] != null && _user!['name'].toString().isNotEmpty
        ? _user!['name'].substring(0, 1).toUpperCase()
        : 'U';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar Card
            AppCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initial,
                      style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _user?['name'] ?? '-',
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, letterSpacing: -0.3),
                  ),
                  const SizedBox(height: 6),
                  AppBadge(
                    text: (_user?['role'] ?? '-').toString().toUpperCase(),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    textColor: AppColors.primary,
                    borderColor: AppColors.primary.withValues(alpha: 0.25),
                  ),
                  const SizedBox(height: 20),
                  Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight, height: 1),
                  const SizedBox(height: 14),
                  _profileDetailRow('NIK / ID Anggota', _user?['nik']),
                  _profileDetailRow('Tanggal Bergabung', Formatters.formatDate(_user?['tanggal_gabung'])),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.errorBg,
                  border: Border.all(color: AppColors.errorBorder),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(_errorMessage!, style: const TextStyle(color: AppColors.error, fontSize: 12.5, fontWeight: FontWeight.w600)),
              ),

            // Form Edit Card
            AppCard(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Informasi Personal',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 18),

                    _inputLabel('Nama Lengkap'),
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Masukkan nama lengkap',
                        prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.primary, size: 20),
                      ),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Nama harus diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    _inputLabel('Alamat Email'),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'name@example.com',
                        prefixIcon: Icon(Icons.mail_outline_rounded, color: AppColors.primary, size: 20),
                      ),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Email harus diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    _inputLabel('Nomor Handphone (WhatsApp)'),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Contoh: 08123456789',
                        prefixIcon: Icon(Icons.phone_outlined, color: AppColors.primary, size: 20),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _inputLabel('Alamat Tempat Tinggal'),
                    TextFormField(
                      controller: _addressController,
                      maxLines: 3,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Masukkan alamat lengkap',
                        prefixIcon: Icon(Icons.home_outlined, color: AppColors.primary, size: 20),
                      ),
                    ),
                    const SizedBox(height: 24),

                    AppButton(
                      text: 'Simpan Perubahan',
                      onPressed: _saveProfile,
                      isLoading: _isSaving,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Logout Button
            AppButton(
              text: 'Keluar dari Akun',
              variant: AppButtonVariant.danger,
              icon: Icons.logout_rounded,
              onPressed: _handleLogout,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _profileDetailRow(String label, String? value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12.5, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight, fontWeight: FontWeight.w500)),
          Text(value ?? '-', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
        ],
      ),
    );
  }

  Widget _inputLabel(String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
      ),
    );
  }
}
