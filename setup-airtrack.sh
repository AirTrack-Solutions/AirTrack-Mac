#!/usr/bin/env bash
# AirTrack 1.0.0 'Wilbur'
# Copyright (c) 2025 Trevor ("Subhuti"). All rights reserved.
# SPDX-License-Identifier: LicenseRef-AirTrack-Proprietary-NC
#
# macOS setup script — run in Terminal.
# Downloads and installs AirTrack Mac from GitHub.
#
# Usage (paste into a Terminal window):
#   curl -fsSL https://raw.githubusercontent.com/Subhuti/AirTrack-Mac/main/setup-airtrack.sh | bash

set -e

REPO="https://github.com/Subhuti/AirTrack-Mac.git"
INSTALL_DIR="$HOME/docker/AirTrack-Mac"
COMPOSE="docker-compose.mac.yml"

echo ""
echo "  ============================================"
echo "   AirTrack 1.0.0 'Wilbur' — macOS Setup    "
echo "  ============================================"
echo ""

# ── Git check ─────────────────────────────────────────────────────────────────
if ! command -v git &>/dev/null; then
    echo "  ERROR: Git is not installed."
    echo "  Install it by running: xcode-select --install"
    echo "  Then run this script again."
    echo ""
    read -rp "Press Enter to close..."
    exit 1
fi

# ── Docker check ──────────────────────────────────────────────────────────────
if ! command -v docker &>/dev/null; then
    echo "  ERROR: Docker Desktop is not installed."
    echo "  Download it from: https://www.docker.com/products/docker-desktop/"
    echo "  After installing Docker Desktop, run this script again."
    echo ""
    read -rp "Press Enter to close..."
    exit 1
fi

if ! docker info &>/dev/null; then
    echo "  ERROR: Docker Desktop is not running."
    echo "  Please open Docker Desktop and wait for it to finish loading,"
    echo "  then run this script again."
    echo ""
    read -rp "Press Enter to close..."
    exit 1
fi

# ── Clone or update ───────────────────────────────────────────────────────────
FRESH_INSTALL=false

if [ -d "$INSTALL_DIR/.git" ]; then
    echo "  Existing installation found. Updating..."
    git -C "$INSTALL_DIR" pull
else
    if [ -d "$INSTALL_DIR" ]; then
        if [ -t 0 ]; then
            read -rp "  Folder already exists. Delete and reinstall? (y/N): " choice
            [[ "$choice" =~ ^[Yy]$ ]] || { echo "  Install aborted."; exit 0; }
        fi
        echo "  Removing old installation files..."
        rm -rf "$INSTALL_DIR"
    fi
    FRESH_INSTALL=true
    echo "  Cloning AirTrack..."
    git clone "$REPO" "$INSTALL_DIR"
fi

# ── Generate .env (first install only) ───────────────────────────────────────
ENV_FILE="$INSTALL_DIR/.env"
if [ ! -f "$ENV_FILE" ]; then
    SECRET_KEY=$(python3 -c "import uuid; print((uuid.uuid4().hex + uuid.uuid4().hex).upper())")
    DB_PASSWORD=$(python3 -c "import uuid; print(uuid.uuid4().hex[:16])")
    DB_ROOT_PASSWORD=$(python3 -c "import uuid; print(uuid.uuid4().hex[:16])")

    cat > "$ENV_FILE" <<EOF
# AirTrack Mac — generated $(date '+%Y-%m-%d %H:%M:%S')
# Do NOT share or commit this file.

AIRTRACK_ROLE=client
AIRTRACK_UPDATE_MODE=remote
AIRTRACK_FORCE_PUSH=0
AIRTRACK_SYNC_USER=

SECRET_KEY=$SECRET_KEY

DB_HOST=airtrack-db
DB_USER=airtrack
DB_PASSWORD=$DB_PASSWORD
DB_ROOT_PASSWORD=$DB_ROOT_PASSWORD
DB_NAME=airtrack

AIRTRACK_APP_DIR=/app
AIRTRACK_STATIC_DIR=/app/static
AIRTRACK_UPDATES_DIR=/app/static/updates
AIRTRACK_LOG_FILE=/app/logs/file_sync.log
AIRTRACK_BACKUP_DIR=/app/backups
AIRTRACK_MAX_ARCHIVES=7
EOF
    echo "  Created .env with secure credentials."
else
    echo "  Existing .env kept."
fi

# ── On fresh install, remove any stale DB volumes from a previous attempt ─────
if [ "$FRESH_INSTALL" = true ]; then
    echo "  Clearing any old database volumes..."
    docker compose -f "$INSTALL_DIR/$COMPOSE" down -v 2>/dev/null || true
fi

# ── Build and start ───────────────────────────────────────────────────────────
echo ""
echo "  Building and starting AirTrack..."
echo "  This may take several minutes the first time. Please be patient."
echo ""

docker compose -f "$INSTALL_DIR/$COMPOSE" up --build -d

# ── Done ──────────────────────────────────────────────────────────────────────
sleep 3
open http://localhost:5000

echo ""
echo "  ============================================"
echo "   AirTrack is running!"
echo "   Open your browser to: http://localhost:5000"
echo ""
echo "   To launch AirTrack in future:"
echo "   Run start_airtrack.sh in your AirTrack-Mac folder"
echo "  ============================================"
echo ""
read -rp "Press Enter to close..."
