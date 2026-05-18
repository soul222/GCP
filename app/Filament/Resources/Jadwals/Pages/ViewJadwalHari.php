<?php

namespace App\Filament\Resources\Jadwals\Pages;

use App\Filament\Resources\Jadwals\JadwalResource;
use App\Models\Jadwal;
use App\Models\Kelas;
use App\Models\Mapel;
use App\Models\PresensiDetail;
use App\Models\PresensiSesi;
use App\Models\User;
use Filament\Actions\Action;
use Filament\Actions\BulkAction;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\CreateAction;
use Filament\Actions\EditAction;
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\Page;
use Filament\Tables;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Validation\Rules\Unique;

class ViewJadwalHari extends Page implements Tables\Contracts\HasTable
{
    use Tables\Concerns\InteractsWithTable;

    protected static string $resource = JadwalResource::class;

    protected string $view = 'resources.pages.page';

    public ?int $record = null;

    public ?Kelas $kelas = null;

    public ?string $hari = null;

    public function mount($record, string $hari): void
    {
        $this->record = (int) $record;
        $this->hari = strtolower($hari);

        abort_if(! in_array($this->hari, ['senin', 'selasa', 'rabu', 'kamis', 'jumat']), 404);

        $this->kelas = Kelas::findOrFail($this->record);
    }

    public function getTitle(): string
    {
        return 'Jadwal ' . $this->formatHari($this->hari) . ' - ' . ($this->kelas->nama ?? '');
    }

    protected function getHeaderActions(): array
    {
        return [
            Action::make('kembali')
                ->label('Kembali')
                ->icon('heroicon-o-arrow-left')
                ->color('gray')
                ->url(JadwalResource::getUrl('view', [
                    'record' => $this->kelas,
                ])),

            CreateAction::make()
                ->label('Tambah Jadwal')
                ->modalHeading('Tambah Jadwal ' . $this->formatHari($this->hari))
                ->schema($this->getFormSchema())
                ->createAnother(false)
                ->modalSubmitActionLabel('Simpan')
                ->modalCancelActionLabel('Batal')
                ->mutateFormDataUsing(function (array $data): array {
                    if (empty($data['use_custom_dates'])) {
                        $term = \App\Models\SemesterAkademik::find($data['semester_akademik_id']);
                        if ($term) {
                            $data['berlaku_dari'] = $term->starts_at;
                            $data['berlaku_sampai'] = $term->ends_at;
                        }
                    }
                    unset($data['use_custom_dates']);
                    return $data;
                })
                ->using(function (array $data): Jadwal {
                    $data['kelas_id'] = $this->kelas->id;
                    $data['hari'] = $this->hari;

                    return Jadwal::create($data);
                }),
        ];
    }

