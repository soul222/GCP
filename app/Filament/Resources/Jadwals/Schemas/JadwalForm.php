<?php

namespace App\Filament\Resources\Jadwals\Schemas;

use App\Models\Kelas;
use App\Models\Mapel;
use App\Models\SemesterAkademik;
use App\Models\User;
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Utilities\Get;
use Filament\Schemas\Components\Utilities\Set;
use Filament\Schemas\Schema;
use Illuminate\Validation\Rules\Unique;

class JadwalForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema->components([
            Select::make('semester_akademik_id')
                ->label('Semester Akademik')
                ->required()
                ->searchable()
                ->preload()
                ->options(
                    SemesterAkademik::query()
                        ->with('tahunAjaran')
                        ->get()
                        ->mapWithKeys(function ($term) {
                            return [$term->id => $term->tahunAjaran->name . ' - ' . $term->name];
                        })
                        ->toArray()
                )
                ->default(function () {
                    return SemesterAkademik::where('is_active', true)->value('id');
                })
                ->live()
                ->afterStateUpdated(function (Set $set, Get $get, $state) {
                    if ($state && ! $get('use_custom_dates')) {
                        $term = SemesterAkademik::find($state);
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
                    $term = SemesterAkademik::find($record->semester_akademik_id);
                    if (! $term) return true;

                    $termStarts = $term->starts_at?->format('Y-m-d');
                    $termEnds = $term->ends_at?->format('Y-m-d');
                    $jadwalStarts = $record->berlaku_dari?->format('Y-m-d');
                    $jadwalEnds = $record->berlaku_sampai?->format('Y-m-d');

                    return ($termStarts !== $jadwalStarts) || ($termEnds !== $jadwalEnds);
                })
                ->afterStateUpdated(function (Set $set, Get $get, $state) {
                    if (! $state) {
                        $termId = $get('semester_akademik_id');
                        if ($termId) {
                            $term = SemesterAkademik::find($termId);
                            if ($term) {
                                $set('berlaku_dari', $term->starts_at?->format('Y-m-d'));
                                $set('berlaku_sampai', $term->ends_at?->format('Y-m-d'));
                            }
                        }
                    }
                }),

            Select::make('kelas_id')
                ->label('Rombel')
                ->required()
                ->searchable()
                ->preload()
                ->options(
                    Kelas::query()
                        ->where('aktif', true)
                        ->orderByRaw("
                            CASE tingkat
                                WHEN 'X' THEN 1
                                WHEN 'XI' THEN 2
                                WHEN 'XII' THEN 3
                                ELSE 99
                            END
                        ")
                        ->orderBy('jurusan')
                        ->orderBy('nomor')
                        ->pluck('nama', 'id')
                        ->toArray()
                ),

            Select::make('hari')
                ->label('Hari')
                ->required()
                ->options([
                    'senin' => 'Senin',
                    'selasa' => 'Selasa',
                    'rabu' => 'Rabu',
                    'kamis' => 'Kamis',
                    'jumat' => 'Jumat',
                ])
                ->native(false),

            TextInput::make('jam_ke')
                ->label('Jam Ke')
                ->required()
                ->numeric()
                ->minValue(1)
                ->maxValue(20)
                ->rule(function ($record) {
                    return (new Unique('jadwals', 'jam_ke'))
                        ->where(fn ($query, $get) => $query
                            ->where('kelas_id', $get('kelas_id'))
                            ->where('hari', $get('hari'))
                        )
                        ->ignore($record);
                })
                ->validationMessages([
                    'unique' => 'Jam ke untuk rombel dan hari tersebut sudah dipakai.',
                ]),

            Select::make('mapel_id')
                ->label('Mata Pelajaran')
                ->required()
                ->searchable()
                ->preload()
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
                ->visible(fn (Get $get) => $get('use_custom_dates'))
                ->rule(function (Get $get) {
                    return function (string $attribute, $value, \Closure $fail) use ($get) {
                        $termId = $get('semester_akademik_id');
                        if ($termId) {
                            $term = SemesterAkademik::find($termId);
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
                ->visible(fn (Get $get) => $get('use_custom_dates'))
                ->rule('after_or_equal:berlaku_dari')
                ->rule(function (Get $get) {
                    return function (string $attribute, $value, \Closure $fail) use ($get) {
                        $termId = $get('semester_akademik_id');
                        if ($termId) {
                            $term = SemesterAkademik::find($termId);
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
        ]);
    }
}