-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               8.4.3 - MySQL Community Server - GPL
-- Server OS:                    Win64
-- HeidiSQL Version:             12.8.0.6908
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for absensi_smk_alhafidz
DROP DATABASE IF EXISTS `absensi_smk_alhafidz`;
CREATE DATABASE IF NOT EXISTS `absensi_smk_alhafidz` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `absensi_smk_alhafidz`;

-- Dumping structure for table absensi_smk_alhafidz.cache
DROP TABLE IF EXISTS `cache`;
CREATE TABLE IF NOT EXISTS `cache` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table absensi_smk_alhafidz.cache: ~0 rows (approximately)

-- Dumping structure for table absensi_smk_alhafidz.cache_locks
DROP TABLE IF EXISTS `cache_locks`;
CREATE TABLE IF NOT EXISTS `cache_locks` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_locks_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table absensi_smk_alhafidz.cache_locks: ~0 rows (approximately)

-- Dumping structure for table absensi_smk_alhafidz.failed_jobs
DROP TABLE IF EXISTS `failed_jobs`;
CREATE TABLE IF NOT EXISTS `failed_jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table absensi_smk_alhafidz.failed_jobs: ~0 rows (approximately)

-- Dumping structure for table absensi_smk_alhafidz.jadwals
DROP TABLE IF EXISTS `jadwals`;
CREATE TABLE IF NOT EXISTS `jadwals` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `kelas_id` bigint unsigned NOT NULL,
  `mapel_id` bigint unsigned NOT NULL,
  `guru_id` bigint unsigned NOT NULL,
  `hari` enum('senin','selasa','rabu','kamis','jumat','sabtu') COLLATE utf8mb4_unicode_ci NOT NULL,
  `jam_ke` tinyint unsigned NOT NULL,
  `aktif` tinyint(1) NOT NULL DEFAULT '1',
  `berlaku_dari` date DEFAULT NULL,
  `berlaku_sampai` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `semester_akademik_id` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `jadwals_kelas_id_hari_jam_ke_unique` (`kelas_id`,`hari`,`jam_ke`),
  KEY `jadwals_mapel_id_foreign` (`mapel_id`),
  KEY `jadwals_guru_id_foreign` (`guru_id`),
  KEY `jadwals_semester_akademik_id_foreign` (`semester_akademik_id`),
  CONSTRAINT `jadwals_guru_id_foreign` FOREIGN KEY (`guru_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `jadwals_kelas_id_foreign` FOREIGN KEY (`kelas_id`) REFERENCES `kelas` (`id`) ON DELETE CASCADE,
  CONSTRAINT `jadwals_mapel_id_foreign` FOREIGN KEY (`mapel_id`) REFERENCES `mapels` (`id`) ON DELETE CASCADE,
  CONSTRAINT `jadwals_semester_akademik_id_foreign` FOREIGN KEY (`semester_akademik_id`) REFERENCES `semester_akademiks` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table absensi_smk_alhafidz.jadwals: ~1 rows (approximately)
REPLACE INTO `jadwals` (`id`, `kelas_id`, `mapel_id`, `guru_id`, `hari`, `jam_ke`, `aktif`, `berlaku_dari`, `berlaku_sampai`, `created_at`, `updated_at`, `semester_akademik_id`) VALUES
	(26, 22, 30, 2, 'senin', 1, 1, '2026-01-01', '2026-06-30', '2026-05-09 07:39:56', '2026-05-09 07:39:56', 1);

-- Dumping structure for table absensi_smk_alhafidz.jobs
DROP TABLE IF EXISTS `jobs`;
CREATE TABLE IF NOT EXISTS `jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` tinyint unsigned NOT NULL,
  `reserved_at` int unsigned DEFAULT NULL,
  `available_at` int unsigned NOT NULL,
  `created_at` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table absensi_smk_alhafidz.jobs: ~0 rows (approximately)

-- Dumping structure for table absensi_smk_alhafidz.job_batches
DROP TABLE IF EXISTS `job_batches`;
CREATE TABLE IF NOT EXISTS `job_batches` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext COLLATE utf8mb4_unicode_ci,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table absensi_smk_alhafidz.job_batches: ~0 rows (approximately)

