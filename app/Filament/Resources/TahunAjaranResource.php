<?php

namespace App\Filament\Resources;

use App\Filament\Resources\TahunAjaranResource\Pages;
use App\Models\TahunAjaran;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class TahunAjaranResource extends Resource
{
    protected static ?string $model = TahunAjaran::class;

    public static function getNavigationIcon(): ?string
    {
        return 'heroicon-o-calendar';
    }

    public static function getNavigationGroup(): ?string
    {
        return 'Akademik';
    }

    public static function getNavigationSort(): ?int
    {
        return 60;
    }

    public static function getNavigationLabel(): string
    {
        return 'Tahun Ajaran';
    }

    public static function getModelLabel(): string
    {
        return 'Tahun Ajaran';
    }

    public static function getPluralModelLabel(): string
    {
        return 'Tahun Ajaran';
    }

    public static function form(\Filament\Schemas\Schema $schema): \Filament\Schemas\Schema
    {
        return $schema
            ->components([
                Forms\Components\TextInput::make('name')
                    ->label('Nama Tahun Ajaran')
                    ->placeholder('Contoh: 2025/2026')
                    ->required()
                    ->maxLength(255),
                Forms\Components\DatePicker::make('starts_at')
                    ->label('Tanggal Mulai')
                    ->required()
                    ->before('ends_at'),
                Forms\Components\DatePicker::make('ends_at')
                    ->label('Tanggal Selesai')
                    ->required()
                    ->after('starts_at'),
                Forms\Components\Toggle::make('is_active')
                    ->label('Aktif')
                    ->default(false),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')
                    ->label('Nama')
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
                    ->label('Aktif')
                    ->boolean()
                    ->sortable(),
            ])
            ->filters([
                //
            ])
            ->actions([
                \Filament\Actions\EditAction::make()
                    ->modalSubmitActionLabel('Simpan')
                    ->modalCancelActionLabel('Batal'),
                \Filament\Actions\DeleteAction::make()
                    ->before(function (\Filament\Actions\DeleteAction $action, \App\Models\TahunAjaran $record) {
                        if ($record->riwayatKelasSiswas()->exists() || $record->semesterAkademiks()->exists() || $record->is_active || $record->promotion_processed_at) {
                            \Filament\Notifications\Notification::make()
                                ->title('Tahun Ajaran tidak dapat dihapus')
                                ->body('Tahun Ajaran tidak dapat dihapus karena sudah memiliki riwayat kenaikan kelas, semester akademik, atau sedang aktif.')
                                ->danger()
                                ->send();

                            $action->cancel();
                        }
                    })
                    ->hidden(fn (\App\Models\TahunAjaran $record) => 
                        $record->riwayatKelasSiswas()->exists() || 
                        $record->semesterAkademiks()->exists() || 
                        $record->is_active || 
                        $record->promotion_processed_at
                    ),
            ])
            ->bulkActions([
                \Filament\Actions\BulkActionGroup::make([
                    \Filament\Actions\DeleteBulkAction::make()
                        ->action(function (\Illuminate\Database\Eloquent\Collection $records) {
                            $deletedCount = 0;
                            $skippedCount = 0;

                            foreach ($records as $record) {
                                if ($record->riwayatKelasSiswas()->exists() || $record->semesterAkademiks()->exists() || $record->is_active || $record->promotion_processed_at) {
                                    $skippedCount++;
                                    continue;
                                }

                                $record->delete();
                                $deletedCount++;
                            }

                            if ($skippedCount > 0) {
                                \Filament\Notifications\Notification::make()
                                    ->title('Beberapa data tidak dapat dihapus')
                                    ->body("Berhasil menghapus {$deletedCount} data. {$skippedCount} data dilewati karena sudah memiliki keterkaitan data atau sedang aktif.")
                                    ->warning()
                                    ->send();
                            } else {
                                \Filament\Notifications\Notification::make()
                                    ->title('Berhasil dihapus')
                                    ->body("Berhasil menghapus {$deletedCount} data.")
                                    ->success()
                                    ->send();
                            }
                        }),
                ]),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ManageTahunAjarans::route('/'),
        ];
    }
}
