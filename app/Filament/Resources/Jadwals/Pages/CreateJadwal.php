<?php

namespace App\Filament\Resources\Jadwals\Pages;

use App\Filament\Resources\Jadwals\JadwalResource;
use Filament\Actions;
use Filament\Resources\Pages\CreateRecord;

class CreateJadwal extends CreateRecord
{
    protected static string $resource = JadwalResource::class;

    protected static bool $canCreateAnother = false;

    protected static ?string $title = 'Buat Jadwal Pelajaran';

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

    protected function mutateFormDataBeforeCreate(array $data): array
    {
        if (empty($data['use_custom_dates'])) {
            $term = \App\Models\SemesterAkademik::find($data['semester_akademik_id']);
            if ($term) {
                $data['berlaku_dari'] = $term->starts_at;
                $data['berlaku_sampai'] = $term->ends_at;
            }
        }
        
        unset($data['use_custom_dates']);
        
        return $data;
    }
}