local farmWorks=rawget(_G,"farmWorks")or require "farmWorks/API"
local Native={SOURCE_ID="ProjectZomboid.farming_vegetableconf",MAX_MONTHS=12}

local function months(value)
    if type(value)~="table"then return nil end
    local result={};local seen={};local count=0
    for key,entry in pairs(value)do
        if type(key)~="number"or key<1 or key%1~=0 then return nil end
        count=count+1;if count>Native.MAX_MONTHS then return nil end
        local month=tonumber(entry);if not month or month~=math.floor(month)or month<1 or month>12 then return nil end
        if not seen[month]then result[#result+1]=month;seen[month]=true end
    end
    for index=1,count do if value[index]==nil then return nil end end
    table.sort(result);return result
end
local function contains(values,target)for _,value in ipairs(values or{})do if value==target then return true end end;return false end
local function unavailable(cropId,reason)return{schemaVersion=1,cropId=tostring(cropId or""),state="unavailable",reason=reason}end

function Native.evaluate(cropId,context)
    context=type(context)=="table"and context or{}
    if type(cropId)~="string"or cropId==""or#cropId>128 then return unavailable(cropId,"invalid crop id")end
    if context.seasonsEnabled==false then return unavailable(cropId,"seasonal growing disabled")end
    local root=context.cropDefinitions or(rawget(_G,"farming_vegetableconf")and farming_vegetableconf.props)
    local definition=type(root)=="table"and root[cropId]or nil
    if type(definition)~="table"then return unavailable(cropId,"vanilla crop definition unavailable")end
    local sow=months(definition.sowMonth);if not sow or#sow<1 then return unavailable(cropId,"vanilla sow months unavailable")end
    local best=definition.bestMonth~=nil and months(definition.bestMonth)or{}
    local risk=definition.riskMonth~=nil and months(definition.riskMonth)or{}
    if not best or not risk then return unavailable(cropId,"malformed vanilla seasonal months")end
    local weather=rawget(_G,"weatherWorks")
    if type(weather)~="table"or type(weather.observeCalendar)~="function"then return unavailable(cropId,"calendar provider unavailable")end
    local ok,calendar,reason=pcall(weather.observeCalendar,context.calendarContext or context)
    if not ok or type(calendar)~="table"then return unavailable(cropId,tostring(reason or"calendar unavailable"):sub(1,160))end
    local month=tonumber(calendar.month);if not month or month~=math.floor(month)or month<1 or month>12 then
        return unavailable(cropId,"calendar month unavailable")
    end
    local inSeason=contains(sow,month);local isBest=inSeason and contains(best,month);local isRisk=inSeason and contains(risk,month)
    return{schemaVersion=1,cropId=cropId,state=isBest and"ideal"or inSeason and"possible"or"poor",
        source=Native.SOURCE_ID,calendarId=calendar.calendarId,providerId=calendar.providerId,
        year=calendar.year,month=month,dayOfYear=calendar.dayOfYear,regionId=calendar.regionId,
        hemisphere=calendar.hemisphere,inSeason=inSeason,best=isBest,risk=isRisk}
end

farmWorks.VanillaSeasonalGuidance=Native
farmWorks.getVanillaPlantingGuidance=Native.evaluate
return Native
