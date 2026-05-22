#!/bin/bash
# =============================================================================
# DEPLOY KE GOOGLE APP ENGINE via GCP Cloud Shell
# Sistem Informasi Absensi SMK Al Hafidz
# =============================================================================
# Cara pakai di GCP Cloud Shell:
# chmod +x deploy-gcp.sh && ./deploy-gcp.sh
# =============================================================================

set -e

# ── Konfigurasi ─────────────────────────────────────────────────────────────
PROJECT_ID="project-876bbc01-98af-4d8d-9e1"
# ────────────────────────────────────────────────────────────────────────────

echo "============================================"
echo " DEPLOY GCP APP ENGINE - SMK AL HAFIDZ"
echo "============================================"

# 1. Set project
echo ""
echo "[1/4] Set project GCP..."
gcloud config set project $PROJECT_ID

# 2. Install dependencies & build aset frontend
echo ""
echo "[2/4] Menginstall dependencies dan build aset frontend..."

# Install Node.js dependencies dan build CSS/JS
if [ -f "package.json" ]; then
    npm install --prefer-offline 2>/dev/null || npm install
    npm run build
    echo "     Frontend build OK"
else
    echo "     SKIP: package.json tidak ditemukan"
fi

# Install PHP dependencies (production only)
if [ -f "composer.json" ]; then
    composer install --no-dev --optimize-autoloader --ignore-platform-reqs --no-interaction --no-progress 2>/dev/null || \
    composer install --ignore-platform-reqs --no-interaction --no-progress
    echo "     Composer install OK"
fi

# 3. Deploy ke App Engine
echo ""
echo "[3/4] Deploying ke App Engine... (proses ini 5-10 menit)"
gcloud app deploy app.yaml \
    --quiet \
    --project=$PROJECT_ID

# 4. Ambil URL hasil deploy
echo ""
echo "[4/4] Mengambil URL deployment..."
SERVICE_URL=$(gcloud app browse --no-launch-browser --project=$PROJECT_ID 2>&1 | tail -1)

echo ""
echo "============================================"
echo " DEPLOY BERHASIL!"
echo " URL App Engine : https://$PROJECT_ID.et.r.appspot.com"
echo "============================================"
echo ""
echo "[INFO] Buka URL di atas di browser untuk mengakses aplikasi."
echo "[INFO] Cek log jika ada error:"
echo "  gcloud app logs tail -s default --project=$PROJECT_ID"
