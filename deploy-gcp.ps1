#!/usr/bin/env pwsh
# =============================================================================
# SCRIPT DEPLOY KE GOOGLE CLOUD RUN
# Sistem Informasi Absensi SMK Al Hafidz
# =============================================================================
# Cara pakai:
# > cd E:\Sintia\GCP\Tugas_Akhir
# > .\deploy-gcp.ps1
# =============================================================================

param(
    [string]$ProjectId    = "presensi-alhafidz",
    [string]$Region       = "asia-southeast2",
    [string]$ServiceName  = "presensi-alhafidz",
    [string]$DbInstance   = "presensi-db-gcp",
    [string]$DbName       = "presensi_db1",
    [string]$DbUser       = "root",
    [string]$DbPassword   = "Wnakmi42GCP",
    [string]$AppUrl       = "https://dashboard.forumapi.my.id",
    [string]$AppKey       = "base64:Br9Ve9nWUHcC1ocU0LnnMQgkraQdPzeDRhuCPd0uQjA="
)

$SOURCE_DIR = "E:\Sintia\Staging\Tugas_Akhir"
$GCP_DIR    = $PSScriptRoot

Write-Host "============================================" -ForegroundColor Cyan
Write-Host " DEPLOY GCP CLOUD RUN - SMK AL HAFIDZ" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# STEP 1: Salin file Docker + config ke root project sementara
Write-Host "`n[1/6] Menyalin Dockerfile & config GCP ke project..." -ForegroundColor Yellow
Copy-Item "$GCP_DIR\Dockerfile"    "$SOURCE_DIR\Dockerfile"    -Force
Copy-Item "$GCP_DIR\.dockerignore" "$SOURCE_DIR\.dockerignore" -Force
Copy-Item "$GCP_DIR\gcp-config"    "$SOURCE_DIR\gcp-config"    -Recurse -Force
Write-Host "     OK" -ForegroundColor Green

# STEP 2: Build frontend
Write-Host "`n[2/6] Membangun aset frontend..." -ForegroundColor Yellow
Set-Location $SOURCE_DIR
npm run build
Write-Host "     OK" -ForegroundColor Green

# STEP 3: Ambil IP Cloud SQL
Write-Host "`n[3/6] Mengambil endpoint Cloud SQL..." -ForegroundColor Yellow
$DB_HOST = gcloud sql instances describe $DbInstance `
    --project=$ProjectId `
    --format="value(ipAddresses[0].ipAddress)" 2>$null

if (-not $DB_HOST) {
    Write-Host "     PERINGATAN: Cloud SQL belum ada. Menggunakan IP placeholder." -ForegroundColor Red
    Write-Host "     Jalankan setup-gcp.ps1 terlebih dahulu!" -ForegroundColor Red
    $DB_HOST = "GANTI_DB_HOST"
}
Write-Host "     DB_HOST = $DB_HOST" -ForegroundColor Green

# STEP 4: Deploy ke Cloud Run
Write-Host "`n[4/6] Deploying ke Cloud Run ($Region)..." -ForegroundColor Yellow
gcloud run deploy $ServiceName `
    --source $SOURCE_DIR `
    --region $Region `
    --platform managed `
    --allow-unauthenticated `
    --memory 512Mi `
    --cpu 1 `
    --min-instances 0 `
    --max-instances 3 `
    --project $ProjectId `
    --set-env-vars "APP_ENV=production,APP_DEBUG=false,APP_KEY=$AppKey,APP_URL=$AppUrl,DB_CONNECTION=mysql,DB_HOST=$DB_HOST,DB_PORT=3306,DB_DATABASE=$DbName,DB_USERNAME=$DbUser,DB_PASSWORD=$DbPassword,SESSION_DRIVER=database,CACHE_STORE=database,QUEUE_CONNECTION=database,PROMETHEUS_ALLOWED_IPS=*"
Write-Host "     OK" -ForegroundColor Green

# STEP 5: Bersihkan file sementara dari root project
Write-Host "`n[5/6] Membersihkan file sementara dari project..." -ForegroundColor Yellow
Remove-Item "$SOURCE_DIR\Dockerfile"    -ErrorAction SilentlyContinue
Remove-Item "$SOURCE_DIR\.dockerignore" -ErrorAction SilentlyContinue
Remove-Item "$SOURCE_DIR\gcp-config"    -Recurse -ErrorAction SilentlyContinue
Write-Host "     OK" -ForegroundColor Green

# STEP 6: Tampilkan URL hasil deploy
Write-Host "`n[6/6] Mengambil URL deployment..." -ForegroundColor Yellow
$SERVICE_URL = gcloud run services describe $ServiceName `
    --region $Region --project $ProjectId `
    --format="value(status.url)" 2>$null

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host " DEPLOY BERHASIL!" -ForegroundColor Green
Write-Host " URL GCP    : $SERVICE_URL" -ForegroundColor Green
Write-Host " Domain     : $AppUrl" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "`n[INFO] Update CNAME Cloudflare 'dashboard' ke:"
Write-Host "  $($SERVICE_URL -replace 'https://','')" -ForegroundColor Yellow
