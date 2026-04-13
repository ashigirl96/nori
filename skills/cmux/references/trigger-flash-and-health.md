# Trigger Flash and Surface Health

Operational checks useful in automation loops.

## Trigger Flash

Flash a surface or workspace to provide visual confirmation in UI:

```bash
nori trigger-flash --surface surface:7
nori trigger-flash --workspace workspace:2
```

## Surface Health

Use health output to detect hidden/detached/non-windowed surfaces:

```bash
nori surface-health
nori surface-health --workspace workspace:2
```

Use this before routing focused input if UI state may be stale.
