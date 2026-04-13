#!/usr/bin/env bash
set -euo pipefail

URL="${1:-https://example.com/form}"
SURFACE="${2:-surface:1}"

nori browser "$SURFACE" goto "$URL"
nori browser "$SURFACE" get url
nori browser "$SURFACE" wait --load-state complete --timeout-ms 15000
nori browser "$SURFACE" snapshot --interactive

echo "Now run fill/click commands using refs from the snapshot above."
