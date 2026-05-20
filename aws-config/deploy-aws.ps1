#!/usr/bin/env pwsh
# =============================================================================
# SCRIPT DEPLOY KE AWS ELASTIC BEANSTALK
# Sistem Informasi Absensi SMK Al Hafidz
# =============================================================================
# Cara pakai: Jalankan dari folder INI (aws-config)
# > cd E:\Sintia\Staging\Tugas_Akhir\aws-config
# > .\deploy-aws.ps1
# =============================================================================

param(
    [string]$EnvName     = "presensi-staging-8",
    [string]$InstanceType = "t3.small",
    [string]$DbHost      = "database-1.c5s60w4y2517.ap-southeast-1.rds.amazonaws.com",
    [string]$DbName      = "presensi_db1",
    [string]$DbUser      = "admin",
    [string]$DbPassword  = "Wnakmi42",
    [string]$AppUrl      = "https://dashboard.forumapi.my.id",
    [string]$AppKey      = "base64:Br9Ve9nWUHcC1ocU0LnnMQgkraQdPzeDRhuCPd0uQjA="
)

$SOURCE_DIR = "E:\Sintia\Staging\Tugas_Akhir"
$AWS_DIR    = $PSScriptRoot

Write-Host "============================================" -ForegroundColor Yellow
Write-Host " DEPLOY AWS ELASTIC BEANSTALK - SMK AL HAFIDZ" -ForegroundColor Yellow
Write-Host "============================================" -ForegroundColor Yellow

# STEP 1: Salin config AWS ke root project sementara
Write-Host "`n[1/5] Menyalin config AWS ke root project..." -ForegroundColor Cyan
Copy-Item "$AWS_DIR\.ebextensions" "$SOURCE_DIR\.ebextensions" -Recurse -Force
Copy-Item "$AWS_DIR\.platform"     "$SOURCE_DIR\.platform"     -Recurse -Force
Write-Host "     OK" -ForegroundColor Green

# STEP 2: Build aset frontend
Write-Host "`n[2/5] Membangun aset frontend..." -ForegroundColor Cyan
Set-Location $SOURCE_DIR
npm run build
Write-Host "     OK" -ForegroundColor Green

# STEP 3: Commit ke Git
Write-Host "`n[3/5] Commit perubahan ke Git..." -ForegroundColor Cyan
git add .
git commit -m "Deploy AWS: $EnvName"
Write-Host "     OK" -ForegroundColor Green

# STEP 4: Buat environment baru dan deploy
Write-Host "`n[4/5] Membuat environment AWS EB baru..." -ForegroundColor Cyan
eb create $EnvName --instance-type $InstanceType --single
Write-Host "     OK" -ForegroundColor Green

# STEP 5: Set environment variables
Write-Host "`n[5/5] Mengatur environment variables..." -ForegroundColor Cyan
eb setenv `
    APP_ENV=production `
    APP_DEBUG=false `
    "APP_URL=$AppUrl" `
    "APP_KEY=$AppKey" `
    DB_CONNECTION=mysql `
    "DB_HOST=$DbHost" `
    DB_PORT=3306 `
    "DB_DATABASE=$DbName" `
    "DB_USERNAME=$DbUser" `
    "DB_PASSWORD=$DbPassword" `
    SESSION_DRIVER=database `
    QUEUE_CONNECTION=database `
    CACHE_STORE=database `
    "PROMETHEUS_ALLOWED_IPS=*"

# STEP 6: Bersihkan file AWS dari root project
Write-Host "`n[6] Membersihkan config sementara dari root project..." -ForegroundColor Cyan
Remove-Item "$SOURCE_DIR\.ebextensions" -Recurse -ErrorAction SilentlyContinue
Remove-Item "$SOURCE_DIR\.platform"     -Recurse -ErrorAction SilentlyContinue
Write-Host "     OK" -ForegroundColor Green

Write-Host "`n============================================" -ForegroundColor Yellow
Write-Host " DEPLOY SELESAI!" -ForegroundColor Green
$cname = eb status $EnvName | Select-String "CNAME"
Write-Host " $cname" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Yellow
