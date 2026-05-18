<?php

namespace App\Filament\Resources\Mapels\Pages;

use App\Filament\Resources\Mapels\MapelResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditMapel extends EditRecord
{
    protected static string $resource = MapelResource::class;

    protected static ?string $title = 'Edit Mata Pelajaran';

    protected function getHeaderActions(): array
    {
        return [];
    }

    protected function getFormActions(): array
    {
        return [
            $this->getSaveFormAction()->label('Simpan'),
            $this->getCancelFormAction()->label('Batal'),
        ];
    }

    protected function getRedirectUrl(): string
    {
        return static::getResource()::getUrl('index');
    }
}