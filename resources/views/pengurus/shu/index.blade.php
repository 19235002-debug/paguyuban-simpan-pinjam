<x-app-layout>

    <x-slot name="header">
        <div class="flex items-center justify-between">
            <div>
                <h2 class="text-lg font-bold text-slate-800">
                    Pengeluaran SHU
                </h2>
                <p class="text-[11px] text-slate-500">
                    Daftar dan catat pengeluaran Sisa Hasil Usaha koperasi
                </p>
            </div>
            <a href="{{ route('pengurus.shu.create') }}"
                class="px-4 py-2.5 bg-teal-600 hover:bg-teal-700 text-white rounded-xl font-semibold text-xs transition tap-scale flex items-center gap-1.5">
                <i class="ti ti-plus"></i>
                <span>Catat SHU</span>
            </a>
        </div>
    </x-slot>

    <div class="space-y-5 mt-4">

        <!-- COMPACT CASH RESERVE INDICATOR -->
        <div class="bg-gradient-to-r from-teal-500 to-cyan-500 text-white rounded-3xl p-5 shadow-sm">
            <span class="text-[10px] text-teal-100 font-bold uppercase tracking-wider block">
                Saldo Kas Koperasi Saat Ini
            </span>
            <h3 class="text-2xl font-bold mt-1">
                Rp {{ number_format($saldoKas, 0, ',', '.') }}
            </h3>
            <p class="text-[9px] text-teal-100 mt-2 leading-relaxed">
                Setiap pencatatan pengeluaran SHU baru akan otomatis memotong total saldo kas koperasi.
            </p>
        </div>

        <!-- LIST SHU DISBURSEMENTS (RESPONSIVE CARD GRID) -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">

            @forelse($shus as $shu)
            <div class="bg-white rounded-3xl p-4 border border-slate-100 shadow-sm flex flex-col justify-between space-y-4">
                
                <div class="space-y-2">
                    <div class="flex justify-between items-start">
                        <div class="text-[10px] text-slate-400 font-semibold">
                            {{ $shu->tanggal->format('d M Y') }}
                        </div>
                        <span class="badge-pill badge-rejected">
                            <span class="w-1.5 h-1.5 rounded-full bg-rose-500"></span>
                            Pengeluaran
                        </span>
                    </div>
                    
                    <div>
                        <h4 class="text-base font-extrabold text-slate-800">
                            Rp {{ number_format($shu->nominal, 0, ',', '.') }}
                        </h4>
                        <p class="text-[10px] text-slate-500 mt-1 leading-relaxed">
                            {{ $shu->keterangan }}
                        </p>
                    </div>
                </div>

                <div class="pt-3 border-t border-slate-50 flex items-center justify-between text-[10px]">
                    <div class="flex items-center gap-1.5">
                        <div class="w-5 h-5 rounded-full bg-slate-100 flex items-center justify-center font-bold text-teal-600 text-[8px] border border-slate-200">
                            {{ strtoupper(substr($shu->user->name, 0, 1)) }}
                        </div>
                        <span class="text-slate-600 font-semibold">{{ $shu->user->name }}</span>
                    </div>

                    <!-- Delete button -->
                    <form id="delete-form-{{ $shu->id }}" method="POST" action="{{ route('pengurus.shu.destroy', $shu->id) }}">
                        @csrf
                        @method('DELETE')
                        <button type="button" onclick="confirmDelete('{{ $shu->id }}')" 
                                class="text-rose-600 hover:text-rose-700 font-bold hover:underline transition tap-scale flex items-center gap-0.5">
                            <i class="ti ti-trash text-sm"></i>
                            <span>Hapus</span>
                        </button>
                    </form>
                </div>

            </div>
            @empty
            <div class="col-span-full bg-white rounded-3xl p-10 border border-slate-100 text-center">
                <div class="w-16 h-16 mx-auto rounded-full bg-slate-50 flex items-center justify-center">
                    <i class="ti ti-scale text-slate-400 text-3xl"></i>
                </div>
                <h4 class="font-bold text-slate-800 mt-4">Belum Ada Pengeluaran SHU</h4>
                <p class="text-xs text-slate-500 mt-1 max-w-[240px] mx-auto leading-relaxed">
                    Belum ada pengeluaran Sisa Hasil Usaha (SHU) yang dicatat oleh pengurus.
                </p>
            </div>
            @endforelse

            <!-- MOBILE FRIENDLY PAGINATION -->
            <div class="col-span-full mt-2">
                @if ($shus->hasPages())
                <div class="flex items-center justify-between px-3 py-2 bg-white border border-slate-100 rounded-2xl shadow-sm text-xs">
                    @if ($shus->onFirstPage())
                        <span class="px-3 py-1.5 rounded-lg bg-slate-50 text-slate-400 border border-slate-200 cursor-default select-none font-semibold">
                            Sebelumnya
                        </span>
                    @else
                        <a href="{{ $shus->previousPageUrl() }}" class="px-3 py-1.5 rounded-lg bg-white text-slate-700 border border-slate-200 hover:bg-slate-50 transition font-semibold tap-scale">
                            Sebelumnya
                        </a>
                    @endif

                    <span class="text-slate-500 font-medium">
                        Hal {{ $shus->currentPage() }} dari {{ $shus->lastPage() }}
                    </span>

                    @if ($shus->hasMorePages())
                        <a href="{{ $shus->nextPageUrl() }}" class="px-3 py-1.5 rounded-lg bg-white text-slate-700 border border-slate-200 hover:bg-slate-50 transition font-semibold tap-scale">
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

    </div>

    <!-- SweetAlert Deletion Script -->
    <script>
        function confirmDelete(id) {
            Swal.fire({
                title: 'Hapus Catatan SHU?',
                text: 'Tindakan ini akan membatalkan pemotongan kas dan mengembalikan saldo kas koperasi.',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonText: 'Ya, Hapus',
                cancelButtonText: 'Batal',
                confirmButtonColor: '#e11d48',
                cancelButtonColor: '#64748b',
                customClass: {
                    popup: 'rounded-2xl'
                }
            }).then((result) => {
                if (result.isConfirmed) {
                    Swal.fire({
                        title: 'Menghapus...',
                        allowOutsideClick: false,
                        didOpen: () => {
                            Swal.showLoading();
                        }
                    });
                    document.getElementById('delete-form-' + id).submit();
                }
            });
        }
    </script>

</x-app-layout>
