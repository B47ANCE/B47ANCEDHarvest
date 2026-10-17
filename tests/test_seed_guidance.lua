farmWorks={getVanillaPlantingGuidance=function(id,context)return{cropId=id,state="ideal",regionId=context.calendarContext.regionId}end}
local Seed=dofile(arg[1]);local defs={Tomato={seedTypes={"Base.TomatoSeed","Base.TomatoSeedBag"}},Carrot={seedName="Base.CarrotSeed"}}
assert(Seed.resolveCrop("Base.TomatoSeed",defs)=="Tomato");assert(Seed.resolveCrop("Base.CarrotSeed",defs)=="Carrot")
assert(Seed.resolveCrop("Base.Nope",defs)==nil)
local ambiguous={A={seedName="Base.Seed"},B={seedTypes={"Base.Seed"}}};local _,reason=Seed.resolveCrop("Base.Seed",ambiguous);assert(reason=="ambiguous seed crop")
Seed.registerContextProvider{id="map.fixture",getContext=function()return{regionId="region:a",hemisphere="north"}end}
local result=assert(Seed.evaluate({},"Base.TomatoSeed",{cropDefinitions=defs}));assert(result.cropId=="Tomato"and result.regionId=="region:a")
print("B47ANCEDHarvest live seed-to-crop seasonal guidance checks passed")
