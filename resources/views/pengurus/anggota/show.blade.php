<x-app-layout>

    <x-slot name="header">
        <div class="flex items-center gap-3">
            <a href="{{ route('pengurus.anggota.index') }}" class="w-10 h-10 rounded-xl bg-white border border-slate-200/60 flex items-center justify-center text-slate-600 hover:text-slate-800 transition tap-scale">
                <i class="ti ti-arrow-left text-lg"></i>
            </a>
            <div>
                <h2 class="text-lg font-bold text-slate-800">
                    Detail Anggota
                </h2>
                <p class="text-[11px] text-slate-500">
                    Informasi profil dan rekam jejak keuangan anggota
                </p>
            </div>
        </div>
    </x-slot>

    <!-- RESPONSIVE GRID LAYOUT (Desktop sidebar look) -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mt-4 items-start" x-data="{ activeTab: 'simpanan' }">

        <!-- LEFT SIDE: MEMBER PROFILE HERO (1 Column on desktop) -->
        <div class="lg:col-span-1 bg-white rounded-3xl p-6 border border-slate-100 shadow-sm flex flex-col items-center text-center relative overflow-hidden">
            <!-- decorative bg -->
            <div class="absolute inset-x-0 top-0 h-1.5 bg-gradient-to-r from-teal-500 to-cyan-500"></div>

            <div class="w-20 h-20 rounded-2xl bg-gradient-to-br from-teal-500 to-cyan-500 text-white flex items-center justify-center shadow-lg font-bold text-3xl mb-4 mt-2">
                {{ strtoupper(substr($user->name, 0, 1)) }}
            </div>

            <h3 class="font-extrabold text-slate-800 text-base leading-tight">{{ $user->name }}</h3>
            <span class="text-xs text-slate-400 mt-1 block">{{ $user->email }}</span>
            <span class="text-[10px] font-semibold text-slate-400 uppercase tracking-widest mt-3 block">Mulai Bergabung: {{ $user->created_at->format('d M Y') }}</span>

            <div class="mt-4">
                @if(($user->total_pinjaman ?? 0) > 0)
                <span class="badge-pill badge-rejected">
                    <span class="w-1.5 h-1.5 rounded-full bg-rose-500"></span>
                    Aktif Pinjaman
                </span>
                @else
                <span class="badge-pill badge-approved">
                    <span class="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>
                    Aman / Bebas Pinjaman
                </span>
                @endif
            </div>
        </div>

        <!-- RIGHT SIDE: STATS & TRANSACTION HISTORIES (2 Columns on desktop) -->
        <div class="lg:col-span-2 space-y-5">
            
            <!-- TRANSACTION SUMMARY CARDS -->
            <div class="grid grid-cols-3 gap-3">
                <div class="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm text-center">
                    <span class="text-[9px] font-bold text-slate-400 uppercase tracking-wider block">Simpanan</span>
                    <span class="text-sm font-extrabold text-emerald-600 mt-1.5 block truncate">
                        Rp {{ number_format($user->total_simpanan ?? 0, 0, ',', '.') }}
                    </span>
                </div>
                <div class="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm text-center">
                    <span class="text-[9px] font-bold text-slate-400 uppercase tracking-wider block">Pinjaman</span>
                    <span class="text-sm font-extrabold text-rose-600 mt-1.5 block truncate">
                        Rp {{ number_format($user->total_pinjaman ?? 0, 0, ',', '.') }}
                    </span>
                </div>
                @php
                    $net = ($user->total_simpanan ?? 0) - ($user->total_pinjaman ?? 0);
                @endphp
                <div class="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm text-center">
                    <span class="text-[9px] font-bold text-slate-400 uppercase tracking-wider block">Posisi Net</span>
                    <span class="text-sm font-extrabold mt-1.5 block truncate {{ $net >= 0 ? 'text-teal-600' : 'text-rose-600' }}">
                        Rp {{ number_format($net, 0, ',', '.') }}
                    </span>
                </div>
            </div>

            <!-- TAB SELECTOR -->
            <div class="flex border-b border-slate-200">
                <button @click="activeTab = 'simpanan'" 
                        :class="activeTab === 'simpanan' ? 'border-teal-500 text-teal-600 font-bold' : 'border-transparent text-slate-500 font-medium'"
                        class="flex-1 py-3 text-xs text-center border-b-2 transition">
                    Riwayat Simpanan
                </button>
                <button @click="activeTab = 'pinjaman'" 
                        :class="activeTab === 'pinjaman' ? 'border-teal-500 text-teal-600 font-bold' : 'border-transparent text-slate-500 font-medium'"
                        class="flex-1 py-3 text-xs text-center border-b-2 transition">
                    Riwayat Pinjaman
                </button>
            </div>

            <!-- TAB CONTENT: SIMPANAN -->
            <div x-show="activeTab === 'simpanan'" class="space-y-2.5">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
                    @forelse($simpanan as $s)
                    <div class="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm flex items-center justify-between text-xs">
                        <div>
                            <span class="font-bold text-slate-700 block">Setoran {{ ucfirst($s->jenis) }}</span>
                            <span class="text-[9px] text-slate-400 mt-0.5 block">{{ $s->created_at->format('d M Y') }}</span>
                        </div>
                        <span class="font-bold text-emerald-600">
                            +Rp {{ number_format($s->nominal_simpanan, 0, ',', '.') }}
                        </span>
                    </div>
                    @empty
                    <div class="col-span-full bg-white rounded-3xl p-8 border border-slate-100 text-center text-slate-500 text-xs">
                        Anggota belum memiliki riwayat simpanan.
                    </div>
                    @endforelse
                </div>
            </div>

            <!-- TAB CONTENT: PINJAMAN -->
            <div x-show="activeTab === 'pinjaman'" class="space-y-3" style="display: none;">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
                    @forelse($pinjaman as $p)
                    <div class="bg-white rounded-3xl p-4 border border-slate-100 shadow-sm space-y-3">
                        <div class="flex justify-between items-start">
                            <div>
                                <span class="text-[9px] text-slate-400 uppercase tracking-wider block">Pinjaman Tunai</span>
                                <span class="text-sm font-extrabold text-slate-800 mt-0.5 block">
                                    Rp {{ number_format($p->nominal, 0, ',', '.') }}
                                </span>
                            </div>

                            <!-- Status Indicator -->
                            <div>
                                @if($p->status == 'pending')
                                <span class="badge-pill badge-pending">Pending</span>
                                @elseif($p->status == 'approved')
                                <span class="badge-pill badge-approved">Aktif</span>
                                @elseif($p->status == 'rejected')
                                <span class="badge-pill badge-rejected">Ditolak</span>
                                @else
                                <span class="badge-pill badge-approved">Lunas</span>
                                @endif
                            </div>
                        </div>

                        <div class="grid grid-cols-2 gap-y-2 pt-2.5 border-t border-slate-50 text-[10px] text-slate-600">
                            <div>
                                <span class="text-slate-400">Tenor:</span>
                                <span class="font-bold text-slate-700">{{ $p->tenor_bulan }} Bulan</span>
                            </div>
                            <div>
                                <span class="text-slate-400">Bunga:</span>
                                <span class="font-bold text-slate-700">{{ $p->persen_bunga }}%</span>
                            </div>
                            <div>
                                <span class="text-slate-400">Cicilan/Bln:</span>
                                <span class="font-bold text-slate-700 truncate">Rp {{ number_format($p->angsuran_per_bulan, 0, ',', '.') }}</span>
                            </div>
                            <div>
                                <span class="text-slate-400">Sisa Hutang:</span>
                                <span class="font-bold text-rose-500 truncate">Rp {{ number_format($p->sisa_pinjaman, 0, ',', '.') }}</span>
                            </div>
                        </div>
                    </div>
                    @empty
                    <div class="col-span-full bg-white rounded-3xl p-8 border border-slate-100 text-center text-slate-500 text-xs">
                        Anggota belum memiliki riwayat pinjaman.
                    </div>
                    @endforelse
                </div>
            </div>

        </div>

    </div>

</x-app-layout>