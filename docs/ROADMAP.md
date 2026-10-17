# B47ANCE'd Harvest Roadmap

> Consolidated status: [MASTER_ROADMAP.md](MASTER_ROADMAP.md).

## Current foundation

B47ANCE'd Harvest provides bounded crop inspection, irrigation planning, and an
authoritative provider-owned crop-side irrigation application boundary. It does
not replace vanilla farming or choose/withdraw external water supplies.

## Approved research addition

### EXT-10 — Seasonal planting guidance

Register optional crop planting windows and compare them with canonical
weatherWorks calendar/season observations. Return read-only advice such as ideal,
possible, poor, or unavailable with source and reason. uiWorks may decorate seed
or crop presentation from that snapshot.

The first slice must support missing/custom crop data, nonstandard calendars,
regional assumptions, and multiplayer-consistent dates. It must not modify crop
growth, skip calendar days, predict weather, or inherit external balance tables.

Version 0.5.0 implements that provider-backed read model, including year-wrap
windows and explicit calendar/region/hemisphere matching. At that version,
production crop data and a verified native calendar provider remained unfinished.

Version 0.6.0 avoids duplicating those windows: it adapts the live vanilla
`farming_vegetableconf.props` sow/best/risk month arrays and consumes
weatherWorks' Build 42 calendar observation. Modded or missing definitions fail
closed. Native date synchronization and per-map geographic assumptions remain
validation gates.

Version 0.7.0 provides deterministic console diagnostics for that native gate.
The probe detects normalization mismatches and world-age regression and requires
a changed Lua session before reporting save/reload verification. Multiplayer
agreement and map-specific geographic policy remain unproven.

Version 0.8.0 resolves seed items through the same live crop-definition fields
used by vanilla planting and exposes an explicit map-context provider for
optional uiWorks badges. It supplies no guessed geographic default.

## Proof order

1. Verify Build 42 seed/crop identities and current calendar observation.
2. Define a versioned planting-window provider and one vanilla fixture.
3. Prove deterministic advice across year boundaries and altered calendars.
4. Add optional UI only after the read model is stable.
5. Validate save/load, hosted, and dedicated date consistency.

## Hardening follow-up

Version 0.9.1 fixes the audited crop/season/calendar/authority boundaries and adds
regressions for all eight cases. Before irrigation consumers, prove native
startup, seasonal configuration, save/reload and dedicated synchronization.
Partial/unknown irrigation receipts are not an atomic source-water transaction.
A small read-only inspector is the next feature slice after those checks;
soil simulation, machinery and autonomous irrigation remain later work.
