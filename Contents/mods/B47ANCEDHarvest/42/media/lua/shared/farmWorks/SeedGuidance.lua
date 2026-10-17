local farmWorks=rawget(_G,"farmWorks")or{}
local Seed={MAX_CROPS=256,MAX_CONTEXT_PROVIDERS=16};local contexts={};local contextCount=0
local function validId(value,maximum)return type(value)=="string"and value~=""and#value<=maximum and not value:find("[%c]")end
local function fullType(item)
    if type(item)=="string"then return validId(item,160)and item or nil end
    local ok,fn=pcall(function()return item and item.getFullType end)
    if ok and type(fn)=="function"then local called,value=pcall(fn,item);return called and validId(value,160)and value or nil end
end
function Seed.registerContextProvider(definition)
    assert(type(definition)=="table"and validId(definition.id,96)and type(definition.getContext)=="function","context provider id/getContext required")
    assert(not contexts[definition.id],"duplicate seasonal context provider")
    contextCount=contextCount+1;assert(contextCount<=Seed.MAX_CONTEXT_PROVIDERS,"seasonal context provider limit reached")
    contexts[definition.id]={id=definition.id,priority=tonumber(definition.priority)or 0,getContext=definition.getContext};return{id=definition.id}
end
function Seed.getContext(character,item)
    local ordered={};for _,provider in pairs(contexts)do ordered[#ordered+1]=provider end
    table.sort(ordered,function(a,b)return a.priority==b.priority and a.id<b.id or a.priority>b.priority end)
    for _,provider in ipairs(ordered)do
        local ok,value=pcall(provider.getContext,character,item)
        if ok and type(value)=="table"and validId(value.regionId,96)and validId(value.hemisphere,32)then
            return{regionId=value.regionId,hemisphere=value.hemisphere,providerId=provider.id}
        end
    end
    return nil,"seasonal context unavailable"
end
function Seed.resolveCrop(item,definitions)
    local itemType=fullType(item);if not itemType then return nil,"invalid seed item"end
    local root=definitions or(rawget(_G,"farming_vegetableconf")and farming_vegetableconf.props)
    if type(root)~="table"then return nil,"vanilla crop definitions unavailable"end
    local matches={};local examined=0
    for cropId,props in pairs(root)do
        examined=examined+1;if examined>Seed.MAX_CROPS then return nil,"crop definition limit reached"end
        if validId(cropId,128)and type(props)=="table"then
            local seedTypes=props.seedTypes or(props.seedName and{props.seedName})or{}
            if type(seedTypes)~="table"then return nil,"malformed seed types"end
            for index=1,math.min(#seedTypes,64)do if seedTypes[index]==itemType then matches[#matches+1]=cropId;break end end
        end
    end
    table.sort(matches)
    if #matches==0 then return nil,"NOT_APPLICABLE"end
    if #matches>1 then return nil,"ambiguous seed crop"end
    return matches[1]
end
function Seed.evaluate(character,item,options)
    options=type(options)=="table"and options or{}
    local cropId,reason=Seed.resolveCrop(item,options.cropDefinitions);if not cropId then return nil,reason end
    local context=options.seasonalContext
    if type(context)~="table"then context,reason=Seed.getContext(character,item);if not context then return nil,reason end end
    if type(farmWorks.getVanillaPlantingGuidance)~="function"then return nil,"seasonal guidance unavailable"end
    local view=farmWorks.getVanillaPlantingGuidance(cropId,{cropDefinitions=options.cropDefinitions,calendarContext=context,seasonsEnabled=options.seasonsEnabled})
    if type(view)~="table"then return nil,"seasonal guidance unavailable"end
    view.seedItemType=fullType(item);view.contextProviderId=context.providerId;return view
end
farmWorks.SeedGuidance=Seed;farmWorks.registerSeasonalContextProvider=Seed.registerContextProvider
farmWorks.resolveSeedCrop=Seed.resolveCrop;farmWorks.getSeedPlantingGuidance=Seed.evaluate;return Seed
