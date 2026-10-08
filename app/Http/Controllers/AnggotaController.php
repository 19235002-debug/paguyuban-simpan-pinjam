<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Pinjaman;
use App\Models\Simpanan;
use Illuminate\Http\Request;

class AnggotaController extends Controller
{
    public function index(Request $request)
    {
        $query = User::where('role', 'anggota');

        // ======================
        // SEARCH
        // ======================
        if ($request->search) {
            $query->where(function ($q) use ($request) {
                $q->where('name', 'like', "%{$request->search}%")
                    ->orWhere('email', 'like', "%{$request->search}%");
            });
        }

        $anggota = $query->latest()->paginate(10);

        // ======================
        // APPEND DATA STATISTIK
        // ======================
        $anggota->getCollection()->transform(function ($user) {

            $sisaPinjaman = (int) Pinjaman::where('user_id', $user->id)
                ->whereIn('status', ['pending', 'approved'])
                ->sum('sisa_pinjaman');

            $kredits = \App\Models\KreditBarang::where('user_id', $user->id)
                ->whereIn('status', ['pending', 'approved'])
                ->get();
            $sisaKredit = 0;
            foreach ($kredits as $kr) {
                $sisaKredit += $kr->sisa_kredit;
            }

            $totalSimpanan = Simpanan::where('user_id', $user->id)
                ->where('status', 'approved')
                ->sum('nominal_simpanan');

            $user->total_pinjaman = $sisaPinjaman + $sisaKredit;
            $user->total_simpanan = $totalSimpanan;

            return $user;
        });

        return view('pengurus.anggota.index', compact('anggota'));
    }

    public function show($id)
    {
        $user = User::findOrFail($id);

        $sisaPinjaman = (int) Pinjaman::where('user_id', $id)
            ->whereIn('status', ['pending', 'approved'])
            ->sum('sisa_pinjaman');

        $kredits = \App\Models\KreditBarang::where('user_id', $id)
            ->whereIn('status', ['pending', 'approved'])
            ->get();
        $sisaKredit = 0;
        foreach ($kredits as $kr) {
            $sisaKredit += $kr->sisa_kredit;
        }

        $user->total_pinjaman = $sisaPinjaman + $sisaKredit;

        $user->total_simpanan = Simpanan::where('user_id', $id)
            ->where('status', 'approved')
            ->sum('nominal_simpanan');

        $simpanan = Simpanan::where('user_id', $id)->latest()->get();
        $pinjaman = Pinjaman::where('user_id', $id)->latest()->get();

        return view('pengurus.anggota.show', compact(
            'user',
            'simpanan',
            'pinjaman'
        ));
    }
}
