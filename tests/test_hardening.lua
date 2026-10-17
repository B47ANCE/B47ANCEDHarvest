local api=require "farmWorks/API"
local failed=0
local function check(name,fn)
    local ok,reason=pcall(fn)
    if ok then print("PASS hardening: "..name)
    else failed=failed+1;print("FAIL hardening: "..name..": "..tostring(reason))end
end
local function nativeCrop()
    return{state="seeded",typeOfSeed="Tomato",waterLvl=0,waterNeeded=70,
        isAlive=function()return true end,canHarvest=function()return false end,
        water=function(self,_,uses)self.waterLvl=math.min(100,self.waterLvl+uses*10)end}
end
local function calendar()
    return{calendarId="ProjectZomboid.Gregorian",yearLengthDays=365,dayOfYear=91,
        month=4,year=1993,regionId="map.fixture",hemisphere="north"}
end
weatherWorks={observeCalendar=function(context)return context.calendar end}
local function context()
    return{cropDefinitions={Tomato={sowMonth={4},bestMonth={4},riskMonth={5}}},calendar=calendar()}
end

check("unknown/client authority rejects before mutation",function()
    local probes={false,function()error("unknown realm")end,function()return nil end,
        function()return "false"end,function()return true end}
    for _,probe in ipairs(probes)do
        isClient=probe or nil
        local crop=nativeCrop();local ok=api.applyIrrigation(crop,1)
        assert(not ok and crop.waterLvl==0,"ambiguous/client realm must not invoke crop mutation")
    end
end)
isClient=function()return false end

check("failed irrigation reports observed/unknown effects and clears locks",function()
    api.registerCropProvider{id="hardening.partial",priority=900,
        matches=function(c)return c.auditCrop end,
        inspect=function(c)
            if c.unreadable then error("readback unavailable")end
            if c.malformed then return{cropType="Fixture"}end
            return{cropType="Fixture",waterLevel=c.water,waterNeeded=70,alive=true}
        end,
        applyIrrigation=function(c,uses)
            if c.mode=="clean-rejection"then return false,"rejected"end
            c.water=c.water+(c.mode=="mismatch"and 5 or uses*10)
            if c.mode=="readback"then c.unreadable=true;return true end
            if c.mode=="malformed"then c.malformed=true;return true end
            if c.mode=="provider-change"then c.auditCrop=false;c.switched=true;return true end
            if c.mode=="rejection"then return false,"changed then rejected"end
            if c.mode=="mismatch"then return true end
            error("changed then threw")
        end}
    api.registerCropProvider{id="hardening.switched",priority=950,matches=function(c)return c.switched end,
        inspect=function(c)return{cropType="Fixture",waterLevel=c.water,waterNeeded=70,alive=true}end}
    for _,mode in ipairs({"exception","rejection","mismatch","readback","malformed","provider-change","clean-rejection"})do
        local crop={auditCrop=true,mode=mode,water=0}
        local ok,reason,receipt=api.applyIrrigation(crop,1)
        assert(not ok and type(reason)=="string"and type(receipt)=="table","failure needs additive effect receipt")
        assert(receipt.retrySafe==false and receipt.waterBefore==0 and receipt.appliedUses==nil)
        assert(api._IrrigationLocks[crop]==nil,"failure/readback must release the crop lock")
        if mode=="readback"or mode=="malformed"or mode=="provider-change"then assert(receipt.outcome=="unknown"and receipt.waterAfter==nil)
        elseif mode=="clean-rejection"then assert(receipt.outcome=="unchanged"and receipt.waterAfter==0)
        else assert(receipt.outcome=="partial"and receipt.waterAfter==crop.water and receipt.measuredIncrease==crop.water)end
        assert(crop.water==(mode=="clean-rejection"and 0 or mode=="mismatch"and 5 or 10),"no rollback/retry is authorized")
    end
    local crop=nativeCrop();local ok,receipt=api.applyIrrigation(crop,1)
    assert(ok and receipt.outcome=="applied"and receipt.appliedUses==1 and receipt.waterAfter==10)
    crop={auditCrop=true,malformed=true,water=0}
    assert(not api.applyIrrigation(crop,1)and crop.water==0,"missing initial water observation must reject mutation")
end)

check("empty and plowed furrows are not crops",function()
    local live=nativeCrop();live.waterLvl=70
    local empty=nativeCrop();empty.state="plow";empty.typeOfSeed="none";empty.nbOfGrow=-1;empty.waterNeeded=0
    local plow=nativeCrop();plow.state="plow"
    local none=nativeCrop();none.typeOfSeed="none"
    local field=api.inspectField({empty,plow,none,live})
    assert(field.count==1 and field.alive==1 and field.meanWater==70 and field.byType.none==nil)
    assert(field.rejected==3 and api.planIrrigation({empty,plow,none}).count==0)
end)

