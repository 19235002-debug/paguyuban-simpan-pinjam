<x-app-layout>

    <x-slot name="header">
        <div class="flex items-center justify-between">
            <div>
                <h2 class="text-lg font-bold text-slate-800">
                    Kredit Barang Saya
                </h2>
                <p class="text-[11px] text-slate-500">
                    Riwayat dan status kredit pengadaan barang Anda
                </p>
            </div>
            @if($bolehAjukan)
            <a href="{{ route('kredit-barang.create') }}"
                class="px-4 py-2.5 bg-teal-600 hover:bg-teal-700 text-white rounded-xl font-semibold text-xs transition tap-scale flex items-center gap-1.5">
                <i class="ti ti-plus"></i>
                <span>Ajukan Kredit</span>
            </a>
            @endif
        </div>
    </x-slot>

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

    <!-- KREDIT GOODS CARD GRID (RESPONSIVE) -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 mt-4">
        
        @forelse($kreditBarang as $item)
        <div class="bg-white rounded-3xl border border-slate-100 shadow-sm overflow-hidden flex flex-col justify-between">
            
            <!-- IMAGE PREVIEW HEADER -->
            <div class="relative h-36 bg-slate-100 flex items-center justify-center">
                @if($item->foto_barang)
                <img src="{{ asset('storage/'.$item->foto_barang) }}" class="w-full h-full object-cover">
                @else
                <div class="flex flex-col items-center justify-center text-slate-400">
                    <i class="ti ti-photo text-3xl"></i>
                    <span class="text-[10px] mt-1 font-semibold">Tidak Foto</span>
                </div>
                @endif

                <!-- Dynamic Status Badge -->
                <div class="absolute top-3 right-3">
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
                    @elseif($item->status == 'rejected')
                    <span class="badge-pill badge-rejected">
                        <span class="w-1.5 h-1.5 rounded-full bg-rose-500"></span>
                        Rejected
                    </span>
                    @else
                    <span class="badge-pill badge-approved">
                        <span class="w-1.5 h-1.5 rounded-full bg-cyan-500"></span>
                        Lunas
                    </span>
                    @endif
                </div>
            </div>

            <!-- CARD DETAIL AREA -->
            <div class="p-4 space-y-3">
                <div>
                    <h3 class="font-bold text-slate-800 text-sm">
                        {{ $item->nama_barang }}
                    </h3>
                    @if($item->keterangan)
                    <p class="text-[10px] text-slate-500 mt-1 leading-relaxed">
                        {{ Str::limit($item->keterangan, 75) }}
                    </p>
                    @endif
                </div>

                <!-- Terms Breakdown -->
                <div class="grid grid-cols-2 gap-y-2.5 gap-x-2 pt-3 border-t border-slate-50 text-[11px]">
                    <div class="flex justify-between items-center pr-2 border-r border-slate-50">
                        <span class="text-slate-400">Harga</span>
                        <span class="font-bold text-slate-700">Rp {{ number_format($item->harga_barang, 0, ',', '.') }}</span>
                    </div>
                    <div class="flex justify-between items-center pl-2">
                        <span class="text-slate-400">Bunga</span>
                        <span class="font-bold text-slate-700">{{ $item->persen_bunga }}%</span>
                    </div>
                    <div class="flex justify-between items-center pr-2 border-r border-slate-50">
                        <span class="text-slate-400">Tenor</span>
                        <span class="font-bold text-slate-700">{{ $item->tenor_bulan }} Bln</span>
                    </div>
                    <div class="flex justify-between items-center pl-2">
                        <span class="text-slate-400">Angsuran</span>
                        <span class="font-extrabold text-teal-600">Rp {{ number_format($item->angsuran_per_bulan, 0, ',', '.') }}</span>
                    </div>
                </div>

            </div>

            <!-- Footer for approved and active credit -->
            @if($item->status == 'approved')
            <div class="px-4 py-3 bg-slate-50 border-t border-slate-100 flex items-center justify-between">
                <span class="text-[9px] text-slate-500">Sisa Tagihan: Rp {{ number_format($item->total_tagihan,0,',','.') }}</span>
                <a href="{{ route('pembayaran.index') }}" class="text-[10px] font-bold text-teal-600 hover:text-teal-700 flex items-center gap-0.5 transition tap-scale">
                    <span>Lihat Tagihan</span>
                    <i class="ti ti-chevron-right"></i>
                </a>
            </div>
            @endif

        </div>
        @empty
        <div class="col-span-full bg-white rounded-3xl p-10 border border-slate-100 text-center">
            <div class="w-16 h-16 mx-auto rounded-full bg-slate-50 flex items-center justify-center">
                <i class="ti ti-shopping-cart text-slate-400 text-3xl"></i>
            </div>
            <h4 class="font-bold text-slate-800 mt-4">Belum Ada Kredit</h4>
            <p class="text-xs text-slate-500 mt-1 max-w-[200px] mx-auto leading-relaxed">
                Anda belum pernah mengajukan kredit barang.
            </p>
            @if($bolehAjukan)
            <a href="{{ route('kredit-barang.create') }}" class="inline-flex items-center gap-1.5 mt-5 px-4 py-2 rounded-xl bg-teal-600 hover:bg-teal-700 text-white font-semibold text-xs transition tap-scale">
                <i class="ti ti-plus"></i>
                <span>Ajukan Sekarang</span>
            </a>
            @endif
        </div>
        @endforelse

        <!-- MOBILE FRIENDLY PAGINATION -->
        <div class="col-span-full mt-2">
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

</x-app-layout>