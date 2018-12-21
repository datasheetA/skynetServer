--import module

local global = require "global"
local skynet = require "skynet"

Cmds = {}

Cmds.login = import(service_path("netcmd.login"))

function Invoke(sModule, sCmd, fd, mData)
    local m = Cmds[sModule]
    if m then
        local f = m[sCmd]
        if f then
            local oGateMgr = global.oGateMgr
            local oConnection = oGateMgr:GetConnection(fd)
            return f(oConnection, mData)
        end
    end
end
