--import module

local global = require "global"
local skynet = require "skynet"

Cmds = {}

Cmds.login = import(service_path("netcmd.login"))
Cmds.scene = import(service_path("netcmd.scene"))
Cmds.other = import(service_path("netcmd.other"))
Cmds.item = import(service_path("netcmd.item"))

function Invoke(sModule, sCmd, fd, mData)
    local m = Cmds[sModule]
    if m then
        local f = m[sCmd]
        if f then
            local oWorldMgr = global.oWorldMgr
            local oPlayer = oWorldMgr:GetOnlinePlayerByFd(fd)
            if oPlayer then
                return f(oPlayer, mData)
            end
        end
    end
end
