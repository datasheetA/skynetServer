local global = require "global"
local skynet = require "skynet"
local net = require "base.net"
local interactive = require "base.interactive"

require "skynet.manager"

local logiccmd = import(service_path("logiccmd.init"))
local warmgrobj = import(service_path("warmgrobj"))
local actionmgrobj = import(service_path("actionmgrobj"))

skynet.start(function()
    interactive.Init(logiccmd)
    net.Init()

    global.oWarMgr = warmgrobj.NewWarMgr()
    global.oActionMgr = actionmgrobj.NewActionMgr()

    print("war service booted")
end)
