# B47ANCE'd Harvest — PROJECT ZOMBOID BUILD 42 FARMING AND
# WORKING FARM EQUIPMENT FOR ANIMALS API DEEP-DIVE
#
# Agriculture, Soil, Irrigation, Field Management, Agricultural Infrastructure,
# Draft-Animal Implements, Farm Machinery & Cross-Works Framework

TARGET:
Project Zomboid Build 42.20+ Stable

PROJECT:
B47ANCE'd Harvest

MISSION:

Turn Project Zomboid's Build 42 farming and husbandry primitives into a
comprehensive agricultural infrastructure framework.

B47ANCE'd Harvest should NOT replace vanilla farming.

B47ANCE'd Harvest should extend it into a progression from:

    hand gardening
        ↓
    subsistence farming
        ↓
    managed fields
        ↓
    animal-powered agriculture
        ↓
    mechanized agriculture
        ↓
    survivor-scale farm infrastructure

The central design rule:

VANILLA OWNS THE CROP.

B47ANCE'd Harvest OWNS THE FARM.

======================================================================
0. ARCHITECTURAL POSITION
======================================================================

Build 42 already provides substantial crop simulation.

Current B42 farming includes or has explicitly developed:

- realistic crop growth times;
- planting seasons;
- optimal planting months;
- failed/out-of-season planting;
- expanded crop varieties;
- herbs;
- repeat harvesting;
- propagation;
- weeding;
- pests;
- slug/snail infestation;
- pest control;
- watering;
- fertilizer;
- compost;
- manure;
- direct farming-tool interactions;
- animal husbandry integration;
- sandbox farming configuration.

Therefore DO NOT create:

    farmWorksPlant
    farmWorksCropGrowth
    farmWorksWaterLevel

as parallel replacements for vanilla state.

Preferred architecture:

VANILLA FARMING
       ↓
B47ANCE'd Harvest ADAPTER
       ↓
SOIL / FIELD / INFRASTRUCTURE / EQUIPMENT
       ↓
animalWorks / waterWorks / powerWorks
       ↓
PLAYER AGRICULTURE

======================================================================
1. IMPLEMENTATION CONFIDENCE
======================================================================

Classify every capability:

CONFIRMED
    Verified against current B42.20 runtime/repository.

HIGH
    Strong current primitives exist; implementation needs validation.

EXPERIMENTAL
    Technically plausible but requires a prototype.

BLOCKED
    No clean current API path.

UNVERIFIED
    Documentation/history suggests support but current stable runtime
    has not been inspected.

Critical:

OLD B41 FARMING LUA
!=
CURRENT B42 CONTRACT.

Do not assume old farming_vegetableconf, ISFarmingMenu or plant state remains
unchanged.

The installed B42.20 runtime/repository is authoritative.

======================================================================
2. VANILLA B42 FARMING BASELINE
======================================================================

Audit current B42.20 implementation for:

CROP STATE

- species;
- growth stage;
- age;
- health;
- water;
- disease;
- pests;
- weeds;
- fertilizer;
- harvestability;
- seed production;
- planting date;
- season;
- environmental suitability.

ACTIONS

- digging/furrowing;
- planting;
- watering;
- fertilizing;
- weeding;
- pest treatment;
- harvesting;
- removing crops;
- propagation.

ENVIRONMENT

- outdoors;
- indoors;
- season;
- temperature;
- rain;
- sunlight;
- soil/furrow state.

Do not design B47ANCE'd Harvest fields until this is enumerated from current code.

======================================================================
3. VANILLA FARMING SHOULD REMAIN FIRST-CLASS
======================================================================

A completely vanilla crop should automatically benefit from compatible
B47ANCE'd Harvest systems.

Example:

Vanilla tomato plant
        ↓
B47ANCE'd Harvest field contains tile
        ↓
waterWorks irrigation reaches tile
        ↓
B47ANCE'd Harvest requests vanilla watering
        ↓
vanilla tomato receives water.

Do NOT require:

farmWorksTomato.

======================================================================
4. CROP ADAPTER
======================================================================

Create a generic CropAdapter.

Conceptually:

farmWorks.Crops.get(square)
farmWorks.Crops.getType(crop)
farmWorks.Crops.getWaterNeed(crop)
farmWorks.Crops.getGrowthState(crop)
farmWorks.Crops.canHarvest(crop)
farmWorks.Crops.applyWater(...)
farmWorks.Crops.applyFertilizer(...)

Exact names follow repository conventions.

The adapter must call vanilla state wherever possible.

======================================================================
5. THIRD-PARTY CROPS
======================================================================

Do not hard-code every supported crop.

Provider system:

farmWorks.Crops.registerProvider(...)

Third-party crop mods can expose:

- water requirements;
- soil preferences;
- fertilizer behavior;
- harvest state;
- field compatibility.

Vanilla provider ships by default.

======================================================================
6. FIELD ABSTRACTION
======================================================================

Introduce:

FarmField

A field is a logical agricultural management zone.

It does NOT replace individual plants.

Potential field state:

    id
    bounds
    crop composition
    irrigation connection
    soil profile
    fertilizer status
    management settings
    equipment access
    cached crop list

This enables large-scale agriculture without scanning arbitrary world areas.

======================================================================
7. FIELD DESIGNATION
======================================================================

Allow players to designate agricultural fields.

Similar conceptually to animal zones.

Benefits:

- irrigation;
- field statistics;
- bulk management;
- equipment targeting;
- crop rotation;
- soil management;
- automation.

Do not require field designation for ordinary vanilla gardening.

======================================================================
8. FIELD UI
======================================================================

Potential:

FIELD: SOUTH FIELD

Area:
    124 tiles

Crop:
    Corn

Growth:
    68%

Water:
    Adequate

Soil:
    Fair

Weeds:
    Moderate

Pests:
    Low

Fertilization:
    Needed

Irrigation:
    Connected

Harvest:
    18 plants ready

This should summarize existing state, not create hidden duplicates.

======================================================================
9. SOIL SYSTEM
======================================================================

Vanilla farming simulates plant-level conditions but B47ANCE'd Harvest can provide a
broader persistent soil-management abstraction if current B42 lacks one.

Potential:

    fertility
    moisture retention
    compaction
    organic matter
    drainage

Avoid full agronomy simulation.

Every variable must produce meaningful gameplay.

======================================================================
10. SOIL FERTILITY
======================================================================

Generic field/tile property:

Fertility.

Possible categories:

POOR
FAIR
GOOD
RICH

Influences:

- crop health;
- growth;
- yield;
- fertilizer requirement.

Prefer broad categories over fake scientific precision.

======================================================================
11. ORGANIC MATTER
======================================================================

Potential improvement:

Adding:

- compost;
- manure;
- crop residue

can improve soil.

This creates a loop:

Animals
    ↓
Manure
    ↓
B47ANCE'd Harvest
    ↓
Soil
    ↓
Crops
    ↓
Animal feed / human food.

That is exactly the cross-Works ecosystem we want.

======================================================================
12. COMPOST
======================================================================

Vanilla has IsoCompost.

Current API exposes:

    getCompost()
    setCompost(...)
    syncCompost()
    update()
    save/load.

B47ANCE'd Harvest should ADAPT vanilla compost.

Do not replace IsoCompost.

Potential improvements:

- compost maturity information;
- material composition;
- multiple compost-bin types;
- bulk compost application;
- manure integration.

======================================================================
13. COMPOST API
======================================================================

Potential:

