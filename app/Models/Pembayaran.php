<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\User;
use App\Models\Pinjaman;
use App\Models\KreditBarang;

class Pembayaran extends Model
{
    protected $table = 'pembayaran';

    protected $fillable = [
        'user_id',
        'source_type',
        'source_id',
        'angsuran_ke',
        'jatuh_tempo',
        'nominal',
        'tanggal_bayar',
        'bukti_transfer',
        'status',
        'approved_by',
        'approved_at',
    ];

    protected $casts = [
        'jatuh_tempo' => 'date',
        'tanggal_bayar' => 'date',
        'approved_at' => 'datetime',
    ];

    /*
    |--------------------------------------------------------------------------
    | RELATION
    |--------------------------------------------------------------------------
    */

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function pinjaman()
    {
        return $this->belongsTo(
            Pinjaman::class,
            'source_id'
        );
    }

    public function kreditBarang()
    {
        return $this->belongsTo(
            KreditBarang::class,
            'source_id'
        );
    }

    /*
    |--------------------------------------------------------------------------
    | HELPER
    |--------------------------------------------------------------------------
    */

    public function isPinjaman()
    {
        return $this->source_type === 'pinjaman';
    }

    public function isKredit()
    {
        return $this->source_type === 'kredit_barang';
    }

    /*
    |--------------------------------------------------------------------------
    | ACCESSOR
    |--------------------------------------------------------------------------
    */

    public function getPembiayaanAttribute()
    {
        if ($this->isPinjaman()) {
            return $this->pinjaman;
        }

        if ($this->isKredit()) {
            return $this->kreditBarang;
        }

        return null;
    }

    public function getJenisAttribute()
    {
        return $this->isPinjaman()
            ? 'Pinjaman Tunai'
            : 'Kredit Barang';
    }

    public function getStatusBadgeAttribute()
    {
        return match ($this->status) {
            'approved' => [
                'label' => 'Lunas',
                'class' => 'bg-green-100 text-green-700'
            ],

            'pending' => [
                'label' => 'Menunggu Verifikasi',
                'class' => 'bg-yellow-100 text-yellow-700'
            ],

            'rejected' => [
                'label' => 'Ditolak',
                'class' => 'bg-red-100 text-red-700'
            ],

            default => [
                'label' => 'Belum Bayar',
                'class' => 'bg-red-100 text-red-700'
            ],
        };
    }

    public function getCanPayAttribute()
    {
        return in_array(
            $this->status,
            ['belum_bayar', 'rejected']
        );
    }
}
