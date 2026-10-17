# Build 42 Irrigation Runtime Audit

Audited against the locally installed Project Zomboid Build 42.20 source under
`media/lua`.

## Verified vanilla path

- `shared/Farming/TimedActions/ISWaterPlantAction.lua` sends the farming-system
  `water` command once per accepted use.
- `server/Farming/farmingCommands.lua` resolves the authoritative plant and
  invokes `plant:water(nil, args.uses)`.
- `server/Farming/SPlantGlobalObject.lua` implements `water`: each use adds ten
  water-level points up to 100, records `lastWaterHour`, and calls `saveData()`.
- `server/Farming/SFarmingSystem.lua` includes `waterLvl`, `waterNeeded`,
  `waterNeededMax`, and `lastWaterHour` in the saved global-object fields.

B47ANCE'd Harvest therefore uses the native plant method rather than writing
`waterLvl` directly or inventing a synchronization call. Host tests model the
verified ten-point quantization and validate clamping, readback, unsupported
providers, invalid use counts, and client-side rejection. In-game and
multiplayer behavior remain unverified.

## Ownership boundary

The new API applies water that an owning system has already delivered to a crop.
It does not locate, reserve, withdraw, filter, or classify a water source.
Those operations remain waterWorks-owned. An end-to-end irrigation transaction
must wait for an evidence-backed coupling that can preserve both fluid and crop
state without duplicating either project's authority.

## Current hardening source recheck

The earlier Build 42.20 observations above remain historical. For 0.9.1, the
installed Steam manifest reports build 25485521. The same SPlantGlobalObject
source hash is 0db75ed607f5c2bc82ebeaf7b52d5965241077e184e52f1a6cf88762c916b2f7.
Lines 501-518 still implement ten-point watering and saveData; lines 771-777
write/transmit object ModData when the IsoObject is available. This is
[VERIFIED] Lua source, not a durable/dedicated-runtime claim. Full game version
was not independently decoded during this pass.

The new error receipts describe observed crop effects after provider failure.
They do not claim rollback or transactional source withdrawal. See
IRRIGATION_API.md and the current validation record.
