<x-app-layout>

    <x-slot name="header">
        <div class="flex items-center gap-3">
            <a href="{{ route('dashboard') }}" class="w-10 h-10 rounded-xl bg-white border border-slate-200/60 flex items-center justify-center text-slate-600 hover:text-slate-800 transition tap-scale">
                <i class="ti ti-arrow-left text-lg"></i>
            </a>
            <div>
                <h2 class="text-lg font-bold text-slate-800">
                    Data Anggota
                </h2>
                <p class="text-[11px] text-slate-500">
                    Monitoring keanggotaan dan rekap transaksi koperasi
                </p>
            </div>
        </div>
    </x-slot>

    <div class="space-y-4 mt-4">
        
        <!-- COMPACT SEARCH INPUT -->
        <form method="GET" class="bg-white rounded-2xl border border-slate-100 p-3 shadow-sm flex gap-2">
            <div class="relative flex-1">
                <div class="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400">
                    <i class="ti ti-search text-base"></i>
                </div>
                <input type="text" 
                       name="search" 
                       value="{{ request('search') }}" 
                       placeholder="Cari nama / email..." 
                       class="w-full h-10 pl-9 pr-4 rounded-xl border-slate-200 focus:border-teal-500 focus:ring-teal-500 text-xs">
            </div>
            <button class="px-4 py-2 bg-teal-600 hover:bg-teal-700 text-white rounded-xl text-xs font-semibold shadow transition tap-scale flex items-center gap-1">
                <span>Cari</span>
            </button>
        </form>

        <!-- ADMIN SUMMARY HEADER -->
        <div class="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm flex items-center justify-between text-xs">
            <div class="flex items-center gap-2">
                <div class="w-8 h-8 rounded-lg bg-teal-50 text-teal-600 flex items-center justify-center">
                    <i class="ti ti-users text-lg"></i>
                </div>
                <div>
                    <span class="text-slate-400 block text-[9px] uppercase tracking-wider font-bold">Total Anggota</span>
                    <span class="font-bold text-slate-700 block mt-0.5">{{ $anggota->total() }} Anggota</span>
                </div>
            </div>
            <a href="{{ route('pengurus.laporan.print', 'rekap_anggota') }}" target="_blank"
               class="px-3.5 py-2 bg-teal-600 hover:bg-teal-700 text-white rounded-xl text-[10px] font-bold shadow flex items-center gap-1.5 transition tap-scale">
                <i class="ti ti-printer text-xs"></i>
                <span>Cetak Rekap PDF</span>
            </a>
        </div>

        <!-- DIRECTORY LIST OF MEMBERS (CARDS GRID) -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            @forelse($anggota as $user)
            <a href="{{ route('pengurus.anggota.show', $user->id) }}" 
               class="block bg-white rounded-3xl p-5 border border-slate-100 shadow-sm hover:shadow-md transition tap-scale flex flex-col justify-between">
                
                <div>
                    <div class="flex justify-between items-start gap-4">
                        <div>
                            <!-- Profile/Name header -->
                            <h4 class="font-bold text-slate-800 text-sm">
                                {{ $user->name }}
                            </h4>
                            <span class="text-[10px] text-slate-400 mt-0.5 block">
                                {{ $user->email }}
                            </span>
                        </div>

                        <!-- Status Indicator Pill -->
                        <div class="flex-shrink-0">
                            @if(($user->total_pinjaman ?? 0) > 0)
                            <span class="badge-pill badge-rejected">
                                <span class="w-1 h-1 rounded-full bg-rose-500"></span>
                                Ada Pinjaman
                            </span>
                            @else
                            <span class="badge-pill badge-approved">
                                <span class="w-1 h-1 rounded-full bg-emerald-500"></span>
                                Aman
                            </span>
                            @endif
                        </div>
                    </div>

                    <!-- Transaction balance statistics -->
                    <div class="grid grid-cols-2 gap-3 mt-4 text-[11px] pt-3 border-t border-slate-50">
                        <div class="bg-slate-50/50 rounded-xl p-2.5 border border-slate-100 text-center">
                            <span class="text-slate-400 block">Total Simpanan</span>
                            <span class="font-extrabold text-emerald-600 mt-0.5 block">
                                Rp {{ number_format($user->total_simpanan ?? 0, 0, ',', '.') }}
                            </span>
                        </div>

                        <div class="bg-slate-50/50 rounded-xl p-2.5 border border-slate-100 text-center">
                            <span class="text-slate-400 block">Total Pinjaman</span>
                            <span class="font-extrabold text-rose-600 mt-0.5 block">
                                Rp {{ number_format($user->total_pinjaman ?? 0, 0, ',', '.') }}
                            </span>
                        </div>
                    </div>
                </div>

                <div class="mt-4 flex justify-between items-center text-[9px] text-slate-400 pt-2 border-t border-slate-50/50">
                    <span>Bergabung: {{ $user->created_at->format('d M Y') }}</span>
                    <span class="font-bold text-teal-600 flex items-center gap-0.5">
                        <span>Detail</span>
                        <i class="ti ti-chevron-right"></i>
                    </span>
                </div>

            </a>
            @empty
            <div class="col-span-full bg-white rounded-3xl p-10 border border-slate-100 text-center">
                <div class="w-16 h-16 mx-auto rounded-full bg-slate-50 flex items-center justify-center">
                    <i class="ti ti-users text-slate-400 text-3xl"></i>
                </div>
                <h4 class="font-bold text-slate-800 mt-4">Anggota Tidak Ditemukan</h4>
                <p class="text-xs text-slate-500 mt-1 max-w-[200px] mx-auto leading-relaxed">
                    Tidak ada data anggota dengan pencarian "{{ request('search') }}".
                </p>
            </div>
            @endforelse
        </div>

        <!-- MOBILE FRIENDLY PAGINATION -->
        <div class="mt-4">
            @if ($anggota->hasPages())
            <div class="flex items-center justify-between px-3 py-2 bg-white border border-slate-100 rounded-2xl shadow-sm text-xs">
                @if ($anggota->onFirstPage())
                    <span class="px-3 py-1.5 rounded-lg bg-slate-50 text-slate-400 border border-slate-200 cursor-default select-none font-semibold">
                        Sebelumnya
                    </span>
                @else
                    <a href="{{ $anggota->previousPageUrl() }}" class="px-3 py-1.5 rounded-lg bg-white text-slate-700 border border-slate-200 hover:bg-slate-50 transition font-semibold tap-scale">
                        Sebelumnya
                    </a>
                @endif

                <span class="text-slate-500 font-medium">
                    Hal {{ $anggota->currentPage() }} dari {{ $anggota->lastPage() }}
                </span>

                @if ($anggota->hasMorePages())
                    <a href="{{ $anggota->nextPageUrl() }}" class="px-3 py-1.5 rounded-lg bg-white text-slate-700 border border-slate-200 hover:bg-slate-50 transition font-semibold tap-scale">
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