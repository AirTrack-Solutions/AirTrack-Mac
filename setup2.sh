#!/usr/bin/env bash
# AirTrack Mac — Diagnostic Installer
# Run this if the standard installer fails.
# It will show detailed error information you can send to support.
#
# Usage:
#   bash setup2.sh

set -e

URL="https://raw.githubusercontent.com/Subhuti/AirTrack-Mac/main/setup-airtrack.sh"

cleanup() {
    echo ""
    read -rp "Press Enter to close..."
}
trap cleanup EXIT

echo "Fetching $URL ..."

if ! SCRIPT=$(curl -fsSL "$URL" 2>&1); then
    echo ""
    echo "==================== ERROR ===================="
    echo "Failed to download installer."
    echo "$SCRIPT"
    echo "==============================================="
    exit 1
fi

echo "Downloaded ${#SCRIPT} bytes. Executing..."
echo ""

bash <(echo "$SCRIPT") || {
    EXIT_CODE=$?
    echo ""
    echo "==================== ERROR ===================="
    echo "Installer exited with code: $EXIT_CODE"
    echo ""
    echo "Run the following for more detail:"
    echo "  bash -x <(curl -fsSL $URL)"
    echo "==============================================="
    exit $EXIT_CODE
}
