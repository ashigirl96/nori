# Windows and Workspaces

Window/workspace lifecycle and ordering operations.

## Inspect

```bash
nori list-windows
nori current-window
nori list-workspaces
nori current-workspace
```

## Create/Focus/Close

```bash
nori new-window
nori focus-window --window window:2
nori close-window --window window:2

nori new-workspace
nori select-workspace --workspace workspace:4
nori close-workspace --workspace workspace:4
```

## Reorder and Move

```bash
nori reorder-workspace --workspace workspace:4 --before workspace:2
nori move-workspace-to-window --workspace workspace:4 --window window:1
```
