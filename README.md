# cmux (personal fork)

Personal fork of [cmux](https://github.com/manaflow-ai/cmux): a Ghostty-based macOS
terminal with vertical tabs and notifications for AI coding agents.

This fork is not published — no DMG, no Homebrew cask, no auto-update. Builds
run locally via `scripts/reload.sh`.

## Setup

```bash
./scripts/setup.sh
```

Initializes submodules and builds `GhosttyKit.xcframework`.

## Build

```bash
./scripts/reload.sh --tag build           # build Debug app (does not launch)
./scripts/reload.sh --tag build --launch  # build + launch
./scripts/reloadp.sh                      # launch Release build
```

`reload.sh` prints an `App path:` line — cmd-click to open.

See `CLAUDE.md` for the full build/debug workflow and policies.

## License

GPL-3.0-or-later. See `LICENSE`.
