<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('kelas', function (Blueprint $table) {
            $table->integer('tingkat_angka')->nullable()->after('tingkat');
            $table->foreignId('next_kelas_id')->nullable()->constrained('kelas')->nullOnDelete()->after('tingkat_angka');
        });

        // Safe Backfill mapping based on existing string
        DB::table('kelas')->where('tingkat', 'X')->update(['tingkat_angka' => 10]);
        DB::table('kelas')->where('tingkat', 'XI')->update(['tingkat_angka' => 11]);
        DB::table('kelas')->where('tingkat', 'XII')->update(['tingkat_angka' => 12]);
    }

    public function down(): void
    {
        Schema::table('kelas', function (Blueprint $table) {
            $table->dropForeign(['next_kelas_id']);
            $table->dropColumn(['next_kelas_id', 'tingkat_angka']);
        });
    }
};
