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

    <!-- SweetAlert2 -->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <!-- NPROGRESS -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/nprogress/0.2.0/nprogress.min.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/nprogress/0.2.0/nprogress.min.js"></script>

    @vite([
        'resources/css/app.css',
        'resources/js/app.js'
    ])

    <style>
        :root {
            --primary: #0d9488;
            --primary-dark: #0f766e;
            --secondary: #2563eb;
            --bg: #f8fafc;
        }

        html {
            scroll-behavior: smooth;
        }

        body {
            font-family: 'Poppins', sans-serif;
            background: 
                radial-gradient(circle at top right, rgba(13, 148, 136, 0.04), transparent 45%),
                radial-gradient(circle at top left, rgba(37, 99, 235, 0.04), transparent 45%),
                #f8fafc;
            background-attachment: fixed;
        }

        /* Safe area padding for mobile bottom bar */
        .safe-bottom {
            padding-bottom: calc(90px + env(safe-area-inset-bottom));
        }

        /* Global Fade-Up Animation */
        .fade-up {
            animation: fadeUp .35s cubic-bezier(0.16, 1, 0.3, 1);
        }

        @keyframes fadeUp {
            from {
                opacity: 0;
                transform: translateY(12px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* NProgress customization */
        #nprogress .bar {
            background: #0d9488 !important;
            height: 3px !important;
        }

        #nprogress .peg {
            box-shadow: 0 0 10px #0d9488, 0 0 5px #0d9488 !important;
        }

        /* Modern Status Badges */
        .badge-pill {
            padding: 0.25rem 0.75rem;
            font-size: 0.725rem;
            font-weight: 600;
            border-radius: 9999px;
            display: inline-flex;
            align-items: center;
            gap: 0.25rem;
        }

        .badge-approved, .badge-lunas {
            background-color: #dcfce7;
            color: #166534;
        }

        .badge-pending {
            background-color: #fef3c7;
            color: #92400e;
        }

        .badge-rejected, .badge-belum-bayar {
            background-color: #fee2e2;
            color: #991b1b;
        }

        /* Dynamic Tap Feedback */
        .tap-scale {
            transition: transform 0.1s ease;
        }
        .tap-scale:active {
            transform: scale(0.97);
        }
    </style>
</head>

<body class="antialiased text-slate-800 bg-[#f8fafc]">

    <div class="min-h-screen">
        
        <!-- Navigation Component: holds sidebar and mobile tab navigation -->
        @include('layouts.navigation')

        <!-- MAIN LAYOUT AREA -->
        <div class="lg:pl-72 min-h-screen flex flex-col transition-all duration-300">

            <!-- Sticky Top Header (Desktop Only) -->
            @isset($header)
            <header class="hidden lg:block sticky top-0 z-30 bg-white/80 backdrop-blur-md border-b border-slate-200/50 py-4 px-8">
                <div class="max-w-7xl mx-auto">
                    <div class="fade-up">
                        {{ $header }}
                    </div>
                </div>
            </header>
            @endisset

            <!-- MAIN CONTENT AREA -->
            <main class="flex-1 max-w-7xl w-full mx-auto px-4 py-6 md:p-6 lg:p-8 pt-20 lg:pt-8 pb-28 lg:pb-12 safe-bottom page-enter">
                
                <!-- Mobile Header Title (Inline inside Content) -->
                @isset($header)
                <div class="lg:hidden mb-5 pb-3 border-b border-slate-200/60">
                    <div class="fade-up">
                        {{ $header }}
                    </div>
                </div>
                @endisset

                <div class="fade-up">
                    {{ $slot }}
                </div>
            </main>

        </div>

    </div>

    <!-- GLOBAL LOADING -->
    <div id="global-loading" class="hidden fixed inset-0 z-[9999] bg-black/40 backdrop-blur-sm">
        <div class="h-full flex items-center justify-center">
            <div class="bg-white rounded-3xl px-8 py-6 shadow-2xl text-center max-w-xs mx-4">
                <div class="w-14 h-14 border-4 border-teal-200 border-t-teal-500 rounded-full animate-spin mx-auto mb-4"></div>
                <h3 class="font-semibold text-slate-800">Sedang Memproses...</h3>
                <p class="text-sm text-slate-500 mt-1">Mohon tunggu beberapa saat</p>
            </div>
        </div>
    </div>

    {{-- SUCCESS ALERT --}}
    @if(session('success'))
    <script>
        document.addEventListener('DOMContentLoaded', () => {
            Swal.fire({
                toast: true,
                position: 'top-end',
                icon: 'success',
                title: @json(session('success')),
                background: '#ffffff',
                color: '#0f172a',
                showConfirmButton: false,
                timer: 2500,
                timerProgressBar: true,
                customClass: {
                    popup: 'rounded-2xl shadow-lg border border-slate-100'
                }
            });
        });
    </script>
    @endif

    {{-- ERROR ALERT --}}
    @if(session('error'))
    <script>
        document.addEventListener('DOMContentLoaded', () => {
            Swal.fire({
                icon: 'error',
                title: 'Terjadi Kesalahan',
                text: @json(session('error')),
                confirmButtonColor: '#ef4444',
                background: '#fff',
                customClass: {
                    popup: 'rounded-2xl'
                }
            });
        });
    </script>
    @endif

    {{-- VALIDATION ALERT --}}
    @if ($errors->any())
    <script>
        document.addEventListener('DOMContentLoaded', () => {
            Swal.fire({
                icon: 'warning',
                title: 'Validasi Gagal',
                html: `{!! implode('<br>', $errors->all()) !!}`,
                confirmButtonColor: '#0d9488',
                background: '#fff',
                customClass: {
                    popup: 'rounded-2xl'
                }
            });
        });
    </script>
    @endif

    <script>
        document.addEventListener('DOMContentLoaded', () => {
            NProgress.done();

            // Page navigation transition loading
            document.querySelectorAll('a').forEach(link => {
                if (
                    link.href && 
                    !link.href.startsWith('#') && 
                    !link.target && 
                    !link.href.startsWith('javascript:') &&
                    !link.getAttribute('@click') &&
                    !link.getAttribute('x-on:click')
                ) {
                    link.addEventListener('click', () => {
                        NProgress.start();
                    });
                }
            });

            // Form submit loading
            document.querySelectorAll('form').forEach(form => {
                form.addEventListener('submit', (e) => {
                    setTimeout(() => {
                        if (!e.defaultPrevented) {
                            const loading = document.getElementById('global-loading');
                            if (loading) {
                                loading.classList.remove('hidden');
                            }
                        }
                    }, 50);
                });
            });

            // Confirmation for delete actions
            document.querySelectorAll('.btn-delete').forEach(btn => {
                btn.addEventListener('click', function(e) {
                    e.preventDefault();
                    const form = this.closest('form');
                    Swal.fire({
                        title: 'Yakin ingin menghapus?',
                        text: 'Data yang dihapus tidak dapat dikembalikan.',
                        icon: 'warning',
                        showCancelButton: true,
                        confirmButtonColor: '#ef4444',
                        cancelButtonColor: '#64748b',
                        confirmButtonText: 'Ya, Hapus',
                        cancelButtonText: 'Batal',
                        customClass: {
                            popup: 'rounded-2xl'
                        }
                    }).then((result) => {
                        if (result.isConfirmed) {
                            form.submit();
                        }
                    });
                });
            });
        });
    </script>

</body>

</html>