<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class KalenderAkademik extends Model
{
    protected $table = 'kalender_akademiks';

    protected $fillable = [
        'name',
        'starts_at',
        'ends_at',
        'type',
        'is_holiday',
        'is_active',
        'notes',
    ];

    protected $casts = [
        'starts_at' => 'date',
        'ends_at' => 'date',
        'is_holiday' => 'boolean',
        'is_active' => 'boolean',
    ];
}
