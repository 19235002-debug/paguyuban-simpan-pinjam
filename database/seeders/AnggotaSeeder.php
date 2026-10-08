<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class AnggotaSeeder extends Seeder
{
    public function run(): void
    {
        $data = [
            ['nik' => '001', 'name' => 'MUSAFAK', 'email' => 'musafak@pbb.com', 'status' => 'aktif'],
            ['nik' => '002', 'name' => 'TRIYO SUTOPO', 'email' => 'topo@pbb.com', 'status' => 'aktif'],
            ['nik' => '003', 'name' => 'SAEPUL MUHAEMIN', 'email' => 'saepul@pbb.com', 'status' => 'aktif'],
            ['nik' => '004', 'name' => 'SOLEHUDIN', 'email' => 'solehudin@pbb.com', 'status' => 'aktif'],
            ['nik' => '005', 'name' => 'HAMBALI', 'email' => 'hambali@pbb.com', 'status' => 'aktif'],
            ['nik' => '006', 'name' => 'SEPRUDIANTO', 'email' => 'seprudianto@pbb.com', 'status' => 'aktif'],
            ['nik' => '007', 'name' => 'AGUS PURWANTO', 'email' => 'agus@pbb.com', 'status' => 'aktif'],
            ['nik' => '008', 'name' => 'TARKA WIJAYA', 'email' => 'tarka@pbb.com', 'status' => 'aktif'],
            ['nik' => '009', 'name' => 'ARTA WIGUNA', 'email' => 'arta@pbb.com', 'status' => 'aktif'],
            ['nik' => '010', 'name' => 'RUMIN SAPUTRA', 'email' => 'rumin@pbb.com', 'status' => 'aktif'],
            ['nik' => '011', 'name' => 'MUHAMMAD SOLEH', 'email' => 'soleh@pbb.com', 'status' => 'aktif'],
            ['nik' => '012', 'name' => 'DIKA ADITYA', 'email' => 'dika@pbb.com', 'status' => 'aktif'],
            ['nik' => '013', 'name' => 'MUHAMMAD ROFIK', 'email' => 'rofik@pbb.com', 'status' => 'aktif'],
            ['nik' => '014', 'name' => 'ADE AHMAD SAMSUDIN', 'email' => 'ade@pbb.com', 'status' => 'aktif'],
            ['nik' => '015', 'name' => 'MADIH IRAMA', 'email' => 'madih@pbb.com', 'status' => 'aktif'],
            ['nik' => '016', 'name' => 'GUNTUR ARYA SUTA', 'email' => 'guntur@pbb.com', 'status' => 'aktif'],
            ['nik' => '018', 'name' => 'DAFA ANASSYAH MUTIARA TAMA', 'email' => 'dafa@pbb.com', 'status' => 'aktif'],
            ['nik' => '019', 'name' => 'HENDRA', 'email' => 'hendra@pbb.com', 'status' => 'aktif'],
            ['nik' => '020', 'name' => 'GIYATNO', 'email' => 'giyatno@pbb.com', 'status' => 'aktif'],
            ['nik' => '022', 'name' => 'SOLIH BIN ABBAS', 'email' => 'solih@pbb.com', 'status' => 'aktif'],
            ['nik' => '023', 'name' => 'ADITYA', 'email' => 'adit@pbb.com', 'status' => 'aktif'],
        ];

        foreach ($data as $row) {
            User::firstOrCreate(
                ['nik' => $row['nik']],
                [
                    'name'           => $row['name'],
                    'email'          => $row['email'],
                    'no_hp'          => '0812' . str_pad($row['nik'], 8, '0', STR_PAD_LEFT),
                    'role'           => 'anggota',
                    'status'         => $row['status'],
                    'tanggal_gabung' => '2023-01-01',
                    'password'       => Hash::make('123'),
                ]
            );
        }
    }
}
