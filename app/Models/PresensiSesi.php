<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PresensiSesi extends Model
{
    protected $table = 'presensi_sesis';

    protected $fillable = [
        'jadwal_id',
        'tanggal',
        'status',
        'dibuka_pada',
        'dibuka_oleh',
        'ditutup_pada',
        'ditutup_oleh',
        'catatan',
    ];

    protected $casts = [
        'tanggal' => 'date',
        'dibuka_pada' => 'datetime',
        'ditutup_pada' => 'datetime',
    ];

    public function jadwal()
    {
        return $this->belongsTo(Jadwal::class);
    }

    public function dibukaOleh()
    {
        return $this->belongsTo(User::class, 'dibuka_oleh');
    }

    public function ditutupOleh()
    {
        return $this->belongsTo(User::class, 'ditutup_oleh');
    }

    public function details()
    {
        return $this->hasMany(PresensiDetail::class, 'presensi_sesi_id');
    }

    public function scopeNotBlockedByKalender($query)
    {
        return $query->whereNotExists(function ($subquery) {
            $subquery->select(\Illuminate\Support\Facades\DB::raw(1))
                ->from('kalender_akademiks')
                ->whereRaw('kalender_akademiks.starts_at <= presensi_sesis.tanggal')
                ->where(function ($q) {
                    $q->whereNull('kalender_akademiks.ends_at')
                      ->orWhereRaw('kalender_akademiks.ends_at >= presensi_sesis.tanggal');
                });
        });
    }
}