<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('kalender_akademiks', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->date('starts_at');
            $table->date('ends_at')->nullable();
            $table->string('type')->default('lainnya');
            $table->boolean('is_holiday')->default(false);
            $table->boolean('is_active')->default(true);
            $table->text('notes')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('kalender_akademiks');
    }
};
