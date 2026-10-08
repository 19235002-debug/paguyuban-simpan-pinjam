<x-app-layout>

    <x-slot name="header">
        <div class="flex items-center gap-3">
            <a href="{{ route('dashboard') }}" class="w-10 h-10 rounded-xl bg-white border border-slate-200/60 flex items-center justify-center text-slate-600 hover:text-slate-800 transition tap-scale">
                <i class="ti ti-arrow-left text-lg"></i>
            </a>
            <div>
                <h2 class="text-lg font-bold text-slate-800">
                    Laporan Keuangan
                </h2>
                <p class="text-[11px] text-slate-500">
                    Unduh dan cetak rekapitulasi data keuangan koperasi
                </p>
            </div>
        </div>
    </x-slot>

    <div class="space-y-6 mt-4">

        <!-- GLOBAL CASH FLOW SUMMARY -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
            
            <!-- Saldo Kas -->
            <div class="bg-gradient-to-br from-teal-500 via-teal-600 to-cyan-600 text-white rounded-3xl p-5 shadow-sm relative overflow-hidden">
                <div class="absolute -right-5 -top-5 w-20 h-20 bg-white/10 rounded-full blur-xs"></div>
                <span class="text-[10px] text-teal-100 font-bold uppercase tracking-wider block">Saldo Kas Bersih</span>
                <h3 class="text-xl font-extrabold mt-1">
                    Rp {{ number_format($saldoKas, 0, ',', '.') }}
                </h3>
                <p class="text-[9px] text-teal-100 mt-2 leading-relaxed">
                    Total Kas = Pemasukan - Pengeluaran
                </p>
            </div>

            <!-- Total Pemasukan -->
            <div class="bg-white rounded-3xl p-5 border border-slate-100 shadow-sm flex items-center gap-4">
                <div class="w-11 h-11 rounded-2xl bg-emerald-50 text-emerald-600 flex items-center justify-center flex-shrink-0">
                    <i class="ti ti-arrow-up-right text-xl"></i>
                </div>
                <div>
                    <span class="text-[9px] text-slate-400 font-bold uppercase tracking-wider block">Total Pemasukan</span>
                    <span class="text-base font-extrabold text-slate-800 mt-0.5 block">
                        Rp {{ number_format($totalPemasukan, 0, ',', '.') }}
                    </span>
                </div>
            </div>

            <!-- Total Pengeluaran -->
            <div class="bg-white rounded-3xl p-5 border border-slate-100 shadow-sm flex items-center gap-4">
                <div class="w-11 h-11 rounded-2xl bg-rose-50 text-rose-600 flex items-center justify-center flex-shrink-0">
                    <i class="ti ti-arrow-down-left text-xl"></i>
                </div>
                <div>
                    <span class="text-[9px] text-slate-400 font-bold uppercase tracking-wider block">Total Pengeluaran</span>
                    <span class="text-base font-extrabold text-slate-800 mt-0.5 block">
                        Rp {{ number_format($totalPengeluaran, 0, ',', '.') }}
                    </span>
                </div>
            </div>

        </div>

        <!-- OUTSTANDING SUMMARY TILES -->
        <div class="grid grid-cols-2 gap-4">
            
            <div class="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm flex items-center gap-3 text-xs">
                <div class="w-9 h-9 rounded-xl bg-teal-50 text-teal-600 flex items-center justify-center flex-shrink-0">
                    <i class="ti ti-wallet text-lg"></i>
                </div>
                <div>
                    <span class="text-slate-400 block text-[9px] uppercase tracking-wider font-bold">Kas Simpanan Global</span>
                    <span class="font-extrabold text-slate-800 block mt-0.5">Rp {{ number_format($saldoSimpananGlobal, 0, ',', '.') }}</span>
                </div>
            </div>

            <div class="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm flex items-center gap-3 text-xs">
                <div class="w-9 h-9 rounded-xl bg-amber-50 text-amber-500 flex items-center justify-center flex-shrink-0">
                    <i class="ti ti-clipboard-list text-lg"></i>
                </div>
                <div>
                    <span class="text-slate-400 block text-[9px] uppercase tracking-wider font-bold">Outstanding Piutang</span>
                    <span class="font-extrabold text-slate-800 block mt-0.5">Rp {{ number_format($totalOutstanding, 0, ',', '.') }}</span>
                </div>
            </div>

        </div>

        <!-- EXPORT REPORT ACTION LIST (CARDS) -->
        <div class="space-y-4">
            <h3 class="text-xs font-bold text-slate-400 uppercase tracking-widest px-1">
                Unduh / Cetak Laporan Koperasi
            </h3>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">

                <!-- 1. Laporan Pemasukan -->
                <div class="bg-white rounded-3xl p-5 border border-slate-100 shadow-sm space-y-4 flex flex-col justify-between">
                    <div>
                        <div class="flex items-center gap-3">
                            <div class="w-10 h-10 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center">
                                <i class="ti ti-trending-up text-lg"></i>
                            </div>
                            <div>
                                <h4 class="font-bold text-slate-800 text-xs">Laporan Pemasukan</h4>
                                <span class="text-[9px] text-slate-400 mt-0.5 block">Arus masuk setoran wajib & cicilan bulanan</span>
                            </div>
                        </div>
                    </div>
                    <div class="flex gap-3 pt-2">
                        <a href="{{ route('pengurus.laporan.export', 'pemasukan') }}" 
                           class="flex-1 py-2 rounded-xl bg-slate-50 hover:bg-slate-100 border border-slate-200 text-slate-700 font-bold text-[10px] text-center flex items-center justify-center gap-1 transition tap-scale">
                            <i class="ti ti-file-spreadsheet text-sm"></i>
                            <span>Excel</span>
                        </a>
                        <a href="{{ route('pengurus.laporan.print', 'pemasukan') }}" target="_blank"
                           class="flex-1 py-2 rounded-xl bg-teal-600 hover:bg-teal-700 text-white font-bold text-[10px] text-center flex items-center justify-center gap-1 shadow-sm transition tap-scale">
                            <i class="ti ti-printer text-sm"></i>
                            <span>Cetak PDF</span>
                        </a>
                    </div>
                </div>

                <!-- 2. Laporan Pengeluaran -->
                <div class="bg-white rounded-3xl p-5 border border-slate-100 shadow-sm space-y-4 flex flex-col justify-between">
                    <div>
                        <div class="flex items-center gap-3">
                            <div class="w-10 h-10 rounded-xl bg-rose-50 text-rose-600 flex items-center justify-center">
                                <i class="ti ti-trending-down text-lg"></i>
                            </div>
                            <div>
                                <h4 class="font-bold text-slate-800 text-xs">Laporan Pengeluaran</h4>
                                <span class="text-[9px] text-slate-400 mt-0.5 block">Arus keluar pencairan pinjaman & kredit barang</span>
                            </div>
                        </div>
                    </div>
                    <div class="flex gap-3 pt-2">
                        <a href="{{ route('pengurus.laporan.export', 'pengeluaran') }}" 
                           class="flex-1 py-2 rounded-xl bg-slate-50 hover:bg-slate-100 border border-slate-200 text-slate-700 font-bold text-[10px] text-center flex items-center justify-center gap-1 transition tap-scale">
                            <i class="ti ti-file-spreadsheet text-sm"></i>
                            <span>Excel</span>
                        </a>
                        <a href="{{ route('pengurus.laporan.print', 'pengeluaran') }}" target="_blank"
                           class="flex-1 py-2 rounded-xl bg-teal-600 hover:bg-teal-700 text-white font-bold text-[10px] text-center flex items-center justify-center gap-1 shadow-sm transition tap-scale">
                            <i class="ti ti-printer text-sm"></i>
                            <span>Cetak PDF</span>
                        </a>
                    </div>
                </div>

                <!-- 3. Rekap Saldo Simpanan Anggota -->
                <div class="bg-white rounded-3xl p-5 border border-slate-100 shadow-sm space-y-4 flex flex-col justify-between">
                    <div>
                        <div class="flex items-center gap-3">
                            <div class="w-10 h-10 rounded-xl bg-cyan-50 text-cyan-600 flex items-center justify-center">
                                <i class="ti ti-wallet text-lg"></i>
                            </div>
                            <div>
                                <h4 class="font-bold text-slate-800 text-xs">Saldo Simpanan Anggota</h4>
                                <span class="text-[9px] text-slate-400 mt-0.5 block">Akumulasi simpanan wajib per anggota koperasi</span>
                            </div>
                        </div>
                    </div>
                    <div class="flex gap-3 pt-2">
                        <a href="{{ route('pengurus.laporan.export', 'saldo_anggota') }}" 
                           class="flex-1 py-2 rounded-xl bg-slate-50 hover:bg-slate-100 border border-slate-200 text-slate-700 font-bold text-[10px] text-center flex items-center justify-center gap-1 transition tap-scale">
                            <i class="ti ti-file-spreadsheet text-sm"></i>
                            <span>Excel</span>
                        </a>
                        <a href="{{ route('pengurus.laporan.print', 'saldo_anggota') }}" target="_blank"
                           class="flex-1 py-2 rounded-xl bg-teal-600 hover:bg-teal-700 text-white font-bold text-[10px] text-center flex items-center justify-center gap-1 shadow-sm transition tap-scale">
                            <i class="ti ti-printer text-sm"></i>
                            <span>Cetak PDF</span>
                        </a>
                    </div>
                </div>

                <!-- 4. Rekap Outstanding Pinjaman Anggota -->
                <div class="bg-white rounded-3xl p-5 border border-slate-100 shadow-sm space-y-4 flex flex-col justify-between">
                    <div>
                        <div class="flex items-center gap-3">
                            <div class="w-10 h-10 rounded-xl bg-violet-50 text-violet-600 flex items-center justify-center">
                                <i class="ti ti-credit-card text-lg"></i>
                            </div>
                            <div>
                                <h4 class="font-bold text-slate-800 text-xs">Hutang / Pinjaman Anggota</h4>
                                <span class="text-[9px] text-slate-400 mt-0.5 block">Sisa pinjaman & kontrak barang berjalan per anggota</span>
                            </div>
                        </div>
                    </div>
                    <div class="flex gap-3 pt-2">
                        <a href="{{ route('pengurus.laporan.export', 'pinjaman_anggota') }}" 
                           class="flex-1 py-2 rounded-xl bg-slate-50 hover:bg-slate-100 border border-slate-200 text-slate-700 font-bold text-[10px] text-center flex items-center justify-center gap-1 transition tap-scale">
                            <i class="ti ti-file-spreadsheet text-sm"></i>
                            <span>Excel</span>
                        </a>
                        <a href="{{ route('pengurus.laporan.print', 'pinjaman_anggota') }}" target="_blank"
                           class="flex-1 py-2 rounded-xl bg-teal-600 hover:bg-teal-700 text-white font-bold text-[10px] text-center flex items-center justify-center gap-1 shadow-sm transition tap-scale">
                            <i class="ti ti-printer text-sm"></i>
                            <span>Cetak PDF</span>
                        </a>
                    </div>
                </div>

            </div>

        </div>

    </div>

</x-app-layout>
