<?php

namespace App\Filament\Resources\Kelas\Tables;

use App\Filament\Resources\Kelas\KelasResource;
use App\Models\Jurusan;
use Filament\Actions\Action;
use Filament\Actions\BulkAction;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\EditAction;
use Filament\Notifications\Notification;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Filters\TernaryFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Collection;

class KelasTable
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

                TextColumn::make('nextKelas.nama')
                    ->label('Naik Ke')
                    ->placeholder('-')
                    ->sortable(),

                IconColumn::make('aktif')
                    ->label('Status')
                    ->boolean()
                    ->sortable(),
            ])
            ->filters([
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
                    ->options(fn () => Jurusan::query()
                        ->where('aktif', true)
                        ->orderBy('singkatan')
                        ->pluck('singkatan', 'singkatan')
                        ->toArray())
                    ->native(false),

                TernaryFilter::make('aktif')
                    ->label('Status')
                    ->placeholder('Semua')
                    ->trueLabel('Aktif')
                    ->falseLabel('Nonaktif'),
            ])
            ->recordActions([
                Action::make('detailSiswa')
                    ->label('Detail Siswa')
                    ->icon('heroicon-o-users')
                    ->url(fn ($record) => KelasResource::getUrl('view', ['record' => $record])),

                EditAction::make()->label('Edit'),

                Action::make('hapusPermanen')
                    ->label('Hapus')
                    ->icon('heroicon-o-trash')
                    ->color('danger')
                    ->requiresConfirmation()
                    ->modalHeading('Hapus Rombel?')
                    ->modalDescription('Data rombel akan dihapus permanen (tidak bisa di-restore).')
                    ->action(function ($record) {
                        $record->forceDelete();

                        Notification::make()
                            ->title('Berhasil dihapus')
                            ->success()
                            ->send();
                    }),
            ])
            ->toolbarActions([
                Action::make('generateMapping')
                    ->label('Isi Tujuan Otomatis')
                    ->icon('heroicon-o-arrow-path')
                    ->color('info')
                    ->requiresConfirmation()
                    ->modalHeading('Generate Mapping Kenaikan Kelas?')
                    ->modalDescription('Sistem akan mencari tujuan otomatis (misal: X RPL 1 -> XI RPL 1). Kelas XII akan dikosongkan untuk persiapan kelulusan. Aksi ini tidak akan memindahkan siswa. Lanjutkan?')
                    ->action(function () {
                        $kelasList = \App\Models\Kelas::where('aktif', true)->get();
                        $mappedCount = 0;
                        $notFoundCount = 0;
                        $lulusCount = 0;

                        foreach ($kelasList as $kelas) {
                            if ($kelas->tingkat_angka === 12 || $kelas->tingkat === 'XII') {
                                $kelas->next_kelas_id = null;
                                $kelas->save();
                                $lulusCount++;
                            } elseif ($kelas->tingkat_angka === 10 || $kelas->tingkat === 'X') {
                                $target = \App\Models\Kelas::where('aktif', true)
                                    ->where(function ($q) {
                                        $q->where('tingkat_angka', 11)->orWhere('tingkat', 'XI');
                                    })
                                    ->where('jurusan', $kelas->jurusan)
                                    ->where('nomor', $kelas->nomor)
                                    ->first();

                                if ($target) {
                                    $kelas->next_kelas_id = $target->id;
                                    $kelas->save();
                                    $mappedCount++;
                                } else {
                                    $notFoundCount++;
                                }
                            } elseif ($kelas->tingkat_angka === 11 || $kelas->tingkat === 'XI') {
                                $target = \App\Models\Kelas::where('aktif', true)
                                    ->where(function ($q) {
                                        $q->where('tingkat_angka', 12)->orWhere('tingkat', 'XII');
                                    })
                                    ->where('jurusan', $kelas->jurusan)
                                    ->where('nomor', $kelas->nomor)
                                    ->first();

                                if ($target) {
                                    $kelas->next_kelas_id = $target->id;
                                    $kelas->save();
                                    $mappedCount++;
                                } else {
                                    $notFoundCount++;
                                }
                            }
                        }

                        Notification::make()
                            ->title('Mapping Selesai')
                            ->body("Berhasil: {$mappedCount} kelas.<br>Tidak ditemukan: {$notFoundCount} kelas.<br>Lulus (XII): {$lulusCount} kelas.")
                            ->success()
                            ->send();
                    }),
                BulkActionGroup::make([
                    BulkAction::make('hapusTerpilihPermanen')
                        ->label('Hapus terpilih')
                        ->icon('heroicon-o-trash')
                        ->color('danger')
                        ->requiresConfirmation()
                        ->modalHeading('Hapus semua yang dipilih?')
                        ->modalDescription('Are you sure you would like to do this?')
                        ->action(function (Collection $records) {
                            foreach ($records as $record) {
                                $record->forceDelete();
                            }

                            Notification::make()
                                ->title('Data terpilih berhasil dihapus')
                                ->success()
                                ->send();
                        }),
                ]),
            ]);
    }
}