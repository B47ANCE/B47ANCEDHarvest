local farmWorks=rawget(_G,"farmWorks") or {}
farmWorks.VERSION="0.9.0"
farmWorks.CropProviders=farmWorks.CropProviders or {}
farmWorks.MAX_FIELD_PAGE=1024
farmWorks._IrrigationLocks=farmWorks._IrrigationLocks or setmetatable({},{__mode="k"})

local function clamp(value,min,max) return math.max(min,math.min(max,tonumber(value) or min)) end
local function read(object,key,method)
    if key~=nil and type(object)=="table" and object[key]~=nil then return object[key] end
    if object and method then
        local ok,fn=pcall(function() return object[method] end)
        if ok and type(fn)=="function" then local called,value=pcall(fn,object); if called then return value end end
    end
    return nil
end

function farmWorks.registerCropProvider(definition)
    assert(type(definition)=="table" and type(definition.id)=="string","crop provider id required")
    assert(type(definition.matches)=="function" and type(definition.inspect)=="function","crop provider callbacks required")
    assert(not farmWorks.CropProviders[definition.id],"duplicate B47ANCEDHarvest crop provider: "..definition.id)
    local registered={id=definition.id,priority=tonumber(definition.priority) or 0,
        matches=definition.matches,inspect=definition.inspect,applyIrrigation=definition.applyIrrigation}
    farmWorks.CropProviders[registered.id]=registered
    return {id=registered.id,priority=registered.priority,matches=registered.matches,
        inspect=registered.inspect,applyIrrigation=registered.applyIrrigation}
end

