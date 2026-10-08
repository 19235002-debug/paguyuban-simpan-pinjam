<x-app-layout>

    <x-slot name="header">
        <div>
            <h2 class="text-lg font-bold text-slate-800">
                Tagihan & Angsuran
            </h2>
            <p class="text-[11px] text-slate-500">
                Pantau kewajiban cicilan bulanan Anda
            </p>
        </div>
    </x-slot>

    <!-- COMPACT STATS HEADER -->
    <div class="relative overflow-hidden rounded-3xl bg-gradient-to-br from-emerald-600 to-teal-600 p-5 text-white shadow-lg mb-5">
        <!-- background circles -->
        <div class="absolute -right-6 -top-6 w-24 h-24 bg-white/10 rounded-full blur-sm"></div>
        
        <div class="relative z-10">
            <span class="text-[10px] uppercase font-bold text-teal-100">Total Tagihan Aktif</span>
            <h3 class="text-2xl font-bold mt-1">
                Rp {{ number_format($totalTagihan, 0, ',', '.') }}
            </h3>
            
            <div class="mt-4 flex gap-2 text-[10px] font-semibold">
                <span class="px-2.5 py-1 rounded-lg bg-white/15 backdrop-blur-md">
                    {{ $belumBayar }} Belum Bayar
                </span>
                <span class="px-2.5 py-1 rounded-lg bg-white/15 backdrop-blur-md">
                    {{ $pending }} Pending
                </span>
                <span class="px-2.5 py-1 rounded-lg bg-white/15 backdrop-blur-md">
                    {{ $lunas }} Lunas
                </span>
            </div>
        </div>
    </div>

    <!-- DETAILED LOANS & INSTALLMENTS LIST -->
    <div class="space-y-4">
        
        <h3 class="text-xs font-bold text-slate-400 uppercase tracking-widest px-1">
            Daftar Pembiayaan
        </h3>

        <!-- RESPONSIVE GRID FOR PACKAGES -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
            @forelse($uniqueSources as $source)
            @php
                $sourceKey = $source->source_type . '-' . $source->source_id;
                $items = $groupedPembayaran->get($sourceKey) ?? collect();
                $first = $items->first();
                
                if (!$first) continue;

                $totalAngsuran = $items->count();
                $angsuranLunas = $items->where('status', 'approved')->count();
                $pendingCount = $items->where('status', 'pending')->count();
                $sisaTagihan = $items->whereIn('status', ['belum_bayar', 'pending', 'rejected'])->sum('nominal');
                $totalNominal = $items->sum('nominal');
                
                $progress = $totalAngsuran > 0 ? round(($angsuranLunas / $totalAngsuran) * 100) : 0;
            @endphp

            <!-- COLLAPSIBLE PACKAGE CONTAINER (Alpine.js powered) -->
            <div x-data="{ collapsed: true }" class="bg-white rounded-3xl border border-slate-100 shadow-sm overflow-hidden transition-all self-start">
                
                <!-- PACKAGE HEADER (Click to Expand) -->
                <div @click="collapsed = !collapsed" class="bg-slate-900 text-white p-4 cursor-pointer select-none relative tap-scale">
                    
                    <div class="flex justify-between items-start">
                        <div>
                            <span class="text-[9px] font-bold text-teal-400 uppercase tracking-wider">
                                {{ $first->jenis }}
                            </span>
                            <h4 class="text-sm font-bold mt-0.5">
                                {{ $first->isPinjaman() ? 'Pinjaman Tunai' : ($first->kreditBarang->nama_barang ?? 'Kredit Barang') }}
                            </h4>
                        </div>

                        <!-- Dropdown arrow indicator -->
                        <div class="w-8 h-8 rounded-lg bg-white/10 flex items-center justify-center text-slate-300">
                            <i class="ti text-base transition-transform duration-200" :class="collapsed ? 'ti-chevron-down' : 'ti-chevron-up'"></i>
                        </div>
                    </div>

                    <div class="flex items-center justify-between mt-4 text-[10px] text-slate-400">
                        <span>Progres Pelunasan</span>
                        <span class="font-bold text-teal-400">{{ $progress }}%</span>
                    </div>

                    <!-- Small progress bar -->
                    <div class="w-full h-1 bg-white/10 rounded-full overflow-hidden mt-1.5">
                        <div class="h-full bg-teal-400" style="width: {{ $progress }}%"></div>
                    </div>

                </div>

                <!-- COLLAPSIBLE DETAILS (Shows installments) -->
                <div x-show="!collapsed" x-collapse class="divide-y divide-slate-100 bg-white" style="display: none;">
                    
                    <!-- Package Summary Info -->
                    <div class="p-4 bg-slate-50/50 grid grid-cols-2 gap-y-2 text-[10px] text-slate-600 border-b border-slate-100">
                        <div>
                            <span class="text-slate-400 block">Total Tagihan</span>
                            <span class="font-bold text-slate-700">Rp {{ number_format($totalNominal, 0, ',', '.') }}</span>
                        </div>
                        <div>
                            <span class="text-slate-400 block">Sisa Tagihan</span>
                            <span class="font-bold text-rose-500">Rp {{ number_format($sisaTagihan, 0, ',', '.') }}</span>
                        </div>
                        <div>
                            <span class="text-slate-400 block">Lunas</span>
                            <span class="font-bold text-emerald-600">{{ $angsuranLunas }} / {{ $totalAngsuran }} Bulan</span>
                        </div>
                        <div>
                            <span class="text-slate-400 block">Pending</span>
                            <span class="font-bold text-amber-500">{{ $pendingCount }} Bulan</span>
                        </div>
                    </div>

                    <!-- Installments Lists -->
                    @foreach($items as $item)
                    <div class="p-4 flex flex-col gap-3">
                        <div class="flex items-start justify-between gap-4">
                            <div>
                                <div class="text-xs font-bold text-slate-800">
                                    Angsuran Ke-{{ $item->angsuran_ke }}
                                </div>
                                <div class="text-[10px] text-slate-400 mt-0.5">
                                    Jatuh Tempo: {{ $item->jatuh_tempo->format('d M Y') }}
                                </div>
                            </div>

                            <div class="text-right">
                                <span class="text-xs font-extrabold text-slate-800">
                                    Rp {{ number_format($item->nominal, 0, ',', '.') }}
                                </span>
                            </div>
                        </div>

                        <!-- Status and actions -->
                        <div class="flex items-center justify-between">
                            
                            <!-- Badges -->
                            <div>
                                @if($item->status == 'pending')
                                <span class="badge-pill badge-pending">
                                    <span class="w-1.5 h-1.5 rounded-full bg-amber-500"></span>
                                    Pending
                                </span>
                                @elseif($item->status == 'approved')
                                <span class="badge-pill badge-approved">
                                    <span class="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>
                                    Lunas
                                </span>
                                @elseif($item->status == 'rejected')
                                <span class="badge-pill badge-rejected">
                                    <span class="w-1.5 h-1.5 rounded-full bg-rose-500"></span>
                                    Ditolak
                                </span>
                                @else
                                <span class="badge-pill badge-rejected">
                                    <span class="w-1.5 h-1.5 rounded-full bg-rose-500"></span>
                                    Belum Bayar
                                </span>
                                @endif
                            </div>

                            <!-- Action button -->
                            @if($item->can_pay)
                            <a href="{{ route('pembayaran.bayar', $item->id) }}" 
                               class="px-3.5 py-1.5 rounded-xl bg-teal-600 hover:bg-teal-700 text-white font-bold text-[10px] shadow transition tap-scale flex items-center gap-1">
                                <i class="ti ti-credit-card"></i>
                                <span>Bayar</span>
                            </a>
                            @endif

                        </div>

                        @if($item->status == 'rejected')
                        <div class="text-[9px] text-rose-500 font-semibold mt-0.5 bg-rose-50 border border-rose-100 rounded-lg p-1.5">
                            Pembayaran sebelumnya ditolak pengurus. Silakan upload bukti transfer ulang yang valid.
                        </div>
                        @endif

                    </div>
                    @endforeach

                </div>

            </div>
            @empty
            <div class="col-span-full bg-white rounded-3xl p-10 border border-slate-100 text-center">
                <div class="w-16 h-16 mx-auto rounded-full bg-slate-50 flex items-center justify-center">
                    <i class="ti ti-credit-card-off text-slate-400 text-3xl"></i>
                </div>
                <h4 class="font-bold text-slate-800 mt-4">Tidak Ada Tagihan</h4>
                <p class="text-xs text-slate-500 mt-1 max-w-[200px] mx-auto leading-relaxed">
                    Anda tidak memiliki kontrak pembiayaan aktif yang perlu diangsur.
                </p>
            </div>
            @endforelse
        </div>

        <!-- MOBILE FRIENDLY PAGINATION -->
        <div class="mt-4">
            @if ($uniqueSources->hasPages())
            <div class="flex items-center justify-between px-3 py-2 bg-white border border-slate-100 rounded-2xl shadow-sm text-xs">
                @if ($uniqueSources->onFirstPage())
                    <span class="px-3 py-1.5 rounded-lg bg-slate-50 text-slate-400 border border-slate-200 cursor-default select-none font-semibold">
                        Sebelumnya
                    </span>
                @else
                    <a href="{{ $uniqueSources->previousPageUrl() }}" class="px-3 py-1.5 rounded-lg bg-white text-slate-700 border border-slate-200 hover:bg-slate-50 transition font-semibold tap-scale">
                        Sebelumnya
                    </a>
                @endif

                <span class="text-slate-500 font-medium">
                    Hal {{ $uniqueSources->currentPage() }} dari {{ $uniqueSources->lastPage() }}
                </span>

                @if ($uniqueSources->hasMorePages())
                    <a href="{{ $uniqueSources->nextPageUrl() }}" class="px-3 py-1.5 rounded-lg bg-white text-slate-700 border border-slate-200 hover:bg-slate-50 transition font-semibold tap-scale">
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
