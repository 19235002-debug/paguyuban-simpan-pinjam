#!/bin/bash

# ==============================================================================
# Script Otomatis Deploy Paguyuban Simpan Pinjam (Laravel & Flutter Web)
# ==============================================================================

echo "----------------------------------------------------"
echo "🚀 Memulai Proses Deploy dari GitHub..."
echo "----------------------------------------------------"

# 1. Pull perubahan terbaru dari GitHub
echo "📥 1. Menarik kode terbaru dari GitHub..."
git reset --hard origin/main
git pull origin main

if [ $? -ne 0 ]; then
    echo "❌ Error: Gagal melakukan git pull. Pastikan koneksi dan permission aman."
    exit 1
fi

# 2. Setup Environment File (.env)
if [ ! -f .env ]; then
    echo "📄 File .env belum ditemukan. Menyalin dari .env.example..."
    cp .env.example .env
    echo "🔑 Generating Application Key..."
    php artisan key:generate --force
else
    echo "✅ File .env sudah tersedia."
    # Memastikan APP_KEY tidak kosong
    if ! grep -q "^APP_KEY=base64:" .env; then
        echo "🔑 APP_KEY belum di-set. Generating Application Key..."
        php artisan key:generate --force
    fi
fi

# 3. Install/Update Dependensi PHP via Composer
if command -v composer &> /dev/null; then
    echo "📦 2. Menginstal/Memperbarui Composer package (production)..."
    composer install --no-dev --optimize-autoloader
else
    echo "⚠️ Warning: Composer tidak ditemukan. Lewati composer install."
fi

# 4. Jalankan Migrasi Database & Seeder
echo "🗄️ 3. Menjalankan migrasi database & seeder..."
php artisan migrate --force
php artisan db:seed --force

# 5. Clearing & Caching Configuration
echo "⚡ 4. Mengoptimalkan Cache Laravel..."
php artisan config:clear
php artisan config:cache
php artisan route:clear
php artisan route:cache
php artisan view:clear
php artisan view:cache

# 6. Storage Link
echo "🔗 5. Membuat Storage Symlink..."
php artisan storage:link --force

# 7. Check & Build Flutter Web jika Flutter tersedia di server
if command -v flutter &> /dev/null; then
    echo "💙 6. Flutter ditemukan! Membangun Flutter Web..."
    cd mobile
    flutter pub get
    flutter build web --release
    cd ..
else
    echo "ℹ️ Flutter SDK tidak ditemukan di server. Pastikan folder mobile/build/web telah di-upload jika menggunakan aplikasi Flutter Web."
fi

echo "----------------------------------------------------"
echo "🎉 DEPLOYMENT SELESAI DENGAN SUKSES!"
echo "----------------------------------------------------"
