<?php

namespace App\Http\Controllers;

use App\Models\Simpanan;
use App\Models\Pinjaman;
use App\Models\Pembayaran;
use App\Models\KreditBarang;
use Illuminate\Support\Facades\Auth;

class DashboardController extends Controller
{
    public function index()
    {
        $user = Auth::user();
        $isPengurus = ($user->role === 'pengurus');

        if ($isPengurus) {
            // GLOBAL COOPERATIVE STATS FOR ADMIN
            $saldoSimpanan = Simpanan::where('status', 'approved')->sum('nominal_simpanan');
            
            $pinjamanAktif = Pinjaman::where('status', 'approved')->count();
            
            $kreditAktif = KreditBarang::where('status', 'approved')->count();

            $tagihanBulanIni = Pembayaran::where('status', 'belum_bayar')
                ->whereMonth('jatuh_tempo', now()->month)
                ->whereYear('jatuh_tempo', now()->year)
                ->sum('nominal');

            $totalTagihanBelumBayar = Pembayaran::where('status', 'belum_bayar')->sum('nominal');

            $totalPending = Simpanan::where('status', 'pending')->count() +
                            Pinjaman::where('status', 'pending')->count() +
                            KreditBarang::where('status', 'pending')->count() +
                            Pembayaran::where('status', 'pending')->count();
        } else {
            // PERSONAL STATS FOR MEMBERS
            $saldoSimpanan = Simpanan::where('user_id', $user->id)
                ->where('status', 'approved')
                ->sum('nominal_simpanan');

            $pinjamanAktif = Pinjaman::where('user_id', $user->id)
                ->where('status', 'approved')
                ->count();

            $kreditAktif = KreditBarang::where('user_id', $user->id)
                ->where('status', 'approved')
                ->count();

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
        }

        $pinjamanTerakhir = Pinjaman::where('user_id', $user->id)
            ->latest()
            ->first();

        $kreditTerakhir = KreditBarang::where('user_id', $user->id)
            ->latest()
            ->first();

        return view('dashboard', compact(
            'saldoSimpanan',
            'tagihanBulanIni',
            'pinjamanAktif',
            'kreditAktif',
            'pinjamanTerakhir',
            'kreditTerakhir',
            'totalTagihanBelumBayar',
            'totalPending'
        ));
    }
}
