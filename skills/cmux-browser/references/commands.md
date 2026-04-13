# Command Reference (nori Browser)

This maps common `agent-browser` usage to `nori browser` usage.

## Direct Equivalents

- `agent-browser open <url>` -> `nori browser open <url>`
- `agent-browser goto|navigate <url>` -> `nori browser <surface> goto|navigate <url>`
- `agent-browser snapshot -i` -> `nori browser <surface> snapshot --interactive`
- `agent-browser click <ref>` -> `nori browser <surface> click <ref>`
- `agent-browser fill <ref> <text>` -> `nori browser <surface> fill <ref> <text>`
- `agent-browser type <ref> <text>` -> `nori browser <surface> type <ref> <text>`
- `agent-browser select <ref> <value>` -> `nori browser <surface> select <ref> <value>`
- `agent-browser get text <ref>` -> `nori browser <surface> get text <ref-or-selector>`
- `agent-browser get url` -> `nori browser <surface> get url`
- `agent-browser get title` -> `nori browser <surface> get title`

## Core Command Groups

### Navigation

```bash
nori browser open <url>                        # opens in caller's workspace (uses NORI_WORKSPACE_ID)
nori browser open <url> --workspace <id|ref>   # opens in a specific workspace
nori browser <surface> goto <url>
nori browser <surface> back|forward|reload
nori browser <surface> get url|title
```

> **Workspace context:** `browser open` targets the workspace of the terminal where the command is run (via `NORI_WORKSPACE_ID`), even if a different workspace is currently focused. Use `--workspace` to override.

### Snapshot and Inspection

```bash
nori browser <surface> snapshot --interactive
nori browser <surface> snapshot --interactive --compact --max-depth 3
nori browser <surface> get text body
nori browser <surface> get html body
nori browser <surface> get value "#email"
nori browser <surface> get attr "#email" --attr placeholder
nori browser <surface> get count ".row"
nori browser <surface> get box "#submit"
nori browser <surface> get styles "#submit" --property color
nori browser <surface> eval '<js>'
```

### Interaction

```bash
nori browser <surface> click|dblclick|hover|focus <selector-or-ref>
nori browser <surface> fill <selector-or-ref> [text]   # empty text clears
nori browser <surface> type <selector-or-ref> <text>
nori browser <surface> press|keydown|keyup <key>
nori browser <surface> select <selector-or-ref> <value>
nori browser <surface> check|uncheck <selector-or-ref>
nori browser <surface> scroll [--selector <css>] [--dx <n>] [--dy <n>]
```

### Wait

```bash
nori browser <surface> wait --selector "#ready" --timeout-ms 10000
nori browser <surface> wait --text "Done" --timeout-ms 10000
nori browser <surface> wait --url-contains "/dashboard" --timeout-ms 10000
nori browser <surface> wait --load-state complete --timeout-ms 15000
nori browser <surface> wait --function "document.readyState === 'complete'" --timeout-ms 10000
```

### Session/State

```bash
nori browser <surface> cookies get|set|clear ...
nori browser <surface> storage local|session get|set|clear ...
nori browser <surface> tab list|new|switch|close ...
nori browser <surface> state save|load <path>
```

### Diagnostics

```bash
nori browser <surface> console list|clear
nori browser <surface> errors list|clear
nori browser <surface> highlight <selector>
nori browser <surface> screenshot
nori browser <surface> download wait --timeout-ms 10000
```

## Agent Reliability Tips

- Use `--snapshot-after` on mutating actions to return a fresh post-action snapshot.
- Re-snapshot after navigation, modal open/close, or major DOM changes.
- Prefer short handles in outputs by default (`surface:N`, `pane:N`, `workspace:N`, `window:N`).
- Use `--id-format both` only when a UUID must be logged/exported.

## Known WKWebView Gaps (`not_supported`)

- `browser.viewport.set`
- `browser.geolocation.set`
- `browser.offline.set`
- `browser.trace.start|stop`
- `browser.network.route|unroute|requests`
- `browser.screencast.start|stop`
- `browser.input_mouse|input_keyboard|input_touch`

See also:
- [snapshot-refs.md](snapshot-refs.md)
- [authentication.md](authentication.md)
- [session-management.md](session-management.md)
