import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../shared/widgets/app_button.dart';
import '../shared/widgets/app_card.dart';
import '../widgets/liquid_aquarium_loader.dart';
import 'member_nav.dart';
import 'admin_nav.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  // Login success liquid loader animation state
  bool _showSuccessAnimation = false;
  double _successProgress = 0.0;
  AnimationController? _successAnimController;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _successAnimController?.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.post('/login', {
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
      });

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = data['token'];
        final user = data['user'];

        await StorageService.saveToken(token);
        await StorageService.saveUser(user);

        if (mounted) {
          final role = user['role'];
          
          setState(() {
            _showSuccessAnimation = true;
            _isLoading = false;
          });

          _successAnimController = AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 1500),
          );
          
          Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: _successAnimController!, curve: Curves.easeInOut),
          ).addListener(() {
              setState(() {
                _successProgress = _successAnimController!.value;
              });
            });

          await _successAnimController!.forward();

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => role == 'pengurus'
                    ? const AdminNavigationShell()
                    : const MemberNavigationShell(),
              ),
            );
          }
        }
      } else {
        setState(() {
          _errorMessage = data['message'] ?? 'Email/NIK atau password salah.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal terhubung ke server. Periksa koneksi internet Anda.';
      });
    } finally {
      if (mounted && !_showSuccessAnimation) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSettingsDialog() {
    final controller = TextEditingController(text: ApiService.baseUrl);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Pengaturan API Base URL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ubah URL API sesuai alamat host server Anda:',
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondaryLight),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                labelText: 'Base URL',
                hintText: 'http://10.0.2.2:8000/api',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              setState(() {
                ApiService.baseUrl = controller.text.trim();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('API Base URL diubah ke: ${ApiService.baseUrl}'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showSuccessAnimation) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.heroGradient,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LiquidAquariumLoader(
                  progress: _successProgress,
                  size: 140,
                  color: AppColors.primaryLight,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Autentikasi Berhasil!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mempersiapkan dashboard... ${(_successProgress * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white70),
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.heroGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -60,
                left: -60,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: 60,
                right: -60,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo & Branding
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/logo.png',
                            width: 64,
                            height: 64,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Center(
                        child: Text(
                          'Bravo Bekasi',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          'KOPERASI SIMPAN PINJAM MODERN',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withValues(alpha: 0.5),
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Error message popup
                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.15),
                            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Glassmorphic Form Card
                      AppCard(
                        color: Colors.white.withValues(alpha: 0.05),
                        border: BorderSide(color: Colors.white.withValues(alpha: 0.12), width: 1.5),
                        padding: const EdgeInsets.all(24),
                        borderRadius: 28,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Email atau NIK',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                                decoration: InputDecoration(
                                  hintText: 'Email atau NIK anggota',
                                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 13),
                                  prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primaryLight, size: 20),
                                  fillColor: Colors.white.withValues(alpha: 0.05),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: AppColors.error.withValues(alpha: 0.6), width: 1.5),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: AppColors.error, width: 2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Harap isi email atau NIK.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              Text(
                                'Kata Sandi',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                                decoration: InputDecoration(
                                  hintText: '••••••••',
                                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 13),
                                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primaryLight, size: 20),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                      color: Colors.white60,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  fillColor: Colors.white.withValues(alpha: 0.05),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: AppColors.error.withValues(alpha: 0.6), width: 1.5),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: AppColors.error, width: 2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Harap isi kata sandi.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 28),

                              AppButton(
                                text: 'Masuk ke Aplikasi',
                                onPressed: _handleLogin,
                                isLoading: _isLoading,
                                height: 50,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: Text(
                          '© 2026 Paguyuban Bravo Bekasi',
                          style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.35), fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
