local farmWorks=rawget(_G,"farmWorks") or require "farmWorks/API"
local Inspector={MAX_RADIUS=10}

local function call(object,method,...)
    if not object then return nil end
    local ok,fn=pcall(function()return object[method]end)
    if not ok or type(fn)~="function"then return nil end
    local called,value=pcall(fn,object,...)
    return called and value or nil
end

local function radius(value)
    value=math.floor(tonumber(value)or 5)
    return math.max(0,math.min(Inspector.MAX_RADIUS,value))
end

function Inspector.collect(playerObj,requestedRadius)
    local origin=call(playerObj,"getSquare")
    if not origin then return nil,"player square unavailable"end
    local system=rawget(_G,"CFarmingSystem")
    system=type(system)=="table"and system.instance or nil
    if not system or type(system.getLuaObjectOnSquare)~="function"then
        return nil,"vanilla farming system unavailable"
    end
    local cell=type(getCell)=="function"and getCell()or nil
    if not cell then return nil,"world cell unavailable"end
    local r=radius(requestedRadius);local crops={};local visited=0
    local x,y,z=call(origin,"getX"),call(origin,"getY"),call(origin,"getZ")
    if x==nil or y==nil or z==nil then return nil,"player coordinates unavailable"end
    for dx=-r,r do
        for dy=-r,r do
            visited=visited+1
            local square=call(cell,"getGridSquare",x+dx,y+dy,z)
            local crop=call(system,"getLuaObjectOnSquare",square)
            if crop then crops[#crops+1]=crop end
        end
    end
    local summary=farmWorks.inspectField(crops,{limit=farmWorks.MAX_FIELD_PAGE})
    local irrigation=farmWorks.planIrrigation(crops,{limit=farmWorks.MAX_FIELD_PAGE})
    return {schemaVersion=1,radius=r,visitedSquares=visited,crops=crops,
        summary=summary,irrigation=irrigation}
end

function Inspector.format(result)
    if type(result)~="table"or type(result.summary)~="table"or type(result.irrigation)~="table"then
        return nil,"invalid inspection result"
    end
    local summary=result.summary;local irrigation=result.irrigation
    local types={};for cropType,count in pairs(summary.byType or{})do types[#types+1]=tostring(cropType).."="..tostring(count)end
    table.sort(types)
    return table.concat({
        "radius="..tostring(result.radius),
        "squares="..tostring(result.visitedSquares),
        "crops="..tostring(summary.count),
        "rejected="..tostring(summary.rejected),
        "alive="..tostring(summary.alive),
        "harvestReady="..tostring(summary.harvestReady),
        string.format("meanWater=%.2f",tonumber(summary.meanWater)or 0),
        string.format("irrigationDemand=%.2f",tonumber(irrigation.totalAmount)or 0),
        "irrigationCrops="..tostring(irrigation.count),
        "types="..(#types>0 and table.concat(types,",")or"none"),
    }," ")
end

function Inspector.run(requestedRadius,playerNum)
    local playerObj=type(getSpecificPlayer)=="function"and getSpecificPlayer(math.max(0,math.floor(tonumber(playerNum)or 0)))or nil
    local result,reason=Inspector.collect(playerObj,requestedRadius)
    if not result then print("[B47ANCEDHarvest][Debug] FAILED "..tostring(reason));return false,reason end
    local line=Inspector.format(result)
    print("[B47ANCEDHarvest][Debug] "..tostring(line))
    return true,result
end

_G.farmWorksDebugInspect=function(requestedRadius,playerNum)return Inspector.run(requestedRadius,playerNum)end
farmWorks.DebugInspector=Inspector
_G.B47ANCEDHarvestDebugInspect=_G.farmWorksDebugInspect
return Inspector
