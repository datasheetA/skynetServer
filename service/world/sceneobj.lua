--import module

local global = require "global"
local skynet = require "skynet"
local interactive = require "base.interactive"

local gamedefines = import(lualib_path("public.gamedefines"))

function NewSceneMgr(...)
    local o = CSceneMgr:New(...)
    return o
end

function NewScene(...)
    local o = CScene:New(...)
    return o
end


CSceneMgr = {}
CSceneMgr.__index = CSceneMgr
inherit(CSceneMgr, logic_base_cls())

function CSceneMgr:New(lSceneRemote)
    local o = super(CSceneMgr).New(self)
    o.m_iDispatchId = 0
    o.m_lSceneRemote = lSceneRemote
    o.m_mScenes = {}

    o.m_mDurableScenes = {}
    return o
end

function CSceneMgr:Release()
    for _, v in pairs(self.m_mScenes) do
        v:Release()
    end
    self.m_mScenes = {}
    super(CSceneMgr).Release(self)
end

function CSceneMgr:DispatchSceneId()
    self.m_iDispatchId = self.m_iDispatchId + 1
    return self.m_iDispatchId
end

function CSceneMgr:SelectRemoteScene()
    local l = self.m_lSceneRemote
    return l[math.random(#l)]
end

function CSceneMgr:SelectDurableScene(iMapId)
    local m = self.m_mDurableScenes[iMapId]
    local iTargetId
    if m then
        --iTargetId = m[math.random(#m)]
        iTargetId = m[1]
    end
    if iTargetId then
        return self:GetScene(iTargetId)
    end
end

function CSceneMgr:CreateScene(mInfo)
    local id = self:DispatchSceneId()
    local oScene = NewScene(id, mInfo)
    oScene:ConfirmRemote()
    self.m_mScenes[id] = oScene

    if oScene:IsDurable() then
        local iMapId = oScene:MapId()
        local m = self.m_mDurableScenes[iMapId]
        if not m then
            self.m_mDurableScenes[iMapId] = {}
            m = self.m_mDurableScenes[iMapId] 
        end
        table.insert(m, oScene:GetSceneId())
    end

    return oScene
end

function CSceneMgr:GetScene(id)
    return self.m_mScenes[id]
end

function CSceneMgr:RemoveScene(id)
    local oScene = self.m_mScenes[id]
    if oScene then
        oScene:Release()
        self.m_mScenes[id] = nil
    end
end

function CSceneMgr:GetSceneListByMap(iMapId)
    local mScene = self.m_mDurableScenes[iMapId] or {}
    local mSceneObj = {}
    for _,iScene in pairs(mScene) do
        local oScene = self:GetScene(iScene)
        table.insert(mSceneObj,oScene)
    end
    return mSceneObj
end

function CSceneMgr:OnEnterWar(oPlayer)
    local oNowScene = oPlayer.m_oActiveCtrl:GetNowScene()
    if oNowScene then
        oNowScene:NotifyEnterWar(oPlayer)
    end
end

function CSceneMgr:OnLeaveWar(oPlayer)
    local oNowScene = oPlayer.m_oActiveCtrl:GetNowScene()
    if oNowScene then
        oNowScene:NotifyLeaveWar(oPlayer)
    end
end

function CSceneMgr:OnDisconnected(oPlayer)
    local oNowScene = oPlayer.m_oActiveCtrl:GetNowScene()
    if oNowScene then
        oNowScene:NotifyDisconnected(oPlayer)
    end
end

function CSceneMgr:OnLogout(oPlayer)
    self:LeaveScene(oPlayer, true)
end

function CSceneMgr:OnLogin(oPlayer, bReEnter)
    if bReEnter then
        self:ReEnterScene(oPlayer)
    else
        --lxldebug test
        local mDurableInfo = oPlayer.m_oActiveCtrl:GetDurableSceneInfo()
        local iMapId = mDurableInfo.map_id
        local mPos = mDurableInfo.pos
        local oScene = self:SelectDurableScene(iMapId)
        self:EnterScene(oPlayer, oScene:GetSceneId(), {pos = mPos}, true)
    end
end

function CSceneMgr:ReEnterScene(oPlayer)
    local oNowScene = oPlayer.m_oActiveCtrl:GetNowScene()
    oNowScene:ReEnterPlayer(oPlayer)
    return {errcode = gamedefines.ERRCODE.ok}
end

function CSceneMgr:LeaveScene(oPlayer, bForce)
    local oNowScene = oPlayer.m_oActiveCtrl:GetNowScene()
    if not oNowScene then
        return {errcode = gamedefines.ERRCODE.ok}
    end
    if not bForce then
        if not oNowScene:VaildLeave(oPlayer) then
            return {errcode = gamedefines.ERRCODE.common}
        end
    end
    oNowScene:LeavePlayer(oPlayer)
    return {errcode = gamedefines.ERRCODE.ok}
end

function CSceneMgr:EnterScene(oPlayer, iScene, mInfo, bForce)
    local oNewScene = self:GetScene(iScene)
    assert(oNewScene, string.format("EnterScene error %d", iScene))
    local oNowScene = oPlayer.m_oActiveCtrl:GetNowScene()

    if not bForce then
        if oNowScene and not oNowScene:VaildLeave(oPlayer) then
            return {errcode = gamedefines.ERRCODE.common}
        end
        if not oNewScene:VaildEnter(oPlayer) then
            return {errcode = gamedefines.ERRCODE.common}
        end
    end

    if oNowScene then
        oNowScene:LeavePlayer(oPlayer)
    end
    oNewScene:EnterPlayer(oPlayer, mInfo.pos)

    return {errcode = gamedefines.ERRCODE.ok}
end

function CSceneMgr:RemoteEvent(sEvent, mData)
    return true
end


CScene = {}
CScene.__index = CScene
inherit(CScene, logic_base_cls())

function CScene:New(id, mInfo)
    local o = super(CScene).New(self)
    o.m_iSceneId = id
    o.m_iRemoteAddr = nil
    o.m_iDispatchId = 0
    o.m_iMapId = mInfo.map_id
    o.m_bIsDurable = mInfo.is_durable

    o.m_mPlayers = {}
    o.m_mNpc = {}

    return o
end

function CScene:Release()
    interactive.Send(self.m_iRemoteAddr, "scene", "RemoveRemote", {scene_id = self.m_iSceneId})
    super(CScene).Release(self)
end

function CScene:GetSceneId()
    return self.m_iSceneId
end

function CScene:DispatchEntityId()
    self.m_iDispatchId = self.m_iDispatchId + 1
    return self.m_iDispatchId
end

function CScene:MapId()
    return self.m_iMapId
end

function CScene:IsDurable()
    return self.m_bIsDurable
end

function CScene:ConfirmRemote()
    local oSceneMgr = global.oSceneMgr
    local iRemoteAddr = oSceneMgr:SelectRemoteScene()
    self.m_iRemoteAddr = iRemoteAddr
    interactive.Send(iRemoteAddr, "scene", "ConfirmRemote", {scene_id = self.m_iSceneId})
end

function CScene:VaildLeave(oPlayer)
    return true
end

function CScene:VaildEnter(oPlayer)
    return true
end

function CScene:LeavePlayer(oPlayer)
    oPlayer.m_oActiveCtrl:ClearNowSceneInfo()
    self.m_mPlayers[oPlayer:GetPid()] = nil
    interactive.Send(self.m_iRemoteAddr, "scene", "LeavePlayer", {scene_id = self.m_iSceneId, pid = oPlayer:GetPid()})
    return true
end

function CScene:EnterPlayer(oPlayer, mPos)
    oPlayer.m_oActiveCtrl:SetNowSceneInfo({
        now_scene = self.m_iSceneId,
        now_pos = mPos,
    })
    if self:IsDurable() then
        oPlayer.m_oActiveCtrl:SetDurableSceneInfo(self.m_iMapId, mPos)
    end
    local iEid = self:DispatchEntityId()
    self.m_mPlayers[oPlayer:GetPid()] = iEid
    oPlayer:Send("GS2CShowScene", {scene_id = self.m_iSceneId, map_id = self:MapId()})
    interactive.Send(self.m_iRemoteAddr, "scene", "EnterPlayer", {scene_id = self.m_iSceneId, eid = iEid, pid = oPlayer:GetPid(), pos = mPos, mail = oPlayer:MailAddr()})
    return true
end

function CScene:ReEnterPlayer(oPlayer)
    oPlayer:Send("GS2CShowScene", {scene_id = self.m_iSceneId, map_id = self:MapId()})
    interactive.Send(self.m_iRemoteAddr, "scene", "ReEnterPlayer", {scene_id = self.m_iSceneId, pid = oPlayer:GetPid(), mail = oPlayer:MailAddr()})
    return true
end

function CScene:NotifyDisconnected(oPlayer)
    interactive.Send(self.m_iRemoteAddr, "scene", "NotifyDisconnected", {scene_id = self.m_iSceneId, pid = oPlayer:GetPid()})
    return true
end

function CScene:NotifyEnterWar(oPlayer)
    interactive.Send(self.m_iRemoteAddr, "scene", "NotifyEnterWar", {scene_id = self.m_iSceneId, pid = oPlayer:GetPid()})
    return true
end

function CScene:NotifyLeaveWar(oPlayer)
    interactive.Send(self.m_iRemoteAddr, "scene", "NotifyLeaveWar", {scene_id = self.m_iSceneId, pid = oPlayer:GetPid()})
    return true
end

function CScene:Forward(sCmd, iPid, mData)
    interactive.Send(self.m_iRemoteAddr, "scene", "Forward", {pid = iPid, scene_id = self.m_iSceneId, cmd = sCmd, data = mData})
    return true
end

function CScene:EnterNpc(oNpc)
    local iEid = self:DispatchEntityId()
    self.m_mNpc[oNpc.m_ID] = iEid
    local mData = oNpc:PackInfo()
    local mPos = oNpc:PosInfo()
    interactive.Send(self.m_iRemoteAddr, "scene", "EnterNpc", {scene_id = self.m_iSceneId, eid = iEid,pos=mPos,data=mData})
end

function CScene:SyncNpcInfo(oNpc,mArgs)
    local iEid = self.m_mNpc[oNpc.m_ID]
    interactive.Send(self.m_iRemoteAddr, "scene", "SyncNpcInfo", {scene_id = self.m_iSceneId, eid = iEid,mArgs=mArgs})
end

function CScene:RemoveSceneNpc(npcid)
    local iEid = self.m_mNpc[npcid]
    assert(iEid,string.format("RemoveSceneNpc npcid err:%d",npcid))
    interactive.Send(self.m_iRemoteAddr,"scene","RemoveSceneNpc",{scene_id = self.m_iSceneId,eid=iEid})
end
