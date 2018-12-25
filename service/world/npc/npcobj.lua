--import module
local global = require "global"

local npcnet = import(service_path("netcmd/npc"))

CNpc = {}
CNpc.__index = CNpc
inherit(CNpc,logic_base_cls())

function CNpc:New(type)
    local o = super(CNpc).New(self)
    o.m_iType = type
    o:Init()
    return o
end

function CNpc:Init()
    self:InitObject()
    local mData = self:GetData()
    self.m_sName = mData["name"]
    self.m_sTitle = mData["title"]
    self.m_iMapid = mData["sceneId"]

    local mModel = {
        shape = mData["modelId"],
        adorn = mData["ornamentId"],
        weapon = mData["wpmodel"],
        color = mData["mutateColor"],
        mutate_texture = mData["mutateTexture"],
        scale = mData["scale"]
    }
    self.m_mModel = mModel

    self.m_iDialog = mData["dialogId"]
    local mPosInfo = {
            x = mData["x"],
            y = mData["y"],
            z = mData["z"],
            face_x = mData["face_x"] or 0,
            face_y = mData["face_y"] or 0,
            face_z = mData["face_z"] or 0
    }
    self.m_PosInfo = mPosInfo
end

function CNpc:InitObject()
    local oNpcMgr = global.oNpcMgr
    local id = oNpcMgr:DispatchId()
    self.m_ID = id
end

function CNpc:Release()
    -- body
end

function CNpc:SetScene(iScene)
    self.m_Scene = iScene
end

function CNpc:GetData()
    local res = require "base.res"
    return res["daobiao"]["global_npc"][self.m_iType]
end

function CNpc:do_look(oPlayer)
end

function CNpc:Say(pid,sText)
    local mNet = {}
    mNet["shape"] = self:Shape()
    mNet["name"] = self:Name()
    mNet["text"] = sText
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(pid)
    if oPlayer then
        oPlayer:Send("GS2CNpcSay",mNet)
    end
end

--需要客户端回应
function CNpc:SayRespond(pid,sText,fResCb,fCallBack)
    local mNet = {}
    mNet["shape"] = self:Shape()
    mNet["name"] = self:Name()
    mNet["text"] = sText
    local oCbMgr = global.oCbMgr
    oCbMgr:SetCallBack(pid,"GS2CNpcSay",mNet,fResCb,fCallBack)
end

function CNpc:Name()
    return self.m_sName
end

function CNpc:Type()
    return self.m_iType
end

function CNpc:Shape()
    return self.m_mModel["shape"]
end

function CNpc:PosInfo()
    return self.m_PosInfo
end

function CNpc:MapId()
    return self.m_iMapid
end

function CNpc:Dialog()
    local res = require "base.res"
    local iDialog = self.m_iDialog
    local mDialog = res["daobiao"]["dialog_npc"][iDialog]
    local iNo = math.random(3) + 1
    local sDialog = mDialog[iNo]
    return sDialog
end

function CNpc:PackSceneInfo()
    local mInfo = {
        npctype  = self.m_iType,
        npcid = self.m_ID,
        model_info = self.m_mModel,
        scale = self.m_iScale
    }
    return mInfo
end

--同步信息去场景
function CNpc:SyncSceneInfo(mInfo)
    local iScene = self.m_Scene
    local oSceneMgr = global.oSceneMgr
    local oScene = oSceneMgr:GetScene(iScene)
    if oScene then
        oScene:SyncNpcInfo(self,mInfo)
    end
end

function NewNpc(npctype)
    local o = CNpc:New(npctype)
    return o
end

