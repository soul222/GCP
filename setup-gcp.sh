#!/bin/bash
# =============================================================================
# SETUP AWAL GCP (App Engine) - Jalankan SEKALI saja
# Sistem Informasi Absensi SMK Al Hafidz
# =============================================================================
# Cara pakai di GCP Cloud Shell:
# chmod +x setup-gcp.sh && ./setup-gcp.sh
# =============================================================================

set -e  # Berhenti otomatis jika ada error

PROJECT_ID="project-876bbc01-98af-4d8d-9e1"
REGION="asia-southeast2"
DB_INSTANCE="presensi-db-gcp"
DB_NAME="absensi_smk_alhafidz"
DB_PASSWORD="Wnakmi42GCP"

echo "============================================"
echo " SETUP AWAL GCP (App Engine) - SMK AL HAFIDZ"
echo "============================================"

# 1. Set project
echo ""
echo "[1/6] Set project GCP ke: $PROJECT_ID"
gcloud config set project $PROJECT_ID

# 2. Aktifkan layanan yang diperlukan untuk App Engine
echo ""
echo "[2/6] Mengaktifkan layanan GCP..."
gcloud services enable \
    appengine.googleapis.com \
    sqladmin.googleapis.com \
    cloudbuild.googleapis.com
echo "     OK"

# 3. Inisialisasi App Engine di region Jakarta
echo ""
echo "[3/6] Inisialisasi App Engine di region $REGION..."
gcloud app create --region=$REGION 2>/dev/null || echo "     App Engine sudah diinisialisasi sebelumnya."
echo "     OK"

# 4. Buat Cloud SQL
echo ""
echo "[4/6] Membuat Cloud SQL (db-f1-micro)... (~5-10 menit)"
gcloud sql instances create $DB_INSTANCE \
    --database-version=MYSQL_8_0 \
    --tier=db-f1-micro \
    --region=$REGION \
    --root-password=$DB_PASSWORD \
    --storage-auto-increase \
    --no-backup
echo "     OK"

# 5. Buat database
echo ""
echo "[5/6] Membuat database $DB_NAME..."
gcloud sql databases create $DB_NAME --instance=$DB_INSTANCE
echo "     OK"

# 6. Tampilkan info koneksi
echo ""
echo "[6/6] Informasi Koneksi Database:"
DB_IP=$(gcloud sql instances describe $DB_INSTANCE \
    --format="value(ipAddresses[0].ipAddress)")
echo "     DB_HOST (IP)     = $DB_IP"
echo "     DB_SOCKET (Unix) = /cloudsql/$PROJECT_ID:$REGION:$DB_INSTANCE"
echo "     DB_DATABASE      = $DB_NAME"
echo "     DB_USERNAME      = root"
echo "     DB_PASSWORD      = $DB_PASSWORD"

echo ""
echo "============================================"
echo " SETUP SELESAI!"
echo ""
echo " Langkah selanjutnya:"
echo " 1. Import database: Lihat panduan import SQL"
echo " 2. Deploy aplikasi: ./deploy-gcp.sh"
echo "============================================"
