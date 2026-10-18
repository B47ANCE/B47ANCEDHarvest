# B47ANCE'd Harvest

B47ANCE'd Harvest is the farming and agricultural-infrastructure project. Its first
foundation extends vanilla Build 42 crops through read-only adapters rather
than replacing them.

- Status: version `0.9.2` bounded crop/irrigation APIs plus deterministic
  seasonal guidance backed by live vanilla crop definitions and the optional
  weatherWorks calendar and a save/reload-aware native date probe; native date synchronization remains unverified and
  this is not yet a gameplay release.

See [docs/B42_API_RESEARCH_HANDOFF.md](docs/B42_API_RESEARCH_HANDOFF.md) for the Build 42 farming audit plan. The current API normalizes vanilla and registered third-party crops and produces field summaries; mutation, automation, and machinery remain gated behind focused tests.
Approved feature research is allocated in [docs/ROADMAP.md](docs/ROADMAP.md).
Field inspection is cursor-paged under a hard 1,024-crop ceiling. The irrigation
planner derives per-crop and aggregate water demand from normalized live crop
state without mutating crops or assuming waterWorks supply availability.
`applyIrrigation` now applies already-delivered whole irrigation uses through a
provider-owned authoritative method. The vanilla provider calls the verified
Build 42 `SPlantGlobalObject:water(nil, uses)` path, clamps work to the current
target deficit, rejects client-side mutation, and verifies the resulting crop
water level. It does not choose or withdraw a waterWorks source.

For development inspection, `B47ANCEDHarvestDebugInspect(radius)` samples only the
current Z level in a square radius clamped to 0–10 tiles. It resolves crops
through Build 42's `CFarmingSystem.instance:getLuaObjectOnSquare`, then prints
canonical field totals and non-mutating irrigation demand. It does not create a
field, reveal a player-facing farming panel, or alter crops.
- Hard dependencies: none beyond Project Zomboid for its base module.
- Optional integrations: animalWorks, waterWorks, powerWorks, and lightWorks.
- Ownership: crop/soil enhancements, agricultural implements, irrigation
  effects, farm transport content, and electric-fence gameplay.

The owner-supplied Harvest PNG is kept unchanged at
`Contents/mods/B47ANCEDHarvest/thumbnail.png` for the mod poster. Root
`preview.png` is the approved 960 x 960 Workshop export (954,246 bytes). Build 42 metadata uses `poster=thumbnail.png`; the small `42/icon.png`
is unchanged. [Artwork provenance](docs/ARTWORK.json) records dimensions/hashes
and the preserved previous image. Workshop distribution uses the validated
preview export described there.

## Identity and compatibility

- Display name: B47ANCE'd Harvest.
- Mod ID and authoritative mod folder: `B47ANCEDHarvest`.
- Existing Workshop item: `3788591121` (unchanged).
- Previous Mod ID: `farmWorks`. Update enabled-mod lists to `B47ANCEDHarvest`;
  do not enable both identities. Re-enable the mod after changing the ID.
  Existing-save compatibility remains a runtime gate.
- Canonical Lua entry: `require "B47ANCEDHarvest/API"` and global
  `B47ANCEDHarvest`. Legacy `farmWorks` globals, require paths and commands
  share the same implementation and provider registry.
- Retain diagnostic ModData key `farmWorks.CalendarProbe.v1` unchanged;
  no schema migration or parallel crop/save state.

`Contents/mods/B47ANCEDHarvest/` is authoritative runtime source. Root Workshop
text is authoring metadata. `dist/`, checksum ledgers and the last-upload marker
are historical outputs, not current source or publication proof.

See [versioning](docs/VERSIONING.md), [validation](docs/VALIDATION.md), and
[testing](docs/TESTING.md). Root `VERSION` is canonical. Public source repository:
[B47ANCE/B47ANCEDHarvest](https://github.com/B47ANCE/B47ANCEDHarvest).
The initial import, 0.9.1 hardening and publication preparation merged through
PRs #1–#3. The cosmetic 0.9.2 iteration uses `art/harvest-0.9.2-thumbnail` for
PR review. Historical output archives
and private developer settings remain local and are excluded from Git.
G7 dedicated multiplayer NOT TESTED / BLOCKED; stable-release G8 BLOCKED.

## Hardening behavior

Crop totals exclude empty furrows. Seasonal advice reads the native
PlantGrowingSeasons sandbox option and fails closed on malformed month arrays,
invalid days or incompatible native calendars. Native crop windows require
ProjectZomboid.Gregorian with 365/366 days; explicitly registered windows still
support custom calendars. Rejected registrations consume no ID or capacity.

Irrigation rejects uncertain execution authority. Provider failures may already
have changed the crop; the additive third return value reports partial,
unchanged or unknown water effects without authorizing automatic retries.
See [the irrigation contract](docs/IRRIGATION_API.md). No new user sandbox
setting is needed: these are safety checks and existing vanilla configuration.

## Workshop test distribution

Version 0.9.1 was uploaded as an MP testing build to existing item 3788591121.
A subsequent explicit publish request authorizes packaging and Workshop MP test
distribution of the cosmetic 0.9.2 iteration. Description and current change
notes retain the MP-testing label. See [publishing](docs/PUBLISHING.md).

scripts/build_workshop.py creates deterministic committed-source ZIP/staging
and a release manifest under ignored dist/current. It does not upload, overwrites
no existing outputs, and ships only the selected mod. Steam receives staging/
Contents as its content folder; the ZIP retains the authoring Contents layout.