check("native sandbox seasons override caller assumptions",function()
    local old=getSandboxOptions
    getSandboxOptions=function()return{getOptionByName=function(_,name)
        assert(name=="PlantGrowingSeasons");return{getValue=function()return false end}end}end
    local ctx=context();ctx.seasonsEnabled=true
    local view=api.getVanillaPlantingGuidance("Tomato",ctx)
    getSandboxOptions=old
    assert(view.state=="unavailable"and view.reason=="seasonal growing disabled")
    local getter=getSandboxOptions
    getSandboxOptions=nil
    view=api.getVanillaPlantingGuidance("Tomato",context())
    getSandboxOptions=getter
    assert(view.state=="unavailable","missing native configuration must fail closed")
    for _,value in ipairs({"false",0})do
        getSandboxOptions=function()return{getOptionByName=function()return{getValue=function()return value end}end}end
        view=api.getVanillaPlantingGuidance("Tomato",context())
        getSandboxOptions=getter
        assert(view.state=="unavailable","non-boolean native configuration must fail closed")
    end
    getSandboxOptions=function()error("configuration unavailable")end
    view=api.getVanillaPlantingGuidance("Tomato",context());getSandboxOptions=getter
    assert(view.state=="unavailable")
    assert(api.getVanillaPlantingGuidance("Tomato",context()).state=="ideal")
end)

check("malformed optional month arrays fail closed",function()
    for _,key in ipairs({"bestMonth","riskMonth"})do
        for _,bad in ipairs({"bad",false,{0},{13},{1.5},{[2]=4},{4,named=5}})do
            local ctx=context();ctx.cropDefinitions.Tomato[key]=bad
            assert(api.getVanillaPlantingGuidance("Tomato",ctx).state=="unavailable",key.." must reject malformed data")
        end
        local ctx=context();ctx.cropDefinitions.Tomato[key]=nil
        assert(api.getVanillaPlantingGuidance("Tomato",ctx).state~="unavailable","absent optional array is valid")
    end
end)

check("calendar days are bounded integers",function()
    api.registerPlantingGuidance{cropId="hardening.Winter",calendarId="fixture.365",yearLengthDays=365,
        windows={{startDay=350,endDay=20,grade="ideal"}}}
    local function at(day)return api.getPlantingGuidance("hardening.Winter",{calendarId="fixture.365",yearLengthDays=365,dayOfYear=day})end
    for _,day in ipairs({0,-1,999,1.5,math.huge,0/0})do assert(at(day).state=="unavailable")end
    assert(at(1).state=="ideal"and at(365).state=="ideal"and at(170).state=="poor")
end)

check("native windows require compatible Gregorian calendar",function()
    local ctx=context();ctx.calendar.calendarId="fixture.400day";ctx.calendar.yearLengthDays=400
    assert(api.getVanillaPlantingGuidance("Tomato",ctx).state=="unavailable")
    ctx=context();ctx.calendar.yearLengthDays=400
    assert(api.getVanillaPlantingGuidance("Tomato",ctx).state=="unavailable")
    ctx=context();ctx.calendar.dayOfYear=999
    assert(api.getVanillaPlantingGuidance("Tomato",ctx).state=="unavailable")
    ctx=context();ctx.calendar.yearLengthDays=366
    assert(api.getVanillaPlantingGuidance("Tomato",ctx).state=="ideal")
    api.registerPlantingGuidance{cropId="hardening.Custom",calendarId="fixture.400day",yearLengthDays=400,
        windows={{startDay=390,endDay=10,grade="ideal"}}}
    assert(api.getPlantingGuidance("hardening.Custom",{calendarId="fixture.400day",yearLengthDays=400,dayOfYear=399}).state=="ideal")
end)

check("failed registration never consumes capacity or reserves id",function()
    for i=1,256 do
        assert(not pcall(api.registerPlantingGuidance,{cropId="hardening.Invalid",calendarId="fixture.365",yearLengthDays=365,windows={}}))
    end
    api.registerPlantingGuidance{cropId="hardening.Invalid",calendarId="fixture.365",yearLengthDays=365,
        windows={{startDay=1,endDay=2}}}
    assert(api.getPlantingGuidance("hardening.Invalid",{calendarId="fixture.365",yearLengthDays=365,dayOfYear=1}).state=="possible")
    for i=4,256 do api.registerPlantingGuidance{cropId="hardening.Quota"..i,calendarId="fixture.365",yearLengthDays=365,windows={{startDay=1,endDay=2}}}end
    assert(not pcall(api.registerPlantingGuidance,{cropId="hardening.Overflow",calendarId="fixture.365",yearLengthDays=365,windows={{startDay=1,endDay=2}}}))
    assert(api.getPlantingGuidance("hardening.Invalid",{calendarId="fixture.365",yearLengthDays=365,dayOfYear=1}).state=="possible")
end)
assert(failed==0,tostring(failed).." hardening regression group(s) failed")
print("B47ANCEDHarvest eight hardening regression groups passed")
