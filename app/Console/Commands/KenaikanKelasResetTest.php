<?php

namespace App\Console\Commands;

use App\Models\RiwayatKelasSiswa;
use App\Models\TahunAjaran;
use App\Models\User;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\App;
use Illuminate\Support\Facades\DB;

class KenaikanKelasResetTest extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'kenaikan-kelas:reset-test 
                            {--tahun-ajaran-ids= : Comma-separated IDs of Tahun Ajaran to reset} 
                            {--dry-run : Only show changes without updating the database}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Reset student promotion test data for local development';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        if (!App::environment('local')) {
            $this->error('This command can only be used in local development.');
            return 1;
        }

        $idsInput = $this->option('tahun-ajaran-ids');
        if (!$idsInput) {
            $this->error('Please specify --tahun-ajaran-ids=1,2,3');
            return 1;
        }

        $ids = explode(',', $idsInput);
        $tahunAjarans = TahunAjaran::whereIn('id', $ids)->get();

        if ($tahunAjarans->isEmpty()) {
            $this->error('No Tahun Ajaran found with the specified IDs.');
            return 1;
        }

        $this->info('Resetting Kenaikan Kelas Test Data');
        $this->info('Selected Tahun Ajaran: ' . $tahunAjarans->pluck('name')->implode(', '));

        $histories = RiwayatKelasSiswa::whereIn('tahun_ajaran_id', $ids)
            ->with(['siswa', 'fromKelas', 'toKelas'])
            ->orderBy('processed_at', 'asc')
            ->orderBy('id', 'asc')
            ->get();

        if ($histories->isEmpty()) {
            $this->warn('No class history found for the selected years.');
            return 0;
        }

        $groupedHistories = $histories->groupBy('siswa_id');
        $this->info('Affected Students: ' . $groupedHistories->count());

        $restoreData = [];
        foreach ($groupedHistories as $siswaId => $siswaHistories) {
            $earliest = $siswaHistories->first();
            $siswa = $earliest->siswa;

            if (!$siswa) {
                $this->warn("Student ID {$siswaId} not found in users table, skipping.");
                continue;
            }

            if (!$earliest->from_kelas_id) {
                $this->warn("Student {$siswa->name} earliest history has no from_kelas_id, skipping.");
                continue;
            }

            $currentStatus = $siswa->is_active ? ($siswa->kelas->nama ?? 'Aktif / No Kelas') : "Inactive ({$siswa->keterangan_nonaktif})";
            $restoredKelas = $earliest->fromKelas->nama ?? 'Unknown';

            $restoreData[] = [
                'id' => $siswa->id,
                'name' => $siswa->name,
                'current' => $currentStatus,
                'restore_to_id' => $earliest->from_kelas_id,
                'restore_to_name' => $restoredKelas,
            ];
        }

        $this->table(
            ['ID', 'Student Name', 'Current Status', 'Restore To'],
            collect($restoreData)->map(fn($d) => [$d['id'], $d['name'], $d['current'], $d['restore_to_name']])->toArray()
        );

        $this->info('Summary:');
        $this->line("- History records to delete: " . $histories->count());
        $this->line("- Tahun Ajaran to reset: " . $tahunAjarans->count());
        $this->line("- Students to restore: " . count($restoreData));

        if ($this->option('dry-run')) {
            $this->warn('*** DRY RUN: No changes were made to the database. ***');
            return 0;
        }

        if (!$this->confirm('Are you sure you want to proceed with the reset? This will modify students and delete history records.')) {
            $this->info('Reset cancelled.');
            return 0;
        }

        DB::beginTransaction();
        try {
            // 1. Restore Students
            foreach ($restoreData as $data) {
                User::where('id', $data['id'])->update([
                    'kelas_id' => $data['restore_to_id'],
                    'is_active' => true,
                    'keterangan_nonaktif' => null,
                ]);
            }

            // 2. Delete History Records
            RiwayatKelasSiswa::whereIn('tahun_ajaran_id', $ids)->delete();

            // 3. Reset Promotion Processed At
            TahunAjaran::whereIn('id', $ids)->update([
                'promotion_processed_at' => null,
            ]);

            DB::commit();
            $this->success('Reset completed successfully.');
        } catch (\Exception $e) {
            DB::rollBack();
            $this->error('Reset failed: ' . $e->getMessage());
            return 1;
        }

        return 0;
    }

    /**
     * Helper to show success message with color (since Success isn't a method)
     */
    private function success($message)
    {
        $this->line("<info>{$message}</info>");
    }
}
