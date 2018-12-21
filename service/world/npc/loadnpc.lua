local global = require "global"

local NpcDir = {
    ["func"] = {5001,5200},
    ["idle"] = {5201,5400},
}

function GetDir(npcid)
    for sDir,mNpc in pairs(NpcDir) do
        local iStart,iEnd = table.unpack(mNpc)
        if iStart <= npcid and npcid <= iEnd then
            return sDir
        end
    end
end

function NewNpc(npctype)
    local sDir = GetDir(npctype)
    local sPath = string.format("npc/%s/n%d",sDir,npctype)
    local oModule = import(service_path(sPath))
    assert(oModule,string.format("Load Npc Module:%d",npctype))
    return oModule.NewNpc(npctype)
end