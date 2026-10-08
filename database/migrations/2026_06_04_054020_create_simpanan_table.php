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
        Schema::create('simpanan', function (Blueprint $table) {
            $table->id();

            $table->foreignId('user_id')
                ->constrained()
                ->cascadeOnDelete();

            $table->enum('jenis', [
                'wajib',
                'sukarela'
            ]);

            $table->unsignedTinyInteger('bulan');
            $table->unsignedSmallInteger('tahun');

            $table->decimal('nominal_simpanan', 15, 2);
            $table->decimal('nominal_admin', 15, 2)->default(10000);

            $table->decimal('total_bayar', 15, 2);

            $table->date('tanggal_bayar')->nullable();

            $table->string('bukti_transfer')->nullable();

            $table->enum('status', [
                'pending',
                'approved',
                'rejected'
            ])->default('pending');

            $table->foreignId('approved_by')
                ->nullable()
                ->constrained('users')
                ->nullOnDelete();

            $table->unique([
                'user_id',
                'jenis',
                'bulan',
                'tahun'
            ], 'simpanan_periode_unique');

            $table->timestamp('approved_at')->nullable();

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('simpanan');
    }
};
