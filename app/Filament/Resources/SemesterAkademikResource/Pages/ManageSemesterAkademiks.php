<?php

namespace App\Filament\Resources\SemesterAkademikResource\Pages;

use App\Filament\Resources\SemesterAkademikResource;
use Filament\Actions;
use Filament\Resources\Pages\ManageRecords;

class ManageSemesterAkademiks extends ManageRecords
{
    protected static string $resource = SemesterAkademikResource::class;

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
