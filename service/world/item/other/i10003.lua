local global = require "global"
local skynet = require "skynet"

local itembase = import(service_path("item/other/otherbase"))

function NewItem(sid)
    local o = CItem:New(sid)
    return o
end

CItem = {}
CItem.__index = CItem
inherit(CItem,itembase.CItem)

function CItem:New(sid)
    local o = super(CItem).New(self,sid)
    return o
end

function CItem:TrueUse(who,target)
    local iCostAmount = self:GetUseCostAmount()
    self:AddAmount(-iCostAmount,"itemuse")
    who:RewardExp(3000,"人物经验书")
end