farmWorks.Compost.getAvailable(...)
farmWorks.Compost.consume(...)
farmWorks.Compost.applyToSoil(...)

Vanilla IsoCompost remains authoritative for vanilla compost quantity.

======================================================================
14. MANURE
======================================================================

B42 animals already produce manure. Current stable explicitly lists manure
among animal-derived resources.

Ownership:

animalWorks:
    animal produces manure.

B47ANCE'd Harvest:
    collection;
    storage;
    composting;
    fertilizer application;
    manure spreading;
    soil effect.

Do not put fertilizer calculations inside animalWorks.

======================================================================
15. MANURE PILE
======================================================================

Potential construct:

Manure Pile.

Can:

- receive animal manure;
- age;
- become usable fertilizer/compost.

Could share compost framework.

Do not create unnecessarily granular chemistry.

======================================================================
16. MANURE SPREADER
======================================================================

Late-game/draft equipment.

animalWorks:
    pulls implement.

B47ANCE'd Harvest:
    stores fertilizer payload;
    detects traversed soil;
    applies manure.

Potential:

Horse/Ox
    ↓
Harness
    ↓
Manure Spreader
    ↓
field receives fertilizer.

======================================================================
17. FERTILIZER
======================================================================

B42 farming already includes fertilizer systems.

B47ANCE'd Harvest must first enumerate vanilla fertilizer items and crop interactions.

B47ANCE'd Harvest can add:

- bulk fertilizer;
- manure;
- compost;
- spreaders;
- field application.

Do not duplicate vanilla fertilizer status.

======================================================================
18. OVER-FERTILIZATION
======================================================================

If vanilla already models excessive fertilizer:

use it.

Otherwise consider only if meaningful.

Do not punish players with invisible chemistry.

Field UI should make risk understandable.

======================================================================
19. SOIL COMPACTION
======================================================================

Potential B47ANCE'd Harvest system.

Caused by:

- repeated heavy equipment;
- vehicles;
- animal traffic;
- poor field management.

Effects:

- reduced growth;
- poorer drainage;
- harder tilling.

Can be corrected by:

- tillage;
- plowing;
- rest.

CLASSIFICATION:
HIGH as custom B47ANCE'd Harvest state.

But defer until core field mechanics are stable.

======================================================================
20. CROP ROTATION
======================================================================

Potential long-term soil system.

Repeated same crop:
    gradually reduces field performance.

Rotation:
    preserves/improves fertility.

Possible crop groups:

LEGUME
GRAIN
ROOT
VEGETABLE
FALLOW.

Do not model dozens of nutrients individually.

======================================================================
21. NITROGEN FIXING
======================================================================

Legumes can conceptually improve fertility.

Represent as:

soil fertility modifier

rather than explicit nitrogen chemistry unless future gameplay requires it.

======================================================================
22. FALLOW FIELDS
======================================================================

Allow field designation:

FALLOW.

Benefits:

- recovery;
- weed control depending management;
- grazing opportunity.

animalWorks livestock could graze fallow fields.

======================================================================
23. COVER CROPS
======================================================================

Potential future feature:

- clover;
- rye;
- other cover crop.

Purpose:

- soil recovery;
- erosion suppression;
- animal feed.

Not initial priority.

======================================================================
24. TILLING
======================================================================

Vanilla supports hand digging/furrowing.

B47ANCE'd Harvest generalizes:

hand tool
    ↓
animal-drawn till
    ↓
mechanized tiller.

All should produce compatible vanilla plantable soil.

Do NOT create a separate "B47ANCE'd Harvest soil tile" that vanilla crops cannot use.

======================================================================
25. HAND TOOLS
======================================================================

Preserve vanilla:

- hoe;
- shovel;
- appropriate digging tools.

B47ANCE'd Harvest may improve:

- area targeting;
- action feedback;
- tool wear;
- field designation.

Do not make ordinary gardening depend on B47ANCE'd Harvest machinery.

======================================================================
26. ANIMAL-DRAWN TILL
======================================================================

Previously established flagship feature.

B47ANCE'd Harvest owns:

    till implement
    soil-processing behavior
    resistance
    working width
    condition

animalWorks owns:

    animal
    harness
    hitch
    draft force
    stamina
    movement.

======================================================================
27. IMPLEMENT CONTRACT
======================================================================

Conceptually:

farmWorks.DraftImplements.register({
    requiredForce
    workingWidth
    hitchType
    resistance
    operation
})

animalWorks sees only:

    pullable implement.

B47ANCE'd Harvest sees only:

    current implement position/motion.

This avoids circular ownership.

======================================================================
28. PLOW
======================================================================

Potential implement:

Moldboard Plow.

Purpose:

- prepare untilled ground;
- improve compacted soil;
- create field-ready ground.

Possible:

1-bottom plow
2-bottom plow.

Larger implement:
    more resistance
    requires stronger/multiple animals.

======================================================================
29. CULTIVATOR
======================================================================

Purpose:

- shallow tillage;
- weed suppression;
- seedbed preparation.

Lower resistance than deep plow.

Useful repeated field maintenance.

======================================================================
30. HARROW
======================================================================

Purpose:

- smooth prepared ground;
- break clods;
- improve seedbed.

Whether this needs a distinct soil state depends on gameplay value.

Do not add implement stages purely because they exist historically.

======================================================================
31. SEED DRILL
======================================================================

Animal-drawn seed drill.

Player loads seed.

While moving over valid field:

B47ANCE'd Harvest:
    determines planting spacing
    consumes seed
    invokes vanilla planting.

This is an excellent late-game field tool.

======================================================================
32. ROW PLANTER
======================================================================

Simpler alternative to seed drill.

Could plant one/few rows at a time.

Use vanilla crop creation.

======================================================================
33. CULTIVATING WEEDS
======================================================================

Animal-drawn cultivator can reduce weeds between rows.

Use vanilla weed state if exposed.

Do not maintain B47ANCE'd Harvest-only weed percentage if vanilla already owns it.

======================================================================
34. MECHANICAL HARVESTING
======================================================================

Possible for suitable crops.

But Build 42 crop/harvest architecture must be audited first.

Potential:

- potato digger;
- grain reaper;
- specialized harvest tools.

CLASSIFICATION:
EXPERIMENTAL/HIGH.

Do not make universal combine harvester initially.

======================================================================
35. POTATO DIGGER
======================================================================

Historically appropriate animal-drawn implement.

Potential:

animal pulls implement
    ↓
B47ANCE'd Harvest identifies mature root crops
    ↓
harvest action
    ↓
produce left/collected.

Requires vanilla harvest hook.

======================================================================
36. MOWER
======================================================================

Animal-drawn sickle-bar mower.

Potential uses:

- cut grass;
- produce hay;
- clear field vegetation.

B47ANCE'd Harvest owns cutting/resource result.

animalWorks owns draft.

======================================================================
37. HAY
======================================================================

B47ANCE'd Harvest should provide a hay-production pipeline.

Grass/fodder
    ↓
cut
    ↓
dry
    ↓
hay
    ↓
store/bale
    ↓
animalWorks feed.

This gives livestock farming a sustainable agricultural loop.

======================================================================
38. HAY DRYING
======================================================================

Possible:

cut grass item/world material
    ↓
elapsed dry weather
    ↓
hay.

Weather comes from vanilla climate.

Avoid checking every piece every frame.

Use batch/elapsed-time state.

======================================================================
39. HAY BALES
======================================================================

Potential:

Loose Hay
    ↓
