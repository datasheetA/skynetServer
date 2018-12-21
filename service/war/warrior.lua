--import module

local global = require "global"
local skynet = require "skynet"
local interactive = require "base.interactive"
local net = require "base.net"

local status = import(lualib_path("base.status"))
local gamedefines = import(lualib_path("public.gamedefines"))

CWarrior = {}
CWarrior.__index = CWarrior
inherit(CWarrior, logic_base_cls())

function CWarrior:New(iWid)
    local o = super(CWarrior).New(self)
    o.m_iType = gamedefines.WAR_WARRIOR_TYPE.WARRIOR_TYPE
    o.m_iWid = iWid
    o.m_iWarId = nil
    o.m_iCamp = nil
    o.m_iPos = nil

    o.m_bIsDefense = false
    o.m_iProtectVictim = nil
    o.m_iProtectGuard = nil

    o.m_oStatus = status.NewStatus()
    o.m_oStatus:Set(gamedefines.WAR_WARRIOR_STATUS.ALIVE)

    return o
end

function CWarrior:Type()
    return self.m_iType
end

function CWarrior:Init(mInit)
    self.m_iWarId = mInit.war_id
    self.m_iCamp = mInit.camp_id
    self.m_mData = mInit.data
end

function CWarrior:IsDead()
    return self.m_oStatus:Get() == gamedefines.WAR_WARRIOR_STATUS.DEAD
end

function CWarrior:IsAlive()
    return self.m_oStatus:Get() == gamedefines.WAR_WARRIOR_STATUS.ALIVE
end

function CWarrior:GetWid()
    return self.m_iWid
end

function CWarrior:GetWarId()
    return self.m_iWarId
end

function CWarrior:GetCampId()
    return self.m_iCamp
end

function CWarrior:SetPos(id)
    self.m_iPos = id
end

function CWarrior:GetPos()
    return self.m_iPos
end

function CWarrior:GetData(k, rDefault)
    return self.m_mData[k] or rDefault
end

function CWarrior:SetData(k, v)
    self.m_mData[k] = v
end

function CWarrior:StatusChange(...)
end

function CWarrior:GetMaxHp()
    return self:GetData("max_hp")
end

function CWarrior:GetModelInfo()
    return self:GetData("model_info")
end

function CWarrior:GetMaxMp()
    return self:GetData("max_mp")
end

function CWarrior:GetHp()
    return self:GetData("hp")
end

function CWarrior:GetMp()
    return self:GetData("mp")
end

function CWarrior:SubHp(i)
    self:SetData("hp", self:GetHp("hp") - i)
    self:SetData("hp", math.max(0, math.min(self:GetMaxHp(), self:GetData("hp"))))

    if self:IsAlive() and self:GetData("hp") <= 0 then
        self.m_oStatus:Set(gamedefines.WAR_WARRIOR_STATUS.DEAD)
    end

    self:StatusChange("hp")
end

function CWarrior:AddHp(i)
    self:SetData("hp", self:GetData("hp") + i)
    self:SetData("hp", math.max(0, math.min(self:GetMaxHp(), self:GetData("hp"))))

    if self:IsDead() and self:GetData("hp") > 0 then
        self.m_oStatus:Set(gamedefines.WAR_WARRIOR_STATUS.ALIVE)
    end

    self:SendAll("GS2CWarWarriorStatus", {
        war_id = self:GetWarId(),
        wid = self:GetWid(),
        type = self:Type(),
        status = self:GetSimpleStatus(),
    })

    self:StatusChange("hp")
end

function CWarrior:GetSimpleWarriorInfo()
end

function CWarrior:GetSimpleStatus()
end

function CWarrior:GetWar()
    local oWarMgr = global.oWarMgr
    return oWarMgr:GetWar(self:GetWarId())
end

function CWarrior:GetWarrior(iWid)
    local oWar = self:GetWar()
    return oWar:GetWarrior(iWid)
end

function CWarrior:GetPos()
    return self.m_iPos
end

function CWarrior:GetSpeed()
    return 1
end

function CWarrior:SetDefense(bFlag)
    self.m_bIsDefense = bFlag
end

function CWarrior:IsDefense()
    return self.m_bIsDefense
end

function CWarrior:SetProtect(iVictim)
    if not iVictim then
        if self.m_iProtectVictim then
            local oVictim = self:GetWarrior(self.m_iProtectVictim)
            if oVictim then
                oVictim:SetGuard()
            end
            self.m_iProtectVictim = nil
        end
    else
        local oVictim = self:GetWarrior(iVictim)
        if oVictim then
            self.m_iProtectVictim = iVictim
            oVictim:SetGuard(self:GetWid())
        end
    end
end

function CWarrior:SetGuard(iGuard)
    self.m_iProtectGuard = iGuard
end

function CWarrior:GetProtect()
    local id = self.m_iProtectVictim
    if not id then
        return
    end
    return self:GetWarrior(id)
end

function CWarrior:GetGuard()
    local id = self.m_iProtectGuard
    if not id then
        return
    end
    return self:GetWarrior(id)
end

function CWarrior:OnBoutStart()
    self:SetDefense(false)
    self:SetProtect()
    self:SetGuard()
end

function CWarrior:OnBoutEnd()
end

function CWarrior:Send(sMessage, mData)
end

function CWarrior:SendRaw(sData)
end

function CWarrior:SendAll(sMessage, mData, mExclude)
    local oWar = self:GetWar()
    oWar:SendAll(sMessage, mData, mExclude)
end
