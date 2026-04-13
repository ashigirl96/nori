#!/usr/bin/env bash
set -euo pipefail

SURFACE="${1:-surface:1}"
STATE_FILE="${2:-./auth-state.json}"
DASHBOARD_URL="${3:-https://app.example.com/dashboard}"

if [ -f "$STATE_FILE" ]; then
  nori browser "$SURFACE" state load "$STATE_FILE"
fi

nori browser "$SURFACE" goto "$DASHBOARD_URL"
nori browser "$SURFACE" get url
nori browser "$SURFACE" wait --load-state complete --timeout-ms 15000
nori browser "$SURFACE" snapshot --interactive

echo "If redirected to login, complete login flow then run:"
echo "  nori browser $SURFACE state save $STATE_FILE"
