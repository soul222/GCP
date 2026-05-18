<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // 1. Drop foreign key constraints
        Schema::table('jadwals', function (Blueprint $table) {
            if (Schema::hasColumn('jadwals', 'academic_term_id')) {
                $table->dropForeign(['academic_term_id']);
            }
        });

        Schema::table('academic_terms', function (Blueprint $table) {
            if (Schema::hasColumn('academic_terms', 'academic_year_id')) {
                $table->dropForeign(['academic_year_id']);
            }
        });

        Schema::table('student_class_histories', function (Blueprint $table) {
            if (Schema::hasColumn('student_class_histories', 'academic_year_id')) {
                $table->dropForeign(['academic_year_id']);
            }
        });

        // 2. Rename columns
        if (Schema::hasColumn('jadwals', 'academic_term_id')) {
            Schema::table('jadwals', function (Blueprint $table) {
                $table->renameColumn('academic_term_id', 'semester_akademik_id');
            });
        }

        if (Schema::hasColumn('academic_terms', 'academic_year_id')) {
            Schema::table('academic_terms', function (Blueprint $table) {
                $table->renameColumn('academic_year_id', 'tahun_ajaran_id');
            });
        }

        if (Schema::hasColumn('student_class_histories', 'academic_year_id')) {
            Schema::table('student_class_histories', function (Blueprint $table) {
                $table->renameColumn('academic_year_id', 'tahun_ajaran_id');
            });
        }

        // 3. Rename tables
        if (Schema::hasTable('academic_years') && !Schema::hasTable('tahun_ajarans')) {
            Schema::rename('academic_years', 'tahun_ajarans');
        }

        if (Schema::hasTable('academic_terms') && !Schema::hasTable('semester_akademiks')) {
            Schema::rename('academic_terms', 'semester_akademiks');
        }

        if (Schema::hasTable('student_class_histories') && !Schema::hasTable('riwayat_kelas_siswas')) {
            Schema::rename('student_class_histories', 'riwayat_kelas_siswas');
        }

        // 4. Re-add foreign keys with new table and column names
        Schema::table('semester_akademiks', function (Blueprint $table) {
            $table->foreign('tahun_ajaran_id')->references('id')->on('tahun_ajarans')->cascadeOnDelete();
        });

        Schema::table('jadwals', function (Blueprint $table) {
            $table->foreign('semester_akademik_id')->references('id')->on('semester_akademiks')->nullOnDelete();
        });

        Schema::table('riwayat_kelas_siswas', function (Blueprint $table) {
            $table->foreign('tahun_ajaran_id')->references('id')->on('tahun_ajarans')->restrictOnDelete();
        });
    }

    public function down(): void
    {
        // 1. Drop foreign keys
        Schema::table('jadwals', function (Blueprint $table) {
            if (Schema::hasColumn('jadwals', 'semester_akademik_id')) {
                $table->dropForeign(['semester_akademik_id']);
            }
        });

        Schema::table('semester_akademiks', function (Blueprint $table) {
            if (Schema::hasColumn('semester_akademiks', 'tahun_ajaran_id')) {
                $table->dropForeign(['tahun_ajaran_id']);
            }
        });

        Schema::table('riwayat_kelas_siswas', function (Blueprint $table) {
            if (Schema::hasColumn('riwayat_kelas_siswas', 'tahun_ajaran_id')) {
                $table->dropForeign(['tahun_ajaran_id']);
            }
        });

        // 2. Rename tables back
        if (Schema::hasTable('riwayat_kelas_siswas')) {
            Schema::rename('riwayat_kelas_siswas', 'student_class_histories');
        }
        if (Schema::hasTable('semester_akademiks')) {
            Schema::rename('semester_akademiks', 'academic_terms');
        }
        if (Schema::hasTable('tahun_ajarans')) {
            Schema::rename('tahun_ajarans', 'academic_years');
        }

        // 3. Rename columns back
        if (Schema::hasColumn('jadwals', 'semester_akademik_id')) {
            Schema::table('jadwals', function (Blueprint $table) {
                $table->renameColumn('semester_akademik_id', 'academic_term_id');
            });
        }
        if (Schema::hasColumn('academic_terms', 'tahun_ajaran_id')) {
            Schema::table('academic_terms', function (Blueprint $table) {
                $table->renameColumn('tahun_ajaran_id', 'academic_year_id');
            });
        }
        if (Schema::hasColumn('student_class_histories', 'tahun_ajaran_id')) {
            Schema::table('student_class_histories', function (Blueprint $table) {
                $table->renameColumn('tahun_ajaran_id', 'academic_year_id');
            });
        }

        // 4. Re-add old foreign keys
        Schema::table('academic_terms', function (Blueprint $table) {
            $table->foreign('academic_year_id')->references('id')->on('academic_years')->cascadeOnDelete();
        });

        Schema::table('jadwals', function (Blueprint $table) {
            $table->foreign('academic_term_id')->references('id')->on('academic_terms')->nullOnDelete();
        });

        Schema::table('student_class_histories', function (Blueprint $table) {
            $table->foreign('academic_year_id')->references('id')->on('academic_years')->restrictOnDelete();
        });
    }
};
