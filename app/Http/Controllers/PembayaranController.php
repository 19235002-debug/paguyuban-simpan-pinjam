<?php

namespace App\Http\Controllers;

use App\Models\Pembayaran;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class PembayaranController extends Controller
{
    public function index()
    {
        // Get all unique packages for Auth::id()
        $uniquePackages = Pembayaran::where('user_id', Auth::id())
            ->select('source_type', 'source_id')
            ->groupBy('source_type', 'source_id')
            ->get();

        // Identify active packages (packages with at least one unpaid, pending, or rejected installment)
        $activePackages = [];
        foreach ($uniquePackages as $pkg) {
            $hasUnpaid = Pembayaran::where('user_id', Auth::id())
                ->where('source_type', $pkg->source_type)
                ->where('source_id', $pkg->source_id)
                ->whereIn('status', ['belum_bayar', 'pending', 'rejected'])
                ->exists();
            if ($hasUnpaid) {
                $activePackages[] = [
                    'source_type' => $pkg->source_type,
                    'source_id' => $pkg->source_id,
                ];
            }
        }

        if (empty($activePackages)) {
            $totalPembayaran = 0;
            $belumBayar = 0;
            $pending = 0;
            $lunas = 0;
            $totalTagihan = 0;
            $totalNominalPinjaman = 0;
            $persentaseLunas = 0;
        } else {
            $activeQuery = Pembayaran::where('user_id', Auth::id())
                ->where(function($q) use ($activePackages) {
                    foreach ($activePackages as $pkg) {
                        $q->orWhere(function($sub) use ($pkg) {
                            $sub->where('source_type', $pkg['source_type'])
                                ->where('source_id', $pkg['source_id']);
                        });
                    }
                });

            $activePembayaran = $activeQuery->get();
            $totalPembayaran = $activePembayaran->count();
            $belumBayar = $activePembayaran->where('status', 'belum_bayar')->count();
            $pending = $activePembayaran->where('status', 'pending')->count();
            $lunas = $activePembayaran->where('status', 'approved')->count();
            $totalTagihan = $activePembayaran->whereIn('status', ['belum_bayar', 'rejected'])->sum('nominal');
            $totalNominalPinjaman = $activePembayaran->sum('nominal');
            $persentaseLunas = $totalPembayaran > 0 ? round(($lunas / $totalPembayaran) * 100) : 0;
        }

        // Paginate unique loan/credit sources (e.g. 3 active/inactive packages per page)
        $uniqueSources = Pembayaran::where('user_id', Auth::id())
            ->select('source_type', 'source_id')
            ->selectRaw('MAX(id) as max_id')
            ->groupBy('source_type', 'source_id')
            ->orderBy('max_id', 'desc')
            ->paginate(5);

        // Fetch pembayaran details for current page's packages
        $pembayaranList = collect();
        if ($uniqueSources->isNotEmpty()) {
            $pembayaranQuery = Pembayaran::with(['pinjaman', 'kreditBarang'])
                ->where('user_id', Auth::id());

            $pembayaranQuery->where(function($q) use ($uniqueSources) {
                foreach ($uniqueSources as $src) {
                    $q->orWhere(function($sub) use ($src) {
                        $sub->where('source_type', $src->source_type)
                            ->where('source_id', $src->source_id);
                    });
                }
            });

            $pembayaranList = $pembayaranQuery->orderByRaw("
                CASE
                    WHEN status = 'belum_bayar' THEN 1
                    WHEN status = 'pending' THEN 2
                    WHEN status = 'rejected' THEN 3
                    WHEN status = 'approved' THEN 4
                END
            ")
            ->orderBy('jatuh_tempo')
            ->get();
        }

        $groupedPembayaran = $pembayaranList->groupBy(function ($item) {
            return $item->source_type . '-' . $item->source_id;
        });

        return view('pembayaran.index', compact(
            'uniqueSources',
            'groupedPembayaran',
            'totalPembayaran',
            'belumBayar',
            'pending',
            'lunas',
            'totalTagihan',
            'totalNominalPinjaman',
            'persentaseLunas'
        ));
    }

    public function bayar(Pembayaran $pembayaran)
    {
        abort_if(
            $pembayaran->user_id !== Auth::id(),
            403
        );

        abort_if(
            !in_array($pembayaran->status, ['belum_bayar', 'rejected']),
            403
        );

        return view('pembayaran.bayar', compact('pembayaran'));
    }

    public function storeBayar(
        Request $request,
        Pembayaran $pembayaran
    ) {
        abort_if(
            $pembayaran->user_id !== Auth::id(),
            403
        );

        $request->validate([
            'tanggal_bayar'   => 'required|date',
            'bukti_transfer'  => 'required|image|max:2048',
        ]);

        $path = $request->file('bukti_transfer')
            ->store('pembayaran', 'public');

        $pembayaran->update([
            'tanggal_bayar'  => $request->tanggal_bayar,
            'bukti_transfer' => $path,
            'status'         => 'pending',
        ]);

        return redirect()
            ->route('pembayaran.index')
            ->with(
                'success',
                'Pembayaran berhasil dikirim dan menunggu persetujuan pengurus.'
            );
    }
}
