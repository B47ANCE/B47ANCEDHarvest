local farmWorks=rawget(_G,"farmWorks")or{}
local Guidance={MAX_CROPS=256,MAX_WINDOWS=8};local crops={};local count=0
local function finite(value)value=tonumber(value);return value and value==value and value~=math.huge and value~=-math.huge and value or nil end
local function validId(value,maximum)return type(value)=="string"and value~=""and#value<=maximum and not value:find("[%c]")end
local function inside(day,first,last)return first<=last and day>=first and day<=last or first>last and(day>=first or day<=last)end
local function windows(values,length)
    assert(type(values)=="table"and#values>0 and#values<=Guidance.MAX_WINDOWS,"one to eight planting windows required")
    local result={};for _,window in ipairs(values)do local first,last=finite(window.startDay),finite(window.endDay)
        assert(first and last and first==math.floor(first)and last==math.floor(last)and first>=1 and last>=1 and first<=length and last<=length,"window outside declared calendar")
        result[#result+1]={startDay=first,endDay=last,grade=window.grade=="ideal"and"ideal"or"possible"}end;return result
end
function Guidance.register(definition)
    assert(type(definition)=="table"and validId(definition.cropId,128)and validId(definition.calendarId,96),"crop and calendar ids required")
    local length=finite(definition.yearLengthDays);assert(length and length==math.floor(length)and length>=1 and length<=10000,"bounded calendar length required")
    assert(not crops[definition.cropId],"duplicate crop guidance");assert(count<Guidance.MAX_CROPS,"crop guidance limit reached")
    local registered={cropId=definition.cropId,calendarId=definition.calendarId,yearLengthDays=length,
        regionId=definition.regionId,hemisphere=definition.hemisphere,windows=windows(definition.windows,length)}
    crops[definition.cropId]=registered;count=count+1
    return{cropId=definition.cropId,calendarId=definition.calendarId}
end
function Guidance.evaluate(cropId,calendar)
    local definition=crops[cropId];if not definition then return{schemaVersion=1,cropId=cropId,state="unavailable",reason="crop guidance unavailable"}end
    if type(calendar)~="table"or calendar.calendarId~=definition.calendarId or calendar.yearLengthDays~=definition.yearLengthDays then return{schemaVersion=1,cropId=cropId,state="unavailable",reason="calendar mismatch"}end
    if definition.regionId and calendar.regionId~=definition.regionId or definition.hemisphere and calendar.hemisphere~=definition.hemisphere then return{schemaVersion=1,cropId=cropId,state="unavailable",reason="region assumptions mismatch"}end
    local day=finite(calendar.dayOfYear)
    if not day or day~=math.floor(day)or day<1 or day>definition.yearLengthDays then
        return{schemaVersion=1,cropId=cropId,state="unavailable",reason="calendar day outside declared calendar"}
    end
    local state="poor";for _,window in ipairs(definition.windows)do if inside(day,window.startDay,window.endDay)then if window.grade=="ideal"then state="ideal";break elseif state~="ideal"then state="possible"end end end
    return{schemaVersion=1,cropId=cropId,state=state,calendarId=definition.calendarId,dayOfYear=day,regionId=calendar.regionId,hemisphere=calendar.hemisphere}
end
farmWorks.SeasonalGuidance=Guidance;farmWorks.registerPlantingGuidance=Guidance.register;farmWorks.getPlantingGuidance=Guidance.evaluate;_G.farmWorks=farmWorks
return Guidance
