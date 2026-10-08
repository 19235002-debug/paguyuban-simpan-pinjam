<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\User;

class Simpanan extends Model
{
    protected $table = 'simpanan';

    protected $fillable = [
        'user_id',
        'jenis',
        'bulan',
        'tahun',
        'nominal_simpanan',
        'nominal_admin',
        'total_bayar',
        'tanggal_bayar',
        'bukti_transfer',
        'status',
        'approved_by',
        'approved_at',
    ];

    protected $casts = [
        'tanggal_bayar' => 'date',
        'approved_at' => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function approver()
    {
        return $this->belongsTo(User::class, 'approved_by');
    }
}
