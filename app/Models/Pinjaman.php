<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\User;
use App\Models\Pembayaran;

class Pinjaman extends Model
{
    protected $table = 'pinjaman';

    protected $fillable = [
        'user_id',
        'sumber_id',
        'tipe',
        'nominal',
        'persen_bunga',
        'nominal_bunga',
        'total_pengembalian',
        'tenor_bulan',
        'angsuran_per_bulan',
        'sisa_pinjaman',
        'keterangan',
        'status',
        'approved_by',
        'approved_at',
        'ttd_anggota',
        'ttd_admin',
    ];

    protected $casts = [
        'approved_at' => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // 🔥 FIXED: filter source_type agar tidak collision ID
    public function pembayaran()
    {
        return $this->hasMany(Pembayaran::class, 'source_id')->where('source_type', 'pinjaman');
    }
}
