<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\Auth;
use App\Models\Pinjaman;
use App\Models\Pembayaran;
use Carbon\Carbon;

class ApprovalPinjamanController extends Controller
{
    public function index()
    {
        $pinjaman = Pinjaman::with('user')
            ->where('status', 'pending')
            ->latest()
            ->paginate(15);

        return view('pengurus.pinjaman.index', compact('pinjaman'));
    }

    public function approve(Pinjaman $pinjaman)
    {
        // =========================
        // CEGAH DOUBLE APPROVAL
        // =========================
        if ($pinjaman->status !== 'pending') {
            return back()->with('error', 'Pinjaman sudah diproses.');
        }

        $pinjaman->update([
            'status' => 'approved',
            'approved_by' => Auth::id(),
            'approved_at' => now(),
        ]);

        // =========================
        // CEGAH DUPLIKAT PEMBAYARAN
        // =========================
        if ($pinjaman->pembayaran()->count() > 0) {
            return back()->with('error', 'Pembayaran sudah pernah dibuat.');
        }

        // =========================
        // AUTO GENERATE PEMBAYARAN
        // =========================
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

        return back()->with('success', 'Pinjaman disetujui & pembayaran otomatis dibuat.');
    }

    public function reject(Pinjaman $pinjaman)
    {
        // =========================
        // CEGAH DOUBLE REJECT
        // =========================
        if ($pinjaman->status !== 'pending') {
            return back()->with('error', 'Pinjaman sudah diproses.');
        }

        $pinjaman->update([
            'status' => 'rejected',
            'approved_by' => Auth::id(),
            'approved_at' => now(),
        ]);

        return back()->with('success', 'Pinjaman berhasil direject.');
    }
}
