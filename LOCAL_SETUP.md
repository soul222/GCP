# 📚 Panduan Menjalankan Aplikasi Secara Lokal

> **Sistem Informasi Absensi — SMK Al Hafidz**  
> Dibangun dengan Laravel 12 + Filament v5

---

## 📖 Gambaran Umum Aplikasi

Aplikasi ini adalah **Sistem Informasi Absensi** berbasis web untuk **SMK Al Hafidz**. Aplikasi memiliki **3 panel terpisah** yang diakses berdasarkan role pengguna:

| Panel | URL | Role | Fungsi |
|-------|-----|------|--------|
| **Admin** | `/admin` | `admin` | Manajemen master data (Guru, Siswa, Kelas, Jurusan, Mapel, Jadwal) |
| **Guru** | `/guru` | `guru` | Membuka/menutup sesi presensi, melihat rekap absensi kelas |
| **Siswa** | `/siswa` | `siswa` | Mengisi presensi & melihat rekap absensi pribadi |

**Stack Teknologi:**
- **Backend:** Laravel 12, PHP 8.2+
- **Admin UI:** Filament v5 (multi-panel)
- **Frontend:** Vite 7, TailwindCSS 3, AlpineJS
- **Database:** MySQL
- **Session/Queue/Cache:** Database driver

---

## ✅ Prasyarat (Prerequisites)

Pastikan semua software berikut sudah terinstal di komputer Anda sebelum memulai:

| Software | Versi Minimum | Cek Versi |
|----------|--------------|-----------|
| **PHP** | 8.2+ | `php -v` |
| **Composer** | 2.x | `composer -V` |
| **Node.js** | 18+ | `node -v` |
| **NPM** | 9+ | `npm -v` |
| **MySQL** | 8.0+ | `mysql --version` |
| **Git** | Terbaru | `git --version` |

