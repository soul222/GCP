<?php

namespace App\Filament\Resources\RekapAbsensis\Pages;

use App\Filament\Resources\RekapAbsensis\RekapAbsensiResource;
use Filament\Resources\Pages\CreateRecord;

class CreateRekapAbsensi extends CreateRecord
{
    protected static string $resource = RekapAbsensiResource::class;

    protected function getFormActions(): array
    {
        return [
            $this->getCreateFormAction()->label('Buat'),
            $this->getCancelFormAction()->label('Batal'),
        ];
    }

    protected function getRedirectUrl(): string
    {
        return static::getResource()::getUrl('index');
    }
}
