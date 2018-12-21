local global = require "global"
local skynet = require "skynet"

local virtualbase = import(service_path("item/virtual/virtualbase"))

CItem = {}
CItem.__index = CItem
inherit(CItem,virtualbase.CItem)

function CItem:Reward(oPlayer)
    local iValue = self:GetData("Value")
    if not iValue then
        return
    end
    local oWorldMgr = global.oWorldMgr
    oWorldMgr:LoadRW(oPlayer.m_iPid,function (oRW)
    	oRW:AddGoldCoin(iValue,"虚拟道具")
    end)
end

function NewItem(sid)
    local o = CItem:New(sid)
    return o
end