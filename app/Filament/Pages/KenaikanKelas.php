<?php

namespace App\Filament\Pages;

use App\Models\RiwayatKelasSiswa;
use App\Models\TahunAjaran;
use App\Models\User;
use BackedEnum;
use Filament\Notifications\Notification;
use Filament\Pages\Page;
use Filament\Actions\Action;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Concerns\InteractsWithTable;
use Filament\Tables\Contracts\HasTable;
use Filament\Tables\Table;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class KenaikanKelas extends Page implements HasTable
{
    use InteractsWithTable;

    protected static string|BackedEnum|null $navigationIcon = 'heroicon-o-academic-cap';

    protected static ?string $navigationLabel = 'Kenaikan Kelas';

    protected static ?string $title = 'Kenaikan Kelas';

    protected static string|\UnitEnum|null $navigationGroup = 'Akademik';

    protected static ?int $navigationSort = 70;

    protected string $view = 'filament.pages.kenaikan-kelas';

    public function mount(): void
    {
        abort_unless(Auth::user()->role === 'admin', 403);
    }

    public function table(Table $table): Table
    {
        return $table
            ->query(TahunAjaran::query()->latest())
            ->columns([
                TextColumn::make('name')
                    ->label('Tahun Ajaran')
                    ->weight('bold')
                    ->searchable(),

                TextColumn::make('periode')
                    ->label('Periode')
                    ->state(fn ($record) => $record->starts_at->format('d M Y') . ' - ' . $record->ends_at->format('d M Y')),

                TextColumn::make('is_active')
                    ->label('Status Tahun Ajaran')
                    ->badge()
                    ->state(fn ($record) => $record->is_active ? 'Aktif' : 'Tidak Aktif')
                    ->color(fn ($record) => $record->is_active ? 'success' : 'gray'),

                TextColumn::make('status_kenaikan')
                    ->label('Status Kenaikan')
                    ->badge()
                    ->state(fn ($record) => $record->promotion_processed_at ? 'Sudah Diproses' : 'Belum Diproses')
                    ->color(fn ($record) => $record->promotion_processed_at ? 'success' : 'warning'),

                TextColumn::make('total_siswa')
                    ->label('Total Siswa Aktif')
                    ->alignCenter()
                    ->state(function ($record) {
                        if (!$record->is_active) return '-';
                        return User::query()
                            ->where('role', 'siswa')
                            ->where('is_active', true)
                            ->whereNotNull('kelas_id')
                            ->count();
                    }),

                TextColumn::make('total_naik')
                    ->label('Naik Kelas')
                    ->alignCenter()
                    ->state(function ($record) {
                        if (!$record->is_active) return '-';
                        return User::query()
                            ->where('role', 'siswa')
                            ->where('is_active', true)
                            ->whereHas('kelas', fn ($q) => $q->whereIn('tingkat', ['X', 'XI']))
                            ->count();
                    }),

                TextColumn::make('total_lulus')
                    ->label('Lulus')
                    ->alignCenter()
                    ->state(function ($record) {
                        if (!$record->is_active) return '-';
                        return User::query()
                            ->where('role', 'siswa')
                            ->where('is_active', true)
                            ->whereHas('kelas', fn ($q) => $q->where('tingkat', 'XII'))
                            ->count();
                    }),
            ])
            ->actions([
                Action::make('prosesKenaikan')
                    ->label('Proses Kenaikan')
                    ->icon('heroicon-m-academic-cap')
                    ->color('primary')
                    ->requiresConfirmation()
                    ->modalHeading('Konfirmasi Proses Kenaikan Kelas')
                    ->modalDescription('Proses ini akan memperbarui kelas siswa berdasarkan Tujuan Kenaikan yang sudah ditentukan. Siswa kelas XII akan ditandai sebagai Lulus dan dinonaktifkan. Pastikan seluruh data sudah benar sebelum melanjutkan.')
                    ->modalSubmitActionLabel('Ya, Proses Kenaikan')
                    ->modalCancelActionLabel('Batal')
                    ->action(fn (TahunAjaran $record) => $this->proses($record))
                    ->visible(fn (TahunAjaran $record) => $record->is_active && !$record->promotion_processed_at),
            ]);
    }

    public function proses(TahunAjaran $tahunAjaran): void
    {
        if (!$tahunAjaran->is_active || $tahunAjaran->promotion_processed_at) {
            return;
        }

        // 1. Validation Class Mapping
        $activeStudents = User::query()
            ->where('role', 'siswa')
            ->where('is_active', true)
            ->whereNotNull('kelas_id')
            ->with('kelas')
            ->get();

        foreach ($activeStudents as $student) {
            if (in_array($student->kelas->tingkat, ['X', 'XI']) && !$student->kelas->next_kelas_id) {
                Notification::make()
                    ->title('Gagal Memproses')
                    ->body('Masih ada kelas yang belum memiliki Tujuan Kenaikan. Lengkapi mapping kenaikan kelas terlebih dahulu.')
                    ->danger()
                    ->persistent()
                    ->send();
                return;
            }
        }

        DB::beginTransaction();
        try {
            $processedBy = Auth::id();
            $processedAt = now();

            foreach ($activeStudents as $student) {
                $oldKelasId = $student->kelas_id;
                $tingkat = $student->kelas->tingkat;

                if (in_array($tingkat, ['X', 'XI'])) {
                    // Naik Kelas
                    $newKelasId = $student->kelas->next_kelas_id;
                    $student->update(['kelas_id' => $newKelasId]);

                    RiwayatKelasSiswa::create([
                        'siswa_id' => $student->id,
                        'from_kelas_id' => $oldKelasId,
                        'to_kelas_id' => $newKelasId,
                        'tahun_ajaran_id' => $tahunAjaran->id,
                        'action_type' => 'naik_kelas',
                        'processed_by' => $processedBy,
                        'processed_at' => $processedAt,
                    ]);
                } elseif ($tingkat === 'XII') {
                    // Lulus
                    $student->update([
                        'kelas_id' => null,
                        'is_active' => false,
                        'keterangan_nonaktif' => 'Lulus',
                    ]);

                    RiwayatKelasSiswa::create([
                        'siswa_id' => $student->id,
                        'from_kelas_id' => $oldKelasId,
                        'to_kelas_id' => null,
                        'tahun_ajaran_id' => $tahunAjaran->id,
                        'action_type' => 'lulus',
                        'processed_by' => $processedBy,
                        'processed_at' => $processedAt,
                    ]);
                }
            }

            // Mark year as processed
            $tahunAjaran->update([
                'promotion_processed_at' => $processedAt
            ]);

            DB::commit();

            Notification::make()
                ->title('Berhasil')
                ->body('Proses kenaikan kelas telah selesai.')
                ->success()
                ->send();

        } catch (\Exception $e) {
            DB::rollBack();
            Notification::make()
                ->title('Terjadi Kesalahan')
                ->body($e->getMessage())
                ->danger()
                ->send();
        }
    }
}
