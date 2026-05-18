<?php

namespace App\Filament\Resources\KalenderAkademikResource\Pages;

use App\Filament\Resources\KalenderAkademikResource;
use Filament\Actions;
use Filament\Resources\Pages\ManageRecords;

class ManageKalenderAkademiks extends ManageRecords
{
    protected static string $resource = KalenderAkademikResource::class;

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
