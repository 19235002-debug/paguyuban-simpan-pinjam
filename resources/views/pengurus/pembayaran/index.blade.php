<x-app-layout>

    <x-slot name="header">
        <div class="flex items-center gap-3">
            <a href="{{ route('dashboard') }}" class="w-10 h-10 rounded-xl bg-white border border-slate-200/60 flex items-center justify-center text-slate-600 hover:text-slate-800 transition tap-scale">
                <i class="ti ti-arrow-left text-lg"></i>
            </a>
            <div>
                <h2 class="text-lg font-bold text-slate-800">
                    Approval Angsuran
                </h2>
                <p class="text-[11px] text-slate-500">
                    Verifikasi pembayaran angsuran bulanan dari anggota
                </p>
            </div>
        </div>
    </x-slot>

    <!-- ADMIN METRICS SUMMARY -->
    <div class="grid grid-cols-3 gap-2 mt-4">
        <div class="bg-white rounded-2xl p-3 border border-slate-100 shadow-sm text-center">
            <span class="text-[8px] font-bold text-slate-400 uppercase tracking-wider block">Antrian</span>
            <span class="text-base font-extrabold text-amber-600 mt-0.5 block">
                {{ $pembayaran->total() }}
            </span>
        </div>
        <div class="bg-white rounded-2xl p-3 border border-slate-100 shadow-sm text-center">
            <span class="text-[8px] font-bold text-slate-400 uppercase tracking-wider block">Total Nominal</span>
            <span class="text-xs font-bold text-teal-600 mt-1 block truncate">
                Rp {{ number_format($pembayaran->sum('nominal'), 0, ',', '.') }}
            </span>
        </div>
        <div class="bg-white rounded-2xl p-3 border border-slate-100 shadow-sm text-center">
            <span class="text-[8px] font-bold text-slate-400 uppercase tracking-wider block">Hari Ini</span>
            <span class="text-base font-extrabold text-slate-800 mt-0.5 block">
                {{ $pembayaran->where('created_at','>=',now()->startOfDay())->count() }}
            </span>
        </div>
    </div>

    <!-- APPROVAL ITEM LIST -->
    <div class="space-y-4 mt-5">
        <h3 class="text-xs font-bold text-slate-400 uppercase tracking-widest px-1">
            Daftar Setoran Angsuran Pending
        </h3>

        <!-- RESPONSIVE GRID -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            @forelse($pembayaran as $item)
            @php
                $memberName = '-';
                if ($item->source_type === 'pinjaman') {
                    $memberName = optional($item->pinjaman?->user)->name ?? '-';
                } elseif ($item->source_type === 'kredit_barang') {
                    $memberName = optional($item->kreditBarang?->user)->name ?? '-';
                }
            @endphp
            <div class="bg-white rounded-3xl p-5 border border-slate-100 shadow-sm space-y-4 flex flex-col justify-between">
                
                <div class="space-y-4">
                    <div class="flex justify-between items-start gap-4">
                        <div>
                            <!-- Member and loan details -->
                            <h4 class="font-bold text-slate-800 text-sm">
                                {{ $memberName }}
                            </h4>
                            <span class="text-[10px] text-slate-500 mt-1 block">
                                Jenis: <strong class="text-slate-700">{{ $item->jenis }}</strong>
                            </span>
                            <span class="text-[10px] text-slate-500 mt-0.5 block">
                                Angsuran Ke-{{ $item->angsuran_ke }}
                            </span>
                            <span class="text-[10px] text-slate-400 mt-0.5 block">
                                Kirim: {{ optional($item->tanggal_bayar)->format('d M Y') }}
                            </span>
                        </div>

                        <!-- Price tag -->
                        <div class="text-right flex-shrink-0">
                            <span class="text-[9px] text-slate-400 block font-semibold uppercase">Nominal Bayar</span>
                            <span class="text-xs font-extrabold text-teal-600 mt-0.5 block">
                                Rp {{ number_format($item->nominal, 0, ',', '.') }}
                            </span>
                        </div>
                    </div>

                    <!-- Receipt view widget -->
                    <div class="bg-slate-50 rounded-2xl p-3 border border-slate-100 flex items-center justify-between">
                        <span class="text-[9px] font-medium text-slate-600">Lampiran bukti:</span>
                        @if($item->bukti_transfer)
                        <a href="{{ asset('storage/'.$item->bukti_transfer) }}" 
                           target="_blank" 
                           class="text-[10px] font-bold text-teal-600 bg-white border border-slate-200 px-3 py-1.5 rounded-xl shadow-xs transition tap-scale flex items-center gap-1">
                            <i class="ti ti-eye"></i>
                            <span>Lihat Bukti</span>
                        </a>
                        @else
                        <span class="text-[9px] text-slate-400">Tidak ada bukti</span>
                        @endif
                    </div>
                </div>

                <!-- Action buttons stack -->
                <div class="flex gap-3 pt-1">
                    
                    <!-- Reject Action Form -->
                    <form class="flex-1 reject-form" method="POST" action="{{ route('pengurus.pembayaran.reject', $item->id) }}">
                        @csrf
                        <button type="submit" class="w-full py-2.5 rounded-xl bg-rose-50 hover:bg-rose-100 text-rose-600 font-bold text-xs transition tap-scale flex items-center justify-center gap-1">
                            <i class="ti ti-x"></i>
                            <span>Reject</span>
                        </button>
                    </form>

                    <!-- Approve Action Form -->
                    <form class="flex-1 approve-form" method="POST" action="{{ route('pengurus.pembayaran.approve', $item->id) }}">
                        @csrf
                        <button type="submit" class="w-full py-2.5 rounded-xl bg-teal-600 hover:bg-teal-700 text-white font-bold text-xs transition tap-scale flex items-center justify-center gap-1 shadow-md shadow-teal-600/10">
                            <i class="ti ti-check"></i>
                            <span>Approve</span>
                        </button>
                    </form>

                </div>

            </div>
            @empty
            <div class="col-span-full bg-white rounded-3xl p-10 border border-slate-100 text-center">
                <div class="w-16 h-16 mx-auto rounded-full bg-slate-50 flex items-center justify-center">
                    <i class="ti ti-clipboard-check text-slate-400 text-3xl"></i>
                </div>
                <h4 class="font-bold text-slate-800 mt-4">Semua Terproses</h4>
                <p class="text-xs text-slate-500 mt-1 max-w-[200px] mx-auto leading-relaxed">
                    Tidak ada pengajuan setoran angsuran pending.
                </p>
            </div>
            @endforelse
        </div>

        <!-- MOBILE FRIENDLY PAGINATION -->
        <div class="mt-4">
            @if ($pembayaran->hasPages())
            <div class="flex items-center justify-between px-3 py-2 bg-white border border-slate-100 rounded-2xl shadow-sm text-xs">
                @if ($pembayaran->onFirstPage())
                    <span class="px-3 py-1.5 rounded-lg bg-slate-50 text-slate-400 border border-slate-200 cursor-default select-none font-semibold">
                        Sebelumnya
                    </span>
                @else
                    <a href="{{ $pembayaran->previousPageUrl() }}" class="px-3 py-1.5 rounded-lg bg-white text-slate-700 border border-slate-200 hover:bg-slate-50 transition font-semibold tap-scale">
                        Sebelumnya
                    </a>
                @endif

                <span class="text-slate-500 font-medium">
                    Hal {{ $pembayaran->currentPage() }} dari {{ $pembayaran->lastPage() }}
                </span>

                @if ($pembayaran->hasMorePages())
                    <a href="{{ $pembayaran->nextPageUrl() }}" class="px-3 py-1.5 rounded-lg bg-white text-slate-700 border border-slate-200 hover:bg-slate-50 transition font-semibold tap-scale">
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

    <!-- SWEETALERT APPROVAL ACTIONS -->
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            function bindSweetAlert(selector, config) {
                document.querySelectorAll(selector).forEach(form => {
                    form.addEventListener('submit', function(e) {
                        e.preventDefault();
                        Swal.fire({
                            title: config.title,
                            text: config.text,
                            icon: config.icon,
                            showCancelButton: true,
                            confirmButtonColor: config.confirmColor,
                            cancelButtonColor: '#6b7280',
                            confirmButtonText: config.confirmText,
                            customClass: { popup: 'rounded-2xl' }
                        }).then((result) => {
                            if (result.isConfirmed) {
                                Swal.fire({
                                    title: 'Memproses...',
                                    text: 'Mohon tunggu',
                                    allowOutsideClick: false,
                                    didOpen: () => Swal.showLoading()
                                });
                                form.submit();
                            }
                        });
                    });
                });
            }

            bindSweetAlert('.approve-form', {
                title: 'Setujui Pembayaran?',
                text: 'Angsuran bulanan ini akan ditandai LUNAS.',
                icon: 'question',
                confirmColor: '#0d9488',
                confirmText: 'Approve'
            });

            bindSweetAlert('.reject-form', {
                title: 'Tolak Pembayaran?',
                text: 'Kirim penolakan dan kembalikan ke status Belum Bayar.',
                icon: 'warning',
                confirmColor: '#dc2626',
                confirmText: 'Tolak'
            });
        });
    </script>

</x-app-layout>