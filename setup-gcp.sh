#!/bin/bash
# =============================================================================
# SETUP AWAL GCP - Jalankan SEKALI saja
# Sistem Informasi Absensi SMK Al Hafidz
# =============================================================================
# Cara pakai di GCP Cloud Shell:
# chmod +x setup-gcp.sh && ./setup-gcp.sh
# =============================================================================

set -e  # Berhenti otomatis jika ada error

PROJECT_ID="project-876bbc01-98af-4d8d-9e1"
REGION="asia-southeast2"
DB_INSTANCE="presensi-db-gcp"
DB_NAME="absensi_smk_alhafidz" # Jika kondisinya ingin mengimport file sql maka namanya harus sama dengan file sql yang akan diimport
DB_PASSWORD="Wnakmi42GCP" # diubah jika sesuai kebutuhan dan harus sama dengan password  di setup-gcp.sh

echo "============================================"
echo " SETUP AWAL GCP - SMK AL HAFIDZ"
echo "============================================"

# 1. Set project
echo ""
echo "[1/5] Set project GCP ke: $PROJECT_ID"
gcloud config set project $PROJECT_ID

# 2. Aktifkan layanan
echo ""
echo "[2/5] Mengaktifkan layanan GCP..."
gcloud services enable \
    run.googleapis.com \
    sqladmin.googleapis.com \
    cloudbuild.googleapis.com \
    artifactregistry.googleapis.com
echo "     OK"

# 3. Buat Cloud SQL
echo ""
echo "[3/5] Membuat Cloud SQL (db-f1-micro)... (~5-10 menit)"
gcloud sql instances create $DB_INSTANCE \
    --database-version=MYSQL_8_0 \
    --tier=db-f1-micro \
    --region=$REGION \
    --root-password=$DB_PASSWORD \
    --storage-auto-increase \
    --no-backup
echo "     OK"

# 4. Buat database
echo ""
echo "[4/5] Membuat database $DB_NAME..."
gcloud sql databases create $DB_NAME --instance=$DB_INSTANCE
echo "     OK"

# 5. Tampilkan IP
echo ""
echo "[5/5] IP Address Cloud SQL Anda:"
DB_IP=$(gcloud sql instances describe $DB_INSTANCE \
    --format="value(ipAddresses[0].ipAddress)")
echo "     DB_HOST = $DB_IP"

echo ""
echo "============================================"
echo " SETUP SELESAI!"
echo " Sekarang jalankan: ./deploy-gcp.sh"
echo "============================================"
