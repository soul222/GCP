# 🔍 Analisis Rencana Deployment & Monitoring
## Panduan PDF vs Source Code Aktual — Sistem Absensi SMK Al Hafidz

---

## 📋 Ringkasan Dokumen PDF yang Dianalisis

| Dokumen | Isi |
|---------|-----|
| **Panduan_Deploy_GCP_AWS_Laravel.pdf** | 20 halaman — Deploy ke AWS Elastic Beanstalk + GCP App Engine, setup monitoring EC2, pengujian JMeter |
| **Panduan_Monitoring_Lokal_Prometheus_Grafana.pdf** | 14 halaman — Install Prometheus + Grafana di Windows lokal, endpoint `/metrics`, skenario pengujian |

---

## ✅ Yang Sudah SESUAI (Kelebihan Plan)

### 1. Stack Teknologi — MATCH ✅
Panduan menggunakan **PHP 8.2 + Laravel + Composer** yang sesuai 100% dengan source code (`composer.json` mensyaratkan `"php": "^8.2"`).

### 2. Database Engine — SESUAI ✅
Panduan deploy menggunakan **MySQL 8.0** (RDS di AWS, Cloud SQL di GCP) — sesuai dengan konfigurasi `.env` aktual project (`DB_CONNECTION=mysql`).

### 3. Migrasi Otomatis via `.ebextensions` — SESUAI ✅
Panduan menyertakan `container_commands: 01_migrate: php artisan migrate --force` — ini benar dan diperlukan karena project memiliki **16 migration file** yang harus dijalankan.

### 4. Alur Pengujian JMeter — TERSTRUKTUR ✅
4 skenario (S-01 hingga S-04) dengan variasi thread (10, 50, 100 users) sudah cukup representatif untuk membandingkan AWS vs GCP.

### 5. Grafana Dashboard ID — RELEVAN ✅
Dashboard ID `1860` (Node Exporter Full) dan `14282` (HTTP Request Rate) sudah tepat untuk kebutuhan monitoring web application.

---

## ❌ GAP KRITIS yang BELUM Dicover (Wajib Diperbaiki)

### GAP #1 — MetricsController TIDAK KOMPATIBEL dengan Filament v5 🚨

**Problem di panduan monitoring:**
```php
// Panduan menyarankan ini:
$registry = new CollectorRegistry(new InMemory());
```

**Masalah nyata di source code:**
- Aplikasi menggunakan **Filament v5** yang memiliki middleware stack kompleks (`DisableBladeIconComponents`, `DispatchServingFilamentEvent`, dll.)
- Route `/metrics` yang ditambahkan ke `routes/web.php` akan melewati **Filament middleware** jika tidak dikonfigurasi dengan benar
- `InMemory` storage berarti **counter direset setiap request** — Prometheus tidak akan mendapat data kumulatif yang akurat

**Solusi yang benar:**
```php
// Harus menggunakan APC atau Redis sebagai storage, bukan InMemory:
use Prometheus\Storage\APC;
// atau gunakan package yang lebih cocok untuk Laravel:
composer require spatie/laravel-prometheus
```

---

### GAP #2 — Storage Permission Tidak Dihandle untuk AWS EB 🚨

**Problem:**
Panduan hanya menyertakan `02_storage_link` di `.ebextensions`, namun **tidak menangani permission folder `storage/`**.

**Dampak ke source code:**
- Filament v5 menyimpan banyak file di `storage/` (views, cache, uploaded assets)
- `SESSION_DRIVER=database` dan `CACHE_STORE=database` di `.env` seharusnya aman, **TETAPI** Filament cache panel/views ke `storage/framework/`
- Tanpa permission yang benar, **semua 3 panel (admin/guru/siswa) akan error 500**

