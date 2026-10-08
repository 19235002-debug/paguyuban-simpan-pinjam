<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
        <meta name="csrf-token" content="{{ csrf_token() }}">

        <title>{{ config('app.name', 'Paguyuban Bravo Bekasi') }}</title>
        <link rel="icon" type="image/png" href="{{ asset('logo.png') }}">

        <!-- Poppins -->
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">

        <!-- Tabler Icons -->
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@latest/tabler-icons.min.css">

        <!-- Scripts -->
        @vite(['resources/css/app.css', 'resources/js/app.js'])
    </head>
    <body class="antialiased">
        
        <!-- Glowing Accent Blobs (Matches Dashboard Accents) -->
        <div class="fixed inset-0 -z-10 overflow-hidden bg-slate-50">
            <!-- Teal Glow Blob (Top Left) -->
            <div class="absolute -top-[20%] -left-[10%] w-[60%] h-[60%] rounded-full bg-teal-500/10 blur-[120px]"></div>
            <!-- Amber/Cyan Glow Blob (Bottom Right) -->
            <div class="absolute -bottom-[20%] -right-[10%] w-[60%] h-[60%] rounded-full bg-amber-500/10 blur-[120px]"></div>
        </div>

        <div class="min-h-screen flex flex-col justify-center items-center px-4 py-8 font-sans" style="font-family: 'Poppins', sans-serif;">
            
            <!-- Branding Kop Header -->
            <div class="flex flex-col items-center mb-6 text-center z-10">
                <img src="{{ asset('logo.png') }}" class="w-16 h-16 object-contain mb-3 drop-shadow-md">
                <h1 class="text-base font-extrabold text-slate-800 tracking-wide">Paguyuban Bravo Bekasi</h1>
                <p class="text-[9px] text-teal-600 font-bold uppercase tracking-widest mt-1">Koperasi Simpan Pinjam</p>
            </div>

            <!-- Card Container (Glassmorphic panel showing the glowing background) -->
            <div class="w-full sm:max-w-md bg-white/70 backdrop-blur-xl border border-white/60 shadow-2xl shadow-slate-200/50 rounded-3xl p-6 md:p-8 z-10">
                {{ $slot }}
            </div>
            
            <!-- Footer brand info -->
            <p class="text-[9px] text-slate-400 mt-6 text-center font-medium z-10">
                &copy; {{ date('Y') }} Paguyuban Bravo Bekasi. All rights reserved.
            </p>

        </div>
    </body>
</html>
