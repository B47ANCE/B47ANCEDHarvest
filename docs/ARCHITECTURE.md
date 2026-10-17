# B47ANCE'd Harvest Architecture

Vanilla farming remains authoritative for planting, crop growth, watering,
disease, weeds, seasons, harvesting, and multiplayer synchronization.
B47ANCE'd Harvest adapts that state for field-scale management and adds agricultural
effects through explicit provider APIs.

Version 0.1.0 implements a priority-ordered crop-provider registry, a read-only
adapter for installed Build 42 `SPlantGlobalObject` fields, and pure field
summaries covering crop type, water, health, pests, harvest readiness, and
bounds. It does not mutate crop growth or introduce a parallel crop object.

waterWorks owns water sources and quality; B47ANCE'd Harvest will own irrigation demand
and application to vanilla crops. weatherWorks owns climate observations.
animalWorks owns animals, grazing behavior, stamina, and draft motive.
powerWorks owns electrical demand for controllers and fences.

Version 0.2.0 bounds field inspection to deterministic cursor pages of at most
1,024 candidates. Each result reports rejected crops and continuation state.
`farmWorks.planIrrigation` uses the same page boundary and produces pure semantic
requests from each living crop's normalized current/needed water. It never
mutates vanilla crops, selects a water source, or applies water quality;
waterWorks and a future authoritative farm action retain those responsibilities.

Version 0.3.0 adds the crop side of that authoritative action without assuming
ownership of water supply. `farmWorks.applyIrrigation` accepts whole delivered
uses, resolves the crop's registered provider, clamps the accepted use count to
the requested target deficit, and rejects client-side execution. The vanilla
provider uses Build 42's `SPlantGlobalObject:water(nil, uses)` method; that
method updates `lastWaterHour` and calls the farming object's native persistence
path. B47ANCE'd Harvest then re-inspects the crop and requires the exact vanilla
ten-water-point-per-use result. Source selection, withdrawal, quality, emitters,
and end-to-end resource coupling remain waterWorks-owned and are not implied by
this API.

Version 0.4.0 adds a client-only developer inspector over the existing APIs. It
uses the same vanilla `CFarmingSystem` square lookup as Build 42's farming menu,
examines at most 441 same-level squares, and prints aggregate crop and irrigation
demand state. It is a bounded diagnostic, not a persistent field abstraction or
player-facing knowledge system.

Version 0.4.1 snapshots crop-provider registrations and decorates detached
top-level inspection views. A third-party caller cannot replace registered
callbacks or priorities by mutating its input/return table, and B47ANCE'd Harvest does
not write normalization metadata into provider-owned result tables.

Version 0.5.0 adds read-only `SeasonalGuidance`. Each crop definition binds
planting windows to an explicit calendar ID, integer year length, and optional
region/hemisphere. Windows may wrap year-end. Missing crops, incompatible
calendars, and assumption mismatches return `unavailable`; it never predicts
weather, mutates crops, or advances time.

Version 0.7.0 adds a client-side `CalendarProbe` validation boundary. It reads
the live game clock through weatherWorks, cross-checks normalized year/month/day
against the raw Build 42 getters, and stores one bounded observation in player
ModData for a later same-session or true save/reload comparison. It requires an
explicit region and hemisphere, never advances time, and does not claim hosted
or dedicated agreement until those tests are performed.

Version 0.8.0 adds bounded live-registry seed resolution and priority-ordered
map-context providers. Multiple crop matches, malformed registries, and missing
region/hemisphere data fail closed.

Version 0.9.1 corrects adapter and boundary defects without adding an autonomous
gameplay loop. The vanilla provider excludes plow/none-seed furrows. Provider
inspection exposes waterLevelKnown; mutation requires a real finite observation.

Authority now fails closed unless isClient() explicitly returns false. The
provider call and its readback share one crop lock. Error/rejection/readback
mismatch retain the existing boolean and reason and add a transient third
receipt with partial, unchanged or unknown outcome and retrySafe=false. See
IRRIGATION_API.md for accounting limitations; this is not a source-water
transaction or a retry/deduplication protocol.

Vanilla seasonal advice reads getSandboxOptions():getOptionByName(
"PlantGrowingSeasons"):getValue(). A caller may suppress advice but cannot
override disabled/unknown native configuration. No custom gameplay knob is
introduced: authoritative settings stay vanilla, while calendar IDs, quotas,
ten-point doses and page limits remain implementation/provider contracts.

Optional best/risk arrays are validated independently. Native month windows
require the Gregorian calendar identifier and 365/366-day year; explicit custom
calendars remain supported through registered planting windows. Generic days
must be bounded integers, and registrations commit their ID/quota only after
window validation succeeds. No crop-growth, persistence or diagnostic-key
ownership changes occur. Dedicated synchronization remains untested.
