--import module

local global = require "global"
local skynet = require "skynet"

Cmds = {}

Cmds.playerdb = import(service_path("logiccmd.playerdb"))

function Invoke(sModule, sCmd, mRecord, mData)
    local m = Cmds[sModule]
    if m then
        local f = m[sCmd]
        if f then
            return f(mRecord, mData)
        end
    end
end
