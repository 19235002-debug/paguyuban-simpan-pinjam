<x-app-layout>

    <x-slot name="header">
        <div class="flex items-center gap-3">
            <a href="{{ route('dashboard') }}" class="w-10 h-10 rounded-xl bg-white border border-slate-200/60 flex items-center justify-center text-slate-600 hover:text-slate-800 transition tap-scale">
                <i class="ti ti-arrow-left text-lg"></i>
            </a>
            <div>
                <h2 class="text-lg font-bold text-slate-800">
                    Pengaturan Profil
                </h2>
                <p class="text-[11px] text-slate-500">
                    Kelola informasi pribadi dan keamanan akun Anda
                </p>
            </div>
        </div>
    </x-slot>

    <div class="space-y-5 mt-4">

        <!-- PROFILE INFORMATION CARD -->
        <div class="bg-white rounded-3xl p-5 border border-slate-100 shadow-sm">
            <h3 class="text-xs font-bold text-slate-400 uppercase tracking-widest px-0.5 mb-4">
                Informasi Pribadi
            </h3>
            <div class="text-sm">
                @include('profile.partials.update-profile-information-form')
            </div>
        </div>

        <!-- PASSWORD CHANGE CARD -->
        <div class="bg-white rounded-3xl p-5 border border-slate-100 shadow-sm">
            <h3 class="text-xs font-bold text-slate-400 uppercase tracking-widest px-0.5 mb-4">
                Ganti Password
            </h3>
            <div class="text-sm">
                @include('profile.partials.update-password-form')
            </div>
        </div>

        <!-- DELETE ACCOUNT CARD -->
        <div class="bg-white rounded-3xl p-5 border border-slate-100 shadow-sm border-rose-100">
            <h3 class="text-xs font-bold text-rose-500 uppercase tracking-widest px-0.5 mb-4">
                Hapus Akun Koperasi
            </h3>
            <div class="text-sm">
                @include('profile.partials.delete-user-form')
            </div>
        </div>

    </div>

</x-app-layout>
