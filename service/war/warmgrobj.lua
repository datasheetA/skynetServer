--import module

local global = require "global"
local skynet = require "skynet"
local interactive = require "base.interactive"

local warobj = import(service_path("warobj"))

function NewWarMgr(...)
    local o = CWarMgr:New(...)
    return o
end

CWarMgr = {}
CWarMgr.__index = CWarMgr
inherit(CWarMgr, logic_base_cls())

function CWarMgr:New()
    local o = super(CWarMgr).New(self)
    o.m_mWars = {}
    return o
end

function CWarMgr:Release()
    for _, v in pairs(self.m_mWars) do
        v:Release()
    end
    self.m_mWars = {}
    super(CWarMgr).Release(self)
end

function CWarMgr:ConfirmRemote(iWarId)
    assert(not self.m_mWars[iWarId], string.format("ConfirmRemote error %d", iWarId))
    local oWar = warobj.NewWar(iWarId)
    oWar:Init()
    self.m_mWars[iWarId] = oWar
end

function CWarMgr:GetWar(iWarId)
    return self.m_mWars[iWarId]
end

function CWarMgr:RemoveWar(iWarId)
    local oWar = self.m_mWars[iWarId]
    if oWar then
        self.m_mWars[iWarId] = nil
        oWar:Release()
    end
end
