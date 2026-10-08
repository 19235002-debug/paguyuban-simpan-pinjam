<x-guest-layout>

    <div class="mb-5 text-center">
        <h2 class="text-base font-bold text-slate-800">Selamat Datang Kembali</h2>
        <p class="text-xs text-slate-400 mt-1">Masukkan kredensial Anda untuk masuk ke sistem</p>
    </div>

    <!-- Session Status -->
    <x-auth-session-status class="mb-4" :status="session('status')" />

    <form method="POST" action="{{ route('login') }}" class="space-y-4">
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
                   autocomplete="username" 
                   placeholder="nama@email.com"
                   class="w-full h-11 px-4 rounded-xl border-slate-200 focus:border-teal-500 focus:ring-teal-500 text-sm font-medium text-slate-800">
            <x-input-error :messages="$errors->get('email')" class="mt-1 text-xs text-red-500 font-medium" />
        </div>

        <!-- Password -->
        <div>
            <div class="flex items-center justify-between mb-2">
                <label for="password" class="block text-xs font-bold text-slate-500 uppercase tracking-wider">
                    Password
                </label>
                @if (Route::has('password.request'))
                    <a class="text-xs text-teal-600 hover:text-teal-700 font-bold hover:underline" href="{{ route('password.request') }}">
                        Lupa Password?
                    </a>
                @endif
            </div>
            <input id="password" 
                   type="password" 
                   name="password" 
                   required 
                   autocomplete="current-password" 
                   placeholder="••••••••"
                   class="w-full h-11 px-4 rounded-xl border-slate-200 focus:border-teal-500 focus:ring-teal-500 text-sm font-medium text-slate-800">
            <x-input-error :messages="$errors->get('password')" class="mt-1 text-xs text-red-500 font-medium" />
        </div>

        <!-- Remember Me -->
        <div class="flex items-center">
            <input id="remember_me" 
                   type="checkbox" 
                   name="remember"
                   class="w-4 h-4 rounded border-slate-200 text-teal-600 focus:ring-teal-500">
            <label for="remember_me" class="ms-2 text-xs text-slate-500 font-semibold select-none cursor-pointer">Ingat Perangkat Ini</label>
        </div>

        <!-- Login Button -->
        <button type="submit" 
                class="w-full h-11 rounded-xl bg-teal-600 hover:bg-teal-700 text-white font-bold text-xs transition tap-scale flex items-center justify-center gap-1.5 shadow shadow-teal-600/10 mt-6">
            <i class="ti ti-login text-sm"></i>
            <span>Masuk Aplikasi</span>
        </button>

    </form>
</x-guest-layout>
