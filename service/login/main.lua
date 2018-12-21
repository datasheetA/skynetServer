local global = require "global"
local skynet = require "skynet"
local net = require "base.net"
local interactive = require "base.interactive"
local texthandle = require "base.texthandle"

require "skynet.manager"

local textcmd = import(service_path("textcmd.init"))
local netcmd = import(service_path("netcmd.init"))
local logiccmd = import(service_path("logiccmd.init"))
local gateobj = import(service_path("gateobj"))

skynet.start(function()
    net.Init(netcmd)
    interactive.Init(logiccmd)
    texthandle.Init(textcmd)

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
