# 🚀 Panduan Lengkap Deployment GCP (App Engine & Cloud SQL)
## Sistem Informasi Absensi SMK Al Hafidz

Dokumen ini disusun khusus untuk tim pengembang guna mempermudah proses deployment, konfigurasi ulang kredensial (password & kunci), pemantauan sistem, hingga penghapusan resource di Google Cloud Platform (GCP). Seluruh langkah dijalankan secara mandiri melalui **GCP Cloud Shell** di browser tanpa memerlukan instalasi software lokal apa pun di komputer Anda.

---

## 📋 Daftar Isi
1. [💡 Mengapa App Engine? (Perbandingan dengan AWS Elastic Beanstalk)](#1-mengapa-app-engine-perbandingan-dengan-aws-elastic-beanstalk)
2. [📊 Informasi Proyek GCP & Repository](#2-informasi-proyek-gcp--repository)
3. [🔑 Peta Lokasi Password & Kunci (Cara Mengubah Kredensial)](#3-peta-lokasi-password--kunci-cara-mengubah-kredensial)
4. [🔌 Layanan GCP yang Wajib Diaktifkan (APIs & Services)](#4-layanan-gcp-yang-wajib-diaktifkan-apis--services)
5. [🛠️ Langkah-Langkah Deployment via Cloud Shell](#5-langkah-langkah-deployment-via-cloud-shell)
   - [Langkah 5.1: Persiapan & Kloning Repository](#langkah-51-persiapan--kloning-repository)
   - [Langkah 5.2: Setup Infrastruktur Otomatis](#langkah-52-setup-infrastruktur-otomatis)
   - [Langkah 5.3: Import Database Manual (.sql)](#langkah-53-import-database-manual-sql)
   - [Langkah 5.4: Deploy Aplikasi ke App Engine](#langkah-54-deploy-aplikasi-ke-app-engine)
6. [📈 Verifikasi & Pemantauan (Monitoring)](#6-verifikasi--pemantauan-monitoring)
7. [🛑 Langkah Pembersihan Resource (Teardown)](#7-langkah-pembersihan-resource-teardown)
8. [🆘 Troubleshooting & Masalah Umum](#8-troubleshooting--masalah-umum)

---

## 1. 💡 Mengapa App Engine? (Perbandingan dengan AWS Elastic Beanstalk)

> [!NOTE]
> **Mengapa kita menggunakan App Engine, dan bukan Cloud Run?**
> 
> Tugas Akhir ini bertujuan membandingkan **performa layanan cloud yang setipe** antara AWS dan GCP. Agar perbandingan adil secara akademis (*apples-to-apples*), tipe layanan yang dibandingkan harus sama-sama **PaaS (Platform as a Service)**:

### 📊 Tabel Perbandingan Layanan yang Setara

| Aspek | ☁️ AWS Elastic Beanstalk | 🚀 GCP App Engine | Kategori |
|:---|:---|:---|:---|
| **Tipe Layanan** | PaaS (Platform as a Service) | PaaS (Platform as a Service) | **Sama ✅** |
| **Cara Deploy** | Upload source code + konfigurasi | Upload source code + `app.yaml` | **Mirip ✅** |
| **Managed Server** | AWS mengelola EC2 di belakang layar | Google mengelola server di belakang layar | **Sama ✅** |
| **Auto Scaling** | Didukung (min/max instances) | Didukung (`min_instances`/`max_instances`) | **Sama ✅** |
| **Load Balancing** | Otomatis oleh AWS ELB | Otomatis oleh Google Front End | **Sama ✅** |
| **Database Terkelola** | AWS RDS (MySQL) | GCP Cloud SQL (MySQL) | **Sama ✅** |

### ❌ Mengapa BUKAN Cloud Run?

| Aspek | GCP Cloud Run | Kategori vs EB |
|:---|:---|:---|
| **Tipe Layanan** | **CaaS** (Container as a Service) | **Berbeda ❌** |
| **Cara Deploy** | Harus membangun Docker container | **Berbeda ❌** |
| **Koneksi Database** | Via IP address publik | **Berbeda ❌** |

Cloud Run menggunakan arsitektur **kontainer Docker** (CaaS), sedangkan Elastic Beanstalk menggunakan arsitektur **platform terkelola** (PaaS). Membandingkan keduanya akan menghasilkan argumen perbandingan yang **tidak valid secara akademis** karena tipe layanannya berbeda.

### 💡 Kesimpulan:
**GCP App Engine** adalah pasangan yang tepat untuk dibandingkan dengan **AWS Elastic Beanstalk** karena keduanya sama-sama:
- Menerima upload source code langsung (tanpa Docker)
- Mengelola server secara otomatis di belakang layar
- Menyediakan auto-scaling dan load balancing bawaan
- Terhubung ke database terkelola (Cloud SQL / RDS) melalui mekanisme internal platform

---

## 📊 2. Informasi Proyek GCP & Repository

Berikut adalah data identitas proyek GCP yang telah terdaftar dan siap digunakan:

| Parameter | Nilai Proyek | Keterangan |
|:---|:---|:---|
| **Project Name** | `presensi-smk-alhafidz` | Nama proyek di Google Cloud Console |
| **Project ID** | `project-876bbc01-98af-4d8d-9e1` | ID unik proyek GCP (Gunakan ID ini untuk perintah CLI) |
| **Project Number** | `278327720815` | Nomor unik proyek GCP |
| **GCP Region** | `asia-southeast2` (Jakarta) | Lokasi data center terdekat untuk latensi terbaik |
| **Git Repository** | `https://github.com/soul222/GCP.git` | Sumber kode utama yang memuat konfigurasi GCP |
| **URL App Engine** | `https://project-876bbc01-98af-4d8d-9e1.et.r.appspot.com` | URL default website setelah deploy |

---

## 🔑 3. Peta Lokasi Password & Kunci (Cara Mengubah Kredensial)

Demi keamanan sistem, Anda **sangat disarankan** untuk mengubah password bawaan sebelum melakukan deployment pertama. Berikut adalah lokasi file dan parameter yang harus disesuaikan:

### 🗺️ Tabel Pemetaan Kredensial

| Nama Variabel / Kredensial | File Sumber | Nilai Default | Cara Mengubah & Keterangan |
|:---|:---|:---|:---|
| **DB_PASSWORD** (Pembuatan DB) | `setup-gcp.sh` baris `16` | `Wnakmi42GCP` | Ubah nilai variabel `DB_PASSWORD` sebelum menjalankan script setup. |
| **DB_PASSWORD** (Koneksi Aplikasi) | `app.yaml` baris `30` | `Wnakmi42GCP` | **PENTING:** Harus disamakan persis dengan password di `setup-gcp.sh`. |
| **DB_DATABASE** (Nama Database) | `setup-gcp.sh` baris `15` & `app.yaml` baris `29` | `absensi_smk_alhafidz` | Nama database MySQL. Harus sama di kedua file. |
| **DB_INSTANCE** (Nama Server DB) | `setup-gcp.sh` baris `14` | `sintia-db-gcp` | Nama instance Cloud SQL. Harus sama dengan yang ada di `app.yaml` bagian `beta_settings`. |
| **APP_KEY** (Kunci Laravel) | `app.yaml` baris `23` | `base64:45CldhQZf7Dzc...` | Kunci enkripsi Laravel. Bisa digenerate baru: `php artisan key:generate --show`. |
| **APP_URL** (Alamat Website) | `app.yaml` baris `22` | `https://project-876bbc01-98af-4d8d-9e1.et.r.appspot.com` | URL default App Engine. Ganti jika menggunakan domain custom nanti. |

### 🛠️ Cara Mengubah Kredensial via Cloud Shell (Sebelum Deploy)
Jika rekan Anda ingin mengubah password langsung dari Cloud Shell tanpa perlu mengedit di laptop:
```bash
# Edit file setup
nano setup-gcp.sh
# Ubah baris DB_PASSWORD="Wnakmi42GCP" → password baru Anda
# Simpan: Ctrl+O → Enter → Ctrl+X

# Edit file app.yaml
nano app.yaml
# Ubah baris DB_PASSWORD: "Wnakmi42GCP" → password baru yang sama
# Simpan: Ctrl+O → Enter → Ctrl+X
```

---

## 🔌 4. Layanan GCP yang Wajib Diaktifkan (APIs & Services)

Aplikasi ini berjalan menggunakan arsitektur **App Engine Standard + Cloud SQL (MySQL)**. Agar seluruh proses berjalan lancar, 3 API utama berikut **wajib diaktifkan**:

1. **App Engine Admin API** (`appengine.googleapis.com`): Untuk mengelola dan mendeploy aplikasi ke App Engine.
2. **Cloud SQL Admin API** (`sqladmin.googleapis.com`): Untuk mengelola basis data MySQL terkelola di GCP.
3. **Cloud Build API** (`cloudbuild.googleapis.com`): Untuk membangun (build) aplikasi secara otomatis saat proses deploy.

---

### 🖥️ Opsi A: Cara Mengaktifkan via GCP Console UI (Browser)

```
[GCP Console] ──> [Navigation Menu] ──> [APIs & Services] ──> [Library] ──> [Search & Enable API]
```

1. Buka browser dan masuk ke **[GCP Console](https://console.cloud.google.com)**.
2. Pilih proyek Anda: **`presensi-smk-alhafidz`** melalui dropdown di bagian kiri atas.
3. Klik tombol **Navigation Menu** (tiga garis horizontal di pojok kiri atas).
4. Arahkan kursor ke **APIs & Services** -> Klik **Library**.
5. Di kolom pencarian, masukkan nama API yang ingin diaktifkan, lalu klik **ENABLE**:
   - `App Engine Admin API` -> Klik **ENABLE**
   - `Cloud SQL Admin API` -> Klik **ENABLE**
   - `Cloud Build API` -> Klik **ENABLE**

---

### 🐚 Opsi B: Cara Cepat via GCP Cloud Shell CLI (Direkomendasikan)

Script `setup-gcp.sh` yang telah disediakan **sudah mengotomatiskan langkah ini**:

```bash
gcloud services enable \
    appengine.googleapis.com \
    sqladmin.googleapis.com \
    cloudbuild.googleapis.com
```
*Anda tidak perlu menjalankan perintah di atas secara manual jika menggunakan script otomatis.*

---

## 🛠️ 5. Langkah-Langkah Deployment via Cloud Shell

Ikuti langkah-langkah berikut secara berurutan untuk meluncurkan aplikasi Anda dari nol (0) hingga online.

### Langkah 5.1: Persiapan & Kloning Repository
1. Buka **[GCP Console](https://console.cloud.google.com)**.
2. Klik ikon **Cloud Shell** `>_` di bagian pojok kanan atas layar.
3. Tunggu hingga terminal virtual Cloud Shell muncul di bagian bawah browser Anda.
4. Kloning repositori GitHub:
   ```bash
   git clone https://github.com/soul222/GCP.git presensi
   cd presensi
   ```

---

### Langkah 5.2: Setup Infrastruktur Otomatis
Jalankan script setup untuk mengaktifkan API, menginisialisasi App Engine, membuat instance Cloud SQL MySQL, serta membuat database kosong.

1. Di dalam Cloud Shell, berikan izin eksekusi dan jalankan script:
   ```bash
   chmod +x setup-gcp.sh
   ./setup-gcp.sh
   ```
2. ⏳ **Proses ini memakan waktu sekitar 5 - 10 menit** (sebagian besar untuk pembuatan Cloud SQL `db-f1-micro`).
3. Setelah script selesai, terminal akan menampilkan informasi koneksi database:
   ```
   ============================================
    SETUP SELESAI!
    
    Langkah selanjutnya:
    1. Import database: Lihat panduan import SQL
    2. Deploy aplikasi: ./deploy-gcp.sh
   ============================================
   ```

---

### Langkah 5.3: Import Database Manual (.sql)
Karena database menggunakan data terisi dari file `database/absensi_smk_alhafidz.sql`, ikuti langkah import manual berikut:

#### 1. Buat Bucket Cloud Storage Sementara
```bash
gsutil mb -p project-876bbc01-98af-4d8d-9e1 -c standard -l asia-southeast2 gs://presensi-db-import-876/
```

#### 2. Upload File SQL ke Bucket Storage
```bash
gsutil cp database/absensi_smk_alhafidz.sql gs://presensi-db-import-876/
```

#### 3. Jalankan Proses Import Database ke Cloud SQL
```bash
gcloud sql import sql sintia-db-gcp gs://presensi-db-import-876/absensi_smk_alhafidz.sql \
    --database=absensi_smk_alhafidz \
    --project=project-876bbc01-98af-4d8d-9e1 \
    --quiet
```
*Tunggu hingga proses selesai dan muncul konfirmasi keberhasilan.*

#### 4. Hapus Bucket Storage Sementara
```bash
gsutil rm -r gs://presensi-db-import-876/
```

#### 5. Verifikasi Keberhasilan Import Data
```bash
gcloud sql connect sintia-db-gcp --user=root
```
Masukkan password database (default: `Wnakmi42GCP`), lalu ketik perintah berikut di dalam terminal MySQL:
```sql
USE absensi_smk_alhafidz;
SHOW TABLES;
EXIT;
```
Pastikan tabel-tabel seperti `users`, `presensi_details`, dll. sudah muncul.

---

### Langkah 5.4: Deploy Aplikasi ke App Engine
Jalankan proses build aset frontend dan deploy aplikasi Laravel ke App Engine Standard.

1. Di terminal Cloud Shell, jalankan script deployment:
   ```bash
   chmod +x deploy-gcp.sh
   ./deploy-gcp.sh
   ```
2. ⏳ **Proses build dan deploy ini memakan waktu sekitar 5–10 menit.**
3. Setelah selesai, terminal akan menampilkan output keberhasilan:
   ```
   ============================================
    DEPLOY BERHASIL!
    URL App Engine : https://project-876bbc01-98af-4d8d-9e1.et.r.appspot.com
   ============================================
   ```
4. **Buka URL tersebut di browser** — halaman login absensi SMK Al Hafidz akan langsung muncul!

> [!NOTE]
> **Tidak perlu langkah "Update APP_URL" seperti Cloud Run.**
> Pada App Engine, URL sudah diketahui sebelum deployment (format: `https://PROJECT_ID.et.r.appspot.com`) dan sudah ditulis di dalam `app.yaml`. Jadi semua link, aset CSS/JS, dan menu akan langsung bekerja sempurna tanpa langkah tambahan.

---

## 📈 6. Verifikasi & Pemantauan (Monitoring)

### 6.1 Verifikasi Aplikasi Web di Browser
1. Buka tab baru di browser dan kunjungi: `https://project-876bbc01-98af-4d8d-9e1.et.r.appspot.com`
2. Pastikan halaman login **Sistem Informasi Absensi SMK Al Hafidz** muncul.
3. Coba login menggunakan akun admin yang ada di database.

### 6.2 Verifikasi Endpoint Metrics Prometheus
Buka alamat berikut untuk memastikan endpoint monitoring aktif:
```
https://project-876bbc01-98af-4d8d-9e1.et.r.appspot.com/metrics
```
Pastikan halaman menampilkan teks baris data metrik Prometheus.

---

### 6.3 Menghubungkan Prometheus Lokal ke App Engine GCP

Jika ingin memantau server produksi GCP dari Prometheus lokal di laptop:

1. Buka file konfigurasi `prometheus.yml` di komputer lokal:
   ```yaml
   scrape_configs:
     - job_name: "gcp_presensi_produksi"
       metrics_path: "/metrics"
       scheme: https
       static_configs:
         - targets:
             - "project-876bbc01-98af-4d8d-9e1.et.r.appspot.com"
           labels:
             platform: "GCP_App_Engine"
             location: "Jakarta"
   ```
2. Restart Prometheus:
   ```powershell
   cd C:\prometheus\prometheus-3.11.3.windows-amd64
   .\prometheus.exe --config.file=prometheus.yml
   ```
3. Buka Grafana lokal (`http://localhost:3000`) dan pastikan data dari server GCP tampil sempurna.

---

### 6.4 Cara Membaca Log Sistem di App Engine
Jika terjadi error, baca pesan kesalahan melalui Cloud Shell:
```bash
gcloud app logs tail -s default --project=project-876bbc01-98af-4d8d-9e1
```
Atau untuk melihat 50 log terakhir:
```bash
gcloud app logs read --limit=50 --project=project-876bbc01-98af-4d8d-9e1
```

---

## 🛑 7. Langkah Pembersihan Resource (Teardown)

> [!WARNING]
> **PENTING:** Lakukan langkah pembersihan ini setelah masa demo, pengujian, atau penilaian Tugas Akhir selesai agar saldo akun GCP tidak terkuras!

### 1. Ekspor Database Akhir (Cadangan Data Terakhir)
```bash
# Buat bucket backup final
gsutil mb -p project-876bbc01-98af-4d8d-9e1 -c standard -l asia-southeast2 gs://presensi-final-backup-876/

# Ekspor database ke bucket
gcloud sql export sql sintia-db-gcp gs://presensi-final-backup-876/backup_akhir_tugas_akhir.sql \
    --database=absensi_smk_alhafidz \
    --project=project-876bbc01-98af-4d8d-9e1
```

### 2. Hentikan App Engine (Stop Traffic)
App Engine tidak bisa dihapus langsung per-service, tetapi bisa dihentikan:
```bash
# Hentikan versi yang sedang berjalan
gcloud app versions stop $(gcloud app versions list --format="value(version.id)" --project=project-876bbc01-98af-4d8d-9e1) \
    --service=default \
    --project=project-876bbc01-98af-4d8d-9e1 \
    --quiet
```

### 3. Hapus Instance Cloud SQL (MySQL)
Hapus instance database MySQL (komponen ini memakan biaya harian paling besar):
```bash
gcloud sql instances delete sintia-db-gcp \
    --project=project-876bbc01-98af-4d8d-9e1 \
    --quiet
```

### 4. Hapus Bucket Cloud Storage
```bash
gsutil rm -r gs://presensi-final-backup-876/
```

### 💥 Opsi Alternatif: Hapus Total Project (Opsi Paling Bersih & Mudah)
Jika Anda tidak membutuhkan proyek GCP ini lagi, hapus secara keseluruhan:
```bash
gcloud projects delete project-876bbc01-98af-4d8d-9e1 --quiet
```
Ini akan **otomatis menghapus semua resource** termasuk App Engine, Cloud SQL, dan Cloud Storage tanpa tersisa.

> [!NOTE]
> **Mengapa App Engine tidak bisa dihapus secara individual?**
> Berbeda dengan Cloud Run, App Engine **tidak mendukung penghapusan service** secara langsung. Anda hanya bisa menghentikan (*stop*) versi yang berjalan. Untuk menghapus App Engine sepenuhnya, satu-satunya cara adalah menghapus seluruh proyek GCP.

---

## 🆘 8. Troubleshooting & Masalah Umum

### ❌ Error 1: `500 | Server Error` saat membuka website
* **Penyebab:** Umumnya aplikasi gagal terhubung ke database MySQL.
* **Solusi:**
  1. Pastikan `DB_SOCKET` di `app.yaml` sudah benar: `/cloudsql/project-876bbc01-98af-4d8d-9e1:asia-southeast2:sintia-db-gcp`
  2. Pastikan `DB_PASSWORD` di `app.yaml` sama dengan password di `setup-gcp.sh`.
  3. Pastikan `beta_settings.cloud_sql_instances` di `app.yaml` sudah sesuai.
  4. Cek log: `gcloud app logs tail -s default`

### ❌ Error 2: `SQLSTATE[HY000] [2002] No such file or directory`
* **Penyebab:** Unix Socket koneksi Cloud SQL belum terkonfigurasi dengan benar.
* **Solusi:**
  * Pastikan `beta_settings.cloud_sql_instances` di `app.yaml` terisi: `project-876bbc01-98af-4d8d-9e1:asia-southeast2:sintia-db-gcp`
  * Pastikan `DB_SOCKET` (bukan `DB_HOST`) digunakan di `app.yaml`.

### ❌ Error 3: Aset web (CSS/JS) rusak atau link menu tidak bekerja
* **Penyebab:** Variabel `APP_URL` di `app.yaml` tidak sesuai.
* **Solusi:** Pastikan `APP_URL` di `app.yaml` terisi: `https://project-876bbc01-98af-4d8d-9e1.et.r.appspot.com`

### ❌ Error 4: `Error: NOT_FOUND: Unable to retrieve P4SA`
* **Penyebab:** App Engine belum diinisialisasi di region yang dipilih.
* **Solusi:** Jalankan `gcloud app create --region=asia-southeast2` terlebih dahulu (sudah otomatis di `setup-gcp.sh`).

### ❌ Error 5: Build gagal saat `npm run build`
* **Penyebab:** Dependencies Node.js belum terinstall.
* **Solusi:** Jalankan `npm install` secara manual sebelum deploy, lalu ulangi `./deploy-gcp.sh`.

---

## 💰 Estimasi Biaya App Engine

| Resource | Kondisi | Biaya/Hari |
|:---|:---|:---|
| App Engine Standard | Idle (min_instances: 0, tidak ada traffic) | ~$0.00 - $0.05 |
| App Engine Standard | Aktif dengan traffic rendah | ~$0.10 - $0.30 |
| Cloud SQL db-f1-micro | Running 24 jam | ~$0.21 |
| **Total (testing aktif)** | | **~Rp 5.000 – Rp 15.000/hari** |

> 💡 **Tips hemat:** Hentikan App Engine dan matikan Cloud SQL saat tidak dipakai:
> ```bash
> # Stop App Engine
> gcloud app versions stop [VERSION_ID] --service=default --project=project-876bbc01-98af-4d8d-9e1
> 
> # Matikan Cloud SQL
> gcloud sql instances patch sintia-db-gcp --activation-policy=NEVER
> 
> # Hidupkan kembali saat dibutuhkan
> gcloud sql instances patch sintia-db-gcp --activation-policy=ALWAYS
> ```

---
*Dokumentasi ini disiapkan secara khusus untuk memudahkan kolaborasi tim pengembang dalam deployment Sistem Informasi Absensi SMK Al Hafidz ke GCP App Engine Standard.*
