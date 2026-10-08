<?php

namespace App\Http\Controllers;

use App\Models\Simpanan;
use Illuminate\Support\Facades\Auth;

class ApprovalSimpananController extends Controller
{
    public function index()
    {
        $simpanan = Simpanan::with('user')
            ->where('status', 'pending')
            ->latest()
            ->paginate(15);

        return view('pengurus.simpanan.index', compact('simpanan'));
    }

    public function approve(Simpanan $simpanan)
    {
        // =========================
        // CEGAH DOUBLE APPROVAL
        // =========================
        if ($simpanan->status !== 'pending') {
            return back()->with('error', 'Simpanan sudah diproses.');
        }

        $simpanan->update([
            'status' => 'approved',
            'approved_by' => Auth::id(),
            'approved_at' => now(),
        ]);

        return back()->with('success', 'Simpanan berhasil diapprove.');
    }

    public function reject(Simpanan $simpanan)
    {
        // =========================
        // CEGAH DOUBLE REJECT
        // =========================
        if ($simpanan->status !== 'pending') {
            return back()->with('error', 'Simpanan sudah diproses.');
        }

        $simpanan->update([
            'status' => 'rejected',
            'approved_by' => Auth::id(),
            'approved_at' => now(),
        ]);

        return back()->with('success', 'Simpanan ditolak.');
    }
}
