<?php

namespace App\Filament\Resources;

use App\Filament\Resources\SemesterAkademikResource\Pages;
use App\Models\SemesterAkademik;
use App\Models\TahunAjaran;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class SemesterAkademikResource extends Resource
{
    protected static ?string $model = SemesterAkademik::class;

    public static function getNavigationIcon(): ?string
    {
        return 'heroicon-o-book-open';
    }

    public static function getNavigationGroup(): ?string
    {
        return 'Akademik';
    }

    public static function getNavigationSort(): ?int
    {
        return 61;
    }

    public static function getNavigationLabel(): string
    {
        return 'Semester Akademik';
    }

    public static function getModelLabel(): string
    {
        return 'Semester Akademik';
    }

    public static function getPluralModelLabel(): string
    {
        return 'Semester Akademik';
    }

    public static function form(\Filament\Schemas\Schema $schema): \Filament\Schemas\Schema
    {
        return $schema
            ->components([
                Forms\Components\Select::make('tahun_ajaran_id')
                    ->label('Tahun Ajaran')
                    ->relationship('tahunAjaran', 'name')
                    ->required()
                    ->live(),
                Forms\Components\Select::make('name')
                    ->label('Semester')
                    ->options([
                        'Semester Ganjil' => 'Semester Ganjil',
                        'Semester Genap' => 'Semester Genap',
                    ])
                    ->required()
                    ->rule(function ($get, $record) {
                        return (new \Illuminate\Validation\Rules\Unique('semester_akademiks', 'name'))
                            ->where('tahun_ajaran_id', $get('tahun_ajaran_id'))
                            ->ignore($record);
                    })
                    ->validationMessages([
                        'unique' => 'Semester ini sudah ada di Tahun Ajaran tersebut.',
                    ]),
                Forms\Components\DatePicker::make('starts_at')
                    ->label('Tanggal Mulai')
                    ->required()
                    ->before('ends_at')
                    ->rule(function ($get) {
                        return function (string $attribute, $value, \Closure $fail) use ($get) {
                            $yearId = $get('tahun_ajaran_id');
                            if ($yearId) {
                                $year = TahunAjaran::find($yearId);
                                if ($year && $value < $year->starts_at->toDateString()) {
                                    $fail("Tanggal mulai semester tidak boleh sebelum tanggal mulai Tahun Ajaran ({$year->starts_at->format('d M Y')}).");
                                }
                            }
                        };
                    }),
                Forms\Components\DatePicker::make('ends_at')
                    ->label('Tanggal Selesai')
                    ->required()
                    ->after('starts_at')
                    ->rule(function ($get) {
                        return function (string $attribute, $value, \Closure $fail) use ($get) {
                            $yearId = $get('tahun_ajaran_id');
                            if ($yearId) {
                                $year = TahunAjaran::find($yearId);
                                if ($year && $value > $year->ends_at->toDateString()) {
                                    $fail("Tanggal selesai semester tidak boleh melebihi tanggal selesai Tahun Ajaran ({$year->ends_at->format('d M Y')}).");
                                }
                            }
                        };
                    }),
                Forms\Components\Toggle::make('is_active')
                    ->label('Aktif')
                    ->default(false)
                    ->helperText('Hanya satu semester yang bisa aktif di seluruh sistem. Tahun ajarannya juga akan ikut diaktifkan.'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('tahunAjaran.name')
                    ->label('Tahun Ajaran')
                    ->sortable()
                    ->searchable(),
                Tables\Columns\TextColumn::make('name')
                    ->label('Semester')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('starts_at')
                    ->label('Mulai')
                    ->date('d M Y')
                    ->sortable(),
                Tables\Columns\TextColumn::make('ends_at')
                    ->label('Selesai')
                    ->date('d M Y')
                    ->sortable(),
                Tables\Columns\IconColumn::make('is_active')
                    ->label('Status')
                    ->boolean()
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('tahun_ajaran_id')
                    ->label('Tahun Ajaran')
                    ->relationship('tahunAjaran', 'name'),
            ])
            ->actions([
                \Filament\Actions\EditAction::make()
                    ->modalSubmitActionLabel('Simpan')
                    ->modalCancelActionLabel('Batal'),
                \Filament\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                \Filament\Actions\BulkActionGroup::make([
                    \Filament\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ManageSemesterAkademiks::route('/'),
        ];
    }
}
