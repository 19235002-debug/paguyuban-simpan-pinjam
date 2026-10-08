<x-app-layout>

    <x-slot name="header">
        <div class="flex items-center gap-3">
            <a href="{{ route('simpanan.index') }}" class="w-10 h-10 rounded-xl bg-white border border-slate-200/60 flex items-center justify-center text-slate-600 hover:text-slate-800 transition tap-scale">
                <i class="ti ti-arrow-left text-lg"></i>
            </a>
            <div>
                <h2 class="text-lg font-bold text-slate-800">
                    Setor Simpanan Wajib
                </h2>
                <p class="text-[11px] text-slate-500">
                    Upload bukti transfer setoran wajib bulanan
                </p>
            </div>
        </div>
    </x-slot>

    <div class="space-y-5 mt-4">
        
        <!-- PAYMENT DETAIL SUMMARY CARDS -->
        <div class="bg-white rounded-3xl p-5 border border-slate-100 shadow-sm space-y-4">
            <h3 class="text-xs font-bold text-slate-400 uppercase tracking-widest px-0.5">
                Rincian Pembayaran
            </h3>
            
            <div class="space-y-2.5">
                <div class="flex justify-between items-center text-xs">
                    <span class="text-slate-500">Simpanan Wajib</span>
                    <span class="font-semibold text-slate-800">Rp 100.000</span>
                </div>
                <div class="flex justify-between items-center text-xs">
                    <span class="text-slate-500">Biaya Administrasi</span>
                    <span class="font-semibold text-slate-800">Rp 10.000</span>
                </div>
                <div class="flex justify-between items-center pt-2.5 border-t border-slate-100">
                    <span class="text-xs font-bold text-slate-700">Total Setoran</span>
                    <span class="text-base font-extrabold text-teal-600">Rp 110.000</span>
                </div>
            </div>
        </div>

        <!-- BANK ACCOUNT DESTINATION -->
        <div class="bg-white rounded-3xl p-5 border border-slate-100 shadow-sm space-y-3">
            <h3 class="text-xs font-bold text-slate-400 uppercase tracking-widest px-0.5">
                Transfer Ke Rekening Koperasi
            </h3>

            <div class="rounded-2xl bg-slate-50 border border-slate-100 p-4 relative overflow-hidden flex items-center justify-between">
                <div>
                    <div class="text-[10px] font-bold text-teal-600 uppercase tracking-wider">BANK BRI</div>
                    <div class="text-lg font-bold text-slate-800 mt-0.5 tracking-wide">
                        5280 3667 32
                    </div>
                    <div class="text-[11px] text-slate-500 mt-0.5">
                        a.n. Guntur Arya Suta
                    </div>
                </div>
                <!-- Copy Button icon overlay -->
                <button onclick="navigator.clipboard.writeText('5280366732'); Swal.fire({toast:true,position:'bottom',icon:'success',title:'Nomor rekening disalin!',showConfirmButton:false,timer:1500});" 
                        class="w-9 h-9 rounded-xl bg-white hover:bg-slate-100 border border-slate-200 flex items-center justify-center text-slate-500 transition tap-scale shadow-sm"
                        title="Salin Nomor">
                    <i class="ti ti-copy text-base"></i>
                </button>
            </div>
        </div>

        <!-- FORM ENTRY -->
        <div class="bg-white rounded-3xl p-5 border border-slate-100 shadow-sm">
            <form id="formSimpanan" action="{{ route('simpanan.store') }}" method="POST" enctype="multipart/form-data" class="space-y-4">
                @csrf

                <!-- Date Paid input -->
                <div>
                    <label class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">
                        Tanggal Bayar
                    </label>
                    <input type="date" 
                           name="tanggal_bayar" 
                           required
                           value="{{ old('tanggal_bayar', now()->format('Y-m-d')) }}"
                           class="w-full h-11 px-4 rounded-xl border-slate-200 focus:border-teal-500 focus:ring-teal-500 text-sm font-medium">
                </div>

                <!-- Proof input file -->
                <div>
                    <label class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">
                        Bukti Transfer
                    </label>
                    <div class="relative flex items-center justify-center w-full">
                        <label class="flex flex-col items-center justify-center w-full h-32 border-2 border-slate-200 border-dashed rounded-2xl cursor-pointer bg-slate-50 hover:bg-slate-100/50 transition">
                            <div class="flex flex-col items-center justify-center pt-5 pb-6">
                                <i class="ti ti-cloud-upload text-slate-400 text-3xl mb-1"></i>
                                <p class="text-[11px] text-slate-500 font-medium">Tap untuk mengupload gambar</p>
                                <p class="text-[9px] text-slate-400 mt-0.5">PNG, JPG, JPEG (Maks. 2MB)</p>
                            </div>
                            <input id="bukti_transfer" type="file" name="bukti_transfer" accept="image/*" class="hidden">
                        </label>
                    </div>
                </div>

                <!-- Upload Image Preview Container -->
                <div id="preview-container" class="hidden border border-slate-100 rounded-2xl p-2 bg-slate-50">
                    <div class="text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-2 px-1">Preview Bukti</div>
                    <img id="preview-image" class="w-full max-h-56 object-contain rounded-xl border border-slate-200 bg-white">
                </div>

                <!-- Action Button Stack -->
                <div class="pt-2 flex gap-3">
                    <a href="{{ route('simpanan.index') }}" class="flex-1 py-3 text-center rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-700 font-semibold text-xs transition tap-scale">
                        Batal
                    </a>
                    <button type="submit" class="flex-1 py-3 rounded-xl bg-teal-600 hover:bg-teal-700 text-white font-semibold text-xs transition tap-scale">
                        Kirim Setoran
                    </button>
                </div>
            </form>
        </div>

    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const input = document.getElementById('bukti_transfer');
            const previewContainer = document.getElementById('preview-container');
            const previewImage = document.getElementById('preview-image');

            input.addEventListener('change', function() {
                const file = this.files[0];
                if (!file) {
                    previewContainer.classList.add('hidden');
                    return;
                }

                previewContainer.classList.remove('hidden');
                previewImage.src = URL.createObjectURL(file);
            });

            const form = document.getElementById('formSimpanan');
            form.addEventListener('submit', function(e) {
                e.preventDefault();

                // Validate form inputs manually
                const tanggalBayar = document.getElementsByName('tanggal_bayar')[0].value;
                const file = input.files[0];

                if (!tanggalBayar) {
                    Swal.fire({
                        icon: 'warning',
                        title: 'Tanggal Wajib Diisi',
                        text: 'Silakan tentukan tanggal pembayaran terlebih dahulu.',
                        confirmButtonColor: '#0d9488',
                        customClass: { popup: 'rounded-2xl' }
                    });
                    return;
                }

                if (!file) {
                    Swal.fire({
                        icon: 'warning',
                        title: 'Bukti Transfer Wajib Diupload',
                        text: 'Silakan pilih gambar screenshot bukti transfer Anda.',
                        confirmButtonColor: '#0d9488',
                        customClass: { popup: 'rounded-2xl' }
                    });
                    return;
                }

                Swal.fire({
                    title: 'Kirim Setoran?',
                    text: 'Bukti transfer setoran wajib bulanan akan dikirim ke pengurus.',
                    icon: 'question',
                    showCancelButton: true,
                    confirmButtonText: 'Kirim',
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