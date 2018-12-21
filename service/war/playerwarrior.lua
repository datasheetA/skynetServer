
local global = require "global"
local skynet = require "skynet"
local interactive = require "base.interactive"
local net = require "base.net"

local gamedefines = import(lualib_path("public.gamedefines"))
local CWarrior = import(service_path("warrior")).CWarrior

function NewPlayerWarrior(...)
    return CPlayerWarrior:New(...)
end

CPlayerWarrior = {}
CPlayerWarrior.__index = CPlayerWarrior
inherit(CPlayerWarrior, CWarrior)

function CPlayerWarrior:New(iWid, iPid, mMail)
    local o = super(CPlayerWarrior).New(self, iWid)
    o.m_iType = gamedefines.WAR_WARRIOR_TYPE.PLAYER_TYPE
    o.m_iPid = iPid
    o.m_mMail = mMail
    return o
end

function CPlayerWarrior:GetPid()
    return self.m_iPid
end

function CPlayerWarrior:Send(sMessage, mData)
    if self.m_mMail then
        net.Send(self.m_mMail, sMessage, mData)
    end
end

function CPlayerWarrior:Disconnected()
    self.m_mMail = nil
end

function CPlayerWarrior:SendRaw(sData)
    if self.m_mMail then
        net.SendRaw(self.m_mMail, sData)
    end
end

function CPlayerWarrior:ReEnter(mMail)
    self.m_mMail = mMail

    local oWar = self:GetWar()
    local iStatus, iStatusTime = oWar.m_oBoutStatus:Get()
    if iStatus == gamedefines.WAR_BOUT_STATUS.OPERATE then
        self:Send("GS2CWarBoutStart", {
            war_id = oWar:GetWarId(),
            bout_id = oWar.m_iBout,
            left_time = math.max(0, math.floor((iStatusTime + oWar:GetOperateTime() - get_msecond())/1000)),
        })
    elseif iStatus == gamedefines.WAR_BOUT_STATUS.ANIMATION then
        self:Send("GS2CWarBoutEnd", {
            war_id = oWar:GetWarId(),
        })
    end

    local mWarriorMap = oWar:GetWarriorMap()
    for k, _ in pairs(mWarriorMap) do
        local o = self:GetWarrior(k)
        if o then
            self:Send("GS2CWarAddWarrior", {
                war_id = o:GetWarId(),
                camp_id = o:GetCampId(),
                type = o:Type(),
                warrior = o:GetSimpleWarriorInfo(),
            })
        end
    end
end

function CPlayerWarrior:GetSimpleWarriorInfo()
    return {
        wid = self:GetWid(),
        pid = self:GetPid(),
        pos = self:GetPos(),
        status = self:GetSimpleStatus(),
    }
end

function CPlayerWarrior:GetSimpleStatus()
    return {
        hp = self:GetHp(),
        mp = self:GetMp(),
        max_hp = self:GetMaxHp(),
        max_mp = self:GetMaxMp(),
    }
end
