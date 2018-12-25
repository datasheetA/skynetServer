--import module

local global = require "global"
local skynet = require "skynet"

Cmds = {}

Cmds.login = import(service_path("netcmd.login"))
Cmds.scene = import(service_path("netcmd.scene"))
Cmds.other = import(service_path("netcmd.other"))
Cmds.item = import(service_path("netcmd.item"))
Cmds.war = import(service_path("netcmd.war"))
Cmds.player = import(service_path("netcmd.player"))
Cmds.npc = import(service_path("netcmd.npc"))
Cmds.openui = import(service_path("netcmd.openui"))
Cmds.warehouse =import(service_path("netcmd.warehouse"))

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
        else
            print(string.format("Invoke fail %s %s %s %s", MY_SERVICE_NAME, MY_ADDR, sModule, sCmd))
        end
    else
        print(string.format("Invoke fail %s %s %s %s", MY_SERVICE_NAME, MY_ADDR, sModule, sCmd))
    end
end
