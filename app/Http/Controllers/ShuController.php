<?php

namespace App\Http\Controllers;

use App\Models\PengeluaranShu;
use App\Models\Simpanan;
use App\Models\Pinjaman;
use App\Models\Pembayaran;
use App\Models\KreditBarang;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ShuController extends Controller
{
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

    public function index()
    {
        $shus = PengeluaranShu::with('user')
            ->latest()
            ->paginate(15);

        $saldoKas = $this->getSaldoKas();

        return view('pengurus.shu.index', compact('shus', 'saldoKas'));
    }

    public function create()
    {
        $saldoKas = $this->getSaldoKas();
        return view('pengurus.shu.create', compact('saldoKas'));
    }

    public function store(Request $request)
    {
        $nominal = (int) preg_replace('/\D/', '', $request->nominal);
        
        $request->merge([
            'nominal' => $nominal
        ]);

        $request->validate([
            'nominal' => 'required|numeric|min:1000',
            'tanggal' => 'required|date',
            'keterangan' => 'required|string|max:255',
        ]);

        $saldoKas = $this->getSaldoKas();
        if ($nominal > $saldoKas) {
            return back()
                ->withInput()
                ->with('error', 'Nominal pengeluaran SHU melebihi saldo kas koperasi saat ini (Maks: Rp ' . number_format($saldoKas, 0, ',', '.') . ').');
        }

        PengeluaranShu::create([
            'nominal' => $nominal,
            'tanggal' => $request->tanggal,
            'keterangan' => $request->keterangan,
            'user_id' => Auth::id(),
        ]);

        return redirect()
            ->route('pengurus.shu.index')
            ->with('success', 'Pengeluaran SHU berhasil dicatat!');
    }

    public function destroy(PengeluaranShu $shu)
    {
        $shu->delete();
        return redirect()
            ->route('pengurus.shu.index')
            ->with('success', 'Catatan pengeluaran SHU berhasil dihapus.');
    }
}
