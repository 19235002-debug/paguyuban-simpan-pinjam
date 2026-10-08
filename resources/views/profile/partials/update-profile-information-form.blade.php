<?php /** @var \App\Models\User $user */ ?>
<section>

    <div class="mb-6">
        <h2 class="text-xl font-bold text-slate-800">
            Informasi Profil
        </h2>

        <p class="mt-1 text-sm text-slate-500">
            Perbarui informasi akun dan alamat email Anda.
        </p>
    </div>

    <form
        id="send-verification"
        method="POST"
        action="{{ route('verification.send') }}">
        @csrf
    </form>

    <form
        method="POST"
        action="{{ route('profile.update') }}"
        enctype="multipart/form-data"
        class="space-y-6">

        @csrf
        @method('PATCH')

        {{-- NAMA --}}
        <div>

            <label
                for="name"
                class="block text-sm font-medium text-slate-700 mb-2">

                Nama Lengkap

            </label>

            <input
                id="name"
                name="name"
                type="text"
                value="{{ old('name', $user->name) }}"
                required
                autofocus
                autocomplete="name"
                class="w-full rounded-xl border-slate-300 focus:border-blue-500 focus:ring-blue-500">

            @error('name')
            <p class="mt-2 text-sm text-red-600">
                {{ $message }}
            </p>
            @enderror

        </div>

        {{-- EMAIL --}}
        <div>

            <label
                for="email"
                class="block text-sm font-medium text-slate-700 mb-2">

                Email

            </label>

            <input
                id="email"
                name="email"
                type="email"
                value="{{ old('email', $user->email) }}"
                required
                autocomplete="username"
                class="w-full rounded-xl border-slate-300 focus:border-blue-500 focus:ring-blue-500">

            @error('email')
            <p class="mt-2 text-sm text-red-600">
                {{ $message }}
            </p>
            @enderror

            @if (
            $user instanceof \Illuminate\Contracts\Auth\MustVerifyEmail
            && ! $user->hasVerifiedEmail()
            )

            <div class="mt-4">

                <div
                    class="rounded-xl border border-yellow-200 bg-yellow-50 p-4">

                    <p class="text-sm text-yellow-800">

                        Email Anda belum terverifikasi.

                    </p>

                    <button
                        form="send-verification"
                        type="submit"
                        class="mt-3 inline-flex items-center rounded-lg bg-yellow-500 px-4 py-2 text-sm font-medium text-white hover:bg-yellow-600">

                        Kirim Ulang Verifikasi

                    </button>

                </div>

                @if (session('status') === 'verification-link-sent')

                <div
                    class="mt-3 rounded-xl bg-green-50 border border-green-200 p-3 text-sm text-green-700">

                    Link verifikasi baru berhasil dikirim.

                </div>

                @endif

            </div>

            @endif

        </div>

        {{-- TANDA TANGAN (TTD PENGURUS ONLY) --}}
        @if($user->role === 'pengurus')
        <div class="border-t border-slate-100 pt-5">
            <label class="block text-sm font-semibold text-slate-700 mb-2">
                Tanda Tangan Pengurus (TTD)
            </label>
            
            <p class="text-[11px] text-slate-500 mb-3">
                Unggah gambar tanda tangan transparan Anda untuk dicantumkan pada kop/tanda tangan laporan.
            </p>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4 items-center">
                <!-- File Input -->
                <div class="relative flex items-center justify-center w-full">
                    <label class="flex flex-col items-center justify-center w-full h-24 border-2 border-slate-200 border-dashed rounded-2xl cursor-pointer bg-slate-50 hover:bg-slate-100/50 transition">
                        <div class="flex flex-col items-center justify-center pt-3 pb-3">
                            <i class="ti ti-signature text-slate-400 text-xl mb-0.5"></i>
                            <p class="text-[10px] text-slate-500 font-semibold">Tap untuk mengupload TTD</p>
                            <p class="text-[8px] text-slate-400 mt-0.5">PNG, JPG (Maks. 2MB)</p>
                        </div>
                        <input id="signature_input" type="file" name="signature" accept="image/*" class="hidden">
                    </label>
                </div>

                <!-- Preview Area -->
                <div class="p-3 border border-slate-150 rounded-2xl bg-slate-50 flex flex-col items-center justify-center min-h-[96px]">
                    <div class="text-[8px] font-bold text-slate-400 uppercase tracking-wider mb-1">Preview TTD Aktif</div>
                    @if($user->signature)
                        <img id="signature_preview" src="{{ asset('storage/' . $user->signature) }}" class="max-h-16 object-contain bg-white border border-slate-200 rounded p-1">
                    @else
                        <div id="signature_placeholder" class="text-[10px] text-slate-400 italic">Belum ada tanda tangan</div>
                        <img id="signature_preview" class="hidden max-h-16 object-contain bg-white border border-slate-200 rounded p-1">
                    @endif
                </div>
            </div>

            @error('signature')
            <p class="mt-2 text-sm text-red-600">
                {{ $message }}
            </p>
            @enderror
        </div>

        <script>
            document.addEventListener('DOMContentLoaded', () => {
                const sigInput = document.getElementById('signature_input');
                const sigPreview = document.getElementById('signature_preview');
                const sigPlaceholder = document.getElementById('signature_placeholder');

                sigInput.addEventListener('change', function(e) {
                    const file = e.target.files[0];
                    if (!file) return;

                    const reader = new FileReader();
                    reader.onload = function(event) {
                        sigPreview.src = event.target.result;
                        sigPreview.classList.remove('hidden');
                        if (sigPlaceholder) {
                            sigPlaceholder.classList.add('hidden');
                        }
                    }
                    reader.readAsDataURL(file);
                });
            });
        </script>
        @endif

        {{-- BUTTON --}}
        <div class="flex justify-end">

            <button
                type="submit"
                class="inline-flex items-center rounded-xl bg-blue-600 px-5 py-3 text-white font-medium hover:bg-blue-700 transition">

                Simpan Perubahan

            </button>

        </div>

    </form>

</section>