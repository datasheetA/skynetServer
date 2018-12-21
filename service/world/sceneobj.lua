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

function CSceneMgr:New(lSceneRemote)
    local o = setmetatable({}, self)
    o.m_iDispatchId = 0
    o.m_lSceneRemote = lSceneRemote
    o.m_mScenes = {}

    o.m_mDurableScenes = {}
    return o
end

function CSceneMgr:Release()
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

function CSceneMgr:OnLogin(oPlayer, bReEnter)
    if bReEnter then
        self:ReEnterScene(oPlayer)
    else
        --lxldebug test
        local iMapId = 1001
        local mPos = {x = 100, y = 100, z = 0, face_x = 0, face_y = 0, face_z = 0}
        local oScene = self:SelectDurableScene(iMapId)
        self:EnterScene(oPlayer, oScene:GetSceneId(), {pos = mPos}, true)
    end
end

function CSceneMgr:ReEnterScene(oPlayer)
    local oNowScene = oPlayer:GetNowScene()
    oNowScene:ReEnterPlayer(oPlayer)
    return {errcode = gamedefines.ERRCODE.ok}
end

function CSceneMgr:LeaveScene(oPlayer, bForce)
    local oNowScene = oPlayer:GetNowScene()
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
    local oNowScene = oPlayer:GetNowScene()

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


CScene = {}
CScene.__index = CScene

function CScene:New(id, mInfo)
    local o = setmetatable({}, self)
    o.m_iSceneId = id
    o.m_iDispatchId = 0
    o.m_iMapId = mInfo.map_id
    o.m_bIsDurable = mInfo.is_durable

    o.m_mPlayers = {}

    return o
end

function CScene:Release()
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
    self.m_mPlayers[oPlayer:GetPid()] = nil
    interactive.Send(self.m_iRemoteAddr, "scene", "LeavePlayer", {scene_id = self.m_iSceneId, pid = oPlayer:GetPid()})
    return true
end

function CScene:EnterPlayer(oPlayer, mPos)
    oPlayer:SetSceneInfo({
        now_scene = self.m_iSceneId,
        now_pos = mPos,
    })
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

function CScene:SyncPos(iEid, iPid, mPos)
    if self.m_mPlayers[iPid] == iEid then
        interactive.Send(self.m_iRemoteAddr, "scene", "SyncPlayerPos", {scene_id = self.m_iSceneId, pid = iPid, pos_info = mPos})
    end
end
