--import module

local global = require "global"
local skynet = require "skynet"

local gamedefines = import(lualib_path("public.gamedefines"))

function NewCamp(...)
    local o = CCamp:New(...)
    return o
end

CCamp = {}
CCamp.__index = CCamp
inherit(CCamp, logic_base_cls())

function CCamp:New(id)
    local o = super(CCamp).New(self)
    o.m_iCampId = id
    o.m_mWarriors = {}
    o.m_mPos2Wid = {}
    o.m_iMaxPos = 0
    return o
end

function CCamp:Release()
    for _, v in pairs(self.m_mWarriors) do
        v:Release()
    end
    self.m_mWarriors = {}
    super(CCamp).Release(self)
end

function CCamp:Init(mInit)
end

function CCamp:GetCampId()
    return self.m_iCampId
end

function CCamp:GetWarrior(id)
    return self.m_mWarriors[id]
end

function CCamp:GetAliveCount()
    local i = 0
    for k, v in pairs(self.m_mWarriors) do
        if v:IsAlive() then
            i = i + 1
        end
    end
    return i
end

function CCamp:GetWarriorByPos(iPos)
    local id = self.m_mPos2Wid[iPos]
    if id then
        return self:GetWarrior(id)
    end
end

function CCamp:DispatchPos(iWid, iPos)
    local iTarget
    if not iPos then
        local iMax = self.m_iMaxPos + 1
        for i = 1, iMax do
            if not self.m_mPos2Wid[i] then
                iTarget = i
                break
            end
        end
    else
        assert(not self.m_mPos2Wid[iPos], string.format("CCamp DispatchPos fail %d %d", iWid, iPos))
        iTarget = iPos
    end
    if iTarget > self.m_iMaxPos then
        self.m_iMaxPos = iTarget
    end
    self.m_mPos2Wid[iTarget] = iWid
    return iTarget
end

function CCamp:Enter(obj)
    local iTargetPos = self:DispatchPos(obj:GetWid())
    obj:SetPos(iTargetPos)
    self.m_mWarriors[obj:GetWid()] = obj
end

function CCamp:Leave(obj)
    self.m_mPos2Wid[obj:GetPos()] = nil
    self.m_mWarriors[obj:GetWid()] = nil
end

function CCamp:WarriorCount()
    return table_count(self.m_mWarriors)
end

function CCamp:OnBoutStart()
    for k, v in pairs(self.m_mWarriors) do
        v:OnBoutStart()
    end
end

function CCamp:OnBoutEnd()
    for k, v in pairs(self.m_mWarriors) do
        v:OnBoutEnd()
    end
end
