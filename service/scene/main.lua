local global = require "global"
local skynet = require "skynet"
local net = require "base.net"
local interactive = require "base.interactive"

require "skynet.manager"

local luacmd = import(service_path("luacmd.init"))
local scenemgrobj = import(service_path("scenemgrobj"))

skynet.start(function()
    interactive.Init(luacmd)
    net.Init()

    global.oSceneMgr = scenemgrobj.NewSceneMgr()

    print("scene service booted")
end)
