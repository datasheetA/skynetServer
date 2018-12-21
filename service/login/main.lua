local global = require "global"
local skynet = require "skynet"
local net = require "base.net"
local interactive = require "base.interactive"

require "skynet.manager"
require "base.skynet_text"

local textcmd = import(service_path("textcmd.init"))
local netcmd = import(service_path("netcmd.init"))
local luacmd = import(service_path("luacmd.init"))
local gateobj = import(service_path("gateobj"))

skynet.start(function()
    net.Init(netcmd)
    interactive.Init(luacmd)

    skynet.dispatch("text", function (session, address, message)
        local id, cmd , parm = string.match(message, "(%d+) (%w+) ?(.*)")
        id = tonumber(id)
        textcmd.Invoke(cmd, address, id, parm)
    end)

    global.oGateMgr = gateobj.NewGateMgr()
    local  sPorts = skynet.getenv("GATEWAY_PORTS")
    local lPorts = split_string(sPorts, ",", tonumber)
    for _, v in ipairs(lPorts) do
        local oGate = gateobj.NewGate(v)
        global.oGateMgr:AddGate(oGate)
    end

    skynet.register ".login"

    print("login service booted")
end)
