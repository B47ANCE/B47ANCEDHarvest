local memory={}
local player={getModData=function()return memory end}
local raw={year=1993,month=11,day=30,age=100}
function raw:getYear()return self.year end
function raw:getMonth()return self.month end
function raw:getDay()return self.day end
function raw:getWorldAgeHours()return self.age end
getGameTime=function()return raw end
getPlayer=function()return player end
weatherWorks={observeCalendar=function(context)
    return{providerId="weatherWorks.Build42Calendar",calendarId="ProjectZomboid.Gregorian",year=context.gameTime.year,
        month=context.gameTime.month+1,dayOfMonth=context.gameTime.day+1,dayOfYear=365,yearLengthDays=365,
        worldAgeHours=context.gameTime.age,regionId=context.regionId,hemisphere=context.hemisphere}
end}
farmWorks={}
local Probe=dofile(arg[1])
local ok,value=Probe.begin(player,"pz.default-map","north");assert(ok and value.month==12)
assert(not Probe.verify(player,true)and Probe.verify(player,false))
raw.year=1994;raw.month=0;raw.day=0;raw.age=101
Probe.SESSION_TOKEN="reloaded"
ok,value=Probe.verify(player,true);assert(ok and value.year==1994 and memory[Probe.ROOT_KEY].status=="verified")
assert(not Probe.begin(player,"","north"))
weatherWorks.observeCalendar=function()return{providerId="x",calendarId="x",year=1994,month=2,dayOfMonth=1,dayOfYear=1,yearLengthDays=365,regionId="pz.default-map",hemisphere="north"}end
assert(not Probe.begin(player,"pz.default-map","north"))
print("B47ANCEDHarvest native calendar probe checks passed")
