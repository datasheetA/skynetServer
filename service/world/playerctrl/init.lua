--import module
local skynet = require "skynet"

local basectrl = import(service_path("playerctrl.basectrl"))
local activectrl = import(service_path("playerctrl.activectrl"))

function NewBaseCtrl(...)
    return basectrl.CPlayerBaseCtrl:New(...)
end

function NewActiveCtrl(...)
    return activectrl.CPlayerActiveCtrl:New(...)
end
