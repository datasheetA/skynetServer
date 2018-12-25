--import module
local global = require "global"

function NewUIMgr()
    local o = CUIMgr:New()
    return o
end

CUIMgr = {}
CUIMgr.__index = CUIMgr
inherit(CUIMgr, logic_base_cls())

function CUIMgr:New()
    local o = super(CUIMgr).New(self)
    return o
end

function CUIMgr:GS2CShortWay(pid,iType)
    local mNet = {}
    mNet["type"] = iType
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(pid)
    if oPlayer then
        oPlayer:Send("GS2CShortWay",mNet)
    end
end