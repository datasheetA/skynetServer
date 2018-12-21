--import module
local skynet = require "skynet"

CDataCtrl = {}
CDataCtrl.__index = CDataCtrl
inherit(CDataCtrl, logic_base_cls())

function CDataCtrl:New(mInfo)
    local o = super(CDataCtrl).New(self)

    o.m_mInfo = mInfo or {}
    o.m_mData = {}
    o.m_bIsDirty = false

    return o
end

function CDataCtrl:SetInfo(k, v)
    self.m_mInfo[k] = v
end

function CDataCtrl:GetInfo(k, rDefault)
    return self.m_mInfo[k] or rDefault
end

function CDataCtrl:SetData(k, v)
    self.m_mData[k] = v
    self:Dirty()
end

function CDataCtrl:GetData(k, rDefault)
    return self.m_mData[k] or rDefault
end

function CDataCtrl:Load(m)
end

function CDataCtrl:Save()
end

function CDataCtrl:IsDirty()
    return self.m_bIsDirty
end

function CDataCtrl:Dirty()
    self.m_bIsDirty = true
end

function CDataCtrl:UnDirty()
    self.m_bIsDirty = false
end
