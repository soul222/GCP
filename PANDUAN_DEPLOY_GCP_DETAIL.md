# 🚀 Panduan Lengkap Deployment GCP (Cloud Run & Cloud SQL)

## Sistem Informasi Absensi SMK Al Hafidz

Dokumen ini disusun khusus untuk tim pengembang guna mempermudah proses deployment, konfigurasi ulang kredensial (password & kunci), pemantauan sistem, hingga penghapusan resource di Google Cloud Platform (GCP). Seluruh langkah dijalankan secara mandiri melalui **GCP Cloud Shell** di browser tanpa memerlukan instalasi software lokal apa pun di komputer Anda.

---

## 📋 Daftar Isi

1. [💡 Mengapa Cloud Run? (Bukan App Engine)](#1-mengapa-cloud-run-bukan-app-engine)
2. [📊 Informasi Proyek GCP & Repository](#2-informasi-proyek-gcp--repository)
3. [🔑 Peta Lokasi Password & Kunci (Cara Mengubah Kredensial)](#3-peta-lokasi-password--kunci-cara-mengubah-kredensial)
4. [🔌 Layanan GCP yang Wajib Diaktifkan (APIs & Services)](#4-layanan-gcp-yang-wajib-diaktifkan-apis--services)
5. [🛠️ Langkah-Langkah Deployment via Cloud Shell](#5-langkah-langkah-deployment-via-cloud-shell)
    - [Langkah 5.1: Persiapan & Kloning Repository](#langkah-51-persiapan--kloning-repository)
    - [Langkah 5.2: Setup Infrastruktur Otomatis](#langkah-52-setup-infrastruktur-otomatis)
    - [Langkah 5.3: Import Database Manual (.sql)](#langkah-53-import-database-manual-sql)
    - [Langkah 5.4: Deploy Aplikasi ke Cloud Run](#langkah-54-deploy-aplikasi-ke-cloud-run)
    - [Langkah 5.5: Sinkronisasi APP_URL Pasca-Deploy](#langkah-55-sinkronisasi-app_url-pasca-deploy)
6. [📈 Verifikasi & Pemantauan (Monitoring)](#6-verifikasi--pemantauan-monitoring)
7. [🛑 Langkah Pembersihan Resource (Teardown)](#7-langkah-pembersihan-resource-teardown)
8. [🆘 Troubleshooting & Masalah Umum](#8-troubleshooting--masalah-umum)

---

## 1. 💡 Mengapa Cloud Run? (Bukan App Engine)

> [!NOTE]
> **Mengapa dokumen lama/deskripsi tugas akhir menyebutkan App Engine, tetapi kita malah menggunakan Cloud Run?**
>
> Jawabannya sangat sederhana: **BIAYA (COST) & KEMUDAHAN.**
>
> Bagi pemula atau rekan tim yang baru belajar _cloud computing_, sangat penting untuk memahami perbedaan mendasar ini agar tagihan kartu kredit/saldo GCP Anda tidak jebol (sampai jutaan rupiah) hanya karena salah memilih jenis layanan cloud.

Berikut adalah perbandingan jujur mengapa **Cloud Run** jauh lebih baik, aman, dan hemat untuk proyek Tugas Akhir ini dibandingkan dengan **App Engine**:

### 📊 Tabel Perbandingan: Cloud Run vs App Engine

| Aspek                      | 🚀 GCP Cloud Run (Pilihan Kita)                           | ☁️ GCP App Engine                          | Mengapa Ini Penting bagi Mahasiswa?                                                                                                                                                                                         |
| :------------------------- | :-------------------------------------------------------- | :----------------------------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Fitur "Scale to Zero"**  | **Mendukung Penuh (`--min-instances 0`)**                 | Terbatas / Tidak Mendukung (Flexible)      | **SANGAT PENTING!** Jika web tidak diakses (misal malam hari), server Cloud Run otomatis mati total. Biayanya **Rp 0** saat tidak ada traffic. App Engine akan terus menyala 24 jam dan memotong saldo Anda secara konstan. |
| **Estimasi Biaya Bulanan** | **Sangat Murah (~Rp 3.000 - Rp 5.000 / hari jika aktif)** | Mahal (~Rp 300.000 - Rp 1.500.000 / bulan) | Cloud Run hanya menagih untuk milidetik saat kode Anda benar-benar berjalan memproses request.                                                                                                                              |
| **Teknologi Dasar**        | **Berbasis Docker Container**                             | Berbasis runtime bawaan GCP                | Cloud Run menggunakan Docker, artinya kode aplikasi Anda standar industri, mandiri, dan sangat mudah dipindahkan ke server mana pun (AWS, VPS, local PC) tanpa mengubah kode.                                               |
| **Waktu Deployment**       | **Cepat (3 - 5 menit)**                                   | Lambat (10 - 20 menit)                     | Rekan tim Anda tidak perlu membuang waktu lama menunggu proses deploy selesai di Cloud Shell.                                                                                                                               |
| **Keamanan Kredensial**    | Diset dinamis melalui Env Vars saat deploy                | Harus ditulis di dalam file `app.yaml`     | Menulis kredensial di `app.yaml` sangat rawan tidak sengaja ter-push ke GitHub publik.                                                                                                                                      |

### 💡 Analogi Sederhana untuk Pemula:

- **App Engine** itu seperti **Menyewa Kamar Kos Bulanan**. Anda pakai atau tidak pakai kamar tersebut (misalnya saat Anda sedang pergi/tidur), Anda tetap wajib membayar sewa penuh setiap bulan.
- **Cloud Run** itu seperti **Membayar Kamar Hotel/Bilik Warnet per Jam**. Anda hanya perlu membayar tepat untuk durasi menit/jam saat Anda menempati dan menggunakan bilik tersebut. Jika Anda keluar, arloji pembayaran berhenti seketika.

Oleh karena itu, demi menyelamatkan kantong mahasiswa dan memberikan fleksibilitas deployment berbasis Docker kontainer modern, **GCP Cloud Run adalah keputusan arsitektur terbaik untuk sistem absensi ini.**

---

## 📊 2. Informasi Proyek GCP & Repository

Berikut adalah data identitas proyek GCP yang telah terdaftar dan siap digunakan:

| Parameter          | Nilai Proyek                         | Keterangan                                             |
| :----------------- | :----------------------------------- | :----------------------------------------------------- |
| **Project Name**   | `presensi-smk-alhafidz`              | Nama proyek di Google Cloud Console                    |
| **Project ID**     | `project-876bbc01-98af-4d8d-9e1`     | ID unik proyek GCP (Gunakan ID ini untuk perintah CLI) |
| **Project Number** | `278327720815`                       | Nomor unik proyek GCP                                  |
| **GCP Region**     | `asia-southeast2` (Jakarta)          | Lokasi data center terdekat untuk latensi terbaik      |
| **Git Repository** | `https://github.com/soul222/GCP.git` | Sumber kode utama yang memuat konfigurasi GCP          |

---

## 🔑 3. Peta Lokasi Password & Kunci (Cara Mengubah Kredensial)

Demi keamanan sistem, Anda **sangat disarankan** untuk mengubah password bawaan sebelum melakukan deployment pertama. Berikut adalah lokasi file dan parameter yang harus disesuaikan:

### 🗺️ Tabel Pemetaan Kredensial

| Nama Variabel / Kredensial       | File Sumber                                                                                                                                    | Baris Ke-    | Nilai Default                      | Cara Mengubah & Keterangan                                                                                                                                                        |
| :------------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------- | :----------- | :--------------------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **DB_PASSWORD** (Koneksi DB)     | [`setup-gcp.sh`](file:///E:/Sintia/Staging/Tugas_Akhir/setup-gcp.sh)                                                                           | `16`         | `Wnakmi42GCP`                      | Ubah nilai variabel `DB_PASSWORD` sebelum menjalankan script setup database.                                                                                                      |
| **DB_PASSWORD** (Aplikasi Run)   | [`deploy-gcp.sh`](file:///E:/Sintia/Staging/Tugas_Akhir/deploy-gcp.sh)                                                                         | `19`         | `Wnakmi42GCP`                      | **PENTING:** Harus disamakan persis dengan password yang Anda set di `setup-gcp.sh` agar aplikasi dapat terhubung ke DB.                                                          |
| **DB_NAME** (Nama Database)      | [`setup-gcp.sh`](file:///E:/Sintia/Staging/Tugas_Akhir/setup-gcp.sh)                                                                           | `15`         | `presensi_db1`                     | Nama database MySQL yang akan dibuat di Cloud SQL.                                                                                                                                |
| **DB_NAME** (Aplikasi Run)       | [`deploy-gcp.sh`](file:///E:/Sintia/Staging/Tugas_Akhir/deploy-gcp.sh)                                                                         | `17`         | `presensi_db1`                     | Harus disamakan dengan `DB_NAME` di `setup-gcp.sh`.                                                                                                                               |
| **DB_INSTANCE** (Nama Server DB) | [`setup-gcp.sh`](file:///E:/Sintia/Staging/Tugas_Akhir/setup-gcp.sh)<br>[`deploy-gcp.sh`](file:///E:/Sintia/Staging/Tugas_Akhir/deploy-gcp.sh) | `14`<br>`16` | `presensi-db-gcp`                  | Nama instance fisik Cloud SQL Anda. Harus sama di kedua file tersebut.                                                                                                            |
| **APP_KEY** (Kunci Laravel)      | [`deploy-gcp.sh`](file:///E:/Sintia/Staging/Tugas_Akhir/deploy-gcp.sh)                                                                         | `21`         | `base64:Br9Ve9nWUHcC1ocU0LnnMQ...` | Kunci enkripsi Laravel. Jangan pernah mempublikasikan kunci ini secara bebas. Anda bisa membuat kunci baru di laptop Anda menggunakan perintah `php artisan key:generate --show`. |

### 🛠️ Cara Mengubah Kredensial di Laptop Anda Sebelum Push

1. Buka file [`setup-gcp.sh`](file:///E:/Sintia/Staging/Tugas_Akhir/setup-gcp.sh) di VS Code / Text Editor Anda.
2. Cari baris `16`: `DB_PASSWORD="Wnakmi42GCP"` dan ubah ke password baru yang lebih aman.
3. Buka file [`deploy-gcp.sh`](file:///E:/Sintia/Staging/Tugas_Akhir/deploy-gcp.sh).
4. Cari baris `19`: `DB_PASSWORD="Wnakmi42GCP"` dan **samakan persis** nilainya dengan langkah kedua.
5. Simpan semua file, lalu lakukan commit dan push ke GitHub:
    ```powershell
    git add setup-gcp.sh deploy-gcp.sh
    git commit -m "chore: update database deployment password"
    git push origin main
    ```

---

## 🔌 4. Layanan GCP yang Wajib Diaktifkan (APIs & Services)

Aplikasi ini berjalan menggunakan arsitektur Cloud Run + Cloud SQL (MySQL). Agar seluruh proses berjalan lancar, 4 API utama berikut **wajib diaktifkan** di dalam proyek GCP Anda:

1. **Cloud Run API** (`run.googleapis.com`): Untuk meng-host aplikasi berbasis kontainer docker (Laravel) secara serverless.
2. **Cloud SQL Admin API** (`sqladmin.googleapis.com`): Untuk mengelola basis data MySQL terkelola di GCP.
3. **Cloud Build API** (`cloudbuild.googleapis.com`): Untuk membangun (build) Docker image dari source code Laravel secara otomatis di server GCP.
4. **Artifact Registry API** (`artifactregistry.googleapis.com`): Untuk menyimpan hasil build Docker image sebelum dideploy ke Cloud Run.

---

### 🖥️ Opsi A: Cara Mengaktifkan via GCP Console UI (Browser)

Jika Anda ingin mengaktifkannya secara visual di browser, ikuti langkah berikut:

```
[GCP Console] ──> [Navigation Menu] ──> [APIs & Services] ──> [Library] ──> [Search & Enable API]
```

1. Buka browser dan masuk ke **[GCP Console](https://console.cloud.google.com)**.
2. Pilih proyek Anda: **`presensi-smk-alhafidz`** melalui dropdown di bagian kiri atas.
3. Klik tombol **Navigation Menu** (tiga garis horizontal di pojok kiri atas).
4. Arahkan kursor ke **APIs & Services** -> Klik **Library**.
5. Di kolom pencarian (Search box), masukkan nama API yang ingin diaktifkan (misalnya: `Cloud Run API`).
6. Klik pada hasil pencarian **Cloud Run API** yang muncul.
7. Klik tombol biru bertuliskan **ENABLE**.
8. Ulangi langkah 4-7 untuk ketiga API lainnya:
    - Pencarian: `Cloud SQL Admin API` -> Klik **ENABLE**.
    - Pencarian: `Cloud Build API` -> Klik **ENABLE**.
    - Pencarian: `Artifact Registry API` -> Klik **ENABLE**.

---

### 🐚 Opsi B: Cara Cepat via GCP Cloud Shell CLI (Direkomendasikan)

Script `setup-gcp.sh` yang telah disediakan **sudah mengotomatiskan langkah ini**. Saat Anda menjalankan script tersebut di Cloud Shell, perintah berikut akan dieksekusi secara otomatis di latar belakang:

```bash
gcloud services enable \
    run.googleapis.com \
    sqladmin.googleapis.com \
    cloudbuild.googleapis.com \
    artifactregistry.googleapis.com
```

_Anda tidak perlu menjalankan perintah di atas secara manual jika Anda menggunakan script otomatis._

---

## 🛠️ 5. Langkah-Langkah Deployment via Cloud Shell

Ikuti langkah-langkah berikut secara berurutan untuk meluncurkan aplikasi Anda dari nol (0) hingga online.

### Langkah 5.1: Persiapan & Kloning Repository

1. Buka **[GCP Console](https://console.cloud.google.com)**.
2. Klik ikon **Cloud Shell** `>_` di bagian pojok kanan atas layar (sebelah kanan kolom pencarian).
3. Tunggu hingga terminal virtual Cloud Shell muncul di bagian bawah browser Anda.
4. Kloning repositori GitHub Anda ke dalam ruang penyimpanan Cloud Shell dengan mengetik:
    ```bash
    git clone https://github.com/soul222/GCP.git
    cd GCP
    ```
    ```
    sudo apt-get install -y php8.3-intl php8.3-zip
    ```
    ```
    composer install --ignore-platform-req=ext-intl --ignore-platform-req=ext-zip
    ```
    ```
    npm install
    ```
    ```
    npm run build
    ```

---

### Langkah 5.2: Setup Infrastruktur Otomatis

Jalankan script setup untuk mengaktifkan API, membuat instance Cloud SQL MySQL, serta membuat database kosong.

1. Di dalam Cloud Shell, berikan izin eksekusi dan jalankan script:
    ```bash
    chmod +x setup-gcp.sh
    ./setup-gcp.sh
    ```
2. ⏳ **Proses ini memakan waktu sekitar 5 - 10 menit** (sebagian besar waktu digunakan untuk memproses pembuatan Cloud SQL instance `db-f1-micro`). Silakan tunggu hingga proses selesai.
3. Setelah script selesai berjalan, terminal akan menampilkan output seperti berikut:
    ```
    ============================================
     SETUP SELESAI!
     Sekarang jalankan: ./deploy-gcp.sh
    ============================================
    ```
4. **PENTING:** Perhatikan baris sebelum teks selesai yang menuliskan IP Address database Anda:
    ```
    DB_HOST = 34.xxx.xxx.xxx
    ```
    **Salin dan catat IP tersebut** di notepad laptop Anda. Kita akan menggunakannya untuk proses import di langkah berikutnya.

---

### Langkah 5.3: Import Database Manual (.sql)

Karena database tidak di-migrate dari awal tetapi menggunakan backup data terisi yang ada di file `database/absensi_smk_alhafidz.sql`, ikuti langkah pengunggahan dan pengimporan manual berikut:

#### 1. Buat Bucket Cloud Storage Sementara

Buat ruang penyimpanan (bucket) sementara di GCP untuk mengupload file SQL Anda:

```bash
# Buat bucket (Ganti nama bucket (bagian yang bisa di ganti ini: presensi-db-import-876) agar unik, misal tambahkan ID projek di belakangnya (id project nya yang ini: project-876bbc01-98af-4d8d-9e1))
gsutil mb -p project-876bbc01-98af-4d8d-9e1 -c standard -l asia-southeast2 gs://presensi-db-import-876/
```

#### 2. Upload File SQL dari Git ke Bucket Storage

Copy file SQL yang ada di repositori lokal ke dalam bucket yang baru dibuat:

```bash
# Buat bagian ini presensi-db-import-876 diganti dengan nama bucket yang telah dibuat
gsutil cp database/absensi_smk_alhafidz.sql gs://presensi-db-import-876/
```

#### 3. Jalankan Proses Import Database ke Cloud SQL

Perintahkan GCP Cloud SQL untuk mengimpor file SQL dari bucket storage ke database `absensi_smk_alhafidz`:

```bash
# Buat bagian ini presensi-db-import-876 diganti dengan nama bucket yang telah dibuat (id project nya yang ini: project-876bbc01-98af-4d8d-9e1) bisa di ganti disesuaikan dengan proejct yang di gunakan dan sesuai dengan id project bucket yang dibuat)

gcloud sql import sql presensi-db-gcp gs://presensi-db-import-876/absensi_smk_alhafidz.sql \
    --database=absensi_smk_alhafidz \
    --project=project-876bbc01-98af-4d8d-9e1 \
    --quiet
```

_Tunggu hingga proses selesai. Jika berhasil, akan muncul konfirmasi status keberhasilan._

#### 4. Hapus Bucket Storage Sementara (Pembersihan)

Setelah data terimport, hapus bucket sementara agar tidak menambah biaya storage:

```bash
# Buat bagian ini presensi-db-import-876 diganti dengan nama bucket yang telah dibuat
gsutil rm -r gs://presensi-db-import-876/
```

#### 5. Verifikasi Keberhasilan Import Data

Untuk memastikan tabel dan data siswa sudah masuk ke database, hubungkan Cloud Shell Anda ke database:

```bash

gcloud sql connect presensi-db-gcp --user=root --database=absensi_smk_alhafidz
```

- Terminal akan meminta password MySQL. Masukkan password database Anda (Default: `Wnakmi42GCP` atau password baru yang sudah Anda ubah).\*
- Setelah masuk ke mode command line MySQL (`mysql>`), ketik perintah berikut:
    ```sql
    SHOW TABLES;
    ```
- Pastikan seluruh tabel absensi (seperti `users`, `presensi_details`, dll.) terdaftar dengan benar.
- Keluar dari terminal MySQL dengan mengetik:
    ```sql
    EXIT;
    ```

---

### Langkah 5.4: Deploy Aplikasi ke Cloud Run

Jalankan proses kompilasi kode Laravel ke image Docker, mengunggahnya ke registry, dan meluncurkannya ke serverless Cloud Run.

1. Di terminal Cloud Shell, jalankan script deployment:
    ```bash
    chmod +x deploy-gcp.sh
    ./deploy-gcp.sh
    ```
2. ⏳ **Proses kompilasi dan upload ini memakan waktu sekitar 5–8 menit.**
3. Setelah selesai, terminal akan menampilkan output keberhasilan:
    ```
    ============================================
     DEPLOY BERHASIL!
     URL GCP  : https://presensi-alhafidz-xxxxxxxxxx-et.a.run.app
     Domain   : https://presensi-alhafidz-placeholder.a.run.app
    ============================================
    ```
4. **Salin URL GCP yang dihasilkan** (URL yang berakhiran `.a.run.app`).

---

### Langkah 5.5: Sinkronisasi APP_URL Pasca-Deploy

Karena Laravel memerlukan informasi URL server yang tepat agar link menu, aset CSS, dan Javascript termuat sempurna di browser, kita harus memperbarui konfigurasi `APP_URL` di Cloud Run dengan URL asli yang didapatkan pada Langkah 5.4.

1. Jalankan perintah pembaruan env-var berikut di Cloud Shell:

    ```bash
    gcloud run services update presensi-alhafidz \
        --region=asia-southeast2 \
        --project=project-876bbc01-98af-4d8d-9e1 \
        --update-env-vars APP_URL=https://presensi-alhafidz-xxxxxxxxxx-et.a.run.app
    ```

    _(Ganti `https://presensi-alhafidz-xxxxxxxxxx-et.a.run.app` dengan URL asli hasil deploy Anda di Langkah 5.4)_

2. Tunggu proses update revisi Cloud Run selesai (~30 detik). Aplikasi Anda sekarang **100% aktif dan siap digunakan!**

---

## 📈 6. Verifikasi & Pemantauan (Monitoring)

### 6.1 Verifikasi Aplikasi Web di Browser

1. Buka tab baru di browser Anda dan kunjungi URL Cloud Run yang Anda catat sebelumnya.
2. Pastikan halaman login absensi **Sistem Informasi Absensi SMK Al Hafidz** terbuka dengan desain premium.
3. Coba lakukan login menggunakan akun kredensial admin yang ada di database absensi Anda.

### 6.2 Verifikasi Endpoint Metrics Prometheus

Aplikasi ini sudah dilengkapi sistem monitoring bawaan. Cek keberadaan metrik sistem dengan membuka alamat:

```
https://presensi-alhafidz-xxxxxxxxxx-et.a.run.app/metrics
```

_Pastikan halaman tersebut menampilkan teks baris data metrik sistem (Prometheus format) dan tidak menghasilkan error._

---

### 6.3 Menghubungkan Prometheus Lokal Teammate ke GCP

Jika rekan kerja Anda ingin memantau server produksi GCP dari Prometheus lokal di laptop mereka:

1. Buka file konfigurasi `prometheus.yml` di komputer lokal rekan Anda (misalnya di folder `C:\prometheus\prometheus.yml`).
2. Sesuaikan konfigurasi target scraping menjadi seperti berikut:
    ```yaml
    scrape_configs:
        - job_name: "gcp_presensi_produksi"
          metrics_path: "/metrics"
          scheme: https
          static_configs:
              - targets:
                    # MASUKKAN URL GCP CLOUD RUN TANPA AWALAN https://
                    - "presensi-alhafidz-xxxxxxxxxx-et.a.run.app"
                labels:
                    platform: "GCP_Production"
                    location: "Jakarta"
    ```
3. Restart aplikasi Prometheus di komputer rekan Anda:
    ```powershell
    cd C:\prometheus\prometheus-3.11.3.windows-amd64
    .\prometheus.exe --config.file=prometheus.yml
    ```
4. Buka Grafana lokal di browser (`http://localhost:3000`), masukkan dashboard metrik Laravel, dan pastikan visualisasi data dari server GCP produksi tampil sempurna.

---

### 6.4 Cara Membaca Log System di Cloud Run

Jika terjadi error (misalnya `500 Server Error` atau masalah konektivitas), Anda dapat membaca pesan kesalahan langsung melalui terminal Cloud Shell dengan mengetik:

```bash
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=presensi-alhafidz" \
    --limit=50 \
    --format="table(timestamp, textPayload)"
```

---

## 🛑 7. Langkah Pembersihan Resource (Teardown)

> [!WARNING]
> **PENTING:** Lakukan langkah pembersihan ini setelah masa demo, pengujian, atau penilaian Tugas Akhir selesai. Hal ini penting untuk menghentikan billing agar saldo akun GCP Anda tidak berkurang terus-menerus!

Jika Anda ingin menghapus seluruh resource secara bersih dan menyelamatkan tagihan billing, jalankan perintah-perintah berikut di Cloud Shell:

### 1. Ekspor Hasil Database Akhir (Cadangan Data Terakhir)

Sebelum menghapus database, amankan data absensi terbaru dengan mengekspornya ke bucket storage:

```bash
# Buat bucket backup final

gsutil mb -p project-876bbc01-98af-4d8d-9e1 -c standard -l asia-southeast2 gs://presensi-final-backup-876/

# Ekspor database ke bucket
gcloud sql export sql presensi-db-gcp gs://presensi-final-backup-876/backup_akhir_tugas_akhir.sql \
    --database=presensi_db1 \
    --project=project-876bbc01-98af-4d8d-9e1

# Download file backup dari Cloud Shell jika ingin disimpan di komputer lokal:
# gsutil cp gs://presensi-final-backup-876/backup_akhir_tugas_akhir.sql ./
```

### 2. Hapus Cloud Run Service

Hapus aplikasi web serverless presensi dari GCP:

```bash
gcloud run services delete presensi-alhafidz \
    --region=asia-southeast2 \
    --project=project-876bbc01-98af-4d8d-9e1 \
    --quiet
```

### 3. Hapus Instance Cloud SQL (MySQL)

Hapus instance database MySQL (komponen ini memakan biaya harian paling besar):

```bash
gcloud sql instances delete presensi-db-gcp \
    --project=project-876bbc01-98af-4d8d-9e1 \
    --quiet
```

### 4. Hapus Docker Image di Artifact Registry

Hapus kontainer image tersimpan yang memakan kuota storage registry:

```bash
gcloud artifacts repositories delete cloud-run-source-deploy \
    --location=asia-southeast2 \
    --project=project-876bbc01-98af-4d8d-9e1 \
    --quiet
```

### 5. Hapus Bucket Cloud Storage

Hapus bucket backup final yang dibuat pada langkah 1:

```bash
gsutil rm -r gs://presensi-final-backup-876/
```

### 💥 Opsi Alternatif: Hapus Total Project (Opsi Paling Bersih & Mudah)

Jika Anda tidak membutuhkan riwayat atau konfigurasi proyek GCP ini lagi untuk tugas lain, Anda bisa langsung menghapus Proyek GCP secara keseluruhan. Ini akan **otomatis menghapus semua resource** di dalamnya secara instan tanpa tersisa:

```bash
gcloud projects delete project-876bbc01-98af-4d8d-9e1 --quiet
```

---

## 🆘 8. Troubleshooting & Masalah Umum

### ❌ Error 1: `500 | Server Error` saat membuka website

- **Penyebab:** Umumnya dikarenakan aplikasi gagal terhubung ke database MySQL.
- **Solusi:**
    1. Pastikan IP address `DB_HOST` di Cloud Run terkonfigurasi dengan benar.
    2. Buka `deploy-gcp.sh`, pastikan password database (`DB_PASSWORD`) sama dengan yang dibuat saat menjalankan `setup-gcp.sh`.
    3. Cek log dengan perintah `gcloud logging read ...` (Langkah 6.4) untuk melihat detail error Laravel.

### ❌ Error 2: Koneksi database `Connection refused` atau `Access denied`

- **Penyebab:** Cloud SQL memblokir akses koneksi dari luar atau kredensial user salah.
- **Solusi:**
    - Pastikan script `deploy-gcp.sh` berhasil menjalankan perintah `gcloud sql instances patch presensi-db-gcp --authorized-networks=0.0.0.0/0`.
    - Parameter `--authorized-networks=0.0.0.0/0` wajib diset agar Cloud Run (yang memiliki IP dinamis) diperbolehkan mengakses database Cloud SQL.

### ❌ Error 3: Aset web (CSS/JS) rusak atau link menu mengarah ke localhost/AWS

- **Penyebab:** Variabel `APP_URL` di Cloud Run masih mengarah ke URL lama atau placeholder.
- **Solusi:** Jalankan perintah pada **Langkah 5.5** untuk memperbarui variabel `APP_URL` dengan alamat URL asli Cloud Run yang berakhiran `.run.app`.

---

_Dokumentasi ini disiapkan secara khusus untuk memudahkan kolaborasi tim pengembang dalam deployment Sistem Informasi Absensi SMK Al Hafidz._
