--import module
local global = require "global"

function NewPubMgr()
    local o = CPublicMgr:New()
    return o
end

CPublicMgr = {}
CPublicMgr.__index = CPublicMgr
inherit(CPublicMgr, logic_base_cls())

function CPublicMgr:New()
    local o = super(CPublicMgr).New(self)
    return o
end

function CPublicMgr:OnlineExecute(pid,sFunc,mArgs)
    local oWorldMgr = global.oWorldMgr
    oWorldMgr:LoadRW(pid,function (oRW)
        oRW:AddFunc(sFunc,mArgs)
    end)
end