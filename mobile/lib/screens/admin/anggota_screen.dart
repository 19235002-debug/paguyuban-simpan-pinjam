import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/api_service.dart';
import '../../shared/widgets/app_badge.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_empty_state.dart';
import '../../shared/widgets/app_error_state.dart';
import '../../shared/widgets/app_skeleton.dart';
import '../../utils/formatters.dart';
import 'anggota_detail_screen.dart';
import 'anggota_form_dialog.dart';
import '../profile_screen.dart';
import '../login_screen.dart';
import '../../services/storage_service.dart';

class AdminAnggotaScreen extends StatefulWidget {
  final bool isActive;
  const AdminAnggotaScreen({super.key, this.isActive = false});

  @override
  State<AdminAnggotaScreen> createState() => _AdminAnggotaScreenState();
}

class _AdminAnggotaScreenState extends State<AdminAnggotaScreen> {
  final _searchController = TextEditingController();
  final List<dynamic> _membersList = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = false;
  bool _isFetchingMore = false;
  Timer? _refreshTimer;
  Timer? _debounceTimer;
  String _selectedStatus = 'semua';

  @override
  void initState() {
    super.initState();
    _fetchMembers();
    _startTimer();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _fetchMembers(refresh: true);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (widget.isActive && mounted && !_isLoading && !_isFetchingMore) {
        _fetchMembers(quiet: true);
      }
    });
  }

  @override
  void didUpdateWidget(covariant AdminAnggotaScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _fetchMembers(refresh: true);
      _startTimer();
    } else if (!widget.isActive && oldWidget.isActive) {
      _refreshTimer?.cancel();
      _debounceTimer?.cancel();
      if (_searchController.text.isNotEmpty) {
        _searchController.clear();
        setState(() {
          _currentPage = 1;
          _membersList.clear();
          _selectedStatus = 'semua';
        });
      }
    }
  }

  Future<void> _fetchMembers({bool refresh = false, bool quiet = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _membersList.clear();
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
      final query = _searchController.text.trim();
      final response = await ApiService.get(
        '/anggota?page=$pageToFetch&search=$query&status=$_selectedStatus',
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data['data'] as List;
        final lastPage = data['last_page'] ?? 1;

        if (mounted) {
          setState(() {
            if (quiet || pageToFetch == 1) {
              _membersList.clear();
            }
            _membersList.addAll(list);
            _hasMore = _currentPage < lastPage;
            _isLoading = false;
            _isFetchingMore = false;
          });
        }
      } else if (!quiet) {
        setState(() {
          _errorMessage = 'Gagal memuat data anggota.';
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
      _fetchMembers();
    }
  }

  void _openAddMemberDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AnggotaFormBottomSheet(),
    ).then((result) {
      if (result == true) {
        _fetchMembers(refresh: true);
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
                          'Daftar Anggota',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Manajemen seluruh anggota koperasi',
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

            // Search Bar & Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: 'Cari Nama, NIK, No. HP, Alamat...',
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _statusChip('semua', 'Semua Status'),
                      const SizedBox(width: 8),
                      _statusChip('aktif', 'Aktif'),
                      const SizedBox(width: 8),
                      _statusChip('nonaktif', 'Non-Aktif'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _fetchMembers(refresh: true),
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
                        onRetry: () => _fetchMembers(refresh: true),
                      )
                    : _membersList.isEmpty
                    ? const AppEmptyState(
                        title: 'Anggota Tidak Ditemukan',
                        description: 'Tidak ada data anggota yang sesuai dengan kriteria pencarian.',
                        icon: Icons.people_outline_rounded,
                      )
                    : NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification scrollInfo) {
                          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                            _loadMore();
                          }
                          return true;
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          itemCount: _membersList.length + (_hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _membersList.length) {
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
                            final member = _membersList[index];
                            return _memberCard(member);
                          },
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: _openAddMemberDialog,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text('Tambah Anggota', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
      ),
    );
  }

  Widget _statusChip(String value, String label) {
    final isSelected = _selectedStatus == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
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
            _selectedStatus = value;
          });
          _fetchMembers(refresh: true);
        }
      },
    );
  }

  Widget _memberCard(dynamic member) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String name = member['name'] ?? '-';
    final String nik = member['nik'] ?? '-';
    final String status = member['status'] ?? 'aktif';
    final int totalSimpanan = member['total_simpanan'] is num
        ? (member['total_simpanan'] as num).toInt()
        : (double.tryParse(member['total_simpanan']?.toString() ?? '')?.toInt() ?? 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AdminAnggotaDetailScreen(userId: member['id'], name: member['name'] ?? '-'),
            ),
          ).then((_) => _fetchMembers());
        },
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
              alignment: Alignment.center,
              child: Text(
                name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'A',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'NIK: $nik',
                    style: TextStyle(fontSize: 11.5, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Simpanan: ${Formatters.formatCurrency(totalSimpanan)}',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            AppBadge.status(status, fontSize: 10),
          ],
        ),
      ),
    );
  }
}
