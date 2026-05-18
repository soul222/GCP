<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class RiwayatKelasSiswa extends Model
{
    use HasFactory;

    protected $table = 'riwayat_kelas_siswas';

    protected $fillable = [
        'siswa_id',
        'from_kelas_id',
        'to_kelas_id',
        'tahun_ajaran_id',
        'action_type',
        'notes',
        'processed_by',
        'processed_at',
    ];

    protected $casts = [
        'processed_at' => 'datetime',
    ];

    public function siswa(): BelongsTo
    {
        return $this->belongsTo(User::class, 'siswa_id');
    }

    public function fromKelas(): BelongsTo
    {
        return $this->belongsTo(Kelas::class, 'from_kelas_id');
    }

    public function toKelas(): BelongsTo
    {
        return $this->belongsTo(Kelas::class, 'to_kelas_id');
    }

    public function tahunAjaran(): BelongsTo
    {
        return $this->belongsTo(TahunAjaran::class, 'tahun_ajaran_id');
    }

    public function processedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'processed_by');
    }
}
