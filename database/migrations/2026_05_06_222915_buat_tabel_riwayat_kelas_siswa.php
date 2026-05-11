<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('student_class_histories', function (Blueprint $table) {
            $table->id();
            $table->foreignId('siswa_id')->constrained('users')->restrictOnDelete();
            $table->foreignId('from_kelas_id')->nullable()->constrained('kelas')->nullOnDelete();
            $table->foreignId('to_kelas_id')->nullable()->constrained('kelas')->nullOnDelete();
            $table->foreignId('academic_year_id')->constrained('academic_years')->restrictOnDelete();
            $table->string('action_type'); // initial, naik_kelas, tinggal_kelas, pindah_kelas, lulus, nonaktif
            $table->text('notes')->nullable();
            $table->foreignId('processed_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('processed_at')->useCurrent();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('student_class_histories');
    }
};
