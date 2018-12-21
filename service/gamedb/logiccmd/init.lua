--import module

local global = require "global"
local skynet = require "skynet"

Cmds = {}

Cmds.playerdb = import(service_path("logiccmd.playerdb"))
Cmds.offlinedb = import(service_path("logiccmd.offlinedb"))

function Invoke(sModule, sCmd, mRecord, mData)
    local m = Cmds[sModule]
    if m then
        local f = m[sCmd]
        if f then
            return f(mRecord, mData)
        end
    end
end
