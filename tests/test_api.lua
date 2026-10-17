local api=dofile(assert(arg[1]))
local function water(self,source,uses)
    assert(source==nil)
    self.waterLvl=math.min(100,self.waterLvl+uses*10)
    self.waterCalls=(self.waterCalls or 0)+1
end
local crops={
    {typeOfSeed="Tomato",nbOfGrow=4,waterLvl=80,waterNeeded=70,health=90,x=2,y=4,z=0,isAlive=function()return true end,canHarvest=function()return true end,water=water},
    {typeOfSeed="Cabbages",nbOfGrow=2,waterLvl=40,waterNeeded=70,health=50,x=5,y=8,z=0,isAlive=function()return true end,canHarvest=function()return false end,water=water},
}
local tomato=assert(api.inspectCrop(crops[1]))
assert(tomato.providerId=="vanilla.SPlantGlobalObject" and tomato.harvestReady and tomato.waterLevel==80)
local field=api.inspectField(crops)
assert(field.count==2 and field.alive==2 and field.harvestReady==1 and field.meanWater==60)
assert(field.byType.Tomato==1 and field.bounds.minX==2 and field.bounds.maxY==8)
local irrigation=api.planIrrigation(crops)
assert(irrigation.count==1 and irrigation.totalAmount==30)
assert(irrigation.requests[1].cropType=="Cabbages" and irrigation.requests[1].targetWater==70)
local many={}; for index=1,1100 do many[index]=crops[1] end
local bounded=api.inspectField(many,{limit=9999})
assert(bounded.count==api.MAX_FIELD_PAGE and bounded.nextCursor==api.MAX_FIELD_PAGE)
local tail=api.inspectField(many,{cursor=bounded.nextCursor,limit=9999})
assert(tail.count==76 and tail.nextCursor==nil)

local applied,result=api.applyIrrigation(crops[2],9,{targetWater=70})
assert(applied and result.requestedUses==9 and result.appliedUses==3)
assert(result.waterBefore==40 and result.waterAfter==70 and result.measuredIncrease==30)
assert(crops[2].waterCalls==1)
local needed,neededErr=api.applyIrrigation(crops[2],1,{targetWater=70})
assert(not needed and neededErr=="crop does not require irrigation")
local fractional,fractionalErr=api.applyIrrigation(crops[2],1.5,{targetWater=100})
assert(not fractional and fractionalErr=="positive whole irrigation-use count required")

_G.isClient=function()return true end
local clientApplied,clientErr=api.applyIrrigation(crops[2],1,{targetWater=100})
assert(not clientApplied and clientErr=="irrigation application requires server or single-player authority")
_G.isClient=function()return false end

local cachedModel={cropType="Mod",waterLevel=150}
local providerDefinition={id="test.mod",priority=200,matches=function(c)return c.modCrop end,
    inspect=function()return cachedModel end}
local providerResult=api.registerCropProvider(providerDefinition)
providerDefinition.matches=function()return false end;providerDefinition.inspect=function()return {}end
providerResult.matches=function()return false end;providerResult.inspect=function()return {}end
local modded=assert(api.inspectCrop({modCrop=true,typeOfSeed="ignored",waterLvl=1}))
assert(modded.providerId=="test.mod" and modded.waterLevel==100)
assert(cachedModel.providerId==nil and cachedModel.waterLevel==150,
    "crop inspection must not mutate provider-owned models")
modded.cropType="consumer mutation"
assert(api.inspectCrop({modCrop=true}).cropType=="Mod",
    "crop inspection must return a detached top-level provider view")
local unsupported,unsupportedErr=api.applyIrrigation({modCrop=true,typeOfSeed="ignored",waterLvl=1},1,{targetWater=100})
assert(not unsupported and unsupportedErr=="crop provider does not support irrigation application")
print("B47ANCEDHarvest crop-provider/field-inspection/irrigation-application checks passed")
