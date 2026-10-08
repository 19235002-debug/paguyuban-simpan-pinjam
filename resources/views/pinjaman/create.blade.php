<x-app-layout>

    <x-slot name="header">
        <div class="flex items-center gap-3">
            <a href="{{ route('pinjaman.index') }}" class="w-10 h-10 rounded-xl bg-white border border-slate-200/60 flex items-center justify-center text-slate-600 hover:text-slate-800 transition tap-scale">
                <i class="ti ti-arrow-left text-lg"></i>
            </a>
            <div>
                <h2 class="text-lg font-bold text-slate-800">
                    Simulasi Pinjaman
                </h2>
                <p class="text-[11px] text-slate-500">
                    Hitung cicilan dan buat pengajuan baru
                </p>
            </div>
        </div>
    </x-slot>

    <div class="space-y-5 mt-4">
        
        <!-- INPUT FORM CARD -->
        <div class="bg-white rounded-3xl p-5 border border-slate-100 shadow-sm">
            <form method="POST" action="{{ route('pinjaman.store') }}" id="formPinjaman" class="space-y-4">
                @csrf

                <!-- Nominal Input -->
                <div>
                    <label class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">
                        Nominal Pinjaman
                    </label>
                    <div class="relative">
                        <div class="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 font-bold text-sm">
                            Rp
                        </div>
                        <input type="text" 
                               id="nominal" 
                               name="nominal" 
                               value="{{ old('nominal', 'Rp 100.000') }}"
                               placeholder="Rp 1.000.000" 
                               required
                               class="w-full h-11 pl-9 pr-4 rounded-xl border-slate-200 focus:border-teal-500 focus:ring-teal-500 text-sm font-semibold text-slate-800">
                    </div>
                </div>

                <!-- Tenor Selection -->
                <div>
                    <label class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">
                        Tenor Pinjaman
                    </label>
                    <select id="tenor" 
                            name="tenor_bulan" 
                            required
                            class="w-full h-11 px-3 rounded-xl border-slate-200 focus:border-teal-500 focus:ring-teal-500 text-sm font-medium text-slate-800">
                        @for($i = 1; $i <= 12; $i++)
                            <option value="{{ $i }}" {{ old('tenor_bulan', 1) == $i ? 'selected' : '' }}>
                                {{ $i }} Bulan
                            </option>
                        @endfor
                    </select>
                </div>

                <!-- LIVE CALCULATOR PANEL inside the Form -->
                <div class="border border-slate-100 rounded-2xl p-4 bg-slate-50/50 space-y-3 pt-3">
                    <div class="text-[10px] font-bold text-slate-400 uppercase tracking-wider pb-1.5 border-b border-slate-100 flex justify-between">
                        <span>Hasil Simulasi</span>
                        <span class="text-teal-600 font-extrabold uppercase">Live</span>
                    </div>
                    
                    <div class="space-y-2 text-xs">
                        <div class="flex justify-between">
                            <span class="text-slate-500">Nominal Pokok</span>
                            <span id="simNominal" class="font-bold text-slate-700">Rp 100.000</span>
                        </div>
                        <div class="flex justify-between">
                            <span class="text-slate-500">Suku Bunga</span>
                            <span id="simBunga" class="font-bold text-teal-600">5%</span>
                        </div>
                        <div class="flex justify-between">
                            <span class="text-slate-500">Biaya Bunga</span>
                            <span id="simNominalBunga" class="font-bold text-slate-700">Rp 5.000</span>
                        </div>
                        <div class="flex justify-between pt-2 border-t border-slate-100">
                            <span class="text-slate-600 font-semibold">Total Pengembalian</span>
                            <span id="simTotal" class="font-bold text-slate-800">Rp 105.000</span>
                        </div>
                    </div>

                    <!-- ESTIMATED MONTHLY INSTALLMENT -->
                    <div class="mt-4 rounded-xl bg-gradient-to-r from-teal-500 to-cyan-500 p-4 text-white shadow shadow-teal-500/10">
                        <div class="text-white/80 text-[9px] font-bold uppercase tracking-wider">
                            Estimasi Cicilan / Bulan
                        </div>
                        <div id="simAngsuran" class="text-lg font-extrabold mt-1">
                            Rp 105.000
                        </div>
                    </div>
                </div>

                <!-- SUBMIT ACTION -->
                <button type="submit" 
                        class="w-full h-11 rounded-xl bg-teal-600 hover:bg-teal-700 text-white font-bold text-xs transition tap-scale flex items-center justify-center gap-1.5 shadow shadow-teal-600/10">
                    <i class="ti ti-send"></i>
                    <span>Kirim Pengajuan</span>
                </button>
            </form>
        </div>

    </div>

    <script>
        document.addEventListener('DOMContentLoaded', () => {
            const nominalInput = document.getElementById('nominal');
            const tenorInput = document.getElementById('tenor');

            function formatRupiah(angka) {
                return 'Rp ' + Number(angka).toLocaleString('id-ID');
            }

            function hitungSimulasi() {
                let nominal = nominalInput.value.replace(/\D/g, '');
                nominal = parseInt(nominal || 0);
                let tenor = parseInt(tenorInput.value || 1);

                let bunga = 10;

                let nominalBunga = nominal * bunga / 100;
                let total = nominal + nominalBunga;
                let angsuran = Math.round(total / tenor);

                document.getElementById('simNominal').innerText = formatRupiah(nominal);
                document.getElementById('simBunga').innerText = bunga + '%';
                document.getElementById('simNominalBunga').innerText = formatRupiah(nominalBunga);
                document.getElementById('simTotal').innerText = formatRupiah(total);
                document.getElementById('simAngsuran').innerText = formatRupiah(angsuran);
            }

            nominalInput.addEventListener('input', e => {
                let value = e.target.value.replace(/\D/g, '');
                if (!value) {
                    e.target.value = '';
                } else {
                    e.target.value = 'Rp ' + Number(value).toLocaleString('id-ID');
                }
                hitungSimulasi();
            });

            tenorInput.addEventListener('change', hitungSimulasi);
            hitungSimulasi();

            document.getElementById('formPinjaman').addEventListener('submit', function(e) {
                e.preventDefault();
                Swal.fire({
                    title: 'Ajukan Pinjaman?',
                    text: 'Pengajuan akan dikirim ke pengurus koperasi.',
                    icon: 'question',
                    showCancelButton: true,
                    confirmButtonText: 'Ajukan',
                    cancelButtonText: 'Batal',
                    confirmButtonColor: '#0d9488',
                    cancelButtonColor: '#64748b',
                    customClass: {
                        popup: 'rounded-2xl'
                    }
                }).then((result) => {
                    if (result.isConfirmed) {
                        Swal.fire({
                            title: 'Mengirim...',
                            allowOutsideClick: false,
                            didOpen: () => Swal.showLoading()
                        });
                        this.submit();
                    }
                });
            });
        });
    </script>

</x-app-layout>