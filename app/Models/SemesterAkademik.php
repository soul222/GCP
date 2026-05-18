<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class SemesterAkademik extends Model
{
    use HasFactory;

    protected $table = 'semester_akademiks';

    protected $fillable = [
        'tahun_ajaran_id',
        'name',
        'starts_at',
        'ends_at',
        'is_active',
    ];

    protected $casts = [
        'starts_at' => 'date',
        'ends_at' => 'date',
        'is_active' => 'boolean',
    ];

    public function tahunAjaran(): BelongsTo
    {
        return $this->belongsTo(TahunAjaran::class, 'tahun_ajaran_id');
    }

    public function jadwals(): HasMany
    {
        return $this->hasMany(Jadwal::class, 'semester_akademik_id');
    }

    // Scopes
    public function scopeActive(Builder $query): Builder
    {
        return $query->where('is_active', true);
    }

    protected static function booted(): void
    {
        static::saving(function (SemesterAkademik $term) {
            if ($term->is_active) {
                // Deactivate all other semesters globally
                SemesterAkademik::where('id', '!=', $term->id)->update(['is_active' => false]);
                
                // Ensure the parent academic year is activated
                $year = $term->tahunAjaran;
                if ($year && ! $year->is_active) {
                    $year->is_active = true;
                    $year->save(); // This triggers TahunAjaran's saving event, deactivating other years
                }
            }
        });
    }
}
