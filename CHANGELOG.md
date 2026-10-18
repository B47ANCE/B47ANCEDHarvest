# B47ANCE'd Harvest changelog

## 0.9.2

- Keep the user-supplied 1254 x 1254 PNG unchanged as the mod thumbnail and
  export an approved 960 x 960 PNG preview below Steam's size limit. Preserve
  the previous artwork and validation evidence.
- Cosmetic PATCH; gameplay, configuration, APIs, schemas and small icon are
  unchanged. A subsequent publish request authorizes MP test distribution;
  preview export/provenance must pass before upload. No deployment.

## 0.9.1

- Prepare explicitly labelled Workshop MP test distribution with public source
  link, reproducible offline packaging/provenance and reviewed mod overview.

- Reject crop mutation when the engine authority probe is missing, throws or
  returns a non-boolean result.
- Add explicit non-retryable irrigation failure receipts for observed partial,
  unchanged or unknown crop-water effects, without rollback or automatic retry.
- Exclude empty/plowed furrows from crop counts, water summaries and irrigation.
- Read the native PlantGrowingSeasons option; caller flags cannot enable advice
  when the native option disables it or configuration is unavailable.
- Reject malformed optional planting months, incompatible native calendars and
  non-integer/out-of-range calendar days. Keep explicit custom-window calendars.
- Commit planting guidance registrations only after complete validation so
  failed registrations consume no quota or crop ID.
- Add regressions for all eight audited defects. Validation remains offline;
  G7 dedicated multiplayer NOT TESTED / BLOCKED and stable G8 BLOCKED.

## 0.9.0

- Rename farmWorks to B47ANCE'd Harvest, including Mod ID and active mod folder
  `B47ANCEDHarvest`; enabled-mod lists must be updated.
- Keep Workshop item `3788591121`, legacy Lua API and diagnostic saved-data key.
  Add branded API entry points and commands sharing the same implementation.
- Establish user-approved canonical VERSION, mirror inventory, version checks,
  and a standalone offline host-test runner.
- Preserve artwork, historical packages, checksum ledgers and upload evidence.
  No gameplay, balance, authority, dependency or schema changes.
- Initialize the public B47ANCE/B47ANCEDHarvest GitHub repository and import
  this development iteration on feature/harvest-0.9.0 for PR review.
- Allow clean-clone identity validation without local output archives; retain
  strict preservation validation for the original development workspace.
- Development iteration only. Dedicated MP NOT TESTED; G7/stable G8 BLOCKED.

Earlier history remains in WORKSHOP_CHANGE_NOTE.txt and version-specific
architecture/roadmap records; no old runtime evidence was upgraded.
