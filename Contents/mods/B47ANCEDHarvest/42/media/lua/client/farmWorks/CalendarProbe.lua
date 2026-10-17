local farmWorks=rawget(_G,"farmWorks")or require "farmWorks/API"
local Probe={ROOT_KEY="farmWorks.CalendarProbe.v1",SCHEMA_VERSION=1}
Probe.SESSION_TOKEN=tostring({})..":"..tostring(type(rawget(_G,"getTimestampMs"))=="function"and getTimestampMs()or 0)

local function call(object,name,...)
    local ok,fn=pcall(function()return object and object[name]end)
    if not ok or type(fn)~="function"then return nil end
    local called,value=pcall(fn,object,...);return called and value or nil
end
local function validId(value,maximum)
    return type(value)=="string"and value~=""and#value<=maximum and not value:find("[%c]")and value or nil
end
local function actor(value)
    if value then return value end
    if type(rawget(_G,"getPlayer"))=="function"then local ok,result=pcall(getPlayer);if ok then return result end end
end
local function store(player,create)
    local data=call(player,"getModData");if type(data)~="table"then return nil,"PLAYER_MODDATA_UNAVAILABLE"end
    local value=data[Probe.ROOT_KEY]
    if value==nil and create then value={schemaVersion=Probe.SCHEMA_VERSION};data[Probe.ROOT_KEY]=value end
    if type(value)~="table"or value.schemaVersion~=Probe.SCHEMA_VERSION then return nil,"PROBE_STATE_INVALID"end
    return value
end
local function observe(regionId,hemisphere)
    regionId=validId(regionId,96);hemisphere=validId(hemisphere,32)
    if not regionId or not hemisphere then return nil,"REGION_AND_HEMISPHERE_REQUIRED"end
    local weather=rawget(_G,"weatherWorks")
    if type(weather)~="table"or type(weather.observeCalendar)~="function"then return nil,"WEATHERWORKS_CALENDAR_UNAVAILABLE"end
    local gameTime=type(rawget(_G,"getGameTime"))=="function"and getGameTime()or nil
    if not gameTime then return nil,"GAME_TIME_UNAVAILABLE"end
    local ok,value,reason=pcall(weather.observeCalendar,{gameTime=gameTime,regionId=regionId,hemisphere=hemisphere})
    if not ok or type(value)~="table"then return nil,tostring(reason or value or"CALENDAR_UNAVAILABLE"):sub(1,160)end
    local rawYear,rawMonth,rawDay=call(gameTime,"getYear"),call(gameTime,"getMonth"),call(gameTime,"getDay")
    if value.year~=rawYear or value.month~=(tonumber(rawMonth)and rawMonth+1)or value.dayOfMonth~=(tonumber(rawDay)and rawDay+1)then
        return nil,"NORMALIZED_DATE_MISMATCH"
    end
    return{schemaVersion=1,providerId=value.providerId,calendarId=value.calendarId,year=value.year,month=value.month,
        dayOfMonth=value.dayOfMonth,dayOfYear=value.dayOfYear,yearLengthDays=value.yearLengthDays,
        worldAgeHours=value.worldAgeHours,regionId=value.regionId,hemisphere=value.hemisphere,sessionToken=Probe.SESSION_TOKEN}
end
function Probe.begin(player,regionId,hemisphere)
    player=actor(player);if not player then return false,"PLAYER_UNAVAILABLE"end
    local snapshot,reason=observe(regionId,hemisphere);if not snapshot then return false,reason end
    local state,storeReason=store(player,true);if not state then return false,storeReason end
    state.pending=snapshot;state.status="pending";return true,snapshot
end
function Probe.verify(player,requireReload)
    player=actor(player);if not player then return false,"PLAYER_UNAVAILABLE"end
    local state,reason=store(player,false);if not state then return false,reason end
    local previous=state.pending;if type(previous)~="table"then return false,"NO_PENDING_OBSERVATION"end
    if requireReload~=false and previous.sessionToken==Probe.SESSION_TOKEN then return false,"SAVE_RELOAD_REQUIRED"end
    local current,observeReason=observe(previous.regionId,previous.hemisphere);if not current then return false,observeReason end
    if current.providerId~=previous.providerId or current.calendarId~=previous.calendarId then return false,"CALENDAR_PROVIDER_CHANGED"end
    if current.worldAgeHours and previous.worldAgeHours and current.worldAgeHours<previous.worldAgeHours then return false,"WORLD_AGE_REGRESSED"end
    state.status="verified";state.verified=current;return true,current
end
local function report(action,ok,value)
    local detail=type(value)=="table"and string.format("%04d-%02d-%02d day=%d/%d age=%s region=%s hemisphere=%s",
        value.year,value.month,value.dayOfMonth,value.dayOfYear,value.yearLengthDays,tostring(value.worldAgeHours),value.regionId,value.hemisphere)or tostring(value)
    print("[B47ANCEDHarvest][CalendarProbe] "..action.." "..(ok and"PASS "or"BLOCKED ")..detail)
end
function Probe.commandBegin(regionId,hemisphere,player)
    local ok,value=Probe.begin(player,regionId,hemisphere);report("begin",ok,value);return ok,value
end
function Probe.commandVerify(player,requireReload)
    local ok,value=Probe.verify(player,requireReload~=false);report(requireReload==false and"observe"or"reload",ok,value);return ok,value
end
farmWorks.CalendarProbe=Probe
_G.farmWorksCalendarBegin=Probe.commandBegin
_G.farmWorksCalendarObserve=function(player)return Probe.commandVerify(player,false)end
_G.farmWorksCalendarVerify=function(player)return Probe.commandVerify(player,true)end
_G.B47ANCEDHarvestCalendarBegin=_G.farmWorksCalendarBegin
_G.B47ANCEDHarvestCalendarObserve=_G.farmWorksCalendarObserve
_G.B47ANCEDHarvestCalendarVerify=_G.farmWorksCalendarVerify
return Probe
