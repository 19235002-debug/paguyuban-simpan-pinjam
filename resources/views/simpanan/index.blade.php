<x-app-layout>

    <x-slot name="header">
        <div class="flex items-center justify-between">
            <div>
                <h2 class="text-lg font-bold text-slate-800">
                    Simpanan Saya
                </h2>
                <p class="text-[11px] text-slate-500">
                    Riwayat simpanan wajib bulanan Anda
                </p>
            </div>
            <a href="{{ route('simpanan.create') }}"
                class="px-4 py-2.5 bg-teal-600 hover:bg-teal-700 text-white rounded-xl font-semibold text-xs transition tap-scale flex items-center gap-1.5">
                <i class="ti ti-plus"></i>
                <span>Bayar</span>
            </a>
        </div>
    </x-slot>

    <!-- LIST OF SAVINGS CARDS -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 mt-4">
        
        @forelse($simpanan as $item)
        <div class="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm flex flex-col justify-between gap-3">
            
            <div class="flex items-start justify-between">
                <div>
                    <!-- Savings Type/Month -->
                    <span class="text-xs font-semibold text-slate-800">
                        Simpanan {{ ucfirst($item->jenis) }}
                    </span>
                    <!-- Payment Date -->
                    <div class="text-[10px] text-slate-400 mt-0.5">
                        {{ optional($item->tanggal_bayar)->format('d M Y') }}
                    </div>
                </div>

                <!-- Status Badge -->
                <div>
                    @if($item->status == 'pending')
                    <span class="badge-pill badge-pending">
                        <span class="w-1.5 h-1.5 rounded-full bg-amber-500"></span>
                        Pending
                    </span>
                    @elseif($item->status == 'approved')
                    <span class="badge-pill badge-approved">
                        <span class="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>
                        Approved
                    </span>
                    @else
                    <span class="badge-pill badge-rejected">
                        <span class="w-1.5 h-1.5 rounded-full bg-rose-500"></span>
                        Rejected
                    </span>
                    @endif
                </div>
            </div>

            <!-- Total Paid & Receipt Button -->
            <div class="flex items-center justify-between pt-2 border-t border-slate-50">
                <div>
                    <div class="text-[9px] text-slate-400 uppercase tracking-wider">Total Nominal</div>
                    <div class="font-bold text-sm text-slate-800 mt-0.5">
                        Rp {{ number_format($item->total_bayar, 0, ',', '.') }}
                    </div>
                </div>

                @if($item->bukti_transfer)
                <a href="{{ asset('storage/'.$item->bukti_transfer) }}"
                    target="_blank"
                    class="text-xs font-semibold text-teal-600 hover:text-teal-700 bg-teal-50 px-3 py-1.5 rounded-xl border border-teal-100/50 flex items-center gap-1 transition tap-scale">
                    <i class="ti ti-file-text"></i>
                    <span>Bukti</span>
                </a>
                @else
                <span class="text-xs text-slate-400">-</span>
                @endif
            </div>

        </div>
        @empty
        <div class="col-span-full bg-white rounded-3xl p-10 border border-slate-100 text-center">
            <div class="w-16 h-16 mx-auto rounded-full bg-slate-50 flex items-center justify-center">
                <i class="ti ti-wallet text-slate-400 text-3xl"></i>
            </div>
            <h4 class="font-bold text-slate-800 mt-4">Belum Ada Simpanan</h4>
            <p class="text-xs text-slate-500 mt-1 max-w-[200px] mx-auto leading-relaxed">
                Anda belum pernah menyetorkan simpanan wajib bulanan.
            </p>
            <a href="{{ route('simpanan.create') }}" class="inline-flex items-center gap-1.5 mt-5 px-4 py-2 rounded-xl bg-teal-600 hover:bg-teal-700 text-white font-semibold text-xs transition tap-scale">
                <i class="ti ti-plus"></i>
                <span>Setor Sekarang</span>
            </a>
        </div>
        @endforelse

        <!-- MOBILE FRIENDLY PAGINATION -->
        <div class="col-span-full mt-4">
            @if ($simpanan->hasPages())
            <div class="flex items-center justify-between px-3 py-2 bg-white border border-slate-100 rounded-2xl shadow-sm text-xs">
                @if ($simpanan->onFirstPage())
                    <span class="px-3 py-1.5 rounded-lg bg-slate-50 text-slate-400 border border-slate-200 cursor-default select-none font-semibold">
                        Sebelumnya
                    </span>
                @else
                    <a href="{{ $simpanan->previousPageUrl() }}" class="px-3 py-1.5 rounded-lg bg-white text-slate-700 border border-slate-200 hover:bg-slate-50 transition font-semibold tap-scale">
                        Sebelumnya
                    </a>
                @endif

                <span class="text-slate-500 font-medium">
                    Hal {{ $simpanan->currentPage() }} dari {{ $simpanan->lastPage() }}
                </span>

                @if ($simpanan->hasMorePages())
                    <a href="{{ $simpanan->nextPageUrl() }}" class="px-3 py-1.5 rounded-lg bg-white text-slate-700 border border-slate-200 hover:bg-slate-50 transition font-semibold tap-scale">
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
