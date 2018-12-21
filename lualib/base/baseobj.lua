--import module

local servicetime = require "base.servicetimer"

local basedefines = import(lualib_path("base.basedefines"))

CBaseObject = {}
CBaseObject.__index = CBaseObject

function CBaseObject:New()
    local o = setmetatable({}, self)
    o.m_oTimer = servicetime.NewTimer()
    o.m_bIsRelease = false
    return o
end

function CBaseObject:Release()
    self.m_oTimer:Release()
    self.m_bIsRelease = true
end

function CBaseObject:IsRelease()
    return self.m_bIsRelease
end

function CBaseObject:AddTimeCb(sKey, iDelay, func)
    self.m_oTimer:AddCallback(sKey, iDelay, func)
end

function CBaseObject:DelTimeCb(sKey)
    self.m_oTimer:DelCallback(sKey)
end