-- Dumping structure for table absensi_smk_alhafidz.jurusans
DROP TABLE IF EXISTS `jurusans`;
CREATE TABLE IF NOT EXISTS `jurusans` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `nama` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `singkatan` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `aktif` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `jurusans_nama_unique` (`nama`),
  UNIQUE KEY `jurusans_singkatan_unique` (`singkatan`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table absensi_smk_alhafidz.jurusans: ~2 rows (approximately)
REPLACE INTO `jurusans` (`id`, `nama`, `singkatan`, `aktif`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(1, 'Pengembangan Perangkat Lunak dan Gim', 'PPLG', 1, '2026-04-19 03:18:00', '2026-04-19 03:18:00', NULL),
	(2, 'Manajemen Perkantoran dan Layanan Bisnis', 'MPLB', 1, '2026-04-19 03:18:00', '2026-04-19 03:18:00', NULL);

-- Dumping structure for table absensi_smk_alhafidz.kalender_akademiks
DROP TABLE IF EXISTS `kalender_akademiks`;
CREATE TABLE IF NOT EXISTS `kalender_akademiks` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `starts_at` date NOT NULL,
  `ends_at` date DEFAULT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'lainnya',
  `is_holiday` tinyint(1) NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table absensi_smk_alhafidz.kalender_akademiks: ~3 rows (approximately)
REPLACE INTO `kalender_akademiks` (`id`, `name`, `starts_at`, `ends_at`, `type`, `is_holiday`, `is_active`, `notes`, `created_at`, `updated_at`) VALUES
	(1, 'Hari Buruh Internasional', '2026-05-25', '2026-05-25', 'libur_nasional', 1, 1, NULL, '2026-05-12 08:18:05', '2026-05-14 07:55:46'),
	(2, 'malas', '2026-05-18', '2026-05-18', 'lainnya', 1, 1, NULL, '2026-05-14 06:55:21', '2026-05-14 07:07:48'),
	(3, 'malassss', '2026-05-11', '2026-05-11', 'lainnya', 0, 1, NULL, '2026-05-14 07:24:24', '2026-05-14 07:24:24');

-- Dumping structure for table absensi_smk_alhafidz.kelas
DROP TABLE IF EXISTS `kelas`;
CREATE TABLE IF NOT EXISTS `kelas` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tingkat` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tingkat_angka` int DEFAULT NULL,
  `jurusan` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nomor` tinyint unsigned NOT NULL,
  `nama` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `aktif` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `next_kelas_id` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `kelas_nama_unique` (`nama`),
  KEY `kelas_tingkat_jurusan_index` (`tingkat`,`jurusan`),
  KEY `kelas_next_kelas_id_foreign` (`next_kelas_id`),
  CONSTRAINT `kelas_next_kelas_id_foreign` FOREIGN KEY (`next_kelas_id`) REFERENCES `kelas` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table absensi_smk_alhafidz.kelas: ~18 rows (approximately)
REPLACE INTO `kelas` (`id`, `tingkat`, `tingkat_angka`, `jurusan`, `nomor`, `nama`, `aktif`, `created_at`, `updated_at`, `deleted_at`, `next_kelas_id`) VALUES
	(3, 'X', 10, 'PPLG', 1, 'X PPLG 1', 1, '2026-02-26 01:53:19', '2026-05-06 16:18:07', NULL, 9),
	(4, 'X', 10, 'PPLG', 2, 'X PPLG 2', 1, '2026-02-28 00:55:59', '2026-05-06 16:18:07', NULL, 10),
	(9, 'XI', 11, 'PPLG', 1, 'XI PPLG 1', 1, '2026-02-28 00:57:29', '2026-05-06 16:18:07', NULL, 15),
	(10, 'XI', 11, 'PPLG', 2, 'XI PPLG 2', 1, '2026-02-28 00:57:45', '2026-05-06 16:18:07', NULL, 16),
	(12, 'XI', 11, 'MPLB', 1, 'XI MPLB 1', 1, '2026-02-28 00:58:22', '2026-05-06 16:18:07', NULL, 18),
	(13, 'XI', 11, 'MPLB', 2, 'XI MPLB 2', 1, '2026-02-28 00:58:39', '2026-05-06 16:18:07', NULL, 19),
	(14, 'XI', 11, 'MPLB', 3, 'XI MPLB 3', 1, '2026-02-28 00:58:55', '2026-05-06 16:18:07', NULL, 20),
	(15, 'XII', 12, 'PPLG', 1, 'XII PPLG 1', 1, '2026-02-28 00:59:14', '2026-02-28 00:59:14', NULL, NULL),
	(16, 'XII', 12, 'PPLG', 2, 'XII PPLG 2', 1, '2026-02-28 00:59:36', '2026-02-28 00:59:36', NULL, NULL),
	(17, 'XII', 12, 'PPLG', 3, 'XII PPLG 3', 1, '2026-02-28 01:01:09', '2026-02-28 01:01:09', NULL, NULL),
	(18, 'XII', 12, 'MPLB', 1, 'XII MPLB 1', 1, '2026-02-28 01:01:25', '2026-02-28 01:01:25', NULL, NULL),
	(19, 'XII', 12, 'MPLB', 2, 'XII MPLB 2', 1, '2026-02-28 01:01:41', '2026-02-28 01:01:41', NULL, NULL),
	(20, 'XII', 12, 'MPLB', 3, 'XII MPLB 3', 1, '2026-02-28 01:01:59', '2026-02-28 01:01:59', NULL, NULL),
	(22, 'X', 10, 'MPLB', 1, 'X MPLB 1', 1, '2026-03-05 02:51:04', '2026-05-06 16:18:07', NULL, 12),
	(23, 'X', 10, 'MPLB', 2, 'X MPLB 2', 1, '2026-03-05 02:51:24', '2026-05-06 16:18:07', NULL, 13),
	(24, 'X', 10, 'MPLB', 3, 'X MPLB 3', 1, '2026-03-05 02:57:23', '2026-05-06 16:18:07', NULL, 14),
	(26, 'XI', 11, 'MPLB', 4, 'XI MPLB 4', 1, '2026-03-09 15:37:51', '2026-03-09 15:37:51', NULL, NULL),
	(28, 'X', 10, 'PPLG', 3, 'X PPLG 3', 1, '2026-04-02 04:58:19', '2026-04-02 04:58:19', NULL, NULL);

-- Dumping structure for table absensi_smk_alhafidz.mapels
DROP TABLE IF EXISTS `mapels`;
CREATE TABLE IF NOT EXISTS `mapels` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `nama` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `kode` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `aktif` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mapels_nama_unique` (`nama`),
  UNIQUE KEY `mapels_kode_unique` (`kode`)
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table absensi_smk_alhafidz.mapels: ~20 rows (approximately)
REPLACE INTO `mapels` (`id`, `nama`, `kode`, `aktif`, `created_at`, `updated_at`) VALUES
	(16, 'Bahasa Indonesia', 'B.INDO', 1, '2026-03-05 01:42:05', '2026-03-05 01:45:10'),
	(20, 'Bimbingan Konseling', 'BK', 1, '2026-03-05 01:46:07', '2026-03-05 01:46:07'),
	(21, 'BTQ', 'BTQ', 1, '2026-03-05 01:46:26', '2026-03-05 01:46:26'),
	(26, 'Jaringan Komputer', 'JARKOM', 1, '2026-03-05 01:48:33', '2026-03-05 01:48:33'),
	(29, 'KTK', 'KTK', 1, '2026-03-05 01:49:53', '2026-03-05 01:49:53'),
	(30, 'Matematika', 'MTK', 1, '2026-03-05 01:50:12', '2026-03-05 01:50:12'),
	(31, 'Praktikum Web', 'P WEB', 1, '2026-03-05 01:50:50', '2026-03-05 01:50:50'),
	(32, 'Pendidikan Agama Islam', 'PAI', 1, '2026-03-05 01:51:15', '2026-03-05 01:51:15'),
	(35, 'Pendidikan Kewarganegaraan', 'PKN', 1, '2026-03-05 01:52:17', '2026-03-05 01:52:17'),
	(36, 'Pendidikan Jasmani, Olahraga, dan Kesehatan', 'PJOK', 1, '2026-03-05 01:52:49', '2026-03-05 01:52:49'),
	(37, 'PKK', 'PKK', 1, '2026-03-05 01:53:23', '2026-03-05 01:53:23'),
	(38, 'PPL', 'PPL', 1, '2026-03-05 01:53:37', '2026-03-05 01:53:37'),
	(39, 'PRP', 'PRP', 1, '2026-03-05 01:53:54', '2026-03-05 01:53:54'),
	(40, 'PROTER', 'PROTER', 1, '2026-03-05 01:54:11', '2026-03-05 01:54:11'),
	(41, 'Seni Budaya dan Keterampilan', 'SBK', 1, '2026-03-05 01:54:36', '2026-03-05 01:54:36'),
	(42, 'Sejarah', 'SEJARAH', 1, '2026-03-05 01:54:55', '2026-03-05 01:54:55'),
	(43, 'Sistem Komunikasi', 'SISKOM', 1, '2026-03-05 01:55:14', '2026-03-05 01:55:14'),
	(44, 'TP', 'TP', 1, '2026-03-05 01:55:32', '2026-03-05 01:55:32'),
	(45, 'WDK- MP', 'WDK-MP', 1, '2026-03-05 01:56:39', '2026-03-05 01:56:39'),
	(46, 'WDK- MLB', 'WDK-MLB', 1, '2026-03-05 01:57:09', '2026-03-05 01:57:09');

-- Dumping structure for table absensi_smk_alhafidz.migrations
DROP TABLE IF EXISTS `migrations`;
CREATE TABLE IF NOT EXISTS `migrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table absensi_smk_alhafidz.migrations: ~24 rows (approximately)
REPLACE INTO `migrations` (`id`, `migration`, `batch`) VALUES
	(1, '0001_01_01_000000_create_users_table', 1),
	(2, '0001_01_01_000001_create_cache_table', 1),
	(3, '0001_01_01_000002_create_jobs_table', 1),
	(4, '2026_02_24_082312_add_role_username_nis_to_users_table', 2),
	(5, '2026_02_26_064804_create_kelas_table', 3),
	(6, '2026_02_27_080141_add_wali_kelas_id_to_users_table', 4),
	(7, '2026_02_28_072711_make_email_nullable_in_users_table', 5),
	(8, '2026_02_28_073943_add_kelas_id_to_users_table', 6),
	(9, '2026_02_28_132044_create_mapels_table', 7),
	(10, '2026_02_28_225054_create_jadwals_table', 8),
	(11, '2026_02_28_232254_create_presensi_sesis_table', 9),
	(12, '2026_02_28_232311_create_presensi_details_table', 9),
	(13, '2026_03_06_071807_add_masa_berlaku_to_jadwals_table', 10),
	(14, '2026_04_19_100339_create_jurusans_table', 11),
	(15, '2026_04_24_071235_add_is_active_to_users_table', 12),
	(16, '2026_04_24_080246_add_keterangan_nonaktif_to_users_table', 13),
	(17, '2026_05_06_222805_buat_tabel_tahun_ajaran', 14),
	(18, '2026_05_06_222836_buat_tabel_semester_akademik', 14),
	(19, '2026_05_06_222915_buat_tabel_riwayat_kelas_siswa', 14),
	(20, '2026_05_06_222938_tambah_semester_ke_jadwal_pelajaran', 14),
	(21, '2026_05_06_223001_tambah_tingkat_dan_kelas_tujuan_ke_kelas', 14),
	(22, '2026_05_06_223022_isi_default_tahun_ajaran_semester_dan_backfill_jadwal', 14),
	(23, '2026_05_07_001244_buat_tabel_kalender_akademik', 15),
	(24, '2026_05_07_014007_rapikan_nama_tabel_dan_kolom_akademik_ke_indonesia', 16);

-- Dumping structure for table absensi_smk_alhafidz.password_reset_tokens
DROP TABLE IF EXISTS `password_reset_tokens`;
CREATE TABLE IF NOT EXISTS `password_reset_tokens` (
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table absensi_smk_alhafidz.password_reset_tokens: ~0 rows (approximately)

-- Dumping structure for table absensi_smk_alhafidz.presensi_details
DROP TABLE IF EXISTS `presensi_details`;
CREATE TABLE IF NOT EXISTS `presensi_details` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `presensi_sesi_id` bigint unsigned NOT NULL,
  `siswa_id` bigint unsigned NOT NULL,
  `status` enum('hadir','izin','sakit','alfa') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'alfa',
  `keterangan` text COLLATE utf8mb4_unicode_ci,
  `metode` enum('siswa','guru') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'siswa',
  `waktu_isi` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `presensi_details_presensi_sesi_id_siswa_id_unique` (`presensi_sesi_id`,`siswa_id`),
  KEY `presensi_details_siswa_id_foreign` (`siswa_id`),
  CONSTRAINT `presensi_details_presensi_sesi_id_foreign` FOREIGN KEY (`presensi_sesi_id`) REFERENCES `presensi_sesis` (`id`) ON DELETE CASCADE,
  CONSTRAINT `presensi_details_siswa_id_foreign` FOREIGN KEY (`siswa_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=304 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table absensi_smk_alhafidz.presensi_details: ~29 rows (approximately)
REPLACE INTO `presensi_details` (`id`, `presensi_sesi_id`, `siswa_id`, `status`, `keterangan`, `metode`, `waktu_isi`, `created_at`, `updated_at`) VALUES
	(275, 211, 25, 'alfa', NULL, 'guru', NULL, '2026-05-09 07:42:01', '2026-05-09 07:42:01'),
	(276, 211, 30, 'alfa', NULL, 'guru', NULL, '2026-05-09 07:42:01', '2026-05-09 07:42:01'),
	(277, 230, 25, 'alfa', NULL, 'guru', NULL, '2026-05-14 06:58:25', '2026-05-14 06:58:25'),
	(278, 230, 30, 'alfa', NULL, 'guru', NULL, '2026-05-14 06:58:25', '2026-05-14 06:58:25'),
	(279, 230, 35, 'alfa', NULL, 'guru', NULL, '2026-05-14 06:58:25', '2026-05-14 06:58:25'),
	(280, 212, 25, 'alfa', NULL, 'guru', NULL, '2026-05-14 07:13:29', '2026-05-14 07:13:29'),
	(281, 213, 25, 'alfa', NULL, 'guru', NULL, '2026-05-14 07:13:29', '2026-05-14 07:13:29'),
	(282, 214, 25, 'alfa', NULL, 'guru', NULL, '2026-05-14 07:13:29', '2026-05-14 07:13:29'),
	(283, 215, 25, 'alfa', NULL, 'guru', NULL, '2026-05-14 07:13:29', '2026-05-14 07:13:29'),
	(284, 216, 25, 'alfa', NULL, 'guru', NULL, '2026-05-14 07:13:29', '2026-05-14 07:13:29'),
	(285, 217, 25, 'alfa', NULL, 'guru', NULL, '2026-05-14 07:13:30', '2026-05-14 07:13:30'),
	(286, 218, 25, 'alfa', NULL, 'guru', NULL, '2026-05-14 07:13:30', '2026-05-14 07:13:30'),
	(287, 219, 25, 'alfa', NULL, 'guru', NULL, '2026-05-14 07:13:30', '2026-05-14 07:13:30'),
	(288, 220, 25, 'alfa', NULL, 'guru', NULL, '2026-05-14 07:13:30', '2026-05-14 07:13:30'),
	(289, 221, 25, 'alfa', NULL, 'guru', NULL, '2026-05-14 07:13:30', '2026-05-14 07:13:30'),
	(290, 222, 25, 'alfa', NULL, 'guru', NULL, '2026-05-14 07:13:30', '2026-05-14 07:13:30'),
	(291, 223, 25, 'alfa', NULL, 'guru', NULL, '2026-05-14 07:13:30', '2026-05-14 07:13:30'),
	(292, 224, 25, 'alfa', NULL, 'guru', NULL, '2026-05-14 07:13:30', '2026-05-14 07:13:30'),
	(293, 225, 25, 'alfa', NULL, 'guru', NULL, '2026-05-14 07:13:30', '2026-05-14 07:13:30'),
	(294, 226, 25, 'alfa', NULL, 'guru', NULL, '2026-05-14 07:13:30', '2026-05-14 07:13:30'),
	(295, 227, 25, 'alfa', NULL, 'guru', NULL, '2026-05-14 07:13:31', '2026-05-14 07:13:31'),
	(296, 228, 25, 'alfa', NULL, 'guru', NULL, '2026-05-14 07:13:31', '2026-05-14 07:13:31'),
	(297, 229, 25, 'alfa', NULL, 'guru', NULL, '2026-05-14 07:13:31', '2026-05-14 07:13:31'),
	(298, 231, 25, 'alfa', NULL, 'guru', NULL, '2026-05-14 07:13:31', '2026-05-14 07:13:31'),
	(299, 232, 25, 'alfa', NULL, 'guru', NULL, '2026-05-14 07:13:31', '2026-05-14 07:13:31'),
	(300, 233, 25, 'alfa', NULL, 'guru', NULL, '2026-05-14 07:13:31', '2026-05-14 07:13:31'),
	(301, 234, 25, 'alfa', NULL, 'guru', NULL, '2026-05-14 07:13:31', '2026-05-14 07:13:31'),
	(302, 235, 25, 'alfa', NULL, 'guru', NULL, '2026-05-14 07:13:31', '2026-05-14 07:13:31'),
	(303, 236, 25, 'alfa', NULL, 'guru', NULL, '2026-05-14 07:13:31', '2026-05-14 07:13:31');

-- Dumping structure for table absensi_smk_alhafidz.presensi_sesis
DROP TABLE IF EXISTS `presensi_sesis`;
CREATE TABLE IF NOT EXISTS `presensi_sesis` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `jadwal_id` bigint unsigned NOT NULL,
  `tanggal` date NOT NULL,
  `status` enum('draft','open','closed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'draft',
  `dibuka_pada` datetime DEFAULT NULL,
  `dibuka_oleh` bigint unsigned DEFAULT NULL,
  `ditutup_pada` datetime DEFAULT NULL,
  `ditutup_oleh` bigint unsigned DEFAULT NULL,
  `catatan` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `presensi_sesis_jadwal_id_tanggal_unique` (`jadwal_id`,`tanggal`),
  KEY `presensi_sesis_dibuka_oleh_foreign` (`dibuka_oleh`),
  KEY `presensi_sesis_ditutup_oleh_foreign` (`ditutup_oleh`),
  CONSTRAINT `presensi_sesis_dibuka_oleh_foreign` FOREIGN KEY (`dibuka_oleh`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `presensi_sesis_ditutup_oleh_foreign` FOREIGN KEY (`ditutup_oleh`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `presensi_sesis_jadwal_id_foreign` FOREIGN KEY (`jadwal_id`) REFERENCES `jadwals` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=237 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table absensi_smk_alhafidz.presensi_sesis: ~26 rows (approximately)
REPLACE INTO `presensi_sesis` (`id`, `jadwal_id`, `tanggal`, `status`, `dibuka_pada`, `dibuka_oleh`, `ditutup_pada`, `ditutup_oleh`, `catatan`, `created_at`, `updated_at`) VALUES
	(211, 26, '2026-01-05', 'draft', NULL, NULL, NULL, NULL, NULL, '2026-05-09 07:41:45', '2026-05-09 07:41:45'),
	(212, 26, '2026-01-12', 'draft', NULL, NULL, NULL, NULL, NULL, '2026-05-09 07:41:45', '2026-05-09 07:41:45'),
	(213, 26, '2026-01-19', 'draft', NULL, NULL, NULL, NULL, NULL, '2026-05-09 07:41:45', '2026-05-09 07:41:45'),
	(214, 26, '2026-01-26', 'draft', NULL, NULL, NULL, NULL, NULL, '2026-05-09 07:41:45', '2026-05-09 07:41:45'),
	(215, 26, '2026-02-02', 'draft', NULL, NULL, NULL, NULL, NULL, '2026-05-09 07:41:45', '2026-05-09 07:41:45'),
	(216, 26, '2026-02-09', 'draft', NULL, NULL, NULL, NULL, NULL, '2026-05-09 07:41:45', '2026-05-09 07:41:45'),
	(217, 26, '2026-02-16', 'draft', NULL, NULL, NULL, NULL, NULL, '2026-05-09 07:41:45', '2026-05-09 07:41:45'),
	(218, 26, '2026-02-23', 'draft', NULL, NULL, NULL, NULL, NULL, '2026-05-09 07:41:45', '2026-05-09 07:41:45'),
	(219, 26, '2026-03-02', 'draft', NULL, NULL, NULL, NULL, NULL, '2026-05-09 07:41:45', '2026-05-09 07:41:45'),
	(220, 26, '2026-03-09', 'draft', NULL, NULL, NULL, NULL, NULL, '2026-05-09 07:41:45', '2026-05-09 07:41:45'),
	(221, 26, '2026-03-16', 'draft', NULL, NULL, NULL, NULL, NULL, '2026-05-09 07:41:45', '2026-05-09 07:41:45'),
	(222, 26, '2026-03-23', 'draft', NULL, NULL, NULL, NULL, NULL, '2026-05-09 07:41:45', '2026-05-09 07:41:45'),
	(223, 26, '2026-03-30', 'draft', NULL, NULL, NULL, NULL, NULL, '2026-05-09 07:41:45', '2026-05-09 07:41:45'),
	(224, 26, '2026-04-06', 'draft', NULL, NULL, NULL, NULL, NULL, '2026-05-09 07:41:45', '2026-05-09 07:41:45'),
	(225, 26, '2026-04-13', 'draft', NULL, NULL, NULL, NULL, NULL, '2026-05-09 07:41:45', '2026-05-09 07:41:45'),
	(226, 26, '2026-04-20', 'draft', NULL, NULL, NULL, NULL, NULL, '2026-05-09 07:41:45', '2026-05-09 07:41:45'),
	(227, 26, '2026-04-27', 'draft', NULL, NULL, NULL, NULL, NULL, '2026-05-09 07:41:45', '2026-05-09 07:41:45'),
	(228, 26, '2026-05-04', 'draft', NULL, NULL, NULL, NULL, NULL, '2026-05-09 07:41:45', '2026-05-09 07:41:45'),
	(229, 26, '2026-05-11', 'draft', NULL, NULL, NULL, NULL, NULL, '2026-05-09 07:41:45', '2026-05-09 07:41:45'),
	(230, 26, '2026-05-18', 'draft', NULL, NULL, NULL, NULL, NULL, '2026-05-09 07:41:46', '2026-05-09 07:41:46'),
	(231, 26, '2026-05-25', 'draft', NULL, NULL, NULL, NULL, NULL, '2026-05-09 07:41:46', '2026-05-09 07:41:46'),
	(232, 26, '2026-06-01', 'draft', NULL, NULL, NULL, NULL, NULL, '2026-05-09 07:41:46', '2026-05-09 07:41:46'),
	(233, 26, '2026-06-08', 'draft', NULL, NULL, NULL, NULL, NULL, '2026-05-09 07:41:46', '2026-05-09 07:41:46'),
	(234, 26, '2026-06-15', 'draft', NULL, NULL, NULL, NULL, NULL, '2026-05-09 07:41:46', '2026-05-09 07:41:46'),
	(235, 26, '2026-06-22', 'draft', NULL, NULL, NULL, NULL, NULL, '2026-05-09 07:41:46', '2026-05-09 07:41:46'),
	(236, 26, '2026-06-29', 'draft', NULL, NULL, NULL, NULL, NULL, '2026-05-09 07:41:46', '2026-05-09 07:41:46');

-- Dumping structure for table absensi_smk_alhafidz.riwayat_kelas_siswas
DROP TABLE IF EXISTS `riwayat_kelas_siswas`;
CREATE TABLE IF NOT EXISTS `riwayat_kelas_siswas` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `siswa_id` bigint unsigned NOT NULL,
  `from_kelas_id` bigint unsigned DEFAULT NULL,
  `to_kelas_id` bigint unsigned DEFAULT NULL,
  `tahun_ajaran_id` bigint unsigned NOT NULL,
  `action_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `processed_by` bigint unsigned DEFAULT NULL,
  `processed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `student_class_histories_siswa_id_foreign` (`siswa_id`),
  KEY `student_class_histories_from_kelas_id_foreign` (`from_kelas_id`),
  KEY `student_class_histories_to_kelas_id_foreign` (`to_kelas_id`),
  KEY `student_class_histories_processed_by_foreign` (`processed_by`),
  KEY `riwayat_kelas_siswas_tahun_ajaran_id_foreign` (`tahun_ajaran_id`),
  CONSTRAINT `riwayat_kelas_siswas_tahun_ajaran_id_foreign` FOREIGN KEY (`tahun_ajaran_id`) REFERENCES `tahun_ajarans` (`id`),
  CONSTRAINT `student_class_histories_from_kelas_id_foreign` FOREIGN KEY (`from_kelas_id`) REFERENCES `kelas` (`id`) ON DELETE SET NULL,
  CONSTRAINT `student_class_histories_processed_by_foreign` FOREIGN KEY (`processed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `student_class_histories_siswa_id_foreign` FOREIGN KEY (`siswa_id`) REFERENCES `users` (`id`),
  CONSTRAINT `student_class_histories_to_kelas_id_foreign` FOREIGN KEY (`to_kelas_id`) REFERENCES `kelas` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table absensi_smk_alhafidz.riwayat_kelas_siswas: ~9 rows (approximately)
REPLACE INTO `riwayat_kelas_siswas` (`id`, `siswa_id`, `from_kelas_id`, `to_kelas_id`, `tahun_ajaran_id`, `action_type`, `notes`, `processed_by`, `processed_at`, `created_at`, `updated_at`) VALUES
	(19, 6, 4, 10, 1, 'naik_kelas', NULL, 1, '2026-05-16 12:36:26', '2026-05-16 12:36:26', '2026-05-16 12:36:26'),
	(20, 7, 23, 13, 1, 'naik_kelas', NULL, 1, '2026-05-16 12:36:26', '2026-05-16 12:36:26', '2026-05-16 12:36:26'),
	(21, 25, 22, 12, 1, 'naik_kelas', NULL, 1, '2026-05-16 12:36:26', '2026-05-16 12:36:26', '2026-05-16 12:36:26'),
	(22, 27, 23, 13, 1, 'naik_kelas', NULL, 1, '2026-05-16 12:36:26', '2026-05-16 12:36:26', '2026-05-16 12:36:26'),
	(23, 30, 22, 12, 1, 'naik_kelas', NULL, 1, '2026-05-16 12:36:26', '2026-05-16 12:36:26', '2026-05-16 12:36:26'),
	(24, 31, 23, 13, 1, 'naik_kelas', NULL, 1, '2026-05-16 12:36:26', '2026-05-16 12:36:26', '2026-05-16 12:36:26'),
	(25, 35, 22, 12, 1, 'naik_kelas', NULL, 1, '2026-05-16 12:36:26', '2026-05-16 12:36:26', '2026-05-16 12:36:26'),
	(26, 36, 23, 13, 1, 'naik_kelas', NULL, 1, '2026-05-16 12:36:26', '2026-05-16 12:36:26', '2026-05-16 12:36:26'),
	(27, 37, 18, NULL, 1, 'lulus', NULL, 1, '2026-05-16 12:36:26', '2026-05-16 12:36:26', '2026-05-16 12:36:26');

-- Dumping structure for table absensi_smk_alhafidz.semester_akademiks
DROP TABLE IF EXISTS `semester_akademiks`;
CREATE TABLE IF NOT EXISTS `semester_akademiks` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tahun_ajaran_id` bigint unsigned NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `starts_at` date NOT NULL,
  `ends_at` date NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `semester_akademiks_tahun_ajaran_id_foreign` (`tahun_ajaran_id`),
  CONSTRAINT `semester_akademiks_tahun_ajaran_id_foreign` FOREIGN KEY (`tahun_ajaran_id`) REFERENCES `tahun_ajarans` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table absensi_smk_alhafidz.semester_akademiks: ~2 rows (approximately)
REPLACE INTO `semester_akademiks` (`id`, `tahun_ajaran_id`, `name`, `starts_at`, `ends_at`, `is_active`, `created_at`, `updated_at`) VALUES
	(1, 1, 'Semester Genap', '2026-01-01', '2026-06-30', 1, '2026-05-06 16:03:10', '2026-05-06 18:53:25'),
	(2, 1, 'Semester Ganjil', '2025-07-01', '2025-12-31', 0, '2026-05-06 18:56:23', '2026-05-06 18:56:23');

-- Dumping structure for table absensi_smk_alhafidz.sessions
DROP TABLE IF EXISTS `sessions`;
CREATE TABLE IF NOT EXISTS `sessions` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint unsigned DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_activity` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table absensi_smk_alhafidz.sessions: ~3 rows (approximately)
REPLACE INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
	('CeSpydW8iYxqb5KPMWZJv0oVLQr8dXnbscC82CRC', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.120.0 Chrome/142.0.7444.265 Electron/39.8.8 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNHlTakJmdnVGa25ZVWc3UEIyZmZqUFh1SnJoU0cwZ3E3M1NSS1d5aCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjE6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMCI7czo1OiJyb3V0ZSI7Tjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1779062592),
	('Kzag9TvEdhlPoBplfDnYwko0RjyL5LJgNqXEiZ34', 38, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:150.0) Gecko/20100101 Firefox/150.0', 'YTo3OntzOjY6Il90b2tlbiI7czo0MDoiZ1ZFbjBmMnU4U0pDR0c4WTFWMUluaVpzajhKRVhITDFlZDVVbldITSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzQ6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMC9hZG1pbi9zaXN3YXMiO3M6NToicm91dGUiO3M6Mzc6ImZpbGFtZW50LmFkbWluLnJlc291cmNlcy5zaXN3YXMuaW5kZXgiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX1zOjUwOiJsb2dpbl93ZWJfNTliYTM2YWRkYzJiMmY5NDAxNTgwZjAxNGM3ZjU4ZWE0ZTMwOTg5ZCI7aTozODtzOjE3OiJwYXNzd29yZF9oYXNoX3dlYiI7czo2NDoiNTJjZDZmNTAyYmVjOWNkYWNmZDAzYTkzZDY4Y2NiNzZmOTY2YzNiNzhlNjIzNzk1MDczNDhhNWFlYzg1YWRmOCI7czo2OiJ0YWJsZXMiO2E6MTA6e3M6NDA6IjMwNjI3Y2NhYmMzNDEwOGMyMDFkYTAzZWM4MjYzMjY3X2NvbHVtbnMiO2E6Njp7aTowO2E6Nzp7czo0OiJ0eXBlIjtzOjY6ImNvbHVtbiI7czo0OiJuYW1lIjtzOjk6InJvd19pbmRleCI7czo1OiJsYWJlbCI7czoyOiJObyI7czo4OiJpc0hpZGRlbiI7YjowO3M6OToiaXNUb2dnbGVkIjtiOjE7czoxMjoiaXNUb2dnbGVhYmxlIjtiOjA7czoyNDoiaXNUb2dnbGVkSGlkZGVuQnlEZWZhdWx0IjtOO31pOjE7YTo3OntzOjQ6InR5cGUiO3M6NjoiY29sdW1uIjtzOjQ6Im5hbWUiO3M6NzoidGluZ2thdCI7czo1OiJsYWJlbCI7czo3OiJUaW5na2F0IjtzOjg6ImlzSGlkZGVuIjtiOjA7czo5OiJpc1RvZ2dsZWQiO2I6MTtzOjEyOiJpc1RvZ2dsZWFibGUiO2I6MDtzOjI0OiJpc1RvZ2dsZWRIaWRkZW5CeURlZmF1bHQiO047fWk6MjthOjc6e3M6NDoidHlwZSI7czo2OiJjb2x1bW4iO3M6NDoibmFtZSI7czo3OiJqdXJ1c2FuIjtzOjU6ImxhYmVsIjtzOjc6Ikp1cnVzYW4iO3M6ODoiaXNIaWRkZW4iO2I6MDtzOjk6ImlzVG9nZ2xlZCI7YjoxO3M6MTI6ImlzVG9nZ2xlYWJsZSI7YjowO3M6MjQ6ImlzVG9nZ2xlZEhpZGRlbkJ5RGVmYXVsdCI7Tjt9aTozO2E6Nzp7czo0OiJ0eXBlIjtzOjY6ImNvbHVtbiI7czo0OiJuYW1lIjtzOjU6Im5vbW9yIjtzOjU6ImxhYmVsIjtzOjU6Ik5vbW9yIjtzOjg6ImlzSGlkZGVuIjtiOjA7czo5OiJpc1RvZ2dsZWQiO2I6MTtzOjEyOiJpc1RvZ2dsZWFibGUiO2I6MDtzOjI0OiJpc1RvZ2dsZWRIaWRkZW5CeURlZmF1bHQiO047fWk6NDthOjc6e3M6NDoidHlwZSI7czo2OiJjb2x1bW4iO3M6NDoibmFtZSI7czo0OiJuYW1hIjtzOjU6ImxhYmVsIjtzOjQ6Ik5hbWEiO3M6ODoiaXNIaWRkZW4iO2I6MDtzOjk6ImlzVG9nZ2xlZCI7YjoxO3M6MTI6ImlzVG9nZ2xlYWJsZSI7YjowO3M6MjQ6ImlzVG9nZ2xlZEhpZGRlbkJ5RGVmYXVsdCI7Tjt9aTo1O2E6Nzp7czo0OiJ0eXBlIjtzOjY6ImNvbHVtbiI7czo0OiJuYW1lIjtzOjU6ImFrdGlmIjtzOjU6ImxhYmVsIjtzOjU6IkFrdGlmIjtzOjg6ImlzSGlkZGVuIjtiOjA7czo5OiJpc1RvZ2dsZWQiO2I6MTtzOjEyOiJpc1RvZ2dsZWFibGUiO2I6MDtzOjI0OiJpc1RvZ2dsZWRIaWRkZW5CeURlZmF1bHQiO047fX1zOjQwOiIxOWM2Yjc0MzUzYmQwMzJlZTNiODlmYTUwYTEzYjMwM19jb2x1bW5zIjthOjQ6e2k6MDthOjc6e3M6NDoidHlwZSI7czo2OiJjb2x1bW4iO3M6NDoibmFtZSI7czo5OiJyb3dfaW5kZXgiO3M6NToibGFiZWwiO3M6MjoiTm8iO3M6ODoiaXNIaWRkZW4iO2I6MDtzOjk6ImlzVG9nZ2xlZCI7YjoxO3M6MTI6ImlzVG9nZ2xlYWJsZSI7YjowO3M6MjQ6ImlzVG9nZ2xlZEhpZGRlbkJ5RGVmYXVsdCI7Tjt9aToxO2E6Nzp7czo0OiJ0eXBlIjtzOjY6ImNvbHVtbiI7czo0OiJuYW1lIjtzOjQ6Im5hbWUiO3M6NToibGFiZWwiO3M6OToiTmFtYSBHdXJ1IjtzOjg6ImlzSGlkZGVuIjtiOjA7czo5OiJpc1RvZ2dsZWQiO2I6MTtzOjEyOiJpc1RvZ2dsZWFibGUiO2I6MDtzOjI0OiJpc1RvZ2dsZWRIaWRkZW5CeURlZmF1bHQiO047fWk6MjthOjc6e3M6NDoidHlwZSI7czo2OiJjb2x1bW4iO3M6NDoibmFtZSI7czo1OiJlbWFpbCI7czo1OiJsYWJlbCI7czo1OiJFbWFpbCI7czo4OiJpc0hpZGRlbiI7YjowO3M6OToiaXNUb2dnbGVkIjtiOjE7czoxMjoiaXNUb2dnbGVhYmxlIjtiOjA7czoyNDoiaXNUb2dnbGVkSGlkZGVuQnlEZWZhdWx0IjtOO31pOjM7YTo3OntzOjQ6InR5cGUiO3M6NjoiY29sdW1uIjtzOjQ6Im5hbWUiO3M6MTQ6IndhbGlLZWxhcy5uYW1hIjtzOjU6ImxhYmVsIjtzOjEwOiJXYWxpIEtlbGFzIjtzOjg6ImlzSGlkZGVuIjtiOjA7czo5OiJpc1RvZ2dsZWQiO2I6MTtzOjEyOiJpc1RvZ2dsZWFibGUiO2I6MDtzOjI0OiJpc1RvZ2dsZWRIaWRkZW5CeURlZmF1bHQiO047fX1zOjQwOiIwYWMwMDc2OWM3YTEzYWE3OTNmYTBiODJjYzk5NmRiZV9jb2x1bW5zIjthOjY6e2k6MDthOjc6e3M6NDoidHlwZSI7czo2OiJjb2x1bW4iO3M6NDoibmFtZSI7czo5OiJyb3dfaW5kZXgiO3M6NToibGFiZWwiO3M6MjoiTm8iO3M6ODoiaXNIaWRkZW4iO2I6MDtzOjk6ImlzVG9nZ2xlZCI7YjoxO3M6MTI6ImlzVG9nZ2xlYWJsZSI7YjowO3M6MjQ6ImlzVG9nZ2xlZEhpZGRlbkJ5RGVmYXVsdCI7Tjt9aToxO2E6Nzp7czo0OiJ0eXBlIjtzOjY6ImNvbHVtbiI7czo0OiJuYW1lIjtzOjc6InRpbmdrYXQiO3M6NToibGFiZWwiO3M6NzoiVGluZ2thdCI7czo4OiJpc0hpZGRlbiI7YjowO3M6OToiaXNUb2dnbGVkIjtiOjE7czoxMjoiaXNUb2dnbGVhYmxlIjtiOjA7czoyNDoiaXNUb2dnbGVkSGlkZGVuQnlEZWZhdWx0IjtOO31pOjI7YTo3OntzOjQ6InR5cGUiO3M6NjoiY29sdW1uIjtzOjQ6Im5hbWUiO3M6NzoianVydXNhbiI7czo1OiJsYWJlbCI7czo3OiJKdXJ1c2FuIjtzOjg6ImlzSGlkZGVuIjtiOjA7czo5OiJpc1RvZ2dsZWQiO2I6MTtzOjEyOiJpc1RvZ2dsZWFibGUiO2I6MDtzOjI0OiJpc1RvZ2dsZWRIaWRkZW5CeURlZmF1bHQiO047fWk6MzthOjc6e3M6NDoidHlwZSI7czo2OiJjb2x1bW4iO3M6NDoibmFtZSI7czo1OiJub21vciI7czo1OiJsYWJlbCI7czo1OiJOb21vciI7czo4OiJpc0hpZGRlbiI7YjowO3M6OToiaXNUb2dnbGVkIjtiOjE7czoxMjoiaXNUb2dnbGVhYmxlIjtiOjA7czoyNDoiaXNUb2dnbGVkSGlkZGVuQnlEZWZhdWx0IjtOO31pOjQ7YTo3OntzOjQ6InR5cGUiO3M6NjoiY29sdW1uIjtzOjQ6Im5hbWUiO3M6NDoibmFtYSI7czo1OiJsYWJlbCI7czo0OiJOYW1hIjtzOjg6ImlzSGlkZGVuIjtiOjA7czo5OiJpc1RvZ2dsZWQiO2I6MTtzOjEyOiJpc1RvZ2dsZWFibGUiO2I6MDtzOjI0OiJpc1RvZ2dsZWRIaWRkZW5CeURlZmF1bHQiO047fWk6NTthOjc6e3M6NDoidHlwZSI7czo2OiJjb2x1bW4iO3M6NDoibmFtZSI7czo1OiJha3RpZiI7czo1OiJsYWJlbCI7czo1OiJBa3RpZiI7czo4OiJpc0hpZGRlbiI7YjowO3M6OToiaXNUb2dnbGVkIjtiOjE7czoxMjoiaXNUb2dnbGVhYmxlIjtiOjA7czoyNDoiaXNUb2dnbGVkSGlkZGVuQnlEZWZhdWx0IjtOO319czo0MDoiMTk1NDU4YWM1Y2M4NGNiM2JkMDk0YzA2Y2UzZDNiZTZfY29sdW1ucyI7YTo2OntpOjA7YTo3OntzOjQ6InR5cGUiO3M6NjoiY29sdW1uIjtzOjQ6Im5hbWUiO3M6OToicm93X2luZGV4IjtzOjU6ImxhYmVsIjtzOjI6Ik5vIjtzOjg6ImlzSGlkZGVuIjtiOjA7czo5OiJpc1RvZ2dsZWQiO2I6MTtzOjEyOiJpc1RvZ2dsZWFibGUiO2I6MDtzOjI0OiJpc1RvZ2dsZWRIaWRkZW5CeURlZmF1bHQiO047fWk6MTthOjc6e3M6NDoidHlwZSI7czo2OiJjb2x1bW4iO3M6NDoibmFtZSI7czo0OiJuYW1lIjtzOjU6ImxhYmVsIjtzOjEwOiJOYW1hIFNpc3dhIjtzOjg6ImlzSGlkZGVuIjtiOjA7czo5OiJpc1RvZ2dsZWQiO2I6MTtzOjEyOiJpc1RvZ2dsZWFibGUiO2I6MDtzOjI0OiJpc1RvZ2dsZWRIaWRkZW5CeURlZmF1bHQiO047fWk6MjthOjc6e3M6NDoidHlwZSI7czo2OiJjb2x1bW4iO3M6NDoibmFtZSI7czozOiJuaXMiO3M6NToibGFiZWwiO3M6MzoiTklTIjtzOjg6ImlzSGlkZGVuIjtiOjA7czo5OiJpc1RvZ2dsZWQiO2I6MTtzOjEyOiJpc1RvZ2dsZWFibGUiO2I6MDtzOjI0OiJpc1RvZ2dsZWRIaWRkZW5CeURlZmF1bHQiO047fWk6MzthOjc6e3M6NDoidHlwZSI7czo2OiJjb2x1bW4iO3M6NDoibmFtZSI7czoxMDoia2VsYXMubmFtYSI7czo1OiJsYWJlbCI7czo1OiJLZWxhcyI7czo4OiJpc0hpZGRlbiI7YjowO3M6OToiaXNUb2dnbGVkIjtiOjE7czoxMjoiaXNUb2dnbGVhYmxlIjtiOjA7czoyNDoiaXNUb2dnbGVkSGlkZGVuQnlEZWZhdWx0IjtOO31pOjQ7YTo3OntzOjQ6InR5cGUiO3M6NjoiY29sdW1uIjtzOjQ6Im5hbWUiO3M6OToiaXNfYWN0aXZlIjtzOjU6ImxhYmVsIjtzOjU6IkFrdGlmIjtzOjg6ImlzSGlkZGVuIjtiOjA7czo5OiJpc1RvZ2dsZWQiO2I6MTtzOjEyOiJpc1RvZ2dsZWFibGUiO2I6MDtzOjI0OiJpc1RvZ2dsZWRIaWRkZW5CeURlZmF1bHQiO047fWk6NTthOjc6e3M6NDoidHlwZSI7czo2OiJjb2x1bW4iO3M6NDoibmFtZSI7czoxOToia2V0ZXJhbmdhbl9ub25ha3RpZiI7czo1OiJsYWJlbCI7czoxMDoiS2V0ZXJhbmdhbiI7czo4OiJpc0hpZGRlbiI7YjowO3M6OToiaXNUb2dnbGVkIjtiOjE7czoxMjoiaXNUb2dnbGVhYmxlIjtiOjA7czoyNDoiaXNUb2dnbGVkSGlkZGVuQnlEZWZhdWx0IjtOO319czo0MToiMTk1NDU4YWM1Y2M4NGNiM2JkMDk0YzA2Y2UzZDNiZTZfcGVyX3BhZ2UiO3M6MjoiMjUiO3M6NDA6IjllODEwNzI5MmRlODg5YmUwMDIwZDdiY2Y1NWRlNjUzX2NvbHVtbnMiO2E6NDp7aTowO2E6Nzp7czo0OiJ0eXBlIjtzOjY6ImNvbHVtbiI7czo0OiJuYW1lIjtzOjk6InJvd19pbmRleCI7czo1OiJsYWJlbCI7czoyOiJObyI7czo4OiJpc0hpZGRlbiI7YjowO3M6OToiaXNUb2dnbGVkIjtiOjE7czoxMjoiaXNUb2dnbGVhYmxlIjtiOjA7czoyNDoiaXNUb2dnbGVkSGlkZGVuQnlEZWZhdWx0IjtOO31pOjE7YTo3OntzOjQ6InR5cGUiO3M6NjoiY29sdW1uIjtzOjQ6Im5hbWUiO3M6OToic2luZ2thdGFuIjtzOjU6ImxhYmVsIjtzOjk6IlNpbmdrYXRhbiI7czo4OiJpc0hpZGRlbiI7YjowO3M6OToiaXNUb2dnbGVkIjtiOjE7czoxMjoiaXNUb2dnbGVhYmxlIjtiOjA7czoyNDoiaXNUb2dnbGVkSGlkZGVuQnlEZWZhdWx0IjtOO31pOjI7YTo3OntzOjQ6InR5cGUiO3M6NjoiY29sdW1uIjtzOjQ6Im5hbWUiO3M6NDoibmFtYSI7czo1OiJsYWJlbCI7czoxMjoiTmFtYSBKdXJ1c2FuIjtzOjg6ImlzSGlkZGVuIjtiOjA7czo5OiJpc1RvZ2dsZWQiO2I6MTtzOjEyOiJpc1RvZ2dsZWFibGUiO2I6MDtzOjI0OiJpc1RvZ2dsZWRIaWRkZW5CeURlZmF1bHQiO047fWk6MzthOjc6e3M6NDoidHlwZSI7czo2OiJjb2x1bW4iO3M6NDoibmFtZSI7czo1OiJha3RpZiI7czo1OiJsYWJlbCI7czo1OiJBa3RpZiI7czo4OiJpc0hpZGRlbiI7YjowO3M6OToiaXNUb2dnbGVkIjtiOjE7czoxMjoiaXNUb2dnbGVhYmxlIjtiOjA7czoyNDoiaXNUb2dnbGVkSGlkZGVuQnlEZWZhdWx0IjtOO319czo0MDoiMjhjM2ZiNGI3MDRhNTQxYmM5YmM1OThlOTQ1ZGE5MmFfY29sdW1ucyI7YToxMjp7aTowO2E6Nzp7czo0OiJ0eXBlIjtzOjY6ImNvbHVtbiI7czo0OiJuYW1lIjtzOjk6InJvd19pbmRleCI7czo1OiJsYWJlbCI7czoyOiJObyI7czo4OiJpc0hpZGRlbiI7YjowO3M6OToiaXNUb2dnbGVkIjtiOjE7czoxMjoiaXNUb2dnbGVhYmxlIjtiOjA7czoyNDoiaXNUb2dnbGVkSGlkZGVuQnlEZWZhdWx0IjtOO31pOjE7YTo3OntzOjQ6InR5cGUiO3M6NjoiY29sdW1uIjtzOjQ6Im5hbWUiO3M6NzoidGluZ2thdCI7czo1OiJsYWJlbCI7czo3OiJUaW5na2F0IjtzOjg6ImlzSGlkZGVuIjtiOjA7czo5OiJpc1RvZ2dsZWQiO2I6MTtzOjEyOiJpc1RvZ2dsZWFibGUiO2I6MDtzOjI0OiJpc1RvZ2dsZWRIaWRkZW5CeURlZmF1bHQiO047fWk6MjthOjc6e3M6NDoidHlwZSI7czo2OiJjb2x1bW4iO3M6NDoibmFtZSI7czo3OiJqdXJ1c2FuIjtzOjU6ImxhYmVsIjtzOjc6Ikp1cnVzYW4iO3M6ODoiaXNIaWRkZW4iO2I6MDtzOjk6ImlzVG9nZ2xlZCI7YjoxO3M6MTI6ImlzVG9nZ2xlYWJsZSI7YjowO3M6MjQ6ImlzVG9nZ2xlZEhpZGRlbkJ5RGVmYXVsdCI7Tjt9aTozO2E6Nzp7czo0OiJ0eXBlIjtzOjY6ImNvbHVtbiI7czo0OiJuYW1lIjtzOjU6Im5vbW9yIjtzOjU6ImxhYmVsIjtzOjU6Ik5vbW9yIjtzOjg6ImlzSGlkZGVuIjtiOjA7czo5OiJpc1RvZ2dsZWQiO2I6MTtzOjEyOiJpc1RvZ2dsZWFibGUiO2I6MDtzOjI0OiJpc1RvZ2dsZWRIaWRkZW5CeURlZmF1bHQiO047fWk6NDthOjc6e3M6NDoidHlwZSI7czo2OiJjb2x1bW4iO3M6NDoibmFtZSI7czo0OiJuYW1hIjtzOjU6ImxhYmVsIjtzOjEwOiJOYW1hIEtlbGFzIjtzOjg6ImlzSGlkZGVuIjtiOjA7czo5OiJpc1RvZ2dsZWQiO2I6MTtzOjEyOiJpc1RvZ2dsZWFibGUiO2I6MDtzOjI0OiJpc1RvZ2dsZWRIaWRkZW5CeURlZmF1bHQiO047fWk6NTthOjc6e3M6NDoidHlwZSI7czo2OiJjb2x1bW4iO3M6NDoibmFtZSI7czoxMDoid2FsaV9rZWxhcyI7czo1OiJsYWJlbCI7czoxMDoiV2FsaSBLZWxhcyI7czo4OiJpc0hpZGRlbiI7YjowO3M6OToiaXNUb2dnbGVkIjtiOjE7czoxMjoiaXNUb2dnbGVhYmxlIjtiOjA7czoyNDoiaXNUb2dnbGVkSGlkZGVuQnlEZWZhdWx0IjtOO31pOjY7YTo3OntzOjQ6InR5cGUiO3M6NjoiY29sdW1uIjtzOjQ6Im5hbWUiO3M6MTI6Imp1bWxhaF9zaXN3YSI7czo1OiJsYWJlbCI7czoxMjoiSnVtbGFoIFNpc3dhIjtzOjg6ImlzSGlkZGVuIjtiOjA7czo5OiJpc1RvZ2dsZWQiO2I6MTtzOjEyOiJpc1RvZ2dsZWFibGUiO2I6MDtzOjI0OiJpc1RvZ2dsZWRIaWRkZW5CeURlZmF1bHQiO047fWk6NzthOjc6e3M6NDoidHlwZSI7czo2OiJjb2x1bW4iO3M6NDoibmFtZSI7czoxOToianVtbGFoX2phZHdhbF9ha3RpZiI7czo1OiJsYWJlbCI7czoxMjoiSmFkd2FsIEFrdGlmIjtzOjg6ImlzSGlkZGVuIjtiOjA7czo5OiJpc1RvZ2dsZWQiO2I6MTtzOjEyOiJpc1RvZ2dsZWFibGUiO2I6MDtzOjI0OiJpc1RvZ2dsZWRIaWRkZW5CeURlZmF1bHQiO047fWk6ODthOjc6e3M6NDoidHlwZSI7czo2OiJjb2x1bW4iO3M6NDoibmFtZSI7czoxNToidG90YWxfcGVydGVtdWFuIjtzOjU6ImxhYmVsIjtzOjE1OiJUb3RhbCBQZXJ0ZW11YW4iO3M6ODoiaXNIaWRkZW4iO2I6MDtzOjk6ImlzVG9nZ2xlZCI7YjoxO3M6MTI6ImlzVG9nZ2xlYWJsZSI7YjowO3M6MjQ6ImlzVG9nZ2xlZEhpZGRlbkJ5RGVmYXVsdCI7Tjt9aTo5O2E6Nzp7czo0OiJ0eXBlIjtzOjY6ImNvbHVtbiI7czo0OiJuYW1lIjtzOjEyOiJzdWRhaF9kaWJ1a2EiO3M6NToibGFiZWwiO3M6MTI6IlN1ZGFoIERpYnVrYSI7czo4OiJpc0hpZGRlbiI7YjowO3M6OToiaXNUb2dnbGVkIjtiOjE7czoxMjoiaXNUb2dnbGVhYmxlIjtiOjA7czoyNDoiaXNUb2dnbGVkSGlkZGVuQnlEZWZhdWx0IjtOO31pOjEwO2E6Nzp7czo0OiJ0eXBlIjtzOjY6ImNvbHVtbiI7czo0OiJuYW1lIjtzOjg6InByb2dyZXNzIjtzOjU6ImxhYmVsIjtzOjg6IlByb2dyZXNzIjtzOjg6ImlzSGlkZGVuIjtiOjA7czo5OiJpc1RvZ2dsZWQiO2I6MTtzOjEyOiJpc1RvZ2dsZWFibGUiO2I6MDtzOjI0OiJpc1RvZ2dsZWRIaWRkZW5CeURlZmF1bHQiO047fWk6MTE7YTo3OntzOjQ6InR5cGUiO3M6NjoiY29sdW1uIjtzOjQ6Im5hbWUiO3M6NToiYWt0aWYiO3M6NToibGFiZWwiO3M6NToiQWt0aWYiO3M6ODoiaXNIaWRkZW4iO2I6MDtzOjk6ImlzVG9nZ2xlZCI7YjoxO3M6MTI6ImlzVG9nZ2xlYWJsZSI7YjowO3M6MjQ6ImlzVG9nZ2xlZEhpZGRlbkJ5RGVmYXVsdCI7Tjt9fXM6NDA6IjZmM2E3YmQ4NGNhMzM1MjdiN2RlNDE4NGIwYmI2ZTA4X2NvbHVtbnMiO2E6Njp7aTowO2E6Nzp7czo0OiJ0eXBlIjtzOjY6ImNvbHVtbiI7czo0OiJuYW1lIjtzOjI6ImlkIjtzOjU6ImxhYmVsIjtzOjI6Ik5vIjtzOjg6ImlzSGlkZGVuIjtiOjA7czo5OiJpc1RvZ2dsZWQiO2I6MTtzOjEyOiJpc1RvZ2dsZWFibGUiO2I6MDtzOjI0OiJpc1RvZ2dsZWRIaWRkZW5CeURlZmF1bHQiO047fWk6MTthOjc6e3M6NDoidHlwZSI7czo2OiJjb2x1bW4iO3M6NDoibmFtZSI7czo0OiJoYXJpIjtzOjU6ImxhYmVsIjtzOjQ6IkhhcmkiO3M6ODoiaXNIaWRkZW4iO2I6MDtzOjk6ImlzVG9nZ2xlZCI7YjoxO3M6MTI6ImlzVG9nZ2xlYWJsZSI7YjowO3M6MjQ6ImlzVG9nZ2xlZEhpZGRlbkJ5RGVmYXVsdCI7Tjt9aToyO2E6Nzp7czo0OiJ0eXBlIjtzOjY6ImNvbHVtbiI7czo0OiJuYW1lIjtzOjEzOiJqdW1sYWhfamFkd2FsIjtzOjU6ImxhYmVsIjtzOjEzOiJKdW1sYWggSmFkd2FsIjtzOjg6ImlzSGlkZGVuIjtiOjA7czo5OiJpc1RvZ2dsZWQiO2I6MTtzOjEyOiJpc1RvZ2dsZWFibGUiO2I6MDtzOjI0OiJpc1RvZ2dsZWRIaWRkZW5CeURlZmF1bHQiO047fWk6MzthOjc6e3M6NDoidHlwZSI7czo2OiJjb2x1bW4iO3M6NDoibmFtZSI7czoxNToidG90YWxfcGVydGVtdWFuIjtzOjU6ImxhYmVsIjtzOjE1OiJUb3RhbCBQZXJ0ZW11YW4iO3M6ODoiaXNIaWRkZW4iO2I6MDtzOjk6ImlzVG9nZ2xlZCI7YjoxO3M6MTI6ImlzVG9nZ2xlYWJsZSI7YjowO3M6MjQ6ImlzVG9nZ2xlZEhpZGRlbkJ5RGVmYXVsdCI7Tjt9aTo0O2E6Nzp7czo0OiJ0eXBlIjtzOjY6ImNvbHVtbiI7czo0OiJuYW1lIjtzOjEyOiJzdWRhaF9kaWJ1a2EiO3M6NToibGFiZWwiO3M6MTI6IlN1ZGFoIERpYnVrYSI7czo4OiJpc0hpZGRlbiI7YjowO3M6OToiaXNUb2dnbGVkIjtiOjE7czoxMjoiaXNUb2dnbGVhYmxlIjtiOjA7czoyNDoiaXNUb2dnbGVkSGlkZGVuQnlEZWZhdWx0IjtOO31pOjU7YTo3OntzOjQ6InR5cGUiO3M6NjoiY29sdW1uIjtzOjQ6Im5hbWUiO3M6ODoicHJvZ3Jlc3MiO3M6NToibGFiZWwiO3M6ODoiUHJvZ3Jlc3MiO3M6ODoiaXNIaWRkZW4iO2I6MDtzOjk6ImlzVG9nZ2xlZCI7YjoxO3M6MTI6ImlzVG9nZ2xlYWJsZSI7YjowO3M6MjQ6ImlzVG9nZ2xlZEhpZGRlbkJ5RGVmYXVsdCI7Tjt9fXM6NDA6IjliMWExMjRhYjJjZWI0MDE3NmUzZDUxZmVmOGExYTUyX2NvbHVtbnMiO2E6MTM6e2k6MDthOjc6e3M6NDoidHlwZSI7czo2OiJjb2x1bW4iO3M6NDoibmFtZSI7czoyOiJubyI7czo1OiJsYWJlbCI7czoyOiJObyI7czo4OiJpc0hpZGRlbiI7YjowO3M6OToiaXNUb2dnbGVkIjtiOjE7czoxMjoiaXNUb2dnbGVhYmxlIjtiOjA7czoyNDoiaXNUb2dnbGVkSGlkZGVuQnlEZWZhdWx0IjtOO31pOjE7YTo3OntzOjQ6InR5cGUiO3M6NjoiY29sdW1uIjtzOjQ6Im5hbWUiO3M6NjoiamFtX2tlIjtzOjU6ImxhYmVsIjtzOjY6IkphbSBLZSI7czo4OiJpc0hpZGRlbiI7YjowO3M6OToiaXNUb2dnbGVkIjtiOjE7czoxMjoiaXNUb2dnbGVhYmxlIjtiOjA7czoyNDoiaXNUb2dnbGVkSGlkZGVuQnlEZWZhdWx0IjtOO31pOjI7YTo3OntzOjQ6InR5cGUiO3M6NjoiY29sdW1uIjtzOjQ6Im5hbWUiO3M6MTA6Im1hcGVsLm5hbWEiO3M6NToibGFiZWwiO3M6MTQ6Ik1hdGEgUGVsYWphcmFuIjtzOjg6ImlzSGlkZGVuIjtiOjA7czo5OiJpc1RvZ2dsZWQiO2I6MTtzOjEyOiJpc1RvZ2dsZWFibGUiO2I6MDtzOjI0OiJpc1RvZ2dsZWRIaWRkZW5CeURlZmF1bHQiO047fWk6MzthOjc6e3M6NDoidHlwZSI7czo2OiJjb2x1bW4iO3M6NDoibmFtZSI7czo5OiJndXJ1Lm5hbWUiO3M6NToibGFiZWwiO3M6NDoiR3VydSI7czo4OiJpc0hpZGRlbiI7YjowO3M6OToiaXNUb2dnbGVkIjtiOjE7czoxMjoiaXNUb2dnbGVhYmxlIjtiOjA7czoyNDoiaXNUb2dnbGVkSGlkZGVuQnlEZWZhdWx0IjtOO31pOjQ7YTo3OntzOjQ6InR5cGUiO3M6NjoiY29sdW1uIjtzOjQ6Im5hbWUiO3M6MTA6IndhbGlfa2VsYXMiO3M6NToibGFiZWwiO3M6MTA6IldhbGkgS2VsYXMiO3M6ODoiaXNIaWRkZW4iO2I6MDtzOjk6ImlzVG9nZ2xlZCI7YjoxO3M6MTI6ImlzVG9nZ2xlYWJsZSI7YjowO3M6MjQ6ImlzVG9nZ2xlZEhpZGRlbkJ5RGVmYXVsdCI7Tjt9aTo1O2E6Nzp7czo0OiJ0eXBlIjtzOjY6ImNvbHVtbiI7czo0OiJuYW1lIjtzOjU6ImFrdGlmIjtzOjU6ImxhYmVsIjtzOjU6IkFrdGlmIjtzOjg6ImlzSGlkZGVuIjtiOjA7czo5OiJpc1RvZ2dsZWQiO2I6MTtzOjEyOiJpc1RvZ2dsZWFibGUiO2I6MDtzOjI0OiJpc1RvZ2dsZWRIaWRkZW5CeURlZmF1bHQiO047fWk6NjthOjc6e3M6NDoidHlwZSI7czo2OiJjb2x1bW4iO3M6NDoibmFtZSI7czoxNToidG90YWxfcGVydGVtdWFuIjtzOjU6ImxhYmVsIjtzOjE1OiJUb3RhbCBQZXJ0ZW11YW4iO3M6ODoiaXNIaWRkZW4iO2I6MDtzOjk6ImlzVG9nZ2xlZCI7YjoxO3M6MTI6ImlzVG9nZ2xlYWJsZSI7YjowO3M6MjQ6ImlzVG9nZ2xlZEhpZGRlbkJ5RGVmYXVsdCI7Tjt9aTo3O2E6Nzp7czo0OiJ0eXBlIjtzOjY6ImNvbHVtbiI7czo0OiJuYW1lIjtzOjEyOiJzdWRhaF9kaWJ1a2EiO3M6NToibGFiZWwiO3M6MTI6IlN1ZGFoIERpYnVrYSI7czo4OiJpc0hpZGRlbiI7YjowO3M6OToiaXNUb2dnbGVkIjtiOjE7czoxMjoiaXNUb2dnbGVhYmxlIjtiOjA7czoyNDoiaXNUb2dnbGVkSGlkZGVuQnlEZWZhdWx0IjtOO31pOjg7YTo3OntzOjQ6InR5cGUiO3M6NjoiY29sdW1uIjtzOjQ6Im5hbWUiO3M6ODoicHJvZ3Jlc3MiO3M6NToibGFiZWwiO3M6ODoiUHJvZ3Jlc3MiO3M6ODoiaXNIaWRkZW4iO2I6MDtzOjk6ImlzVG9nZ2xlZCI7YjoxO3M6MTI6ImlzVG9nZ2xlYWJsZSI7YjowO3M6MjQ6ImlzVG9nZ2xlZEhpZGRlbkJ5RGVmYXVsdCI7Tjt9aTo5O2E6Nzp7czo0OiJ0eXBlIjtzOjY6ImNvbHVtbiI7czo0OiJuYW1lIjtzOjU6ImhhZGlyIjtzOjU6ImxhYmVsIjtzOjU6IkhhZGlyIjtzOjg6ImlzSGlkZGVuIjtiOjA7czo5OiJpc1RvZ2dsZWQiO2I6MTtzOjEyOiJpc1RvZ2dsZWFibGUiO2I6MDtzOjI0OiJpc1RvZ2dsZWRIaWRkZW5CeURlZmF1bHQiO047fWk6MTA7YTo3OntzOjQ6InR5cGUiO3M6NjoiY29sdW1uIjtzOjQ6Im5hbWUiO3M6NDoiaXppbiI7czo1OiJsYWJlbCI7czo0OiJJemluIjtzOjg6ImlzSGlkZGVuIjtiOjA7czo5OiJpc1RvZ2dsZWQiO2I6MTtzOjEyOiJpc1RvZ2dsZWFibGUiO2I6MDtzOjI0OiJpc1RvZ2dsZWRIaWRkZW5CeURlZmF1bHQiO047fWk6MTE7YTo3OntzOjQ6InR5cGUiO3M6NjoiY29sdW1uIjtzOjQ6Im5hbWUiO3M6NToic2FraXQiO3M6NToibGFiZWwiO3M6NToiU2FraXQiO3M6ODoiaXNIaWRkZW4iO2I6MDtzOjk6ImlzVG9nZ2xlZCI7YjoxO3M6MTI6ImlzVG9nZ2xlYWJsZSI7YjowO3M6MjQ6ImlzVG9nZ2xlZEhpZGRlbkJ5RGVmYXVsdCI7Tjt9aToxMjthOjc6e3M6NDoidHlwZSI7czo2OiJjb2x1bW4iO3M6NDoibmFtZSI7czo0OiJhbGZhIjtzOjU6ImxhYmVsIjtzOjQ6IkFsZmEiO3M6ODoiaXNIaWRkZW4iO2I6MDtzOjk6ImlzVG9nZ2xlZCI7YjoxO3M6MTI6ImlzVG9nZ2xlYWJsZSI7YjowO3M6MjQ6ImlzVG9nZ2xlZEhpZGRlbkJ5RGVmYXVsdCI7Tjt9fXM6NDA6ImFhYzgyMDUzNDFjZTdjOTJjMDYyNjAxMDQ3YTAzNDlkX2NvbHVtbnMiO2E6MzI6e2k6MDthOjc6e3M6NDoidHlwZSI7czo2OiJjb2x1bW4iO3M6NDoibmFtZSI7czoyOiJubyI7czo1OiJsYWJlbCI7czoyOiJObyI7czo4OiJpc0hpZGRlbiI7YjowO3M6OToiaXNUb2dnbGVkIjtiOjE7czoxMjoiaXNUb2dnbGVhYmxlIjtiOjA7czoyNDoiaXNUb2dnbGVkSGlkZGVuQnlEZWZhdWx0IjtOO31pOjE7YTo3OntzOjQ6InR5cGUiO3M6NjoiY29sdW1uIjtzOjQ6Im5hbWUiO3M6NDoibmFtZSI7czo1OiJsYWJlbCI7czoxMDoiTmFtYSBTaXN3YSI7czo4OiJpc0hpZGRlbiI7YjowO3M6OToiaXNUb2dnbGVkIjtiOjE7czoxMjoiaXNUb2dnbGVhYmxlIjtiOjA7czoyNDoiaXNUb2dnbGVkSGlkZGVuQnlEZWZhdWx0IjtOO31pOjI7YTo3OntzOjQ6InR5cGUiO3M6NjoiY29sdW1uIjtzOjQ6Im5hbWUiO3M6ODoic2VzaV8yMTEiO3M6NToibGFiZWwiO3M6NToiMDUvMDEiO3M6ODoiaXNIaWRkZW4iO2I6MDtzOjk6ImlzVG9nZ2xlZCI7YjoxO3M6MTI6ImlzVG9nZ2xlYWJsZSI7YjowO3M6MjQ6ImlzVG9nZ2xlZEhpZGRlbkJ5RGVmYXVsdCI7Tjt9aTozO2E6Nzp7czo0OiJ0eXBlIjtzOjY6ImNvbHVtbiI7czo0OiJuYW1lIjtzOjg6InNlc2lfMjEyIjtzOjU6ImxhYmVsIjtzOjU6IjEyLzAxIjtzOjg6ImlzSGlkZGVuIjtiOjA7czo5OiJpc1RvZ2dsZWQiO2I6MTtzOjEyOiJpc1RvZ2dsZWFibGUiO2I6MDtzOjI0OiJpc1RvZ2dsZWRIaWRkZW5CeURlZmF1bHQiO047fWk6NDthOjc6e3M6NDoidHlwZSI7czo2OiJjb2x1bW4iO3M6NDoibmFtZSI7czo4OiJzZXNpXzIxMyI7czo1OiJsYWJlbCI7czo1OiIxOS8wMSI7czo4OiJpc0hpZGRlbiI7YjowO3M6OToiaXNUb2dnbGVkIjtiOjE7czoxMjoiaXNUb2dnbGVhYmxlIjtiOjA7czoyNDoiaXNUb2dnbGVkSGlkZGVuQnlEZWZhdWx0IjtOO31pOjU7YTo3OntzOjQ6InR5cGUiO3M6NjoiY29sdW1uIjtzOjQ6Im5hbWUiO3M6ODoic2VzaV8yMTQiO3M6NToibGFiZWwiO3M6NToiMjYvMDEiO3M6ODoiaXNIaWRkZW4iO2I6MDtzOjk6ImlzVG9nZ2xlZCI7YjoxO3M6MTI6ImlzVG9nZ2xlYWJsZSI7YjowO3M6MjQ6ImlzVG9nZ2xlZEhpZGRlbkJ5RGVmYXVsdCI7Tjt9aTo2O2E6Nzp7czo0OiJ0eXBlIjtzOjY6ImNvbHVtbiI7czo0OiJuYW1lIjtzOjg6InNlc2lfMjE1IjtzOjU6ImxhYmVsIjtzOjU6IjAyLzAyIjtzOjg6ImlzSGlkZGVuIjtiOjA7czo5OiJpc1RvZ2dsZWQiO2I6MTtzOjEyOiJpc1RvZ2dsZWFibGUiO2I6MDtzOjI0OiJpc1RvZ2dsZWRIaWRkZW5CeURlZmF1bHQiO047fWk6NzthOjc6e3M6NDoidHlwZSI7czo2OiJjb2x1bW4iO3M6NDoibmFtZSI7czo4OiJzZXNpXzIxNiI7czo1OiJsYWJlbCI7czo1OiIwOS8wMiI7czo4OiJpc0hpZGRlbiI7YjowO3M6OToiaXNUb2dnbGVkIjtiOjE7czoxMjoiaXNUb2dnbGVhYmxlIjtiOjA7czoyNDoiaXNUb2dnbGVkSGlkZGVuQnlEZWZhdWx0IjtOO31pOjg7YTo3OntzOjQ6InR5cGUiO3M6NjoiY29sdW1uIjtzOjQ6Im5hbWUiO3M6ODoic2VzaV8yMTciO3M6NToibGFiZWwiO3M6NToiMTYvMDIiO3M6ODoiaXNIaWRkZW4iO2I6MDtzOjk6ImlzVG9nZ2xlZCI7YjoxO3M6MTI6ImlzVG9nZ2xlYWJsZSI7YjowO3M6MjQ6ImlzVG9nZ2xlZEhpZGRlbkJ5RGVmYXVsdCI7Tjt9aTo5O2E6Nzp7czo0OiJ0eXBlIjtzOjY6ImNvbHVtbiI7czo0OiJuYW1lIjtzOjg6InNlc2lfMjE4IjtzOjU6ImxhYmVsIjtzOjU6IjIzLzAyIjtzOjg6ImlzSGlkZGVuIjtiOjA7czo5OiJpc1RvZ2dsZWQiO2I6MTtzOjEyOiJpc1RvZ2dsZWFibGUiO2I6MDtzOjI0OiJpc1RvZ2dsZWRIaWRkZW5CeURlZmF1bHQiO047fWk6MTA7YTo3OntzOjQ6InR5cGUiO3M6NjoiY29sdW1uIjtzOjQ6Im5hbWUiO3M6ODoic2VzaV8yMTkiO3M6NToibGFiZWwiO3M6NToiMDIvMDMiO3M6ODoiaXNIaWRkZW4iO2I6MDtzOjk6ImlzVG9nZ2xlZCI7YjoxO3M6MTI6ImlzVG9nZ2xlYWJsZSI7YjowO3M6MjQ6ImlzVG9nZ2xlZEhpZGRlbkJ5RGVmYXVsdCI7Tjt9aToxMTthOjc6e3M6NDoidHlwZSI7czo2OiJjb2x1bW4iO3M6NDoibmFtZSI7czo4OiJzZXNpXzIyMCI7czo1OiJsYWJlbCI7czo1OiIwOS8wMyI7czo4OiJpc0hpZGRlbiI7YjowO3M6OToiaXNUb2dnbGVkIjtiOjE7czoxMjoiaXNUb2dnbGVhYmxlIjtiOjA7czoyNDoiaXNUb2dnbGVkSGlkZGVuQnlEZWZhdWx0IjtOO31pOjEyO2E6Nzp7czo0OiJ0eXBlIjtzOjY6ImNvbHVtbiI7czo0OiJuYW1lIjtzOjg6InNlc2lfMjIxIjtzOjU6ImxhYmVsIjtzOjU6IjE2LzAzIjtzOjg6ImlzSGlkZGVuIjtiOjA7czo5OiJpc1RvZ2dsZWQiO2I6MTtzOjEyOiJpc1RvZ2dsZWFibGUiO2I6MDtzOjI0OiJpc1RvZ2dsZWRIaWRkZW5CeURlZmF1bHQiO047fWk6MTM7YTo3OntzOjQ6InR5cGUiO3M6NjoiY29sdW1uIjtzOjQ6Im5hbWUiO3M6ODoic2VzaV8yMjIiO3M6NToibGFiZWwiO3M6NToiMjMvMDMiO3M6ODoiaXNIaWRkZW4iO2I6MDtzOjk6ImlzVG9nZ2xlZCI7YjoxO3M6MTI6ImlzVG9nZ2xlYWJsZSI7YjowO3M6MjQ6ImlzVG9nZ2xlZEhpZGRlbkJ5RGVmYXVsdCI7Tjt9aToxNDthOjc6e3M6NDoidHlwZSI7czo2OiJjb2x1bW4iO3M6NDoibmFtZSI7czo4OiJzZXNpXzIyMyI7czo1OiJsYWJlbCI7czo1OiIzMC8wMyI7czo4OiJpc0hpZGRlbiI7YjowO3M6OToiaXNUb2dnbGVkIjtiOjE7czoxMjoiaXNUb2dnbGVhYmxlIjtiOjA7czoyNDoiaXNUb2dnbGVkSGlkZGVuQnlEZWZhdWx0IjtOO31pOjE1O2E6Nzp7czo0OiJ0eXBlIjtzOjY6ImNvbHVtbiI7czo0OiJuYW1lIjtzOjg6InNlc2lfMjI0IjtzOjU6ImxhYmVsIjtzOjU6IjA2LzA0IjtzOjg6ImlzSGlkZGVuIjtiOjA7czo5OiJpc1RvZ2dsZWQiO2I6MTtzOjEyOiJpc1RvZ2dsZWFibGUiO2I6MDtzOjI0OiJpc1RvZ2dsZWRIaWRkZW5CeURlZmF1bHQiO047fWk6MTY7YTo3OntzOjQ6InR5cGUiO3M6NjoiY29sdW1uIjtzOjQ6Im5hbWUiO3M6ODoic2VzaV8yMjUiO3M6NToibGFiZWwiO3M6NToiMTMvMDQiO3M6ODoiaXNIaWRkZW4iO2I6MDtzOjk6ImlzVG9nZ2xlZCI7YjoxO3M6MTI6ImlzVG9nZ2xlYWJsZSI7YjowO3M6MjQ6ImlzVG9nZ2xlZEhpZGRlbkJ5RGVmYXVsdCI7Tjt9aToxNzthOjc6e3M6NDoidHlwZSI7czo2OiJjb2x1bW4iO3M6NDoibmFtZSI7czo4OiJzZXNpXzIyNiI7czo1OiJsYWJlbCI7czo1OiIyMC8wNCI7czo4OiJpc0hpZGRlbiI7YjowO3M6OToiaXNUb2dnbGVkIjtiOjE7czoxMjoiaXNUb2dnbGVhYmxlIjtiOjA7czoyNDoiaXNUb2dnbGVkSGlkZGVuQnlEZWZhdWx0IjtOO31pOjE4O2E6Nzp7czo0OiJ0eXBlIjtzOjY6ImNvbHVtbiI7czo0OiJuYW1lIjtzOjg6InNlc2lfMjI3IjtzOjU6ImxhYmVsIjtzOjU6IjI3LzA0IjtzOjg6ImlzSGlkZGVuIjtiOjA7czo5OiJpc1RvZ2dsZWQiO2I6MTtzOjEyOiJpc1RvZ2dsZWFibGUiO2I6MDtzOjI0OiJpc1RvZ2dsZWRIaWRkZW5CeURlZmF1bHQiO047fWk6MTk7YTo3OntzOjQ6InR5cGUiO3M6NjoiY29sdW1uIjtzOjQ6Im5hbWUiO3M6ODoic2VzaV8yMjgiO3M6NToibGFiZWwiO3M6NToiMDQvMDUiO3M6ODoiaXNIaWRkZW4iO2I6MDtzOjk6ImlzVG9nZ2xlZCI7YjoxO3M6MTI6ImlzVG9nZ2xlYWJsZSI7YjowO3M6MjQ6ImlzVG9nZ2xlZEhpZGRlbkJ5RGVmYXVsdCI7Tjt9aToyMDthOjc6e3M6NDoidHlwZSI7czo2OiJjb2x1bW4iO3M6NDoibmFtZSI7czo4OiJzZXNpXzIyOSI7czo1OiJsYWJlbCI7czo1OiIxMS8wNSI7czo4OiJpc0hpZGRlbiI7YjowO3M6OToiaXNUb2dnbGVkIjtiOjE7czoxMjoiaXNUb2dnbGVhYmxlIjtiOjA7czoyNDoiaXNUb2dnbGVkSGlkZGVuQnlEZWZhdWx0IjtOO31pOjIxO2E6Nzp7czo0OiJ0eXBlIjtzOjY6ImNvbHVtbiI7czo0OiJuYW1lIjtzOjg6InNlc2lfMjMwIjtzOjU6ImxhYmVsIjtzOjU6IjE4LzA1IjtzOjg6ImlzSGlkZGVuIjtiOjA7czo5OiJpc1RvZ2dsZWQiO2I6MTtzOjEyOiJpc1RvZ2dsZWFibGUiO2I6MDtzOjI0OiJpc1RvZ2dsZWRIaWRkZW5CeURlZmF1bHQiO047fWk6MjI7YTo3OntzOjQ6InR5cGUiO3M6NjoiY29sdW1uIjtzOjQ6Im5hbWUiO3M6ODoic2VzaV8yMzEiO3M6NToibGFiZWwiO3M6NToiMjUvMDUiO3M6ODoiaXNIaWRkZW4iO2I6MDtzOjk6ImlzVG9nZ2xlZCI7YjoxO3M6MTI6ImlzVG9nZ2xlYWJsZSI7YjowO3M6MjQ6ImlzVG9nZ2xlZEhpZGRlbkJ5RGVmYXVsdCI7Tjt9aToyMzthOjc6e3M6NDoidHlwZSI7czo2OiJjb2x1bW4iO3M6NDoibmFtZSI7czo4OiJzZXNpXzIzMiI7czo1OiJsYWJlbCI7czo1OiIwMS8wNiI7czo4OiJpc0hpZGRlbiI7YjowO3M6OToiaXNUb2dnbGVkIjtiOjE7czoxMjoiaXNUb2dnbGVhYmxlIjtiOjA7czoyNDoiaXNUb2dnbGVkSGlkZGVuQnlEZWZhdWx0IjtOO31pOjI0O2E6Nzp7czo0OiJ0eXBlIjtzOjY6ImNvbHVtbiI7czo0OiJuYW1lIjtzOjg6InNlc2lfMjMzIjtzOjU6ImxhYmVsIjtzOjU6IjA4LzA2IjtzOjg6ImlzSGlkZGVuIjtiOjA7czo5OiJpc1RvZ2dsZWQiO2I6MTtzOjEyOiJpc1RvZ2dsZWFibGUiO2I6MDtzOjI0OiJpc1RvZ2dsZWRIaWRkZW5CeURlZmF1bHQiO047fWk6MjU7YTo3OntzOjQ6InR5cGUiO3M6NjoiY29sdW1uIjtzOjQ6Im5hbWUiO3M6ODoic2VzaV8yMzQiO3M6NToibGFiZWwiO3M6NToiMTUvMDYiO3M6ODoiaXNIaWRkZW4iO2I6MDtzOjk6ImlzVG9nZ2xlZCI7YjoxO3M6MTI6ImlzVG9nZ2xlYWJsZSI7YjowO3M6MjQ6ImlzVG9nZ2xlZEhpZGRlbkJ5RGVmYXVsdCI7Tjt9aToyNjthOjc6e3M6NDoidHlwZSI7czo2OiJjb2x1bW4iO3M6NDoibmFtZSI7czo4OiJzZXNpXzIzNSI7czo1OiJsYWJlbCI7czo1OiIyMi8wNiI7czo4OiJpc0hpZGRlbiI7YjowO3M6OToiaXNUb2dnbGVkIjtiOjE7czoxMjoiaXNUb2dnbGVhYmxlIjtiOjA7czoyNDoiaXNUb2dnbGVkSGlkZGVuQnlEZWZhdWx0IjtOO31pOjI3O2E6Nzp7czo0OiJ0eXBlIjtzOjY6ImNvbHVtbiI7czo0OiJuYW1lIjtzOjg6InNlc2lfMjM2IjtzOjU6ImxhYmVsIjtzOjU6IjI5LzA2IjtzOjg6ImlzSGlkZGVuIjtiOjA7czo5OiJpc1RvZ2dsZWQiO2I6MTtzOjEyOiJpc1RvZ2dsZWFibGUiO2I6MDtzOjI0OiJpc1RvZ2dsZWRIaWRkZW5CeURlZmF1bHQiO047fWk6Mjg7YTo3OntzOjQ6InR5cGUiO3M6NjoiY29sdW1uIjtzOjQ6Im5hbWUiO3M6MTE6InRvdGFsX2hhZGlyIjtzOjU6ImxhYmVsIjtzOjU6IkhhZGlyIjtzOjg6ImlzSGlkZGVuIjtiOjA7czo5OiJpc1RvZ2dsZWQiO2I6MTtzOjEyOiJpc1RvZ2dsZWFibGUiO2I6MDtzOjI0OiJpc1RvZ2dsZWRIaWRkZW5CeURlZmF1bHQiO047fWk6Mjk7YTo3OntzOjQ6InR5cGUiO3M6NjoiY29sdW1uIjtzOjQ6Im5hbWUiO3M6MTA6InRvdGFsX2l6aW4iO3M6NToibGFiZWwiO3M6NDoiSXppbiI7czo4OiJpc0hpZGRlbiI7YjowO3M6OToiaXNUb2dnbGVkIjtiOjE7czoxMjoiaXNUb2dnbGVhYmxlIjtiOjA7czoyNDoiaXNUb2dnbGVkSGlkZGVuQnlEZWZhdWx0IjtOO31pOjMwO2E6Nzp7czo0OiJ0eXBlIjtzOjY6ImNvbHVtbiI7czo0OiJuYW1lIjtzOjExOiJ0b3RhbF9zYWtpdCI7czo1OiJsYWJlbCI7czo1OiJTYWtpdCI7czo4OiJpc0hpZGRlbiI7YjowO3M6OToiaXNUb2dnbGVkIjtiOjE7czoxMjoiaXNUb2dnbGVhYmxlIjtiOjA7czoyNDoiaXNUb2dnbGVkSGlkZGVuQnlEZWZhdWx0IjtOO31pOjMxO2E6Nzp7czo0OiJ0eXBlIjtzOjY6ImNvbHVtbiI7czo0OiJuYW1lIjtzOjEwOiJ0b3RhbF9hbGZhIjtzOjU6ImxhYmVsIjtzOjQ6IkFsZmEiO3M6ODoiaXNIaWRkZW4iO2I6MDtzOjk6ImlzVG9nZ2xlZCI7YjoxO3M6MTI6ImlzVG9nZ2xlYWJsZSI7YjowO3M6MjQ6ImlzVG9nZ2xlZEhpZGRlbkJ5RGVmYXVsdCI7Tjt9fX1zOjg6ImZpbGFtZW50IjthOjA6e319', 1779066105);

-- Dumping structure for table absensi_smk_alhafidz.tahun_ajarans
DROP TABLE IF EXISTS `tahun_ajarans`;
CREATE TABLE IF NOT EXISTS `tahun_ajarans` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `starts_at` date NOT NULL,
  `ends_at` date NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '0',
  `promotion_processed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table absensi_smk_alhafidz.tahun_ajarans: ~1 rows (approximately)
REPLACE INTO `tahun_ajarans` (`id`, `name`, `starts_at`, `ends_at`, `is_active`, `promotion_processed_at`, `created_at`, `updated_at`) VALUES
	(1, '2025/2026', '2025-07-01', '2026-06-30', 1, '2026-05-16 12:36:26', '2026-05-06 16:03:10', '2026-05-16 12:36:26');

-- Dumping structure for table absensi_smk_alhafidz.users
DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'siswa',
  `username` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nis` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `wali_kelas_id` bigint unsigned DEFAULT NULL,
  `kelas_id` bigint unsigned DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `keterangan_nonaktif` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`),
  UNIQUE KEY `users_username_unique` (`username`),
  UNIQUE KEY `users_nis_unique` (`nis`),
  KEY `users_wali_kelas_id_foreign` (`wali_kelas_id`),
  KEY `users_kelas_id_foreign` (`kelas_id`),
  CONSTRAINT `users_kelas_id_foreign` FOREIGN KEY (`kelas_id`) REFERENCES `kelas` (`id`) ON DELETE SET NULL,
  CONSTRAINT `users_wali_kelas_id_foreign` FOREIGN KEY (`wali_kelas_id`) REFERENCES `kelas` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=138 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table absensi_smk_alhafidz.users: ~13 rows (approximately)
REPLACE INTO `users` (`id`, `name`, `email`, `email_verified_at`, `password`, `role`, `username`, `nis`, `remember_token`, `created_at`, `updated_at`, `wali_kelas_id`, `kelas_id`, `is_active`, `keterangan_nonaktif`) VALUES
	(1, 'Kesiswaan SMK AL Hafidz', 'admin@smkalhafidz', NULL, '$2y$12$8R0tMVpidOgDXDgRaFEzgOoeZosmaK/Pb24ewVAHENE5C1GtxXnQK', 'admin', 'kesiswaan@smkalhafidz', NULL, 'iBSmElXqwD5UQJdp7XjB5Ahmdy1CA4XRz2uhvCV85Y1lFkjGFrEeahRsL5rc', '2026-02-25 00:21:43', '2026-03-10 13:41:57', NULL, NULL, 1, NULL),
	(2, 'Sintia Sari', 'sintia@gmail.com', NULL, '$2y$12$fhvQTIN5Tdc./xLjIENzxeYHlKKAXAv9mkhdyln0HF6D7Z2hfJJdC', 'guru', 'sintia@gmail.com', NULL, NULL, '2026-02-27 01:11:46', '2026-04-02 03:40:27', 22, NULL, 1, NULL),
	(6, 'Ahmad Al-Faqih Assasi', NULL, NULL, '$2y$12$84gYg1DXHfcmcMDJNkwAY.0SHIui/zh1iLtDqSjNIkvqKMPnCbrSS', 'siswa', '0110222021', '0110222021', NULL, '2026-02-28 00:41:46', '2026-05-17 17:42:49', NULL, 12, 1, 'Dikeluarkan'),
	(7, 'Bagus Achmad Hidayat', NULL, NULL, '$2y$12$5iJY1XurM4We1QM67cDOIuX1OqTuKbCStUYTu7zES17vQDRo5iVMu', 'siswa', '0110222002', '0110222002', NULL, '2026-02-28 02:17:12', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(11, 'Aulia Rahman', 'agam@gmail.com', NULL, '$2y$12$da3HeyZZNgwhnay0D6L4NuYWxK5fHQq3Crgwfsz0Nx07Bo4zpIKDe', 'guru', 'agam@gmail.com', NULL, NULL, '2026-02-28 16:11:04', '2026-04-02 09:05:26', NULL, NULL, 1, NULL),
	(25, 'Adit Sulistiawan', NULL, NULL, '$2y$12$WlyjwEmmqASwd6rPEh/emuyxiCImqT1RF3kfL5dhl9xJP69l/Rcgy', 'siswa', '0110222555', '0110222555', NULL, '2026-03-05 03:43:35', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(27, 'Deva Lubna', NULL, NULL, '$2y$12$rsRYow4DWM661t5bqZcBseQy6ISP0bNHbLAPXfaXLlTBfIilKDNIm', 'siswa', '0110222212', '0110222212', NULL, '2026-03-07 02:10:04', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(30, 'Denis Kurniawan', NULL, NULL, '$2y$12$XvAhOM4Bv7Dw0FkSSmdqXehGZMlTlevf5KEuuuQOJCBpafCRa0yVG', 'siswa', '0110222505', '0110222505', NULL, '2026-03-08 00:49:31', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(31, 'SInta Amanda', NULL, NULL, '$2y$12$xsbFScX4.NdFNaLJKTHKDuskiB4WMUEkCkuwHUNWbv0/bt1R.d9PC', 'siswa', '0110222009', '0110222009', NULL, '2026-03-09 15:53:17', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(33, 'Qotrun Nada', 'sqotrunada121@gmail.com', NULL, '$2y$12$6p0JK5QryDG.fv9AZr2JtuvBl1/UK1xVioQB2HuD12lbYAybmqMra', 'guru', 'sqotrunada121@gmail.com', NULL, NULL, '2026-04-02 06:00:53', '2026-04-21 13:11:17', NULL, NULL, 1, NULL),
	(35, 'Haikal Ridho', NULL, NULL, '$2y$12$OaIgNqzHC.bsWYQmSP9zLuZAqTt5bG9WdObRz/M0kE1bUOoOcGNq2', 'siswa', '0110222302', '0110222302', NULL, '2026-04-23 13:45:20', '2026-05-17 17:42:49', NULL, 12, 1, 'Lulus'),
	(36, 'Yanuar Rahma', NULL, NULL, '$2y$12$tT6l5LvtPaBkgImuGzHnA.mModWgZIRulE8rpWcxI72Aeygzh8qCC', 'siswa', '0110222015', '0110222015', NULL, '2026-04-23 13:45:20', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(37, 'Muhammad Risky', NULL, NULL, '$2y$12$VXPItfcZQEE1cbMizYF8mOyuqOnehroFaGOVYLwxG5N/kIR9DNEVq', 'siswa', '0110222125', '0110222125', NULL, '2026-05-16 12:30:58', '2026-05-17 17:42:49', NULL, 12, 0, 'Lulus'),
	(38, 'Administrator', 'admin@smkalfhafidz.sch.id', '2026-05-18 00:39:40', '$2y$12$INEG6xpXOMVr9AMgPCb6seIanUIQIDLu7GJz57g2mEnk.NtO1xfHi', 'admin', 'admin', NULL, NULL, '2026-05-17 17:02:37', '2026-05-17 17:02:37', NULL, NULL, 1, NULL),
	(39, 'Siswa 1', 'siswa1@test.com', '2026-05-18 00:39:44', '$2y$12$s5BnuXKx7f5F6W47fx/mju.i8W8dRnytoFgU1.FTNvL1i0.T10qnK', 'siswa', '0110222301', '0110222301', NULL, '2026-05-17 17:09:17', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(40, 'Siswa 5', 'siswa5@test.com', '2026-05-18 00:39:45', '$2y$12$q7z7e4zqQzQA2w5WPiRgpegGF4uLgrx6LpodTYipQVdr/qXN1tlNa', 'siswa', '0110222303', '0110222303', NULL, '2026-05-17 17:31:40', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(41, 'Siswa 6', 'siswa6@test.com', '2026-05-18 00:39:46', '$2y$12$gB8yK09oE/CvCN.DbYHNi.QB608OobsKxq5Q4uZ.AFoDgC5nIlm8G', 'siswa', '0110222304', '0110222304', NULL, '2026-05-17 17:31:40', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(42, 'Siswa 7', 'siswa7@test.com', '2026-05-18 00:39:46', '$2y$12$hMKTHUEA4YxdA0Umgrvs7Oh/.Lyzohc18Zd8neX8N1g9ZjI6RpLD2', 'siswa', '0110222305', '0110222305', NULL, '2026-05-17 17:31:41', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(43, 'Siswa 8', 'siswa8@test.com', '2026-05-18 00:39:47', '$2y$12$FC6J3Di09uLNqNSOQMy4/.8WYKQWvIkPX1Xwt5txy9aP9dOB/Ny0y', 'siswa', '0110222306', '0110222306', NULL, '2026-05-17 17:31:41', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(44, 'Siswa 9', 'siswa9@test.com', '2026-05-18 00:39:48', '$2y$12$f48.0OW/.CjGwsANbLLL4eJNQiqF5M8GneMJcG50KZtvgG0D2bzA.', 'siswa', '0110222307', '0110222307', NULL, '2026-05-17 17:31:41', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(45, 'Siswa 10', 'siswa10@test.com', '2026-05-18 00:39:49', '$2y$12$sAB6jeOCJJtZ.F.G6rzNreKWzVhoCJVyYUYH9mRVtjfa.3xm0HGfC', 'siswa', '0110222308', '0110222308', NULL, '2026-05-17 17:31:41', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(46, 'Siswa 11', 'siswa11@test.com', '2026-05-18 00:39:50', '$2y$12$YSmrQOW3VcCzVGewaGq1DuD/biDUNSVG9TqLh5lCQ.1TX3oucH2cu', 'siswa', '0110222309', '0110222309', NULL, '2026-05-17 17:31:42', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(47, 'Siswa 12', 'siswa12@test.com', '2026-05-18 00:39:52', '$2y$12$/pyx422p8ehsrb6bJ2hUFuSfT26Bgm3Lqn/kEw.2urxpeelulomb2', 'siswa', '0110222310', '0110222310', NULL, '2026-05-17 17:31:42', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(48, 'Siswa 13', 'siswa13@test.com', '2026-05-18 00:40:13', '$2y$12$VuQIMsyTcPxs01MUNlbGbOTYGUo3M47IiWDtnw60teGswXf84MIH.', 'siswa', '0110222311', '0110222311', NULL, '2026-05-17 17:31:42', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(49, 'Siswa 14', 'siswa14@test.com', '2026-05-18 00:40:14', '$2y$12$M9997.9IRFiSy/0rVCt02erBlyhgwjd8rhWgo7yz2FY4N3fjxmypW', 'siswa', '0110222312', '0110222312', NULL, '2026-05-17 17:31:42', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(50, 'Siswa 15', 'siswa15@test.com', '2026-05-18 00:40:15', '$2y$12$I4ot9la3I1oQjdeYwj6Yaepdj23x8HeWSU.G6M/WpzKyJ0IdxrKDi', 'siswa', '0110222313', '0110222313', NULL, '2026-05-17 17:31:42', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(51, 'Siswa 16', 'siswa16@test.com', '2026-05-18 00:40:15', '$2y$12$iAGY5i43LcVUW99RDTyhG.rGGeb17uVA0lOMySxEsiXTfDRISmA3m', 'siswa', '0110222314', '0110222314', NULL, '2026-05-17 17:31:43', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(52, 'Siswa 17', 'siswa17@test.com', '2026-05-18 00:40:17', '$2y$12$QjTqwR4u5L3RV24l5JHcVuzgDbytLqiB7sw6itZAn5GbpBFOTXGC6', 'siswa', '0110222315', '0110222315', NULL, '2026-05-17 17:31:43', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(53, 'Siswa 18', 'siswa18@test.com', '2026-05-18 00:40:16', '$2y$12$mEbyIbCCOq.uFovdKCkN8uUCHAoVUIggHGAQMB/UdoZonD3GUVZIy', 'siswa', '0110222316', '0110222316', NULL, '2026-05-17 17:31:43', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(54, 'Siswa 19', 'siswa19@test.com', '2026-05-18 00:40:17', '$2y$12$oynTRLSIr19T4jthvHG67uqB5APHALBhB0uMXu56I1XnF8cvq2bnm', 'siswa', '0110222317', '0110222317', NULL, '2026-05-17 17:31:43', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(55, 'Siswa 20', 'siswa20@test.com', '2026-05-18 00:40:18', '$2y$12$w8Q9fe.cq1cy/e0gVZlQ3u/a/M98Zov03DIr9Ya8fw4Fx4dIIQfs.', 'siswa', '0110222318', '0110222318', NULL, '2026-05-17 17:31:44', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(56, 'Siswa 21', 'siswa21@test.com', '2026-05-18 00:40:19', '$2y$12$d3Zd8T1f.z239P5809YD1u1mT3Zru121q6t03pKcGtFuIXdq1Uv/e', 'siswa', '0110222319', '0110222319', NULL, '2026-05-17 17:31:44', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(57, 'Siswa 22', 'siswa22@test.com', '2026-05-18 00:40:20', '$2y$12$1RbpD7WLujh1.uUVNQuWZuw8vU03CeMBNkO9I54MT5siMi7GGIhaq', 'siswa', '0110222320', '0110222320', NULL, '2026-05-17 17:31:44', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(58, 'Siswa 23', 'siswa23@test.com', '2026-05-18 00:40:20', '$2y$12$o9YNa17R6qKnPkiLcy.FSuezC6ORCeKJgPLuhAow7/TdQGJ5umouq', 'siswa', '0110222321', '0110222321', NULL, '2026-05-17 17:31:44', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(59, 'Siswa 24', 'siswa24@test.com', '2026-05-18 00:40:21', '$2y$12$pPFBgJv0TD2w/2C6K7E4fOiCu47fLIi2MwCPGIka0/FynozgSTVyi', 'siswa', '0110222322', '0110222322', NULL, '2026-05-17 17:31:44', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(60, 'Siswa 25', 'siswa25@test.com', '2026-05-18 00:40:22', '$2y$12$Z4XxBUfqOW5W9cDDFnDxJOe9xH5bgn4cgqlKP5qpfwcg2iy0rDj/.', 'siswa', '0110222323', '0110222323', NULL, '2026-05-17 17:31:45', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(61, 'Siswa 26', 'siswa26@test.com', '2026-05-18 00:40:22', '$2y$12$CKA6xuOzfsTiS87d3z6Nne.S4TTllfsVZ9jZ1eb/JE9TKqZ2wYb7C', 'siswa', '0110222324', '0110222324', NULL, '2026-05-17 17:31:45', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(62, 'Siswa 27', 'siswa27@test.com', '2026-05-18 00:40:23', '$2y$12$NRdw4UbafbWn7jU6hGLWXuS1oIAsNi8t1Vs0w4JN6twe1TSb7tD4y', 'siswa', '0110222325', '0110222325', NULL, '2026-05-17 17:31:45', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(63, 'Siswa 28', 'siswa28@test.com', '2026-05-18 00:40:25', '$2y$12$U0HadsDGRGgh/Tu3v6KpD.hvBOY9f5zSIZRxBms8dzC25CIfUDexG', 'siswa', '0110222326', '0110222326', NULL, '2026-05-17 17:31:45', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(64, 'Siswa 29', 'siswa29@test.com', '2026-05-18 00:40:25', '$2y$12$7FOMkF3vOXnDqFfBCOGG6eu5Cq2Kom07lomRsbXm74R4p36dhpBNS', 'siswa', '0110222327', '0110222327', NULL, '2026-05-17 17:31:46', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(65, 'Siswa 30', 'siswa30@test.com', '2026-05-18 00:40:26', '$2y$12$0Tx5GjjdgrhR0wUONuB1Ked128T1z7tKV1KCFTh4hlAVhkURBloW.', 'siswa', '0110222328', '0110222328', NULL, '2026-05-17 17:31:46', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(66, 'Siswa 31', 'siswa31@test.com', '2026-05-18 00:40:27', '$2y$12$D.fY/EGfajNbpJ3QX7wI0eNSqVlEaF.CSLRuOnnki.hvvbkTkjTkC', 'siswa', '0110222329', '0110222329', NULL, '2026-05-17 17:31:46', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(67, 'Siswa 32', 'siswa32@test.com', '2026-05-18 00:40:27', '$2y$12$BuQYeqlnVdS9UDgFbkkMpOm5H.orbTnDHUdboEJ1uyGV/29r2fH22', 'siswa', '0110222330', '0110222330', NULL, '2026-05-17 17:31:46', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(68, 'Siswa 33', 'siswa33@test.com', '2026-05-18 00:40:28', '$2y$12$D81Gr/DpOAWxvZUW2WhgCO4W9.EIYEnzTXS6vrLrBOdfmXvmacpSS', 'siswa', '0110222331', '0110222331', NULL, '2026-05-17 17:31:46', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(69, 'Siswa 34', 'siswa34@test.com', '2026-05-18 00:40:29', '$2y$12$hAWtP.pUAxGuQWTiWvOXI.hA10IEbJPr2aqkdWk9WK1rpl9uVkdI2', 'siswa', '0110222332', '0110222332', NULL, '2026-05-17 17:31:47', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(70, 'Siswa 35', 'siswa35@test.com', '2026-05-18 00:40:30', '$2y$12$pl/6bkMovVV/yKt95zoJiu/keT4jebDQptII2iOdahBINoYCQbK0W', 'siswa', '0110222333', '0110222333', NULL, '2026-05-17 17:31:47', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(71, 'Siswa 36', 'siswa36@test.com', '2026-05-18 00:40:31', '$2y$12$uhCghfYeu2KqPY8dNSCIiuvaVLHs.WGiSqfv6yaSh5rBVCv2Mj8Aa', 'siswa', '0110222334', '0110222334', NULL, '2026-05-17 17:31:47', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(72, 'Siswa 37', 'siswa37@test.com', '2026-05-18 00:40:32', '$2y$12$ZC6TgIrAOd0r0vrR3ujOrO/mOycpMU9sx/LmruX74hfFmGonIpoj2', 'siswa', '0110222335', '0110222335', NULL, '2026-05-17 17:31:47', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(73, 'Siswa 38', 'siswa38@test.com', '2026-05-18 00:40:33', '$2y$12$LEqDXpvrPrJ2c.KJ.3S3jOpJpPJZ/IyQpPcqGc3f1ThGefKtm5XyK', 'siswa', '0110222336', '0110222336', NULL, '2026-05-17 17:31:48', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(74, 'Siswa 39', 'siswa39@test.com', '2026-05-18 00:40:34', '$2y$12$JElVJRYWOlvuj6x/D.ba7utO8dWRItOW/G.OQUcn45z0RS9UdtTpu', 'siswa', '0110222337', '0110222337', NULL, '2026-05-17 17:31:48', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(75, 'Siswa 40', 'siswa40@test.com', '2026-05-18 00:40:34', '$2y$12$8M21LGaVWPUDqEh1t7MpwueKj/8EIemUUOAaJFLJZuJcIOISeHAES', 'siswa', '0110222338', '0110222338', NULL, '2026-05-17 17:31:48', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(76, 'Siswa 41', 'siswa41@test.com', '2026-05-18 00:40:35', '$2y$12$d3suzLhUvOGkM4grbfk5pu/Wcpqip/0Nb9KKOy9hUD/qGWfD0hMV2', 'siswa', '0110222339', '0110222339', NULL, '2026-05-17 17:31:48', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(77, 'Siswa 42', 'siswa42@test.com', '2026-05-18 00:40:36', '$2y$12$/wrofL/WpOaKRHUSdK8MzOEsjwsQAMcis/qKRUMC3wh9PBxXkyQ/O', 'siswa', '0110222340', '0110222340', NULL, '2026-05-17 17:31:48', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(78, 'Siswa 43', 'siswa43@test.com', '2026-05-18 00:40:36', '$2y$12$JhLxzhcP6EGZ9EfkHgIuX.6OZpPUkKgcQtYT0ORuouUovNUjJwXHi', 'siswa', '0110222341', '0110222341', NULL, '2026-05-17 17:31:49', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(79, 'Siswa 44', 'siswa44@test.com', '2026-05-18 00:40:37', '$2y$12$x.W.tZOxd9ydo3B5U6szdeQbaK.Ae.b.LaYiorNIh.YDjSkmj2oMa', 'siswa', '0110222342', '0110222342', NULL, '2026-05-17 17:31:49', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(80, 'Siswa 45', 'siswa45@test.com', '2026-05-18 00:40:40', '$2y$12$/ScERbo152C1nCBXMi2YC.H2SOVHzhf43Ihg/Ffqf60ZhCfeSFAOC', 'siswa', '0110222343', '0110222343', NULL, '2026-05-17 17:31:49', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(81, 'Siswa 46', 'siswa46@test.com', '2026-05-18 00:40:41', '$2y$12$uMatBziCz9XEK6z7fxtoau0.1ivSZYR1EwXdqT7dfEuepFOTvVoXW', 'siswa', '0110222344', '0110222344', NULL, '2026-05-17 17:31:49', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(82, 'Siswa 47', 'siswa47@test.com', '2026-05-18 00:40:42', '$2y$12$ckJ7p42TuxtcB99FHL/G3uWnC82BPYWIMDptDaxlDouSr.iBVGin6', 'siswa', '0110222345', '0110222345', NULL, '2026-05-17 17:31:50', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(83, 'Siswa 48', 'siswa48@test.com', '2026-05-18 00:40:42', '$2y$12$jZzP.WT3Aqhqm596smB0EOMg6KHJ6MGDQ.g/7OoBAuFwU3pmOc.oi', 'siswa', '0110222346', '0110222346', NULL, '2026-05-17 17:31:50', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(84, 'Siswa 49', 'siswa49@test.com', '2026-05-18 00:40:43', '$2y$12$g9OPU7exPI6kvN1n6mFV7OBvlUWEd75T42EhNh2.fx4PsPOdkVeCa', 'siswa', '0110222347', '0110222347', NULL, '2026-05-17 17:31:50', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(85, 'Siswa 50', 'siswa50@test.com', '2026-05-18 00:40:44', '$2y$12$MvhOrblcmYMF3zuSHBGoKe51ym.t5.uA4wmuGof08clyBUW8QBX3G', 'siswa', '0110222348', '0110222348', NULL, '2026-05-17 17:31:50', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(86, 'Siswa 51', 'siswa51@test.com', '2026-05-18 00:40:44', '$2y$12$2UjAHwzFQ1l//kNHll1qweMbWSsUpIQ2ayBjsR0qxzQLIeJ12UB1C', 'siswa', '0110222349', '0110222349', NULL, '2026-05-17 17:31:50', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(87, 'Siswa 52', 'siswa52@test.com', '2026-05-18 00:40:45', '$2y$12$aThX1No9bUid7P2aHqm3Ju1/XUS9LfZB/CUAXtGkjcnEB6eYe32K6', 'siswa', '0110222350', '0110222350', NULL, '2026-05-17 17:31:51', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(88, 'Siswa 53', 'siswa53@test.com', '2026-05-18 00:40:46', '$2y$12$W1ePh4cWFsNoXf7BDZJtOeh6l2F0zmp9ExwhcDTLsdbvDUqliKEnK', 'siswa', '0110222351', '0110222351', NULL, '2026-05-17 17:31:51', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(89, 'Siswa 54', 'siswa54@test.com', '2026-05-18 00:40:47', '$2y$12$OUs./PAPae9dhi8CV1d5luero8oo2VNAyFSkKIl2VVY9PI3tSMnGu', 'siswa', '0110222352', '0110222352', NULL, '2026-05-17 17:31:51', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(90, 'Siswa 55', 'siswa55@test.com', '2026-05-18 00:40:47', '$2y$12$Gkxw/XuXIl3bStCEBpqlKO/CmAPHgAwfFoT8GXGuAdwTS7od0HxLK', 'siswa', '0110222353', '0110222353', NULL, '2026-05-17 17:31:51', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(91, 'Siswa 56', 'siswa56@test.com', '2026-05-18 00:40:48', '$2y$12$rEJaBV8YZ39/eOCaOvmXy.Hhl2dDk7MPC/aRFz7naMIRWAmupzsHa', 'siswa', '0110222354', '0110222354', NULL, '2026-05-17 17:31:51', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(92, 'Siswa 57', 'siswa57@test.com', '2026-05-18 00:40:49', '$2y$12$NO8tQ9a7Zy4BOf/cclWLxeHAlixGLx5g4BZwIQzoomTKgztll9eGG', 'siswa', '0110222355', '0110222355', NULL, '2026-05-17 17:31:52', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(93, 'Siswa 58', 'siswa58@test.com', '2026-05-18 00:40:49', '$2y$12$uFzBs9dYXg5h9Yg9bF1BDeCQqmvBo9QH1W.tJSmqavDm35Sr6J6Ba', 'siswa', '0110222356', '0110222356', NULL, '2026-05-17 17:31:52', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(94, 'Siswa 59', 'siswa59@test.com', '2026-05-18 00:40:50', '$2y$12$KK8evxFJvPR4vF1A3Eu02exAPU4e5jHvbII/hkk3kIAjE6hOfAbVW', 'siswa', '0110222357', '0110222357', NULL, '2026-05-17 17:31:52', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(95, 'Siswa 60', 'siswa60@test.com', '2026-05-18 00:40:51', '$2y$12$RQifgX1tNJhj3ecJWiTqb.H79uyOnORpUf6HMc.2WzbzcyVwimDFS', 'siswa', '0110222358', '0110222358', NULL, '2026-05-17 17:31:52', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(96, 'Siswa 61', 'siswa61@test.com', '2026-05-18 00:40:52', '$2y$12$Tuvv44sGqunCUMED4rosEeW9u/cSoLPvIJFJ/kj3VusqcSzUZDfW.', 'siswa', '0110222359', '0110222359', NULL, '2026-05-17 17:31:52', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(97, 'Siswa 62', 'siswa62@test.com', '2026-05-18 00:40:53', '$2y$12$KPDjbKNQ1aKIzr3bjHBq3u1BXCb7dl3FZlEhpKV4jU9VOq0V7Afj2', 'siswa', '0110222360', '0110222360', NULL, '2026-05-17 17:31:53', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(98, 'Siswa 63', 'siswa63@test.com', '2026-05-18 00:40:54', '$2y$12$NWGJyJPsMjcH/fCL.9O5Ie.H91HlY0GzHRVcInw7i/gFmjReGa3FO', 'siswa', '0110222361', '0110222361', NULL, '2026-05-17 17:31:53', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(99, 'Siswa 64', 'siswa64@test.com', '2026-05-18 00:40:55', '$2y$12$l2YtrLwBojT2aDWb8fHnmeMNBOEEnnHfs5PVJ0bfwKWcej9mzR8j6', 'siswa', '0110222362', '0110222362', NULL, '2026-05-17 17:31:53', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(100, 'Siswa 65', 'siswa65@test.com', '2026-05-18 00:40:55', '$2y$12$IgTAf50tuIgHee9we83LvuZjd89RMtmKMj15tVEEBaZOte0Xsg9AW', 'siswa', '0110222363', '0110222363', NULL, '2026-05-17 17:31:53', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(101, 'Siswa 66', 'siswa66@test.com', '2026-05-18 00:40:56', '$2y$12$WKHgTjPOxQxSBmwCBV9p7OfviAjemyGPokz5oG3hsc0mlsMAowHJq', 'siswa', '0110222364', '0110222364', NULL, '2026-05-17 17:31:54', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(102, 'Siswa 67', 'siswa67@test.com', '2026-05-18 00:40:57', '$2y$12$aNA0zDrufY/Tlq8M9YUuLeV0hMcYvf.r7ThDM7YnFEasZkZ.u7iTS', 'siswa', '0110222365', '0110222365', NULL, '2026-05-17 17:31:54', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(103, 'Siswa 68', 'siswa68@test.com', '2026-05-18 00:40:58', '$2y$12$ZbYCxrKZSgdUCbDYfOyiSO8DYJ8gAOCuQij4U1wU1igVZZnpDHuZW', 'siswa', '0110222366', '0110222366', NULL, '2026-05-17 17:31:54', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(104, 'Siswa 69', 'siswa69@test.com', '2026-05-18 00:41:00', '$2y$12$8EP7Z9LOxYszful1h6WVfuIQ7Buwq8E14R7H7cJQz0EnIUD4K21VW', 'siswa', '0110222367', '0110222367', NULL, '2026-05-17 17:31:54', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(105, 'Siswa 70', 'siswa70@test.com', '2026-05-18 00:41:01', '$2y$12$e1Jzwwgdejz5u0bkLi15KurJXGDSw0A0fzZrqaoKarXu815BwNg8y', 'siswa', '0110222368', '0110222368', NULL, '2026-05-17 17:31:54', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(106, 'Siswa 71', 'siswa71@test.com', '2026-05-18 00:41:02', '$2y$12$qxhIPapLP7xYl5MgvzNky.9H1TjgwJFY9ualpnMOIUPEEaRAQjAPO', 'siswa', '0110222369', '0110222369', NULL, '2026-05-17 17:31:55', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(107, 'Siswa 72', 'siswa72@test.com', '2026-05-18 00:41:03', '$2y$12$XzgX/X6Rfcw0yhQdD0OsOeeWo/gC6DuWiYZXGsGVExnvfSpZcCnFK', 'siswa', '0110222370', '0110222370', NULL, '2026-05-17 17:31:55', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(108, 'Siswa 73', 'siswa73@test.com', '2026-05-18 00:41:03', '$2y$12$6RkLVfQvAFh3M52TTw8JGu8/Sd16jxS053P41wV/VlkejM9aPhONq', 'siswa', '0110222371', '0110222371', NULL, '2026-05-17 17:31:55', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(109, 'Siswa 74', 'siswa74@test.com', '2026-05-18 00:41:04', '$2y$12$o7C6bNqhQ5Ei5YVbS3I7rOb3sJKclXYRBMK1tuosbFrG6GcU4BsGu', 'siswa', '0110222372', '0110222372', NULL, '2026-05-17 17:31:55', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(110, 'Siswa 75', 'siswa75@test.com', '2026-05-18 00:41:04', '$2y$12$HGsp7aIiAH5dVkG4UAX.VuIoVPsRq8EB9MpsNtjDQGgcUev3p8iH6', 'siswa', '0110222373', '0110222373', NULL, '2026-05-17 17:31:55', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(111, 'Siswa 76', 'siswa76@test.com', '2026-05-18 00:41:05', '$2y$12$HImfML7urmi51RaJkASSsuaSql5KqMWROIL4xYY3NxMnHvWPoJhvG', 'siswa', '0110222374', '0110222374', NULL, '2026-05-17 17:31:56', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(112, 'Siswa 77', 'siswa77@test.com', '2026-05-18 00:41:06', '$2y$12$LcKbSVQZrW97ugHL2eTO3O47GqzBNNDibEdV/apkAZXq/fI00rdCa', 'siswa', '0110222375', '0110222375', NULL, '2026-05-17 17:31:56', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(113, 'Siswa 78', 'siswa78@test.com', '2026-05-18 00:41:07', '$2y$12$4K0qTjkniZf5jXZi4UNP.OuwjMsDoL5S9T2Orjt76O9ttoYv6Shty', 'siswa', '0110222376', '0110222376', NULL, '2026-05-17 17:31:56', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(114, 'Siswa 79', 'siswa79@test.com', '2026-05-18 00:41:08', '$2y$12$o8EfkIJ7Q3fZmaF1cWzFZ.PdtebBmRIcrlC7XcveqoXpoKhYVrJQy', 'siswa', '0110222377', '0110222377', NULL, '2026-05-17 17:31:56', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(115, 'Siswa 80', 'siswa80@test.com', '2026-05-18 00:41:08', '$2y$12$yCMJOHUmTWkiLKgHJIC7negoAt7/yOqwMQcJKfaSZ6Qokxn/qMQcC', 'siswa', '0110222378', '0110222378', NULL, '2026-05-17 17:31:57', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(116, 'Siswa 81', 'siswa81@test.com', '2026-05-18 00:41:09', '$2y$12$f/NaNjY8NA7Q9DL0hRJN0uofRHFWptu/zDOfuEEatxSspti8KHJy6', 'siswa', '0110222379', '0110222379', NULL, '2026-05-17 17:31:57', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(117, 'Siswa 82', 'siswa82@test.com', '2026-05-18 00:41:10', '$2y$12$mIPSO344yTXFv4wwPLj4XOb/RdQry3wZCFXaFFY90j69L/vN6c/Pi', 'siswa', '0110222380', '0110222380', NULL, '2026-05-17 17:31:57', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(118, 'Siswa 83', 'siswa83@test.com', '2026-05-18 00:41:11', '$2y$12$bLim044MqE7ltu1QOLF60uRHpHX5WEf85K44Vi4NdzSVL7r8tvTI2', 'siswa', '0110222381', '0110222381', NULL, '2026-05-17 17:31:57', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(119, 'Siswa 84', 'siswa84@test.com', '2026-05-18 00:41:12', '$2y$12$..1cOVCiHm06gilzMHNmdO70paI5jJEUqph1.hAMLyoWYl.SUSpBW', 'siswa', '0110222382', '0110222382', NULL, '2026-05-17 17:31:57', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(120, 'Siswa 85', 'siswa85@test.com', '2026-05-18 00:41:12', '$2y$12$UCX0t5BRD3GwNmOIZoTrke5hj//AMEI6sCPLYPiFdsS8yeCHYWDRW', 'siswa', '0110222383', '0110222383', NULL, '2026-05-17 17:31:58', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(121, 'Siswa 86', 'siswa86@test.com', '2026-05-18 00:41:15', '$2y$12$HsvD7YjCqzmEJOxLS9vbNO9D8Hx8GKUYOXYZRe2B20U0nL/QkFxRS', 'siswa', '0110222384', '0110222384', NULL, '2026-05-17 17:31:58', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(122, 'Siswa 87', 'siswa87@test.com', '2026-05-18 00:41:16', '$2y$12$FK8cj6YlXWbwo/MenYhjQOT0pkaqskMTzTMU5O5DlypxAnENeu9Pe', 'siswa', '0110222385', '0110222385', NULL, '2026-05-17 17:31:58', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(123, 'Siswa 88', 'siswa88@test.com', '2026-05-18 00:41:17', '$2y$12$Tn.t1yt4SbyBqiU.da5/j.SGr7JkInKRdtqfybTPn/U8nQL8Q69JC', 'siswa', '0110222386', '0110222386', NULL, '2026-05-17 17:31:58', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(124, 'Siswa 89', 'siswa89@test.com', '2026-05-18 00:41:17', '$2y$12$.NYyPrk5vbXiu1Tnw42jPOjpyN275gIYN1LlcmtS7w5qNGE79rmJK', 'siswa', '0110222387', '0110222387', NULL, '2026-05-17 17:31:59', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(125, 'Siswa 90', 'siswa90@test.com', '2026-05-18 00:41:18', '$2y$12$XrZFJ1.CZ7x3Tfx5ilDCp.NR0IrZYc2kgqLsM9QNbJd7wmZd06CSi', 'siswa', '0110222388', '0110222388', NULL, '2026-05-17 17:31:59', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(126, 'Siswa 91', 'siswa91@test.com', '2026-05-18 00:41:18', '$2y$12$BLjRZ3TPtJVuO1ltgxcpEO2KJ5mkZ9/AvW/R3H5h/aYAoUES4JM1S', 'siswa', '0110222389', '0110222389', NULL, '2026-05-17 17:31:59', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(127, 'Siswa 92', 'siswa92@test.com', '2026-05-18 00:41:19', '$2y$12$kyYZVg6leTRbbbymBrt3buo07IPu4c7OeVV1YxqQ9oLIqjX1U9DP2', 'siswa', '0110222390', '0110222390', NULL, '2026-05-17 17:31:59', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(128, 'Siswa 93', 'siswa93@test.com', '2026-05-18 00:41:19', '$2y$12$f8Z5/SXdnmOIHPX5Cft9eOCC3ATDyqxy7GW9RIxxgOGfciqMSe1Ky', 'siswa', '0110222391', '0110222391', NULL, '2026-05-17 17:31:59', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(129, 'Siswa 94', 'siswa94@test.com', '2026-05-18 00:41:20', '$2y$12$WpH4kmILIyz8XLJh9mx2ZemXFifJBYPXZoMvNnxXi4sUZ05kJ45Qe', 'siswa', '0110222392', '0110222392', NULL, '2026-05-17 17:32:00', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(130, 'Siswa 95', 'siswa95@test.com', '2026-05-18 00:41:21', '$2y$12$YHVUsDEeKi6tSu27YarbnuZjkSO9f8f0ttCDDe8/uHnAwnjylwIqm', 'siswa', '0110222393', '0110222393', NULL, '2026-05-17 17:32:00', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(131, 'Siswa 96', 'siswa96@test.com', '2026-05-18 00:41:22', '$2y$12$gXZmV7B4RiE01tjDM8zG9./kNCheTDNkqLDmD6jOlQtRjypPeZXkC', 'siswa', '0110222394', '0110222394', NULL, '2026-05-17 17:32:00', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(132, 'Siswa 97', 'siswa97@test.com', '2026-05-18 00:41:23', '$2y$12$bLUBWeaklY2mbunlSZ8/GeeP/.S1mUc4i11ewG0m1BU2MZ8ZPi8ca', 'siswa', '0110222395', '0110222395', NULL, '2026-05-17 17:32:00', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(133, 'Siswa 98', 'siswa98@test.com', '2026-05-18 00:41:23', '$2y$12$877sBqm09dB064WOhXzB5uEYy/eYyC4UutOhXV9pVA3MdSXY/XWAC', 'siswa', '0110222396', '0110222396', NULL, '2026-05-17 17:32:01', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(134, 'Siswa 99', 'siswa99@test.com', '2026-05-18 00:41:24', '$2y$12$fiVTI8eFW8OfVnVsaTDXcOTc4YkCr8mlVlYshgPiWHG.pVwBzU8ga', 'siswa', '0110222397', '0110222397', NULL, '2026-05-17 17:32:01', '2026-05-17 17:42:49', NULL, 12, 1, NULL),
	(135, 'Siswa 100', 'siswa100@test.com', '2026-05-18 00:41:27', '$2y$12$16bsy1Fv/jMxqdSw/L1jGuJqYfnmel3mERXc0HVNB4fRvBsd9XCRG', 'siswa', '0110222398', '0110222398', NULL, '2026-05-17 17:32:01', '2026-05-17 17:42:49', NULL, 12, 1, NULL);

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
