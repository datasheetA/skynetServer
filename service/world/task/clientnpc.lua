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
    self.m_iMapid = mArgs["map_id"] or 0
    self.m_mModel = mArgs["model_info"] or {}
    self.m_mPosInfo = mArgs["pos_info"] or {}

    self.m_iEvent = mArgs["event"] or 0
    self.m_iReUse = mArgs["reuse"]
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
            pos_info = self.m_PosInfo,
            model_info = self.m_mModel,
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