--import module

local global = require "global"

function NewNotifyMgr(...)
    return CNotifyMgr:New(...)
end


CNotifyMgr = {}
CNotifyMgr.__index = CNotifyMgr
inherit(CNotifyMgr,logic_base_cls())

function CNotifyMgr:New()
    local o = super(CNotifyMgr).New(self)
    return o
end

function CNotifyMgr:Notify(iPid, sMsg)
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(iPid)
    if oPlayer then
        oPlayer:Send("GS2CNotify", {
            cmd = sMsg,
        })
    end
end
