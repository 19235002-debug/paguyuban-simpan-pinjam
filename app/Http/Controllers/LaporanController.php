<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Simpanan;
use App\Models\Pinjaman;
use App\Models\Pembayaran;
use App\Models\KreditBarang;
use App\Models\PengeluaranShu;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class LaporanController extends Controller
{
    public function index()
    {
        $userId = Auth::id();

        // 1. Pemasukan (Deposit Simpanan + Bayar Angsuran)
        $totalSimpananMasuk = Simpanan::where('status', 'approved')->sum('total_bayar');
        $totalAngsuranMasuk = Pembayaran::where('status', 'approved')->sum('nominal');
        $totalPemasukan = $totalSimpananMasuk + $totalAngsuranMasuk;

        // 2. Pengeluaran (Pinjaman Cair + Pembelian Kredit Barang + SHU)
        $totalPinjamanKeluar = Pinjaman::where('status', 'approved')->sum('nominal');
        $totalKreditKeluar = KreditBarang::where('status', 'approved')->sum('harga_barang');
        $totalShuKeluar = PengeluaranShu::sum('nominal');
        $totalPengeluaran = $totalPinjamanKeluar + $totalKreditKeluar + $totalShuKeluar;

        // 3. Saldo Kas Bersih Koperasi
        $saldoKas = $totalPemasukan - $totalPengeluaran;

        // 4. Saldo Simpanan Anggota
        $saldoSimpananGlobal = Simpanan::where('status', 'approved')->sum('nominal_simpanan');

        // 5. Total Sisa Pinjaman/Kredit Berjalan (Outstanding)
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

        return view('pengurus.laporan.index', compact(
            'totalPemasukan',
            'totalPengeluaran',
            'saldoKas',
            'saldoSimpananGlobal',
            'totalOutstanding'
        ));
    }

    private function authenticateViaToken(Request $request)
    {
        if ($request->has('token')) {
            $tokenStr = $request->query('token');
            $token = \Laravel\Sanctum\PersonalAccessToken::findToken($tokenStr);
            if ($token && $token->tokenable) {
                $user = $token->tokenable;
                if ($user->role === 'pengurus') {
                    Auth::login($user);
                }
            }
        }
    }

    public function exportCsv(Request $request, $type)
    {
        $this->authenticateViaToken($request);
        if (!Auth::check() || Auth::user()->role !== 'pengurus') {
            abort(403, 'Unauthorized');
        }

        $headers = [
            "Content-type" => "text/csv; charset=UTF-8",
            "Content-Disposition" => "attachment; filename=Laporan_" . ucfirst($type) . "_" . date('Ymd') . ".csv",
            "Pragma" => "no-cache",
            "Cache-Control" => "must-revalidate, post-check=0, pre-check=0",
            "Expires" => "0"
        ];

        $callback = function() use ($type) {
            $file = fopen('php://output', 'w');
            
            // Add UTF-8 BOM for Excel compatibility
            fprintf($file, chr(0xEF).chr(0xBB).chr(0xBF));

            if ($type === 'pemasukan') {
                fputcsv($file, ['Tanggal', 'Anggota', 'Jenis Transaksi', 'Keterangan', 'Nominal']);

                $simpanan = Simpanan::with('user')->where('status', 'approved')->get();
                foreach($simpanan as $s) {
                    fputcsv($file, [
                        optional($s->tanggal_bayar)->format('Y-m-d') ?? $s->created_at->format('Y-m-d'),
                        $s->user->name,
                        'Simpanan Wajib',
                        'Setoran wajib simpanan bulanan',
                        $s->total_bayar
                    ]);
                }

                $pembayaran = Pembayaran::where('status', 'approved')->get();
                foreach($pembayaran as $p) {
                    $name = '-';
                    if ($p->source_type === 'pinjaman' && $p->pinjaman) {
                        $name = optional($p->pinjaman->user)->name ?? '-';
                    } elseif ($p->source_type === 'kredit_barang' && $p->kreditBarang) {
                        $name = optional($p->kreditBarang->user)->name ?? '-';
                    }
                    fputcsv($file, [
                        optional($p->tanggal_bayar)->format('Y-m-d') ?? $p->created_at->format('Y-m-d'),
                        $name,
                        'Angsuran',
                        'Pembayaran cicilan ' . str_replace('_', ' ', $p->source_type) . ' ke-' . $p->angsuran_ke,
                        $p->nominal
                    ]);
                }

            } elseif ($type === 'pengeluaran') {
                fputcsv($file, ['Tanggal', 'Anggota', 'Jenis Pengeluaran', 'Keterangan/Barang', 'Nominal']);

                $pinjaman = Pinjaman::with('user')->where('status', 'approved')->get();
                foreach($pinjaman as $p) {
                    fputcsv($file, [
                        $p->created_at->format('Y-m-d'),
                        $p->user->name,
                        'Pencairan Pinjaman',
                        'Pencairan pinjaman tenor ' . $p->tenor_bulan . ' bulan',
                        $p->nominal
                    ]);
                }

                $kredit = KreditBarang::with('user')->where('status', 'approved')->get();
                foreach($kredit as $k) {
                    fputcsv($file, [
                        $k->created_at->format('Y-m-d'),
                        $k->user->name,
                        'Pengadaan Kredit Barang',
                        'Kredit barang: ' . $k->nama_barang,
                        $k->harga_barang
                    ]);
                }

                $shus = PengeluaranShu::with('user')->get();
                foreach($shus as $sh) {
                    fputcsv($file, [
                        \Carbon\Carbon::parse($sh->tanggal)->format('Y-m-d'),
                        $sh->user->name,
                        'Pengeluaran SHU',
                        $sh->keterangan,
                        $sh->nominal
                    ]);
                }

            } elseif ($type === 'saldo_anggota') {
                fputcsv($file, ['NIK', 'Nama Anggota', 'Email', 'Total Simpanan']);

                $users = User::where('role', 'anggota')->get();
                foreach($users as $u) {
                    $totalSimpanan = Simpanan::where('user_id', $u->id)->where('status', 'approved')->sum('nominal_simpanan');
                    fputcsv($file, [
                        $u->nik,
                        $u->name,
                        $u->email,
                        $totalSimpanan
                    ]);
                }

            } elseif ($type === 'pinjaman_anggota') {
                fputcsv($file, ['NIK', 'Nama Anggota', 'Total Pinjaman Aktif', 'Sisa Pinjaman']);

                $users = User::where('role', 'anggota')->get();
                foreach($users as $u) {
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

                    fputcsv($file, [
                        $u->nik,
                        $u->name,
                        $totalPinjaman + $totalKredit,
                        $sisaPinjaman + $sisaKredit
                    ]);
                }
            }

            fclose($file);
        };

        return response()->stream($callback, 200, $headers);
    }

    public function printPdf(Request $request, $type)
    {
        $this->authenticateViaToken($request);
        if (!Auth::check() || Auth::user()->role !== 'pengurus') {
            abort(403, 'Unauthorized');
        }

        $data = [];

        switch ($type) {
            case 'pemasukan':
                $data = $this->getPemasukanPrintData();
                break;
            case 'pengeluaran':
                $data = $this->getPengeluaranPrintData();
                break;
            case 'saldo_anggota':
                $data = $this->getSaldoAnggotaPrintData();
                break;
            case 'pinjaman_anggota':
                $data = $this->getPinjamanAnggotaPrintData();
                break;
            case 'rekap_anggota':
                $data = $this->getRekapAnggotaPrintData();
                break;
        }

        return view('pengurus.laporan.print', compact('data', 'type'));
    }

    private function getPemasukanPrintData()
    {
        $items = collect();

        $simpanan = Simpanan::with('user')->where('status', 'approved')->get();
        foreach($simpanan as $s) {
            $items->push([
                'tanggal' => optional($s->tanggal_bayar)->format('d M Y') ?? $s->created_at->format('d M Y'),
                'anggota' => $s->user->name,
                'jenis' => 'Simpanan Wajib',
                'keterangan' => 'Setoran simpanan wajib bulanan',
                'nominal' => $s->total_bayar
            ]);
        }

        $pembayaran = Pembayaran::where('status', 'approved')->get();
        foreach($pembayaran as $p) {
            $name = '-';
            if ($p->source_type === 'pinjaman' && $p->pinjaman) {
                $name = optional($p->pinjaman->user)->name ?? '-';
            } elseif ($p->source_type === 'kredit_barang' && $p->kreditBarang) {
                $name = optional($p->kreditBarang->user)->name ?? '-';
            }
            $items->push([
                'tanggal' => optional($p->tanggal_bayar)->format('d M Y') ?? $p->created_at->format('d M Y'),
                'anggota' => $name,
                'jenis' => 'Angsuran',
                'keterangan' => 'Pembayaran cicilan ' . str_replace('_', ' ', $p->source_type) . ' ke-' . $p->angsuran_ke,
                'nominal' => $p->nominal
            ]);
        }

        return [
            'items' => $items->sortByDesc('tanggal'),
            'title' => 'Laporan Pemasukan Koperasi'
        ];
    }

    private function getPengeluaranPrintData()
    {
        $items = collect();

        $pinjaman = Pinjaman::with('user')->where('status', 'approved')->get();
        foreach($pinjaman as $p) {
            $items->push([
                'tanggal' => $p->created_at->format('d M Y'),
                'anggota' => $p->user->name,
                'jenis' => 'Pencairan Pinjaman',
                'keterangan' => 'Pencairan pinjaman tenor ' . $p->tenor_bulan . ' bulan',
                'nominal' => $p->nominal
            ]);
        }

        $kredit = KreditBarang::with('user')->where('status', 'approved')->get();
        foreach($kredit as $k) {
            $items->push([
                'tanggal' => $k->created_at->format('d M Y'),
                'anggota' => $k->user->name,
                'jenis' => 'Kredit Barang',
                'keterangan' => 'Kredit barang: ' . $k->nama_barang,
                'nominal' => $k->harga_barang
            ]);
        }

        $shus = PengeluaranShu::with('user')->get();
        foreach($shus as $sh) {
            $items->push([
                'tanggal' => \Carbon\Carbon::parse($sh->tanggal)->format('d M Y'),
                'anggota' => $sh->user->name,
                'jenis' => 'Pengeluaran SHU',
                'keterangan' => $sh->keterangan,
                'nominal' => $sh->nominal
            ]);
        }

        return [
            'items' => $items->sortByDesc('tanggal'),
            'title' => 'Laporan Pengeluaran Koperasi'
        ];
    }

    private function getSaldoAnggotaPrintData()
    {
        $items = [];
        $users = User::where('role', 'anggota')->get();
        foreach($users as $u) {
            $totalSimpanan = Simpanan::where('user_id', $u->id)->where('status', 'approved')->sum('nominal_simpanan');
            $items[] = [
                'nik' => $u->nik,
                'anggota' => $u->name,
                'email' => $u->email,
                'nominal' => $totalSimpanan
            ];
        }

        return [
            'items' => $items,
            'title' => 'Laporan Saldo Simpanan Anggota'
        ];
    }

    private function getPinjamanAnggotaPrintData()
    {
        $items = [];
        $users = User::where('role', 'anggota')->get();
        foreach($users as $u) {
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

            $items[] = [
                'nik' => $u->nik,
                'anggota' => $u->name,
                'total_pinjam' => $totalPinjaman + $totalKredit,
                'sisa_pinjam' => $sisaPinjaman + $sisaKredit
            ];
        }

        return [
            'items' => $items,
            'title' => 'Laporan Pinjaman & Kredit Anggota'
        ];
    }

    private function getRekapAnggotaPrintData()
    {
        $items = [];
        $users = User::where('role', 'anggota')->get();
        foreach($users as $u) {
            $totalSimpanan = Simpanan::where('user_id', $u->id)->where('status', 'approved')->sum('nominal_simpanan');
            
            $userLoans = [];
            
            // Pinjaman tunai
            $pinjaman = Pinjaman::where('user_id', $u->id)->where('status', 'approved')->get();
            foreach ($pinjaman as $p) {
                $sudahBayarBulan = Pembayaran::where('source_type', 'pinjaman')
                    ->where('source_id', $p->id)
                    ->where('status', 'approved')
                    ->count();
                $userLoans[] = [
                    'tipe' => null,
                    'nominal' => $p->nominal,
                    'tenor' => $p->tenor_bulan,
                    'bulan_ke' => $sudahBayarBulan,
                    'sisa' => (int) $p->sisa_pinjaman
                ];
            }
            
            // Kredit barang
            $kredit = KreditBarang::where('user_id', $u->id)->where('status', 'approved')->get();
            foreach ($kredit as $kb) {
                $sudahBayarBulan = Pembayaran::where('source_type', 'kredit_barang')
                    ->where('source_id', $kb->id)
                    ->where('status', 'approved')
                    ->count();
                $userLoans[] = [
                    'tipe' => 'Kredit: ' . $kb->nama_barang,
                    'nominal' => $kb->harga_barang,
                    'tenor' => $kb->tenor_bulan,
                    'bulan_ke' => $sudahBayarBulan,
                    'sisa' => $kb->sisa_kredit
                ];
            }

            $items[] = [
                'nik' => $u->nik,
                'anggota' => $u->name,
                'email' => $u->email,
                'total_simpanan' => $totalSimpanan,
                'total_pinjaman' => collect($userLoans)->sum('nominal'),
                'pinjaman' => $userLoans
            ];
        }

        return [
            'items' => $items,
            'title' => 'Rekapitulasi Simpanan & Pinjaman Anggota'
        ];
    }
}
