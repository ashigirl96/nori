#!/usr/bin/env bash
set -euo pipefail

LAUNCH=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --launch)
      LAUNCH=1
      shift
      ;;
    -h|--help)
      cat <<'EOF'
Usage: ./scripts/reload.sh [--launch]

Builds the Debug configuration of nori and (optionally) launches it.

Options:
  --launch   Quit any running instance and open the freshly built app.
  -h, --help Show this help.
EOF
      exit 0
      ;;
    *)
      echo "error: unknown option $1" >&2
      exit 1
      ;;
  esac
done

"$PWD/scripts/ensure-ghosttykit.sh"

# The Ghostty CLI helper is produced by an Xcode build phase; we only need to
# disable it when the host toolchain can't link it (macOS 26 + zig 0.15.2).
should_skip_ghostty_cli_helper_zig_build() {
  if [[ "${NORI_SKIP_ZIG_BUILD:-}" == "1" ]]; then
    return 0
  fi
  local product_version zig_version major_version
  product_version="$(sw_vers -productVersion 2>/dev/null || true)"
  zig_version="$(zig version 2>/dev/null || true)"
  major_version="${product_version%%.*}"
  if [[ "$zig_version" == "0.15.2" ]] && [[ "$major_version" =~ ^[0-9]+$ ]] && (( major_version >= 26 )); then
    echo "Auto-enabling NORI_SKIP_ZIG_BUILD=1 for Ghostty CLI helper (macOS ${product_version} + zig ${zig_version})"
    return 0
  fi
  return 1
}

if should_skip_ghostty_cli_helper_zig_build; then
  export NORI_SKIP_ZIG_BUILD=1
fi

# Pin the derived-data path so the built app location is deterministic. Stale
# DerivedData directories from the old tagged workflow (nori-<tag>/) could
# otherwise outrank the fresh build on mtime when incremental builds skip
# touching the .app bundle.
DERIVED_DATA="$HOME/Library/Developer/Xcode/DerivedData/GhosttyTabs"

XCODEBUILD_ARGS=(
  -project GhosttyTabs.xcodeproj
  -scheme nori
  -configuration Debug
  -destination 'platform=macOS'
  -derivedDataPath "$DERIVED_DATA"
)
if [[ "${NORI_SKIP_ZIG_BUILD:-}" == "1" ]]; then
  XCODEBUILD_ARGS+=(NORI_SKIP_ZIG_BUILD=1)
fi
XCODEBUILD_ARGS+=(build)

XCODE_LOG="/tmp/nori-xcodebuild.log"
set +e
xcodebuild "${XCODEBUILD_ARGS[@]}" 2>&1 | tee "$XCODE_LOG" | grep -E '(warning:|error:|fatal:|BUILD FAILED|BUILD SUCCEEDED|\*\* BUILD)'
XCODE_PIPESTATUS=("${PIPESTATUS[@]}")
set -e
XCODE_EXIT="${XCODE_PIPESTATUS[0]}"
echo "Full build log: $XCODE_LOG"
if [[ "$XCODE_EXIT" -ne 0 ]]; then
  echo "error: xcodebuild failed with exit code $XCODE_EXIT" >&2
  exit "$XCODE_EXIT"
fi

APP_PATH="$DERIVED_DATA/Build/Products/Debug/nori DEV.app"
if [[ ! -d "$APP_PATH" ]]; then
  echo "error: nori DEV.app not found at $APP_PATH" >&2
  exit 1
fi

# norid has no Xcode build phase, so we build and copy it in ourselves.
# (The ghostty CLI helper is handled by its own Xcode build phase.)
if [[ -d "$PWD/norid" ]]; then
  (cd "$PWD/norid" && zig build -Doptimize=ReleaseFast)
  NORID_SRC="$PWD/norid/zig-out/bin/norid"
  if [[ -x "$NORID_SRC" ]]; then
    BIN_DIR="$APP_PATH/Contents/Resources/bin"
    mkdir -p "$BIN_DIR"
    install -m 0755 "$NORID_SRC" "$BIN_DIR/norid"
  fi
fi

if [[ "$LAUNCH" -eq 1 ]]; then
  # Graceful quit first (honors running windows), then pkill as a fallback to
  # avoid racing LaunchServices on a re-open.
  /usr/bin/osascript -e 'tell application id "com.nori.app.debug" to quit' >/dev/null 2>&1 || true
  # Exact-name match on the Debug executable ("nori DEV") so we don't also
  # terminate the Release /Applications/nori.app process. Matches the CI jobs
  # in .github/workflows/ci.yml.
  pkill -x "nori DEV" 2>/dev/null || true
  for _ in $(seq 1 40); do
    pgrep -x "nori DEV" >/dev/null || break
    sleep 0.05
  done

  # Scrub parent-nori environment variables so the child doesn't inherit a
  # surface/tab/panel identity from whatever shell launched the reload script.
  env \
    -u NORI_SOCKET_PATH \
    -u NORI_WORKSPACE_ID \
    -u NORI_SURFACE_ID \
    -u NORI_TAB_ID \
    -u NORI_PANEL_ID \
    -u NORID_UNIX_PATH \
    -u NORI_TAG \
    -u NORI_DEBUG_LOG \
    -u NORI_BUNDLE_ID \
    -u NORI_SHELL_INTEGRATION \
    -u GHOSTTY_BIN_DIR \
    -u GHOSTTY_RESOURCES_DIR \
    -u GHOSTTY_SHELL_FEATURES \
    -u GIT_PAGER \
    -u GH_PAGER \
    -u TERMINFO \
    -u XDG_DATA_DIRS \
    open -a "$APP_PATH"
fi

echo
echo "App path:"
echo "  $APP_PATH"

if [[ "$LAUNCH" -eq 0 ]]; then
  echo
  echo "Build complete. Pass --launch to open the app, or cmd-click the path above."
fi
