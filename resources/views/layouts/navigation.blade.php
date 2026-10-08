<nav x-data="{ mobileMenuOpen: false }">

    <!-- 1. LEFT SIDEBAR (DESKTOP ONLY) -->
    <aside class="hidden lg:flex w-72 fixed inset-y-0 left-0 bg-white border-r border-slate-200/80 z-40 flex-col justify-between py-6 px-5 shadow-sm">
        
        <div class="space-y-6">
            <!-- Brand Logo -->
            <div class="flex items-center gap-3 px-2">
                <img src="{{ asset('logo.png') }}" class="w-10 h-10 object-contain">
                <div>
                    <h1 class="font-extrabold text-slate-800 tracking-wide text-sm leading-none">Bravo Bekasi</h1>
                    <span class="text-[10px] font-semibold text-slate-400 uppercase tracking-widest block mt-0.5">Paguyuban</span>
                </div>
            </div>

            <!-- User Profile Summary Card -->
            <div class="bg-slate-50 border border-slate-100 rounded-2xl p-4 flex items-center gap-3">
                <div class="w-11 h-11 rounded-xl bg-gradient-to-br from-teal-500 to-cyan-500 text-white flex items-center justify-center font-bold text-base shadow-inner">
                    {{ strtoupper(substr(Auth::user()->name, 0, 1)) }}
                </div>
                <div>
                    <h4 class="font-bold text-slate-800 text-xs leading-none">{{ Auth::user()->name }}</h4>
                    <span class="text-[9px] font-semibold text-teal-600 uppercase tracking-wider block mt-1">{{ ucfirst(Auth::user()->role) }}</span>
                </div>
            </div>

            <!-- Navigation Links -->
            <div class="space-y-1.5">
                <span class="text-[9px] font-bold text-slate-400 uppercase tracking-widest block px-2.5 mb-2">Menu Utama</span>
                
                <a href="{{ route('dashboard') }}" 
                    class="flex items-center gap-3 px-3 py-2.5 rounded-xl text-xs font-semibold transition tap-scale {{ request()->routeIs('dashboard') ? 'bg-teal-50 text-teal-600 shadow-sm border-l-4 border-teal-500' : 'text-slate-600 hover:bg-slate-50' }}">
                    <i class="ti ti-smart-home text-lg"></i>
                    <span>Dashboard</span>
                </a>

                @if(Auth::user()->role !== 'pengurus')
                <a href="{{ route('simpanan.index') }}" 
                    class="flex items-center gap-3 px-3 py-2.5 rounded-xl text-xs font-semibold transition tap-scale {{ request()->routeIs('simpanan.*') ? 'bg-teal-50 text-teal-600 shadow-sm border-l-4 border-teal-500' : 'text-slate-600 hover:bg-slate-50' }}">
                    <i class="ti ti-wallet text-lg"></i>
                    <span>Simpanan</span>
                </a>

                <a href="{{ route('pinjaman.index') }}" 
                    class="flex items-center gap-3 px-3 py-2.5 rounded-xl text-xs font-semibold transition tap-scale {{ request()->routeIs('pinjaman.*') ? 'bg-teal-50 text-teal-600 shadow-sm border-l-4 border-teal-500' : 'text-slate-600 hover:bg-slate-50' }}">
                    <i class="ti ti-cash text-lg"></i>
                    <span>Pinjaman</span>
                </a>

                <a href="{{ route('kredit-barang.index') }}" 
                    class="flex items-center gap-3 px-3 py-2.5 rounded-xl text-xs font-semibold transition tap-scale {{ request()->routeIs('kredit-barang.*') ? 'bg-teal-50 text-teal-600 shadow-sm border-l-4 border-teal-500' : 'text-slate-600 hover:bg-slate-50' }}">
                    <i class="ti ti-shopping-cart text-lg"></i>
                    <span>Kredit Barang</span>
                </a>

                <a href="{{ route('pembayaran.index') }}" 
                    class="flex items-center gap-3 px-3 py-2.5 rounded-xl text-xs font-semibold transition tap-scale {{ request()->routeIs('pembayaran.*') ? 'bg-teal-50 text-teal-600 shadow-sm border-l-4 border-teal-500' : 'text-slate-600 hover:bg-slate-50' }}">
                    <i class="ti ti-credit-card text-lg"></i>
                    <span>Tagihan Saya</span>
                </a>
                @else
                <div class="pt-4 border-t border-slate-100 space-y-1.5">
                    <span class="text-[9px] font-bold text-slate-400 uppercase tracking-widest block px-2.5 mb-2">Panel Pengurus</span>

                    <a href="{{ route('pengurus.anggota.index') }}" 
                        class="flex items-center gap-3 px-3 py-2.5 rounded-xl text-xs font-semibold transition tap-scale {{ request()->routeIs('pengurus.anggota.*') ? 'bg-teal-50 text-teal-600 shadow-sm border-l-4 border-teal-500' : 'text-slate-600 hover:bg-slate-50' }}">
                        <i class="ti ti-users text-lg"></i>
                        <span>Data Anggota</span>
                    </a>

                    <a href="{{ route('pengurus.laporan.index') }}" 
                        class="flex items-center gap-3 px-3 py-2.5 rounded-xl text-xs font-semibold transition tap-scale {{ request()->routeIs('pengurus.laporan.*') ? 'bg-teal-50 text-teal-600 shadow-sm border-l-4 border-teal-500' : 'text-slate-600 hover:bg-slate-50' }}">
                        <i class="ti ti-report-money text-lg"></i>
                        <span>Laporan Keuangan</span>
                    </a>

                    <a href="{{ route('pengurus.shu.index') }}" 
                        class="flex items-center gap-3 px-3 py-2.5 rounded-xl text-xs font-semibold transition tap-scale {{ request()->routeIs('pengurus.shu.*') ? 'bg-teal-50 text-teal-600 shadow-sm border-l-4 border-teal-500' : 'text-slate-600 hover:bg-slate-50' }}">
                        <i class="ti ti-percentage text-lg"></i>
                        <span>Pengeluaran SHU</span>
                    </a>
                </div>
                @endif
            </div>
        </div>

        <!-- Account controls bottom -->
        <div class="space-y-1.5 pt-4 border-t border-slate-100">
            <a href="{{ route('profile.edit') }}" 
                class="flex items-center gap-3 px-3 py-2.5 rounded-xl text-xs font-semibold transition text-slate-600 hover:bg-slate-50 tap-scale">
                <i class="ti ti-user-circle text-lg"></i>
                <span>Profil Saya</span>
            </a>
            
            <form method="POST" action="{{ route('logout') }}">
                @csrf
                <button type="submit" class="w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-xs font-bold text-rose-600 hover:bg-rose-50/50 transition tap-scale text-left">
                    <i class="ti ti-logout text-lg"></i>
                    <span>Keluar Aplikasi</span>
                </button>
            </form>
        </div>

    </aside>

    <!-- 2. TOP MOBILE HEADER (MOBILE ONLY) -->
    <header class="lg:hidden fixed top-0 left-0 right-0 bg-white/80 backdrop-blur-md border-b border-slate-200/50 z-30 h-14 flex items-center justify-between px-4 shadow-sm">
        
        <!-- Toggle button for Drawer -->
        <button @click="mobileMenuOpen = true" class="w-10 h-10 rounded-xl bg-slate-50 hover:bg-slate-100 text-slate-700 flex items-center justify-center transition tap-scale">
            <i class="ti ti-menu-2 text-xl"></i>
        </button>

        <!-- Brand centered logo -->
        <div class="flex items-center gap-2">
            <img src="{{ asset('logo.png') }}" class="w-7 h-7 object-contain">
            <span class="font-bold text-slate-800 text-sm tracking-wide">Paguyuban Bravo Bekasi</span>
        </div>

        <!-- Quick Profile Link -->
        <a href="{{ route('profile.edit') }}" class="w-10 h-10 rounded-xl bg-slate-50 hover:bg-slate-100 text-slate-700 flex items-center justify-center transition tap-scale">
            <i class="ti ti-user text-lg"></i>
        </a>

    </header>

    <!-- 3. BOTTOM MOBILE NAVIGATION BAR (MOBILE ONLY) -->
    <div class="lg:hidden fixed bottom-0 left-0 right-0 z-35 bg-white/95 backdrop-blur-md border-t border-slate-200/50 px-2 py-2 pb-[calc(8px+env(safe-area-inset-bottom))] flex justify-around items-center shadow-lg">
        
        <!-- Home -->
        <a href="{{ route('dashboard') }}" 
            class="flex flex-col items-center gap-1 py-1 px-3 rounded-xl transition tap-scale {{ request()->routeIs('dashboard') ? 'text-teal-600 font-semibold' : 'text-slate-500' }}">
            <i class="ti ti-smart-home text-2xl leading-none"></i>
            <span class="text-[9px] tracking-wide font-medium">Home</span>
        </a>

        <!-- Savings -->
        <a href="{{ route('simpanan.index') }}" 
            class="flex flex-col items-center gap-1 py-1 px-3 rounded-xl transition tap-scale {{ request()->routeIs('simpanan.*') ? 'text-teal-600 font-semibold' : 'text-slate-500' }}">
            <i class="ti ti-wallet text-2xl leading-none"></i>
            <span class="text-[9px] tracking-wide font-medium">Simpanan</span>
        </a>

        <!-- Loan Simulation Floating button (Big Center Button) -->
        <a href="{{ route('pinjaman.create') }}" class="relative -mt-6 group">
            <div class="w-12 h-12 rounded-full bg-gradient-to-r from-teal-500 to-cyan-500 text-white shadow-lg shadow-teal-500/25 flex items-center justify-center transition group-active:scale-90 duration-200">
                <i class="ti ti-plus text-xl"></i>
            </div>
        </a>

        <!-- Payments -->
        <a href="{{ route('pembayaran.index') }}" 
            class="flex flex-col items-center gap-1 py-1 px-3 rounded-xl transition tap-scale {{ request()->routeIs('pembayaran.*') ? 'text-teal-600 font-semibold' : 'text-slate-500' }}">
            <i class="ti ti-credit-card text-2xl leading-none"></i>
            <span class="text-[9px] tracking-wide font-medium">Tagihan</span>
        </a>

        <!-- Profile -->
        <a href="{{ route('profile.edit') }}" 
            class="flex flex-col items-center gap-1 py-1 px-3 rounded-xl transition tap-scale {{ request()->routeIs('profile.*') ? 'text-teal-600 font-semibold' : 'text-slate-500' }}">
            <i class="ti ti-user-circle text-2xl leading-none"></i>
            <span class="text-[9px] tracking-wide font-medium">Profil</span>
        </a>

    </div>

    <!-- 4. OFF-CANVAS MOBILE DRAWER MENU BACKDROP -->
    <div x-show="mobileMenuOpen" 
         x-transition.opacity 
         @click="mobileMenuOpen = false" 
         class="lg:hidden fixed inset-0 bg-black/60 backdrop-blur-xs z-45"
         style="display: none;">
    </div>

    <!-- 5. SLIDE-OUT MOBILE MENU DRAWER (MOBILE ONLY) -->
    <aside :class="mobileMenuOpen ? 'translate-x-0' : '-translate-x-full'" 
           class="lg:hidden fixed inset-y-0 left-0 w-72 bg-white z-50 shadow-2xl transition duration-300 transform flex flex-col justify-between py-6 px-5"
           style="display: flex;">
        
        <div class="space-y-6 overflow-y-auto pr-1">
            <!-- Brand/Logo with Close button -->
            <div class="flex items-center justify-between px-1">
                <div class="flex items-center gap-2">
                    <img src="{{ asset('logo.png') }}" class="w-8 h-8 object-contain">
                    <span class="font-bold text-slate-800 text-sm tracking-wide">Paguyuban Bravo Bekasi</span>
                </div>
                <button @click="mobileMenuOpen = false" class="w-8 h-8 rounded-xl hover:bg-slate-100 text-slate-500 flex items-center justify-center transition tap-scale">
                    <i class="ti ti-x text-lg"></i>
                </button>
            </div>

            <!-- Profile Summary -->
            <div class="bg-slate-50 border border-slate-100 rounded-2xl p-4 flex items-center gap-3">
                <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-teal-500 to-cyan-500 text-white flex items-center justify-center font-bold text-sm shadow-inner">
                    {{ strtoupper(substr(Auth::user()->name, 0, 1)) }}
                </div>
                <div>
                    <h4 class="font-bold text-slate-800 text-xs leading-none">{{ Auth::user()->name }}</h4>
                    <span class="text-[9px] font-semibold text-teal-600 uppercase tracking-wider block mt-1">{{ ucfirst(Auth::user()->role) }}</span>
                </div>
            </div>

            <!-- Links Group -->
            <div class="space-y-1">
                <span class="text-[9px] font-bold text-slate-400 uppercase tracking-widest block px-2.5 mb-2">Menu Utama</span>

                <a href="{{ route('dashboard') }}" @click="mobileMenuOpen = false"
                    class="flex items-center gap-3 px-3 py-2.5 rounded-xl text-xs font-semibold text-slate-600 hover:bg-slate-50 transition tap-scale">
                    <i class="ti ti-smart-home text-lg"></i>
                    <span>Dashboard</span>
                </a>

                @if(Auth::user()->role !== 'pengurus')
                <a href="{{ route('simpanan.index') }}" @click="mobileMenuOpen = false"
                    class="flex items-center gap-3 px-3 py-2.5 rounded-xl text-xs font-semibold text-slate-600 hover:bg-slate-50 transition tap-scale">
                    <i class="ti ti-wallet text-lg"></i>
                    <span>Simpanan</span>
                </a>

                <a href="{{ route('pinjaman.index') }}" @click="mobileMenuOpen = false"
                    class="flex items-center gap-3 px-3 py-2.5 rounded-xl text-xs font-semibold text-slate-600 hover:bg-slate-50 transition tap-scale">
                    <i class="ti ti-cash text-lg"></i>
                    <span>Pinjaman</span>
                </a>

                <a href="{{ route('kredit-barang.index') }}" @click="mobileMenuOpen = false"
                    class="flex items-center gap-3 px-3 py-2.5 rounded-xl text-xs font-semibold text-slate-600 hover:bg-slate-50 transition tap-scale">
                    <i class="ti ti-shopping-cart text-lg"></i>
                    <span>Kredit Barang</span>
                </a>

                <a href="{{ route('pembayaran.index') }}" @click="mobileMenuOpen = false"
                    class="flex items-center gap-3 px-3 py-2.5 rounded-xl text-xs font-semibold text-slate-600 hover:bg-slate-50 transition tap-scale">
                    <i class="ti ti-credit-card text-lg"></i>
                    <span>Tagihan Saya</span>
                </a>
                @else
                <div class="pt-4 border-t border-slate-100 space-y-1">
                    <span class="text-[9px] font-bold text-slate-400 uppercase tracking-widest block px-2.5 mb-2">Panel Pengurus</span>

                    <a href="{{ route('pengurus.anggota.index') }}" @click="mobileMenuOpen = false"
                        class="flex items-center gap-3 px-3 py-2.5 rounded-xl text-xs font-semibold transition tap-scale {{ request()->routeIs('pengurus.anggota.*') ? 'bg-teal-50 text-teal-600 shadow-sm border-l-4 border-teal-500' : 'text-slate-600 hover:bg-slate-50' }}">
                        <i class="ti ti-users text-lg"></i>
                        <span>Data Anggota</span>
                    </a>

                    <a href="{{ route('pengurus.laporan.index') }}" @click="mobileMenuOpen = false"
                        class="flex items-center gap-3 px-3 py-2.5 rounded-xl text-xs font-semibold transition tap-scale {{ request()->routeIs('pengurus.laporan.*') ? 'bg-teal-50 text-teal-600 shadow-sm border-l-4 border-teal-500' : 'text-slate-600 hover:bg-slate-50' }}">
                        <i class="ti ti-report-money text-lg"></i>
                        <span>Laporan Keuangan</span>
                    </a>

                    <a href="{{ route('pengurus.shu.index') }}" @click="mobileMenuOpen = false"
                        class="flex items-center gap-3 px-3 py-2.5 rounded-xl text-xs font-semibold transition tap-scale {{ request()->routeIs('pengurus.shu.*') ? 'bg-teal-50 text-teal-600 shadow-sm border-l-4 border-teal-500' : 'text-slate-600 hover:bg-slate-50' }}">
                        <i class="ti ti-percentage text-lg"></i>
                        <span>Pengeluaran SHU</span>
                    </a>
                </div>
                @endif
        </div>

        <!-- Account controls bottom -->
        <div class="space-y-1.5 pt-4 border-t border-slate-100 flex-shrink-0">
            <a href="{{ route('profile.edit') }}" @click="mobileMenuOpen = false"
                class="flex items-center gap-3 px-3 py-2.5 rounded-xl text-xs font-semibold text-slate-600 hover:bg-slate-50 transition tap-scale">
                <i class="ti ti-user-circle text-lg"></i>
                <span>Profil Saya</span>
            </a>
            
            <form method="POST" action="{{ route('logout') }}">
                @csrf
                <button type="submit" class="w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-xs font-bold text-rose-600 hover:bg-rose-50/50 transition tap-scale text-left">
                    <i class="ti ti-logout text-lg"></i>
                    <span>Keluar Aplikasi</span>
                </button>
            </form>
        </div>

    </aside>

</nav>