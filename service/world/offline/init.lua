local skynet = require "skynet"

local roctrl = import(service_path("offline.roctrl"))
local rwctrl = import(service_path("offline.rwctrl"))

function NewROCtrl(...)
    return roctrl.CROCtrl:New(...)
end

function NewRWCtrl(...)
    return rwctrl.CRWCtrl:New(...)
end