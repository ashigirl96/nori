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
./scripts/reload.sh           # build Debug app (does not launch)
./scripts/reload.sh --launch  # build + launch
```

`reload.sh` prints an `App path:` line — cmd-click to open.

## Install over `/Applications/cmux.app`

```bash
./scripts/install.sh          # build Release + copy to /Applications/cmux.app
./scripts/install.sh --launch # build + install + open
```

Produces `cmux.app` (bundle ID `com.cmuxterm.app`) and replaces any existing
`/Applications/cmux.app`. Any running production instance is quit first.

See `CLAUDE.md` for the full build/debug workflow and policies.

## License

GPL-3.0-or-later. See `LICENSE`.