Baling
    ↓
Hay Bale.

Benefits:

- compact storage;
- easier transport;
- trough feeding.

Could support hand and mechanical baling.

======================================================================
40. HAY CART
======================================================================

B47ANCE'd Harvest cart variant for field collection.

animalWorks provides draft transportation framework.

B47ANCE'd Harvest supplies agricultural cargo configuration/content.

======================================================================
41. FARM WAGON
======================================================================

Generic agricultural wagon.

Uses:

- crops;
- hay;
- manure;
- tools;
- water tanks.

animalWorks owns animal-powered motion.

B47ANCE'd Harvest owns farm-specific configuration.

======================================================================
42. IRRIGATION
======================================================================

This should be a major B47ANCE'd Harvest subsystem.

waterWorks owns:

    water source
    quantity
    quality
    pipe network
    pressure
    pumps.

B47ANCE'd Harvest owns:

    irrigation scheduling
    agricultural emitters
    crop water demand
    field coverage
    application.

======================================================================
43. IRRIGATION PIPE
======================================================================

Do NOT create B47ANCE'd Harvest-specific fluid pipes.

Use waterWorks.

B47ANCE'd Harvest components register as waterWorks endpoints.

======================================================================
44. IRRIGATION SOURCE
======================================================================

Possible waterWorks sources:

- well;
- rain tank;
- cistern;
- pond;
- reservoir;
- municipal water while active;
- portable tank.

B47ANCE'd Harvest does not care where water originated.

It asks waterWorks for water.

======================================================================
45. HAND IRRIGATION
======================================================================

Vanilla watering remains.

Watering can
    ↓
vanilla plant.

B47ANCE'd Harvest does not replace it.

======================================================================
46. HOSE
======================================================================

Potential farmWorks/waterWorks integration:

waterWorks:
    hose connection/flow.

B47ANCE'd Harvest:
    agricultural watering action.

Could allow rapid manual watering.

======================================================================
47. SOAKER HOSE
======================================================================

Field irrigation endpoint.

Low pressure.
Low/medium flow.
Linear coverage.

waterWorks supplies flow.

B47ANCE'd Harvest applies water to plants in covered tiles.

======================================================================
48. DRIP IRRIGATION
======================================================================

Efficient irrigation.

Potential:

- low flow;
- precise rows;
- reduced water consumption.

Useful when waterWorks supply is scarce.

Do not simulate every droplet.

======================================================================
49. SPRINKLER
======================================================================

B47ANCE'd Harvest endpoint.

Properties:

    radius
    flowRequirement
    pressureRequirement
    applicationRate.

waterWorks determines whether sufficient water/pressure exists.

B47ANCE'd Harvest determines crop coverage.

======================================================================
50. IMPACT SPRINKLER
======================================================================

Larger field sprinkler.

Potential visual rotating sprinkler if animation practical.

Gameplay works even without complex animation.

======================================================================
51. IRRIGATION ZONES
======================================================================

A field may contain multiple irrigation zones.

Controller:

ZONE A
    tomatoes

ZONE B
    corn

ZONE C
    herbs.

This prevents watering everything simultaneously.

======================================================================
52. IRRIGATION CONTROLLER
======================================================================

Optional powered automation.

B47ANCE'd Harvest owns schedule.

powerWorks supplies electricity.

waterWorks supplies water.

Example:

06:00
    open Field A valve
    ↓
waterWorks supplies water
    ↓
B47ANCE'd Harvest applies irrigation.

======================================================================
53. MANUAL VALVES
======================================================================

Use waterWorks generic valve infrastructure if available.

B47ANCE'd Harvest can label/use valves for field zones.

Do not create another plumbing-control system.

======================================================================
54. IRRIGATION PUMP
======================================================================

waterWorks owns pump.

powerWorks powers pump.

B47ANCE'd Harvest requests irrigation demand.

Architecture:

B47ANCE'd Harvest
    ↓ water demand
waterWorks
    ↓ pump load
powerWorks
    ↓ electricity
waterWorks
    ↓ flow
B47ANCE'd Harvest
    ↓ crop watering.

======================================================================
55. GRAVITY IRRIGATION
======================================================================

waterWorks may provide gravity-fed pressure/flow.

B47ANCE'd Harvest should accept it.

This enables:

elevated rain tank
    ↓
drip irrigation

without electricity.

======================================================================
56. WATER QUALITY
======================================================================

Most crops should tolerate broader water quality than humans.

waterWorks exposes quality.

B47ANCE'd Harvest decides agricultural suitability.

Potential:

clean
rain
stagnant
contaminated.

Do not make drinking-water rules automatically equal irrigation rules.

======================================================================
57. RAIN
======================================================================

Vanilla already waters crops via rain.

B47ANCE'd Harvest should preserve vanilla rain behavior.

Irrigation should supplement it.

Controller can skip irrigation after adequate rainfall.

======================================================================
58. SOIL MOISTURE
======================================================================

Prefer vanilla crop water state as authority.

B47ANCE'd Harvest field moisture should be derived/aggregated unless a genuine soil
moisture layer is required.

Avoid two competing moisture systems.

======================================================================
59. OVERWATERING
======================================================================

If vanilla models it:
    use vanilla.

If not:
    only add if it produces worthwhile decisions.

Do not punish automatic irrigation without clear UI.

======================================================================
60. DRAINAGE
======================================================================

Potential advanced soil characteristic.

Could affect:

- overwatering;
- rain;
- crop suitability.

Not core phase.

======================================================================
61. GREENHOUSES
======================================================================

Major B47ANCE'd Harvest feature candidate.

B42 explicitly makes ordinary indoor crop growth unsuitable.

B47ANCE'd Harvest can provide legitimate controlled growing structures.

A greenhouse should NOT simply set:

    crop.isOutside = true.

Instead provide a documented environmental adapter.

======================================================================
62. GREENHOUSE DETECTION
======================================================================

Potential structure requirements:

- enclosed;
- transparent roof/walls;
- adequate sunlight;
- temperature conditions.

Need technical spike around vanilla indoor crop checks.

CLASSIFICATION:
HIGH/EXPERIMENTAL.

======================================================================
63. GREENHOUSE MICROCLIMATE
======================================================================

Possible:

    temperatureModifier
    lightAvailability
    humidity abstraction.

Do not create a complete atmospheric simulation.

Vanilla climate remains authority.

======================================================================
64. GREENHOUSE HEATING
======================================================================

powerWorks supplies electricity or other compatible energy.

B47ANCE'd Harvest owns greenhouse agricultural consequence.

Potential:

electric heater
    ↓
powerWorks
    ↓
B47ANCE'd Harvest greenhouse temperature modifier.

======================================================================
65. GREENHOUSE LIGHTING
======================================================================

lightWorks owns grow-light emission.

powerWorks powers it.

B47ANCE'd Harvest consumes agricultural light availability.

This is a natural three-project integration.

======================================================================
66. GROW LIGHTS
======================================================================

Ownership:

lightWorks:
    spectrum/intensity/light behavior.

powerWorks:
    electricity.

B47ANCE'd Harvest:
    plant growth consequence.

Do not define light physics inside farmWorks.

======================================================================
67. UV
======================================================================

lightWorks owns UV.

If plants later have UV-related responses:

B47ANCE'd Harvest consumes lightWorks UV exposure API.

No B47ANCE'd Harvest UV implementation.

======================================================================
68. PESTS
======================================================================

B42 already adds slugs and snails.