local function providers()
    local result={}; for _,definition in pairs(farmWorks.CropProviders) do result[#result+1]=definition end
    table.sort(result,function(a,b)
        local ap,bp=tonumber(a.priority) or 0,tonumber(b.priority) or 0
        return ap==bp and a.id<b.id or ap>bp
    end)
    return result
end

function farmWorks.inspectCrop(crop)
    for _,provider in ipairs(providers()) do
        local ok,matched=pcall(provider.matches,crop)
        if ok and matched then
            local inspectedOk,value=pcall(provider.inspect,crop)
            if inspectedOk and type(value)=="table" then
                local view={};for key,entry in pairs(value)do view[key]=entry end
                view.schemaVersion=1; view.providerId=provider.id; view.source=crop
                view.waterLevel=clamp(view.waterLevel,0,100)
                view.growthStage=tonumber(view.growthStage)
                view.cropType=view.cropType and tostring(view.cropType) or "unknown"
                return view
            end
        end
    end
    return nil,"no compatible crop provider"
end

farmWorks.registerCropProvider({id="vanilla.SPlantGlobalObject",priority=100,
    matches=function(crop)return read(crop,"typeOfSeed")~=nil and read(crop,"waterLvl")~=nil end,
    inspect=function(crop)return {
        cropType=read(crop,"typeOfSeed"),growthStage=read(crop,"nbOfGrow"),waterLevel=read(crop,"waterLvl"),
        waterNeeded=tonumber(read(crop,"waterNeeded")),health=tonumber(read(crop,"health")),
        mildew=tonumber(read(crop,"mildewLvl")),flies=tonumber(read(crop,"fliesLvl")),
        aphids=tonumber(read(crop,"aphidLvl")),slugs=tonumber(read(crop,"slugsLvl")),
        weeds=read(crop,"hasWeeds")==true,alive=read(crop,nil,"isAlive"),harvestReady=read(crop,nil,"canHarvest"),
        x=tonumber(read(crop,"x")),y=tonumber(read(crop,"y")),z=tonumber(read(crop,"z")),
    } end,
    applyIrrigation=function(crop,uses)
        local ok,water=pcall(function() return crop.water end)
        if not ok or type(water)~="function" then return false,"authoritative vanilla water method unavailable" end
        water(crop,nil,uses)
        return true
    end})

function farmWorks.inspectField(crops,options)
    crops=type(crops)=="table" and crops or {}; options=type(options)=="table" and options or {}
    local cursor=math.max(0,math.floor(tonumber(options.cursor) or 0))
    local limit=math.max(1,math.min(farmWorks.MAX_FIELD_PAGE,math.floor(tonumber(options.limit) or farmWorks.MAX_FIELD_PAGE)))
    local last=math.min(#crops,cursor+limit)
    local field={schemaVersion=1,count=0,alive=0,harvestReady=0,totalWater=0,byType={},bounds=nil,
        cursor=cursor,limit=limit,totalCandidates=#crops,nextCursor=last<#crops and last or nil,rejected=0}
    for index=cursor+1,last do
        local crop=crops[index]
        local value=farmWorks.inspectCrop(crop)
        if value then
            field.count=field.count+1; field.totalWater=field.totalWater+value.waterLevel
            if value.alive~=false then field.alive=field.alive+1 end
            if value.harvestReady==true then field.harvestReady=field.harvestReady+1 end
            field.byType[value.cropType]=(field.byType[value.cropType] or 0)+1
            if value.x and value.y then
                local b=field.bounds or {minX=value.x,maxX=value.x,minY=value.y,maxY=value.y,minZ=value.z or 0,maxZ=value.z or 0}
                b.minX=math.min(b.minX,value.x); b.maxX=math.max(b.maxX,value.x)
                b.minY=math.min(b.minY,value.y); b.maxY=math.max(b.maxY,value.y)
                b.minZ=math.min(b.minZ,value.z or 0); b.maxZ=math.max(b.maxZ,value.z or 0); field.bounds=b
            end
        else field.rejected=field.rejected+1 end
    end
    field.meanWater=field.count>0 and field.totalWater/field.count or 0
    return field
end

function farmWorks.planIrrigation(crops,options)
    options=type(options)=="table" and options or {}
    local inspected=farmWorks.inspectField(crops,options)
    local requests={}; local total=0
    local start=inspected.cursor+1; local last=math.min(#(type(crops)=="table" and crops or {}),start+inspected.limit-1)
    for index=start,last do
        local crop=farmWorks.inspectCrop(crops[index])
        if crop and crop.alive~=false then
            local target=tonumber(crop.waterNeeded)
            local current=tonumber(crop.waterLevel) or 0
            if target and target>current then
                local amount=math.max(0,math.min(100,current+(target-current))-current)
                if amount>0 then
                    requests[#requests+1]={cropIndex=index,cropType=crop.cropType,x=crop.x,y=crop.y,z=crop.z,
                        currentWater=current,targetWater=math.min(100,target),amount=amount,providerId=crop.providerId}
                    total=total+amount
                end
            end
        end
    end
    return {schemaVersion=1,requests=requests,totalAmount=total,count=#requests,
        cursor=inspected.cursor,nextCursor=inspected.nextCursor,totalCandidates=inspected.totalCandidates,
        inspectedCount=inspected.count,rejected=inspected.rejected}
end

local function providerById(id)
    return id and farmWorks.CropProviders[id] or nil
end

local function clientAuthority()
    local checker=rawget(_G,"isClient")
    if type(checker)~="function" then return false end
    local ok,value=pcall(checker)
    return ok and value==true
end

-- Applies only the crop-side effect for water that an owning system has already
-- delivered. Source selection, withdrawal, and quality remain waterWorks-owned.
-- Vanilla watering is quantized in ten-point uses by SPlantGlobalObject:water().
function farmWorks.applyIrrigation(crop,requestedUses,options)
    options=type(options)=="table" and options or {}
    local uses=tonumber(requestedUses)
    if not uses or uses~=uses or uses==math.huge or uses<=0 or uses~=math.floor(uses) then
        return false,"positive whole irrigation-use count required"
    end
    if clientAuthority() then return false,"irrigation application requires server or single-player authority" end
    if farmWorks._IrrigationLocks[crop] then return false,"crop irrigation already in progress" end

    local before,beforeErr=farmWorks.inspectCrop(crop)
    if not before then return false,beforeErr end
    if before.alive==false then return false,"crop is not alive" end
    local provider=providerById(before.providerId)
    if not provider or type(provider.applyIrrigation)~="function" then
        return false,"crop provider does not support irrigation application"
    end

    local current=tonumber(before.waterLevel) or 0
    local target=tonumber(options.targetWater)
    if target==nil then target=tonumber(before.waterNeeded) or 100 end
    target=clamp(target,0,100)
    if target<=current then return false,"crop does not require irrigation" end
    local acceptedUses=math.min(uses,math.ceil((target-current)/10))
    if acceptedUses<=0 then return false,"crop does not require irrigation" end

    farmWorks._IrrigationLocks[crop]=true
    local called,applied,reason=pcall(provider.applyIrrigation,crop,acceptedUses,options)
    farmWorks._IrrigationLocks[crop]=nil
    if not called then return false,"irrigation provider failed: "..tostring(applied) end
    if applied~=true then return false,reason or "irrigation provider rejected application" end

    local after,afterErr=farmWorks.inspectCrop(crop)
    if not after then return false,"crop readback failed: "..tostring(afterErr) end
    if after.providerId~=before.providerId then return false,"crop provider changed during irrigation" end
    local observed=tonumber(after.waterLevel)
    local expected=math.min(100,current+acceptedUses*10)
    if not observed or observed~=expected then
        return false,"irrigation readback mismatch"
    end
    return true,{schemaVersion=1,providerId=after.providerId,cropType=after.cropType,
        requestedUses=uses,appliedUses=acceptedUses,targetWater=target,
        waterBefore=current,waterAfter=observed,measuredIncrease=observed-current,
        x=after.x,y=after.y,z=after.z}
end

_G.farmWorks=farmWorks
_G.B47ANCEDHarvest=farmWorks
require "farmWorks/SeasonalGuidance"
require "farmWorks/VanillaSeasonalGuidance"
require "farmWorks/SeedGuidance"
return farmWorks
