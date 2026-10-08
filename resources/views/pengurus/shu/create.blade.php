<x-app-layout>

    <x-slot name="header">
        <div class="flex items-center gap-3">
            <a href="{{ route('pengurus.shu.index') }}" class="w-10 h-10 rounded-xl bg-white border border-slate-200/60 flex items-center justify-center text-slate-600 hover:text-slate-800 transition tap-scale">
                <i class="ti ti-arrow-left text-lg"></i>
            </a>
            <div>
                <h2 class="text-lg font-bold text-slate-800">
                    Catat Pengeluaran SHU
                </h2>
                <p class="text-[11px] text-slate-500">
                    Masukkan detail nominal pengeluaran SHU koperasi
                </p>
            </div>
        </div>
    </x-slot>

    <div class="space-y-5 mt-4">

        <!-- MAX SHU LIMIT INFO CARD -->
        <div class="bg-gradient-to-r from-amber-500 to-amber-600 text-white rounded-3xl p-5 shadow-sm">
            <span class="text-[10px] text-amber-100 font-bold uppercase tracking-wider block">
                Batas Maksimal Pengeluaran
            </span>
            <h3 class="text-xl font-bold mt-1">
                Rp {{ number_format($saldoKas, 0, ',', '.') }}
            </h3>
            <p class="text-[9px] text-amber-100 mt-2 leading-relaxed">
                Nominal SHU yang diinputkan tidak boleh melebihi saldo kas aktif koperasi di atas agar arus kas tidak defisit.
            </p>
        </div>

        <!-- FORM ENTRY CARD -->
        <div class="bg-white rounded-3xl p-5 border border-slate-100 shadow-sm">
            <form id="formShu" method="POST" action="{{ route('pengurus.shu.store') }}" class="space-y-4">
                @csrf

                <!-- Nominal SHU -->
                <div>
                    <label class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">
                        Nominal Pengeluaran SHU
                    </label>
                    <div class="relative">
                        <div class="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 font-bold text-sm">
                            Rp
                        </div>
                        <input type="text" 
                               id="nominal" 
                               name="nominal" 
                               placeholder="Rp 0" 
                               required 
                               value="{{ old('nominal') }}"
                               class="w-full h-11 pl-9 pr-4 rounded-xl border-slate-200 focus:border-teal-500 focus:ring-teal-500 text-sm font-semibold text-slate-800">
                    </div>
                </div>

                <!-- Tanggal Pengeluaran -->
                <div>
                    <label class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">
                        Tanggal Pengeluaran
                    </label>
                    <input type="date" 
                           name="tanggal" 
                           required 
                           value="{{ old('tanggal', now()->format('Y-m-d')) }}"
                           class="w-full h-11 px-4 rounded-xl border-slate-200 focus:border-teal-500 focus:ring-teal-500 text-sm font-medium text-slate-800">
                </div>

                <!-- Keterangan -->
                <div>
                    <label class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">
                        Keterangan / Deskripsi
                    </label>
                    <input type="text" 
                           name="keterangan" 
                           required 
                           value="{{ old('keterangan') }}"
                           placeholder="Contoh: Pembagian SHU Periode 2025"
                           class="w-full h-11 px-4 rounded-xl border-slate-200 focus:border-teal-500 focus:ring-teal-500 text-sm font-medium text-slate-800">
                </div>

                <!-- Submit Button -->
                <button type="submit" 
                        class="w-full h-11 rounded-xl bg-teal-600 hover:bg-teal-700 text-white font-bold text-xs transition tap-scale flex items-center justify-center gap-1.5 shadow shadow-teal-600/10">
                    <i class="ti ti-send"></i>
                    <span>Catat Pengeluaran SHU</span>
                </button>
            </form>
        </div>

    </div>

    <!-- JS formatting and validation -->
    <script>
        const nominalInput = document.getElementById('nominal');
        const maxSaldo = {{ $saldoKas }};

        nominalInput.addEventListener('input', function(e) {
            let angka = e.target.value.replace(/\D/g, '');
            if (angka) {
                e.target.value = 'Rp ' + Number(angka).toLocaleString('id-ID');
            } else {
                e.target.value = '';
            }
        });

        document.addEventListener('DOMContentLoaded', () => {
            const form = document.getElementById('formShu');
            form.addEventListener('submit', function(e) {
                e.preventDefault();

                const rawNominal = nominalInput.value.replace(/\D/g, '');
                const nominal = parseInt(rawNominal || 0);

                if (nominal <= 0) {
                    Swal.fire({
                        icon: 'warning',
                        title: 'Nominal Tidak Valid',
                        text: 'Silakan masukkan nominal pengeluaran SHU yang valid.',
                        confirmButtonColor: '#0d9488',
                        customClass: { popup: 'rounded-2xl' }
                    });
                    return;
                }

                if (nominal > maxSaldo) {
                    Swal.fire({
                        icon: 'warning',
                        title: 'Melebihi Saldo Kas',
                        text: 'Nominal pengeluaran SHU tidak boleh melebihi saldo kas koperasi.',
                        confirmButtonColor: '#0d9488',
                        customClass: { popup: 'rounded-2xl' }
                    });
                    return;
                }

                Swal.fire({
                    title: 'Catat SHU?',
                    text: 'Catatan pengeluaran SHU akan memotong total kas koperasi.',
                    icon: 'question',
                    showCancelButton: true,
                    confirmButtonText: 'Catat',
                    cancelButtonText: 'Batal',
                    confirmButtonColor: '#0d9488',
                    cancelButtonColor: '#64748b',
                    customClass: {
                        popup: 'rounded-2xl'
                    }
                }).then((result) => {
                    if (result.isConfirmed) {
                        Swal.fire({
                            title: 'Menyimpan...',
                            allowOutsideClick: false,
                            didOpen: () => {
                                Swal.showLoading();
                            }
                        });
                        form.submit();
                    }
                });
            });
        });
    </script>

</x-app-layout>
