<x-app-layout>

    <x-slot name="header">
        <div class="flex items-center justify-between">
            <div>
                <h2 class="text-lg font-bold text-slate-800">
                    Pinjaman Saya
                </h2>
                <p class="text-[11px] text-slate-500">
                    Riwayat pengajuan dan status pinjaman tunai Anda
                </p>
            </div>
            @if($bolehAjukan)
            <a href="{{ route('pinjaman.create') }}"
                class="px-4 py-2.5 bg-teal-600 hover:bg-teal-700 text-white rounded-xl font-semibold text-xs transition tap-scale flex items-center gap-1.5">
                <i class="ti ti-plus"></i>
                <span>Ajukan Pinjaman</span>
            </a>
            @endif
        </div>
    </x-slot>

    <!-- METRICS CARDS (RESPONSIVE GRID) -->
    <div class="grid grid-cols-2 md:grid-cols-4 gap-3 mt-4">
        
        <div class="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm">
            <span class="text-[9px] font-bold text-slate-400 uppercase tracking-wider block">Sisa Pinjaman</span>
            <span class="text-sm font-extrabold text-rose-600 mt-1 block">
                Rp {{ number_format($totalSisaPinjaman, 0, ',', '.') }}
            </span>
        </div>

        <div class="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm">
            <span class="text-[9px] font-bold text-slate-400 uppercase tracking-wider block">Pinjaman Aktif</span>
            <span class="text-sm font-extrabold text-teal-600 mt-1 block">
                Rp {{ number_format($totalPinjamanAktif, 0, ',', '.') }}
            </span>
        </div>

        <div class="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm flex items-center gap-2">
            <div class="w-8 h-8 rounded-lg bg-slate-50 text-slate-500 flex items-center justify-center">
                <i class="ti ti-folders text-base"></i>
            </div>
            <div>
                <span class="text-[9px] font-bold text-slate-400 uppercase tracking-wider block">Pengajuan</span>
                <span class="text-xs font-bold text-slate-800 mt-0.5 block">{{ $pinjaman->total() }}</span>
            </div>
        </div>

        <div class="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm flex items-center gap-2">
            <div class="w-8 h-8 rounded-lg bg-amber-50 text-amber-500 flex items-center justify-center">
                <i class="ti ti-clock text-base"></i>
            </div>
            <div>
                <span class="text-[9px] font-bold text-slate-400 uppercase tracking-wider block">Pending</span>
                <span class="text-xs font-bold text-slate-800 mt-0.5 block">{{ $totalPending }}</span>
            </div>
        </div>

    </div>

    <!-- ELIGIBILITY / ACTION BANNER -->
    @if(!$bolehAjukan)
    <div class="mt-4 bg-amber-50/70 border border-amber-200/60 rounded-2xl p-4 flex items-start gap-3">
        <i class="ti ti-alert-triangle text-amber-600 text-lg mt-0.5"></i>
        <div>
            <h4 class="font-bold text-slate-800 text-xs">Pengajuan Ditangguhkan</h4>
            <p class="text-[10px] text-slate-600 mt-0.5 leading-relaxed">
                Anda masih memiliki kontrak pinjaman atau kredit barang aktif. Selesaikan terlebih dahulu sebelum melakukan pengajuan baru.
            </p>
        </div>
    </div>
    @endif

    <!-- LOAN CONTRACTS LIST -->
    <div class="mt-6 space-y-4">
        <h3 class="text-xs font-bold text-slate-400 uppercase tracking-widest px-1">
            Riwayat Pinjaman
        </h3>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            @forelse($pinjaman as $item)
            <div class="bg-white rounded-3xl border border-slate-100 shadow-sm overflow-hidden flex flex-col justify-between">
                
                <div class="p-5 space-y-4">
                    
                    <div class="flex items-start justify-between gap-4">
                        <div>
                            <div class="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Nominal Pinjaman</div>
                            <div class="text-base font-extrabold text-slate-800 mt-0.5">
                                Rp {{ number_format($item->nominal, 0, ',', '.') }}
                            </div>
                        </div>

                        <!-- Status Badges -->
                        <div>
                            @if($item->status == 'pending')
                            <span class="badge-pill badge-pending">
                                <span class="w-1.5 h-1.5 rounded-full bg-amber-500"></span>
                                Pending
                            </span>
                            @elseif($item->status == 'approved')
                            <span class="badge-pill badge-approved">
                                <span class="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>
                                Aktif
                            </span>
                            @elseif($item->status == 'rejected')
                            <span class="badge-pill badge-rejected">
                                <span class="w-1.5 h-1.5 rounded-full bg-rose-500"></span>
                                Rejected
                            </span>
                            @elseif($item->status == 'lunas')
                            <span class="badge-pill badge-approved">
                                <span class="w-1.5 h-1.5 rounded-full bg-cyan-500"></span>
                                Lunas
                            </span>
                            @endif
                        </div>
                    </div>

                    <!-- Terms & Installments breakdown -->
                    <div class="grid grid-cols-2 gap-y-3 gap-x-2 pt-3 border-t border-slate-50 text-[11px]">
                        <div>
                            <div class="text-[9px] text-slate-400 uppercase tracking-wider">Bunga</div>
                            <div class="font-bold text-slate-700 mt-0.5">{{ $item->persen_bunga }}%</div>
                        </div>
                        <div>
                            <div class="text-[9px] text-slate-400 uppercase tracking-wider">Tenor</div>
                            <div class="font-bold text-slate-700 mt-0.5">{{ $item->tenor_bulan }} Bulan</div>
                        </div>
                        <div>
                            <div class="text-[9px] text-slate-400 uppercase tracking-wider">Angsuran/Bulan</div>
                            <div class="font-bold text-slate-700 mt-0.5">Rp {{ number_format($item->angsuran_per_bulan, 0, ',', '.') }}</div>
                        </div>
                        <div>
                            <div class="text-[9px] text-slate-400 uppercase tracking-wider">Sisa Hutang</div>
                            <div class="font-bold text-rose-600 mt-0.5">Rp {{ number_format($item->sisa_pinjaman, 0, ',', '.') }}</div>
                        </div>
                    </div>

                </div>

                <!-- Footer button link for active contract -->
                @if($item->status == 'approved')
                <div class="px-5 py-3.5 bg-slate-50/80 border-t border-slate-100 flex items-center justify-between">
                    <span class="text-[10px] text-slate-500">Pantau jadwal angsuran</span>
                    <a href="{{ route('pembayaran.index') }}" class="text-[10px] font-bold text-teal-600 hover:text-teal-700 flex items-center gap-1 transition tap-scale">
                        <span>Bayar Tagihan</span>
                        <i class="ti ti-chevron-right"></i>
                    </a>
                </div>
                @endif

            </div>
            @empty
            <div class="col-span-full bg-white rounded-3xl p-10 border border-slate-100 text-center">
                <div class="w-16 h-16 mx-auto rounded-full bg-slate-50 flex items-center justify-center">
                    <i class="ti ti-cash-banknote text-slate-400 text-3xl"></i>
                </div>
                <h4 class="font-bold text-slate-800 mt-4">Belum Ada Pinjaman</h4>
                <p class="text-xs text-slate-500 mt-1 max-w-[200px] mx-auto leading-relaxed">
                    Anda belum memiliki riwayat pengajuan pinjaman tunai.
                </p>
                @if($bolehAjukan)
                <a href="{{ route('pinjaman.create') }}" class="inline-flex items-center gap-1.5 mt-5 px-4 py-2 rounded-xl bg-teal-600 hover:bg-teal-700 text-white font-semibold text-xs transition tap-scale">
                    <i class="ti ti-plus"></i>
                    <span>Ajukan Sekarang</span>
                </a>
                @endif
            </div>
            @endforelse
        </div>

        <!-- MOBILE FRIENDLY PAGINATION -->
        <div class="mt-4">
            @if ($pinjaman->hasPages())
            <div class="flex items-center justify-between px-3 py-2 bg-white border border-slate-100 rounded-2xl shadow-sm text-xs">
                @if ($pinjaman->onFirstPage())
                    <span class="px-3 py-1.5 rounded-lg bg-slate-50 text-slate-400 border border-slate-200 cursor-default select-none font-semibold">
                        Sebelumnya
                    </span>
                @else
                    <a href="{{ $pinjaman->previousPageUrl() }}" class="px-3 py-1.5 rounded-lg bg-white text-slate-700 border border-slate-200 hover:bg-slate-50 transition font-semibold tap-scale">
                        Sebelumnya
                    </a>
                @endif

                <span class="text-slate-500 font-medium">
                    Hal {{ $pinjaman->currentPage() }} dari {{ $pinjaman->lastPage() }}
                </span>

                @if ($pinjaman->hasMorePages())
                    <a href="{{ $pinjaman->nextPageUrl() }}" class="px-3 py-1.5 rounded-lg bg-white text-slate-700 border border-slate-200 hover:bg-slate-50 transition font-semibold tap-scale">
                        Berikutnya
                    </a>
                @else
                    <span class="px-3 py-1.5 rounded-lg bg-slate-50 text-slate-400 border border-slate-200 cursor-default select-none font-semibold">
                        Berikutnya
                    </span>
                @endif
            </div>
            @endif
        </div>

    </div>

</x-app-layout>