Rosemary and chickens can contribute to pest control.

This is exactly the kind of vanilla system B47ANCE'd Harvest should extend.

Audit vanilla pest state first.

======================================================================
69. PEST MANAGEMENT
======================================================================

Potential:

- hand removal;
- commercial treatments;
- companion planting;
- animal pest control;
- traps/barriers.

Do not replace vanilla slug/snail system.

======================================================================
70. CHICKEN PEST CONTROL
======================================================================

Vanilla B42 explicitly recognizes chickens as useful against slugs.

animalWorks owns chicken behavior.

B47ANCE'd Harvest owns agricultural pest consequence.

Potential integration:

animalWorks:
    chicken present/foraging.

B47ANCE'd Harvest:
    reduces applicable pest pressure.

Do not duplicate chicken AI.

======================================================================
71. COMPANION PLANTING
======================================================================

Vanilla already uses rosemary in pest-control context.

B47ANCE'd Harvest may generalize crop-neighbor modifiers.

Potential:

farmWorks.Companion.register(...)

But keep effects understandable and data-driven.

======================================================================
72. WEEDS
======================================================================

B42 includes weeding as a regular crop-care mechanic.

B47ANCE'd Harvest should expose:

- field weed status;
- bulk weeding;
- cultivator operation.

Vanilla remains owner of individual crop weed state.

======================================================================
73. HERBICIDES
======================================================================

Potential future content if period-appropriate items exist.

Avoid overcomplicating chemistry.

Manual/mechanical weed management should remain viable.

======================================================================
74. SCARECROWS
======================================================================

B42 development explicitly included scarecrow work.

Audit actual B42.20 function.

If currently cosmetic:
B47ANCE'd Harvest may provide crop-protection behavior.

If functional:
adapt vanilla behavior.

Do not assume either until inspected.

======================================================================
75. BIRDS / WILDLIFE CROP DAMAGE
======================================================================

Potential integration with animalWorks.

animalWorks:
    animal/wildlife presence.

B47ANCE'd Harvest:
    crop damage.

Not initial priority.

======================================================================
76. FENCING
======================================================================

B47ANCE'd Harvest owns agricultural fence systems where they relate to:

- field protection;
- livestock boundaries;
- electric fencing.

Vanilla construction should be reused wherever possible.

======================================================================
77. ELECTRIC FENCES
======================================================================

Previously established requirement.

Architecture:

powerWorks
    ↓
electrical supply

B47ANCE'd Harvest
    ↓
fence + energizer + contact detection

animalWorks
    ↓
animal reaction

M.O.R.T.I.S.
    ↓
generic living trauma where appropriate.

======================================================================
78. ELECTRIC FENCE COMPONENTS
======================================================================

Potential:

- fence posts;
- insulators;
- conductive wire;
- gate handle;
- energizer;
- grounding rod.

Do not require real-world electrical engineering detail beyond useful gameplay.

======================================================================
79. FENCE ENERGIZER
======================================================================

B47ANCE'd Harvest equipment.

Registers powerWorks load.

Potential state:

    powered
    outputClass
    fenceLengthCapacity
    condition.

powerWorks owns electricity.

B47ANCE'd Harvest determines fence energized state.

======================================================================
80. ELECTRIC FENCE NETWORK
======================================================================

Do NOT update every fence tile every tick.

Represent logical network:

Energizer
    ↓
FenceNetwork
    ↓
segments.

Recalculate when:

- constructed;
- removed;
- broken;
- gate state changes;
- energizer changes.

======================================================================
81. ELECTRIC FENCE CONTACT
======================================================================

When a living entity contacts an energized segment:

B47ANCE'd Harvest emits:

ElectricalFenceContact.

Consumers:

animalWorks:
    animal reaction.

M.O.R.T.I.S.:
    generic injury.

Do not run constant proximity damage loops.

======================================================================
82. LIVESTOCK GATES
======================================================================

Potential improved farm gates:

- wide gate;
- field gate;
- livestock gate.

animalWorks can understand passage/enclosure state.

Use vanilla door/gate primitives where possible.

======================================================================
83. PASTURES
======================================================================

B47ANCE'd Harvest can designate/manage pasture.

animalWorks owns grazing.

B47ANCE'd Harvest owns:

- land quality;
- recovery;
- rotation;
- pasture management.

======================================================================
84. ROTATIONAL GRAZING
======================================================================

Potential:

Pasture A:
    active.

Pasture B:
    resting.

animalWorks animals consume vegetation.

B47ANCE'd Harvest tracks land recovery.

Excellent late-game animal-agriculture loop.

======================================================================
85. OVERGRAZING
======================================================================

Potential:

too many animals
+
too little land
=
reduced pasture quality.

Do not simulate individual grass blades.

Zone-level abstraction is sufficient.

======================================================================
86. ANIMAL WATER INFRASTRUCTURE
======================================================================

B47ANCE'd Harvest does NOT add animal trough behavior.

animalWorks already owns drinking behavior.

waterWorks owns container/plumbing.

B47ANCE'd Harvest may provide agricultural placement recipes/assets if appropriate,
but domain behavior stays outside farmWorks.

======================================================================
87. BARNS
======================================================================

B47ANCE'd Harvest may add agricultural construction pieces/content.

animalWorks determines animal shelter.

waterWorks handles barn plumbing.

powerWorks handles barn electricity.

lightWorks handles lighting.

B47ANCE'd Harvest should not become a building-engine replacement.

======================================================================
88. SILOS
======================================================================

Potential agricultural bulk-storage system.

Uses:

- grain;
- animal feed.

Need to determine whether B42 container/crafting architecture supports bulk
storage cleanly.

CLASSIFICATION:
HIGH.

======================================================================
89. GRAIN BINS
======================================================================

Smaller alternative to silo.

Standard ItemContainer or appropriate B42 container component should be used.

Do not invent separate inventory semantics.

======================================================================
90. ROOT CELLARS
======================================================================

Potential B47ANCE'd Harvest agricultural storage structure.

But food temperature/spoilage is vanilla territory.

B47ANCE'd Harvest provides structure/environment.

Do not create another spoilage system.

======================================================================
91. FARM PROCESSING
======================================================================

B42's crafting overhaul already includes much deeper production.

Audit existing:

- milling;
- threshing;
- butchery;
- food processing;
- textile processing.

B47ANCE'd Harvest should fill actual gaps.

Do not duplicate B42 crafting stations.

======================================================================
92. THRESHING
======================================================================

Potential manual or mechanical processing:

grain crop
    ↓
thresh
    ↓
grain + residue.

Only implement if vanilla crop pipeline exposes appropriate products.

======================================================================
93. GRAIN MILL
======================================================================

If vanilla lacks suitable machinery:

powerWorks-powered or manual mill.

But generic food-processing behavior may belong in another future Works
project if scope expands.

Keep B47ANCE'd Harvest focused on agricultural production.

======================================================================
94. FARM TOOLS
======================================================================

Audit B42.20 agricultural tools.

Potential gaps:

- broadfork;
- scythe;
- sickle;
- pruning shears;
- seed spreader;
- hand cultivator;
- wheel hoe;
- soil rake.

Only add tools with distinct gameplay.

======================================================================
95. WHEELBARROW
======================================================================

Extremely useful agricultural equipment.

Potential:

- manure;
- compost;
- soil;
- crops;
- water containers.

Could use pullable/pushable equipment framework.

Need movement/container technical spike.

======================================================================
96. HAND CART
======================================================================

