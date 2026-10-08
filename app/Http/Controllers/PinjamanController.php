<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\Pinjaman;
use App\Models\KreditBarang;

class PinjamanController extends Controller
{
    public function index()
    {
        $userId = Auth::id();

        $pinjaman = Pinjaman::where('user_id', $userId)
            ->latest()
            ->paginate(10);

        $totalPinjamanAktif = Pinjaman::where('user_id', $userId)
            ->where('status', 'approved')
            ->sum('total_pengembalian');

        $totalSisaPinjaman = Pinjaman::where('user_id', $userId)
            ->where('status', 'approved')
            ->sum('sisa_pinjaman');

        $totalPending = Pinjaman::where('user_id', $userId)
            ->where('status', 'pending')
            ->count();

        $hasActivePinjaman = Pinjaman::where('user_id', $userId)
            ->whereIn('status', ['pending', 'approved'])
            ->exists();

        $hasActiveKredit = KreditBarang::where('user_id', $userId)
            ->whereIn('status', ['pending', 'approved'])
            ->exists();

        $bolehAjukan = !($hasActivePinjaman || $hasActiveKredit);

        return view('pinjaman.index', compact(
            'pinjaman',
            'totalPinjamanAktif',
            'totalSisaPinjaman',
            'totalPending',
            'bolehAjukan'
        ));
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
                ->route('pinjaman.index')
                ->with(
                    'error',
                    'Anda masih memiliki pinjaman atau kredit yang belum selesai.'
                );
        }

        return view('pinjaman.create', [
            'defaultNominal' => 100000,
            'defaultTenor' => 1,
        ]);
    }

    private function hitungPinjaman($nominal, $tenor)
    {
        $bunga = 10;

        $nominalBunga = ($nominal * $bunga) / 100;

        $totalPengembalian = $nominal + $nominalBunga;

        $angsuranPerBulan = round(
            $totalPengembalian / $tenor
        );

        return [
            'bunga' => $bunga,
            'nominal_bunga' => $nominalBunga,
            'total_pengembalian' => $totalPengembalian,
            'angsuran_per_bulan' => $angsuranPerBulan,
        ];
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
            return redirect()
                ->route('pinjaman.index')
                ->with(
                    'error',
                    'Anda masih memiliki pinjaman atau kredit aktif.'
                );
        }

        $request->merge([
            'nominal' => (int) preg_replace(
                '/\D/',
                '',
                $request->nominal
            ),
        ]);

        $validated = $request->validate([
            'nominal' => [
                'required',
                'numeric',
                'min:100000',
            ],
            'tenor_bulan' => [
                'required',
                'integer',
                'min:1',
                'max:12',
            ],
        ]);

        $hasil = $this->hitungPinjaman(
            $validated['nominal'],
            $validated['tenor_bulan']
        );

        Pinjaman::create([
            'user_id' => $userId,
            'sumber_id' => null,
            'tipe' => 'uang',

            'nominal' => $validated['nominal'],

            'persen_bunga' => $hasil['bunga'],
            'nominal_bunga' => $hasil['nominal_bunga'],

            'total_pengembalian' => $hasil['total_pengembalian'],

            'tenor_bulan' => $validated['tenor_bulan'],

            'angsuran_per_bulan' => $hasil['angsuran_per_bulan'],

            'sisa_pinjaman' => $hasil['total_pengembalian'],

            'status' => 'pending',
        ]);

        return redirect()
            ->route('pinjaman.index')
            ->with(
                'success',
                'Pengajuan pinjaman berhasil dikirim dan menunggu persetujuan pengurus.'
            );
    }
}