**Yang harus ditambahkan ke `.ebextensions/laravel.config`:**
```yaml
container_commands:
  01_migrate:
    command: 'php artisan migrate --force'
    leader_only: true
  02_storage_link:
    command: 'php artisan storage:link'
    leader_only: true
  03_storage_permission:
    command: 'chmod -R 775 storage bootstrap/cache'
    leader_only: true
  04_filament_upgrade:
    command: 'php artisan filament:upgrade'
    leader_only: true
  05_optimize:
    command: 'php artisan optimize'
    leader_only: true
```

---

### GAP #3 — `QUEUE_CONNECTION=database` Tidak Ada Queue Worker di Cloud 🚨

**Problem:**
- Source code menggunakan `QUEUE_CONNECTION=database`
- `SESSION_DRIVER=database` dan `CACHE_STORE=database`
- Panduan deploy **tidak menyebut sama sekali** tentang menjalankan Queue Worker di AWS EB maupun GCP App Engine

**Dampak:**
- Jika ada background job (misalnya notifikasi presensi), job tersebut **tidak akan pernah diproses**
- Di GCP App Engine (shared environment), tidak ada cara standar menjalankan `php artisan queue:work` terus-menerus

**Solusi yang disarankan:**
```yaml
# Untuk AWS EB: tambahkan di .ebextensions/queue.config
container_commands:
  06_queue_worker:
    command: 'php artisan queue:restart'
    leader_only: true
```
Atau gunakan **AWS SQS** sebagai queue driver di production.

---

### GAP #4 — `APP_KEY` di GCP `app.yaml` Harus Di-escape 🚨

**Problem di panduan:**
```yaml
env_variables:
  APP_KEY: [isi dari .env lokal kamu]
```

**Masalah nyata:**
APP_KEY format-nya adalah `base64:Br9Ve9nWUHcC1ocU0LnnMQgkraQdPzeDRhuCPd0uQjA=`
Karakter `:` dan `=` dalam YAML **bisa menyebabkan parsing error** jika tidak di-quote.

**Yang benar:**
```yaml
env_variables:
  APP_KEY: "base64:Br9Ve9nWUHcC1ocU0LnnMQgkraQdPzeDRhuCPd0uQjA="
```
Selalu gunakan **tanda kutip ganda** untuk nilai yang mengandung karakter spesial YAML.

---

### GAP #5 — Filament Panel Auth Butuh `APP_URL` yang Benar 🚨

**Problem:**
Panduan menyebut set `APP_URL=https://[URL-elastic-beanstalk-nanti]` tapi tidak menjelaskan implikasinya.

**Dampak ke source code:**
- Filament v5 secara internal menggunakan `APP_URL` untuk generate URL panel (`/admin`, `/guru`, `/siswa`)
- Jika `APP_URL` salah, redirect setelah login akan **mengarah ke URL yang salah** atau gagal
- Cookie session menggunakan `SESSION_DOMAIN` yang jika `null` bisa bermasalah di shared domain EB/GAE

**Yang perlu ditambahkan ke `.env` production:**
```env
APP_URL=https://[URL-CLOUD-KAMU]
SESSION_DOMAIN=[URL-CLOUD-KAMU]
SANCTUM_STATEFUL_DOMAINS=[URL-CLOUD-KAMU]
```

---

### GAP #6 — Endpoint `/metrics` Tidak Aman (Tanpa Auth) 🚨

**Problem di panduan:**
```php
Route::get('/metrics', [MetricsController::class, 'index']);
```

**Masalah:**
Route ini **terbuka ke publik tanpa autentikasi**. Siapapun bisa mengakses `https://[url-kamu]/metrics` dan melihat data internal aplikasi.

**Solusi:**
```php
Route::get('/metrics', [MetricsController::class, 'index'])
    ->middleware('auth')  // minimal require login
    ->middleware(function ($request, $next) {
        // Atau batasi hanya dari IP monitoring server
        $allowedIps = [env('MONITORING_SERVER_IP', '127.0.0.1')];
        if (!in_array($request->ip(), $allowedIps)) {
            abort(403);
        }
        return $next($request);
    });
```