Potential shared utility object.

Do not duplicate animalWorks cart framework.

animalWorks animal-powered vehicle framework could be generalized so human
pulling/pushing is another motive provider.

Evaluate architecture before implementation.

======================================================================
97. TRACTORS
======================================================================

A 1993 Kentucky farm setting naturally supports tractors.

But tractors are a substantial vehicle project.

Potential:

- tractor;
- three-point implements;
- trailers;
- PTO.

CLASSIFICATION:
EXPERIMENTAL/HIGH.

Do not make tractors prerequisite for core farmWorks.

======================================================================
98. VANILLA VEHICLE INTEGRATION
======================================================================

Before adding tractors, audit B42 vehicle modding/runtime creation.

Prefer BaseVehicle for:

- collision;
- wheels;
- fuel;
- cargo;
- MP;
- mechanics.

Do not implement custom tractor physics in Lua.

======================================================================
99. TRACTOR IMPLEMENTS
======================================================================

Long-term:

- plow;
- cultivator;
- mower;
- seed drill;
- trailer.

Create a generic B47ANCE'd Harvest implement contract that can accept motive source:

ANIMAL
TRACTOR
HUMAN

rather than creating completely separate implementations.

======================================================================
100. MOTIVE SOURCE ABSTRACTION
======================================================================

Important architectural improvement:

B47ANCE'd Harvest implements should not fundamentally care what pulls them.

Concept:

farmWorks.MotiveProvider

Providers:

animalWorks:
    DraftAnimalProvider

B47ANCE'd Harvest:
    HumanPushProvider

Vehicle integration:
    TractorProvider.

Implement asks:

    availableForce
    speed
    direction
    attachment.

This allows one plow implementation to work with several sources.

======================================================================
101. IMPLEMENT OPERATION
======================================================================

Generic lifecycle:

attach
    ↓
lower/engage
    ↓
move
    ↓
process traversed tiles
    ↓
raise/disengage
    ↓
detach.

Only process soil while implement is engaged.

======================================================================
102. WORKING WIDTH
======================================================================

Implement property:

workingWidth.

Examples:

hand hoe:
    1 tile

small animal cultivator:
    1 tile

larger implement:
    multiple tiles where practical.

Need to respect PZ's tile scale.

Do not create unrealistic giant field operations.

======================================================================
103. TILE PROCESSING
======================================================================

Never process every tile around an implement every frame.

Track:

previous position
current position

Determine newly traversed squares.

Process each valid square once.

This is critical for performance.

======================================================================
104. IMPLEMENT CONDITION
======================================================================

Use standard item/vehicle condition concepts where possible.

Wear depends on:

- distance worked;
- soil resistance;
- impacts.

Repair uses appropriate skills/materials.

Do not create bespoke durability framework.

======================================================================
105. AGRICULTURAL SKILLS
======================================================================

Reuse vanilla Farming skill.

Potential cross-skill requirements:

Farming:
    crop/soil knowledge.

Carpentry:
    wooden infrastructure.

Metalworking:
    metal implements.

Mechanics:
    tractor equipment.

Electrical:
    electric fences/controllers.

Do not create B47ANCE'd Harvest Farming 2.0 skill.

======================================================================
106. KNOWLEDGE
======================================================================

Skill != knowledge.

Potential books/manuals:

- Practical Irrigation
- Soil Management
- Composting & Manure
- Pasture Management
- Draft Animal Farming
- Horse-Drawn Implements
- Farm Machinery
- Greenhouse Growing
- Agricultural Electrical Systems

Advanced equipment may require knowledge plus skill.

======================================================================
107. SANDBOX OPTIONS
======================================================================

Vanilla already exposes farming/compost configuration.

B47ANCE'd Harvest should respect vanilla options.

Potential B47ANCE'd Harvest sandbox controls:

- soil system complexity;
- crop rotation;
- irrigation efficiency;
- equipment wear;
- pasture degradation;
- electric-fence effects.

Avoid dozens of micro-options.

======================================================================
108. SEASONAL FARMING
======================================================================

B42 now makes planting season important.

B47ANCE'd Harvest should surface this better.

Field UI can show:

CORN
Optimal planting:
    Apr-Jun

Current:
    May

Status:
    OPTIMAL

Use vanilla crop configuration.

Do not maintain another planting calendar.

======================================================================
109. GREENHOUSE SEASON EXTENSION
======================================================================

Greenhouses may extend growing season.

But they should not necessarily eliminate every seasonal limitation.

Possible:

temperature-controlled greenhouse
+
sufficient lightWorks lighting
=
extended production.

Balance later.

======================================================================
110. FARM PLANNING UI
======================================================================

Potential planning screen:

FIELD
CROP
AREA
PLANTING WINDOW
WATER DEMAND
FERTILIZER
STATUS.

This transforms vanilla crop data into useful management information.

======================================================================
111. HARVEST FORECAST
======================================================================

Potential estimate:

Estimated harvest:
    5-8 days

based on vanilla growth state.

Avoid exact prediction where weather/growth variability makes it misleading.

======================================================================
112. BULK ACTIONS
======================================================================

B47ANCE'd Harvest should reduce repetitive late-game clicking.

Potential field actions:

- inspect field;
- assign irrigation;
- fertilize selected area;
- weed selected area;
- harvest with appropriate equipment.

Do not make bulk action free.

Time, tools and resources still matter.

======================================================================
113. PLAYER ACTION VS EQUIPMENT
======================================================================

Progression should be:

EARLY:
    player performs every action.

MID:
    better hand tools / irrigation.

LATE:
    animals/equipment reduce labor.

The reward is scalability, not magically better crops.

======================================================================
114. FARM LABOR
======================================================================

Potential abstract metric not necessary initially.

PZ's player time is already labor.

Equipment saves time and endurance.

No need for "labor points."

======================================================================
115. powerWorks INTEGRATION
======================================================================

B47ANCE'd Harvest registers loads:

- irrigation controller;
- electric fence energizer;
- greenhouse heater;
- ventilation fan;
- powered agricultural equipment;
- pumps indirectly through waterWorks.

powerWorks determines whether electricity exists.

======================================================================
116. waterWorks INTEGRATION
======================================================================

waterWorks owns:

- water sources;
- plumbing;
- storage;
- pressure;
- flow;
- pumps;
- quality.

B47ANCE'd Harvest owns:

- irrigation;
- agricultural application;
- crop response.

No parallel B47ANCE'd Harvest plumbing.

======================================================================
117. animalWorks INTEGRATION
======================================================================

animalWorks owns:

- animals;
- draft capability;
- harness;
- hitch;
- stamina;
- animal work behavior.

B47ANCE'd Harvest owns:

- implements;
- field work;
- soil effect.

This dependency direction is critical:

B47ANCE'd Harvest
    ↓
animalWorks API

animalWorks MUST NOT depend on farmWorks.

======================================================================
118. lightWorks INTEGRATION
======================================================================

lightWorks owns:

- sunlight exposure API;
- artificial light;
- grow lights;
- UV.

B47ANCE'd Harvest may consume:

    light exposure

for greenhouse/indoor agriculture.

B47ANCE'd Harvest never implements its own light engine.

======================================================================
119. M.O.R.T.I.S. INTEGRATION
======================================================================

B47ANCE'd Harvest generally should NOT directly depend on M.O.R.T.I.S.

If equipment injures living entities:

generic collision/injury event
    ↓
M.O.R.T.I.S. where appropriate.

Do not make agriculture depend on anatomy.

