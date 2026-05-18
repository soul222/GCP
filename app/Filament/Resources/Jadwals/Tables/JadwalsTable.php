<?php

namespace App\Filament\Resources\Jadwals\Tables;

use App\Filament\Resources\Jadwals\JadwalResource;
use Filament\Actions\Action;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Filters\TernaryFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class JadwalsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->recordAction(null)
            ->recordUrl(null)
            ->columns([
                TextColumn::make('row_index')
                    ->label('No')
                    ->state(fn ($rowLoop) => $rowLoop->iteration),

                TextColumn::make('tingkat')
                    ->label('Tingkat')
                    ->searchable()
                    ->sortable(),

                TextColumn::make('jurusan')
                    ->label('Jurusan')
                    ->searchable()
                    ->sortable(),

                TextColumn::make('nomor')
                    ->label('Nomor')
                    ->numeric()
                    ->sortable(),

                TextColumn::make('nama')
                    ->label('Nama')
                    ->searchable()
                    ->sortable(),

                IconColumn::make('aktif')
                    ->label('Status')
                    ->boolean()
                    ->sortable(),
            ])
            ->filters([
                SelectFilter::make('semester_akademik_id')
                    ->label('Semester Akademik')
                    ->options(
                        \App\Models\SemesterAkademik::query()
                            ->with('tahunAjaran')
                            ->get()
                            ->mapWithKeys(function ($term) {
                                return [$term->id => $term->tahunAjaran->name . ' - ' . $term->name];
                            })
                            ->toArray()
                    )
                    ->query(function ($query, array $data) {
                        if (! empty($data['value'])) {
                            $query->whereHas('jadwals', function ($q) use ($data) {
                                $q->where('semester_akademik_id', $data['value']);
                            });
                        }
                    })
                    ->native(false),

                SelectFilter::make('tingkat')
                    ->label('Tingkat')
                    ->options([
                        'X' => 'X',
                        'XI' => 'XI',
                        'XII' => 'XII',
                    ])
                    ->native(false),

                SelectFilter::make('jurusan')
                    ->label('Jurusan')
                    ->options([
                        'PPLG' => 'PPLG',
                        'MPLB' => 'MPLB',
                    ])
                    ->native(false),

                TernaryFilter::make('aktif')
                    ->label('Status')
                    ->placeholder('Semua')
                    ->trueLabel('Aktif')
                    ->falseLabel('Nonaktif'),
            ])
            ->recordActions([
                Action::make('detailJadwal')
                    ->label('Detail Jadwal')
                    ->icon('heroicon-o-calendar-days')
                    ->url(fn ($record) => JadwalResource::getUrl('view', ['record' => $record])),
            ])
            ->toolbarActions([
                \Filament\Actions\Action::make('duplikasi_jadwal')
                    ->label('Salin Jadwal ke Semester Lain')
                    ->icon('heroicon-o-document-duplicate')
                    ->color('warning')
                    ->requiresConfirmation()
                    ->modalHeading('Salin Jadwal ke Semester Lain')
                    ->modalDescription('Pilih semester asal dan semester tujuan. Sistem akan menyalin jadwal, menyesuaikan tanggal berlaku, dan mengabaikan jadwal yang sudah ada di semester tujuan.')
                    ->form([
                        \Filament\Forms\Components\Select::make('source_term_id')
                            ->label('Semester Asal')
                            ->required()
                            ->searchable()
                            ->options(
                                \App\Models\SemesterAkademik::query()
                                    ->with('tahunAjaran')
                                    ->get()
                                    ->mapWithKeys(function ($term) {
                                        return [$term->id => $term->tahunAjaran->name . ' - ' . $term->name];
                                    })
                            ),
                        \Filament\Forms\Components\Select::make('target_term_id')
                            ->label('Semester Tujuan')
                            ->required()
                            ->searchable()
                            ->options(
                                \App\Models\SemesterAkademik::query()
                                    ->with('tahunAjaran')
                                    ->get()
                                    ->mapWithKeys(function ($term) {
                                        return [$term->id => $term->tahunAjaran->name . ' - ' . $term->name];
                                    })
                            )
                            ->different('source_term_id'),
                    ])
                    ->action(function (array $data) {
                        $sourceTerm = \App\Models\SemesterAkademik::find($data['source_term_id']);
                        $targetTerm = \App\Models\SemesterAkademik::find($data['target_term_id']);

                        if (! $sourceTerm || ! $targetTerm) {
                            \Filament\Notifications\Notification::make()
                                ->title('Semester tidak ditemukan.')
                                ->danger()
                                ->send();
                            return;
                        }

                        $jadwalsToCopy = \App\Models\Jadwal::where('semester_akademik_id', $sourceTerm->id)->get();

                        $copiedCount = 0;
                        $skippedCount = 0;

                        foreach ($jadwalsToCopy as $jadwal) {
                            $exists = \App\Models\Jadwal::where('semester_akademik_id', $targetTerm->id)
                                ->where('kelas_id', $jadwal->kelas_id)
                                ->where('hari', $jadwal->hari)
                                ->where('jam_ke', $jadwal->jam_ke)
                                ->where('mapel_id', $jadwal->mapel_id)
                                ->where('guru_id', $jadwal->guru_id)
                                ->exists();

                            if (! $exists) {
                                \App\Models\Jadwal::create([
                                    'kelas_id' => $jadwal->kelas_id,
                                    'mapel_id' => $jadwal->mapel_id,
                                    'guru_id' => $jadwal->guru_id,
                                    'hari' => $jadwal->hari,
                                    'jam_ke' => $jadwal->jam_ke,
                                    'aktif' => $jadwal->aktif,
                                    'semester_akademik_id' => $targetTerm->id,
                                    'berlaku_dari' => $targetTerm->starts_at,
                                    'berlaku_sampai' => $targetTerm->ends_at,
                                ]);
                                $copiedCount++;
                            } else {
                                $skippedCount++;
                            }
                        }

                        \Filament\Notifications\Notification::make()
                            ->title('Duplikasi Selesai')
                            ->body("Berhasil menduplikasi {$copiedCount} jadwal. Mengabaikan {$skippedCount} jadwal yang sudah ada.")
                            ->success()
                            ->send();
                    }),
            ]);
    }
}