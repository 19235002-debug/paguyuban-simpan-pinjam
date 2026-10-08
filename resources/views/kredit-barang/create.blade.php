<x-app-layout>

    <x-slot name="header">
        <div class="flex items-center gap-3">
            <a href="{{ route('kredit-barang.index') }}" class="w-10 h-10 rounded-xl bg-white border border-slate-200/60 flex items-center justify-center text-slate-600 hover:text-slate-800 transition tap-scale">
                <i class="ti ti-arrow-left text-lg"></i>
            </a>
            <div>
                <h2 class="text-lg font-bold text-slate-800">
                    Ajukan Kredit Barang
                </h2>
                <p class="text-[11px] text-slate-500">
                    Masukkan data barang untuk hitung simulasi cicilan
                </p>
            </div>
        </div>
    </x-slot>

    <div class="space-y-5 mt-4">
        
        <!-- INPUT FORM CARD -->
        <div class="bg-white rounded-3xl p-5 border border-slate-100 shadow-sm">
            <form id="formKredit" method="POST" action="{{ route('kredit-barang.store') }}" enctype="multipart/form-data" class="space-y-4">
                @csrf

                <!-- Nama Barang -->
                <div>
                    <label class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">
                        Nama Barang
                    </label>
                    <input type="text" 
                           name="nama_barang" 
                           required 
                           value="{{ old('nama_barang') }}"
                           placeholder="Contoh: Laptop Asus VivoBook"
                           class="w-full h-11 px-4 rounded-xl border-slate-200 focus:border-teal-500 focus:ring-teal-500 text-sm font-medium text-slate-800">
                </div>

                <!-- Harga Barang -->
                <div>
                    <label class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">
                        Harga Barang
                    </label>
                    <div class="relative">
                        <div class="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 font-bold text-sm">
                            Rp
                        </div>
                        <input type="text" 
                               id="harga_barang" 
                               name="harga_barang" 
                               placeholder="Rp 0" 
                               required 
                               value="{{ old('harga_barang') }}"
                               class="w-full h-11 pl-9 pr-4 rounded-xl border-slate-200 focus:border-teal-500 focus:ring-teal-500 text-sm font-semibold text-slate-800">
                    </div>
                </div>

                <!-- Tenor -->
                <div>
                    <label class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">
                        Tenor Kredit
                    </label>
                    <select name="tenor_bulan" 
                            id="tenor_bulan" 
                            required
                            class="w-full h-11 px-3 rounded-xl border-slate-200 focus:border-teal-500 focus:ring-teal-500 text-sm font-medium text-slate-800">
                        @for($i=1; $i<=12; $i++)
                            <option value="{{ $i }}" {{ old('tenor_bulan', 1) == $i ? 'selected' : '' }}>
                                {{ $i }} Bulan
                            </option>
                        @endfor
                    </select>
                </div>

                <!-- Foto Barang Upload -->
                <div>
                    <label class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">
                        Foto Barang
                    </label>
                    <div class="relative flex items-center justify-center w-full">
                        <label class="flex flex-col items-center justify-center w-full h-28 border-2 border-slate-200 border-dashed rounded-2xl cursor-pointer bg-slate-50 hover:bg-slate-100/50 transition">
                            <div class="flex flex-col items-center justify-center pt-4 pb-4">
                                <i class="ti ti-photo-plus text-slate-400 text-2xl mb-1"></i>
                                <p class="text-[10px] text-slate-500 font-semibold">Tap untuk upload foto barang</p>
                                <p class="text-[8px] text-slate-400 mt-0.5">JPG, JPEG, PNG (Maks. 2MB)</p>
                            </div>
                            <input id="foto_barang" type="file" name="foto_barang" accept="image/*" class="hidden">
                        </label>
                    </div>
                </div>

                <!-- Image Preview Container -->
                <div id="previewContainer" class="hidden border border-slate-100 rounded-2xl p-2 bg-slate-50">
                    <div class="text-[9px] font-bold text-slate-400 uppercase tracking-wider mb-2 px-1">Preview Foto</div>
                    <img id="previewImage" class="w-full max-h-48 object-contain rounded-xl border border-slate-200 bg-white">
                </div>

                <!-- Keterangan -->
                <div>
                    <label class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">
                        Keterangan Tambahan
                    </label>
                    <textarea name="keterangan" 
                              rows="3" 
                              placeholder="Spesifikasi barang atau catatan tambahan..."
                              class="w-full p-3 rounded-xl border-slate-200 focus:border-teal-500 focus:ring-teal-500 text-sm font-medium text-slate-800">{{ old('keterangan') }}</textarea>
                </div>

                <!-- LIVE CALCULATOR PANEL -->
                <div class="border border-slate-100 rounded-2xl p-4 bg-slate-50/50 space-y-3 pt-3">
                    <div class="text-[10px] font-bold text-slate-400 uppercase tracking-wider pb-1.5 border-b border-slate-100 flex justify-between">
                        <span>Simulasi Kredit</span>
                        <span class="text-teal-600 font-extrabold uppercase">Live</span>
                    </div>
                    
                    <div class="space-y-2 text-xs">
                        <div class="flex justify-between">
                            <span class="text-slate-500">Suku Bunga</span>
                            <span id="bunga" class="font-bold text-teal-600">10%</span>
                        </div>
                        <div class="flex justify-between">
                            <span class="text-slate-500">Nominal Bunga</span>
                            <span id="nominal_bunga" class="font-bold text-slate-700">Rp 0</span>
                        </div>
                        <div class="flex justify-between pt-2 border-t border-slate-100">
                            <span class="text-slate-600 font-semibold">Total Tagihan</span>
                            <span id="total_tagihan" class="font-bold text-slate-800">Rp 0</span>
                        </div>
                    </div>

                    <!-- ESTIMATED MONTHLY INSTALLMENT -->
                    <div class="mt-4 rounded-xl bg-gradient-to-r from-teal-500 to-cyan-500 p-4 text-white shadow shadow-teal-500/10">
                        <div class="text-white/80 text-[9px] font-bold uppercase tracking-wider">
                            Cicilan Kredit / Bulan
                        </div>
                        <div id="angsuran" class="text-lg font-extrabold mt-1">
                            Rp 0
                        </div>
                    </div>
                </div>

                <!-- Hidden Values -->
                <input type="hidden" name="persen_bunga" id="persen_bunga">
                <input type="hidden" name="nominal_bunga" id="hidden_nominal_bunga">
                <input type="hidden" name="total_tagihan" id="hidden_total_tagihan">
                <input type="hidden" name="angsuran_per_bulan" id="hidden_angsuran">
                <input type="hidden" name="harga_barang" id="harga_raw">

                <!-- SUBMIT ACTION -->
                <button type="submit" 
                        class="w-full h-11 rounded-xl bg-teal-600 hover:bg-teal-700 text-white font-bold text-xs transition tap-scale flex items-center justify-center gap-1.5 shadow shadow-teal-600/10">
                    <i class="ti ti-send"></i>
                    <span>Ajukan Kredit</span>
                </button>
            </form>
        </div>

    </div>

    <script>
        const hargaInput = document.getElementById('harga_barang');
        const tenorInput = document.getElementById('tenor_bulan');

        function rupiah(nominal) {
            return 'Rp ' + Number(nominal).toLocaleString('id-ID');
        }

        function hitungSimulasi() {
            let harga = hargaInput.value.replace(/\D/g, '');
            harga = parseInt(harga || 0);
            document.getElementById('harga_raw').value = harga;

            let tenor = parseInt(tenorInput.value || 1);
            let bunga = 10;

            let nominalBunga = harga * bunga / 100;
            let totalTagihan = harga + nominalBunga;
            let angsuran = Math.round(totalTagihan / tenor);

            // Display
            document.getElementById('bunga').innerText = bunga + '%';
            document.getElementById('nominal_bunga').innerText = rupiah(nominalBunga);
            document.getElementById('total_tagihan').innerText = rupiah(totalTagihan);
            document.getElementById('angsuran').innerText = rupiah(angsuran);

            // Hidden values
            document.getElementById('persen_bunga').value = bunga;
            document.getElementById('hidden_nominal_bunga').value = nominalBunga;
            document.getElementById('hidden_total_tagihan').value = totalTagihan;
            document.getElementById('hidden_angsuran').value = angsuran;
        }

        hargaInput.addEventListener('input', function(e) {
            let angka = e.target.value.replace(/\D/g, '');
            if (angka) {
                e.target.value = 'Rp ' + Number(angka).toLocaleString('id-ID');
            } else {
                e.target.value = '';
            }
            hitungSimulasi();
        });

        tenorInput.addEventListener('change', hitungSimulasi);
        hitungSimulasi();

        // Image Preview logic
        const fotoBarang = document.getElementById('foto_barang');
        const previewImage = document.getElementById('previewImage');
        const previewContainer = document.getElementById('previewContainer');

        fotoBarang.addEventListener('change', function(e) {
            const file = e.target.files[0];
            if (!file) {
                previewContainer.classList.add('hidden');
                return;
            }

            const reader = new FileReader();
            reader.onload = function(event) {
                previewImage.src = event.target.result;
                previewContainer.classList.remove('hidden');
            }
            reader.readAsDataURL(file);
        });

        // Submit form with Sweetalert confirmation
        document.addEventListener('DOMContentLoaded', () => {
            const form = document.getElementById('formKredit');
            form.addEventListener('submit', function(e) {
                e.preventDefault();
                Swal.fire({
                    title: 'Ajukan Kredit?',
                    text: 'Pengajuan kredit barang akan dikirim ke pengurus.',
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
                        form.submit();
                    }
                });
            });
        });
    </script>

</x-app-layout>