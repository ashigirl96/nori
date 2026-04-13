#!/bin/bash
# Rebuild and restart nori app

set -e

cd "$(dirname "$0")/.."

# Kill existing app if running
pkill -9 -f "nori" 2>/dev/null || true

# Build
swift build

# Copy to app bundle
cp .build/debug/nori .build/debug/nori.app/Contents/MacOS/

# Open the app
open .build/debug/nori.app
