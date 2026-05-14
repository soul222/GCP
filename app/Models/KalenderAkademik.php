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

    /**
     * Check if a date is blocked for attendance.
     * 
     * @param string|\DateTimeInterface $date
     * @return KalenderAkademik|null
     */
    public static function getBlockingEvent($date): ?self
    {
        $date = \Illuminate\Support\Carbon::parse($date)->toDateString();

        return self::query()
            ->where('starts_at', '<=', $date)
            ->where(function ($query) use ($date) {
                $query->whereNull('ends_at')
                    ->orWhere('ends_at', '>=', $date);
            })
            ->first();
    }

    /**
     * Check if a date is blocked for attendance by Kalender Akademik.
     * 
     * @param string|\DateTimeInterface $date
     * @return bool
     */
    public static function isTanggalDiblokir($date): bool
    {
        return self::getBlockingEvent($date) !== null;
    }
}
