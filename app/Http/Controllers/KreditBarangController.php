<?php

namespace App\Http\Controllers;

use App\Models\KreditBarang;
use App\Models\Pembayaran;
use App\Models\Pinjaman;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Carbon\Carbon;

class KreditBarangController extends Controller
{
    public function index()
    {
        $userId = Auth::id();

        $kreditBarang = KreditBarang::where('user_id', $userId)
            ->latest()
            ->paginate(10);

        $hasActivePinjaman = Pinjaman::where('user_id', $userId)
            ->whereIn('status', ['pending', 'approved'])
            ->exists();

        $hasActiveKredit = KreditBarang::where('user_id', $userId)
            ->whereIn('status', ['pending', 'approved'])
            ->exists();

        $bolehAjukan = !($hasActivePinjaman || $hasActiveKredit);

        return view('kredit-barang.index', compact('kreditBarang', 'bolehAjukan'));
    }

    public function create()
    {
        $userId = Auth::id();

        $hasActivePinjaman = Pinjaman::where('user_id', $userId)
            ->whereIn('status', ['pending', 'approved'])
            ->exists();

        $hasActiveKredit = KreditBarang::where('user_id', $userId)
            ->whereIn('status', ['pending', 'approved'])
            ->exists();

        if ($hasActivePinjaman || $hasActiveKredit) {
            return redirect()
                ->route('kredit-barang.index')
                ->with('error', 'Anda masih memiliki pinjaman atau kredit yang belum selesai.');
        }

        return view('kredit-barang.create');
    }

    public function store(Request $request)
    {
        $userId = Auth::id();

        $hasActivePinjaman = Pinjaman::where('user_id', $userId)
            ->whereIn('status', ['pending', 'approved'])
            ->exists();

        $hasActiveKredit = KreditBarang::where('user_id', $userId)
            ->whereIn('status', ['pending', 'approved'])
            ->exists();

        if ($hasActivePinjaman || $hasActiveKredit) {
            return back()->with('error', 'Anda masih memiliki pinjaman atau kredit aktif.');
        }

        $harga = (int) preg_replace('/\D/', '', $request->harga_barang);

        $request->merge([
            'harga_barang' => $harga
        ]);

        $request->validate([
            'nama_barang' => 'required|string|max:255',
            'harga_barang' => 'required|numeric',
            'tenor_bulan' => 'required|integer|min:1|max:12',
            'foto_barang' => 'nullable|image|max:2048',
            'keterangan' => 'nullable|string',
        ]);

        // =========================
        // HITUNG BUNGA SERVER SIDE
        // =========================
        $bunga = 10;

        $nominalBunga = ($harga * $bunga) / 100;
        $totalTagihan = $harga + $nominalBunga;
        $angsuran = round($totalTagihan / $request->tenor_bulan);

        // =========================
        // UPLOAD FOTO
        // =========================
        $fotoPath = null;
        if ($request->hasFile('foto_barang')) {
            $fotoPath = $request->file('foto_barang')->store('kredit', 'public');
        }

        // =========================
        // CREATE KREDIT BARANG
        // =========================
        KreditBarang::create([
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
        ]);

        return redirect()->route('kredit-barang.index')->with('success', 'Pengajuan kredit barang berhasil dikirim!');
    }
}
