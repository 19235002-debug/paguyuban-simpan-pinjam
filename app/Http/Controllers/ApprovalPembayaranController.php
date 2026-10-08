<?php

namespace App\Http\Controllers;

use App\Models\Pembayaran;
use Illuminate\Support\Facades\Auth;

class ApprovalPembayaranController extends Controller
{
    public function index()
    {
        $pembayaran = Pembayaran::with(['user', 'pinjaman'])
            ->where('status', 'pending')
            ->latest()
            ->paginate(15);

        return view('pengurus.pembayaran.index', compact('pembayaran'));
    }

    public function approve(Pembayaran $pembayaran)
    {
        // =========================
        // CEGAH DOUBLE APPROVAL
        // =========================
        if ($pembayaran->status !== 'pending') {
            return back()->with('error', 'Pembayaran sudah diproses.');
        }

        $pembayaran->update([
            'status' => 'approved',
            'approved_by' => Auth::id(),
            'approved_at' => now(),
        ]);

        // =========================
        // UPDATE PINJAMAN
        // =========================
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

        // =========================
        // UPDATE KREDIT BARANG
        // =========================
        if ($pembayaran->source_type === 'kredit_barang') {

            $kredit = $pembayaran->kreditBarang;

            if ($kredit) {

                // cek semua pembayaran kredit barang
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

        return back()->with('success', 'Pembayaran disetujui.');
    }

    public function reject(Pembayaran $pembayaran)
    {
        if ($pembayaran->status !== 'pending') {
            return back()->with('error', 'Pembayaran sudah diproses.');
        }

        $pembayaran->update([
            'status' => 'belum_bayar',
            'tanggal_bayar' => null,
            'bukti_transfer' => null,
        ]);

        return back()->with('success', 'Pembayaran ditolak.');
    }
}
