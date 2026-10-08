<x-app-layout>

    <x-slot name="header">
        <div class="flex items-center gap-3">
            <a href="{{ route('pembayaran.index') }}" class="w-10 h-10 rounded-xl bg-white border border-slate-200/60 flex items-center justify-center text-slate-600 hover:text-slate-800 transition tap-scale">
                <i class="ti ti-arrow-left text-lg"></i>
            </a>
            <div>
                <h2 class="text-lg font-bold text-slate-800">
                    Bayar Angsuran
                </h2>
                <p class="text-[11px] text-slate-500">
                    Kirim bukti bayar untuk angsuran pinjaman/kredit Anda
                </p>
            </div>
        </div>
    </x-slot>

    <div class="space-y-5 mt-4">
        
        <!-- COMPACT INFO BANNER -->
        <div class="bg-gradient-to-r from-blue-600 to-blue-500 text-white rounded-3xl p-5 shadow-sm">
            <span class="text-[10px] font-bold text-blue-100 uppercase tracking-wider block">
                Angsuran Ke-{{ $pembayaran->angsuran_ke }}
            </span>
            <h3 class="text-2xl font-bold mt-1 block">
                Rp {{ number_format($pembayaran->nominal, 0, ',', '.') }}
            </h3>
            <p class="text-[10px] text-blue-100 mt-2 leading-relaxed">
                Kewajiban tagihan jatuh tempo pada {{ $pembayaran->jatuh_tempo->format('d M Y') }}.
            </p>
        </div>

        <!-- BANK ACCOUNT SUMMARY FOR CONVENIENCE -->
        <div class="bg-white rounded-3xl p-5 border border-slate-100 shadow-sm space-y-3">
            <div class="rounded-2xl bg-slate-50 border border-slate-100 p-4 relative overflow-hidden flex items-center justify-between">
                <div>
                    <div class="text-[9px] font-bold text-teal-600 uppercase tracking-wider">BANK BRI KOPERASI</div>
                    <div class="text-base font-bold text-slate-800 mt-0.5 tracking-wide">
                        5280 3667 32
                    </div>
                    <div class="text-[10px] text-slate-500 mt-0.5">
                        a.n. Guntur Arya Suta
                    </div>
                </div>
                <button onclick="navigator.clipboard.writeText('5280366732'); Swal.fire({toast:true,position:'bottom',icon:'success',title:'Nomor rekening disalin!',showConfirmButton:false,timer:1500});" 
                        class="w-8 h-8 rounded-xl bg-white hover:bg-slate-100 border border-slate-200 flex items-center justify-center text-slate-500 transition tap-scale shadow-sm"
                        title="Salin Nomor">
                    <i class="ti ti-copy text-sm"></i>
                </button>
            </div>
        </div>

        <!-- FORM ENTRY CARD -->
        <div class="bg-white rounded-3xl p-5 border border-slate-100 shadow-sm">
            <form id="formBayar" method="POST" action="{{ route('pembayaran.storeBayar', $pembayaran->id) }}" enctype="multipart/form-data" class="space-y-4">
                @csrf

                <!-- Tanggal Bayar input -->
                <div>
                    <label class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">
                        Tanggal Pembayaran
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
                        Upload Bukti Transfer
                    </label>
                    <div class="relative flex items-center justify-center w-full">
                        <label class="flex flex-col items-center justify-center w-full h-28 border-2 border-slate-200 border-dashed rounded-2xl cursor-pointer bg-slate-50 hover:bg-slate-100/50 transition">
                            <div class="flex flex-col items-center justify-center pt-4 pb-4">
                                <i class="ti ti-cloud-upload text-slate-400 text-2xl mb-1"></i>
                                <p class="text-[10px] text-slate-500 font-semibold">Tap untuk mengupload gambar</p>
                                <p class="text-[8px] text-slate-400 mt-0.5">PNG, JPG, JPEG (Maks. 2MB)</p>
                            </div>
                            <input id="bukti_transfer" type="file" name="bukti_transfer" accept="image/*" class="hidden">
                        </label>
                    </div>
                </div>

                <!-- Image Preview Container -->
                <div id="previewContainer" class="hidden border border-slate-100 rounded-2xl p-2 bg-slate-50">
                    <div class="text-[9px] font-bold text-slate-400 uppercase tracking-wider mb-2 px-1">Preview Bukti</div>
                    <img id="previewImage" class="w-full max-h-48 object-contain rounded-xl border border-slate-200 bg-white">
                </div>

                <!-- Action Button Stack -->
                <div class="pt-2 flex gap-3">
                    <a href="{{ route('pembayaran.index') }}" class="flex-1 py-3 text-center rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-700 font-semibold text-xs transition tap-scale">
                        Batal
                    </a>
                    <button type="submit" class="flex-1 py-3 rounded-xl bg-teal-600 hover:bg-teal-700 text-white font-semibold text-xs transition tap-scale">
                        Kirim Bukti
                    </button>
                </div>
            </form>
        </div>

    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const fileInput = document.getElementById('bukti_transfer');
            const previewContainer = document.getElementById('previewContainer');
            const previewImage = document.getElementById('previewImage');

            fileInput.addEventListener('change', function(e) {
                const file = e.target.files[0];
                if (!file) {
                    previewContainer.classList.add('hidden');
                    return;
                }

                const reader = new FileReader();
                reader.onload = function(event) {
                    previewImage.src = event.target.result;
                    previewContainer.classList.remove('hidden');
                };
                reader.readAsDataURL(file);
            });

            const form = document.getElementById('formBayar');
            form.addEventListener('submit', function(e) {
                e.preventDefault();

                // Validate form inputs manually
                const tanggalBayar = document.getElementsByName('tanggal_bayar')[0].value;
                const file = fileInput.files[0];

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
                    title: 'Kirim Pembayaran?',
                    text: 'Bukti transfer angsuran akan dikirim ke pengurus.',
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