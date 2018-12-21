--import module

local global = require "global"
local skynet = require "skynet"
local interactive = require "base.interactive"

local gamedefines = import(lualib_path("public.gamedefines"))

function NewWarMgr(...)
    local o = CWarMgr:New(...)
    return o
end

function NewWar(...)
    local o = CWar:New(...)
    return o
end


CWarMgr = {}
CWarMgr.__index = CWarMgr
inherit(CWarMgr, logic_base_cls())

function CWarMgr:New(lWarRemote)
    local o = super(CWarMgr).New(self)
    o.m_iDispatchId = 0
    o.m_mWars = {}
    o.m_lWarRemote = lWarRemote
    return o
end

function CWarMgr:Release()
    for _, v in pairs(self.m_mWars) do
        v:Release()
    end
    self.m_mWars = {}
    super(CWarMgr).Release(self)
end

function CWarMgr:DispatchSceneId()
    self.m_iDispatchId = self.m_iDispatchId + 1
    return self.m_iDispatchId
end

function CWarMgr:SelectRemoteWar()
    local l = self.m_lWarRemote
    return l[math.random(#l)]
end

function CWarMgr:CreateWar(mInfo)
    local id = self:DispatchSceneId()
    local oWar = NewWar(id, mInfo)
    oWar:ConfirmRemote()
    self.m_mWars[id] = oWar
    return oWar
end

function CWarMgr:GetWar(id)
    return self.m_mWars[id]
end

function CWarMgr:RemoveWar(id)
    local oWar = self.m_mWars[id]
    if oWar then
        oWar:Release()
        self.m_mWars[id] = nil
    end
end

function CWarMgr:OnDisconnected(oPlayer)
    local oNowWar = oPlayer.m_oActiveCtrl:GetNowWar()
    if oNowWar then
        oNowWar:NotifyDisconnected(oPlayer)
    end
end

function CWarMgr:OnLogout(oPlayer)
    self:LeaveWar(oPlayer, true)
end

function CWarMgr:OnLogin(oPlayer, bReEnter)
    if bReEnter then
        self:ReEnterWar(oPlayer)
    end
end

function CWarMgr:ReEnterWar(oPlayer)
    local oNowWar = oPlayer.m_oActiveCtrl:GetNowWar()
    if oNowWar then
        oNowWar:ReEnterPlayer(oPlayer)
    end
    return {errcode = gamedefines.ERRCODE.ok}
end

function CWarMgr:LeaveWar(oPlayer, bForce)
    local oNowWar = oPlayer.m_oActiveCtrl:GetNowWar()
    if not oNowWar then
        return {errcode = gamedefines.ERRCODE.ok}
    end
    if not bForce then
        if not oNowWar:VaildLeave(oPlayer) then
            return {errcode = gamedefines.ERRCODE.common}
        end
    end
    oNowWar:LeavePlayer(oPlayer)
    return {errcode = gamedefines.ERRCODE.ok}
end

function CWarMgr:EnterWar(oPlayer, iWarId, mInfo, bForce)
    local oNewWar = self:GetWar(iWarId)
    assert(oNewWar, string.format("EnterWar error %d", iWarId))
    local oNowWar = oPlayer.m_oActiveCtrl:GetNowWar()

    if not bForce then
        if oNowWar and not oNowWar:VaildLeave(oPlayer) then
            return {errcode = gamedefines.ERRCODE.common}
        end
        if not oNewWar:VaildEnter(oPlayer) then
            return {errcode = gamedefines.ERRCODE.common}
        end
    end

    if oNowWar then
        oNowWar:LeavePlayer(oPlayer)
    end
    oNewWar:EnterPlayer(oPlayer, mInfo)

    return {errcode = gamedefines.ERRCODE.ok}
end

function CWarMgr:PrepareWar(iWarId, mInfo)
    local oWar = self:GetWar(iWarId)
    if oWar then
        oWar:WarPrepare(mInfo)
    end
end

function CWarMgr:StartWar(iWarId, mInfo)
    local oWar = self:GetWar(iWarId)
    if oWar then
        oWar:WarStart(mInfo)
    end
end

function CWarMgr:RemoteEvent(sEvent, mData)
    if sEvent == "remote_leave_player" then
        local iPid = mData.pid
        local oWorldMgr = global.oWorldMgr
        local oPlayer = oWorldMgr:GetOnlinePlayerByPid(iPid)
        if oPlayer then
            local oNowWar = oPlayer.m_oActiveCtrl:GetNowWar()
            if oNowWar then
                oNowWar:RemoteLeavePlayer(oPlayer)
            end
        end
    elseif sEvent == "remote_war_end" then
        local iWarId = mData.war_id
        self:RemoveWar(iWarId)
    end
    return true
end


CWar = {}
CWar.__index = CWar
inherit(CWar, logic_base_cls())

function CWar:New(id, mInfo)
    local o = super(CWar).New(self)
    o.m_iWarId = id
    o.m_iDispatchId = 0
    o.m_iRemoteAddr = nil
    o.m_mPlayers = {}
    o.m_mObservers = {}
    return o
end

function CWar:Release()
    interactive.Send(self.m_iRemoteAddr, "war", "RemoveRemote", {war_id = self.m_iWarId})
    super(CWar).Release(self)
end

function CWar:GetWarId()
    return self.m_iWarId
end

function CWar:DispatchWarriorId()
    self.m_iDispatchId = self.m_iDispatchId + 1
    return self.m_iDispatchId
end

function CWar:ConfirmRemote()
    local oWarMgr = global.oWarMgr
    local iRemoteAddr = oWarMgr:SelectRemoteWar()
    self.m_iRemoteAddr = iRemoteAddr
    interactive.Send(iRemoteAddr, "war", "ConfirmRemote", {war_id = self.m_iWarId})
end

function CWar:VaildLeave(oPlayer)
    return true
end

function CWar:VaildEnter(oPlayer)
    return true
end

function CWar:RemoteLeavePlayer(oPlayer)
    local iPid = oPlayer:GetPid()
    if self.m_mPlayers[iPid] then
        self.m_mPlayers[iPid] = nil
        local oSceneMgr = global.oSceneMgr
        oSceneMgr:OnLeaveWar(oPlayer)
        oSceneMgr:ReEnterScene(oPlayer)
    end
    return true
end

function CWar:LeavePlayer(oPlayer)
    if self.m_mPlayers[oPlayer:GetPid()] then
        self.m_mPlayers[oPlayer:GetPid()] = nil
        interactive.Send(self.m_iRemoteAddr, "war", "LeavePlayer", {war_id = self.m_iWarId, pid = oPlayer:GetPid()})
        local oSceneMgr = global.oSceneMgr
        oSceneMgr:OnLeaveWar(oPlayer)
        oSceneMgr:ReEnterScene(oPlayer)
    end
    return true
end

function CWar:EnterPlayer(oPlayer, mInfo)
    local oSceneMgr = global.oSceneMgr
    oSceneMgr:OnEnterWar(oPlayer)

    oPlayer.m_oActiveCtrl:SetNowWarInfo({
        now_war = self.m_iWarId,
    })
    local iWid = self:DispatchWarriorId()
    self.m_mPlayers[oPlayer:GetPid()] = iWid
    oPlayer:Send("GS2CShowWar", {war_id = self.m_iWarId})
    interactive.Send(self.m_iRemoteAddr, "war", "EnterPlayer", {war_id = self.m_iWarId, wid = iWid, pid = oPlayer:GetPid(), camp_id = mInfo.camp_id, mail = oPlayer:MailAddr()})
    return true
end

function CWar:ReEnterPlayer(oPlayer)
    oPlayer:Send("GS2CShowWar", {war_id = self.m_iWarId})
    interactive.Send(self.m_iRemoteAddr, "war", "ReEnterPlayer", {war_id = self.m_iWarId, pid = oPlayer:GetPid(), mail = oPlayer:MailAddr()})
    return true
end

function CWar:WarPrepare(mInfo)
    interactive.Send(self.m_iRemoteAddr, "war", "WarPrepare", {war_id = self.m_iWarId, info = mInfo})
    return true
end

function CWar:WarStart(mInfo)
    interactive.Send(self.m_iRemoteAddr, "war", "WarStart", {war_id = self.m_iWarId, info = mInfo})
    return true
end

function CWar:NotifyDisconnected(oPlayer)
    interactive.Send(self.m_iRemoteAddr, "war", "NotifyDisconnected", {war_id = self.m_iWarId, pid = oPlayer:GetPid()})
    return true
end

function CWar:Forward(sCmd, iPid, mData)
    interactive.Send(self.m_iRemoteAddr, "war", sCmd, {pid = iPid, war_id = self.m_iWarId, data = mData})
    return true
end