---

### GAP #7 — `php artisan filament:upgrade` Tidak Disebut di Deploy Script 🚨

**Problem:**
Filament v5 memerlukan `php artisan filament:upgrade` setiap kali package diupdate (terlihat di `composer.json` post-autoload-dump script).

**Jika tidak dijalankan saat deploy:**
- Asset Filament (CSS/JS panel) tidak akan terupdate
- Semua 3 panel bisa tampil dengan style yang rusak atau halaman blank

---

## ⚠️ Catatan Tambahan (Minor Issues)

### Seeder & Akun Admin
Panduan tidak menyebut cara membuat akun admin di production cloud. Source code seedernya **hanya membuat test user tanpa role admin**. Perlu langkah tambahan via `php artisan tinker` setelah deploy.

### GCP App Engine — Tidak Support Persistent Storage
- GCP App Engine adalah **stateless environment**
- `FILESYSTEM_DISK=local` di `.env` untuk upload file **tidak akan persistent**
- Jika ada fitur upload (misalnya foto profil di panel Filament), file akan hilang setiap deploy
- **Solusi:** Gunakan `FILESYSTEM_DISK=gcs` dengan Google Cloud Storage

### Prometheus Scrape ke GCP App Engine
- GCP App Engine menggunakan **HTTPS** dan bisa memiliki redirect
- Konfigurasi Prometheus di panduan sudah benar menggunakan `scheme: https`
- Namun perlu dipastikan App Engine tidak memblokir user-agent `prometheus/2.x`

---

## 📊 Scorecard Penilaian Keseluruhan

| Aspek | Nilai | Keterangan |
|-------|-------|-----------|
| Kesesuaian PHP/Laravel version | ✅ 10/10 | Perfect match |
| Kesesuaian Database (MySQL) | ✅ 9/10 | Sesuai, minor env config issue |
| Setup Prometheus endpoint | ⚠️ 5/10 | InMemory storage tidak cocok |
| Keamanan endpoint /metrics | ❌ 2/10 | Tidak ada auth sama sekali |
| Handling Filament v5 di cloud | ❌ 3/10 | Banyak step yang terlewat |
| Queue worker di production | ❌ 2/10 | Tidak dicover sama sekali |
| Storage permission | ⚠️ 4/10 | Sebagian dicover, kurang lengkap |
| YAML/ENV escaping | ⚠️ 5/10 | Bisa menyebabkan parsing error |
| Struktur pengujian JMeter | ✅ 8/10 | Sudah baik dan terstruktur |
| Grafana dashboard setup | ✅ 7/10 | Dashboard ID relevan |

**Total: 55/100** — Plan masih memerlukan beberapa perbaikan penting sebelum dieksekusi.

---

## 🗺️ Urutan Eksekusi yang Direkomendasikan

```
1. Perbaiki MetricsController (ganti InMemory → APC/Redis atau pakai spatie/laravel-prometheus)
2. Tambahkan middleware auth/IP filter ke route /metrics
3. Lengkapi .ebextensions/laravel.config dengan: permission, filament:upgrade, optimize
4. Pastikan APP_URL & SESSION_DOMAIN di-set benar di environment cloud
5. Quote APP_KEY di app.yaml GCP dengan tanda kutip ganda
6. Deploy ke AWS → Test panel Admin/Guru/Siswa → Buat akun admin via tinker
7. Setup Prometheus lokal → Cek target UP
8. Setup Grafana → Import dashboard 1860 & 14282
9. Jalankan JMeter skenario S-01 sampai S-04
10. Deploy ke GCP → Test ulang → Ulangi JMeter
11. Screenshot & catat data untuk Bab IV skripsi
```

---

> 📅 Analisis dibuat: 12 Mei 2026  
> 🔎 Berdasarkan: Source code `e:\Sintia\Tugas_Akhir` + PDF panduan deployment & monitoring
