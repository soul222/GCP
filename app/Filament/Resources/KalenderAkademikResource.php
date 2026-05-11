<?php

namespace App\Filament\Resources;

use App\Filament\Resources\KalenderAkademikResource\Pages;
use App\Models\KalenderAkademik;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class KalenderAkademikResource extends Resource
{
    protected static ?string $model = KalenderAkademik::class;

    public static function getNavigationIcon(): ?string
    {
        return 'heroicon-o-calendar';
    }

    public static function getNavigationGroup(): ?string
    {
        return 'Akademik';
    }

    public static function getNavigationLabel(): string
    {
        return 'Kalender Akademik';
    }

    public static function getModelLabel(): string
    {
        return 'Kalender Akademik';
    }

    public static function getPluralModelLabel(): string
    {
        return 'Kalender Akademik';
    }

    public static function getNavigationSort(): ?int
    {
        return 64;
    }

    public static function form(\Filament\Schemas\Schema $schema): \Filament\Schemas\Schema
    {
        return $schema
            ->components([
                Forms\Components\TextInput::make('name')
                    ->label('Nama Kegiatan / Libur')
                    ->required()
                    ->maxLength(255),
                Forms\Components\DatePicker::make('starts_at')
                    ->label('Tanggal Mulai')
                    ->required()
                    ->native(false)
                    ->displayFormat('d/m/Y'),
                Forms\Components\DatePicker::make('ends_at')
                    ->label('Tanggal Selesai')
                    ->native(false)
                    ->displayFormat('d/m/Y')
                    ->afterOrEqual('starts_at'),
                Forms\Components\Select::make('type')
                    ->label('Jenis')
                    ->options([
                        'libur_nasional' => 'Libur Nasional',
                        'libur_sekolah' => 'Libur Sekolah',
                        'kegiatan_sekolah' => 'Kegiatan Sekolah',
                        'lainnya' => 'Lainnya',
                    ])
                    ->required()
                    ->default('lainnya'),
                Forms\Components\Toggle::make('is_holiday')
                    ->label('Libur (Blokir Presensi)')
                    ->default(false),
                Forms\Components\Toggle::make('is_active')
                    ->label('Aktif')
                    ->default(true),
                Forms\Components\Textarea::make('notes')
                    ->label('Catatan')
                    ->columnSpanFull(),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')
                    ->label('Nama Kegiatan')
                    ->searchable(),
                Tables\Columns\TextColumn::make('starts_at')
                    ->label('Tanggal Mulai')
                    ->date('d/m/Y')
                    ->sortable(),
                Tables\Columns\TextColumn::make('ends_at')
                    ->label('Tanggal Selesai')
                    ->date('d/m/Y')
                    ->sortable(),
                Tables\Columns\TextColumn::make('type')
                    ->label('Jenis')
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'libur_nasional' => 'Libur Nasional',
                        'libur_sekolah' => 'Libur Sekolah',
                        'kegiatan_sekolah' => 'Kegiatan Sekolah',
                        'lainnya' => 'Lainnya',
                        default => $state,
                    })
                    ->searchable(),
                Tables\Columns\IconColumn::make('is_holiday')
                    ->label('Libur')
                    ->boolean(),
                Tables\Columns\IconColumn::make('is_active')
                    ->label('Aktif')
                    ->boolean(),
            ])
            ->filters([
                Tables\Filters\TernaryFilter::make('is_active')
                    ->label('Status Aktif'),
                Tables\Filters\TernaryFilter::make('is_holiday')
                    ->label('Status Libur'),
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
            'index' => Pages\ManageKalenderAkademiks::route('/'),
        ];
    }
}
