
local global = require "global"
local skynet = require "skynet"
local interactive = require "base.interactive"
local net = require "base.net"

local gamedefines = import(lualib_path("public.gamedefines"))
local CWarrior = import(service_path("warrior")).CWarrior

function NewPlayerWarrior(...)
    return CPlayerWarrior:New(...)
end

StatusHelperFunc = {}
StatusHelperDef = {}

StatusHelperDef.hp = 2
function StatusHelperFunc.hp(o)
    return o:GetHp()
end

StatusHelperDef.mp = 3
function StatusHelperFunc.mp(o)
    return o:GetMp()
end

StatusHelperDef.max_hp = 4
function StatusHelperFunc.max_hp(o)
    return o:GetMaxHp()
end

StatusHelperDef.max_mp = 5
function StatusHelperFunc.max_mp(o)
    return o:GetMaxMp()
end

StatusHelperDef.model_info = 6
function StatusHelperFunc.model_info(o)
    return o:GetModelInfo()
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

    self:Send("GS2CWarAddWarrior", {
        war_id = self:GetWarId(),
        camp_id = self:GetCampId(),
        type = self:Type(),
        warrior = self:GetSimpleWarriorInfo(),
    })

    local mWarriorMap = oWar:GetWarriorMap()
    for k, _ in pairs(mWarriorMap) do
        local o = self:GetWarrior(k)
        if o and o:GetWid() ~= self:GetWid() then
            self:Send("GS2CWarAddWarrior", {
                war_id = o:GetWarId(),
                camp_id = o:GetCampId(),
                type = o:Type(),
                warrior = o:GetSimpleWarriorInfo(),
            })
        end
    end
    
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
end

function CPlayerWarrior:GetSimpleWarriorInfo()
    return {
        wid = self:GetWid(),
        pid = self:GetPid(),
        pos = self:GetPos(),
        status = self:GetSimpleStatus(),
    }
end

function CPlayerWarrior:GetSimpleStatus(m)
    local mRet = {}
    if not m then
        m = StatusHelperDef
    end
    local iMask = 0
    for k, _ in pairs(m) do
        local i = assert(StatusHelperDef[k], string.format("GetSimpleStatus fail i get %s", k))
        local f = assert(StatusHelperFunc[k], string.format("GetSimpleStatus fail f get %s", k))
        mRet[k] = f(self)
        iMask = iMask | (2^(i-1))
    end
    mRet.mask = iMask
    return mRet
end

function CPlayerWarrior:StatusChange(...)
    local l = table.pack(...)
    local m = {}
    for _, v in ipairs(l) do
        m[v] = true
    end
    local mStatus = self:GetSimpleStatus(m)
    self:SendAll("GS2CWarWarriorStatus", {
        war_id = self:GetWarId(),
        wid = self:GetWid(),
        type = self:Type(),
        player_status = mStatus,
    })
end
