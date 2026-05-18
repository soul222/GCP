<?php

namespace App\Filament\Resources\RekapAbsensis\Pages;

use App\Filament\Resources\RekapAbsensis\RekapAbsensiResource;
use App\Models\Jadwal;
use App\Models\Kelas;
use App\Models\PresensiDetail;
use App\Models\PresensiSesi;
use App\Models\User;
use Filament\Actions\Action;
use Filament\Resources\Pages\Page;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Carbon;
use Illuminate\Support\HtmlString;

class ViewRekapAbsensiPelajaran extends Page implements Tables\Contracts\HasTable
{
    use Tables\Concerns\InteractsWithTable;

    protected static string $resource = RekapAbsensiResource::class;

    protected string $view = 'resources.pages.page';

    public ?int $record = null;
    public ?int $jadwal = null;

    public ?Kelas $kelas = null;
    public ?Jadwal $jadwalRecord = null;

    public function mount($record, $jadwal): void
    {
        $this->record = (int) $record;
        $this->jadwal = (int) $jadwal;

        $this->kelas = Kelas::findOrFail($this->record);

        $this->jadwalRecord = Jadwal::query()
            ->with(['kelas', 'mapel', 'guru'])
            ->where('kelas_id', $this->kelas->id)
            ->findOrFail($this->jadwal);

        $this->syncPresensiSesi($this->jadwalRecord);
    }

    public function getTitle(): string
    {
        $hari = $this->formatHari($this->jadwalRecord?->hari);
        $kelas = $this->jadwalRecord?->kelas?->nama ?? '-';
        $mapel = $this->jadwalRecord?->mapel?->nama ?? '-';

        return "Pertemuan - {$hari} - {$kelas} - {$mapel}";
    }

    protected function getHeaderActions(): array
    {
        return [
            Action::make('kembali')
                ->label('Kembali')
                ->url(RekapAbsensiResource::getUrl('hari', [
                    'record' => $this->kelas,
                    'hari' => $this->jadwalRecord?->hari,
                ])),
        ];
    }

    public function table(Table $table): Table
    {
        $tanggalList = [];
        if ($this->jadwalRecord->berlaku_dari && $this->jadwalRecord->berlaku_sampai) {
            $tanggalList = $this->generateTanggalSesi(
                $this->jadwalRecord->hari,
                $this->jadwalRecord->berlaku_dari,
                $this->jadwalRecord->berlaku_sampai,
            );
        }

        $sesis = PresensiSesi::query()
            ->where('jadwal_id', $this->jadwalRecord->id)
            ->get()
            ->keyBy(fn ($s) => Carbon::parse($s->tanggal)->toDateString());

        $columns = [
            Tables\Columns\TextColumn::make('no')
                ->label('No')
                ->rowIndex(),

            Tables\Columns\TextColumn::make('name')
                ->label('Nama Siswa')
                ->searchable()
                ->sortable(),
        ];

        foreach ($tanggalList as $tanggal) {
            $dateFormatted = Carbon::parse($tanggal)->format('d/m');
            $sesi = $sesis->get($tanggal);
            
            $columns[] = Tables\Columns\TextColumn::make('tgl_' . str_replace('-', '_', $tanggal))
                ->label($dateFormatted)
                ->state(function (User $record) use ($sesi, $tanggal) {
                    if (\App\Models\KalenderAkademik::isTanggalDiblokir($tanggal)) {
                        return 'L';
                    }
                    if (!$sesi) {
                        return '-';
                    }
                    
                    $detail = $record->presensiDetails->firstWhere('presensi_sesi_id', $sesi->id);
                    
                    if (! $detail || $sesi->status === 'draft') {
                        return '-';
                    }

                    if ($detail->status === 'alfa' && is_null($detail->waktu_isi)) {
                        return '-';
                    }

                    return match ($detail->status) {
                        'hadir' => 'H',
                        'izin' => 'I',
                        'sakit' => 'S',
                        'alfa' => 'A',
                        default => '-',
                    };
                })
                ->badge()
                ->color(fn (string $state): string => match ($state) {
                    'H' => 'success',
                    'I' => 'warning',
                    'S' => 'warning',
                    'A' => 'danger',
                    'L' => 'danger',
                    default => 'gray',
                })
                ->tooltip(fn (string $state) => $state === 'L' ? 'Libur / Diblokir Kalender Akademik' : null);
        }

        $columns[] = Tables\Columns\TextColumn::make('total_hadir')
            ->label('Hadir')
            ->state(function (User $record) {
                return $record->presensiDetails->where('status', 'hadir')->count();
            })
            ->alignCenter();

        $columns[] = Tables\Columns\TextColumn::make('total_izin')
            ->label('Izin')
            ->state(function (User $record) {
                return $record->presensiDetails->where('status', 'izin')->count();
            })
            ->alignCenter();

        $columns[] = Tables\Columns\TextColumn::make('total_sakit')
            ->label('Sakit')
            ->state(function (User $record) {
                return $record->presensiDetails->where('status', 'sakit')->count();
            })
            ->alignCenter();

        $columns[] = Tables\Columns\TextColumn::make('total_alfa')
            ->label('Alfa')
            ->state(function (User $record) {
                return $record->presensiDetails
                    ->where('status', 'alfa')
                    ->whereNotNull('waktu_isi')
                    ->count();
            })
            ->alignCenter();

        return $table
            ->query($this->getTableQuery())
            ->defaultSort('name', 'asc')
            ->recordAction(null)
            ->recordUrl(null)
            ->columns($columns)
            ->recordActions([])
            ->toolbarActions([])
            ->paginated(false);
    }

