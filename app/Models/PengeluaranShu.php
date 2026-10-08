<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\User;

class PengeluaranShu extends Model
{
    protected $table = 'pengeluaran_shus';

    protected $fillable = [
        'nominal',
        'tanggal',
        'keterangan',
        'user_id'
    ];

    protected $casts = [
        'tanggal' => 'date'
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
