<x-guest-layout>

    <div class="mb-5 text-center">
        <h2 class="text-base font-bold text-slate-800">Lupa Password?</h2>
        <p class="text-xs text-slate-400 mt-1">Kami akan mengirimkan link reset password melalui email Anda</p>
    </div>

    <!-- Session Status -->
    <x-auth-session-status class="mb-4" :status="session('status')" />

    <form method="POST" action="{{ route('password.email') }}" class="space-y-4">
        @csrf

        <!-- Email Address -->
        <div>
            <label for="email" class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">
                Email Address
            </label>
            <input id="email" 
                   type="email" 
                   name="email" 
                   value="{{ old('email') }}" 
                   required 
                   autofocus 
                   placeholder="nama@email.com"
                   class="w-full h-11 px-4 rounded-xl border-slate-200 focus:border-teal-500 focus:ring-teal-500 text-sm font-medium text-slate-800">
            <x-input-error :messages="$errors->get('email')" class="mt-1 text-xs text-red-500 font-medium" />
        </div>

        <!-- Submit Button -->
        <button type="submit" 
                class="w-full h-11 rounded-xl bg-teal-600 hover:bg-teal-700 text-white font-bold text-xs transition tap-scale flex items-center justify-center gap-1.5 shadow shadow-teal-600/10 mt-6">
            <i class="ti ti-mail-forward text-sm"></i>
            <span>Kirim Link Reset Password</span>
        </button>

        <!-- Back to Login Link -->
        <div class="text-center mt-4">
            <a href="{{ route('login') }}" class="text-xs text-slate-400 hover:text-slate-600 font-bold hover:underline transition">
                Kembali ke Halaman Login
            </a>
        </div>

    </form>
</x-guest-layout>
