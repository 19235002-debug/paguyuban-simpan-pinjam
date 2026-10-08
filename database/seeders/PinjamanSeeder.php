<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Pinjaman;
use App\Models\Pembayaran;
use Carbon\Carbon;

class PinjamanSeeder extends Seeder
{
    public function run(): void
    {
        $inserted  = 0;
        $skipped   = 0;
        $notFound  = [];

        $pembayaranExcel = [
            ['name' => 'AGUS PURWANTO', 'angsuran_ke' => 1, 'tanggal_bayar' => '2024-10-03', 'nominal' => 500000, 'status' => 'approved'],
            ['name' => 'AGUS PURWANTO', 'angsuran_ke' => 2, 'tanggal_bayar' => '2025-02-02', 'nominal' => 500000, 'status' => 'approved'],
            ['name' => 'AGUS PURWANTO', 'angsuran_ke' => 3, 'tanggal_bayar' => '2025-03-03', 'nominal' => 500000, 'status' => 'approved'],
            ['name' => 'AGUS PURWANTO', 'angsuran_ke' => 4, 'tanggal_bayar' => '2025-05-04', 'nominal' => 500000, 'status' => 'approved'],
            ['name' => 'AGUS PURWANTO', 'angsuran_ke' => 5, 'tanggal_bayar' => '2025-06-01', 'nominal' => 500000, 'status' => 'approved'],
            ['name' => 'AGUS PURWANTO', 'angsuran_ke' => 6, 'tanggal_bayar' => '2025-08-04', 'nominal' => 500000, 'status' => 'approved'],
            ['name' => 'AGUS PURWANTO', 'angsuran_ke' => 7, 'tanggal_bayar' => '2026-02-04', 'nominal' => 500000, 'status' => 'approved'],
            ['name' => 'AGUS PURWANTO', 'angsuran_ke' => 8, 'tanggal_bayar' => '2026-03-04', 'nominal' => 500000, 'status' => 'approved'],
            ['name' => 'AGUS PURWANTO', 'angsuran_ke' => 9, 'tanggal_bayar' => '2026-05-05', 'nominal' => 500000, 'status' => 'approved'],
            ['name' => 'AGUS PURWANTO', 'angsuran_ke' => 10, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'AGUS PURWANTO', 'angsuran_ke' => 11, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'AGUS PURWANTO', 'angsuran_ke' => 12, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'AGUS PURWANTO', 'angsuran_ke' => 13, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'AGUS PURWANTO', 'angsuran_ke' => 14, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'AGUS PURWANTO', 'angsuran_ke' => 15, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'ARTA WIGUNA', 'angsuran_ke' => 7, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'ARTA WIGUNA', 'angsuran_ke' => 8, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'ARTA WIGUNA', 'angsuran_ke' => 9, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'ARTA WIGUNA', 'angsuran_ke' => 10, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'TARKA WIJAYA', 'angsuran_ke' => 1, 'tanggal_bayar' => '2025-10-01', 'nominal' => 220000, 'status' => 'approved'],
            ['name' => 'TARKA WIJAYA', 'angsuran_ke' => 2, 'tanggal_bayar' => '2025-11-03', 'nominal' => 220000, 'status' => 'approved'],
            ['name' => 'TARKA WIJAYA', 'angsuran_ke' => 3, 'tanggal_bayar' => '2025-11-30', 'nominal' => 220000, 'status' => 'approved'],
            ['name' => 'TARKA WIJAYA', 'angsuran_ke' => 4, 'tanggal_bayar' => '2026-02-01', 'nominal' => 220000, 'status' => 'approved'],
            ['name' => 'TARKA WIJAYA', 'angsuran_ke' => 5, 'tanggal_bayar' => '2026-03-01', 'nominal' => 220000, 'status' => 'approved'],
            ['name' => 'TARKA WIJAYA', 'angsuran_ke' => 6, 'tanggal_bayar' => '2026-04-01', 'nominal' => 220000, 'status' => 'approved'],
            ['name' => 'TARKA WIJAYA', 'angsuran_ke' => 7, 'tanggal_bayar' => '2026-04-30', 'nominal' => 220000, 'status' => 'approved'],
            ['name' => 'TARKA WIJAYA', 'angsuran_ke' => 8, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'TARKA WIJAYA', 'angsuran_ke' => 9, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'TARKA WIJAYA', 'angsuran_ke' => 10, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'GUNTUR ARYA SUTA', 'angsuran_ke' => 1, 'tanggal_bayar' => '2025-11-28', 'nominal' => 440000, 'status' => 'approved'],
            ['name' => 'GUNTUR ARYA SUTA', 'angsuran_ke' => 2, 'tanggal_bayar' => '2025-12-30', 'nominal' => 440000, 'status' => 'approved'],
            ['name' => 'GUNTUR ARYA SUTA', 'angsuran_ke' => 3, 'tanggal_bayar' => '2026-01-30', 'nominal' => 440000, 'status' => 'approved'],
            ['name' => 'GUNTUR ARYA SUTA', 'angsuran_ke' => 4, 'tanggal_bayar' => '2026-03-01', 'nominal' => 440000, 'status' => 'approved'],
            ['name' => 'GUNTUR ARYA SUTA', 'angsuran_ke' => 5, 'tanggal_bayar' => '2026-04-01', 'nominal' => 440000, 'status' => 'approved'],
            ['name' => 'GUNTUR ARYA SUTA', 'angsuran_ke' => 6, 'tanggal_bayar' => '2026-05-01', 'nominal' => 440000, 'status' => 'approved'],
            ['name' => 'GUNTUR ARYA SUTA', 'angsuran_ke' => 7, 'tanggal_bayar' => '2024-08-05', 'nominal' => 440000, 'status' => 'approved'],
            ['name' => 'GUNTUR ARYA SUTA', 'angsuran_ke' => 8, 'tanggal_bayar' => '2024-09-05', 'nominal' => 440000, 'status' => 'approved'],
            ['name' => 'GUNTUR ARYA SUTA', 'angsuran_ke' => 9, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'GUNTUR ARYA SUTA', 'angsuran_ke' => 10, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'HENDRA', 'angsuran_ke' => 1, 'tanggal_bayar' => '2025-12-02', 'nominal' => 220000, 'status' => 'approved'],
            ['name' => 'HENDRA', 'angsuran_ke' => 2, 'tanggal_bayar' => '2025-01-05', 'nominal' => 220000, 'status' => 'approved'],
            ['name' => 'HENDRA', 'angsuran_ke' => 3, 'tanggal_bayar' => '2026-02-03', 'nominal' => 220000, 'status' => 'approved'],
            ['name' => 'HENDRA', 'angsuran_ke' => 4, 'tanggal_bayar' => null, 'nominal' => 220000, 'status' => 'approved'],
            ['name' => 'HENDRA', 'angsuran_ke' => 5, 'tanggal_bayar' => null, 'nominal' => 220000, 'status' => 'approved'],
            ['name' => 'MUHAMMAD SOLEH', 'angsuran_ke' => 1, 'tanggal_bayar' => '2026-03-31', 'nominal' => 300000, 'status' => 'approved'],
            ['name' => 'MUHAMMAD SOLEH', 'angsuran_ke' => 2, 'tanggal_bayar' => '2026-04-30', 'nominal' => 300000, 'status' => 'approved'],
            ['name' => 'MUHAMMAD SOLEH', 'angsuran_ke' => 3, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'MUHAMMAD SOLEH', 'angsuran_ke' => 4, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'MUHAMMAD SOLEH', 'angsuran_ke' => 5, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'MUHAMMAD SOLEH', 'angsuran_ke' => 6, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'MUHAMMAD SOLEH', 'angsuran_ke' => 7, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'MUHAMMAD SOLEH', 'angsuran_ke' => 8, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'MUHAMMAD SOLEH', 'angsuran_ke' => 9, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'MUHAMMAD SOLEH', 'angsuran_ke' => 10, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'MUHAMMAD SOLEH', 'angsuran_ke' => 11, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'GIYATNO', 'angsuran_ke' => 1, 'tanggal_bayar' => '2026-02-03', 'nominal' => 275000, 'status' => 'approved'],
            ['name' => 'GIYATNO', 'angsuran_ke' => 2, 'tanggal_bayar' => '2026-03-14', 'nominal' => 275000, 'status' => 'approved'],
            ['name' => 'GIYATNO', 'angsuran_ke' => 3, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'GIYATNO', 'angsuran_ke' => 4, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'GIYATNO', 'angsuran_ke' => 5, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'GIYATNO', 'angsuran_ke' => 6, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'GIYATNO', 'angsuran_ke' => 7, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'GIYATNO', 'angsuran_ke' => 8, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'GIYATNO', 'angsuran_ke' => 9, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'GIYATNO', 'angsuran_ke' => 10, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'ADE AHMAD SAMSUDIN', 'angsuran_ke' => 1, 'tanggal_bayar' => '2025-12-30', 'nominal' => 110000, 'status' => 'approved'],
            ['name' => 'ADE AHMAD SAMSUDIN', 'angsuran_ke' => 2, 'tanggal_bayar' => '2026-02-03', 'nominal' => 110000, 'status' => 'approved'],
            ['name' => 'ADE AHMAD SAMSUDIN', 'angsuran_ke' => 3, 'tanggal_bayar' => '2026-03-05', 'nominal' => 110000, 'status' => 'approved'],
            ['name' => 'ADE AHMAD SAMSUDIN', 'angsuran_ke' => 4, 'tanggal_bayar' => '2026-03-31', 'nominal' => 110000, 'status' => 'approved'],
            ['name' => 'ADE AHMAD SAMSUDIN', 'angsuran_ke' => 5, 'tanggal_bayar' => '2026-04-30', 'nominal' => 110000, 'status' => 'approved'],
            ['name' => 'ADE AHMAD SAMSUDIN', 'angsuran_ke' => 6, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'ADE AHMAD SAMSUDIN', 'angsuran_ke' => 7, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'ADE AHMAD SAMSUDIN', 'angsuran_ke' => 8, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'ADE AHMAD SAMSUDIN', 'angsuran_ke' => 9, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'ADE AHMAD SAMSUDIN', 'angsuran_ke' => 10, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'SAEPUL MUHAEMIN', 'angsuran_ke' => 1, 'tanggal_bayar' => '2025-11-28', 'nominal' => 220000, 'status' => 'approved'],
            ['name' => 'SAEPUL MUHAEMIN', 'angsuran_ke' => 2, 'tanggal_bayar' => '2025-12-30', 'nominal' => 220000, 'status' => 'approved'],
            ['name' => 'SAEPUL MUHAEMIN', 'angsuran_ke' => 3, 'tanggal_bayar' => '2026-02-01', 'nominal' => 220000, 'status' => 'approved'],
            ['name' => 'SAEPUL MUHAEMIN', 'angsuran_ke' => 4, 'tanggal_bayar' => '2026-03-03', 'nominal' => 220000, 'status' => 'approved'],
            ['name' => 'SAEPUL MUHAEMIN', 'angsuran_ke' => 5, 'tanggal_bayar' => '2026-03-31', 'nominal' => 220000, 'status' => 'approved'],
            ['name' => 'SAEPUL MUHAEMIN', 'angsuran_ke' => 6, 'tanggal_bayar' => '2026-04-30', 'nominal' => 220000, 'status' => 'approved'],
            ['name' => 'SAEPUL MUHAEMIN', 'angsuran_ke' => 7, 'tanggal_bayar' => '2026-05-30', 'nominal' => 220000, 'status' => 'approved'],
            ['name' => 'SAEPUL MUHAEMIN', 'angsuran_ke' => 8, 'tanggal_bayar' => '2025-06-30', 'nominal' => 220000, 'status' => 'approved'],
            ['name' => 'SAEPUL MUHAEMIN', 'angsuran_ke' => 9, 'tanggal_bayar' => '2026-07-08', 'nominal' => 220000, 'status' => 'approved'],
            ['name' => 'SAEPUL MUHAEMIN', 'angsuran_ke' => 10, 'tanggal_bayar' => '2026-07-08', 'nominal' => 220000, 'status' => 'approved'],
            ['name' => 'SAEPUL MUHAEMIN', 'angsuran_ke' => 11, 'tanggal_bayar' => '2026-07-31', 'nominal' => 500000, 'status' => 'approved'],
            ['name' => 'SAEPUL MUHAEMIN', 'angsuran_ke' => 1, 'tanggal_bayar' => '2025-12-02', 'nominal' => 220000, 'status' => 'approved'],
            ['name' => 'SAEPUL MUHAEMIN', 'angsuran_ke' => 2, 'tanggal_bayar' => '2026-01-14', 'nominal' => 220000, 'status' => 'approved'],
            ['name' => 'SAEPUL MUHAEMIN', 'angsuran_ke' => 3, 'tanggal_bayar' => '2026-02-05', 'nominal' => 220000, 'status' => 'approved'],
            ['name' => 'SAEPUL MUHAEMIN', 'angsuran_ke' => 4, 'tanggal_bayar' => '2026-03-03', 'nominal' => 220000, 'status' => 'approved'],
            ['name' => 'SAEPUL MUHAEMIN', 'angsuran_ke' => 5, 'tanggal_bayar' => '2026-04-02', 'nominal' => 220000, 'status' => 'approved'],
            ['name' => 'SAEPUL MUHAEMIN', 'angsuran_ke' => 6, 'tanggal_bayar' => '2026-05-05', 'nominal' => 220000, 'status' => 'approved'],
            ['name' => 'SAEPUL MUHAEMIN', 'angsuran_ke' => 7, 'tanggal_bayar' => '2026-06-01', 'nominal' => 220000, 'status' => 'approved'],
            ['name' => 'SAEPUL MUHAEMIN', 'angsuran_ke' => 8, 'tanggal_bayar' => '2026-07-01', 'nominal' => 220000, 'status' => 'approved'],
            ['name' => 'SAEPUL MUHAEMIN', 'angsuran_ke' => 9, 'tanggal_bayar' => '2026-08-03', 'nominal' => 220000, 'status' => 'approved'],
            ['name' => 'SAEPUL MUHAEMIN', 'angsuran_ke' => 10, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'TRIYO SUTOPO', 'angsuran_ke' => 1, 'tanggal_bayar' => '2026-01-02', 'nominal' => 220000, 'status' => 'approved'],
            ['name' => 'TRIYO SUTOPO', 'angsuran_ke' => 2, 'tanggal_bayar' => '2026-01-31', 'nominal' => 220000, 'status' => 'approved'],
            ['name' => 'TRIYO SUTOPO', 'angsuran_ke' => 3, 'tanggal_bayar' => '2026-03-02', 'nominal' => 220000, 'status' => 'approved'],
            ['name' => 'TRIYO SUTOPO', 'angsuran_ke' => 4, 'tanggal_bayar' => '2026-04-02', 'nominal' => 220000, 'status' => 'approved'],
            ['name' => 'TRIYO SUTOPO', 'angsuran_ke' => 5, 'tanggal_bayar' => '2026-05-05', 'nominal' => 220000, 'status' => 'approved'],
            ['name' => 'TRIYO SUTOPO', 'angsuran_ke' => 6, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'TRIYO SUTOPO', 'angsuran_ke' => 7, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'TRIYO SUTOPO', 'angsuran_ke' => 8, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'TRIYO SUTOPO', 'angsuran_ke' => 9, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'TRIYO SUTOPO', 'angsuran_ke' => 10, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'MUSAFAK', 'angsuran_ke' => 1, 'tanggal_bayar' => '2026-02-03', 'nominal' => 500000, 'status' => 'approved'],
            ['name' => 'MUSAFAK', 'angsuran_ke' => 2, 'tanggal_bayar' => '2026-03-01', 'nominal' => 500000, 'status' => 'approved'],
            ['name' => 'MUSAFAK', 'angsuran_ke' => 3, 'tanggal_bayar' => '2026-04-01', 'nominal' => 500000, 'status' => 'approved'],
            ['name' => 'MUSAFAK', 'angsuran_ke' => 4, 'tanggal_bayar' => '2026-05-04', 'nominal' => 500000, 'status' => 'approved'],
            ['name' => 'MUSAFAK', 'angsuran_ke' => 5, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'SAEPUL MUHAEMIN', 'angsuran_ke' => 1, 'tanggal_bayar' => '2026-02-07', 'nominal' => 250000, 'status' => 'approved'],
            ['name' => 'SAEPUL MUHAEMIN', 'angsuran_ke' => 2, 'tanggal_bayar' => '2026-04-01', 'nominal' => 300000, 'status' => 'approved'],
            ['name' => 'SAEPUL MUHAEMIN', 'angsuran_ke' => 3, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'SAEPUL MUHAEMIN', 'angsuran_ke' => 4, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'SAEPUL MUHAEMIN', 'angsuran_ke' => 5, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'SAEPUL MUHAEMIN', 'angsuran_ke' => 6, 'tanggal_bayar' => null, 'nominal' => 0, 'status' => 'belum_bayar'],
            ['name' => 'ARTA WIGUNA', 'angsuran_ke' => 1, 'tanggal_bayar' => '2025-09-02', 'nominal' => 850000, 'status' => 'approved'],
            ['name' => 'ARTA WIGUNA', 'angsuran_ke' => 2, 'tanggal_bayar' => '2025-10-01', 'nominal' => 850000, 'status' => 'approved'],
            ['name' => 'ARTA WIGUNA', 'angsuran_ke' => 3, 'tanggal_bayar' => '2025-12-01', 'nominal' => 800000, 'status' => 'approved'],
            ['name' => 'ARTA WIGUNA', 'angsuran_ke' => 4, 'tanggal_bayar' => '2026-02-02', 'nominal' => 850000, 'status' => 'approved'],
            ['name' => 'ARTA WIGUNA', 'angsuran_ke' => 5, 'tanggal_bayar' => '2026-03-05', 'nominal' => 850000, 'status' => 'approved'],
            ['name' => 'ARTA WIGUNA', 'angsuran_ke' => 6, 'tanggal_bayar' => '2026-05-03', 'nominal' => 850000, 'status' => 'approved'],
            ['name' => 'ARTA WIGUNA', 'angsuran_ke' => 7, 'tanggal_bayar' => '2026-06-04', 'nominal' => 850000, 'status' => 'approved'],
        ];

        $pinjamans = [
            [
                'name'               => 'SEPRUDIANTO',
                'tanggal_pinjam'     => '2024-08-01',
                'nominal'            => 4000000,
                'persen_bunga'       => 10.00,
                'nominal_bunga'      => 400000,
                'total_pengembalian' => 4400000,
                'tenor_bulan'        => 10,
                'angsuran_per_bulan' => 440000,
                'sisa_pinjaman'      => 0,
                'status'             => 'lunas',
                'keterangan'         => 'Pinjaman Agustus 2024',
            ],
            [
                'name'               => 'SAEPUL MUHAEMIN',
                'tanggal_pinjam'     => '2024-12-01',
                'nominal'            => 2100000,
                'persen_bunga'       => 10.00,
                'nominal_bunga'      => 0,
                'total_pengembalian' => 2100000,
                'tenor_bulan'        => 10,
                'angsuran_per_bulan' => 210000,
                'sisa_pinjaman'      => 0,
                'status'             => 'lunas',
                'keterangan'         => 'Pinjaman Desember 2024',
            ],
            [
                'name'               => 'GIYATNO',
                'tanggal_pinjam'     => '2024-11-01',
                'nominal'            => 2500000,
                'persen_bunga'       => 10.00,
                'nominal_bunga'      => 250000,
                'total_pengembalian' => 2750000,
                'tenor_bulan'        => 10,
                'angsuran_per_bulan' => 275000,
                'sisa_pinjaman'      => 0,
                'status'             => 'lunas',
                'keterangan'         => 'Pinjaman November 2024',
            ],
            [
                'name'               => 'RUMIN SAPUTRA',
                'tanggal_pinjam'     => '2025-09-01',
                'nominal'            => 3000000,
                'persen_bunga'       => 10.00,
                'nominal_bunga'      => 300000,
                'total_pengembalian' => 3300000,
                'tenor_bulan'        => 10,
                'angsuran_per_bulan' => 330000,
                'sisa_pinjaman'      => 0,
                'status'             => 'lunas',
                'keterangan'         => 'Pinjaman September 2025',
            ],
            [
                'name'               => 'AGUS PURWANTO',
                'tanggal_pinjam'     => '2024-09-01',
                'nominal'            => 7500000,
                'persen_bunga'       => 10.00,
                'nominal_bunga'      => 0,
                'total_pengembalian' => 7500000,
                'tenor_bulan'        => 15,
                'angsuran_per_bulan' => 500000,
                'sisa_pinjaman'      => 3000000,
                'status'             => 'approved',
                'keterangan'         => 'Pembelian Laptop',
            ],
            [
                'name'               => 'ARTA WIGUNA',
                'tanggal_pinjam'     => '2025-11-01',
                'nominal'            => 1500000,
                'persen_bunga'       => 5.00,
                'nominal_bunga'      => 75000,
                'total_pengembalian' => 1575000,
                'tenor_bulan'        => 6,
                'angsuran_per_bulan' => 262500,
                'sisa_pinjaman'      => 0,
                'status'             => 'lunas',
                'keterangan'         => 'Pinjaman November 2025',
            ],
            [
                'name'               => 'TARKA WIJAYA',
                'tanggal_pinjam'     => '2025-11-01',
                'nominal'            => 500000,
                'persen_bunga'       => 10.00,
                'nominal_bunga'      => 50000,
                'total_pengembalian' => 550000,
                'tenor_bulan'        => 6,
                'angsuran_per_bulan' => 91667,
                'sisa_pinjaman'      => 0,
                'status'             => 'lunas',
                'keterangan'         => 'Pinjaman November 2025',
            ],
            [
                'name'               => 'HENDRA',
                'tanggal_pinjam'     => '2024-12-01',
                'nominal'            => 1000000,
                'persen_bunga'       => 10.00,
                'nominal_bunga'      => 100000,
                'total_pengembalian' => 1100000,
                'tenor_bulan'        => 6,
                'angsuran_per_bulan' => 183333,
                'sisa_pinjaman'      => 0,
                'status'             => 'lunas',
                'keterangan'         => 'Pinjaman Desember 2024',
            ],
            [
                'name'               => 'TRIYO SUTOPO',
                'tanggal_pinjam'     => '2024-12-01',
                'nominal'            => 8000000,
                'persen_bunga'       => 12.50,
                'nominal_bunga'      => 1000000,
                'total_pengembalian' => 9000000,
                'tenor_bulan'        => 12,
                'angsuran_per_bulan' => 750000,
                'sisa_pinjaman'      => 0,
                'status'             => 'lunas',
                'keterangan'         => 'Pinjaman Desember 2024',
            ],
            [
                'name'               => 'MADIH IRAMA',
                'tanggal_pinjam'     => '2025-01-01',
                'nominal'            => 3000000,
                'persen_bunga'       => 10.00,
                'nominal_bunga'      => 300000,
                'total_pengembalian' => 3300000,
                'tenor_bulan'        => 10,
                'angsuran_per_bulan' => 330000,
                'sisa_pinjaman'      => 0,
                'status'             => 'lunas',
                'keterangan'         => 'Pinjaman Januari 2025',
            ],
            [
                'name'               => 'DIKA ADITYA',
                'tanggal_pinjam'     => '2025-01-01',
                'nominal'            => 2000000,
                'persen_bunga'       => 5.00,
                'nominal_bunga'      => 100000,
                'total_pengembalian' => 2100000,
                'tenor_bulan'        => 6,
                'angsuran_per_bulan' => 350000,
                'sisa_pinjaman'      => 0,
                'status'             => 'lunas',
                'keterangan'         => 'Pinjaman Januari 2025',
            ],
            [
                'name'               => 'TARKA WIJAYA',
                'tanggal_pinjam'     => '2025-01-01',
                'nominal'            => 2000000,
                'persen_bunga'       => 10.00,
                'nominal_bunga'      => 200000,
                'total_pengembalian' => 2200000,
                'tenor_bulan'        => 6,
                'angsuran_per_bulan' => 366667,
                'sisa_pinjaman'      => 0,
                'status'             => 'lunas',
                'keterangan'         => 'Pinjaman Januari 2025',
            ],
            [
                'name'               => 'DAFA ANASSYAH MUTIARA TAMA',
                'tanggal_pinjam'     => '2025-02-01',
                'nominal'            => 5000000,
                'persen_bunga'       => 10.00,
                'nominal_bunga'      => 500000,
                'total_pengembalian' => 5500000,
                'tenor_bulan'        => 2,
                'angsuran_per_bulan' => 550000,
                'sisa_pinjaman'      => 1000000,
                'status'             => 'approved',
                'keterangan'         => 'Pinjaman Februari 2025',
            ],
            [
                'name'               => 'GIYATNO',
                'tanggal_pinjam'     => '2025-04-01',
                'nominal'            => 2500000,
                'persen_bunga'       => 10.00,
                'nominal_bunga'      => 250000,
                'total_pengembalian' => 2750000,
                'tenor_bulan'        => 2,
                'angsuran_per_bulan' => 275000,
                'sisa_pinjaman'      => 500000,
                'status'             => 'approved',
                'keterangan'         => 'Pinjaman April 2025',
            ],
            [
                'name'               => 'SOLEHUDIN',
                'tanggal_pinjam'     => '2025-04-01',
                'nominal'            => 2000000,
                'persen_bunga'       => 5.00,
                'nominal_bunga'      => 100000,
                'total_pengembalian' => 2100000,
                'tenor_bulan'        => 3,
                'angsuran_per_bulan' => 200000,
                'sisa_pinjaman'      => 1170000,
                'status'             => 'approved',
                'keterangan'         => 'Pinjaman April 2025',
            ],
            [
                'name'               => 'SAEPUL MUHAEMIN',
                'tanggal_pinjam'     => '2025-11-01',
                'nominal'            => 2000000,
                'persen_bunga'       => 5.00,
                'nominal_bunga'      => 100000,
                'total_pengembalian' => 2100000,
                'tenor_bulan'        => 4,
                'angsuran_per_bulan' => 500000,
                'sisa_pinjaman'      => 2000000,
                'status'             => 'approved',
                'keterangan'         => 'Pinjaman November 2025',
            ],
            [
                'name'               => 'ARTA WIGUNA',
                'tanggal_pinjam'     => '2025-08-01',
                'nominal'            => 8000000,
                'persen_bunga'       => 6.25,
                'nominal_bunga'      => 500000,
                'total_pengembalian' => 8500000,
                'tenor_bulan'        => 10,
                'angsuran_per_bulan' => 850000,
                'sisa_pinjaman'      => 6200000,
                'status'             => 'approved',
                'keterangan'         => 'Pinjaman Agustus 2025',
            ],
            [
                'name'               => 'MADIH IRAMA',
                'tanggal_pinjam'     => '2025-07-01',
                'nominal'            => 6300000,
                'persen_bunga'       => 11.11,
                'nominal_bunga'      => 700000,
                'total_pengembalian' => 7000000,
                'tenor_bulan'        => 5,
                'angsuran_per_bulan' => 890000,
                'sisa_pinjaman'      => 4450000,
                'status'             => 'approved',
                'keterangan'         => 'Pinjaman Juli 2025',
            ],
            [
                'name'               => 'MUHAMMAD SOLEH',
                'tanggal_pinjam'     => '2025-09-01',
                'nominal'            => 1500000,
                'persen_bunga'       => 10.00,
                'nominal_bunga'      => 150000,
                'total_pengembalian' => 1650000,
                'tenor_bulan'        => 6,
                'angsuran_per_bulan' => 250000,
                'sisa_pinjaman'      => 1250000,
                'status'             => 'approved',
                'keterangan'         => 'Pinjaman September 2025',
            ],
            [
                'name'               => 'DIKA ADITYA',
                'tanggal_pinjam'     => '2025-09-01',
                'nominal'            => 2000000,
                'persen_bunga'       => 10.00,
                'nominal_bunga'      => 200000,
                'total_pengembalian' => 2200000,
                'tenor_bulan'        => 9,
                'angsuran_per_bulan' => 250000,
                'sisa_pinjaman'      => 1800000,
                'status'             => 'approved',
                'keterangan'         => 'Pinjaman September 2025',
            ],
            [
                'name'               => 'RUMIN SAPUTRA',
                'tanggal_pinjam'     => '2025-09-01',
                'nominal'            => 1000000,
                'persen_bunga'       => 10.00,
                'nominal_bunga'      => 100000,
                'total_pengembalian' => 1100000,
                'tenor_bulan'        => 10,
                'angsuran_per_bulan' => 110000,
                'sisa_pinjaman'      => 350000,
                'status'             => 'approved',
                'keterangan'         => 'Pinjaman September 2025',
            ],
            [
                'name'               => 'TARKA WIJAYA',
                'tanggal_pinjam'     => '2025-09-01',
                'nominal'            => 2000000,
                'persen_bunga'       => 10.00,
                'nominal_bunga'      => 200000,
                'total_pengembalian' => 2200000,
                'tenor_bulan'        => 8,
                'angsuran_per_bulan' => 220000,
                'sisa_pinjaman'      => 1720000,
                'status'             => 'approved',
                'keterangan'         => 'Pinjaman September 2025',
            ],
            [
                'name'               => 'GUNTUR ARYA SUTA',
                'tanggal_pinjam'     => '2024-01-01',
                'nominal'            => 4000000,
                'persen_bunga'       => 10.00,
                'nominal_bunga'      => 400000,
                'total_pengembalian' => 4400000,
                'tenor_bulan'        => 10,
                'angsuran_per_bulan' => 440000,
                'sisa_pinjaman'      => 4000000,
                'status'             => 'approved',
                'keterangan'         => 'Pinjaman November',
            ],
        ];

        foreach ($pinjamans as $data) {
            $user = User::whereRaw('UPPER(TRIM(name)) = ?', [strtoupper(trim($data['name']))])->first();
            if (!$user) {
                $notFound[] = $data['name'];
                continue;
            }

            // Cek duplikasi berdasarkan user_id dan tanggal_pinjam
            $exists = Pinjaman::where('user_id', $user->id)
                ->where('nominal', $data['nominal'])
                ->whereYear('created_at', Carbon::parse($data['tanggal_pinjam'])->year)
                ->whereMonth('created_at', Carbon::parse($data['tanggal_pinjam'])->month)
                ->exists();

            if ($exists) {
                $skipped++;
                continue;
            }

            // Hitung sisa pinjaman secara dinamis dari total angsuran yang approved di Excel
            $totalSudahBayar = 0;
            if ($data['status'] === 'lunas') {
                $sisaPinjamanReal = 0;
            } else {
                foreach ($pembayaranExcel as $pb) {
                    if (strtoupper(trim($pb['name'])) === strtoupper(trim($data['name'])) && $pb['status'] === 'approved') {
                        $totalSudahBayar += $pb['nominal'];
                    }
                }
                // Jika totalSudahBayar kosong/0 (artinya tidak ada record di Rincian Angsuran Excel), 
                // gunakan sisa pinjaman default dari Rekap
                $sisaPinjamanReal = $totalSudahBayar > 0 
                    ? max(0, $data['total_pengembalian'] - $totalSudahBayar) 
                    : $data['sisa_pinjaman'];
            }

            $pinjaman = Pinjaman::create([
                'user_id'            => $user->id,
                'tipe'               => 'uang',
                'nominal'            => $data['nominal'],
                'persen_bunga'       => $data['persen_bunga'],
                'nominal_bunga'      => $data['nominal_bunga'],
                'total_pengembalian' => $data['total_pengembalian'],
                'tenor_bulan'        => $data['tenor_bulan'],
                'angsuran_per_bulan' => $data['angsuran_per_bulan'],
                'sisa_pinjaman'      => $sisaPinjamanReal,
                'keterangan'         => $data['keterangan'],
                'status'             => $data['status'],
                'approved_by'        => 1,
                'approved_at'        => Carbon::parse($data['tanggal_pinjam'])->addDay()->toDateTimeString(),
            ]);

            // Generate tagihan pembayaran cicilan
            $tanggalMulai = Carbon::parse($data['tanggal_pinjam'])->addMonth();
            for ($i = 1; $i <= $data['tenor_bulan']; $i++) {
                $jatuhTempo = (clone $tanggalMulai)->addMonths($i - 1)->format('Y-m-d');
                
                // Default fallback
                $nominalBayar = $data['angsuran_per_bulan'];
                $statusBayar = ($data['status'] === 'lunas') ? 'approved' : 'belum_bayar';
                $tglBayar = null;

                foreach ($pembayaranExcel as $pb) {
                    if (strtoupper(trim($pb['name'])) === strtoupper(trim($data['name'])) && $pb['angsuran_ke'] == $i) {
                        if (strtoupper(trim($data['name'])) === 'ARTA WIGUNA') {
                            if ($data['nominal'] > 2000000 && $pb['nominal'] < 500000) continue;
                            if ($data['nominal'] <= 2000000 && $pb['nominal'] > 500000) continue;
                        }
                        $nominalBayar = $pb['nominal'] > 0 ? $pb['nominal'] : $data['angsuran_per_bulan'];
                        $statusBayar = $pb['status'];
                        if (!empty($pb['tanggal_bayar'])) {
                            if (is_numeric($pb['tanggal_bayar'])) {
                                $tglBayar = Carbon::createFromTimestampUTC(($pb['tanggal_bayar'] - 25569) * 86400)->format('Y-m-d H:i:s');
                            } else {
                                $tglBayar = Carbon::parse($pb['tanggal_bayar'])->format('Y-m-d H:i:s');
                            }
                        }
                        break;
                    }
                }

                Pembayaran::create([
                    'user_id'     => $user->id,
                    'source_type' => 'pinjaman',
                    'source_id'   => $pinjaman->id,
                    'angsuran_ke' => $i,
                    'jatuh_tempo' => $jatuhTempo,
                    'nominal'     => $nominalBayar,
                    'status'      => $statusBayar,
                    'tanggal_bayar' => $tglBayar,
                    'approved_by' => $statusBayar === 'approved' ? 1 : null,
                    'approved_at' => $statusBayar === 'approved' ? ($tglBayar ?? now()) : null,
                ]);
            }

            $inserted++;
        }

        $this->command->info("PinjamanSeeder: Inserted {$inserted}, Skipped {$skipped}");
        if (!empty($notFound)) {
            $this->command->warn('Not found: ' . implode(', ', array_unique($notFound)));
        }
    }
}
