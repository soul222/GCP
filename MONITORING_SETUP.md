# 📡 Panduan Integrasi Monitoring — Prometheus + Grafana
## Sistem Absensi SMK Al Hafidz

---

## 🗺️ Gambaran Arsitektur Monitoring

```
┌─────────────────────────────────────────────────────┐
│                   LAPTOP LOKAL (Windows)            │
│                                                     │
│  ┌──────────────────┐    ┌──────────────────────┐   │
│  │ Prometheus       │    │ Grafana              │   │
│  │ port: 9090       │───▶│ port: 3000           │   │
│  │ C:\prometheus\   │    │ http://localhost:3000 │  │
│  └────────┬─────────┘    └──────────────────────┘   │
│           │ scrape /metrics setiap 15 detik          │
└───────────┼─────────────────────────────────────────┘
            │
     ┌──────┴──────┐
     │             │
     ▼             ▼
┌─────────┐  ┌──────────┐
│  AWS    │  │   GCP    │
│EB + RDS │  │ GAE + SQL│
│/metrics │  │ /metrics │
└─────────┘  └──────────┘
```

---

## 📂 File yang Ditambahkan / Diubah

| File | Status | Lokasi |
|------|--------|--------|
| `app/Http/Controllers/MetricsController.php` | **BARU** | Laravel — endpoint Prometheus |
| `app/Http/Middleware/PrometheusIpWhitelist.php` | **BARU** | Laravel — middleware keamanan |
| `routes/web.php` | **DIUBAH** | Tambah route `/metrics` |
| `.ebextensions/laravel.config` | **BARU** | AWS EB — deploy commands |
| `.ebextensions/nginx.config` | **BARU** | AWS EB — Nginx config |
| `app.yaml` | **BARU** | GCP App Engine — deploy config |
| `.gcloudignore` | **BARU** | GCP — file yang dikecualikan |
| `monitoring/prometheus.yml` | **BARU** | Prometheus — scrape config |
| `monitoring/grafana-dashboard.json` | **BARU** | Grafana — dashboard import |

---

## 🔧 LANGKAH 1 — Konfigurasi Laravel (Sebelum Deploy)

### 1.1 Tambahkan variabel ke `.env`

Buka file `.env` di root project, tambahkan baris berikut:

```env
# Prometheus Monitoring
# Isi dengan IP laptop/server Prometheus (gunakan koma jika lebih dari satu)
# Saat development lokal: biarkan 127.0.0.1
PROMETHEUS_ALLOWED_IPS=127.0.0.1
```

> Saat sudah deploy ke cloud, ganti nilai ini dengan IP publik laptop kamu.

### 1.2 Verifikasi endpoint `/metrics` berjalan (lokal)

Pastikan Laravel berjalan (`composer dev` atau `php artisan serve`), lalu buka:

```
http://localhost:8000/metrics
```

Jika berhasil, halaman akan menampilkan teks seperti:

```
# HELP laravel_info Informasi versi aplikasi Laravel
# TYPE laravel_info gauge
laravel_info{version="1.0.0",env="local",app="smk_alhafidz"} 1

# HELP app_http_requests_total Total HTTP request yang masuk ke endpoint /metrics
# TYPE app_http_requests_total counter
app_http_requests_total{method="GET",endpoint="/metrics"} 1

# HELP app_active_users_total Jumlah user yang aktif (is_active=true)
# TYPE app_active_users_total gauge
app_active_users_total{role="siswa"} 0
app_active_users_total{role="guru"} 0
app_active_users_total{role="admin"} 0
...
```

> ⚠️ Jika muncul `403 Forbidden`: pastikan `PROMETHEUS_ALLOWED_IPS=127.0.0.1` ada di `.env`

---

## 📦 LANGKAH 2 — Install Prometheus di Windows (Lokal)

### 2.1 Download & Extract

