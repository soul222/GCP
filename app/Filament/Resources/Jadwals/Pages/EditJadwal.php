<?php

namespace App\Filament\Resources\Jadwals\Pages;

use App\Filament\Resources\Jadwals\JadwalResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditJadwal extends EditRecord
{
    protected static string $resource = JadwalResource::class;

    protected static ?string $title = 'Edit Jadwal Pelajaran';

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make()->label('Hapus'),
        ];
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

    protected function mutateFormDataBeforeFill(array $data): array
    {
        $data['use_custom_dates'] = false;
        $term = \App\Models\SemesterAkademik::find($data['semester_akademik_id']);
        if ($term) {
            $termStarts = $term->starts_at?->format('Y-m-d');
            $termEnds = $term->ends_at?->format('Y-m-d');
            $jadwalStarts = isset($data['berlaku_dari']) ? \Carbon\Carbon::parse($data['berlaku_dari'])->format('Y-m-d') : null;
            $jadwalEnds = isset($data['berlaku_sampai']) ? \Carbon\Carbon::parse($data['berlaku_sampai'])->format('Y-m-d') : null;
            if ($termStarts !== $jadwalStarts || $termEnds !== $jadwalEnds) {
                $data['use_custom_dates'] = true;
            }
        }
        return $data;
    }

    protected function mutateFormDataBeforeSave(array $data): array
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