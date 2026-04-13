#!/usr/bin/env python3

from __future__ import annotations

import os
from pathlib import Path

# Deterministic DerivedData path used by scripts/reload.sh. Falling back here
# means callers that just ran `./scripts/reload.sh` can locate the built CLI
# without reload.sh having to publish a /tmp marker.
_DEBUG_CLI_PATH = (
    Path.home()
    / "Library/Developer/Xcode/DerivedData/GhosttyTabs"
    / "Build/Products/Debug/nori DEV.app/Contents/MacOS/nori DEV"
)


def resolve_nori_cli() -> str:
    explicit = os.environ.get("NORI_CLI_BIN") or os.environ.get("NORI_CLI")
    if explicit and os.access(explicit, os.X_OK):
        return explicit

    if os.access(_DEBUG_CLI_PATH, os.X_OK):
        return str(_DEBUG_CLI_PATH)

    raise RuntimeError(
        "Unable to find nori CLI binary. Set NORI_CLI_BIN or run ./scripts/reload.sh first."
    )
