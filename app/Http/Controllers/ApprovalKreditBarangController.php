<?php

namespace App\Http\Controllers;

use App\Models\KreditBarang;
use App\Models\Pembayaran;
use Illuminate\Support\Facades\Auth;
use Carbon\Carbon;

class ApprovalKreditBarangController extends Controller
{
    public function index()
    {
        $kreditBarang = KreditBarang::with('user')
            ->where('status', 'pending')
            ->latest()
            ->paginate(10);

        return view('pengurus.kredit-barang.index', compact('kreditBarang'));
    }

    public function approve(KreditBarang $kreditBarang)
    {
        // =========================
        // CEGAH DOUBLE APPROVAL
        // =========================
        if ($kreditBarang->status !== 'pending') {
            return back()->with('error', 'Kredit sudah diproses.');
        }

        $kreditBarang->update([
            'status' => 'approved',
            'approved_by' => Auth::id(),
            'approved_at' => now(),
        ]);

        // =========================
        // CEGAH DUPLIKAT PEMBAYARAN
        // =========================
        if ($kreditBarang->pembayaran()->count() > 0) {
            return back()->with('error', 'Pembayaran sudah pernah dibuat.');
        }

        // =========================
        // AUTO GENERATE PEMBAYARAN (KREDIT BARANG)
        // =========================

        $tenor = $kreditBarang->tenor_bulan;
        $startDate = Carbon::now()->addMonth();

        for ($i = 1; $i <= $tenor; $i++) {

            Pembayaran::create([
                'user_id' => $kreditBarang->user_id,
                'source_type' => 'kredit_barang',
                'source_id' => $kreditBarang->id,

                'angsuran_ke' => $i,
                'jatuh_tempo' => $startDate->copy()->addMonths($i - 1),

                'nominal' => $kreditBarang->angsuran_per_bulan,

                'status' => 'belum_bayar',
            ]);
        }

        return back()->with(
            'success',
            'Kredit barang disetujui & pembayaran otomatis dibuat.'
        );
    }

    public function reject(KreditBarang $kreditBarang)
    {
        if ($kreditBarang->status !== 'pending') {
            return back()->with('error', 'Kredit sudah diproses.');
        }

        $kreditBarang->update([
            'status' => 'rejected',
            'approved_by' => Auth::id(),
            'approved_at' => now(),
        ]);

        return back()->with(
            'success',
            'Pengajuan kredit barang ditolak.'
        );
    }
}
