#!/usr/bin/env bash
set -euo pipefail

# Builds the Release configuration of nori and installs it to /Applications.
# This is the counterpart to reload.sh (which handles iterative Debug builds).
# Use this when you want to replace the production /Applications/nori.app with
# a local build from this fork.

LAUNCH=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --launch)
      LAUNCH=1
      shift
      ;;
    -h|--help)
      cat <<'EOF'
Usage: ./scripts/install.sh [--launch]

Builds the Release configuration of nori and copies it to /Applications/nori.app.

Options:
  --launch   Open /Applications/nori.app after installing.
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

# Mirror reload.sh: the Ghostty CLI helper build phase can't link on
# macOS 26 + zig 0.15.2, so auto-skip there.
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

DERIVED_DATA="$HOME/Library/Developer/Xcode/DerivedData/GhosttyTabs"

XCODEBUILD_ARGS=(
  -project GhosttyTabs.xcodeproj
  -scheme nori
  -configuration Release
  -destination 'platform=macOS'
  -derivedDataPath "$DERIVED_DATA"
)
if [[ "${NORI_SKIP_ZIG_BUILD:-}" == "1" ]]; then
  XCODEBUILD_ARGS+=(NORI_SKIP_ZIG_BUILD=1)
fi
XCODEBUILD_ARGS+=(build)

XCODE_LOG="/tmp/nori-xcodebuild-release.log"
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

APP_SRC="$DERIVED_DATA/Build/Products/Release/nori.app"
if [[ ! -d "$APP_SRC" ]]; then
  echo "error: nori.app not found at $APP_SRC" >&2
  exit 1
fi

# Mirror reload.sh: if a local norid sidecar exists, build it with ReleaseFast
# and inject it into the bundle. The current fork has no norid/ directory, so
# this is a no-op today, but keeps install.sh in sync with reload.sh if the
# sidecar is ever reintroduced.
if [[ -d "$PWD/norid" ]]; then
  (cd "$PWD/norid" && zig build -Doptimize=ReleaseFast)
  NORID_SRC="$PWD/norid/zig-out/bin/norid"
  if [[ -x "$NORID_SRC" ]]; then
    BIN_DIR="$APP_SRC/Contents/Resources/bin"
    mkdir -p "$BIN_DIR"
    install -m 0755 "$NORID_SRC" "$BIN_DIR/norid"
  fi
fi

INSTALL_PATH="/Applications/nori.app"

# Quit any running production instance before overwriting its bundle to avoid
# racing LaunchServices on a re-open. Use exact-name match on "nori" so we
# don't also terminate the Debug "nori DEV" process.
/usr/bin/osascript -e 'tell application id "com.nori.app" to quit' >/dev/null 2>&1 || true
pkill -x "nori" 2>/dev/null || true
for _ in $(seq 1 40); do
  pgrep -x "nori" >/dev/null || break
  sleep 0.05
done

rm -rf "$INSTALL_PATH"
cp -R "$APP_SRC" "$INSTALL_PATH"

echo
echo "Installed: $INSTALL_PATH"

if [[ "$LAUNCH" -eq 1 ]]; then
  open -a "$INSTALL_PATH"
fi
