<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pembayaran', function (Blueprint $table) {

            $table->id();

            // USER
            $table->foreignId('user_id')
                ->constrained()
                ->cascadeOnDelete();

            // UNIVERSAL SOURCE
            $table->string('source_type');
            // pinjaman | kredit_barang

            $table->unsignedBigInteger('source_id');

            // CICILAN
            $table->unsignedInteger('angsuran_ke');
            $table->date('jatuh_tempo');
            $table->decimal('nominal', 15, 2);

            // BAYAR USER
            $table->date('tanggal_bayar')->nullable();
            $table->string('bukti_transfer')->nullable();

            // STATUS
            $table->enum('status', [
                'belum_bayar',
                'pending',
                'approved'
            ])->default('belum_bayar');

            // APPROVAL
            $table->foreignId('approved_by')
                ->nullable()
                ->constrained('users')
                ->nullOnDelete();

            $table->timestamp('approved_at')->nullable();

            $table->timestamps();

            $table->index(['source_type', 'source_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pembayaran');
    }
};
