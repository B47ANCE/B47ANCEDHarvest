# Crop-side irrigation API

Both B47ANCEDHarvest and the legacy farmWorks global expose applyIrrigation.
Both require paths share one implementation and provider registry.

## Authority and ownership

Only an explicit false boolean from the engine isClient() probe permits
mutation. Missing, throwing, nil or non-boolean probes reject before the provider
callback. This retains the existing server/SP entry point and does not create a
client request channel. Crop provider callbacks are trusted integration code,
not network input. A future player action must validate intent on the server.

Vanilla still owns crop water and persistence. The native provider calls
SPlantGlobalObject:water(nil, uses), which updates lastWaterHour and calls
saveData. Source inspection verifies toModData/transmitModData; dedicated
delivery, late join, durability and restart behavior remain runtime gates.
WaterWorks owns already-delivered source water, withdrawal and quality.
No atomic transaction between source water and crop effects exists yet.

Empty plow-state or none-seed furrows do not match the vanilla crop provider.
Inspection adds waterLevelKnown: true only when provider water is finite.
The existing clamped waterLevel field remains for compatibility, but an unknown
initial water observation blocks irrigation and an unknown readback cannot
produce a measured success receipt.

## Return contract

Success keeps the existing two values:

    true, receipt

Existing receipt fields remain: schemaVersion, providerId, cropType,
requestedUses, appliedUses, targetWater, waterBefore, waterAfter,
measuredIncrease, x, y, z. outcome is applied and retrySafe is false.

A failure before provider invocation retains:

    false, reason

A failure after provider invocation adds a third value:

    false, reason, receipt

The boolean/error positions and success fields remain compatible. Callers must
consume the third value to reconcile effects; false never means rolled back.

| receipt.outcome | Meaning |
| --- | --- |
| partial | The same provider reports changed water after a failed/rejected/mismatched invocation. The full requested effect might have occurred. |
| unchanged | The same provider reports the same water level; other provider side effects are not ruled out. |
| unknown | Readback failed, water was missing/non-finite, or the selected provider changed. |
| applied | Provider accepted and the observed water matches the expected native ten-point-per-use effect. |

All post-invocation receipts set retrySafe=false. Failed receipts omit
appliedUses because crop-water readback cannot prove consumed source water.
waterAfter and measuredIncrease exist only for a usable same-provider
observation. Requests are neither retried nor rolled back automatically.
The crop lock stays held through readback and is released on every callback/
readback outcome. Existing reentrant attempts reject before another callback.

Whole uses and ten-point quantization remain the native contract: the final
dose can cross the requested target by less than ten points, capped at 100.
Provider callbacks must honor that existing model; arbitrary unit conversions
are not introduced here.

## Integration gate

Before waterWorks automation, define server-side resource accounting, operation
identity, deduplication and reconciliation of partial/unknown effects. Do not
infer atomicity, refund water automatically, or blindly retry. Dedicated tests
must cover successful delivery, callback failure, lost/late acknowledgement,
disconnect/rejoin, save/load and server restart.

Receipts are transient return values, not a new persistent schema. The Mod ID,
Workshop item, legacy API names and diagnostic ModData key are unchanged.
