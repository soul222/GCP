<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Kelas extends Model
{
    use SoftDeletes;

    protected $table = 'kelas';

    protected $fillable = [
        'tingkat',
        'tingkat_angka',
        'jurusan',
        'nomor',
        'nama',
        'aktif',
        'next_kelas_id',
    ];

    protected $casts = [
        'aktif' => 'boolean',
        'nomor' => 'integer',
        'tingkat_angka' => 'integer',
    ];

    protected static function booted(): void
    {
        static::saving(function (Kelas $kelas) {
            $map = [
                'X' => 10,
                'XI' => 11,
                'XII' => 12,
            ];
            if (array_key_exists($kelas->tingkat, $map)) {
                $kelas->tingkat_angka = $map[$kelas->tingkat];
            }
        });
    }

    public function siswas(): HasMany
    {
        return $this->hasMany(\App\Models\User::class, 'kelas_id')
            ->where('role', 'siswa')
            ->where('is_active', true);
    }

    public function jadwals(): HasMany
    {
        return $this->hasMany(\App\Models\Jadwal::class, 'kelas_id');
    }

    public function nextKelas(): \Illuminate\Database\Eloquent\Relations\BelongsTo
    {
        return $this->belongsTo(Kelas::class, 'next_kelas_id');
    }

    public function previousKelas(): HasMany
    {
        return $this->hasMany(Kelas::class, 'next_kelas_id');
    }
}