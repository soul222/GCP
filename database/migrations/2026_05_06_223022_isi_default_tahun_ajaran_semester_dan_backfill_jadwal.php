<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // 1. Find or create default Academic Year
        $year = DB::table('academic_years')->where('name', '2025/2026')->first();
        if ($year) {
            $yearId = $year->id;
        } else {
            $yearId = DB::table('academic_years')->insertGetId([
                'name' => '2025/2026',
                'starts_at' => '2025-07-01',
                'ends_at' => '2026-06-30',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        // Find the earliest and latest dates in existing jadwals to ensure the term covers them
        $earliest = DB::table('jadwals')->min('berlaku_dari') ?? '2025-07-01';
        $latest = DB::table('jadwals')->max('berlaku_sampai') ?? '2025-12-31';

        // 2. Find or create default Academic Term
        $term = DB::table('academic_terms')
            ->where('academic_year_id', $yearId)
            ->where('name', 'Semester Berjalan')
            ->first();

        if ($term) {
            $termId = $term->id;
        } else {
            $termId = DB::table('academic_terms')->insertGetId([
                'academic_year_id' => $yearId,
                'name' => 'Semester Berjalan',
                'starts_at' => Carbon::parse($earliest)->startOfMonth()->toDateString(),
                'ends_at' => Carbon::parse($latest)->endOfMonth()->toDateString(),
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        // 3. Backfill jadwals safely (only those that are null)
        DB::table('jadwals')
            ->whereNull('academic_term_id')
            ->update(['academic_term_id' => $termId]);
    }

    public function down(): void
    {
        $term = DB::table('academic_terms')->where('name', 'Semester Berjalan')->first();

        if ($term) {
            DB::table('jadwals')
                ->where('academic_term_id', $term->id)
                ->update(['academic_term_id' => null]);
        }
        
        // We do not delete the academic_years or academic_terms records here
        // to prevent destructive data loss of records that might have been actively used.
    }
};
