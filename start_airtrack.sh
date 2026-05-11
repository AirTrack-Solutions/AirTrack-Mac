#!/usr/bin/env bash
# AirTrack 1.0.0 'Wilbur' — Start AirTrack (macOS)
cd "$(dirname "$0")"
open http://localhost:5000
docker compose -f docker-compose.mac.yml up -d
