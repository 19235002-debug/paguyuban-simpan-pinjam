<x-app-layout>

    <x-slot name="header">
        <div class="flex items-center justify-between mt-2">
            <div class="flex items-center gap-3">
                <img src="{{ asset('logo.png') }}" class="w-10 h-10 object-contain">
                <div>
                    <div class="text-[11px] font-semibold text-teal-600 uppercase tracking-widest">
                        Selamat Datang
                    </div>
                    <h2 class="text-xl font-bold text-slate-800 mt-0.5 leading-none">
                        {{ auth()->user()->name }}
                    </h2>
                </div>
            </div>
            <!-- User initial avatar -->
            <div class="w-10 h-10 rounded-xl bg-slate-100 flex items-center justify-center font-bold text-teal-600 border border-slate-200">
                {{ strtoupper(substr(auth()->user()->name, 0, 1)) }}
            </div>
        </div>
    </x-slot>

    <!-- COMPACT HERO CARD -->
    <div class="relative overflow-hidden rounded-3xl bg-gradient-to-br from-teal-500 via-cyan-500 to-blue-600 text-white p-5 shadow-lg shadow-teal-500/10 mb-6">
        <!-- Floating bubbles -->
        <div class="absolute -right-6 -top-6 w-24 h-24 bg-white/10 rounded-full blur-md"></div>
        <div class="absolute -left-6 -bottom-6 w-24 h-24 bg-white/10 rounded-full blur-md"></div>

        <div class="relative z-10 flex flex-col justify-between h-full">
            <div>
                <div class="text-white/80 text-[10px] uppercase font-bold tracking-wider">
                    {{ auth()->user()->role === 'pengurus' ? 'Total Kas Simpanan Koperasi' : 'Total Simpanan Saya' }}
                </div>
                <div class="text-2xl font-bold mt-1 tracking-tight">
                    Rp {{ number_format($saldoSimpanan, 0, ',', '.') }}
                </div>
            </div>

            <div class="mt-6 flex gap-2">
                @if(auth()->user()->role === 'pengurus')
                <a href="{{ route('pengurus.simpanan.index') }}" class="flex-1 py-2 px-3 text-center rounded-xl bg-white text-slate-800 font-semibold text-[11px] shadow-sm hover:bg-slate-50 transition tap-scale">
                    Kelola Simpanan
                </a>
                <a href="{{ route('pengurus.anggota.index') }}" class="flex-1 py-2 px-3 text-center rounded-xl bg-white/20 backdrop-blur-md text-white font-semibold text-[11px] border border-white/20 hover:bg-white/35 transition tap-scale">
                    Data Anggota
                </a>
                @else
                <a href="{{ route('simpanan.create') }}" class="flex-1 py-2 px-3 text-center rounded-xl bg-white text-slate-800 font-semibold text-[11px] shadow-sm hover:bg-slate-50 transition tap-scale">
                    Bayar Simpanan
                </a>
                <a href="{{ route('simpanan.index') }}" class="flex-1 py-2 px-3 text-center rounded-xl bg-white/20 backdrop-blur-md text-white font-semibold text-[11px] border border-white/20 hover:bg-white/35 transition tap-scale">
                    Riwayat
                </a>
                @endif
            </div>
        </div>
    </div>

    <!-- BANKING STYLE QUICK ACTIONS MENU -->
    @if(auth()->user()->role !== 'pengurus')
    <div class="mb-6">
        <h3 class="text-xs font-bold text-slate-400 uppercase tracking-widest mb-3 px-1">
            Layanan Cepat
        </h3>
        <div class="bg-white rounded-3xl border border-slate-100 p-4 shadow-sm grid grid-cols-4 gap-2">
            
            <!-- Quick Link 1: Pinjaman -->
            <a href="{{ route('pinjaman.index') }}" class="flex flex-col items-center text-center group tap-scale">
                <div class="w-12 h-12 rounded-2xl bg-cyan-50 text-cyan-600 flex items-center justify-center transition group-hover:bg-cyan-100">
                    <i class="ti ti-cash text-xl"></i>
                </div>
                <span class="text-[10px] font-semibold text-slate-700 mt-2 leading-none">Pinjaman</span>
            </a>

            <!-- Quick Link 2: Kredit Barang -->
            <a href="{{ route('kredit-barang.index') }}" class="flex flex-col items-center text-center group tap-scale">
                <div class="w-12 h-12 rounded-2xl bg-violet-50 text-violet-600 flex items-center justify-center transition group-hover:bg-violet-100">
                    <i class="ti ti-shopping-cart text-xl"></i>
                </div>
                <span class="text-[10px] font-semibold text-slate-700 mt-2 leading-none">Kredit</span>
            </a>

            <!-- Quick Link 3: Pembayaran -->
            <a href="{{ route('pembayaran.index') }}" class="flex flex-col items-center text-center group tap-scale">
                <div class="w-12 h-12 rounded-2xl bg-emerald-50 text-emerald-600 flex items-center justify-center transition group-hover:bg-emerald-100">
                    <i class="ti ti-credit-card text-xl"></i>
                </div>
                <span class="text-[10px] font-semibold text-slate-700 mt-2 leading-none">Tagihan</span>
            </a>

            <!-- Quick Link 4: Simpanan -->
            <a href="{{ route('simpanan.index') }}" class="flex flex-col items-center text-center group tap-scale">
                <div class="w-12 h-12 rounded-2xl bg-orange-50 text-orange-600 flex items-center justify-center transition group-hover:bg-orange-100">
                    <i class="ti ti-wallet text-xl"></i>
                </div>
                <span class="text-[10px] font-semibold text-slate-700 mt-2 leading-none">Simpanan</span>
            </a>

        </div>
    </div>
    @endif

    <!-- STATISTIK GRID -->
    <div class="mb-6">
        <h3 class="text-xs font-bold text-slate-400 uppercase tracking-widest mb-3 px-1">
            Status Keuangan
        </h3>
        <div class="grid grid-cols-2 gap-3">
            
            <!-- Stat 1: Tagihan Bulan Ini -->
            <div class="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm flex items-center gap-3">
                <div class="w-9 h-9 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center flex-shrink-0">
                    <i class="ti ti-calendar-event text-lg"></i>
                </div>
                <div>
                    <div class="text-[9px] font-semibold text-slate-400 uppercase tracking-wider">
                        {{ auth()->user()->role === 'pengurus' ? 'Piutang Bln Ini' : 'Tagihan' }}
                    </div>
                    <div class="font-bold text-xs text-slate-800 mt-0.5">
                        Rp {{ number_format($tagihanBulanIni, 0, ',', '.') }}
                    </div>
                </div>
            </div>

            <!-- Stat 2: Saldo Simpanan -->
            <div class="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm flex items-center gap-3">
                <div class="w-9 h-9 rounded-xl bg-teal-50 text-teal-600 flex items-center justify-center flex-shrink-0">
                    <i class="ti ti-wallet text-lg"></i>
                </div>
                <div>
                    <div class="text-[9px] font-semibold text-slate-400 uppercase tracking-wider">
                        {{ auth()->user()->role === 'pengurus' ? 'Kas Simpanan' : 'Simpanan' }}
                    </div>
                    <div class="font-bold text-xs text-slate-800 mt-0.5">
                        Rp {{ number_format($saldoSimpanan, 0, ',', '.') }}
                    </div>
                </div>
            </div>

            <!-- Stat 3: Pinjaman Aktif -->
            <div class="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm flex items-center gap-3">
                <div class="w-9 h-9 rounded-xl bg-cyan-50 text-cyan-600 flex items-center justify-center flex-shrink-0">
                    <i class="ti ti-cash text-lg"></i>
                </div>
                <div>
                    <div class="text-[9px] font-semibold text-slate-400 uppercase tracking-wider">
                        {{ auth()->user()->role === 'pengurus' ? 'Pinjaman Aktif' : 'Pinjaman Aktif' }}
                    </div>
                    <div class="font-bold text-xs text-slate-800 mt-0.5">
                        {{ $pinjamanAktif }} Kontrak
                    </div>
                </div>
            </div>

            <!-- Stat 4: Kredit Barang -->
            <div class="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm flex items-center gap-3">
                <div class="w-9 h-9 rounded-xl bg-violet-50 text-violet-600 flex items-center justify-center flex-shrink-0">
                    <i class="ti ti-shopping-cart text-lg"></i>
                </div>
                <div>
                    <div class="text-[9px] font-semibold text-slate-400 uppercase tracking-wider">
                        {{ auth()->user()->role === 'pengurus' ? 'Kredit Aktif' : 'Kredit Aktif' }}
                    </div>
                    <div class="font-bold text-xs text-slate-800 mt-0.5">
                        {{ $kreditAktif }} Barang
                    </div>
                </div>
            </div>

        </div>
    </div>

    <!-- PANEL PENGURUS (ONLY SHOWN FOR PENGURUS USERS) -->
    @if(auth()->user()->role === 'pengurus')
    <div class="mb-6">
        <div class="flex items-center justify-between mb-3 px-1">
            <h3 class="text-xs font-bold text-slate-400 uppercase tracking-widest">
                Panel Pengurus
            </h3>
            <div class="flex items-center gap-2">
                @if(isset($totalPending) && $totalPending > 0)
                <span class="px-2 py-0.5 rounded-lg bg-amber-50 text-amber-600 border border-amber-100 text-[9px] font-bold uppercase tracking-wider">
                    {{ $totalPending }} Pending
                </span>
                @endif
                <span class="px-2.5 py-0.5 rounded-full bg-teal-50 text-teal-600 border border-teal-100 text-[9px] font-bold uppercase tracking-wider">
                    Admin Area
                </span>
            </div>
        </div>
        
        <div class="space-y-2">
            
            <a href="{{ route('pengurus.simpanan.index') }}" class="flex items-center justify-between p-4 bg-white hover:bg-slate-50 border border-slate-100 rounded-2xl shadow-sm transition tap-scale">
                <div class="flex items-center gap-3">
                    <div class="w-9 h-9 rounded-xl bg-teal-55 bg-teal-50 text-teal-600 flex items-center justify-center">
                        <i class="ti ti-checklist text-lg"></i>
                    </div>
                    <div>
                        <div class="font-bold text-xs text-slate-800">Persetujuan Simpanan</div>
                        <div class="text-[10px] text-slate-400 mt-0.5">Verifikasi bukti transfer masuk</div>
                    </div>
                </div>
                <i class="ti ti-chevron-right text-slate-400"></i>
            </a>

            <a href="{{ route('pengurus.pinjaman.index') }}" class="flex items-center justify-between p-4 bg-white hover:bg-slate-50 border border-slate-100 rounded-2xl shadow-sm transition tap-scale">
                <div class="flex items-center gap-3">
                    <div class="w-9 h-9 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center">
                        <i class="ti ti-file-check text-lg"></i>
                    </div>
                    <div>
                        <div class="font-bold text-xs text-slate-800">Persetujuan Pinjaman</div>
                        <div class="text-[10px] text-slate-400 mt-0.5">Verifikasi kontrak pinjaman baru</div>
                    </div>
                </div>
                <i class="ti ti-chevron-right text-slate-400"></i>
            </a>

            <a href="{{ route('pengurus.kredit-barang.index') }}" class="flex items-center justify-between p-4 bg-white hover:bg-slate-50 border border-slate-100 rounded-2xl shadow-sm transition tap-scale">
                <div class="flex items-center gap-3">
                    <div class="w-9 h-9 rounded-xl bg-violet-50 text-violet-600 flex items-center justify-center">
                        <i class="ti ti-shopping-cart-check text-lg"></i>
                    </div>
                    <div>
                        <div class="font-bold text-xs text-slate-800">Persetujuan Kredit Barang</div>
                        <div class="text-[10px] text-slate-400 mt-0.5">Verifikasi kredit pengadaan barang</div>
                    </div>
                </div>
                <i class="ti ti-chevron-right text-slate-400"></i>
            </a>

            <a href="{{ route('pengurus.pembayaran.index') }}" class="flex items-center justify-between p-4 bg-white hover:bg-slate-50 border border-slate-100 rounded-2xl shadow-sm transition tap-scale">
                <div class="flex items-center gap-3">
                    <div class="w-9 h-9 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center">
                        <i class="ti ti-receipt-2 text-lg"></i>
                    </div>
                    <div>
                        <div class="font-bold text-xs text-slate-800">Persetujuan Angsuran</div>
                        <div class="text-[10px] text-slate-400 mt-0.5">Verifikasi bukti bayar angsuran</div>
                    </div>
                </div>
                <i class="ti ti-chevron-right text-slate-400"></i>
            </a>

            <a href="{{ route('pengurus.anggota.index') }}" class="flex items-center justify-between p-4 bg-white hover:bg-slate-50 border border-slate-100 rounded-2xl shadow-sm transition tap-scale">
                <div class="flex items-center gap-3">
                    <div class="w-9 h-9 rounded-xl bg-blue-50 text-blue-600 flex items-center justify-center">
                        <i class="ti ti-users text-lg"></i>
                    </div>
                    <div>
                        <div class="font-bold text-xs text-slate-800">Data Anggota</div>
                        <div class="text-[10px] text-slate-400 mt-0.5">Lihat data dan status anggota</div>
                    </div>
                </div>
                <i class="ti ti-chevron-right text-slate-400"></i>
            </a>

            <a href="{{ route('pengurus.laporan.index') }}" class="flex items-center justify-between p-4 bg-white hover:bg-slate-50 border border-slate-100 rounded-2xl shadow-sm transition tap-scale">
                <div class="flex items-center gap-3">
                    <div class="w-9 h-9 rounded-xl bg-indigo-50 text-indigo-600 flex items-center justify-center">
                        <i class="ti ti-report-money text-lg"></i>
                    </div>
                    <div>
                        <div class="font-bold text-xs text-slate-800">Laporan Keuangan</div>
                        <div class="text-[10px] text-slate-400 mt-0.5">Cetak dan unduh rekap data keuangan</div>
                    </div>
                </div>
                <i class="ti ti-chevron-right text-slate-400"></i>
            </a>

            <a href="{{ route('pengurus.shu.index') }}" class="flex items-center justify-between p-4 bg-white hover:bg-slate-50 border border-slate-100 rounded-2xl shadow-sm transition tap-scale">
                <div class="flex items-center gap-3">
                    <div class="w-9 h-9 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center">
                        <i class="ti ti-percentage text-lg"></i>
                    </div>
                    <div>
                        <div class="font-bold text-xs text-slate-800">Pengeluaran SHU</div>
                        <div class="text-[10px] text-slate-400 mt-0.5">Catat dan kelola pembagian sisa hasil usaha</div>
                    </div>
                </div>
                <i class="ti ti-chevron-right text-slate-400"></i>
            </a>

        </div>
    </div>
    @endif

</x-app-layout>