local global = require "global"
local extend = require "base/extend"

local stringop = import(lualib_path("base.stringop"))

local ItemList = {}

local ItemDir = {
    ["virtual"]  = {1001,10000},
    ["other"]   = {10001,11000},
}

function GetItemDir(sid)
    for sDir,mPos in pairs(ItemDir) do
        local iStart,iEnd = table.unpack(mPos)
        if iStart <= sid and sid <= iEnd then
            return sDir
        end
    end
end

function GetItemPath(sid)
    local sDir = GetItemDir(sid)
    local sPath = string.format("item/%s/%sbase",sDir,sDir)
    if extend.Table.find({"other","virtual"},sDir) then
        sPath  = string.format("item/%s/i%d",sDir,sid)
    end
    --用于测试
    if sid >= 10002 and sid <=10010 then
        sPath = "item/other/otherbase"
    end
   return sPath
end

function Create(sid,...)
    local sPath = GetItemPath(sid)
    local oModule = import(service_path(sPath))
    assert(oModule,string.format("loaditem err:%d",sid))
    local oItem = oModule.NewItem(sid)
    oItem:Setup()
    return oItem
end

function ExtCreate(sid,...)
    local sArg
    if tonumber(sid) then
        sid = tonumber(sid)
    else
        sid,sArg = string.match(sid,"(%d+)(.+)")
        sid = tonumber(sid)
    end
    local oItem = Create(sid,...)
    if sArg then
        sArg = string.sub(sArg,2,#sArg-1)
        local mArg = stringop.split_string(sArg,",")
        for _,sArg in ipairs(mArg) do
            local key,value = string.match(sArg,"(.+)=(.+)")
            local sAttr = string.format("m_%s",key)
            if oItem[sAttr] then
                oItem[sAttr] = value
            else
                oItem:SetData(key,value)
            end
        end
    end
    return oItem
end

function GetItem(sid,...)
    local oItem = ItemList[sid]
    if not oItem then
        oItem = Create(sid,...)
        ItemList[sid] = oItem
    end
    return oItem
end

function LoadItem(sid,data)
    local itemobj = Create(sid)
    itemobj:Load(data)
    return itemobj
end