1. Buka: https://prometheus.io/download/
2. Cari bagian **prometheus** → klik link `...windows-amd64.zip`
3. Extract ke: `C:\prometheus\`

Struktur folder setelah extract:
```
C:\prometheus\
├── prometheus.exe       ← file utama
├── promtool.exe
├── prometheus.yml       ← akan kita ganti dengan yang sudah dibuat
├── consoles\
└── console_libraries\
```

### 2.2 Salin konfigurasi

Salin file konfigurasi dari project ke folder Prometheus:

```powershell
copy "e:\Sintia\Tugas_Akhir\monitoring\prometheus.yml" "C:\prometheus\prometheus.yml"
```

### 2.3 Edit target URL

Buka `C:\prometheus\prometheus.yml`, ganti placeholder:

```yaml
# Ganti baris ini:
- targets: ['[URL-AWS-TANPA-HTTP]']
# Dengan URL AWS kamu, contoh:
- targets: ['presensi-production.ap-southeast-1.elasticbeanstalk.com']

# Ganti baris ini:
- targets: ['[URL-GCP-TANPA-HTTPS]']
# Dengan URL GCP kamu, contoh:
- targets: ['presensi-smk-alhafidz.as.r.appspot.com']
```

### 2.4 Jalankan Prometheus

Buka **Command Prompt sebagai Administrator**:

```cmd
cd C:\prometheus
prometheus.exe --config.file=prometheus.yml
```

Biarkan jendela ini tetap terbuka. Lalu verifikasi di browser:
```
http://localhost:9090
```

Klik **Status → Targets** — pastikan target AWS dan GCP berstatus **UP (hijau)**.

> ℹ️ Jika target DOWN: pastikan endpoint `/metrics` di kedua aplikasi bisa diakses dari browser terlebih dahulu.

---

## 📊 LANGKAH 3 — Install & Konfigurasi Grafana di Windows

### 3.1 Download & Install

1. Buka: https://grafana.com/grafana/download?platform=windows
2. Download file `.msi`
3. Jalankan installer → klik Next → Install → Finish
4. Grafana otomatis berjalan sebagai Windows Service

### 3.2 Login pertama kali

```
URL    : http://localhost:3000
Username: admin
Password: admin  (ganti saat diminta)
```

### 3.3 Tambahkan Prometheus sebagai Data Source

1. Klik ikon **⚙️ (Configuration)** di sidebar kiri
2. Pilih **Data Sources**
3. Klik **Add data source**
4. Pilih **Prometheus**
5. Isi **URL**: `http://localhost:9090`
6. Klik **Save & Test** → harus muncul pesan hijau ✅

---

## 🎨 LANGKAH 4 — Import Dashboard (Sesuai Desain yang Sudah Ada)

Dashboard JSON sudah disiapkan di `monitoring/grafana-dashboard.json` dan mencerminkan desain yang sudah ada (5 panel: CPU/Memory, Response Time, Throughput, Error Rate, Network Traffic — masing-masing AWS vs GCP berdampingan).

### 4.1 Cara Import

1. Di sidebar Grafana, klik **+** → **Import**
2. Klik **Upload JSON file**
3. Pilih file: `e:\Sintia\Tugas_Akhir\monitoring\grafana-dashboard.json`
4. Pada dropdown **Prometheus**, pilih datasource yang sudah ditambahkan
5. Klik **Import**

### 4.2 Hasil Dashboard

Dashboard akan menampilkan **5 baris panel** (sesuai desain):

| Row | Panel Kiri | Panel Kanan | Tipe Visualisasi |
|-----|-----------|------------|-----------------|
| 1 | CPU & Memory Usage — AWS | CPU & Memory Usage — GCP | Time series (line) |
| 2 | Response Time & Latency — AWS | Response Time & Latency — GCP | Time series (line) |
| 3 | Throughput — AWS | Throughput — GCP | Bar gauge |
| 4 | Error Rate — AWS | Error Rate — GCP | Stat (angka besar) |
| 5 | Network Traffic — AWS | Network Traffic — GCP | Time series (line) |

