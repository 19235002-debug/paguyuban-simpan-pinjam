<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\User;
use App\Models\Pembayaran;

class KreditBarang extends Model
{
    protected $table = 'kredit_barang';

    protected $fillable = [
        'user_id',
        'nama_barang',
        'harga_barang',
        'foto_barang',
        'keterangan',
        'persen_bunga',
        'nominal_bunga',
        'total_tagihan',
        'tenor_bulan',
        'angsuran_per_bulan',
        'pinjaman_id',
        'status',
        'approved_by',
        'approved_at',
        'ttd_anggota',
        'ttd_admin',
    ];

    protected $casts = [
        'approved_at' => 'datetime',
    ];

    protected $appends = [
        'sisa_kredit',
    ];

    public function getSisaKreditAttribute()
    {
        $sudahBayar = $this->pembayaran()->where('status', 'approved')->sum('nominal');
        return max(0, (int) ($this->total_tagihan - $sudahBayar));
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function pembayaran()
    {
        return $this->hasMany(Pembayaran::class, 'source_id')->where('source_type', 'kredit_barang');
    }
}
