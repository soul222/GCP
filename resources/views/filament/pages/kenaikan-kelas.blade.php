<x-filament-panels::page>
    <div class="space-y-6">
        <header class="fi-header flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
            <div>
                <p class="text-sm text-gray-500 dark:text-gray-400">
                    Kelola proses kenaikan kelas siswa berdasarkan tahun ajaran.
                </p>
            </div>
        </header>

        {{ $this->table }}
    </div>
</x-filament-panels::page>
