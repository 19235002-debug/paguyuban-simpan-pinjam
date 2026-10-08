<?php
/**
 * Script untuk membuat Storage Symlink di Shared Hosting (cPanel) tanpa SSH.
 * Akses melalui browser: http://subdomain.domain.com/symlink.php
 */

$target = __DIR__ . '/../storage/app/public';
$shortcut = __DIR__ . '/storage';

if (file_exists($shortcut)) {
    echo "<h1>Informasi:</h1>";
    echo "<p>Folder symlink <strong>public/storage</strong> sudah ada.</p>";
} else {
    if (symlink($target, $shortcut)) {
        echo "<h1>Sukses:</h1>";
        echo "<p>Storage symlink berhasil dibuat!</p>";
        echo "<p>Folder <strong>storage/app/public</strong> sekarang terhubung ke <strong>public/storage</strong>.</p>";
    } else {
        echo "<h1>Gagal:</h1>";
        echo "<p>Gagal membuat storage symlink. Pastikan folder <strong>public/storage</strong> belum ada sebelumnya dan server Anda mendukung fungsi php <code>symlink()</code>.</p>";
    }
}