======================================================================
120. medWorks
======================================================================

No normal B47ANCE'd Harvest hard dependency.

Agricultural injuries can be handled by existing health/M.O.R.T.I.S./medWorks
systems.

B47ANCE'd Harvest owns dangerous equipment state, not treatment.

======================================================================
121. DEPENDENCY GRAPH
======================================================================

Preferred:

                  M.O.R.T.I.S.
                      ↓
                   medWorks
                      ↓
                 animalWorks
                      ↑
                      |
                  B47ANCE'd Harvest

waterWorks ───────→ B47ANCE'd Harvest integration
powerWorks ───────→ B47ANCE'd Harvest integration
lightWorks ───────→ B47ANCE'd Harvest integration

Exact optional/hard dependency mechanics should be determined from repository
architecture.

Important:

No animalWorks -> B47ANCE'd Harvest dependency.

======================================================================
122. ELECTRIC FENCE DEPENDENCY
======================================================================

Electric fence requires optional powerWorks functionality.

If powerWorks absent:

B47ANCE'd Harvest should either:

A. disable electrical fence recipes/features cleanly,

or

B. use a compatibility abstraction if project architecture permits.

Never duplicate powerWorks internally.

======================================================================
123. IRRIGATION DEPENDENCY
======================================================================

Advanced network irrigation depends on waterWorks.

B47ANCE'd Harvest can still retain:

vanilla watering
+
possibly basic manual farming

without waterWorks.

Do not ship a second pipe framework as fallback.

======================================================================
124. DRAFT EQUIPMENT DEPENDENCY
======================================================================

Animal-drawn equipment depends on animalWorks.

Without animalWorks:

B47ANCE'd Harvest crop/soil/infrastructure features should continue functioning.

Draft equipment can be unavailable.

======================================================================
125. GREENHOUSE LIGHT DEPENDENCY
======================================================================

If lightWorks absent:

use vanilla environmental behavior where possible.

Do not duplicate advanced lighting.

======================================================================
126. MULTIPLAYER AUTHORITY
======================================================================

SERVER owns:

- field definitions;
- soil state;
- irrigation state;
- fertilizer application;
- implement state;
- equipment attachment;
- tile processing;
- electric-fence network;
- greenhouse state;
- pasture state;
- crop-modification requests.

CLIENT owns:

- UI;
- previews;
- animations;
- placement ghosts;
- cosmetic effects.

Never trust:

client says 100 crop tiles were harvested.

======================================================================
127. FIELD ACTION VALIDATION
======================================================================

Server validates:

- player;
- field;
- permission;
- tool;
- item;
- crop;
- current state;
- distance where relevant;
- available resource;
- equipment state;
- duplicate operation.

======================================================================
128. IMPLEMENT MP
======================================================================

Canonical implement state:

    attachedTo
    motiveProvider
    engaged
    position
    direction
    condition
    payload.

Server processes agricultural tile effects.

Clients render movement.

======================================================================
129. ANIMAL-DRAWN MP
======================================================================

animalWorks owns canonical hitch graph.

B47ANCE'd Harvest receives validated movement/implement information.

Do not create a second B47ANCE'd Harvest animal attachment state.

======================================================================
130. IRRIGATION MP
======================================================================

Server:

B47ANCE'd Harvest requests demand
    ↓
waterWorks validates network
    ↓
water consumed
    ↓
B47ANCE'd Harvest applies watering.

Client cannot independently add water to crops.

======================================================================
131. ELECTRIC FENCE MP
======================================================================

Server owns:

- network connectivity;
- energizer state;
- contact events.

powerWorks owns supply state.

Clients render effects.

======================================================================
132. PERSISTENCE
======================================================================

Persist B47ANCE'd Harvest-owned state:

- field IDs/bounds;
- soil properties not owned by vanilla;
- crop rotation history;
- irrigation-zone assignments;
- pasture state;
- equipment configuration;
- fence network topology;
- greenhouse configuration.

Do NOT duplicate:

- vanilla crop growth;
- vanilla crop water;
- vanilla plant disease;
- vanilla compost quantity;
- vanilla animal state;
- waterWorks water;
- powerWorks electricity.

======================================================================
133. CHUNK UNLOAD
======================================================================

Fields can span multiple chunks.

Never retain unsafe world-object references indefinitely.

Store:

- coordinates;
- stable object IDs where available;
- logical network IDs.

Rebind on chunk load.

======================================================================
134. OFFLINE FIELD SIMULATION
======================================================================

Vanilla crop simulation should remain authoritative.

B47ANCE'd Harvest custom state uses elapsed-time/coarse updates.

Examples:

- pasture recovery;
- compost enhancement;
- soil recovery;
- irrigation schedules.

Do not replay millions of individual updates after server downtime.

======================================================================
135. PERFORMANCE
======================================================================

NEVER:

for every crop
    every tick
        scan field
        scan water
        scan animals
        scan power.

Use:

FIELD CACHE
IRRIGATION NETWORK
FENCE NETWORK
EVENTS
TIME BUCKETS.

======================================================================
136. FIELD CACHE
======================================================================

Maintain cached:

- crop coordinates;
- irrigation emitters;
- soil aggregates;
- ready-to-harvest counts.

Invalidate/update on:

- planting;
- crop removal;
- harvest;
- field resize;
- relevant world change.

======================================================================
137. IRRIGATION UPDATE RATE
======================================================================

Irrigation does not need render-frame precision.

Potential:

every game minute / suitable coarse interval.

Water application can be aggregated.

======================================================================
138. SOIL UPDATE RATE
======================================================================

Soil fertility changes very slowly.

Use event-driven changes plus long intervals.

Do not update soil every tick.

======================================================================
139. PASTURE UPDATE RATE
======================================================================

animalWorks reports grazing consumption.

B47ANCE'd Harvest adjusts pasture state in coarse batches.

No per-grass-blade simulation.

======================================================================
140. ELECTRIC FENCE PERFORMANCE
======================================================================

Logical networks.

Do not scan all fence segments continuously.

Contact detection should be localized to movement/contact events.

======================================================================
141. IMPLEMENT PERFORMANCE
======================================================================

Only evaluate newly traversed tiles while implement is engaged.

Never scan the entire field around moving equipment.

======================================================================
142. DIAGNOSTICS
======================================================================

B47ANCE'd Harvest needs a debug inspector.

Selected crop:

Vanilla Type
Growth
Water
Health
Season
Pests
Weeds
Fertilizer
Field ID

Selected field:

Area
Crop count
Crop types
Irrigation
Average water
Soil fertility
Compaction
Pests
Weeds
Harvest-ready
Pasture state

======================================================================
143. IRRIGATION DEBUGGER
======================================================================

Show:

Field
Zone
waterWorks endpoint
Available pressure
Available flow
Required flow
Coverage
Active emitters
Water applied.

======================================================================
144. IMPLEMENT DEBUGGER
======================================================================

Show:

Implement
ID
Type
Condition
Engaged
Motive provider
Available force
Required force
Speed
Working width
Last processed tile.

======================================================================
145. ELECTRIC FENCE DEBUGGER
======================================================================

Show:

Network ID
Energizer
powerWorks source
Powered?
Segments
Broken segments
Gate state
Output class.

======================================================================
146. GREENHOUSE DEBUGGER
======================================================================

Show:

Structure ID
Enclosed?
Indoor state
Vanilla climate
B47ANCE'd Harvest modifier
lightWorks exposure
powerWorks power
Temperature modifier
Crop compatibility.

