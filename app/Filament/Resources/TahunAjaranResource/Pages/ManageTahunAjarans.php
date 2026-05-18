<?php

namespace App\Filament\Resources\TahunAjaranResource\Pages;

use App\Filament\Resources\TahunAjaranResource;
use Filament\Actions;
use Filament\Resources\Pages\ManageRecords;

class ManageTahunAjarans extends ManageRecords
{
    protected static string $resource = TahunAjaranResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make()
                ->createAnother(false)
                ->modalSubmitActionLabel('Buat')
                ->modalCancelActionLabel('Batal'),
        ];
    }
}
