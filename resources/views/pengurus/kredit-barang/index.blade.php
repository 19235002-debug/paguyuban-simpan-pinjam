<x-app-layout>

    <x-slot name="header">
        <div class="flex items-center gap-3">
            <a href="{{ route('dashboard') }}" class="w-10 h-10 rounded-xl bg-white border border-slate-200/60 flex items-center justify-center text-slate-600 hover:text-slate-800 transition tap-scale">
                <i class="ti ti-arrow-left text-lg"></i>
            </a>
            <div>
                <h2 class="text-lg font-bold text-slate-800">
                    Approval Kredit Barang
                </h2>
                <p class="text-[11px] text-slate-500">
                    Verifikasi pengajuan kredit pengadaan barang baru dari anggota
                </p>
            </div>
        </div>
    </x-slot>

    <!-- ADMIN METRICS SUMMARY -->
    <div class="grid grid-cols-3 gap-2 mt-4">
        <div class="bg-white rounded-2xl p-3 border border-slate-100 shadow-sm text-center">
            <span class="text-[8px] font-bold text-slate-400 uppercase tracking-wider block">Antrian</span>
            <span class="text-base font-extrabold text-amber-600 mt-0.5 block">
                {{ $kreditBarang->total() }}
            </span>
        </div>
        <div class="bg-white rounded-2xl p-3 border border-slate-100 shadow-sm text-center">
            <span class="text-[8px] font-bold text-slate-400 uppercase tracking-wider block">Total Pengajuan</span>
            <span class="text-xs font-bold text-teal-600 mt-1 block truncate">
                Rp {{ number_format($kreditBarang->sum('total_tagihan'), 0, ',', '.') }}
            </span>
        </div>
        <div class="bg-white rounded-2xl p-3 border border-slate-100 shadow-sm text-center">
            <span class="text-[8px] font-bold text-slate-400 uppercase tracking-wider block">Hari Ini</span>
            <span class="text-base font-extrabold text-slate-800 mt-0.5 block">
                {{ $kreditBarang->where('created_at','>=',now()->startOfDay())->count() }}
            </span>
        </div>
    </div>

    <!-- APPROVAL ITEM LIST -->
    <div class="space-y-4 mt-5">
        <h3 class="text-xs font-bold text-slate-400 uppercase tracking-widest px-1">
            Daftar Pengajuan Pending
        </h3>

        <!-- RESPONSIVE GRID -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            @forelse($kreditBarang as $item)
            <div class="bg-white rounded-3xl p-5 border border-slate-100 shadow-sm space-y-4 flex flex-col justify-between">
                
                <div class="space-y-4">
                    <div class="flex justify-between items-start gap-4">
                        <div>
                            <!-- Member info -->
                            <h4 class="font-bold text-slate-800 text-sm">
                                {{ $item->user->name }}
                            </h4>
                            <span class="text-[10px] text-slate-400 mt-0.5 block">
                                Barang: <strong class="text-slate-700">{{ $item->nama_barang }}</strong>
                            </span>
                            @if($item->keterangan)
                            <span class="text-[9px] text-slate-400 mt-0.5 block leading-relaxed max-w-[200px]">
                                Info: {{ Str::limit($item->keterangan, 60) }}
                            </span>
                            @endif
                            <span class="text-[9px] text-slate-400 mt-0.5 block">
                                Diajukan: {{ $item->created_at->format('d M Y') }}
                            </span>
                        </div>

                        <!-- Price tag -->
                        <div class="text-right flex-shrink-0">
                            <span class="text-[9px] text-slate-400 block font-semibold uppercase">Harga Barang</span>
                            <span class="text-xs font-extrabold text-slate-800 mt-0.5 block">
                                Rp {{ number_format($item->harga_barang, 0, ',', '.') }}
                            </span>
                        </div>
                    </div>

                    <!-- Financial breakdown for credit terms -->
                    <div class="grid grid-cols-3 gap-2 p-3 bg-slate-50 rounded-2xl border border-slate-100 text-center text-[10px]">
                        <div>
                            <span class="text-slate-400 block">Bunga</span>
                            <span class="font-bold text-slate-700 mt-0.5 block">{{ $item->persen_bunga }}%</span>
                        </div>
                        <div>
                            <span class="text-slate-400 block">Tenor</span>
                            <span class="font-bold text-slate-700 mt-0.5 block">{{ $item->tenor_bulan }} Bln</span>
                        </div>
                        <div>
                            <span class="text-slate-400 block">Cicilan/Bln</span>
                            <span class="font-bold text-teal-600 mt-0.5 block truncate">Rp {{ number_format($item->angsuran_per_bulan, 0, ',', '.') }}</span>
                        </div>
                    </div>
                </div>

                <!-- Action buttons stack -->
                <div class="flex gap-3 pt-1">
                    
                    <!-- Reject Action Form -->
                    <form class="flex-1 reject-form" method="POST" action="{{ route('pengurus.kredit-barang.reject', $item->id) }}">
                        @csrf
                        <button type="submit" class="w-full py-2.5 rounded-xl bg-rose-50 hover:bg-rose-100 text-rose-600 font-bold text-xs transition tap-scale flex items-center justify-center gap-1">
                            <i class="ti ti-x"></i>
                            <span>Reject</span>
                        </button>
                    </form>

                    <!-- Approve Action Form -->
                    <form class="flex-1 approve-form" method="POST" action="{{ route('pengurus.kredit-barang.approve', $item->id) }}">
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
                    Tidak ada pengajuan kredit barang pending.
                </p>
            </div>
            @endforelse
        </div>

        <!-- MOBILE FRIENDLY PAGINATION -->
        <div class="mt-4">
            @if ($kreditBarang->hasPages())
            <div class="flex items-center justify-between px-3 py-2 bg-white border border-slate-100 rounded-2xl shadow-sm text-xs">
                @if ($kreditBarang->onFirstPage())
                    <span class="px-3 py-1.5 rounded-lg bg-slate-50 text-slate-400 border border-slate-200 cursor-default select-none font-semibold">
                        Sebelumnya
                    </span>
                @else
                    <a href="{{ $kreditBarang->previousPageUrl() }}" class="px-3 py-1.5 rounded-lg bg-white text-slate-700 border border-slate-200 hover:bg-slate-50 transition font-semibold tap-scale">
                        Sebelumnya
                    </a>
                @endif

                <span class="text-slate-500 font-medium">
                    Hal {{ $kreditBarang->currentPage() }} dari {{ $kreditBarang->lastPage() }}
                </span>

                @if ($kreditBarang->hasMorePages())
                    <a href="{{ $kreditBarang->nextPageUrl() }}" class="px-3 py-1.5 rounded-lg bg-white text-slate-700 border border-slate-200 hover:bg-slate-50 transition font-semibold tap-scale">
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

    <!-- SWEETALERT SCRIPT FOR FORM SUBMISSIONS -->
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            function bindSweetAlert(selector, options) {
                document.querySelectorAll(selector).forEach(form => {
                    form.addEventListener('submit', function(e) {
                        e.preventDefault();
                        Swal.fire(options).then((result) => {
                            if (result.isConfirmed) {
                                Swal.fire({
                                    title: 'Memproses...',
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
                title: 'Approve Kredit?',
                text: 'Kredit barang akan disetujui & angsuran otomatis ter-generate!',
                icon: 'question',
                showCancelButton: true,
                confirmButtonColor: '#0d9488',
                cancelButtonColor: '#6b7280',
                confirmButtonText: 'Approve',
                cancelButtonText: 'Batal',
                customClass: { popup: 'rounded-2xl' }
            });

            bindSweetAlert('.reject-form', {
                title: 'Tolak Kredit?',
                text: 'Kredit barang anggota akan ditolak!',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#dc2626',
                cancelButtonColor: '#6b7280',
                confirmButtonText: 'Tolak',
                cancelButtonText: 'Batal',
                customClass: { popup: 'rounded-2xl' }
            });
        });
    </script>

</x-app-layout>