#!/usr/bin/env bash
# AirTrack 1.0.0 'Wilbur' — Stop AirTrack (macOS)
cd "$(dirname "$0")"
echo ""
echo "  ================================================"
echo "   AirTrack Solutions - Stopping AirTrack"
echo "  ================================================"
echo ""
docker compose -f docker-compose.mac.yml down
echo ""
echo "  AirTrack has been stopped."
echo ""
read -rp "Press Enter to close..."
