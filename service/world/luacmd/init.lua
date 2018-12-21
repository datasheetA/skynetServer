--import module

local global = require "global"
local skynet = require "skynet"

Cmds = {}

Cmds.login = import(service_path("luacmd.login"))

function Invoke(sModule, sCmd, mRecord, mData)
    local m = Cmds[sModule]
    if m then
        local f = m[sCmd]
        if f then
            return f(mRecord, mData)
        end
    end
end
