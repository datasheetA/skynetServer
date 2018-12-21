--import module

local global = require "global"
local skynet = require "skynet"
local net = require "base.net"
local interactive = require "base.interactive"

local status = import(lualib_path("base.status"))
local gamedefines = import(lualib_path("public.gamedefines"))
local playerwarrior = import(service_path("playerwarrior"))
local campobj = import(service_path("campobj"))

function NewWar(...)
    local o = CWar:New(...)
    return o
end

CWar = {}
CWar.__index = CWar
inherit(CWar, logic_base_cls())

function CWar:New(id)
    local o = super(CWar).New(self)
    o.m_iWarId = id

    o.m_lCamps = {campobj.NewCamp(1), campobj.NewCamp(2), campobj.NewCamp(3)}
    o.m_mWarriors = {}
    o.m_mPlayers = {}
    o.m_mWatcher = {}

    o.m_iWarResult = nil
    o.m_iBout = 0
    o.m_oBoutStatus = status.NewStatus()
    o.m_oBoutStatus:Set(gamedefines.WAR_BOUT_STATUS.NULL)
    o.m_mBoutCmds = {}
    o:ResetOperateTime()
    o:ResetAnimationTime()

    return o
end

function CWar:Release()
    for _, v in ipairs(self.m_lCamps) do
        v:Release()
    end
    self.m_lCamps = {}
    super(CWar).Release(self)
end

function CWar:Init(mInit)
end

function CWar:GetWarId()
    return self.m_iWarId
end

function CWar:GetWatcherMap()
    return self.m_mWatcher
end

function CWar:AddWatcher(oWatcher)
    self.m_mWatcher[oWatcher:GetWid()] = true
end

function CWar:DelWatcher(oWatcher)
    self.m_mWatcher[oWatcher:GetWid()] = nil
end

function CWar:WarriorCount()
    return table_count(self.m_mWarriors)
end

function CWar:GetWarriorMap()
    return self.m_mWarriors
end

function CWar:BoutCmdLen()
    return table_count(self.m_mBoutCmds)
end

function CWar:CheckBoutCmdEnough()
    if self:BoutCmdLen() >= self:WarriorCount() and self.m_oBoutStatus:Get() == gamedefines.WAR_BOUT_STATUS.OPERATE then
        self:BoutProcess()
    end
end

function CWar:AddBoutCmd(iWid, mCmd)
    if self.m_oBoutStatus:Get() == gamedefines.WAR_BOUT_STATUS.OPERATE then
        self.m_mBoutCmds[iWid] = mCmd
        self:CheckBoutCmdEnough()
    end
end

function CWar:DelBoutCmd(iWid)
    self.m_mBoutCmds[iWid] = nil
end

function CWar:GetWarrior(id)
    local iCamp = self.m_mWarriors[id]
    if iCamp then
        return self.m_lCamps[iCamp]:GetWarrior(id)
    end
end

function CWar:GetPlayerWarrior(iPid)
    local id = self.m_mPlayers[iPid]
    return self:GetWarrior(id)
end

--lxldebug
function CWar:ChooseRandomEnemy(obj)
    local iCamp = obj:GetCampId()
    local iCnt = math.random(1, 5)
    local l = {}
    for k, _ in pairs(self.m_mWarriors) do
        local o = self:GetWarrior(k)
        if o and o:GetCampId() ~= iCamp then
            table.insert(l, o)
            iCnt = iCnt - 1
            if iCnt <= 0 then
                break
            end
        end
    end
    return l
end

function CWar:Enter(obj, iCamp)
    self.m_lCamps[iCamp]:Enter(obj)
    self.m_mWarriors[obj:GetWid()] = iCamp
    return obj
end

function CWar:Leave(obj)
    self.m_lCamps[obj:GetCampId()]:Leave(obj)
    self.m_mWarriors[obj:GetWid()] = nil
    obj:Release()
end

function CWar:EnterPlayer(iPid, iWid, iCamp, mMail)
    assert(not self.m_mPlayers[iPid], string.format("EnterPlayer error %d %d", iPid, iWid))
    local obj = playerwarrior.NewPlayerWarrior(iWid, iPid, mMail)
    self.m_mPlayers[iPid] = iWid
    obj:Init({
        camp_id = iCamp,
        war_id = self:GetWarId(),
        hp = 100,
        mp = 100,
        max_hp = 100,
        max_mp = 100,
    })
    self:Enter(obj, iCamp)
    self:AddWatcher(obj)

    self:SendAll("GS2CWarAddWarrior", {
        war_id = obj:GetWarId(),
        camp_id = obj:GetCampId(),
        type = obj:Type(),
        warrior = obj:GetSimpleWarriorInfo(),
    })

    local mWarriorMap = self:GetWarriorMap()
    for k, _ in pairs(mWarriorMap) do
        if k ~= obj:GetWid() then
            local o = self:GetWarrior(k)
            if o then
                obj:Send("GS2CWarAddWarrior", {
                    war_id = o:GetWarId(),
                    camp_id = o:GetCampId(),
                    type = o:Type(),
                    warrior = o:GetSimpleWarriorInfo(),
                })
            end
        end
    end

    return obj
end

function CWar:LeavePlayer(iPid)
    local obj = self:GetPlayerWarrior(iPid)
    if obj then
        local iWid = obj:GetWid()
        self:SendAll("GS2CWarDelWarrior", {
            war_id = obj:GetWarId(),
            wid = obj:GetWid(),
        })
        if obj then
            obj:Send("GS2CWarResult", {
                war_id = self:GetWarId(),
                bout_id = self.m_iBout,
            })

            self:Leave(obj)
            self.m_mPlayers[iPid] = nil
            self:DelWatcher(obj)
            interactive.Send(".world", "war", "RemoteEvent", {event = "remote_leave_player", data = {
                pid = iPid,
            }})
        end
    end
