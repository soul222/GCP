<?php

use App\Http\Controllers\MetricsController;
use App\Http\Controllers\ProfileController;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

// Temporary route for GCP App Engine migrations
Route::get('/migrate-db-force', function () {
    try {
        \Illuminate\Support\Facades\Artisan::call('migrate', ['--force' => true]);
        return 'Migrasi Database Berhasil: <br><pre>' . \Illuminate\Support\Facades\Artisan::output() . '</pre>';
    } catch (\Exception $e) {
        return 'Error: ' . $e->getMessage();
    }
});

// ── Prometheus Metrics Endpoint ───────────────────────────────────────────
// Dilindungi oleh PrometheusIpWhitelist middleware.
// Hanya IP yang terdaftar di PROMETHEUS_ALLOWED_IPS (.env) yang bisa akses.
// Tambahkan di .env: PROMETHEUS_ALLOWED_IPS=127.0.0.1,<IP-Prometheus-Server>
Route::get('/metrics', [MetricsController::class, 'index'])
    ->middleware(\App\Http\Middleware\PrometheusIpWhitelist::class)
    ->name('metrics');

Route::get('/dashboard', function () {
    $user = Auth::user(); // biar VS Code nggak merah
    $role = strtolower(trim((string) ($user->role ?? '')));

    return match ($role) {
        'admin' => redirect('/admin'),
        'guru'  => redirect('/guru'),
        default => redirect('/siswa'),
    };
})->middleware(['auth', 'verified'])->name('dashboard');

Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');
});

require __DIR__ . '/auth.php';