======================================================================
147. FEATURE FEASIBILITY MATRIX
======================================================================

FEATURE                                  STATUS

Vanilla crop adapter                     VERY HIGH
B42 crop seasons                         VERY HIGH
Expanded crops                           VERY HIGH
Herbs                                    VERY HIGH
Repeated herb harvest                    VERY HIGH
Propagation                              VERY HIGH
Vanilla watering                         VERY HIGH
Rain watering                            VERY HIGH
Vanilla fertilizer                       VERY HIGH
Vanilla pests                            VERY HIGH
Slugs/snails                             VERY HIGH
Vanilla weeding                          VERY HIGH
Compost adapter                          VERY HIGH
Manure fertilizer                        VERY HIGH
Field designation                        HIGH
Field management UI                      HIGH
Bulk crop inspection                     HIGH
Soil fertility                           HIGH
Organic matter                           HIGH
Crop rotation                            HIGH
Compaction                               HIGH
Pasture management                       HIGH
Rotational grazing                       HIGH
Overgrazing                              HIGH
waterWorks irrigation                    HIGH
Hose irrigation                          HIGH
Drip irrigation                          HIGH
Soaker hose                              HIGH
Sprinklers                               HIGH
Irrigation zones                         HIGH
Powered irrigation controller            HIGH
Gravity irrigation                       HIGH
Animal-drawn till                        HIGH after animalWorks hitch proof
Animal-drawn plow                        HIGH
Cultivator                               HIGH
Harrow                                   HIGH
Seed drill                               HIGH/VERIFY planting hook
Mower                                    HIGH
Hay production                           HIGH
Hay drying                               HIGH
Hay bales                                HIGH
Farm wagon                               HIGH after animalWorks vehicle proof
Manure spreader                          HIGH
Potato digger                            HIGH/EXPERIMENTAL
Mechanical harvesting                    EXPERIMENTAL/HIGH
Electric fences                          HIGH
Fence energizer                          HIGH
powerWorks integration                   HIGH
Animal response to fence                 HIGH
Greenhouse                               HIGH/EXPERIMENTAL
Grow-light farming                       HIGH/EXPERIMENTAL
lightWorks integration                   HIGH
Farm silos                               HIGH
Wheelbarrow                              HIGH/EXPERIMENTAL
Animal carts                             animalWorks dependency
Tractors                                 EXPERIMENTAL/HIGH
Tractor implements                       EXPERIMENTAL
PTO simulation                           FUTURE
Full industrial agriculture              DO NOT INITIALIZE EARLY
Per-nutrient soil chemistry               DO NOT DO initially
Per-grass-blade pasture simulation        DO NOT DO
Parallel crop-growth simulation           DO NOT DO
Parallel plumbing                         DO NOT DO
Parallel electricity                      DO NOT DO

======================================================================
148. REQUIRED TECHNICAL SPIKES
======================================================================

FW-SPIKE-01
Enumerate current B42.20 farming Lua/modules.

FW-SPIKE-02
Enumerate current crop definitions.

FW-SPIKE-03
Read vanilla crop state.

FW-SPIKE-04
Modify vanilla crop water through supported path.

FW-SPIKE-05
Apply vanilla fertilizer through supported path.

FW-SPIKE-06
Read weeds.

FW-SPIKE-07
Read pest state.

FW-SPIKE-08
Read season/planting configuration.

FW-SPIKE-09
Create vanilla-compatible tilled/furrow tile.

FW-SPIKE-10
Plant vanilla crop programmatically through supported path.

FW-SPIKE-11
Harvest vanilla crop through supported path.

FW-SPIKE-12
Read/update IsoCompost.

FW-SPIKE-13
Create FarmField.

FW-SPIKE-14
Persist field across save/load.

FW-SPIKE-15
Field across multiple chunks.

FW-SPIKE-16
waterWorks irrigation endpoint.

FW-SPIKE-17
Irrigation consumes real waterWorks volume.

FW-SPIKE-18
Irrigation waters vanilla crop.

FW-SPIKE-19
Sprinkler coverage.

FW-SPIKE-20
powerWorks-powered irrigation controller.

FW-SPIKE-21
Electric fence logical network.

FW-SPIKE-22
powerWorks energizer.

FW-SPIKE-23
animalWorks fence-contact response.

FW-SPIKE-24
Generic B47ANCE'd Harvest draft implement.

FW-SPIKE-25
animalWorks horse/ox attaches implement.

FW-SPIKE-26
Moving implement processes one vanilla tile.

FW-SPIKE-27
Till multiple traversed tiles.

FW-SPIKE-28
Seed drill plants vanilla crop.

FW-SPIKE-29
Manure spreader fertilizes field.

FW-SPIKE-30
Mower/hay prototype.

FW-SPIKE-31
Greenhouse detection.

FW-SPIKE-32
Vanilla crop survives/grows in valid greenhouse.

FW-SPIKE-33
lightWorks grow-light input.

FW-SPIKE-34
Dedicated-server field operation.

FW-SPIKE-35
Dedicated-server irrigation.

FW-SPIKE-36
Dedicated-server animal implement.

======================================================================
149. REQUIRED B42.20 VANILLA AUDIT
======================================================================

Codex must inspect the current installed game/repository.

Enumerate:

FARMING

- farming modules;
- crop definitions;
- growth;
- water;
- fertilizer;
- weeds;
- pests;
- diseases;
- seasons;
- indoor/outdoor checks;
- harvesting;
- seed return;
- propagation;
- rain interaction.

TOOLS

- hoe;
- shovel;
- trowel;
- watering can;
- fertilizer tools;
- pest-control tools;
- harvesting tools;
- direct-action farming mechanics.

WORLD OBJECTS

- farm plants;
- furrows;
- compost;
- scarecrows;
- agricultural containers;
- relevant construction.

CRAFTING

- fertilizer;
- compost;
- seed processing;
- farm equipment;
- crop processing;
- animal-feed production.

MP

- crop synchronization;
- watering;
- planting;
- harvesting;
- fertilizer;
- compost.

Do not rely on B41 guides.

======================================================================
150. VANILLA CONTENT GAP AUDIT
======================================================================

For every proposed B47ANCE'd Harvest feature, record:

VANILLA HAS
VANILLA PARTIALLY HAS
VANILLA LACKS
API HOOK
B47ANCE'd Harvest IMPROVEMENT
CONFIDENCE.

Research at minimum:

- irrigation;
- hoses;
- sprinklers;
- drip irrigation;
- field designation;
- crop rotation;
- soil fertility;
- compaction;
- manure spreading;
- pasture management;
- greenhouses;
- grow lights;
- electric fences;
- farm gates;
- silos;
- haymaking;
- baling;
- animal-drawn implements;
- wheelbarrows;
- tractors;
- tractor implements.

======================================================================
151. DEVELOPMENT ROADMAP
======================================================================

FW0 — VANILLA/API AUDIT

- crop implementation;
- seasons;
- watering;
- fertilizer;
- pests;
- weeds;
- compost;
- MP;
- tool interactions;
- diagnostics.

FW1 — CORE ADAPTER

- CropAdapter;
- crop-provider registry;
- Field abstraction;
- field persistence;
- field inspector;
- third-party API.

FW2 — FIELD MANAGEMENT

- designation;
- crop indexing;
- management UI;
- bulk inspection;
- harvest readiness;
- seasonal planning.

FW3 — SOIL