    protected function getFormSchema(): array
    {
        return [
            Select::make('semester_akademik_id')
                ->label('Semester Akademik')
                ->required()
                ->searchable()
                ->preload()
                ->options(
                    \App\Models\SemesterAkademik::query()
                        ->with('tahunAjaran')
                        ->get()
                        ->mapWithKeys(function ($term) {
                            return [$term->id => $term->tahunAjaran->name . ' - ' . $term->name];
                        })
                        ->toArray()
                )
                ->default(function () {
                    return \App\Models\SemesterAkademik::where('is_active', true)->value('id');
                })
                ->live()
                ->afterStateUpdated(function (\Filament\Schemas\Components\Utilities\Set $set, \Filament\Schemas\Components\Utilities\Get $get, $state) {
                    if ($state && ! $get('use_custom_dates')) {
                        $term = \App\Models\SemesterAkademik::find($state);
                        if ($term) {
                            $set('berlaku_dari', $term->starts_at?->format('Y-m-d'));
                            $set('berlaku_sampai', $term->ends_at?->format('Y-m-d'));
                        }
                    }
                }),

            Toggle::make('use_custom_dates')
                ->label('Gunakan Tanggal Khusus')
                ->live()
                ->formatStateUsing(function ($record) {
                    if (! $record) return false;
                    $term = \App\Models\SemesterAkademik::find($record->semester_akademik_id);
                    if (! $term) return true;

                    $termStarts = $term->starts_at?->format('Y-m-d');
                    $termEnds = $term->ends_at?->format('Y-m-d');
                    $jadwalStarts = $record->berlaku_dari?->format('Y-m-d');
                    $jadwalEnds = $record->berlaku_sampai?->format('Y-m-d');

                    return ($termStarts !== $jadwalStarts) || ($termEnds !== $jadwalEnds);
                })
                ->afterStateUpdated(function (\Filament\Schemas\Components\Utilities\Set $set, \Filament\Schemas\Components\Utilities\Get $get, $state) {
                    if (! $state) {
                        $termId = $get('semester_akademik_id');
                        if ($termId) {
                            $term = \App\Models\SemesterAkademik::find($termId);
                            if ($term) {
                                $set('berlaku_dari', $term->starts_at?->format('Y-m-d'));
                                $set('berlaku_sampai', $term->ends_at?->format('Y-m-d'));
                            }
                        }
                    }
                }),

            TextInput::make('jam_ke')
                ->label('Jam Ke')
                ->required()
                ->numeric()
                ->minValue(1)
                ->maxValue(20)
                ->rule(function ($get, $record) {
                    $kelasId = $this->kelas->id;
                    $hari = $this->hari;

                    return (new Unique('jadwals', 'jam_ke'))
                        ->where(function ($query) use ($kelasId, $hari) {
                            return $query
                                ->where('kelas_id', $kelasId)
                                ->where('hari', $hari);
                        })
                        ->ignore($record);
                })
                ->validationMessages([
                    'unique' => 'Jam ke untuk hari ini sudah dipakai di kelas ini.',
                ]),

            Select::make('mapel_id')
                ->label('Mata Pelajaran')
                ->required()
                ->searchable()
                ->preload()
                ->native(false)
                ->options(
                    Mapel::query()
                        ->where('aktif', true)
                        ->orderBy('nama')
                        ->pluck('nama', 'id')
                        ->toArray()
                ),

            Select::make('guru_id')
                ->label('Guru')
                ->required()
                ->searchable()
                ->preload()
                ->native(false)
                ->options(
                    User::query()
                        ->where('role', 'guru')
                        ->orderBy('name')
                        ->pluck('name', 'id')
                        ->toArray()
                ),

            DatePicker::make('berlaku_dari')
                ->label('Berlaku Dari')
                ->native(false)
                ->displayFormat('d/m/Y')
                ->visible(fn (\Filament\Schemas\Components\Utilities\Get $get) => $get('use_custom_dates'))
                ->rule(function (\Filament\Schemas\Components\Utilities\Get $get) {
                    return function (string $attribute, $value, \Closure $fail) use ($get) {
                        $termId = $get('semester_akademik_id');
                        if ($termId) {
                            $term = \App\Models\SemesterAkademik::find($termId);
                            if ($term && $term->starts_at && $value < $term->starts_at->format('Y-m-d')) {
                                $fail('Berlaku dari tidak boleh sebelum tanggal mulai semester (' . $term->starts_at->format('d/m/Y') . ').');
                            }
                        }
                    };
                }),

            DatePicker::make('berlaku_sampai')
                ->label('Berlaku Sampai')
                ->native(false)
                ->displayFormat('d/m/Y')
                ->visible(fn (\Filament\Schemas\Components\Utilities\Get $get) => $get('use_custom_dates'))
                ->rule('after_or_equal:berlaku_dari')
                ->rule(function (\Filament\Schemas\Components\Utilities\Get $get) {
                    return function (string $attribute, $value, \Closure $fail) use ($get) {
                        $termId = $get('semester_akademik_id');
                        if ($termId) {
                            $term = \App\Models\SemesterAkademik::find($termId);
                            if ($term && $term->ends_at && $value > $term->ends_at->format('Y-m-d')) {
                                $fail('Berlaku sampai tidak boleh setelah tanggal selesai semester (' . $term->ends_at->format('d/m/Y') . ').');
                            }
                        }
                    };
                })
                ->validationMessages([
                    'after_or_equal' => 'Berlaku sampai harus sama atau setelah berlaku dari.',
                ]),

            Toggle::make('aktif')
                ->label('Aktif')
                ->default(true),
        ];
    }

