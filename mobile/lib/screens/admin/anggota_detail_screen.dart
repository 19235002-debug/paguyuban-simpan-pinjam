import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/formatters.dart';
import 'anggota_form_dialog.dart';

class AdminAnggotaDetailScreen extends StatefulWidget {
  final int userId;
  final String name;
  const AdminAnggotaDetailScreen({super.key, required this.userId, required this.name});

  @override
  State<AdminAnggotaDetailScreen> createState() => _AdminAnggotaDetailScreenState();
}

class _AdminAnggotaDetailScreenState extends State<AdminAnggotaDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;

  Map<String, dynamic>? _user;
  List<dynamic> _simpananList = [];
  List<dynamic> _pinjamanList = [];
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.get('/pengurus/anggota/${widget.userId}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _user = data['user'];
          _simpananList = data['simpanan'] ?? [];
          _pinjamanList = data['pinjaman'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Gagal memuat detail anggota.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan koneksi.';
        _isLoading = false;
      });
    }
  }

  void _editMember() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AnggotaFormBottomSheet(member: _user),
    ).then((success) {
      if (success == true && mounted) {
        _fetchDetails();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil anggota berhasil diperbarui.'),
            backgroundColor: Color(0xFF0D9488),
          ),
        );
      }
    });
  }

  Future<void> _deleteMember() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Anggota', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin menghapus "${widget.name}"? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await ApiService.delete('/pengurus/anggota/${widget.userId}');
        if (response.statusCode == 200) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Anggota "${widget.name}" berhasil dihapus.'),
                backgroundColor: Colors.redAccent,
              ),
            );
            Navigator.pop(context, true); // Pop detail screen and notify list to refresh
          }
        } else {
          final body = jsonDecode(response.body);
          final String errMsg = body['message'] ?? 'Gagal menghapus anggota.';
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: const Text('Gagal Menghapus', style: TextStyle(fontWeight: FontWeight.bold)),
                content: Text(errMsg),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Terjadi kesalahan jaringan.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const tealColor = Color(0xFF0D9488);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.name)),
        body: const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(tealColor))),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.name)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(_errorMessage!, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchDetails,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(widget.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: Colors.blue),
            onPressed: _editMember,
          ),
          IconButton(
            icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
            onPressed: _deleteMember,
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: tealColor,
              indicatorWeight: 3,
              labelColor: tealColor,
              unselectedLabelColor: const Color(0xFF94A3B8),
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, fontFamily: 'Poppins'),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, fontFamily: 'Poppins'),
              tabs: const [
                Tab(text: 'Profil'),
                Tab(text: 'Simpanan'),
                Tab(text: 'Pinjaman'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: PROFIL
          SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _profileCard(),
                const SizedBox(height: 20),
                _financeSummaryCard(),
              ],
            ),
          ),

          // TAB 2: SIMPANAN
          Builder(builder: (context) {
            const tealColor = Color(0xFF0D9488);
            // Kumpulkan semua tahun unik yang ada di data simpanan
            final years = _simpananList
                .map((s) {
                  final y = s['tahun'];
                  return (y is int) ? y : int.tryParse(y?.toString() ?? '') ?? 0;
                })
                .where((y) => y > 0)
                .toSet()
                .toList()
              ..sort((a, b) => b.compareTo(a)); // descending

            // Filter simpanan sesuai tahun terpilih
            final filtered = _simpananList.where((s) {
              final y = s['tahun'];
              final yr = (y is int) ? y : int.tryParse(y?.toString() ?? '') ?? 0;
              return yr == _selectedYear;
            }).toList();

            return RefreshIndicator(
              onRefresh: _fetchDetails,
              color: tealColor,
              child: _simpananList.isEmpty
                  ? ListView(children: [
                      const SizedBox(height: 80),
                      Center(
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(color: tealColor.withValues(alpha: 0.08), shape: BoxShape.circle),
                            child: const Icon(Icons.account_balance_wallet_rounded, size: 64, color: tealColor),
                          ),
                          const SizedBox(height: 20),
                          const Text('Anggota belum memiliki riwayat simpanan.', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                        ]),
                      ),
                    ])
                  : Column(
                      children: [
                        // Year filter chips
                        if (years.length > 1)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(22, 14, 22, 4),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: years.map((year) {
                                  final isSelected = _selectedYear == year;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ChoiceChip(
                                      label: Text(
                                        year.toString(),
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : const Color(0xFF475569),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.5,
                                        ),
                                      ),
                                      selected: isSelected,
                                      onSelected: (_) => setState(() => _selectedYear = year),
                                      selectedColor: tealColor,
                                      backgroundColor: Colors.white,
                                      showCheckmark: false,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        side: BorderSide(color: isSelected ? tealColor : const Color(0xFFE2E8F0)),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        Expanded(
                          child: filtered.isEmpty
                              ? Center(
                                  child: Text(
                                    'Tidak ada simpanan di tahun $_selectedYear.',
                                    style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                                  itemCount: filtered.length,
                                  itemBuilder: (context, index) => _simpananLogCard(filtered[index]),
                                ),
                        ),
                      ],
                    ),
            );
          }),

          // TAB 3: PINJAMAN
          RefreshIndicator(
            onRefresh: _fetchDetails,
            color: tealColor,
            child: _pinjamanList.isEmpty
                ? ListView(
                    children: [
                      const SizedBox(height: 80),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.purple.withValues(alpha: 0.08), shape: BoxShape.circle),
                        child: const Icon(Icons.monetization_on_rounded, size: 64, color: Colors.purple),
                      ),
                      const SizedBox(height: 20),
                      const Center(child: Text('Anggota belum memiliki riwayat pinjaman.', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold))),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                    itemCount: _pinjamanList.length,
                    itemBuilder: (context, index) {
                      final p = _pinjamanList[index];
                      return _pinjamanLogCard(p);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _profileCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Informasi Pribadi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
            const SizedBox(height: 16),
            _infoRow('NIK', _user?['nik']),
            _infoRow('Email', _user?['email']),
            _infoRow('No. Handphone', _user?['no_hp']),
            _infoRow('Alamat', _user?['alamat']),
            _infoRow('Tanggal Gabung', Formatters.formatDate(_user?['tanggal_gabung'])),
          ],
        ),
      ),
    );
  }

  Widget _financeSummaryCard() {
    final int ts = ((_user?['total_simpanan']) is int)
        ? _user!['total_simpanan']
        : int.tryParse(_user?['total_simpanan']?.toString() ?? '0') ?? 0;
    final int tp = ((_user?['total_pinjaman']) is int)
        ? _user!['total_pinjaman']
        : int.tryParse(_user?['total_pinjaman']?.toString() ?? '0') ?? 0;
    final int net = ts - tp;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ringkasan Keuangan Anggota', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Simpanan', style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(Formatters.formatCurrency(ts), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF0D9488))),
                    ],
                  ),
                ),
                Container(
                  height: 32,
                  width: 1.5,
                  color: const Color(0xFFE2E8F0),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Pinjaman & Kredit', style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(Formatters.formatCurrency(tp), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.redAccent)),
                    ],
                  ),
                ),
                Container(
                  height: 32,
                  width: 1.5,
                  color: const Color(0xFFE2E8F0),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Posisi Net', style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(
                        Formatters.formatCurrency(net),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: net >= 0 ? const Color(0xFF0D9488) : Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value ?? '-',
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _simpananLogCard(dynamic item) {
    final String status = item['status'] ?? 'pending';
    final int nominal = (item['total_bayar'] is int)
        ? item['total_bayar']
        : int.tryParse(item['total_bayar']?.toString() ?? '0') ?? 0;
    final int bulan = (item['bulan'] is int)
        ? item['bulan']
        : int.tryParse(item['bulan']?.toString() ?? '1') ?? 1;
    final int tahun = (item['tahun'] is int)
        ? item['tahun']
        : int.tryParse(item['tahun']?.toString() ?? '2026') ?? 2026;

    final List<String> listBulan = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final String namaBulan = bulan >= 1 && bulan <= 12 ? listBulan[bulan] : '$bulan';

    Color badgeBg;
    Color badgeText;
    switch (status) {
      case 'approved':
        badgeBg = const Color(0xFFE8F5E9);
        badgeText = const Color(0xFF2E7D32);
        break;
      case 'rejected':
        badgeBg = const Color(0xFFFFEBEE);
        badgeText = const Color(0xFFC62828);
        break;
      default:
        badgeBg = const Color(0xFFFFF8E1);
        badgeText = const Color(0xFFF57F17);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Simpanan Wajib ($namaBulan $tahun)', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
                const SizedBox(height: 4),
                Text(Formatters.formatCurrency(nominal), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF64748B))),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(10)),
              child: Text(status.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: badgeText)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pinjamanLogCard(dynamic item) {
    final String status = item['status'] ?? 'pending';
    final int nominal = (item['nominal'] is int)
        ? item['nominal']
        : (double.tryParse(item['nominal']?.toString() ?? '0') ?? 0).toInt();
    final int tenor = (item['tenor_bulan'] is int)
        ? item['tenor_bulan']
        : int.tryParse(item['tenor_bulan']?.toString() ?? '1') ?? 1;
    final int sisaPinjaman = (item['sisa_pinjaman'] is int)
        ? item['sisa_pinjaman']
        : (double.tryParse(item['sisa_pinjaman']?.toString() ?? '0') ?? 0).toInt();
    final int sudahBayarCount = item['sudah_bayar_count'] ?? 0;
    final List<dynamic> pembayaran = item['pembayaran'] ?? [];

    Color badgeBg;
    Color badgeText;
    switch (status) {
      case 'approved':
      case 'lunas':
        badgeBg = const Color(0xFFE8F5E9);
        badgeText = const Color(0xFF2E7D32);
        break;
      case 'rejected':
        badgeBg = const Color(0xFFFFEBEE);
        badgeText = const Color(0xFFC62828);
        break;
      default:
        badgeBg = const Color(0xFFFFF8E1);
        badgeText = const Color(0xFFF57F17);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        title: Text(
          'Pinjaman Rp ${Formatters.formatCurrency(nominal).replaceAll('Rp ', '')}', 
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            'Tenor: $tenor Bulan • Sisa: Rp ${Formatters.formatCurrency(sisaPinjaman).replaceAll('Rp ', '')}', 
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(10)),
          child: Text(status.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: badgeText)),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Angsuran Masuk:', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    Text('$sudahBayarCount dari $tenor Bulan', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Riwayat Angsuran:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                const Divider(),
                if (pembayaran.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Tidak ada riwayat pembayaran.', style: TextStyle(fontSize: 11, color: Colors.grey)),
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
                    if (tgl.contains('T')) {
                      tgl = tgl.split('T')[0];
                    }
                    if (tgl.contains(' ')) {
                      tgl = tgl.split(' ')[0];
                    }
                    
                    Color statColor = const Color(0xFF64748B);
                    if (statusBayar == 'approved') statColor = const Color(0xFF2E7D32);
                    if (statusBayar == 'pending') statColor = const Color(0xFFF57F17);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Bulan ke-$ke ($tgl)', 
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              Text('Rp ${Formatters.formatCurrency(nominalBayar).replaceAll('Rp ', '')}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                              const SizedBox(width: 8),
                              Text(statusBayar.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: statColor)),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                if (item['ttd_anggota'] != null || item['ttd_admin'] != null) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Persetujuan & Tanda Tangan:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (item['ttd_anggota'] != null)
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey[50],
                                ),
                                padding: const EdgeInsets.all(6),
                                child: Image.network(
                                  item['ttd_anggota'].toString(),
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(child: Icon(Icons.broken_image, size: 24, color: Colors.grey)),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'TTD Anggota',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                      if (item['ttd_anggota'] != null && item['ttd_admin'] != null)
                        const SizedBox(width: 16),
                      if (item['ttd_admin'] != null)
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey[50],
                                ),
                                padding: const EdgeInsets.all(6),
                                child: Image.network(
                                  item['ttd_admin'].toString(),
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(child: Icon(Icons.broken_image, size: 24, color: Colors.grey)),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'TTD Pengurus (Persetujuan)',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          )
        ],
      ),
    );
  }
}
