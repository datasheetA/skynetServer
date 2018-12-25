--import module
local global = require "global"
local geometry = require "base.geometry"

local npcobj = import(service_path("npc/npcobj"))

CClientNpc = {}
CClientNpc.__index = CClientNpc
inherit(CClientNpc,npcobj.CNpc)

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
    self.m_iMapid = mArgs["map_id"] or 0
    self.m_mModel = mArgs["model_info"] or {}
    self.m_mPosInfo = mArgs["pos_info"] or {}

    self.m_iEvent = mArgs["event"] or 0
    self.m_iReUse = mArgs["reuse"]
end

function CClientNpc:Release()
    -- body
end

function CClientNpc:Save()
    local data = {}
    data["type"] = self.m_iType
    data["name"] = self.m_sName
    data["title"] = self.m_sTitle
    data["map_id"] = self.m_iMapid
    data["model_info"] = self.m_mModel
    data["pos_info"] = self.m_mPosInfo

    data["reuse"]  = self.m_iReUse
    data["event"] = self.m_iEvent
    return data
end

function CClientNpc:PackInfo()
    local mData = {
            npctype = self.m_iType,
            npcid      = self.m_ID,
            name = self.m_sName,
            title = self.m_sTitle,
            map_id = self.m_iMapid,
            pos_info = self:GetPos(),
            model_info = self.m_mModel,
    }
    return mData
end

function CClientNpc:SetEvent(iEvent)
    self.m_iEvent = iEvent
end

function CClientNpc:GetPos()
    local mPos = self.m_mPosInfo
    pos_info = {
            x = math.floor(geometry.Cover(mPos.x)),
            y = math.floor(geometry.Cover(mPos.y)),
            z = math.floor(geometry.Cover(mPos.z)),
            face_x = math.floor(geometry.Cover(mPos.face_x)),
            face_y = math.floor(geometry.Cover(mPos.face_y)),
            face_z = math.floor(geometry.Cover(mPos.face_z)),
        }
        return pos_info
end

function NewClientNpc(mArgs)
    local o = CClientNpc:New(mArgs)
    return o
end