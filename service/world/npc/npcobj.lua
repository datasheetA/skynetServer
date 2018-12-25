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
    self.m_iModel = mData["modelId"]
    self.m_iDialog = mData["dialogId"]
    self.m_iWeapon = mData["wpmodel"]
    self.m_imutateTexture = mData["mutateTexture"]
    self.m_iAdorn = mData["ornamentId"]
    self.m_iMapid = mData["sceneId"]
    self.m_mColor = mData["mutateColor"]
    self.m_iScale = mData["scale"]
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

function CNpc:Release( ... )
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

function CNpc:Respond(...)
end

function CNpc:Say(pid,sText)
    npcnet.GS2CNpcObjSay(pid,self,sText)
end

function CNpc:Name()
    return self.m_sName
end

function CNpc:Model()
    return self.m_iModel
end

function CNpc:Type()
    return self.m_iType
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
        model_info = {
            shape = self.m_iModel,
            name = self.m_Name,
            color = self.m_mColor,
            mutate_texture = self.m_imutateTexture,
            weapon = self.m_iWeapon,
            adorn = self.m_iAdorn,
        },
        scale = self.m_iScale
    }
    return mInfo
end

function CNpc:PosInfo()
    return self.m_PosInfo
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