    protected function getTableQuery(): Builder
    {
        $sesiIds = PresensiSesi::query()
            ->where('jadwal_id', $this->jadwalRecord->id)
            ->where('status', '!=', 'draft')
            ->pluck('id')
            ->toArray();

        return User::query()
            ->where('role', 'siswa')
            ->where(function ($query) use ($sesiIds) {
                $query->where('kelas_id', $this->jadwalRecord->kelas_id)
                    ->orWhereHas('presensiDetails', function ($q) use ($sesiIds) {
                        $q->whereIn('presensi_sesi_id', $sesiIds);
                    });
            })
            ->with(['presensiDetails' => function ($q) use ($sesiIds) {
                $q->whereIn('presensi_sesi_id', $sesiIds)
                  ->whereHas('sesi', fn($sq) => $sq->notBlockedByKalender());
            }]);
    }

    protected function syncPresensiSesi(Jadwal $jadwal): void
    {
        if (! $jadwal->berlaku_dari || ! $jadwal->berlaku_sampai) {
            return;
        }

        $tanggalList = $this->generateTanggalSesi(
            $jadwal->hari,
            $jadwal->berlaku_dari,
            $jadwal->berlaku_sampai,
        );

        $validDates = [];

        foreach ($tanggalList as $tanggal) {
            if (\App\Models\KalenderAkademik::isTanggalDiblokir($tanggal)) {
                $exists = PresensiSesi::query()
                    ->where('jadwal_id', $jadwal->id)
                    ->where('tanggal', $tanggal)
                    ->exists();
                if ($exists) {
                    $validDates[] = $tanggal;
                }
                continue;
            }

            $validDates[] = $tanggal;

            PresensiSesi::firstOrCreate(
                [
                    'jadwal_id' => $jadwal->id,
                    'tanggal' => $tanggal,
                ],
                [
                    'status' => 'draft',
                ]
            );
        }

        $existingSessions = PresensiSesi::query()
            ->where('jadwal_id', $jadwal->id)
            ->get();

        foreach ($existingSessions as $session) {
            $tanggal = $session->tanggal?->toDateString() ?? (string) $session->tanggal;

            if (! in_array($tanggal, $validDates, true)) {
                PresensiDetail::query()
                    ->where('presensi_sesi_id', $session->id)
                    ->delete();

                $session->delete();
            }
        }
    }



    protected function generateTanggalSesi(string $hari, $mulai, $sampai): array
    {
        $hasil = [];

        $mapHari = [
            'senin' => Carbon::MONDAY,
            'selasa' => Carbon::TUESDAY,
            'rabu' => Carbon::WEDNESDAY,
            'kamis' => Carbon::THURSDAY,
            'jumat' => Carbon::FRIDAY,
        ];

        $targetDay = $mapHari[$hari] ?? null;

        if (! $targetDay) {
            return [];
        }

        $current = Carbon::parse($mulai)->startOfDay();
        $end = Carbon::parse($sampai)->startOfDay();

        while ($current->dayOfWeek !== $targetDay) {
            $current->addDay();

            if ($current->gt($end)) {
                return [];
            }
        }

        while ($current->lte($end)) {
            $hasil[] = $current->toDateString();
            $current->addWeek();
        }

        return $hasil;
    }

    protected function formatHari(?string $hari): string
    {
        return match ($hari) {
            'senin' => 'Senin',
            'selasa' => 'Selasa',
            'rabu' => 'Rabu',
            'kamis' => 'Kamis',
            'jumat' => 'Jumat',
            default => ucfirst((string) $hari),
        };
    }

    protected function formatHariDariTanggal($tanggal): string
    {
        return match (Carbon::parse($tanggal)->dayOfWeek) {
            Carbon::MONDAY => 'Senin',
            Carbon::TUESDAY => 'Selasa',
            Carbon::WEDNESDAY => 'Rabu',
            Carbon::THURSDAY => 'Kamis',
            Carbon::FRIDAY => 'Jumat',
            Carbon::SATURDAY => 'Sabtu',
            Carbon::SUNDAY => 'Minggu',
            default => '-',
        };
    }
}