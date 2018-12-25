--import module
--与客户端回调管理
local global = require "global"
local extend = require "base.extend"

local timeop = import(lualib_path("base.timeop"))

function NewCBMgr()
    local oMgr = CCBMgr:New()
    return oMgr
end

CCBMgr = {}
CCBMgr.__index = CCBMgr
inherit(CCBMgr,logic_base_cls())

function CCBMgr:New()
    local o = super(CCBMgr).New(self)
    o.m_iSessionIdx = 0
    o.m_mCallBack = {}
    return o
end

function CCBMgr:GetSession()
    self.m_iSessionIdx = self.m_iSessionIdx + 1
    if self.m_iSessionIdx >= 1000000000 then
        self.m_iSessionIdx = 1
    end
    return self.m_iSessionIdx
end

function CCBMgr:GS2CDialog(pid,mNet)
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(pid)
    if oPlayer then
        oPlayer:Send("GS2CDialog",mNet)
    end
end

--[[
1.使用任务道具taskitem
]]
function CCBMgr:GS2CLoadUI(pid,mNet)
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(pid)
    if oPlayer then
        oPlayer:Send("GS2CLoadUI",mNet)
    end
end

--[[
npc回调
]]
function CCBMgr:GS2CNpcSay(pid,mNet)
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(pid)
    if oPlayer then
        oPlayer:Send("GS2CNpcSay",mNet)
    end
end

function CCBMgr:GS2CPopTaskItem(pid,mNet)
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(pid)
    if oPlayer then
        oPlayer:Send("GS2CPopTaskItem",mNet)
    end
end

function CCBMgr:SetCallBack(pid,sCmd,mData,fResCallBack,fCallback)
    local iSessionIdx = self:GetSession()
    mData["sessionidx"] = iSessionIdx
    local func = self[sCmd]
    assert(func,string.format("Callback err:%d %s",pid,sCmd))
    func(self,pid,mData)
    if not fCallback then
        return
    end
    self.m_mCallBack[iSessionIdx] = {pid,fResCallBack,fCallback,timeop.get_time()}
end

function CCBMgr:GetCallBack(iSessionIdx)
    return self.m_mCallBack[iSessionIdx]
end

function CCBMgr:CallBack(oPlayer,iSessionIdx,mData)
    local pid = oPlayer.m_iPid
    local mCallBack = self:GetCallBack(iSessionIdx)
    local iOwner,fResCallBack,fCallback = table.unpack(mCallBack)
    assert(iOwner==pid,string.format("Callback err %d %d %d",iSessionIdx,pid,iOwner))
    if fResCallBack then
        if not fResCallBack(oPlayer,mData) then
            return
        end
    end
    if not fCallback then
        return
    end
    fCallback(oPlayer,mData)
end