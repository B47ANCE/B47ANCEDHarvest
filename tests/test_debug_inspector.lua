local apiPath,inspectorPath=arg[1],arg[2]
local function square(x,y,z)return{getX=function()return x end,getY=function()return y end,getZ=function()return z end}end
local origin=square(10,20,0);local player={getSquare=function()return origin end}
getSpecificPlayer=function()return player end
local crops={}
local cropA={typeOfSeed="Tomato",waterLvl=40,waterNeeded=70,health=80,x=9,y=20,z=0,isAlive=function()return true end,canHarvest=function()return false end}
local cropB={typeOfSeed="Cabbages",waterLvl=80,waterNeeded=70,health=90,x=11,y=20,z=0,isAlive=function()return true end,canHarvest=function()return true end}
crops["9:20:0"]=cropA;crops["11:20:0"]=cropB
local cell={getGridSquare=function(_,x,y,z)return square(x,y,z)end};getCell=function()return cell end
CFarmingSystem={instance={getLuaObjectOnSquare=function(_,value)return crops[value:getX()..":"..value:getY()..":"..value:getZ()]end}}
farmWorks=dofile(apiPath)
local inspector=dofile(inspectorPath)
local result=assert(inspector.collect(player,1))
assert(result.radius==1 and result.visitedSquares==9,"radius-one scan must stay bounded to nine same-level squares")
assert(result.summary.count==2 and result.summary.harvestReady==1,"nearby crops must use canonical field inspection")
assert(result.irrigation.count==1 and result.irrigation.totalAmount==30,"debugger must report pure irrigation demand")
local line=assert(inspector.format(result))
assert(line:find("crops=2",1,true)and line:find("Tomato=1",1,true)and line:find("Cabbages=1",1,true))
local capped=assert(inspector.collect(player,999))
assert(capped.radius==10 and capped.visitedSquares==441,"debug scan must enforce its hard radius ceiling")
CFarmingSystem=nil
local missing,reason=inspector.collect(player,1)
assert(not missing and reason=="vanilla farming system unavailable","missing vanilla state must fail safely")
print("B47ANCEDHarvest bounded nearby-crop debug inspector checks passed")