### 4.3 Tema Dashboard

Dashboard menggunakan:
- **Background**: Dark (#1a1a2e)
- **Warna grafik**: Hijau (#73BF69) — sesuai desain asli
- **Auto-refresh**: setiap 30 detik
- **Timezone**: Asia/Jakarta

---

## ☁️ LANGKAH 5 — Deploy ke AWS

### 5.1 Konfigurasi `.env` AWS

Sebelum deploy, pastikan semua variabel sudah di-set:

```bash
eb setenv \
  APP_ENV=production \
  APP_DEBUG=false \
  APP_URL=https://[URL-AWS] \
  DB_CONNECTION=mysql \
  DB_HOST=[ENDPOINT-RDS] \
  DB_DATABASE=[NAMA-DB] \
  DB_USERNAME=admin \
  DB_PASSWORD=[PASSWORD-RDS] \
  APP_KEY="base64:[APP_KEY_DARI_ENV_LOKAL]" \
  SESSION_DOMAIN=[URL-AWS-TANPA-HTTPS] \
  PROMETHEUS_ALLOWED_IPS=[IP-PUBLIK-LAPTOP-KAMU] \
  QUEUE_CONNECTION=database \
  CACHE_STORE=database \
  SESSION_DRIVER=database
```

### 5.2 Deploy

```bash
cd e:\Sintia\Tugas_Akhir
eb deploy
```

### 5.3 Verifikasi setelah deploy

```bash
# Buka aplikasi
eb open

# Cek log jika ada masalah
eb logs
```

Setelah deploy berhasil, akses:
- `http://[URL-AWS]/admin` → Panel Admin
- `http://[URL-AWS]/guru` → Panel Guru
- `http://[URL-AWS]/siswa` → Panel Siswa
- `http://[URL-AWS]/metrics` → Harus **403** (karena IP laptop belum di-whitelist)

> 💡 Untuk test endpoint `/metrics` dari laptop, update `PROMETHEUS_ALLOWED_IPS` dengan IP publik laptop kamu: `eb setenv PROMETHEUS_ALLOWED_IPS=[IP-PUBLIK-LAPTOP]`

---

## ☁️ LANGKAH 6 — Deploy ke GCP

### 6.1 Edit `app.yaml`

Buka file `e:\Sintia\Tugas_Akhir\app.yaml`, ganti semua placeholder:

```yaml
APP_URL: "https://[PROJECT_ID].as.r.appspot.com"
APP_KEY: "base64:[ISI_APP_KEY]"
DB_SOCKET: "/cloudsql/[PROJECT_ID]:[REGION]:presensi-db"
DB_PASSWORD: "[PASSWORD_DB]"
SESSION_DOMAIN: "[PROJECT_ID].as.r.appspot.com"
```

Ganti bagian `beta_settings`:
```yaml
beta_settings:
  cloud_sql_instances: "[PROJECT_ID]:[REGION]:presensi-db"
```

### 6.2 Deploy

```bash
cd e:\Sintia\Tugas_Akhir
gcloud app deploy app.yaml --quiet
```

### 6.3 Jalankan migrasi (jika tidak otomatis)

```bash
gcloud app instances ssh [INSTANCE_ID] -- php artisan migrate --force
```

---

## 👤 LANGKAH 7 — Buat Akun Admin di Production

Setelah deploy berhasil (baik AWS maupun GCP), buat akun admin:

### Untuk AWS:
```bash
eb ssh
php artisan tinker
```

### Untuk GCP:
```bash
gcloud app instances ssh [INSTANCE_ID]
php artisan tinker
```

Di dalam Tinker:
```php
// Buat admin
App\Models\User::create([
    'name'     => 'Administrator',
    'email'    => 'admin@smkalhafidz.sch.id',
    'username' => 'admin',
    'password' => bcrypt('password_aman_123!'),
    'role'     => 'admin',
    'is_active' => true,
]);
exit
```

---

## 🧪 LANGKAH 8 — Jalankan Pengujian JMeter

Jalankan sesuai skenario yang sudah direncanakan, sambil memantau Grafana:

| Skenario | Users | Ramp-up | Loop | Catatan |
|----------|-------|---------|------|---------|
| S-01 | 10 | 5 detik | 3x | Baseline |
| S-02 | 50 | 10 detik | 3x | Medium load |
| S-03 | 100 | 10 detik | 3x | Peak load |
| S-04 | 100 | 10 detik | 6x | Stress test |

**Urutan untuk setiap skenario:**
1. Buka Grafana: `http://localhost:3000` → set time range **Last 15 minutes**
2. Jalankan JMeter untuk AWS → pantau Grafana
3. Catat: Avg, P95, Min, Max, Throughput, Error%
4. Screenshot panel Grafana
5. Tunggu 2 menit → ganti ke GCP di JMeter → ulangi

---

## 🛠️ Troubleshooting Monitoring

### ❌ Target Prometheus STATUS: DOWN

```
Penyebab 1: URL di prometheus.yml salah
→ Cek lagi, jangan sertakan http:// atau https://

Penyebab 2: Endpoint /metrics belum di-deploy
→ Buka URL/metrics di browser terlebih dahulu

Penyebab 3: IP laptop tidak di-whitelist
→ Cek PROMETHEUS_ALLOWED_IPS di .env cloud
→ Perbarui dengan IP publik laptop kamu: https://whatismyipaddress.com/
```

### ❌ Port 9090 sudah terpakai

```cmd
netstat -ano | findstr :9090
# Ganti port Prometheus:
prometheus.exe --config.file=prometheus.yml --web.listen-address=:9091
# Update Grafana datasource URL ke: http://localhost:9091
```

### ❌ Grafana grafik kosong

```
1. Pastikan Prometheus berjalan: http://localhost:9090
2. Set time range ke "Last 1 hour"
3. Tunggu 30-60 detik setelah Prometheus start
4. Tes query manual di Prometheus:
   up{job="presensi_aws"}
```

### ❌ Error 403 saat akses /metrics

```
Tambahkan IP lokal ke PROMETHEUS_ALLOWED_IPS di .env:
PROMETHEUS_ALLOWED_IPS=127.0.0.1

Saat di cloud, tambahkan IP publik laptop:
PROMETHEUS_ALLOWED_IPS=127.0.0.1,<IP-PUBLIK-KAMU>
```

### ❌ Panel Filament blank/error 500 setelah deploy

```bash
# Cek log EB:
eb logs

# Jalankan ulang command Filament:
eb ssh
php artisan filament:upgrade
php artisan optimize:clear
php artisan optimize
```

---

## 📋 Cheatsheet Cepat

```powershell
# ── Prometheus ──────────────────────────────────────
cd C:\prometheus
prometheus.exe --config.file=prometheus.yml    # Jalankan
# Akses: http://localhost:9090

# ── Grafana ─────────────────────────────────────────
# Cek status service:
Get-Service -Name Grafana
Start-Service -Name Grafana                    # Jika stopped
# Akses: http://localhost:3000

# ── Laravel /metrics (lokal) ────────────────────────
# Buka setelah php artisan serve:
# http://localhost:8000/metrics

# ── AWS Deploy ──────────────────────────────────────
eb deploy                                      # Deploy
eb logs                                        # Lihat log
eb open                                        # Buka browser

# ── GCP Deploy ──────────────────────────────────────
gcloud app deploy app.yaml --quiet             # Deploy
gcloud app logs tail -s default                # Lihat log
gcloud app browse                              # Buka browser
```

---

> 📅 Dokumen ini dibuat: **12 Mei 2026**
> 🔄 Versi: Laravel 12 + Filament v5 + Prometheus 2.51 + Grafana 10+
