--import module

local global = require "global"
local skynet = require "skynet"

Cmds = {}

Cmds.login = import(service_path("logiccmd.login"))

function Invoke(sModule, sCmd, mRecord, mData)
    local m = Cmds[sModule]
    if m then
        local f = m[sCmd]
        if f then
            return f(mRecord, mData)
        end
    end
    print(string.format("Invoke fail %s %s %s %s", MY_SERVICE_NAME, MY_ADDR, sModule, sCmd))
end
