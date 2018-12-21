local global = require "global"
local skynet = require "skynet"
local net = require "base.net"
local interactive = require "base.interactive"

require "skynet.manager"

local logiccmd = import(service_path("logiccmd.init"))
local scenemgrobj = import(service_path("scenemgrobj"))

skynet.start(function()
    interactive.Init(logiccmd)
    net.Init()

    global.oSceneMgr = scenemgrobj.NewSceneMgr()

    print("scene service booted")
end)
