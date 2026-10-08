<?php

use App\Http\Controllers\Api\ApiController;

Route::post('/login', [ApiController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [ApiController::class, 'logout']);
    Route::get('/profile', [ApiController::class, 'profile']);
    Route::put('/profile', [ApiController::class, 'updateProfile']);
    
    Route::get('/dashboard', [ApiController::class, 'dashboard']);
    
    // Simpanan
    Route::get('/simpanan', [ApiController::class, 'getSimpanan']);
    Route::post('/simpanan', [ApiController::class, 'storeSimpanan']);
    
    // Pinjaman
    Route::get('/pinjaman', [ApiController::class, 'getPinjaman']);
    Route::post('/pinjaman', [ApiController::class, 'storePinjaman']);
    Route::post('/pinjaman/simulasi', [ApiController::class, 'simulasiPinjaman']);
    
    // Kredit Barang
    Route::get('/kredit-barang', [ApiController::class, 'getKreditBarang']);
    Route::post('/kredit-barang', [ApiController::class, 'storeKreditBarang']);
    Route::post('/kredit-barang/simulasi', [ApiController::class, 'simulasiKredit']);
    
    // Pembayaran
    Route::get('/pembayaran', [ApiController::class, 'getPembayaran']);
    Route::post('/pembayaran/{id}/bayar', [ApiController::class, 'storeBayarPembayaran']);
    
    // Pengurus Area
    Route::middleware('pengurus')->group(function () {
        Route::get('/pengurus/anggota', [ApiController::class, 'getAnggota']);
        Route::post('/pengurus/anggota', [ApiController::class, 'storeAnggota']);
        Route::get('/pengurus/anggota/{id}', [ApiController::class, 'getAnggotaDetail']);
        Route::put('/pengurus/anggota/{id}', [ApiController::class, 'updateAnggota']);
        Route::delete('/pengurus/anggota/{id}', [ApiController::class, 'destroyAnggota']);
        Route::get('/pengurus/laporan', [ApiController::class, 'getLaporan']);
        Route::get('/pengurus/laporan/{type}', [ApiController::class, 'getLaporanDetail']);
        Route::get('/pengurus/shu', [ApiController::class, 'getShu']);
        Route::post('/pengurus/shu', [ApiController::class, 'storeShu']);
        Route::delete('/pengurus/shu/{id}', [ApiController::class, 'destroyShu']);
        
        // Approvals
        Route::get('/pengurus/approvals', [ApiController::class, 'getPendingApprovals']);
        
        Route::post('/pengurus/simpanan/{id}/approve', [ApiController::class, 'approveSimpanan']);
        Route::post('/pengurus/simpanan/{id}/reject', [ApiController::class, 'rejectSimpanan']);
        
        Route::post('/pengurus/pinjaman/{id}/approve', [ApiController::class, 'approvePinjaman']);
        Route::post('/pengurus/pinjaman/{id}/reject', [ApiController::class, 'rejectPinjaman']);
        
        Route::post('/pengurus/kredit-barang/{id}/approve', [ApiController::class, 'approveKreditBarang']);
        Route::post('/pengurus/kredit-barang/{id}/reject', [ApiController::class, 'rejectKreditBarang']);
        
        Route::post('/pengurus/pembayaran/{id}/approve', [ApiController::class, 'approvePembayaran']);
        Route::post('/pengurus/pembayaran/{id}/reject', [ApiController::class, 'rejectPembayaran']);
    });
});