> **💡 Rekomendasi:** Gunakan [XAMPP](https://www.apachefriends.org/) atau [Laragon](https://laragon.org/) untuk MySQL di Windows agar lebih mudah.

---

## 🚀 Langkah Instalasi

### Step 1 — Clone / Download Project

Jika menggunakan Git, clone repository:
```bash
git clone <URL_REPOSITORY> .
```

Atau ekstrak file ZIP project ke folder yang diinginkan, lalu buka terminal di dalam folder tersebut.

---

### Step 2 — Salin File Environment

Buat file `.env` dari template yang sudah tersedia:

```bash
cp .env.example .env
```

> **Windows (Command Prompt):**
> ```cmd
> copy .env.example .env
> ```

---

### Step 3 — Konfigurasi File `.env`

Buka file `.env` dan sesuaikan konfigurasi database:

```env
APP_NAME="Absensi SMK Al Hafidz"
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost:8000

# ── Konfigurasi Database ──────────────────────
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=absensi_smk      # ← ganti sesuai nama database yang akan dibuat
DB_USERNAME=root             # ← ganti sesuai username MySQL Anda
DB_PASSWORD=                 # ← isi password MySQL Anda (kosong jika tidak ada)

# ── Session, Queue, Cache pakai database ─────
SESSION_DRIVER=database
QUEUE_CONNECTION=database
CACHE_STORE=database
```

> **⚠️ Penting:** Pastikan MySQL sudah **berjalan** sebelum melanjutkan ke step berikutnya.

---

### Step 4 — Buat Database MySQL

Masuk ke MySQL dan buat database baru:

```bash
mysql -u root -p
```

Setelah masuk ke MySQL shell, jalankan:
```sql
CREATE DATABASE absensi_smk CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
EXIT;
```

> Sesuaikan nama `absensi_smk` dengan nilai `DB_DATABASE` di file `.env` Anda.

---

### Step 5 — Install PHP Dependencies

```bash
composer install
```

Proses ini akan mengunduh semua package Laravel, Filament, dan dependency PHP lainnya ke folder `vendor/`.

---

### Step 6 — Generate Application Key

```bash
php artisan key:generate
```

Perintah ini akan mengisi `APP_KEY` di file `.env` secara otomatis.

---

### Step 7 — Jalankan Migrasi Database

Perintah ini akan membuat semua tabel di database:

```bash
php artisan migrate
```

Tabel yang akan terbuat (16 migration):

| Tabel | Keterangan |
|-------|-----------|
| `users` | Data semua pengguna (admin, guru, siswa) |
| `kelas` | Data kelas |
| `jurusans` | Data jurusan |
| `mapels` | Data mata pelajaran |
| `jadwals` | Jadwal pelajaran per kelas |
| `presensi_sesis` | Sesi absensi yang dibuka guru |
| `presensi_details` | Record absensi per siswa |
| `sessions` | Sesi login pengguna |
| `jobs` | Queue jobs |
| `cache` | Cache aplikasi |

> **Jika ada error foreign key**, coba:
> ```bash
> php artisan migrate:fresh
> ```

---

### Step 8 — Install Node.js Dependencies

```bash
npm install
```

---

### Step 9 — Build atau Jalankan Asset Frontend

**Untuk development (dengan hot reload):**
```bash
npm run dev
```
Biarkan terminal ini tetap berjalan.

**Untuk production build (sekali build, tanpa dev server):**
```bash
npm run build
```

---

### Step 10 — Jalankan Laravel Development Server

Buka terminal **baru** (jika menggunakan `npm run dev`), lalu jalankan:

```bash
php artisan serve
```

Aplikasi akan berjalan di: **http://localhost:8000**

---

## ⚡ Cara Cepat: Jalankan Semua Sekaligus

Setelah semua konfigurasi selesai, Anda bisa menjalankan semua service (server + queue + log watcher + vite) **dalam satu perintah**:

```bash
composer dev
```

Perintah ini menjalankan secara bersamaan:
- `php artisan serve` — Laravel dev server
- `php artisan queue:listen` — Queue worker
- `php artisan pail` — Log watcher real-time
- `npm run dev` — Vite HMR

---

## 👤 Membuat Akun Admin Pertama

Setelah migrasi selesai, **belum ada akun** di database. Buat akun admin pertama menggunakan Tinker:

```bash
php artisan tinker
```

Di dalam Tinker, jalankan perintah berikut:

```php
// Buat akun Admin
App\Models\User::create([
    'name'     => 'Administrator',
    'email'    => 'admin@smkalfhafidz.sch.id',
    'username' => 'admin',
    'password' => bcrypt('password123'),
    'role'     => 'admin',
]);
```

Untuk membuat akun Guru:
```php
App\Models\User::create([
    'name'     => 'Budi Santoso',
    'email'    => 'budi@smkalfhafidz.sch.id',
    'username' => 'budi.guru',
    'password' => bcrypt('password123'),
    'role'     => 'guru',
]);
```

Untuk membuat akun Siswa:
```php
App\Models\User::create([
    'name'      => 'Ani Siswa',
    'email'     => null,
    'username'  => 'ani.siswa',
    'nis'       => '20240001',
    'password'  => bcrypt('password123'),
    'role'      => 'siswa',
    'is_active' => true,
]);
```

Keluar dari Tinker:
```php
exit
```

---

## 🌐 Cara Mengakses Panel Aplikasi

Buka browser dan akses URL berikut setelah server berjalan di `http://localhost:8000`:

### 🔵 Panel Admin
```
http://localhost:8000/admin
```
- Login menggunakan akun dengan `role = admin`
- Fitur: Kelola Guru, Siswa, Kelas, Jurusan, Mata Pelajaran, Jadwal

### 🟢 Panel Guru
```
http://localhost:8000/guru
```
- Login melalui halaman utama (`/login`), lalu otomatis redirect ke `/guru`
- Fitur: Buka/tutup sesi presensi, lihat rekap absensi, rekap wali kelas

### 🟡 Panel Siswa
```
http://localhost:8000/siswa
```
- Login melalui halaman utama (`/login`), lalu otomatis redirect ke `/siswa`
- Fitur: Isi presensi, lihat rekap absensi pribadi
- **Catatan:** Siswa harus memiliki `is_active = true` untuk bisa mengakses panel

### 🏠 Halaman Utama & Login
```
http://localhost:8000/         ← Halaman welcome
http://localhost:8000/login    ← Halaman login (Guru & Siswa)
http://localhost:8000/dashboard ← Auto-redirect berdasarkan role
```

---

## 🔄 Menjalankan Queue Worker (Opsional)

Karena aplikasi menggunakan `QUEUE_CONNECTION=database`, jalankan queue worker agar background jobs dapat diproses:

```bash
php artisan queue:listen --tries=1 --timeout=0
```

Atau untuk mode lebih ringan:
```bash
php artisan queue:work
```

---

## 🛠️ Troubleshooting

### ❌ Error: `SQLSTATE[HY000] [1045] Access denied for user`
**Penyebab:** Username/password MySQL salah di `.env`.  
**Solusi:** Periksa kembali `DB_USERNAME` dan `DB_PASSWORD` di file `.env`.

---

### ❌ Error: `SQLSTATE[HY000] [2002] Connection refused`
**Penyebab:** MySQL tidak berjalan.  
**Solusi:** Jalankan MySQL service. Di XAMPP: klik tombol **Start** pada MySQL. Di Laragon: klik **Start All**.

---

### ❌ Error: `The stream or file ... could not be opened: Permission denied`
**Penyebab:** Folder `storage` tidak memiliki izin tulis.  
**Solusi:**
```bash
# Linux/Mac:
chmod -R 775 storage bootstrap/cache

# Windows: klik kanan folder storage → Properties → Security → Edit → beri Full Control
```

---

### ❌ Error: `php_network_getaddresses: getaddrinfo failed`
**Penyebab:** `DB_HOST` tidak dapat ditemukan.  
**Solusi:** Pastikan `DB_HOST=127.0.0.1` (bukan `localhost`) di `.env`.

---

### ❌ Tampilan rusak / CSS tidak muncul
**Penyebab:** Asset belum di-build atau Vite dev server tidak berjalan.  
**Solusi:**
```bash
npm run build
# atau jalankan:
npm run dev
```

---

### ❌ Error: `No application encryption key has been specified`
**Penyebab:** `APP_KEY` kosong di `.env`.  
**Solusi:**
```bash
php artisan key:generate
```

---

### ❌ Error Filament: `Target class [filament.auth.login] does not exist`
**Penyebab:** Cache konfigurasi lama.  
**Solusi:**
```bash
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear
```

---

### ❌ Siswa tidak bisa login / akses panel `/siswa`
**Penyebab:** Field `is_active` bernilai `false` atau `null`.  
**Solusi:** Update via Tinker:
```php
App\Models\User::where('role', 'siswa')->update(['is_active' => true]);
```

---

## 📋 Cheatsheet Perintah Berguna

```bash
# ── Setup Awal ──────────────────────────────────────────
composer install                    # Install PHP dependencies
npm install                         # Install Node dependencies
php artisan key:generate            # Generate APP_KEY
php artisan migrate                 # Jalankan semua migrasi
php artisan migrate:fresh           # Drop semua tabel, migrasi ulang
php artisan migrate:fresh --seed    # Reset DB + jalankan seeder
php artisan db:seed                 # Jalankan seeder tanpa reset

# ── Menjalankan Aplikasi ────────────────────────────────
composer dev                        # Semua service sekaligus (RECOMMENDED)
php artisan serve                   # Laravel dev server saja
npm run dev                         # Vite dev server saja (HMR)
npm run build                       # Build asset untuk production

# ── Queue & Background Jobs ─────────────────────────────
php artisan queue:listen --tries=1  # Jalankan queue listener
php artisan queue:work              # Jalankan queue worker
php artisan queue:failed            # Lihat failed jobs

# ── Cache & Config ──────────────────────────────────────
php artisan config:clear            # Clear cache konfigurasi
php artisan cache:clear             # Clear cache aplikasi
php artisan route:clear             # Clear cache route
php artisan view:clear              # Clear cache view
php artisan optimize:clear          # Clear semua cache sekaligus

# ── Debugging ───────────────────────────────────────────
php artisan tinker                  # Masuk ke REPL interaktif
php artisan pail                    # Lihat log real-time
php artisan route:list              # Lihat semua route terdaftar
php artisan about                   # Info versi & konfigurasi aplikasi
```

---

## 📂 Struktur Direktori Utama

```
tugas-akhir/
├── app/
│   ├── Filament/
│   │   ├── Resources/         ← Admin panel resources
│   │   ├── Guru/              ← Guru panel pages & resources
│   │   └── Siswa/             ← Siswa panel pages & resources
│   ├── Http/Controllers/      ← Controller standard Laravel
│   ├── Models/                ← Eloquent models (User, Kelas, Jadwal, dll)
│   └── Providers/Filament/    ← Konfigurasi panel Admin, Guru, Siswa
├── database/
│   ├── migrations/            ← 16 file migrasi tabel
│   └── seeders/               ← DatabaseSeeder
├── resources/
│   ├── css/                   ← Style TailwindCSS
│   ├── js/                    ← AlpineJS & Axios
│   └── views/                 ← Blade templates
├── routes/
│   ├── web.php                ← Route utama (/, /dashboard, /profile)
│   └── auth.php               ← Route autentikasi Breeze
├── .env                       ← Konfigurasi environment (JANGAN di-commit)
├── .env.example               ← Template environment
├── composer.json              ← PHP dependencies
└── package.json               ← Node dependencies
```

---

## 📊 Diagram Alur Login

```
Pengguna buka /login
        │
        ▼
  Input Kredensial
        │
        ▼
   Autentikasi ──GAGAL──→ Kembali ke /login (error message)
        │
      SUKSES
        │
        ▼
  /dashboard (redirect otomatis)
        │
   ┌────┴──────────────┐
   │                   │
role=admin          role=guru         role=siswa
   │                   │                  │
   ▼                   ▼                  ▼
/admin             /guru              /siswa
                                   (jika is_active=true)
```

---

> 📅 Dokumen ini dibuat pada: **12 Mei 2026**  
> 🔄 Versi Aplikasi: **Laravel 12 + Filament v5**
