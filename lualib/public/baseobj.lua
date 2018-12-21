--import module

local servicetime = require "base.servicetimer"

local gamedefines = import(lualib_path("public.gamedefines"))
local status = import(lualib_path("public.status"))

CBaseObject = {}
CBaseObject.__index = CBaseObject

function CBaseObject:New()
    local o = setmetatable({}, self)
    o.m_oTimer = servicetime.NewTimer()
    o.m_oStatus = status.NewStatus()
    o.m_oStatus:Set(gamedefines.BASEOBJ_STATUS.is_alive)
    return o
end

function CBaseObject:Release()
    self.m_oTimer:Release()
    self.m_oStatus:Set(gamedefines.BASEOBJ_STATUS.is_release)
end

function CBaseObject:IsRelease()
    local iStatus = self.m_oStatus:Get()
    return (iStatus == gamedefines.BASEOBJ_STATUS.is_release)
end

function CBaseObject:AddTimeCb(sKey, iDelay, func)
    self.m_oTimer:AddCallback(sKey, iDelay, func)
end

function CBaseObject:DelTimeCb(sKey)
    self.m_oTimer:DelCallback(sKey)
end
