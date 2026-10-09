<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class PengurusSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        User::firstOrCreate(
            ['email' => 'admin@pbb.com'],
            [
                'nik' => '000001',
                'name' => 'Administrator',
                'no_hp' => '08123456789',
                'role' => 'pengurus',
                'status' => 'aktif',
                'tanggal_gabung' => now(),
                'password' => Hash::make('123')
            ]
        );

        User::firstOrCreate(
            ['email' => 'tes@gmail.com'],
            [
                'nik' => '21000464',
                'name' => 'Tes Akun',
                'no_hp' => '085783807097',
                'role' => 'anggota',
                'status' => 'aktif',
                'tanggal_gabung' => now(),
                'password' => Hash::make('123')
            ]
        );
    }
}