    public function table(Table $table): Table
    {
        return $table
            ->query($this->getTableQuery())
            ->recordAction(null)
            ->recordUrl(null)
            ->columns([
                TextColumn::make('no')
                    ->label('No')
                    ->rowIndex(),

                TextColumn::make('jam_ke')
                    ->label('Jam Ke')
                    ->sortable(),

                TextColumn::make('mapel.nama')
                    ->label('Mata Pelajaran')
                    ->searchable()
                    ->sortable(),

                TextColumn::make('guru.name')
                    ->label('Guru')
                    ->searchable()
                    ->sortable(),

                TextColumn::make('berlaku_dari')
                    ->label('Berlaku Dari')
                    ->date('d/m/Y')
                    ->sortable()
                    ->placeholder('-'),

                TextColumn::make('berlaku_sampai')
                    ->label('Berlaku Sampai')
                    ->date('d/m/Y')
                    ->sortable()
                    ->placeholder('-'),

                IconColumn::make('aktif')
                    ->label('Aktif')
                    ->boolean()
                    ->sortable(),
            ])
            ->filters([
                \Filament\Tables\Filters\SelectFilter::make('semester_akademik_id')
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
                    ->native(false)
            ])
            ->recordActions([
                EditAction::make()
                    ->label('Edit')
                    ->schema($this->getFormSchema())
                    ->modalSubmitActionLabel('Simpan')
                    ->modalCancelActionLabel('Batal')
                    ->mutateRecordDataUsing(function (array $data): array {
                        $data['use_custom_dates'] = false;
                        $term = \App\Models\SemesterAkademik::find($data['semester_akademik_id']);
                        if ($term) {
                            $termStarts = $term->starts_at?->format('Y-m-d');
                            $termEnds = $term->ends_at?->format('Y-m-d');
                            $jadwalStarts = isset($data['berlaku_dari']) ? \Carbon\Carbon::parse($data['berlaku_dari'])->format('Y-m-d') : null;
                            $jadwalEnds = isset($data['berlaku_sampai']) ? \Carbon\Carbon::parse($data['berlaku_sampai'])->format('Y-m-d') : null;
                            if ($termStarts !== $jadwalStarts || $termEnds !== $jadwalEnds) {
                                $data['use_custom_dates'] = true;
                            }
                        }
                        return $data;
                    })
                    ->mutateFormDataUsing(function (array $data): array {
                        if (empty($data['use_custom_dates'])) {
                            $term = \App\Models\SemesterAkademik::find($data['semester_akademik_id']);
                            if ($term) {
                                $data['berlaku_dari'] = $term->starts_at;
                                $data['berlaku_sampai'] = $term->ends_at;
                            }
                        }
                        unset($data['use_custom_dates']);
                        return $data;
                    })
                    ->using(function (Jadwal $record, array $data): Jadwal {
                        $oldValues = [
                            'kelas_id' => $record->kelas_id,
                            'mapel_id' => $record->mapel_id,
                            'guru_id' => $record->guru_id,
                            'hari' => $record->hari,
                            'jam_ke' => $record->jam_ke,
                            'semester_akademik_id' => $record->semester_akademik_id,
                        ];

                        $data['kelas_id'] = $this->kelas->id;
                        $data['hari'] = $this->hari;

                        $willResetPresensi =
                            (int) $oldValues['kelas_id'] !== (int) $data['kelas_id'] ||
                            (int) $oldValues['mapel_id'] !== (int) $data['mapel_id'] ||
                            (int) $oldValues['guru_id'] !== (int) $data['guru_id'] ||
                            (string) $oldValues['hari'] !== (string) $data['hari'] ||
                            (int) $oldValues['jam_ke'] !== (int) $data['jam_ke'] ||
                            (int) $oldValues['semester_akademik_id'] !== (int) $data['semester_akademik_id'];

                        if ($willResetPresensi) {
                            $sessionIds = PresensiSesi::query()
                                ->where('jadwal_id', $record->id)
                                ->pluck('id');

                            if ($sessionIds->isNotEmpty()) {
                                PresensiDetail::query()
                                    ->whereIn('presensi_sesi_id', $sessionIds)
                                    ->delete();
                            }

                            PresensiSesi::query()
                                ->where('jadwal_id', $record->id)
                                ->delete();
                        }

                        $record->update($data);

                        return $record;
                    }),

                Action::make('hapus')
                    ->label('Hapus')
                    ->icon('heroicon-o-trash')
                    ->color('danger')
                    ->requiresConfirmation()
                    ->modalHeading('Hapus jadwal?')
                    ->modalDescription('Jadwal pelajaran ini akan dihapus permanen.')
                    ->action(function (Jadwal $record): void {
                        $sessionIds = PresensiSesi::query()
                            ->where('jadwal_id', $record->id)
                            ->pluck('id');

                        if ($sessionIds->isNotEmpty()) {
                            PresensiDetail::query()
                                ->whereIn('presensi_sesi_id', $sessionIds)
                                ->delete();
                        }

                        PresensiSesi::query()
                            ->where('jadwal_id', $record->id)
                            ->delete();

                        $record->delete();

                        Notification::make()
                            ->title('Jadwal berhasil dihapus')
                            ->success()
                            ->send();
                    }),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    BulkAction::make('hapusTerpilih')
                        ->label('Hapus terpilih')
                        ->icon('heroicon-o-trash')
                        ->color('danger')
                        ->requiresConfirmation()
                        ->modalHeading('Hapus semua yang dipilih?')
                        ->modalDescription('Jadwal yang dipilih akan dihapus permanen.')
                        ->action(function (Collection $records): void {
                            foreach ($records as $record) {
                                $sessionIds = PresensiSesi::query()
                                    ->where('jadwal_id', $record->id)
                                    ->pluck('id');

                                if ($sessionIds->isNotEmpty()) {
                                    PresensiDetail::query()
                                        ->whereIn('presensi_sesi_id', $sessionIds)
                                        ->delete();
                                }

                                PresensiSesi::query()
                                    ->where('jadwal_id', $record->id)
                                    ->delete();

                                $record->delete();
                            }

                            Notification::make()
                                ->title('Data terpilih berhasil dihapus')
                                ->success()
                                ->send();
                        }),
                ]),
            ]);
    }

    protected function getTableQuery(): Builder
    {
        return Jadwal::query()
            ->with(['mapel', 'guru'])
            ->where('kelas_id', $this->kelas->id)
            ->where('hari', $this->hari)
            ->orderBy('jam_ke');
    }

    protected function formatHari(?string $hari): string
    {
        return match ($hari) {
            'senin' => 'Senin',
            'selasa' => 'Selasa',
            'rabu' => 'Rabu',
            'kamis' => 'Kamis',
            'jumat' => 'Jumat',
            default => ucfirst((string) $hari),
        };
    }
}