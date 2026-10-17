farmWorks={};weatherWorks={observeCalendar=function(context)return context.calendar end}
package.loaded["farmWorks/API"]=nil
local Native=require"farmWorks/VanillaSeasonalGuidance"
local crops={Tomato={sowMonth={3,4,5},bestMonth={4},riskMonth={5}},Malformed={sowMonth={0}}}
local function at(month)return{cropDefinitions=crops,calendar={calendarId="ProjectZomboid.Gregorian",providerId="weatherWorks.Build42Calendar",
    year=1993,yearLengthDays=365,dayOfYear=60,month=month,regionId="pz.default-map",hemisphere="north"}}end
local ideal=Native.evaluate("Tomato",at(4));assert(ideal.state=="ideal"and ideal.best and ideal.inSeason and not ideal.risk)
local risk=Native.evaluate("Tomato",at(5));assert(risk.state=="possible"and risk.risk and risk.source==Native.SOURCE_ID)
assert(Native.evaluate("Tomato",at(8)).state=="poor")
assert(Native.evaluate("Missing",at(4)).state=="unavailable")
assert(Native.evaluate("Malformed",at(4)).state=="unavailable")
local noMonth=at(4);noMonth.calendar.month=nil;assert(Native.evaluate("Tomato",noMonth).state=="unavailable")
local disabled=at(4);disabled.seasonsEnabled=false;assert(Native.evaluate("Tomato",disabled).state=="unavailable")
weatherWorks=nil;assert(Native.evaluate("Tomato",at(4)).state=="unavailable")
print("B47ANCEDHarvest live vanilla seasonal-guidance adapter checks passed")
