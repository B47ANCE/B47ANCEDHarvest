farmWorks={};local Guidance=dofile(arg[1])
Guidance.register{cropId="fixture.WinterCrop",calendarId="fixture.400day",yearLengthDays=400,regionId="region:a",hemisphere="custom",
    windows={{startDay=380,endDay=20,grade="ideal"},{startDay=350,endDay=40,grade="possible"}}}
local function calendar(day)return{calendarId="fixture.400day",yearLengthDays=400,dayOfYear=day,regionId="region:a",hemisphere="custom"}end
assert(Guidance.evaluate("fixture.WinterCrop",calendar(390)).state=="ideal")
assert(Guidance.evaluate("fixture.WinterCrop",calendar(30)).state=="possible")
assert(Guidance.evaluate("fixture.WinterCrop",calendar(200)).state=="poor")
assert(Guidance.evaluate("fixture.Unknown",calendar(1)).state=="unavailable")
local wrong=calendar(1);wrong.hemisphere="north";assert(Guidance.evaluate("fixture.WinterCrop",wrong).state=="unavailable")
wrong=calendar(1);wrong.yearLengthDays=365;assert(Guidance.evaluate("fixture.WinterCrop",wrong).state=="unavailable")
print("B47ANCEDHarvest deterministic seasonal planting-guidance checks passed")
