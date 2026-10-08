<?php

use App\Http\Controllers\ProfileController;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Auth;

use App\Http\Controllers\DashboardController;
use App\Http\Controllers\SimpananController;
use App\Http\Controllers\ApprovalSimpananController;
use App\Http\Controllers\LaporanController;

use App\Http\Controllers\PinjamanController;
use App\Http\Controllers\ApprovalPinjamanController;

use App\Http\Controllers\ApprovalKreditBarangController;
use App\Http\Controllers\KreditBarangController;

use App\Http\Controllers\ApprovalPembayaranController;
use App\Http\Controllers\PembayaranController;

use App\Http\Controllers\AnggotaController;
use App\Http\Controllers\ShuController;


Route::get('/', function () {
    return Auth::check()
        ? redirect()->route('dashboard')
        : redirect()->route('login');
});

Route::get('/pengurus/laporan/export/{type}', [LaporanController::class, 'exportCsv'])
    ->name('pengurus.laporan.export');
Route::get('/pengurus/laporan/print/{type}', [LaporanController::class, 'printPdf'])
    ->name('pengurus.laporan.print');

Route::middleware(['auth', 'pengurus'])->group(function () {

    Route::get('/pengurus/anggota', [AnggotaController::class, 'index'])
        ->name('pengurus.anggota.index');

    Route::get('/pengurus/anggota/{user}', [AnggotaController::class, 'show'])
        ->name('pengurus.anggota.show');

    // =========================
    // LAPORAN KEUANGAN
    // =========================
    Route::get('/pengurus/laporan', [LaporanController::class, 'index'])
        ->name('pengurus.laporan.index');

    // =========================
    // PENGELUARAN SHU
    // =========================
    Route::get('/pengurus/shu', [ShuController::class, 'index'])->name('pengurus.shu.index');
    Route::get('/pengurus/shu/create', [ShuController::class, 'create'])->name('pengurus.shu.create');
    Route::post('/pengurus/shu', [ShuController::class, 'store'])->name('pengurus.shu.store');
    Route::delete('/pengurus/shu/{shu}', [ShuController::class, 'destroy'])->name('pengurus.shu.destroy');
});


/*
|--------------------------------------------------------------------------
| PENGURUS AREA
|--------------------------------------------------------------------------
*/

// =========================
// PINJAMAN APPROVAL
// =========================
Route::middleware(['auth', 'pengurus'])->group(function () {

    Route::get('/pengurus/pinjaman', [ApprovalPinjamanController::class, 'index'])
        ->name('pengurus.pinjaman.index');

    Route::post('/pengurus/pinjaman/{pinjaman}/approve', [ApprovalPinjamanController::class, 'approve'])
        ->name('pengurus.pinjaman.approve');

    Route::post('/pengurus/pinjaman/{pinjaman}/reject', [ApprovalPinjamanController::class, 'reject'])
        ->name('pengurus.pinjaman.reject');
});


// =========================
// APPROVAL KREDIT BARANG
// =========================
Route::get('/pengurus/kredit-barang', [ApprovalKreditBarangController::class, 'index'])
    ->name('pengurus.kredit-barang.index');

Route::post('/pengurus/kredit-barang/{kreditBarang}/approve', [ApprovalKreditBarangController::class, 'approve'])
    ->name('pengurus.kredit-barang.approve');

Route::post('/pengurus/kredit-barang/{kreditBarang}/reject', [ApprovalKreditBarangController::class, 'reject'])
    ->name('pengurus.kredit-barang.reject');

// =========================
// PEMBAYARAN APPROVAL (PINJAMAN + KREDIT)
// =========================
Route::middleware(['auth', 'pengurus'])->group(function () {

    Route::get('/pengurus/pembayaran', [ApprovalPembayaranController::class, 'index'])
        ->name('pengurus.pembayaran.index');

    Route::post('/pengurus/pembayaran/{pembayaran}/approve', [ApprovalPembayaranController::class, 'approve'])
        ->name('pengurus.pembayaran.approve');

    Route::post('/pengurus/pembayaran/{pembayaran}/reject', [ApprovalPembayaranController::class, 'reject'])
        ->name('pengurus.pembayaran.reject');
});


/*
|--------------------------------------------------------------------------
| USER AREA
|--------------------------------------------------------------------------
*/

// =========================
// PINJAMAN USER
// =========================
Route::middleware('auth')->group(function () {

    Route::get('/pinjaman', [PinjamanController::class, 'index'])
        ->name('pinjaman.index');

    Route::get('/pinjaman/create', [PinjamanController::class, 'create'])
        ->name('pinjaman.create');

    // FORM SIMULASI (HALAMAN INPUT)
    Route::get('/pinjaman/simulasi', [PinjamanController::class, 'create'])
        ->name('pinjaman.simulasi.form');

    // PROSES SIMULASI
    Route::post('/pinjaman/simulasi', [PinjamanController::class, 'simulasi'])
        ->name('pinjaman.simulasi');

    Route::post('/pinjaman', [PinjamanController::class, 'store'])
        ->name('pinjaman.store');
});


// =========================
// KREDIT BARANG USER
// =========================
Route::middleware('auth')->group(function () {

    Route::get('/kredit-barang', [KreditBarangController::class, 'index'])
        ->name('kredit-barang.index');

    Route::get('/kredit-barang/create', [KreditBarangController::class, 'create'])
        ->name('kredit-barang.create');

    Route::post('/kredit-barang', [KreditBarangController::class, 'store'])
        ->name('kredit-barang.store');
});


// =========================
// PEMBAYARAN USER (SATU SISTEM)
// =========================
Route::middleware('auth')->group(function () {

    Route::get('/pembayaran', [PembayaranController::class, 'index'])
        ->name('pembayaran.index');

    Route::get('/pembayaran/{pembayaran}/bayar', [PembayaranController::class, 'bayar'])
        ->name('pembayaran.bayar');

    Route::post('/pembayaran/{pembayaran}/bayar', [PembayaranController::class, 'storeBayar'])
        ->name('pembayaran.storeBayar');
});


// =========================
// SISA FITUR LAIN
// =========================
Route::middleware(['auth', 'pengurus'])->group(function () {

    Route::get('/pengurus/simpanan', [ApprovalSimpananController::class, 'index'])
        ->name('pengurus.simpanan.index');

    Route::post('/pengurus/simpanan/{simpanan}/approve', [ApprovalSimpananController::class, 'approve'])
        ->name('pengurus.simpanan.approve');

    Route::post('/pengurus/simpanan/{simpanan}/reject', [ApprovalSimpananController::class, 'reject'])
        ->name('pengurus.simpanan.reject');
});

Route::middleware('auth')->group(function () {

    Route::get('/simpanan', [SimpananController::class, 'index'])
        ->name('simpanan.index');

    Route::get('/simpanan/create', [SimpananController::class, 'create'])
        ->name('simpanan.create');

    Route::post('/simpanan', [SimpananController::class, 'store'])
        ->name('simpanan.store');
});


// =========================
// DASHBOARD & PROFILE
// =========================
Route::get('/dashboard', [DashboardController::class, 'index'])
    ->middleware(['auth'])
    ->name('dashboard');

Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');
});

require __DIR__ . '/auth.php';
