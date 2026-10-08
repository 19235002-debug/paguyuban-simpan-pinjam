import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../utils/formatters.dart';

class AdminLaporanDetailScreen extends StatefulWidget {
  final String type;
  const AdminLaporanDetailScreen({super.key, required this.type});

  @override
  State<AdminLaporanDetailScreen> createState() => _AdminLaporanDetailScreenState();
}

class _AdminLaporanDetailScreenState extends State<AdminLaporanDetailScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _list = [];

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.get('/pengurus/laporan/${widget.type}');
      if (response.statusCode == 200) {
        setState(() {
          _list = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Gagal memuat detail laporan.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Kesalahan jaringan.';
        _isLoading = false;
      });
    }
  }

  String get _title {
    switch (widget.type) {
      case 'pemasukan':
        return 'Laporan Pemasukan';
      case 'pengeluaran':
        return 'Laporan Pengeluaran';
      case 'saldo_anggota':
        return 'Laporan Saldo Simpanan';
      case 'pinjaman_anggota':
        return 'Laporan Pinjaman & Kredit';
      case 'pinjaman_berjalan':
        return 'Daftar Pinjaman Aktif';
      case 'tunggakan_simpanan':
        return 'Tunggakan Simpanan Wajib';
      default:
        return 'Detail Laporan';
    }
  }

  Future<void> _launchUrl(String path) async {
    final String baseWebUrl = ApiService.baseUrl.replaceAll('/api', '');
    final token = await StorageService.getToken();
    final Uri url = Uri.parse('$baseWebUrl$path?token=$token');
    
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tidak dapat membuka URL: $url')),
          );
        }
      }
    } catch (e) {
      try {
        if (!await launchUrl(url, mode: LaunchMode.platformDefault)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal membuka link: $url')),
            );
          }
        }
      } catch (err) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Terjadi kesalahan: $err')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const tealColor = Color(0xFF0D9488);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: Colors.blue),
            tooltip: 'Download Excel',
            onPressed: () => _launchUrl('/pengurus/laporan/export/${widget.type}'),
          ),
          IconButton(
            icon: const Icon(Icons.print_outlined, color: tealColor),
            tooltip: 'Cetak PDF',
            onPressed: () => _launchUrl('/pengurus/laporan/print/${widget.type}'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDetail,
        color: tealColor,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(tealColor)))
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
                        const SizedBox(height: 12),
                        Text(_errorMessage!, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchDetail,
                          child: const Text('Muat Ulang'),
                        ),
                      ],
                    ),
                  )
                : _list.isEmpty
                    ? const Center(child: Text('Tidak ada data laporan untuk ditampilkan.', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                        itemCount: _list.length,
                        itemBuilder: (context, index) {
                          final item = _list[index];
                          return _buildReportRow(item);
                        },
                      ),
      ),
    );
  }

  Widget _buildReportRow(dynamic item) {
    if (widget.type == 'pemasukan' || widget.type == 'pengeluaran') {
      final String tanggal = item['tanggal'] ?? '-';
      final String anggota = item['anggota'] ?? '-';
      final String jenis = item['jenis'] ?? '-';
      final String keterangan = item['keterangan'] ?? '-';
      final int nominal = item['nominal'] ?? 0;
      final bool isPemasukan = widget.type == 'pemasukan';

      return Card(
        margin: const EdgeInsets.only(bottom: 14),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isPemasukan ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      jenis,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: isPemasukan ? const Color(0xFF047857) : const Color(0xFFB91C1C),
                      ),
                    ),
                  ),
                  Text(
                    Formatters.formatDate(tanggal),
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                anggota,
                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 4),
              Text(
                keterangan,
                style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
              ),
              const Divider(height: 24, color: Color(0xFFF1F5F9), thickness: 1.5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Nominal Transaksi', style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                  Text(
                    Formatters.formatCurrency(nominal),
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                      color: isPemasukan ? const Color(0xFF0D9488) : const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else if (widget.type == 'saldo_anggota') {
      final String nik = item['nik'] ?? '-';
      final String name = item['name'] ?? '-';
      final String email = item['email'] ?? '-';
      final int totalSimpanan = item['total_simpanan'] ?? 0;

      return Card(
        margin: const EdgeInsets.only(bottom: 14),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'NIK: $nik',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                  ),
                  const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF0D9488), size: 20),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                name,
                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 2),
              Text(
                email,
                style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
              ),
              const Divider(height: 24, color: Color(0xFFF1F5F9), thickness: 1.5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Simpanan Wajib', style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                  Text(
                    Formatters.formatCurrency(totalSimpanan),
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0D9488),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else if (widget.type == 'pinjaman_anggota') {
      final String nik = item['nik'] ?? '-';
      final String name = item['name'] ?? '-';
      final int totalPinjaman = item['total_pinjaman'] ?? 0;
      final int sisaPinjaman = item['sisa_pinjaman'] ?? 0;

      return Card(
        margin: const EdgeInsets.only(bottom: 14),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'NIK: $nik',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                  ),
                  const Icon(Icons.trending_up_rounded, color: Colors.blue, size: 20),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                name,
                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
              ),
              const Divider(height: 24, color: Color(0xFFF1F5F9), thickness: 1.5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Pinjaman & Kredit', style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                  Text(
                    Formatters.formatCurrency(totalPinjaman),
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF475569)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Sisa Tagihan Berjalan', style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                  Text(
                    Formatters.formatCurrency(sisaPinjaman),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else if (widget.type == 'pinjaman_berjalan') {
      final String nik = item['nik'] ?? '-';
      final String name = item['name'] ?? '-';
      final List<dynamic> activeLoans = item['active_loans'] ?? [];

      return Card(
        margin: const EdgeInsets.only(bottom: 14),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'NIK: $nik',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                  ),
                  const Icon(Icons.supervised_user_circle_rounded, color: Colors.deepOrangeAccent, size: 20),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                name,
                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
              ),
              const Divider(height: 24, color: Color(0xFFF1F5F9), thickness: 1.5),
              ...activeLoans.map((loan) => ActiveLoanCard(loan: loan, name: name)),
            ],
          ),
        ),
      );
    } else if (widget.type == 'tunggakan_simpanan') {
      final String nik = item['nik'] ?? '-';
      final String name = item['name'] ?? '-';
      final int totalTunggakan = item['total_tunggakan'] ?? 0;
      final List<dynamic> tunggakan = item['tunggakan'] ?? [];
      final String daftarBulan = tunggakan.map((t) => t['nama']).join(', ');

      return Card(
        margin: const EdgeInsets.only(bottom: 14),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'NIK: $nik',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                  ),
                  const Icon(Icons.money_off_rounded, color: Colors.purple, size: 20),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                name,
                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
              ),
              const Divider(height: 24, color: Color(0xFFF1F5F9), thickness: 1.5),
              const Text(
                'Bulan yang Belum Dibayar (Tahun 2026):',
                style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                daftarBulan,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.redAccent),
              ),
              const Divider(height: 24, color: Color(0xFFF1F5F9), thickness: 1.5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Tunggakan', style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                  Text(
                    Formatters.formatCurrency(totalTunggakan),
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}

