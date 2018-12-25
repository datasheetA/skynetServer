--import module
local global = require "global"

CClientNpc = {}
CClientNpc.__index = CClientNpc
inherit(CClientNpc,logic_base_cls())

function CClientNpc:New(mArgs)
    local o = super(CClientNpc).New(self)
    o:Init(mArgs)
    return o
end

function CClientNpc:Init(mArgs)
    self:InitObject()
    local mArgs = mArgs or {}
    self.m_iType = mArgs["type"]
    self.m_sName = mArgs["name"] or ""
    self.m_sTitle = mArgs["title"] or ""
    self.m_iModel = mArgs["modelId"] or 0
    self.m_iWeapon = mArgs["wpmodel"] or 0
    self.m_imutateTexture = mArgs["mutateTexture"] or 0
    self.m_iAdorn = mArgs["ornamentId"] or 0
    self.m_iMapid = mArgs["sceneId"] or 0
    self.m_iScale = mArgs["scale"] or 0
    self.m_mColor = mArgs["mutateColor"] or 0
    self.m_iReUse = mArgs["reuse"] or {}
    self.m_iEvent = mArgs["event"] or 0
    local mPosInfo = {
            x = mArgs["x"] or 0,
            y = mArgs["y"] or 0,
            z = mArgs["z"] or 0,
            face_x = mArgs["face_x"] or 0,
            face_y = mArgs["face_y"] or 0,
            face_z = mArgs["face_z"] or 0
    }
    self.m_PosInfo = mPosInfo
end

function CClientNpc:InitObject()
    local oNpcMgr = global.oNpcMgr
    self.m_ID = oNpcMgr:DispatchId()
end

function CClientNpc:Release()
    -- body
end

function CClientNpc:Save()
    local data = {}
    data["Type"] = self.m_iType
    data["Name"] = self.m_sName
    data["Title"] = self.m_sTitle
    data["Model"] = self.m_iModel
    data["ReUse"]  = self.m_iReUse
    data["Color"] = self.m_mColor
    data["Map"] = self.m_iMapid
    data["Pos"] = self.m_PosInfo
    data["Event"] = self.m_iEvent
    if self.m_iWeapon > 0 then
        data["Weapon"] = self.m_iWeapon
    end
    if self.m_imutateTexture > 0 then
        data["mutate"] = self.m_imutateTexture
    end
    if self.m_iAdorn > 0 then
        data["adorn"] = self.m_iAdorn
    end
    if self.m_iScale ~= 0 then
        data["scale"] = self.m_iScale
    end
    return data
end

function CClientNpc:PackInfo()
    local mDesc = {
        scale = self.m_iScale ,
        color = self.m_mColor,
        mutateTexture = self.m_imutateTexture,
        adorn = self.m_iAdorn,
        weapon = self.m_iWeapon,
    }
    local mData = {
            npctype = self.m_iType,
            npcid      = self.m_ID,
            name = self.m_sName,
            title = self.m_sTitle,
            map_id = self.m_iMapid,
            pos_info = self.m_PosInfo,
             model_info = self.m_iModel,
            desc = mDesc,
    }
    return mData
end

function CClientNpc:Type()
    return self.m_iType
end

function CClientNpc:Name()
    return self.m_sName
end

function CClientNpc:SetEvent(iEvent)
    self.m_iEvent = iEvent
end

function NewClientNpc(mArgs)
    local o = CClientNpc:New(mArgs)
    return o
end