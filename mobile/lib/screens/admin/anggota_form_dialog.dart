import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AnggotaFormBottomSheet extends StatefulWidget {
  final dynamic member; // if null, mode is Create; else Edit
  const AnggotaFormBottomSheet({super.key, this.member});

  @override
  State<AnggotaFormBottomSheet> createState() => _AnggotaFormBottomSheetState();
}

class _AnggotaFormBottomSheetState extends State<AnggotaFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nikController;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _passwordController;
  late TextEditingController _dateController;
  
  String _selectedStatus = 'aktif';
  bool _isSubmitting = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final m = widget.member;
    _nikController = TextEditingController(text: m?['nik'] ?? '');
    _nameController = TextEditingController(text: m?['name'] ?? '');
    _emailController = TextEditingController(text: m?['email'] ?? '');
    _phoneController = TextEditingController(text: m?['no_hp'] ?? '');
    _addressController = TextEditingController(text: m?['alamat'] ?? '');
    _passwordController = TextEditingController();
    _dateController = TextEditingController(
      text: m?['tanggal_gabung'] != null
          ? m['tanggal_gabung'].toString().split(' ').first
          : DateTime.now().toLocal().toString().split(' ').first,
    );
    if (m?['status'] != null) {
      _selectedStatus = m!['status'];
    }
  }

  @override
  void dispose() {
    _nikController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_dateController.text) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D9488),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text = picked.toLocal().toString().split(' ').first;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final payload = {
      'nik': _nikController.text.trim(),
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'no_hp': _phoneController.text.trim(),
      'alamat': _addressController.text.trim(),
      'status': _selectedStatus,
      'tanggal_gabung': _dateController.text,
    };

    if (_passwordController.text.isNotEmpty) {
      payload['password'] = _passwordController.text;
    }

    try {
      final isEdit = widget.member != null;
      final response = isEdit
          ? await ApiService.put('/pengurus/anggota/${widget.member['id']}', payload)
          : await ApiService.post('/pengurus/anggota', payload);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        final body = jsonDecode(response.body);
        setState(() {
          _errorMessage = body['message'] ?? 'Terjadi kesalahan sistem.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal terhubung ke server.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const tealColor = Color(0xFF0D9488);
    final isEdit = widget.member != null;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEdit ? 'Edit Profil Anggota' : 'Tambah Anggota Baru',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              TextFormField(
                controller: _nikController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'NIK',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap *',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Nama lengkap wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Email wajib diisi';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'No. Handphone',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Alamat Lengkap',
                  prefixIcon: Icon(Icons.home_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: isEdit ? 'Password Baru (Opsional)' : 'Password *',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  helperText: isEdit ? 'Kosongkan jika tidak ingin mengganti password' : null,
                ),
                validator: (val) {
                  if (!isEdit && (val == null || val.isEmpty)) return 'Password wajib diisi';
                  if (val != null && val.isNotEmpty && val.length < 6) {
                    return 'Password minimal 6 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status Anggota',
                        prefixIcon: Icon(Icons.toggle_on_outlined),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'aktif', child: Text('Aktif')),
                        DropdownMenuItem(value: 'nonaktif', child: Text('Nonaktif')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedStatus = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      onTap: _selectDate,
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Gabung',
                        prefixIcon: Icon(Icons.calendar_month_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: tealColor,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                      )
                    : Text(
                        isEdit ? 'Simpan Perubahan' : 'Tambah Anggota Sekarang',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