end

function CWar:ReEnterPlayer(iPid, mMail)
    local oWarrior = self:GetPlayerWarrior(iPid)
    assert(oWarrior, string.format("ReEnterPlayer error %d", iPid))
    oWarrior:ReEnter(mMail)
end

function CWar:AddOperateTime(iTime)
    self.m_iOperateWaitTime = self.m_iOperateWaitTime + iTime
end

function CWar:GetOperateTime()
    return self.m_iOperateWaitTime
end

function CWar:BaseOperateTime()
    return 1000
end

function CWar:ResetOperateTime()
    self.m_iOperateWaitTime = 0
end

function CWar:GetAnimationTime()
    return self.m_iAnimationWaitTime
end

function CWar:BaseAnimationTime()
    return 1000
end

function CWar:AddAnimationTime(iTime)
    self.m_iAnimationWaitTime = self.m_iAnimationWaitTime + iTime
end

function CWar:ResetAnimationTime()
    self.m_iAnimationWaitTime = 0
end

function CWar:WarPrepare(mInfo)
end

function CWar:WarStart(mInfo)
    self:BoutStart()
end

function CWar:WarEnd()
    self:DelTimeCb("BoutStart")
    self:DelTimeCb("BoutProcess")
    self.m_iWarResult = 0

    local l = table_key_list(self.m_mPlayers)
    for _, iPid in ipairs(l) do
        self:LeavePlayer(iPid)
    end

    interactive.Send(".world", "war", "RemoteEvent", {event = "remote_war_end", data = {
        war_id = self:GetWarId(),
    }})
end

function CWar:BoutStart()
    self:DelTimeCb("BoutStart")
    self:DelTimeCb("BoutProcess")

    self.m_iBout = self.m_iBout + 1
    self:ResetAnimationTime()
    self:ResetOperateTime()
    self.m_mBoutCmds = {}
    self.m_oBoutStatus:Set(gamedefines.WAR_BOUT_STATUS.OPERATE)

    self:AddOperateTime(30*1000)
    self:SendAll("GS2CWarBoutStart", {
        war_id = self:GetWarId(),
        bout_id = self.m_iBout,
        left_time = math.floor(self:GetOperateTime()/1000),
    })

    safe_call(self.OnBoutStart, self)

    self:AddTimeCb("BoutProcess", self:GetOperateTime() + self:BaseOperateTime(), function ()
        self:BoutProcess()
    end)
end

function CWar:BoutExecute()
    local oActionMgr = global.oActionMgr
    local lExecute = {}

    for k, v in pairs(self.m_mBoutCmds) do
        local oAction = self:GetWarrior(k)
        if oAction then
            local sCmd = v.cmd
            local mData = v.data
            if sCmd == "defense" then
                oAction:SetDefense(true)
            elseif sCmd == "protect" then
                oAction:SetProtect(mData.select_wid)
            else
                table.insert(lExecute, {k, v})
            end
        end
    end

    table.sort(lExecute, function (a, b)
        local iWid1 = a[1]
        local iWid2 = b[1]
        local o1 = self:GetWarrior(iWid1)
        local o2 = self:GetWarrior(iWid2)
        return o1:GetSpeed() > o2:GetSpeed()
    end)

    for _, m in ipairs(lExecute) do
        local k = m[1]
        local v = m[2]
        local sCmd = v.cmd
        local mData = v.data
        local oAction = self:GetWarrior(k)
        if oAction then
            if sCmd == "skill" then
                local lSelect = mData.select_wlist
                local iSkill = mData.skill_id
                local l = {}
                for _, i in ipairs(lSelect) do
                    local o = self:GetWarrior(i)
                    if o then
                        table.insert(l, o)
                    end
                end
                oActionMgr:WarSkill(oAction, l, iSkill)
            elseif sCmd == "normal_attack" then
                local iSelectWid = mData.select_wid
                local oSelect = self:GetWarrior(iSelectWid)
                if oSelect then
                    oActionMgr:WarNormalAttack(oAction, oSelect)
                end
            elseif sCmd == "escape" then
                oActionMgr:WarEscape(oAction)
            end
        end
    end
end

function CWar:BoutProcess()
    self:DelTimeCb("BoutStart")
    self:DelTimeCb("BoutProcess")
    self.m_oBoutStatus:Set(gamedefines.WAR_BOUT_STATUS.ANIMATION)

    safe_call(self.BoutExecute, self)

    self:SendAll("GS2CWarBoutEnd", {
        war_id = self:GetWarId(),
    })

    safe_call(self.OnBoutEnd, self)

    local iAliveCount1 = self.m_lCamps[1]:GetAliveCount()
    local iAliveCount2 = self.m_lCamps[2]:GetAliveCount()
    if iAliveCount1 <= 0 then
        self:WarEnd()
    elseif iAliveCount2 <= 0 then
        self:WarEnd()
    else
        self:AddTimeCb("BoutStart", self:GetAnimationTime() + self:BaseAnimationTime(), function ()
            self:BoutStart()
        end)
    end
end

function CWar:OnBoutStart()
    for _, v in ipairs(self.m_lCamps) do
        v:OnBoutStart()
    end
end

function CWar:OnBoutEnd()
    for _, v in ipairs(self.m_lCamps) do
        v:OnBoutEnd()
    end
end

function CWar:SendAll(sMessage, mData, mExclude)
    local sData = net.PackData(sMessage, mData)
    mExclude = mExclude or {}

    for k, _ in pairs(self.m_mWatcher) do
        if not mExclude[k] then
            local o = self:GetWarrior(k)
            if o then
                o:SendRaw(sData)
            end
        end
    end
end
