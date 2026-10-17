local legacy=require "farmWorks/API"
local branded=require "B47ANCEDHarvest/API"
assert(branded==legacy and _G.B47ANCEDHarvest==legacy and _G.farmWorks==legacy,
    "both identities must share one API and authoritative provider registry")
assert(branded.VERSION=="0.9.1")
branded.registerCropProvider{id="rename.fixture",priority=1,matches=function()return false end,inspect=function()return{}end}
assert(legacy.CropProviders["rename.fixture"]==branded.CropProviders["rename.fixture"])
for _,name in ipairs({"SeasonalGuidance","VanillaSeasonalGuidance","SeedGuidance"})do
    assert(require("B47ANCEDHarvest/"..name)==require("farmWorks/"..name),name)
end
local probe=require "B47ANCEDHarvest/CalendarProbe"
assert(probe==require "farmWorks/CalendarProbe")
assert(probe.ROOT_KEY=="farmWorks.CalendarProbe.v1","renaming must retain diagnostic save data")
assert(B47ANCEDHarvestCalendarBegin==farmWorksCalendarBegin)
assert(B47ANCEDHarvestCalendarObserve==farmWorksCalendarObserve)
assert(B47ANCEDHarvestCalendarVerify==farmWorksCalendarVerify)
assert(require("B47ANCEDHarvest/DebugInspector")==require("farmWorks/DebugInspector"))
assert(B47ANCEDHarvestDebugInspect==farmWorksDebugInspect)
print("B47ANCEDHarvest canonical/legacy API, command and storage compatibility passed")
