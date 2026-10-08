<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Carbon\Carbon;

use App\Models\User;
use App\Models\Simpanan;
use App\Models\Pinjaman;
use App\Models\KreditBarang;
use App\Models\Pembayaran;
use App\Models\PengeluaranShu;

class ApiController extends Controller
{
    // ==========================================
    // AUTHENTICATION
    // ==========================================

    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|string',
            'password' => 'required|string',
        ]);

        $credentials = $request->only('email', 'password');

        // Attempt email login first
        if (!Auth::attempt($credentials)) {
            // Attempt NIK login
            $user = User::where('nik', $request->email)->first();
            if ($user && Hash::check($request->password, $user->password)) {
                Auth::login($user);
            } else {
                return response()->json([
                    'message' => 'Email/NIK atau password salah.'
                ], 422);
            }
        }

        $user = Auth::user();
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user' => $user,
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Berhasil keluar aplikasi.'
        ]);
    }

    public function profile(Request $request)
    {
        return response()->json($request->user());
    }

    public function updateProfile(Request $request)
    {
        $user = $request->user();

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users,email,' . $user->id,
            'no_hp' => 'nullable|string|max:20',
            'alamat' => 'nullable|string',
        ]);

        $user->update($validated);

        return response()->json([
            'message' => 'Profil berhasil diperbarui.',
            'user' => $user
        ]);
    }

    // ==========================================
    // DASHBOARD METRICS
    // ==========================================

    public function dashboard(Request $request)
    {
        $user = $request->user();
        $isPengurus = ($user->role === 'pengurus');

        if ($isPengurus) {
            // Global cooperative metrics for Pengurus
            $saldoSimpanan = Simpanan::where('status', 'approved')->sum('nominal_simpanan');
            $pinjamanAktif = Pinjaman::where('status', 'approved')->count();
            $kreditAktif = KreditBarang::where('status', 'approved')->count();

            // Total outstanding pinjaman global
            $totalSisaPinjaman = (int) Pinjaman::where('status', 'approved')->sum('sisa_pinjaman');

            // Total outstanding kredit global
            $kreditsGlobal = KreditBarang::where('status', 'approved')->get();
            $totalSisaKredit = 0;
            foreach ($kreditsGlobal as $kr) {
                $totalSisaKredit += $kr->sisa_kredit;
            }

            $totalOutstanding = $totalSisaPinjaman + $totalSisaKredit;

            $tagihanBulanIni = Pembayaran::where('status', 'belum_bayar')
                ->whereMonth('jatuh_tempo', now()->month)
                ->whereYear('jatuh_tempo', now()->year)
                ->sum('nominal');

            $totalTagihanBelumBayar = Pembayaran::where('status', 'belum_bayar')->sum('nominal');

            $totalPending = Simpanan::where('status', 'pending')->count() +
                            Pinjaman::where('status', 'pending')->count() +
                            KreditBarang::where('status', 'pending')->count() +
                            Pembayaran::where('status', 'pending')->count();

            return response()->json([
                'role' => 'pengurus',
                'saldoSimpanan' => (int) $saldoSimpanan,
                'pinjamanAktif' => $pinjamanAktif,
                'kreditAktif' => $kreditAktif,
                'tagihanBulanIni' => (int) $tagihanBulanIni,
                'totalTagihanBelumBayar' => (int) $totalTagihanBelumBayar,
                'totalPending' => $totalPending,
                'totalSisaPinjaman' => $totalSisaPinjaman,
                'totalSisaKredit' => $totalSisaKredit,
                'totalOutstanding' => $totalOutstanding,
            ]);
        } else {
            // Personal metrics for Member
            $saldoSimpanan = Simpanan::where('user_id', $user->id)
                ->where('status', 'approved')
                ->sum('nominal_simpanan');

            $pinjamanAktif = Pinjaman::where('user_id', $user->id)
                ->where('status', 'approved')
                ->count();

            $kreditAktif = KreditBarang::where('user_id', $user->id)
                ->where('status', 'approved')
                ->count();

            // Personal outstanding balances
            $totalSisaPinjaman = (int) Pinjaman::where('user_id', $user->id)
                ->where('status', 'approved')
                ->sum('sisa_pinjaman');

            $kredits = KreditBarang::where('user_id', $user->id)
                ->where('status', 'approved')
                ->get();
            $totalSisaKredit = 0;
            foreach ($kredits as $kr) {
                $totalSisaKredit += $kr->sisa_kredit;
            }

            $totalOutstanding = $totalSisaPinjaman + $totalSisaKredit;

            $tagihanBulanIni = Pembayaran::where('user_id', $user->id)
                ->where('status', 'belum_bayar')
                ->whereMonth('jatuh_tempo', now()->month)
                ->whereYear('jatuh_tempo', now()->year)
                ->sum('nominal');

            $totalTagihanBelumBayar = Pembayaran::where('user_id', $user->id)
                ->where('status', 'belum_bayar')
                ->sum('nominal');

            $totalPending = Pinjaman::where('user_id', $user->id)
                ->where('status', 'pending')
                ->count();

            $pinjamanTerakhir = Pinjaman::where('user_id', $user->id)
                ->latest()
                ->first();
            if ($pinjamanTerakhir) {
                $pinjamanTerakhir->bukti_transfer = $pinjamanTerakhir->bukti_transfer ? asset('storage/' . $pinjamanTerakhir->bukti_transfer) : null;
            }

            $kreditTerakhir = KreditBarang::where('user_id', $user->id)
                ->latest()
                ->first();
            if ($kreditTerakhir) {
                $kreditTerakhir->foto_barang = $kreditTerakhir->foto_barang ? asset('storage/' . $kreditTerakhir->foto_barang) : null;
            }

            return response()->json([
                'role' => 'anggota',
                'saldoSimpanan' => (int) $saldoSimpanan,
                'pinjamanAktif' => $pinjamanAktif,
                'kreditAktif' => $kreditAktif,
                'tagihanBulanIni' => (int) $tagihanBulanIni,
                'totalTagihanBelumBayar' => (int) $totalTagihanBelumBayar,
                'totalPending' => $totalPending,
                'pinjamanTerakhir' => $pinjamanTerakhir,
                'kreditTerakhir' => $kreditTerakhir,
                'totalSisaPinjaman' => $totalSisaPinjaman,
                'totalSisaKredit' => $totalSisaKredit,
                'totalOutstanding' => $totalOutstanding,
            ]);
        }
    }

    // ==========================================
    // SIMPANAN (SAVINGS)
    // ==========================================

    public function getSimpanan(Request $request)
    {
        $query = $request->user()->simpanan();

        if ($request->has('tahun') && $request->tahun !== 'Semua') {
            $query->where('tahun', $request->tahun);
        }

        $simpanan = $query->orderBy('tahun', 'desc')
            ->orderBy('bulan', 'desc')
            ->paginate(15);

        $simpanan->getCollection()->transform(function($s) {
            $s->bukti_transfer = $s->bukti_transfer ? asset('storage/' . $s->bukti_transfer) : null;
            return $s;
        });

        return response()->json($simpanan);
    }

    public function storeSimpanan(Request $request)
    {
        $userId = $request->user()->id;

        $cek = Simpanan::where('user_id', $userId)
            ->where('jenis', 'wajib')
            ->where('bulan', now()->month)
            ->where('tahun', now()->year)
            ->exists();

        if ($cek) {
            return response()->json([
                'message' => 'Simpanan wajib bulan ini sudah diajukan.'
            ], 422);
        }

        $request->validate([
            'tanggal_bayar' => ['required', 'date'],
            'bukti_transfer' => ['required', 'image', 'max:2048']
        ]);

        $path = $request->file('bukti_transfer')
            ->store('simpanan', 'public');

        $simpanan = Simpanan::create([
            'user_id' => $userId,
            'jenis' => 'wajib',
            'bulan' => now()->month,
            'tahun' => now()->year,
            'nominal_simpanan' => 100000,
            'nominal_admin' => 10000,
            'total_bayar' => 110000,
            'tanggal_bayar' => $request->tanggal_bayar,
            'bukti_transfer' => $path,
            'status' => 'pending'
        ]);

        $simpanan->bukti_transfer = asset('storage/' . $simpanan->bukti_transfer);

        return response()->json([
            'message' => 'Simpanan wajib berhasil diajukan.',
            'data' => $simpanan
        ]);
    }

    // ==========================================
    // PINJAMAN (LOANS)
    // ==========================================

    public function getPinjaman(Request $request)
    {
        $userId = $request->user()->id;

        $query = Pinjaman::where('user_id', $userId)
            ->with(['pembayaran' => function($q) {
                $q->where('source_type', 'pinjaman')->orderBy('angsuran_ke', 'asc');
            }]);

        if ($request->has('tahun') && $request->tahun !== 'Semua') {
            $query->whereYear('created_at', $request->tahun);
        }

        $pinjaman = $query->latest()->paginate(10);

        $pinjaman->getCollection()->transform(function($p) {
            $sudahBayarCount = $p->pembayaran->where('status', 'approved')->count();
            $p->sudah_bayar_count = $sudahBayarCount;
            $p->sisa_angsuran_count = max(0, $p->tenor_bulan - $sudahBayarCount);
            if ($p->ttd_anggota) {
                $p->ttd_anggota = asset('storage/' . $p->ttd_anggota);
            }
            if ($p->ttd_admin) {
                $p->ttd_admin = asset('storage/' . $p->ttd_admin);
            }
            return $p;
        });

        $totalPinjamanAktif = Pinjaman::where('user_id', $userId)
            ->where('status', 'approved')
            ->sum('total_pengembalian');

        $totalSisaPinjaman = Pinjaman::where('user_id', $userId)
            ->where('status', 'approved')
            ->sum('sisa_pinjaman');

        $totalPending = Pinjaman::where('user_id', $userId)
            ->where('status', 'pending')
            ->count();

        $activePinjamanCount = Pinjaman::where('user_id', $userId)
            ->whereIn('status', ['pending', 'approved'])
            ->count();

        $activeKreditCount = KreditBarang::where('user_id', $userId)
            ->whereIn('status', ['pending', 'approved'])
            ->count();

        $bolehAjukan = ($activePinjamanCount + $activeKreditCount) < 2;

        return response()->json([
            'pinjaman' => $pinjaman,
            'totalPinjamanAktif' => (int) $totalPinjamanAktif,
            'totalSisaPinjaman' => (int) $totalSisaPinjaman,
            'totalPending' => $totalPending,
            'bolehAjukan' => $bolehAjukan
        ]);
    }

    public function storePinjaman(Request $request)
    {
        $userId = $request->user()->id;

        $activePinjamanCount = Pinjaman::where('user_id', $userId)
            ->whereIn('status', ['pending', 'approved'])
            ->count();

        $activeKreditCount = KreditBarang::where('user_id', $userId)
            ->whereIn('status', ['pending', 'approved'])
            ->count();

        if (($activePinjamanCount + $activeKreditCount) >= 2) {
            return response()->json([
                'message' => 'Anda sudah memiliki 2 pinjaman atau kredit aktif (pending atau approved).'
            ], 422);
        }

        $request->validate([
            'nominal' => ['required', 'numeric', 'min:100000'],
            'tenor_bulan' => ['required', 'integer', 'min:1', 'max:12'],
            'ttd_anggota' => ['required', 'image', 'max:2048'],
        ]);

        $nominal = $request->nominal;
        $tenor = $request->tenor_bulan;

        // Bunga 10% flat
        $bunga = 10;
        $nominalBunga = ($nominal * $bunga) / 100;
        $totalPengembalian = $nominal + $nominalBunga;
        $angsuranPerBulan = round($totalPengembalian / $tenor);

        $ttdPath = $request->file('ttd_anggota')->store('ttd', 'public');

        $pinjaman = Pinjaman::create([
            'user_id' => $userId,
            'sumber_id' => null,
            'tipe' => 'uang',
            'nominal' => $nominal,
            'persen_bunga' => $bunga,
            'nominal_bunga' => $nominalBunga,
            'total_pengembalian' => $totalPengembalian,
            'tenor_bulan' => $tenor,
            'angsuran_per_bulan' => $angsuranPerBulan,
            'sisa_pinjaman' => $totalPengembalian,
            'status' => 'pending',
            'ttd_anggota' => $ttdPath,
        ]);

        return response()->json([
            'message' => 'Pengajuan pinjaman berhasil dikirim dan menunggu persetujuan.',
            'data' => $pinjaman
        ]);
    }

    public function simulasiPinjaman(Request $request)
    {
        $request->validate([
            'nominal' => ['required', 'numeric', 'min:100000'],
            'tenor_bulan' => ['required', 'integer', 'min:1', 'max:12'],
        ]);

        $nominal = $request->nominal;
        $tenor = $request->tenor_bulan;

        $bunga = 10;
        $nominalBunga = ($nominal * $bunga) / 100;
        $totalPengembalian = $nominal + $nominalBunga;
        $angsuranPerBulan = round($totalPengembalian / $tenor);

        return response()->json([
            'nominal' => (int) $nominal,
            'tenor_bulan' => (int) $tenor,
            'persen_bunga' => $bunga,
            'nominal_bunga' => (int) $nominalBunga,
            'total_pengembalian' => (int) $totalPengembalian,
            'angsuran_per_bulan' => (int) $angsuranPerBulan,
        ]);
    }

    public function simulasiKredit(Request $request)
    {
        $request->validate([
            'harga' => ['required', 'numeric', 'min:100000'],
            'tenor_bulan' => ['required', 'integer', 'min:1', 'max:12'],
        ]);

        $nominal = $request->harga;
        $tenor = $request->tenor_bulan;

        $bunga = 10;
        $nominalBunga = ($nominal * $bunga) / 100;
        $totalPengembalian = $nominal + $nominalBunga;
        $angsuranPerBulan = round($totalPengembalian / $tenor);

        return response()->json([
            'harga' => (int) $nominal,
            'tenor_bulan' => (int) $tenor,
            'persen_bunga' => $bunga,
            'nominal_bunga' => (int) $nominalBunga,
            'total_pengembalian' => (int) $totalPengembalian,
            'angsuran_per_bulan' => (int) $angsuranPerBulan,
        ]);
    }

    // ==========================================
    // KREDIT BARANG (GOODS CREDIT)
    // ==========================================

    public function getKreditBarang(Request $request)
    {
        $userId = $request->user()->id;

        $kreditBarang = KreditBarang::where('user_id', $userId)
            ->with(['pembayaran' => function($q) {
                $q->where('source_type', 'kredit_barang')->orderBy('angsuran_ke', 'asc');
            }])
            ->latest()
            ->paginate(10);

        $kreditBarang->getCollection()->transform(function($kb) {
            $kb->foto_barang = $kb->foto_barang ? asset('storage/' . $kb->foto_barang) : null;
            $sudahBayarCount = $kb->pembayaran->where('status', 'approved')->count();
            $kb->sudah_bayar_count = $sudahBayarCount;
            $kb->sisa_angsuran_count = max(0, $kb->tenor_bulan - $sudahBayarCount);
            if ($kb->ttd_anggota) {
                $kb->ttd_anggota = asset('storage/' . $kb->ttd_anggota);
            }
            if ($kb->ttd_admin) {
                $kb->ttd_admin = asset('storage/' . $kb->ttd_admin);
            }
            return $kb;
        });

        $activePinjamanCount = Pinjaman::where('user_id', $userId)
            ->whereIn('status', ['pending', 'approved'])
            ->count();

        $activeKreditCount = KreditBarang::where('user_id', $userId)
            ->whereIn('status', ['pending', 'approved'])
            ->count();

        $bolehAjukan = ($activePinjamanCount + $activeKreditCount) < 2;

        return response()->json([
            'kreditBarang' => $kreditBarang,
            'bolehAjukan' => $bolehAjukan
        ]);
    }

    public function storeKreditBarang(Request $request)
    {
        $userId = $request->user()->id;

        $activePinjamanCount = Pinjaman::where('user_id', $userId)
            ->whereIn('status', ['pending', 'approved'])
            ->count();

        $activeKreditCount = KreditBarang::where('user_id', $userId)
            ->whereIn('status', ['pending', 'approved'])
            ->count();

        if (($activePinjamanCount + $activeKreditCount) >= 2) {
            return response()->json([
                'message' => 'Anda sudah memiliki 2 pinjaman atau kredit aktif (pending atau approved).'
            ], 422);
        }

        $request->validate([
            'nama_barang' => 'required|string|max:255',
            'harga_barang' => 'required|numeric|min:1000',
            'tenor_bulan' => 'required|integer|min:1|max:12',
            'foto_barang' => 'nullable|image|max:2048',
            'keterangan' => 'nullable|string',
            'ttd_anggota' => 'required|image|max:2048',
        ]);

        $harga = $request->harga_barang;
        $bunga = 10;
        $nominalBunga = ($harga * $bunga) / 100;
        $totalTagihan = $harga + $nominalBunga;
        $angsuran = round($totalTagihan / $request->tenor_bulan);

        $fotoPath = null;
        if ($request->hasFile('foto_barang')) {
            $fotoPath = $request->file('foto_barang')->store('kredit', 'public');
        }

        $ttdPath = $request->file('ttd_anggota')->store('ttd', 'public');

        $kredit = KreditBarang::create([
            'user_id' => $userId,
            'nama_barang' => $request->nama_barang,
            'harga_barang' => $harga,
            'tenor_bulan' => $request->tenor_bulan,
            'persen_bunga' => $bunga,
            'nominal_bunga' => $nominalBunga,
            'total_tagihan' => $totalTagihan,
            'angsuran_per_bulan' => $angsuran,
            'foto_barang' => $fotoPath,
            'keterangan' => $request->keterangan,
            'status' => 'pending',
            'ttd_anggota' => $ttdPath,
        ]);

        if ($kredit->foto_barang) {
            $kredit->foto_barang = asset('storage/' . $kredit->foto_barang);
        }

        return response()->json([
            'message' => 'Pengajuan kredit barang berhasil dikirim!',
            'data' => $kredit
        ]);
    }

    // ==========================================
    // PEMBAYARAN / TAGIHAN (PAYMENTS / BILLS)
    // ==========================================

    public function getPembayaran(Request $request)
    {
        $userId = $request->user()->id;

        // Get all unique packages
        $uniquePackages = Pembayaran::where('user_id', $userId)
            ->select('source_type', 'source_id')
            ->groupBy('source_type', 'source_id')
            ->get();

        // Identify active packages (packages with at least one unpaid, pending, or rejected installment)
        $activePackages = [];
        foreach ($uniquePackages as $pkg) {
            $hasUnpaid = Pembayaran::where('user_id', $userId)
                ->where('source_type', $pkg->source_type)
                ->where('source_id', $pkg->source_id)
                ->whereIn('status', ['belum_bayar', 'pending', 'rejected'])
                ->exists();
            if ($hasUnpaid) {
                $activePackages[] = [
                    'source_type' => $pkg->source_type,
                    'source_id' => $pkg->source_id,
                ];
            }
        }

        if (empty($activePackages)) {
            $totalPembayaran = 0;
            $belumBayar = 0;
            $pending = 0;
            $lunas = 0;
            $totalTagihan = 0;
            $totalNominalPinjaman = 0;
            $persentaseLunas = 0;
        } else {
            $activeQuery = Pembayaran::where('user_id', $userId)
                ->where(function($q) use ($activePackages) {
                    foreach ($activePackages as $pkg) {
                        $q->orWhere(function($sub) use ($pkg) {
                            $sub->where('source_type', $pkg['source_type'])
                                ->where('source_id', $pkg['source_id']);
                        });
                    }
                });

            $activePembayaran = $activeQuery->get();
            $totalPembayaran = $activePembayaran->count();
            $belumBayar = $activePembayaran->where('status', 'belum_bayar')->count();
            $pending = $activePembayaran->where('status', 'pending')->count();
            $lunas = $activePembayaran->where('status', 'approved')->count();
            $totalTagihan = $activePembayaran->whereIn('status', ['belum_bayar', 'rejected'])->sum('nominal');
            $totalNominalPinjaman = $activePembayaran->sum('nominal');
            $persentaseLunas = $totalPembayaran > 0 ? round(($lunas / $totalPembayaran) * 100) : 0;
        }

        $uniqueSources = Pembayaran::where('user_id', $userId)
            ->where(function($q) use ($activePackages) {
                if (empty($activePackages)) {
                    $q->whereRaw('1 = 0');
                } else {
                    foreach ($activePackages as $pkg) {
                        $q->orWhere(function($sub) use ($pkg) {
                            $sub->where('source_type', $pkg['source_type'])
                                ->where('source_id', $pkg['source_id']);
                        });
                    }
                }
            })
            ->select('source_type', 'source_id')
            ->selectRaw('MAX(id) as max_id')
            ->groupBy('source_type', 'source_id')
            ->orderBy('max_id', 'desc')
            ->get();

        $groupedList = [];
        foreach ($uniqueSources as $src) {
            $items = Pembayaran::with(['pinjaman', 'kreditBarang'])
                ->where('user_id', $userId)
                ->where('source_type', $src->source_type)
                ->where('source_id', $src->source_id)
                ->whereIn('status', ['belum_bayar', 'pending', 'rejected'])
                ->orderByRaw("
                    CASE
                        WHEN status = 'belum_bayar' THEN 1
                        WHEN status = 'pending' THEN 2
                        WHEN status = 'rejected' THEN 3
                    END
                ")
                ->orderBy('jatuh_tempo')
                ->get();

            // Format image URLs and relations
            $items->transform(function($p) {
                $p->bukti_transfer = $p->bukti_transfer ? asset('storage/' . $p->bukti_transfer) : null;
                if ($p->source_type === 'kredit_barang' && $p->kreditBarang) {
                    $p->kreditBarang->foto_barang = $p->kreditBarang->foto_barang ? asset('storage/' . $p->kreditBarang->foto_barang) : null;
                }
                return $p;
            });

            $title = $src->source_type === 'pinjaman'
                ? 'Pinjaman Tunai Rp ' . number_format($items->first()->pinjaman->nominal ?? 0, 0, ',', '.')
                : 'Kredit ' . ($items->first()->kreditBarang->nama_barang ?? 'Barang');

            $groupedList[] = [
                'source_type' => $src->source_type,
                'source_id' => $src->source_id,
                'title' => $title,
                'items' => $items
            ];
        }

        return response()->json([
            'totalPembayaran' => $totalPembayaran,
            'belumBayar' => $belumBayar,
            'pending' => $pending,
            'lunas' => $lunas,
            'totalTagihan' => (int) $totalTagihan,
            'totalNominalPinjaman' => (int) $totalNominalPinjaman,
            'persentaseLunas' => $persentaseLunas,
            'groupedPembayaran' => $groupedList
        ]);
    }

    public function storeBayarPembayaran(Request $request, $id)
    {
        $userId = $request->user()->id;
        $pembayaran = Pembayaran::findOrFail($id);

        if ($pembayaran->user_id !== $userId) {
            return response()->json(['message' => 'Akses ditolak.'], 403);
        }

        if (!in_array($pembayaran->status, ['belum_bayar', 'rejected'])) {
            return response()->json([
                'message' => 'Tagihan ini tidak dalam status belum dibayar.'
            ], 422);
        }

        $request->validate([
            'tanggal_bayar'   => 'required|date',
            'bukti_transfer'  => 'required|image|max:2048',
        ]);

        $path = $request->file('bukti_transfer')
            ->store('pembayaran', 'public');

        $pembayaran->update([
            'tanggal_bayar'  => $request->tanggal_bayar,
            'bukti_transfer' => $path,
            'status'         => 'pending',
        ]);

        $pembayaran->bukti_transfer = asset('storage/' . $pembayaran->bukti_transfer);

        return response()->json([
            'message' => 'Bukti pembayaran berhasil diupload.',
            'data' => $pembayaran
        ]);
    }

    // ==========================================
    // PENGURUS (ADMIN) - MEMBERS
    // ==========================================

    public function getAnggota(Request $request)
    {
        $query = User::where('role', 'anggota');

        if ($request->search) {
            $query->where(function ($q) use ($request) {
                $q->where('name', 'like', "%{$request->search}%")
                  ->orWhere('email', 'like', "%{$request->search}%");
            });
        }

        if ($request->status && in_array($request->status, ['aktif', 'nonaktif'])) {
            $query->where('status', $request->status);
        }

        $anggota = $query->orderByRaw("CASE WHEN status = 'aktif' THEN 0 ELSE 1 END ASC")
            ->latest()
            ->paginate(15);

        $anggota->getCollection()->transform(function ($u) {
            $sisaPinjaman = (int) Pinjaman::where('user_id', $u->id)
                ->whereIn('status', ['pending', 'approved'])
                ->sum('sisa_pinjaman');

            $kredits = KreditBarang::where('user_id', $u->id)
                ->whereIn('status', ['pending', 'approved'])
                ->get();
            $sisaKredit = 0;
            foreach ($kredits as $kr) {
                $sisaKredit += $kr->sisa_kredit;
            }

            $u->total_pinjaman = $sisaPinjaman + $sisaKredit;

            $u->total_simpanan = (int) Simpanan::where('user_id', $u->id)
                ->where('status', 'approved')
                ->sum('nominal_simpanan');

            return $u;
        });

        return response()->json($anggota);
    }

    public function getAnggotaDetail($id)
    {
        $user = User::findOrFail($id);

        $sisaPinjaman = (int) Pinjaman::where('user_id', $id)
            ->whereIn('status', ['pending', 'approved'])
            ->sum('sisa_pinjaman');

        $kredits = KreditBarang::where('user_id', $id)
            ->whereIn('status', ['pending', 'approved'])
            ->get();
        $sisaKredit = 0;
        foreach ($kredits as $kr) {
            $sisaKredit += $kr->sisa_kredit;
        }

        $user->total_pinjaman = $sisaPinjaman + $sisaKredit;

        $user->total_simpanan = (int) Simpanan::where('user_id', $id)
            ->where('status', 'approved')
            ->sum('nominal_simpanan');

        $simpanan = Simpanan::where('user_id', $id)
            ->orderBy('tahun', 'desc')
            ->orderBy('bulan', 'desc')
            ->get();
        $simpanan->transform(function($s) {
            $s->bukti_transfer = $s->bukti_transfer ? asset('storage/' . $s->bukti_transfer) : null;
            $s->total_bayar = (int) $s->nominal_simpanan; // alias untuk Flutter
            return $s;
        });

        $pinjaman = Pinjaman::where('user_id', $id)
            ->with(['pembayaran' => function($q) {
                $q->where('source_type', 'pinjaman')->orderBy('angsuran_ke', 'asc');
            }])
            ->latest()
            ->get();

        $pinjaman->transform(function($p) {
            $sudahBayarCount = $p->pembayaran->where('status', 'approved')->count();
            $p->sudah_bayar_count = $sudahBayarCount;
            $p->sisa_angsuran_count = max(0, $p->tenor_bulan - $sudahBayarCount);
            $p->sisa_pinjaman_real = (int) $p->sisa_pinjaman;
            if ($p->ttd_anggota) {
                $p->ttd_anggota = asset('storage/' . $p->ttd_anggota);
            }
            if ($p->ttd_admin) {
                $p->ttd_admin = asset('storage/' . $p->ttd_admin);
            }
            return $p;
        });

        return response()->json([
            'user' => $user,
            'simpanan' => $simpanan,
            'pinjaman' => $pinjaman
        ]);
    }

    public function storeAnggota(Request $request)
    {
        $request->validate([
            'nik' => 'nullable|string|max:50',
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'no_hp' => 'nullable|string|max:20',
            'alamat' => 'nullable|string',
            'status' => 'nullable|string|max:50',
            'tanggal_gabung' => 'nullable|date',
            'password' => 'required|string|min:6',
        ]);

        $user = User::create([
            'nik' => $request->nik,
            'name' => $request->name,
            'email' => $request->email,
            'no_hp' => $request->no_hp,
            'alamat' => $request->alamat,
            'role' => 'anggota',
            'status' => $request->status ?? 'aktif',
            'tanggal_gabung' => $request->tanggal_gabung ?? now()->toDateString(),
            'password' => Hash::make($request->password),
        ]);

        return response()->json([
            'message' => 'Anggota berhasil ditambahkan.',
            'user' => $user
        ], 201);
    }

    public function updateAnggota(Request $request, $id)
    {
        $user = User::findOrFail($id);

        $request->validate([
            'nik' => 'nullable|string|max:50',
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users,email,' . $id,
            'no_hp' => 'nullable|string|max:20',
            'alamat' => 'nullable|string',
            'status' => 'nullable|string|max:50',
            'tanggal_gabung' => 'nullable|date',
            'password' => 'nullable|string|min:6',
        ]);

        $data = [
            'nik' => $request->nik,
            'name' => $request->name,
            'email' => $request->email,
            'no_hp' => $request->no_hp,
            'alamat' => $request->alamat,
            'status' => $request->status ?? $user->status,
            'tanggal_gabung' => $request->tanggal_gabung ?? $user->tanggal_gabung,
        ];

        if ($request->filled('password')) {
            $data['password'] = Hash::make($request->password);
        }

        $user->update($data);

        return response()->json([
            'message' => 'Data anggota berhasil diupdate.',
            'user' => $user
        ]);
    }

    public function destroyAnggota($id)
    {
        $user = User::findOrFail($id);

        $hasLoans = Pinjaman::where('user_id', $id)->exists();
        $hasSavings = Simpanan::where('user_id', $id)->exists();

        if ($hasLoans || $hasSavings) {
            return response()->json([
                'message' => 'Gagal menghapus. Anggota ini memiliki riwayat pinjaman atau simpanan.'
            ], 400);
        }

        $user->delete();

        return response()->json([
            'message' => 'Anggota berhasil dihapus.'
        ]);
    }

    // ==========================================
    // PENGURUS (ADMIN) - FINANCIAL REPORTS
    // ==========================================

    public function getLaporan()
    {
        // 1. Income (Simpanan + Pembayaran)
        $totalSimpananMasuk = Simpanan::where('status', 'approved')->sum('total_bayar');
        $totalAngsuranMasuk = Pembayaran::where('status', 'approved')->sum('nominal');
        $totalPemasukan = $totalSimpananMasuk + $totalAngsuranMasuk;

        // 2. Expenses (Pinjaman + Kredit + SHU)
        $totalPinjamanKeluar = Pinjaman::where('status', 'approved')->sum('nominal');
        $totalKreditKeluar = KreditBarang::where('status', 'approved')->sum('harga_barang');
        $totalShuKeluar = PengeluaranShu::sum('nominal');
        $totalPengeluaran = $totalPinjamanKeluar + $totalKreditKeluar + $totalShuKeluar;

        // 3. Current net cash
        $saldoKas = $totalPemasukan - $totalPengeluaran;

        // 4. Global members savings
        $saldoSimpananGlobal = Simpanan::where('status', 'approved')->sum('nominal_simpanan');

        // 5. Total outstanding debts
        $outstandingPinjaman = Pinjaman::where('status', 'approved')->sum('sisa_pinjaman');

        $kreditList = KreditBarang::where('status', 'approved')->get();
        $outstandingKredit = 0;
        foreach ($kreditList as $kredit) {
            $sudahBayar = Pembayaran::where('source_type', 'kredit_barang')
                ->where('source_id', $kredit->id)
                ->where('status', 'approved')
                ->sum('nominal');
            $outstandingKredit += max(0, $kredit->total_tagihan - $sudahBayar);
        }
        $totalOutstanding = $outstandingPinjaman + $outstandingKredit;

        return response()->json([
            'totalPemasukan' => (int) $totalPemasukan,
            'totalPengeluaran' => (int) $totalPengeluaran,
            'saldoKas' => (int) $saldoKas,
            'saldoSimpananGlobal' => (int) $saldoSimpananGlobal,
            'totalOutstanding' => (int) $totalOutstanding
        ]);
    }

    public function getLaporanDetail(Request $request, $type)
    {
        if (!in_array($type, ['pemasukan', 'pengeluaran', 'saldo_anggota', 'pinjaman_anggota', 'pinjaman_berjalan', 'tunggakan_simpanan'])) {
            return response()->json(['message' => 'Tipe laporan tidak valid.'], 400);
        }

        switch ($type) {
            case 'pemasukan':
                $data = $this->getPemasukanLaporan();
                break;
            case 'pengeluaran':
                $data = $this->getPengeluaranLaporan();
                break;
            case 'saldo_anggota':
                $data = $this->getSaldoAnggotaLaporan();
                break;
            case 'pinjaman_anggota':
                $data = $this->getPinjamanAnggotaLaporan();
                break;
            case 'pinjaman_berjalan':
                $data = $this->getPinjamanBerjalanLaporan();
                break;
            case 'tunggakan_simpanan':
                $data = $this->getTunggakanSimpananLaporan();
                break;
            default:
                $data = [];
        }

        return response()->json($data);
    }

    private function getPemasukanLaporan()
    {
        // Get Simpanan approved
        $simpanan = Simpanan::with('user')->where('status', 'approved')->get()->map(function (Simpanan $s) {
            return [
                'tanggal' => optional($s->tanggal_bayar)->format('Y-m-d') ?? $s->created_at->format('Y-m-d'),
                'anggota' => optional($s->user)->name ?? '-',
                'jenis' => 'Simpanan Wajib',
                'keterangan' => 'Setoran wajib simpanan bulanan',
                'nominal' => (int) $s->total_bayar
            ];
        });

        // Get Pembayaran approved
        $pembayaran = Pembayaran::with(['pinjaman.user', 'kreditBarang.user'])->where('status', 'approved')->get()->map(function (Pembayaran $p) {
            $name = '-';
            if ($p->source_type === 'pinjaman' && $p->pinjaman) {
                $name = optional($p->pinjaman->user)->name ?? '-';
            } elseif ($p->source_type === 'kredit_barang' && $p->kreditBarang) {
                $name = optional($p->kreditBarang->user)->name ?? '-';
            }
            return [
                'tanggal' => optional($p->tanggal_bayar)->format('Y-m-d') ?? $p->created_at->format('Y-m-d'),
                'anggota' => $name,
                'jenis' => 'Angsuran',
                'keterangan' => 'Pembayaran cicilan ' . str_replace('_', ' ', $p->source_type) . ' ke-' . $p->angsuran_ke,
                'nominal' => (int) $p->nominal
            ];
        });

        return $simpanan->merge($pembayaran)->sortByDesc('tanggal')->values();
    }

    private function getPengeluaranLaporan()
    {
        // Get Pinjaman approved
        $pinjaman = Pinjaman::with('user')->where('status', 'approved')->get()->map(function (Pinjaman $p) {
            return [
                'tanggal' => $p->created_at->format('Y-m-d'),
                'anggota' => optional($p->user)->name ?? '-',
                'jenis' => 'Pencairan Pinjaman',
                'keterangan' => 'Pencairan pinjaman tenor ' . $p->tenor_bulan . ' bulan',
                'nominal' => (int) $p->nominal
            ];
        });

        // Get KreditBarang approved
        $kredit = KreditBarang::with('user')->where('status', 'approved')->get()->map(function (KreditBarang $k) {
            return [
                'tanggal' => $k->created_at->format('Y-m-d'),
                'anggota' => optional($k->user)->name ?? '-',
                'jenis' => 'Pengadaan Kredit Barang',
                'keterangan' => 'Kredit barang: ' . $k->nama_barang,
                'nominal' => (int) $k->harga_barang
            ];
        });

        // Get SHU
        $shus = PengeluaranShu::with('user')->get()->map(function (PengeluaranShu $sh) {
            return [
                'tanggal' => Carbon::parse($sh->tanggal)->format('Y-m-d'),
                'anggota' => optional($sh->user)->name ?? '-',
                'jenis' => 'Pengeluaran SHU',
                'keterangan' => $sh->keterangan,
                'nominal' => (int) $sh->nominal
            ];
        });

        return $pinjaman->merge($kredit)->merge($shus)->sortByDesc('tanggal')->values();
    }

    private function getSaldoAnggotaLaporan()
    {
        return User::where('role', 'anggota')->get()->map(function (User $u) {
            $totalSimpanan = Simpanan::where('user_id', $u->id)->where('status', 'approved')->sum('nominal_simpanan');
            return [
                'nik' => $u->nik,
                'name' => $u->name,
                'email' => $u->email,
                'total_simpanan' => (int) $totalSimpanan
            ];
        })->sortByDesc('total_simpanan')->values();
    }

    private function getPinjamanAnggotaLaporan()
    {
        return User::where('role', 'anggota')->get()->map(function (User $u) {
            $totalPinjaman = Pinjaman::where('user_id', $u->id)->where('status', 'approved')->sum('nominal');
            $sisaPinjaman = Pinjaman::where('user_id', $u->id)->where('status', 'approved')->sum('sisa_pinjaman');
            $totalKredit = KreditBarang::where('user_id', $u->id)->where('status', 'approved')->sum('total_tagihan');
            
            $kredits = KreditBarang::where('user_id', $u->id)->where('status', 'approved')->get();
            $sisaKredit = 0;
            foreach ($kredits as $kr) {
                $sudahBayar = Pembayaran::where('source_type', 'kredit_barang')
                    ->where('source_id', $kr->id)
                    ->where('status', 'approved')
                    ->sum('nominal');
                $sisaKredit += max(0, $kr->total_tagihan - $sudahBayar);
            }

            return [
                'nik' => $u->nik,
                'name' => $u->name,
                'total_pinjaman' => (int) ($totalPinjaman + $totalKredit),
                'sisa_pinjaman' => (int) ($sisaPinjaman + $sisaKredit)
            ];
        })->sortByDesc('sisa_pinjaman')->values();
    }

    private function getPinjamanBerjalanLaporan()
    {
        return User::where('role', 'anggota')
            ->where('status', 'aktif')
            ->get()
            ->map(function (User $u) {
                // Pinjaman aktif (sisa_pinjaman > 0)
                $pinjamans = Pinjaman::where('user_id', $u->id)
                    ->where('status', 'approved')
                    ->where('sisa_pinjaman', '>', 0)
                    ->get()
                    ->map(function ($p) {
                        $pembayaran = Pembayaran::where('source_type', 'pinjaman')
                            ->where('source_id', $p->id)
                            ->orderBy('angsuran_ke', 'asc')
                            ->get()
                            ->map(function ($pb) {
                                return [
                                    'angsuran_ke' => $pb->angsuran_ke,
                                    'status' => $pb->status,
                                    'nominal' => (int) $pb->nominal,
                                    'tanggal_bayar' => $pb->tanggal_bayar ? (is_string($pb->tanggal_bayar) ? explode(' ', $pb->tanggal_bayar)[0] : $pb->tanggal_bayar->format('Y-m-d')) : null,
                                    'bukti_transfer' => $pb->bukti_transfer ? asset('storage/' . $pb->bukti_transfer) : null
                                ];
                            });

                        $sudahBayarCount = $pembayaran->where('status', 'approved')->count();

                        return [
                            'tipe' => 'Pinjaman Tunai',
                            'keterangan' => $p->keterangan ?? 'Pinjaman',
                            'nominal' => (int) $p->nominal,
                            'sisa' => (int) $p->sisa_pinjaman,
                            'tenor' => $p->tenor_bulan,
                            'sudah_bayar' => $sudahBayarCount,
                            'riwayat' => $pembayaran,
                            'ttd_anggota' => $p->ttd_anggota ? asset('storage/' . $p->ttd_anggota) : null,
                            'ttd_admin' => $p->ttd_admin ? asset('storage/' . $p->ttd_admin) : null,
                        ];
                    });

                // Kredit aktif (sisa > 0)
                $kredits = KreditBarang::where('user_id', $u->id)
                    ->where('status', 'approved')
                    ->get()
                    ->map(function ($k) {
                        $pembayaran = Pembayaran::where('source_type', 'kredit_barang')
                            ->where('source_id', $k->id)
                            ->orderBy('angsuran_ke', 'asc')
                            ->get()
                            ->map(function ($pb) {
                                return [
                                    'angsuran_ke' => $pb->angsuran_ke,
                                    'status' => $pb->status,
                                    'nominal' => (int) $pb->nominal,
                                    'tanggal_bayar' => $pb->tanggal_bayar ? (is_string($pb->tanggal_bayar) ? explode(' ', $pb->tanggal_bayar)[0] : $pb->tanggal_bayar->format('Y-m-d')) : null,
                                    'bukti_transfer' => $pb->bukti_transfer ? asset('storage/' . $pb->bukti_transfer) : null
                                ];
                            });

                        $sudahBayar = $pembayaran->where('status', 'approved')->sum('nominal');
                        $sisa = max(0, $k->total_tagihan - $sudahBayar);
                        $sudahBayarCount = $pembayaran->where('status', 'approved')->count();

                        return [
                            'tipe' => 'Kredit Barang',
                            'keterangan' => 'Kredit: ' . $k->nama_barang,
                            'nominal' => (int) $k->total_tagihan,
                            'sisa' => (int) $sisa,
                            'tenor' => $k->tenor_bulan,
                            'sudah_bayar' => $sudahBayarCount,
                            'riwayat' => $pembayaran,
                            'ttd_anggota' => $k->ttd_anggota ? asset('storage/' . $k->ttd_anggota) : null,
                            'ttd_admin' => $k->ttd_admin ? asset('storage/' . $k->ttd_admin) : null,
                        ];
                    })->filter(function ($k) {
                        return $k['sisa'] > 0;
                    })->values();

                $allActive = $pinjamans->merge($kredits);

                if ($allActive->isEmpty()) {
                    return null;
                }

                return [
                    'nik' => $u->nik,
                    'name' => $u->name,
                    'active_loans' => $allActive
                ];
            })
            ->filter()
            ->values();
    }

    private function getTunggakanSimpananLaporan()
    {
        $currentYear = 2026;
        $monthsName = [
            1 => 'Januari', 2 => 'Februari', 3 => 'Maret', 4 => 'April',
            5 => 'Mei', 6 => 'Juni', 7 => 'Juli', 8 => 'Agustus',
            9 => 'September', 10 => 'Oktober', 11 => 'November', 12 => 'Desember'
        ];

        return User::where('role', 'anggota')
            ->where('status', 'aktif')
            ->get()
            ->map(function (User $u) use ($currentYear, $monthsName) {
                $tunggakanBulan = [];
                
                // Cek dari bulan 1 sampai 8 (Agustus 2026, periode saat ini)
                for ($m = 1; $m <= 8; $m++) {
                    $hasPaid = Simpanan::where('user_id', $u->id)
                        ->where('tipe', 'wajib')
                        ->where('status', 'approved')
                        ->where('bulan', $m)
                        ->where('tahun', $currentYear)
                        ->exists();

                    if (!$hasPaid) {
                        $tunggakanBulan[] = [
                            'id' => $m,
                            'nama' => $monthsName[$m]
                        ];
                    }
                }

                if (empty($tunggakanBulan)) {
                    return null;
                }

                return [
                    'nik' => $u->nik,
                    'name' => $u->name,
                    'tahun' => $currentYear,
                    'tunggakan' => $tunggakanBulan,
                    'total_tunggakan' => count($tunggakanBulan) * 100000
                ];
            })
            ->filter()
            ->values();
    }

    // ==========================================
    // PENGURUS (ADMIN) - SHU
    // ==========================================

    private function getSaldoKas()
    {
        $totalSimpananMasuk = Simpanan::where('status', 'approved')->sum('total_bayar');
        $totalAngsuranMasuk = Pembayaran::where('status', 'approved')->sum('nominal');
        $totalPemasukan = $totalSimpananMasuk + $totalAngsuranMasuk;

        $totalPinjamanKeluar = Pinjaman::where('status', 'approved')->sum('nominal');
        $totalKreditKeluar = KreditBarang::where('status', 'approved')->sum('harga_barang');
        $totalShuKeluar = PengeluaranShu::sum('nominal');
        $totalPengeluaran = $totalPinjamanKeluar + $totalKreditKeluar + $totalShuKeluar;

        return $totalPemasukan - $totalPengeluaran;
    }

    public function getShu()
    {
        $shus = PengeluaranShu::with('user')
            ->latest()
            ->paginate(15);

        $saldoKas = $this->getSaldoKas();

        return response()->json([
            'saldoKas' => (int) $saldoKas,
            'shus' => $shus
        ]);
    }

    public function storeShu(Request $request)
    {
        $request->validate([
            'nominal' => 'required|numeric|min:1000',
            'tanggal' => 'required|date',
            'keterangan' => 'required|string|max:255',
        ]);

        $saldoKas = $this->getSaldoKas();
        if ($request->nominal > $saldoKas) {
            return response()->json([
                'message' => 'Nominal pengeluaran SHU melebihi saldo kas koperasi saat ini.'
            ], 422);
        }

        $shu = PengeluaranShu::create([
            'nominal' => $request->nominal,
            'tanggal' => $request->tanggal,
            'keterangan' => $request->keterangan,
            'user_id' => $request->user()->id,
        ]);

        return response()->json([
            'message' => 'Pengeluaran SHU berhasil dicatat.',
            'data' => $shu
        ]);
    }

    public function destroyShu($id)
    {
        $shu = PengeluaranShu::findOrFail($id);
        $shu->delete();

        return response()->json([
            'message' => 'Catatan pengeluaran SHU berhasil dihapus.'
        ]);
    }

    // ==========================================
    // PENGURUS (ADMIN) - APPROVALS MANAGER
    // ==========================================

    public function getPendingApprovals()
    {
        $simpanan = Simpanan::with('user')
            ->where('status', 'pending')
            ->latest()
            ->get();
        $simpanan->transform(function($s) {
            $s->bukti_transfer = $s->bukti_transfer ? asset('storage/' . $s->bukti_transfer) : null;
            return $s;
        });

        $pinjaman = Pinjaman::with('user')
            ->where('status', 'pending')
            ->latest()
            ->get();
        $pinjaman->transform(function($p) {
            if ($p->ttd_anggota) {
                $p->ttd_anggota = asset('storage/' . $p->ttd_anggota);
            }
            if ($p->ttd_admin) {
                $p->ttd_admin = asset('storage/' . $p->ttd_admin);
            }
            return $p;
        });

        $kreditBarang = KreditBarang::with('user')
            ->where('status', 'pending')
            ->latest()
            ->get();
        $kreditBarang->transform(function($kb) {
            $kb->foto_barang = $kb->foto_barang ? asset('storage/' . $kb->foto_barang) : null;
            if ($kb->ttd_anggota) {
                $kb->ttd_anggota = asset('storage/' . $kb->ttd_anggota);
            }
            if ($kb->ttd_admin) {
                $kb->ttd_admin = asset('storage/' . $kb->ttd_admin);
            }
            return $kb;
        });

        $pembayaran = Pembayaran::with(['user', 'pinjaman', 'kreditBarang'])
            ->where('status', 'pending')
            ->latest()
            ->get();
        $pembayaran->transform(function($p) {
            $p->bukti_transfer = $p->bukti_transfer ? asset('storage/' . $p->bukti_transfer) : null;
            return $p;
        });

        return response()->json([
            'simpanan' => $simpanan,
            'pinjaman' => $pinjaman,
            'kreditBarang' => $kreditBarang,
            'pembayaran' => $pembayaran
        ]);
    }

    // 1. Simpanan Approval
    public function approveSimpanan(Request $request, $id)
    {
        $simpanan = Simpanan::findOrFail($id);

        if ($simpanan->status !== 'pending') {
            return response()->json(['message' => 'Simpanan sudah diproses.'], 422);
        }

        $simpanan->update([
            'status' => 'approved',
            'approved_by' => $request->user()->id,
            'approved_at' => now(),
        ]);

        return response()->json(['message' => 'Simpanan berhasil disetujui.']);
    }

    public function rejectSimpanan(Request $request, $id)
    {
        $simpanan = Simpanan::findOrFail($id);

        if ($simpanan->status !== 'pending') {
            return response()->json(['message' => 'Simpanan sudah diproses.'], 422);
        }

        $simpanan->update([
            'status' => 'rejected',
            'approved_by' => $request->user()->id,
            'approved_at' => now(),
        ]);

        return response()->json(['message' => 'Simpanan ditolak.']);
    }

    // 2. Pinjaman Approval
    public function approvePinjaman(Request $request, $id)
    {
        $pinjaman = Pinjaman::findOrFail($id);

        if ($pinjaman->status !== 'pending') {
            return response()->json(['message' => 'Pinjaman sudah diproses.'], 422);
        }

        $request->validate([
            'ttd_admin' => ['required', 'image', 'max:2048'],
        ]);

        $ttdPath = $request->file('ttd_admin')->store('ttd', 'public');

        $pinjaman->update([
            'status' => 'approved',
            'approved_by' => $request->user()->id,
            'approved_at' => now(),
            'ttd_admin' => $ttdPath,
        ]);

        if ($pinjaman->pembayaran()->count() > 0) {
            return response()->json(['message' => 'Jadwal pembayaran sudah dibuat.'], 422);
        }

        // Auto-generate payments installment
        $tenor = $pinjaman->tenor_bulan;
        $startDate = Carbon::now()->addMonth();

        for ($i = 1; $i <= $tenor; $i++) {
            Pembayaran::create([
                'user_id' => $pinjaman->user_id,
                'source_type' => 'pinjaman',
                'source_id' => $pinjaman->id,
                'angsuran_ke' => $i,
                'jatuh_tempo' => $startDate->copy()->addMonths($i - 1),
                'nominal' => $pinjaman->angsuran_per_bulan,
                'status' => 'belum_bayar',
            ]);
        }

        return response()->json(['message' => 'Pinjaman disetujui dan jadwal tagihan otomatis dibuat.']);
    }

    public function rejectPinjaman(Request $request, $id)
    {
        $pinjaman = Pinjaman::findOrFail($id);

        if ($pinjaman->status !== 'pending') {
            return response()->json(['message' => 'Pinjaman sudah diproses.'], 422);
        }

        $pinjaman->update([
            'status' => 'rejected',
            'approved_by' => $request->user()->id,
            'approved_at' => now(),
        ]);

        return response()->json(['message' => 'Pengajuan pinjaman ditolak.']);
    }

    // 3. Kredit Barang Approval
    public function approveKreditBarang(Request $request, $id)
    {
        $kredit = KreditBarang::findOrFail($id);

        if ($kredit->status !== 'pending') {
            return response()->json(['message' => 'Kredit sudah diproses.'], 422);
        }

        $request->validate([
            'ttd_admin' => ['required', 'image', 'max:2048'],
        ]);

        $ttdPath = $request->file('ttd_admin')->store('ttd', 'public');

        $kredit->update([
            'status' => 'approved',
            'approved_by' => $request->user()->id,
            'approved_at' => now(),
            'ttd_admin' => $ttdPath,
        ]);

        if ($kredit->pembayaran()->count() > 0) {
            return response()->json(['message' => 'Jadwal pembayaran sudah dibuat.'], 422);
        }

        // Auto-generate installments
        $tenor = $kredit->tenor_bulan;
        $startDate = Carbon::now()->addMonth();

        for ($i = 1; $i <= $tenor; $i++) {
            Pembayaran::create([
                'user_id' => $kredit->user_id,
                'source_type' => 'kredit_barang',
                'source_id' => $kredit->id,
                'angsuran_ke' => $i,
                'jatuh_tempo' => $startDate->copy()->addMonths($i - 1),
                'nominal' => $kredit->angsuran_per_bulan,
                'status' => 'belum_bayar',
            ]);
        }

        return response()->json(['message' => 'Kredit barang disetujui dan jadwal tagihan dibuat.']);
    }

    public function rejectKreditBarang(Request $request, $id)
    {
        $kredit = KreditBarang::findOrFail($id);

        if ($kredit->status !== 'pending') {
            return response()->json(['message' => 'Kredit sudah diproses.'], 422);
        }

        $kredit->update([
            'status' => 'rejected',
            'approved_by' => $request->user()->id,
            'approved_at' => now(),
        ]);

        return response()->json(['message' => 'Pengajuan kredit barang ditolak.']);
    }

    // 4. Pembayaran Approval
    public function approvePembayaran(Request $request, $id)
    {
        $pembayaran = Pembayaran::findOrFail($id);

        if ($pembayaran->status !== 'pending') {
            return response()->json(['message' => 'Pembayaran sudah diproses.'], 422);
        }

        $pembayaran->update([
            'status' => 'approved',
            'approved_by' => $request->user()->id,
            'approved_at' => now(),
        ]);

        // Reduce outstanding loan
        if ($pembayaran->source_type === 'pinjaman') {
            $pinjaman = $pembayaran->pinjaman;
            if ($pinjaman) {
                $sisa = $pinjaman->sisa_pinjaman - $pembayaran->nominal;
                $pinjaman->update([
                    'sisa_pinjaman' => max(0, $sisa),
                    'status' => $sisa <= 0 ? 'lunas' : 'approved',
                ]);
            }
        }

        // Close credit if all items are approved
        if ($pembayaran->source_type === 'kredit_barang') {
            $kredit = $pembayaran->kreditBarang;
            if ($kredit) {
                $totalBelumLunas = $kredit->pembayaran()
                    ->where('status', '!=', 'approved')
                    ->count();

                if ($totalBelumLunas === 0) {
                    $kredit->update([
                        'status' => 'lunas',
                    ]);
                }
            }
        }

        return response()->json(['message' => 'Pembayaran tagihan disetujui.']);
    }

    public function rejectPembayaran(Request $request, $id)
    {
        $pembayaran = Pembayaran::findOrFail($id);

        if ($pembayaran->status !== 'pending') {
            return response()->json(['message' => 'Pembayaran sudah diproses.'], 422);
        }

        $pembayaran->update([
            'status' => 'belum_bayar',
            'tanggal_bayar' => null,
            'bukti_transfer' => null,
        ]);

        return response()->json(['message' => 'Pembayaran ditolak dan tagihan dikembalikan.']);
    }
}
