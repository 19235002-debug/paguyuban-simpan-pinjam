<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

use App\Models\Simpanan;

class SimpananController extends Controller
{
    public function index(Request $request)
    {
        $simpanan = $request->user()
            ->simpanan()
            ->latest()
            ->paginate(10);

        return view('simpanan.index', compact('simpanan'));
    }

    public function create()
    {
        return view('simpanan.create');
    }

    public function store(Request $request)
    {

        $cek = Simpanan::where('user_id', Auth::id())
            ->where('jenis', 'wajib')
            ->where('bulan', now()->month)
            ->where('tahun', now()->year)
            ->exists();

        if ($cek) {
            return back()->withErrors([
                'simpanan' => 'Simpanan wajib bulan ini sudah diajukan.'
            ]);
        }
        $request->validate([
            'tanggal_bayar' => ['required'],
            'bukti_transfer' => ['required', 'image', 'max:2048']
        ]);

        $path = $request->file('bukti_transfer')
            ->store('simpanan', 'public');

        Simpanan::create([
            'user_id' => Auth::id(),
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

        return redirect()
            ->route('simpanan.index')
            ->with('success', 'Simpanan berhasil diajukan.');
    }
}