class ActiveLoanCard extends StatefulWidget {
  final dynamic loan;
  final String name;

  const ActiveLoanCard({super.key, required this.loan, required this.name});

  @override
  State<ActiveLoanCard> createState() => _ActiveLoanCardState();
}

class _ActiveLoanCardState extends State<ActiveLoanCard> {

  void _showProofPhotoDialog(BuildContext context, String? url, String name, int angsuranKe) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Bukti Transfer Ke-$angsuranKe - $name',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (url == null || url.isEmpty)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.no_photography_outlined, size: 50, color: Colors.red[300]),
                    const SizedBox(height: 12),
                    const Text(
                      'Tidak ada foto bukti transfer',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '(Data Awal / Migrasi Seeder)',
                      style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              )
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: const Color(0xFFF1F5F9),
                    child: const Center(
                      child: Icon(Icons.broken_image_rounded, size: 48, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFEE2E2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 14, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Transaksi baru selanjutnya wajib melampirkan foto bukti pembayaran.',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D9488))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String tipe = widget.loan['tipe'] ?? '-';
    final String keterangan = widget.loan['keterangan'] ?? '-';
    final int nominal = widget.loan['nominal'] ?? 0;
    final int sisa = widget.loan['sisa'] ?? 0;
    final int tenor = widget.loan['tenor'] ?? 0;
    final int sudahBayar = widget.loan['sudah_bayar'] ?? 0;
    final List<dynamic> riwayat = widget.loan['riwayat'] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tipe, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
              Text('$sudahBayar/$tenor Bulan', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(keterangan, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nominal Awal', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                      Text(Formatters.formatCurrency(nominal), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Sisa Tagihan', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                      Text(Formatters.formatCurrency(sisa), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                    ],
                  ),
                ],
              ),
            ],
          ),

          children: [
            Padding(
              padding: const EdgeInsets.only(left: 14, right: 14, bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 20, color: Color(0xFFE2E8F0)),
                  const Text(
                    'Detail Angsuran:',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 6),
                  ...riwayat.map((pb) {
                    final int angsuranKe = pb['angsuran_ke'] ?? 1;
                    final String status = pb['status'] ?? 'belum_bayar';
                    final int nominalPb = pb['nominal'] ?? 0;
                    final String? tglBayar = pb['tanggal_bayar'];
                    final String? bukti = pb['bukti_transfer'];
                    final bool isApproved = status == 'approved';

                    Color statusColor = const Color(0xFF94A3B8);
                    if (isApproved) statusColor = const Color(0xFF10B981);
                    if (status == 'pending') statusColor = const Color(0xFFF59E0B);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Angsuran Ke-$angsuranKe',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                              ),
                              if (isApproved && tglBayar != null)
                                Text(
                                  Formatters.formatDate(tglBayar),
                                  style: const TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8)),
                                ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                Formatters.formatCurrency(nominalPb).replaceAll('Rp ', ''),
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: 8),
                              if (isApproved || status == 'pending')
                                GestureDetector(
                                  onTap: () {
                                    _showProofPhotoDialog(context, bukti, widget.name, angsuranKe);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isApproved ? const Color(0xFFF0FDFA) : const Color(0xFFFFFBEB),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: isApproved ? const Color(0xFFCCFBF1) : const Color(0xFFFEF3C7)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.photo_library_outlined, 
                                          size: 11, 
                                          color: isApproved ? const Color(0xFF0F766E) : const Color(0xFFD97706)
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Bukti',
                                          style: TextStyle(
                                            fontSize: 9, 
                                            fontWeight: FontWeight.bold, 
                                            color: isApproved ? const Color(0xFF0F766E) : const Color(0xFFD97706)
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                Text(
                                  'BELUM BAYAR',
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: statusColor),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                  if (widget.loan['ttd_anggota'] != null || widget.loan['ttd_admin'] != null) ...[
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 12),
                    const Text(
                      'Persetujuan & Tanda Tangan:',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (widget.loan['ttd_anggota'] != null)
                          Expanded(
                            child: Column(
                              children: [
                                Container(
                                  height: 70,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: Image.network(
                                    widget.loan['ttd_anggota'].toString(),
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Center(child: Icon(Icons.broken_image, size: 20, color: Colors.grey)),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'TTD Anggota',
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                        if (widget.loan['ttd_anggota'] != null && widget.loan['ttd_admin'] != null)
                          const SizedBox(width: 12),
                        if (widget.loan['ttd_admin'] != null)
                          Expanded(
                            child: Column(
                              children: [
                                Container(
                                  height: 70,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: Image.network(
                                    widget.loan['ttd_admin'].toString(),
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Center(child: Icon(Icons.broken_image, size: 20, color: Colors.grey)),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'TTD Pengurus (Persetujuan)',
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
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
}
