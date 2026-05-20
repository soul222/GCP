#!/bin/bash
# =============================================================================
# DEPLOY KE GOOGLE CLOUD RUN via GCP Cloud Shell
# Sistem Informasi Absensi SMK Al Hafidz
# =============================================================================
# Cara pakai di GCP Cloud Shell:
# chmod +x deploy-gcp.sh && ./deploy-gcp.sh
# =============================================================================

set -e

# ── Konfigurasi (sesuaikan jika perlu) ──────────────────────────────────────
PROJECT_ID="project-876bbc01-98af-4d8d-9e1"
REGION="asia-southeast2"
SERVICE_NAME="presensi-alhafidz"
DB_INSTANCE="presensi-db-gcp"
DB_NAME="presensi_db1"
DB_USER="root"
DB_PASSWORD="Wnakmi42GCP"
APP_URL="https://presensi-alhafidz-placeholder.a.run.app"
APP_KEY="base64:Br9Ve9nWUHcC1ocU0LnnMQgkraQdPzeDRhuCPd0uQjA="
# ────────────────────────────────────────────────────────────────────────────

echo "============================================"
echo " DEPLOY GCP CLOUD RUN - SMK AL HAFIDZ"
echo "============================================"

# 1. Set project
echo ""
echo "[1/5] Set project GCP..."
gcloud config set project $PROJECT_ID

# 2. Ambil IP Cloud SQL
echo ""
echo "[2/5] Mengambil IP Cloud SQL..."
DB_HOST=$(gcloud sql instances describe $DB_INSTANCE \
    --project=$PROJECT_ID \
    --format="value(ipAddresses[0].ipAddress)" 2>/dev/null || echo "")

if [ -z "$DB_HOST" ]; then
    echo "     ERROR: Cloud SQL belum dibuat!"
    echo "     Jalankan dahulu: ./setup-gcp.sh"
    exit 1
fi
echo "     DB_HOST = $DB_HOST"

# 3. Izinkan Cloud SQL menerima koneksi dari Cloud Run (0.0.0.0/0)
echo ""
echo "[3/5] Mengizinkan akses dari Cloud Run ke Cloud SQL..."
gcloud sql instances patch $DB_INSTANCE \
    --authorized-networks=0.0.0.0/0 \
    --project=$PROJECT_ID || true
echo "     OK"

# 4. Build & Deploy ke Cloud Run
echo ""
echo "[4/5] Deploying ke Cloud Run... (proses ini 5-10 menit)"
gcloud run deploy $SERVICE_NAME \
    --source . \
    --region $REGION \
    --platform managed \
    --allow-unauthenticated \
    --memory 512Mi \
    --cpu 1 \
    --min-instances 0 \
    --max-instances 3 \
    --project $PROJECT_ID \
    --set-env-vars "\
APP_ENV=production,\
APP_DEBUG=false,\
APP_KEY=$APP_KEY,\
APP_URL=$APP_URL,\
DB_CONNECTION=mysql,\
DB_HOST=$DB_HOST,\
DB_PORT=3306,\
DB_DATABASE=$DB_NAME,\
DB_USERNAME=$DB_USER,\
DB_PASSWORD=$DB_PASSWORD,\
SESSION_DRIVER=database,\
CACHE_STORE=database,\
QUEUE_CONNECTION=database,\
PROMETHEUS_ALLOWED_IPS=*"

# 5. Ambil URL hasil deploy
echo ""
echo "[5/5] Mengambil URL deployment..."
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME \
    --region $REGION \
    --project $PROJECT_ID \
    --format="value(status.url)")

echo ""
echo "============================================"
echo " DEPLOY BERHASIL!"
echo " URL GCP  : $SERVICE_URL"
echo " Domain   : $APP_URL"
echo "============================================"
echo ""
echo "[INFO] Update CNAME Cloudflare 'dashboard' ke:"
echo "  ${SERVICE_URL#https://}"
