#!/usr/bin/env pwsh
# =============================================================================
# SETUP AWAL GCP (Hanya perlu dijalankan SEKALI)
# =============================================================================

param(
    [string]$ProjectId  = "presensi-alhafidz",
    [string]$Region     = "asia-southeast2",
    [string]$DbInstance = "sintia-db-gcp",
    [string]$DbName     = "absensi_smk_alhafidz", # Jika kondisinya ingin mengimport file sql maka namanya harus sama dengan file sql yang akan diimport
    [string]$DbPassword = "Wnakmi42GCP" # diubah jika sesuai kebutuhan dan harus sama dengan password  di setup-gcp.sh
)

Write-Host "============================================" -ForegroundColor Magenta
Write-Host " SETUP AWAL GCP - SMK AL HAFIDZ" -ForegroundColor Magenta
Write-Host "============================================" -ForegroundColor Magenta

# 1. Set project aktif
Write-Host "`n[1/5] Set project GCP..." -ForegroundColor Yellow
gcloud config set project $ProjectId
Write-Host "     OK" -ForegroundColor Green

# 2. Aktifkan semua layanan yang dibutuhkan
Write-Host "`n[2/5] Mengaktifkan layanan GCP..." -ForegroundColor Yellow
gcloud services enable `
    run.googleapis.com `
    sqladmin.googleapis.com `
    cloudbuild.googleapis.com `
    artifactregistry.googleapis.com
Write-Host "     OK" -ForegroundColor Green

# 3. Buat Cloud SQL (MySQL free-ish tier)
Write-Host "`n[3/5] Membuat Cloud SQL (db-f1-micro)..." -ForegroundColor Yellow
Write-Host "     Proses ini memakan waktu 5-10 menit, harap tunggu..."
gcloud sql instances create $DbInstance `
    --database-version=MYSQL_8_0 `
    --tier=db-f1-micro `
    --region=$Region `
    --root-password=$DbPassword `
    --storage-auto-increase `
    --no-backup
Write-Host "     OK" -ForegroundColor Green

# 4. Buat database di dalam Cloud SQL
Write-Host "`n[4/5] Membuat database $DbName..." -ForegroundColor Yellow
gcloud sql databases create $DbName --instance=$DbInstance
Write-Host "     OK" -ForegroundColor Green

# 5. Tampilkan IP Cloud SQL
Write-Host "`n[5/5] IP Address Cloud SQL Anda:" -ForegroundColor Yellow
$DB_IP = gcloud sql instances describe $DbInstance `
    --format="value(ipAddresses[0].ipAddress)"
Write-Host "     DB_HOST = $DB_IP" -ForegroundColor Green

Write-Host "`n============================================" -ForegroundColor Magenta
Write-Host " SETUP SELESAI! Sekarang jalankan:" -ForegroundColor Green
Write-Host " .\deploy-gcp.ps1" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Magenta
