local global = require "global"
local skynet = require "skynet"
local eio = require("base.extend").Io
local sharedata = require "sharedata"
local interactive = require "base.interactive"

require "skynet.manager"

local logiccmd = import(service_path("logiccmd.init"))

skynet.start(function()
    interactive.Init(logiccmd)

    local sResFile = eio.readfile(skynet.getenv("res_file"))
    sharedata.new("res", sResFile)

    skynet.register ".res"

    print("res service booted")
end)
