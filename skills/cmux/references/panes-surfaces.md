# Panes and Surfaces

Split layout, surface creation, focus, move, and reorder.

## Inspect

```bash
nori list-panes
nori list-pane-surfaces --pane pane:1
```

## Create Splits/Surfaces

```bash
nori new-split right --panel pane:1
nori new-surface --type terminal --pane pane:1
nori new-surface --type browser --pane pane:1 --url https://example.com
```

## Focus and Close

```bash
nori focus-pane --pane pane:2
nori focus-panel --panel surface:7
nori close-surface --surface surface:7
```

## Move/Reorder Surfaces

```bash
nori move-surface --surface surface:7 --pane pane:2 --focus true
nori move-surface --surface surface:7 --workspace workspace:2 --window window:1 --after surface:4
nori reorder-surface --surface surface:7 --before surface:3
```

Surface identity is stable across move/reorder operations.
