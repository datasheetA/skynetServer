--import module

local global = require "global"
local skynet = require "skynet"

Cmds = {}

Cmds.scene = import(service_path("luacmd.scene"))

function Invoke(sModule, sCmd, mRecord, mData)
    local m = Cmds[sModule]
    if m then
        local f = m[sCmd]
        if f then
            return f(mRecord, mData)
        end
    end
end
