<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class TahunAjaran extends Model
{
    use HasFactory;

    protected $table = 'tahun_ajarans';

    protected $fillable = [
        'name',
        'starts_at',
        'ends_at',
        'is_active',
        'promotion_processed_at',
    ];

    protected $casts = [
        'starts_at' => 'date',
        'ends_at' => 'date',
        'is_active' => 'boolean',
        'promotion_processed_at' => 'datetime',
    ];

    public function semesterAkademiks(): HasMany
    {
        return $this->hasMany(SemesterAkademik::class, 'tahun_ajaran_id');
    }

    public function riwayatKelasSiswas(): HasMany
    {
        return $this->hasMany(RiwayatKelasSiswa::class, 'tahun_ajaran_id');
    }

    // Scopes
    public function scopeActive(Builder $query): Builder
    {
        return $query->where('is_active', true);
    }

    protected static function booted(): void
    {
        static::saving(function (TahunAjaran $year) {
            if ($year->is_active) {
                TahunAjaran::where('id', '!=', $year->id)->update(['is_active' => false]);
            }
        });
    }
}