- fertility;
- organic matter;
- manure;
- compost integration;
- optional compaction.

FW4 — waterWorks

- irrigation API;
- hoses;
- drip lines;
- soaker lines;
- sprinklers;
- zones;
- controllers;
- rain-aware scheduling.

FW5 — PASTURE

- pasture fields;
- animalWorks grazing integration;
- recovery;
- rotational grazing;
- overgrazing.

FW6 — ELECTRIC FENCES

- fence network;
- energizer;
- powerWorks;
- contact events;
- animalWorks reactions;
- gates.

FW7 — DRAFT IMPLEMENT FOUNDATION

Requires animalWorks hitch/draft proof.

- motive-provider API;
- implement lifecycle;
- working width;
- tile traversal;
- condition;
- MP.

FW8 — BASIC ANIMAL EQUIPMENT

- till;
- plow;
- cultivator;
- seed drill;
- wagon.

FW9 — HAY / FEED

- mower;
- hay drying;
- hay;
- baling;
- feed integration.

FW10 — ADVANCED IMPLEMENTS

- manure spreader;
- potato digger;
- specialized harvesting;
- larger draft teams.

FW11 — GREENHOUSES

- enclosure;
- microclimate;
- lightWorks;
- powerWorks;
- waterWorks irrigation.

FW12 — FARM INFRASTRUCTURE

- silos;
- storage;
- barns;
- field gates;
- agricultural utility equipment.

FW13 — MECHANIZATION

Only after vehicle feasibility proof:

- tractor;
- powered implements;
- trailers;
- vehicle integration.

FW14 — POLISH / COMPATIBILITY

- third-party crops;
- third-party animals;
- sandbox;
- MP;
- performance;
- migrations;
- documentation.

======================================================================
152. CROSS-WORKS OWNERSHIP SUMMARY
======================================================================

B47ANCE'd Harvest OWNS:

- agricultural fields;
- soil management;
- fertilizer application;
- compost agricultural use;
- manure agricultural use;
- irrigation application;
- pasture management;
- agricultural fences;
- electric-fence network;
- farm implements;
- tilling/plowing;
- planting equipment;
- haymaking;
- farm infrastructure;
- greenhouse agricultural behavior.

animalWorks OWNS:

- draft animals;
- animal stamina;
- animal strength;
- harness;
- hitch;
- animal movement;
- animal reactions;
- grazing behavior.

waterWorks OWNS:

- water;
- containers;
- pipes;
- pressure;
- pumps;
- water quality.

powerWorks OWNS:

- electricity;
- electrical generation;
- batteries;
- circuits;
- powered equipment state.

lightWorks OWNS:

- sunlight;
- artificial light;
- grow lights;
- UV.

M.O.R.T.I.S. OWNS:

- generic living anatomy/trauma.

medWorks OWNS:

- medical treatment.

======================================================================
153. FLAGSHIP CROSS-WORKS EXAMPLE
======================================================================

SURVIVOR BUILDS FARM

waterWorks Rain Tank
        ↓
waterWorks Pump
        ↓
powerWorks Solar/Battery System
        ↓
B47ANCE'd Harvest Drip Irrigation
        ↓
Vanilla Crops

animalWorks Horse
        ↓
animalWorks Harness
        ↓
B47ANCE'd Harvest Plow
        ↓
B47ANCE'd Harvest Soil
        ↓
Vanilla Crops

animalWorks Cattle
        ↓
Vanilla/animalWorks Manure
        ↓
B47ANCE'd Harvest Compost
        ↓
B47ANCE'd Harvest Fertility
        ↓
Vanilla Crops

B47ANCE'd Harvest Greenhouse
        ↓
lightWorks Grow Lights
        ↓
powerWorks Electricity
        ↓
waterWorks Irrigation
        ↓
Vanilla Crops

B47ANCE'd Harvest Electric Fence
        ↓
powerWorks Energizer
        ↓
animalWorks Avoidance

No project duplicates another project's simulation.

======================================================================
154. FARMING PROGRESSION TARGET
======================================================================

EARLY GAME

Hoe
Shovel
Watering Can
Seeds
Vanilla Crops
Hand Weeding
Manual Compost

        ↓

ESTABLISHED SURVIVOR

Field Designation
Compost
Manure
Hose
Rainwater Irrigation
Improved Hand Tools
Pasture

        ↓

WORKING FARM

animalWorks Horse/Ox
Plow
Cultivator
Seed Drill
Mower
Hay
Farm Wagon
Rotational Grazing
Electric Fences

        ↓

ADVANCED FARM

waterWorks Irrigation Network
powerWorks Pumps
Automated Irrigation
Greenhouse
lightWorks Grow Lights
Manure Spreader
Bulk Storage

        ↓

LATE-GAME AGRICULTURAL INFRASTRUCTURE

Multiple Fields
Managed Crop Rotation
Automated Water
Renewable Power
Animal Draft Teams
Mechanized Equipment
Potential Tractor Support
Sustainable Livestock/Crop Integration.

======================================================================
155. CORE DESIGN PRINCIPLE
======================================================================

DO NOT MAKE:

"More Crops."

DO NOT MAKE:

"Tractor Mod."

DO NOT MAKE:

"Irrigation Mod."

MAKE FARMING SCALE.

Vanilla B42 already provides:

PLANT
    ↓
GROW
    ↓
WATER
    ↓
WEED
    ↓
PROTECT
    ↓
HARVEST

B47ANCE'd Harvest adds:

LAND
    ↓
SOIL
    ↓
WATER INFRASTRUCTURE
    ↓
PASTURE
    ↓
ANIMAL POWER
    ↓
IMPLEMENTS
    ↓
FARM INFRASTRUCTURE
    ↓
MECHANIZATION

The player's progression should feel like rebuilding agriculture after the
collapse rather than unlocking increasingly magical crop recipes.

======================================================================
156. CODEX NEXT ACTION
======================================================================

Before broad implementation:

1. Audit the B47ANCE'd Harvest repository.
2. Audit the installed B42.20 farming implementation.
3. Enumerate every vanilla crop.
4. Enumerate every vanilla crop property.
5. Trace planting from player action to crop creation.
6. Trace watering.
7. Trace rain watering.
8. Trace fertilizer.
9. Trace weeds.
10. Trace pests.
11. Trace crop disease.
12. Trace growth.
13. Trace seasonal validation.
14. Trace harvest.
15. Trace seed return/propagation.
16. Trace IsoCompost.
17. Trace farming synchronization in MP.
18. Audit every vanilla farming tool.
19. Audit existing B42 agricultural machinery/content.
20. Audit vanilla animal/manure interfaces.
21. Verify waterWorks integration points.
22. Verify animalWorks draft/hitch contract.
23. Verify powerWorks load-provider contract.
24. Verify lightWorks exposure contract.
25. Run FW-SPIKE-01 through FW-SPIKE-36.
26. Replace every assumption in this document with runtime evidence.
27. Produce final capability matrix:
       CONFIRMED
       HIGH
       EXPERIMENTAL
       BLOCKED.
28. Build CropAdapter before adding new crop logic.
29. Build Field abstraction before large-scale automation.
30. Prove one waterWorks sprinkler watering one vanilla crop.
31. Prove one animalWorks draft animal pulling one implement over one vanilla
    farm tile.
32. Only then expand into the complete agricultural framework.

CURRENT B42.20 RUNTIME AND THE FARM WORKS REPOSITORY OVERRIDE THIS DOCUMENT
WHENEVER THEY DISAGREE.