<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pinjaman', function (Blueprint $table) {

            $table->id();

            // USER
            $table->foreignId('user_id')
                ->constrained()
                ->cascadeOnDelete();

            // SOURCE (opsional kalau dari kredit barang)
            $table->string('tipe')->default('uang');
            // uang | barang

            $table->unsignedBigInteger('sumber_id')->nullable();

            // KEUANGAN
            $table->decimal('nominal', 15, 2);
            $table->decimal('persen_bunga', 5, 2);
            $table->decimal('nominal_bunga', 15, 2);
            $table->decimal('total_pengembalian', 15, 2);
            $table->unsignedInteger('tenor_bulan');
            $table->decimal('angsuran_per_bulan', 15, 2);

            $table->decimal('sisa_pinjaman', 15, 2)->default(0);

            // OPSIONAL
            $table->text('keterangan')->nullable();

            // STATUS
            $table->enum('status', [
                'pending',
                'approved',
                'rejected',
                'lunas'
            ])->default('pending');

            // APPROVAL
            $table->foreignId('approved_by')
                ->nullable()
                ->constrained('users')
                ->nullOnDelete();

            $table->timestamp('approved_at')->nullable();
            $table->string('ttd_anggota')->nullable();
            $table->string('ttd_admin')->nullable();

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pinjaman');
    }
};
