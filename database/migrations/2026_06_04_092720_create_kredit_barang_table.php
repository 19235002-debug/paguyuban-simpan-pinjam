<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('kredit_barang', function (Blueprint $table) {

            $table->id();

            // USER
            $table->foreignId('user_id')
                ->constrained()
                ->cascadeOnDelete();

            // DATA BARANG
            $table->string('nama_barang');
            $table->decimal('harga_barang', 15, 2);
            $table->string('foto_barang')->nullable();
            $table->text('keterangan')->nullable();

            // KREDIT
            $table->decimal('persen_bunga', 5, 2);
            $table->decimal('nominal_bunga', 15, 2);
            $table->decimal('total_tagihan', 15, 2);
            $table->unsignedInteger('tenor_bulan');
            $table->decimal('angsuran_per_bulan', 15, 2);

            // LINK KE PINJAMAN (JIKA DIPAKAI)
            $table->unsignedBigInteger('pinjaman_id')->nullable();

            // APPROVAL
            $table->foreignId('approved_by')
                ->nullable()
                ->constrained('users')
                ->nullOnDelete();

            $table->timestamp('approved_at')->nullable();

            $table->string('ttd_anggota')->nullable();
            $table->string('ttd_admin')->nullable();

            // STATUS
            $table->enum('status', [
                'pending',
                'approved',
                'rejected',
                'lunas'
            ])->default('pending');

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('kredit_barang');
    }
};
