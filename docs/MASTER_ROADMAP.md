# B47ANCE'd Harvest Master Roadmap

Canonical version: 0.9.0.

## Implemented

- Bounded crop/provider inspection with detached snapshots.
- Irrigation-demand planning and provider-owned authoritative crop-side water
  application boundary without owning external water selection or withdrawal.
- Registered planting windows and deterministic seasonal-guidance core using
  weatherWorks calendar observations, including year-boundary host tests.
- Read-only adaptation of live vanilla crop `sowMonth`, `bestMonth`, and
  `riskMonth` definitions without copied balance tables.
- Debug inspection and production load-graph coverage.
- Live-registry seed-to-crop resolution and explicit map-context providers for
  optional uiWorks advice.
- Save/reload-aware native calendar diagnostics with raw-date normalization and
  monotonic-world-age checks.

## Still to add

- Optional uiWorks seed/crop advice presentation.
- Additional irrigation consumers only through measured waterWorks contracts.

## Validation and release gates

- Verify Build 42 crop identities, custom/missing crop data, nonstandard
  calendars, regional assumptions, native dates, save/load, hosted, and dedicated
  consistency. Seasonal guidance must remain advice and never modify growth.
